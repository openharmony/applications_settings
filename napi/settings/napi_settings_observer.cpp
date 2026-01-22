/*
 * Copyright (c) 2023-2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "napi_settings_observer.h"

#include <map>

#include "napi_settings_log.h"
#include "abs_shared_result_set.h"
#include "values_bucket.h"
#include "uv.h"

#include "napi_base_context.h"
#include "os_account_manager.h"


using namespace OHOS::AppExecFwk;
using namespace OHOS::DataShare;
using namespace OHOS::AccountSA;


namespace OHOS {
namespace Settings {
    std::map<std::string, sptr<SettingsObserver>> g_observerMap;
    std::recursive_mutex g_observerMapMutex;

    SettingsObserver::~SettingsObserver()
    {
        if (this->cbInfo == nullptr) {
            return;
        }
        delete this->cbInfo;
        this->cbInfo = nullptr;
    }

    bool IsExistObserver(SettingsObserver* settingsObserver) {
        for (auto it = g_observerMap.begin(); it != g_observerMap.end(); ++it) {
            if (&(*(it->second)) == settingsObserver) {
                return true;
            }
        }
        return false;
    }

    void SettingsObserver::DoEventWork(SettingsObserver *settingsObserver)
    {
        SETTING_LOG_INFO("n_s_o_c_a_l");
        std::lock_guard<std::recursive_mutex> lockGuard(g_observerMapMutex);
        if (!IsExistObserver(settingsObserver) || settingsObserver == nullptr || settingsObserver->cbInfo == nullptr ||
            settingsObserver->toBeDelete) {
            SETTING_LOG_ERROR("uv_work: cbInfo invalid.");
            return;
        }

        napi_handle_scope scope = nullptr;
        napi_open_handle_scope(settingsObserver->cbInfo->env, &scope);
        napi_value callback = nullptr;
        napi_value undefined;
        napi_get_undefined(settingsObserver->cbInfo->env, &undefined);
        napi_value error = nullptr;
        napi_create_object(settingsObserver->cbInfo->env, &error);
        int unSupportCode = 802;
        napi_value errCode = nullptr;
        napi_create_int32(settingsObserver->cbInfo->env, unSupportCode, &errCode);
        napi_set_named_property(settingsObserver->cbInfo->env, error, "code", errCode);
        napi_value result[PARAM2] = {0};
        result[0] = error;
        result[1] = wrap_bool_to_js(settingsObserver->cbInfo->env, false);
        napi_get_reference_value(settingsObserver->cbInfo->env, settingsObserver->cbInfo->callbackRef,
            &callback);
        napi_value callResult;
        napi_call_function(settingsObserver->cbInfo->env, undefined, callback, PARAM2, result,
            &callResult);
        napi_close_handle_scope(settingsObserver->cbInfo->env, scope);
        SETTING_LOG_INFO("%{public}s, uv_work success.", __func__);
    }

    void SettingsObserver::OnChange()
    {
        SETTING_LOG_INFO("n_s_o_cl");
        std::lock_guard<std::recursive_mutex> lockGuard(g_observerMapMutex);
        if (this->cbInfo == nullptr) {
            SETTING_LOG_ERROR("%{public}s, cbInfo is null.", __func__);
            return;
        }
        uv_loop_s* loop = nullptr;
        napi_get_uv_event_loop(cbInfo->env, &loop);
        if (loop == nullptr) {
            SETTING_LOG_ERROR("%{public}s, fail to get uv loop.", __func__);
            return;
        }
        auto work = new (std::nothrow) uv_work_t;
        if (work == nullptr) {
            SETTING_LOG_ERROR("%{public}s, fail to get uv work.", __func__);
            return;
        }
        work->data = reinterpret_cast<void*>(this);
        SettingsObserver* settingsObserver = reinterpret_cast<SettingsObserver*>(work->data);
        int ret = napi_send_event(cbInfo->env, std::bind(DoEventWork, settingsObserver), napi_eprio_high);
        if (ret != 0) {
            SETTING_LOG_ERROR("%{public}s, uv_queue_work failed.", __func__);
        }
        if (work != nullptr) {
            delete work;
            work = nullptr;
        }
    }

    int GetObserverIdStr()
    {
        int currentUserId = -1;
        OHOS::AccountSA::OsAccountManager::GetOsAccountLocalIdFromProcess(currentUserId);
        int tmpId = 100;
        if (currentUserId > 0) {
            tmpId = currentUserId;
            SETTING_LOG_INFO("userId is %{public}d", tmpId);
        } else if (currentUserId == 0) {
            OHOS::AccountSA::OsAccountManager::GetForegroundOsAccountLocalId(currentUserId);
            tmpId = currentUserId;
            SETTING_LOG_INFO("user0 userId is %{public}d", tmpId);
        } else {
            SETTING_LOG_INFO("%{public}s, user id 100.", __func__);
        }
        return tmpId;
    }

    void CleanObserverMap(std::string key)
    {
        std::lock_guard<std::recursive_mutex> lockGuard(g_observerMapMutex);
        g_observerMap[key]->toBeDelete = true;
        g_observerMap[key] = nullptr;
        g_observerMap.erase(key);
    }

    void CleanUp(void* data)
    {
        SETTING_LOG_INFO("CleanUp");
        if (data == nullptr) {
            SETTING_LOG_WARN("CleanUp, data nullptr");
            return;
        }
        AsyncCallbackInfo* callbackInfo = reinterpret_cast<AsyncCallbackInfo*>(data);
        std::lock_guard<std::recursive_mutex> lockGuard(g_observerMapMutex);
        if (g_observerMap.find(callbackInfo->key) != g_observerMap.end() &&
            g_observerMap[callbackInfo->key] != nullptr) {
            SETTING_LOG_WARN("CleanUp key is %{public}s", callbackInfo->key.c_str());
            CleanObserverMap(callbackInfo->key);
            napi_delete_reference(callbackInfo->env, callbackInfo->callbackRef);
            callbackInfo->env = nullptr;
            callbackInfo->callbackRef = nullptr;
            delete callbackInfo;
        }
    }

    napi_value npai_settings_register_observer(napi_env env, napi_callback_info info)
    {
        SETTING_LOG_INFO("n_s_r_o");
        // Check the number of the arguments
        size_t argc = ARGS_FOUR;
        napi_value args[ARGS_FOUR] = {nullptr};
        NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
        if (argc != ARGS_FOUR) {
            SETTING_LOG_ERROR("%{public}s, wrong number of arguments.", __func__);
            return wrap_bool_to_js(env, false);
        }

        // Check the value type of the arguments
        napi_valuetype valueType;
        NAPI_CALL(env, napi_typeof(env, args[PARAM0], &valueType));
        NAPI_ASSERT(env, valueType == napi_object, "Wrong argument[0] type. Object expected.");
        NAPI_CALL(env, napi_typeof(env, args[PARAM1], &valueType));
        NAPI_ASSERT(env, valueType == napi_string, "Wrong argument[1] type. String expected.");
        NAPI_CALL(env, napi_typeof(env, args[PARAM2], &valueType));
        NAPI_ASSERT(env, valueType == napi_string, "Wrong argument[2] type. String expected.");

        bool stageMode = false;
        if (napi_ok != OHOS::AbilityRuntime::IsStageContext(env, args[PARAM0], stageMode)) {
            SETTING_LOG_ERROR("%{public}s, not stage mode.", __func__);
            return wrap_bool_to_js(env, false);
        }
        AsyncCallbackInfo *callbackInfo = new AsyncCallbackInfo();
        if (callbackInfo == nullptr) {
            SETTING_LOG_ERROR("%{public}s, failed to get callbackInfo.", __func__);
            return wrap_bool_to_js(env, false);
        }

        std::lock_guard<std::recursive_mutex> lockGuard(g_observerMapMutex);
        callbackInfo->env = env;
        callbackInfo->key = unwrap_string_from_js(env, args[PARAM1]);
        callbackInfo->tableName = unwrap_string_from_js(env, args[PARAM2]);
        napi_create_reference(env, args[PARAM3], 1, &(callbackInfo->callbackRef));

        if (g_observerMap.find(callbackInfo->key) != g_observerMap.end() &&
        g_observerMap[callbackInfo->key] != nullptr) {
            SETTING_LOG_INFO("%{public}s, already registered.", __func__);
            napi_delete_reference(env, callbackInfo->callbackRef);
            delete callbackInfo;
            return wrap_bool_to_js(env, false);
        }
        auto contextS = OHOS::AbilityRuntime::GetStageModeContext(env, args[PARAM0]);
        if (contextS == nullptr) {
            SETTING_LOG_ERROR("get context is error.");
            delete callbackInfo;
            return wrap_bool_to_js(env, false);
        }
        auto dataShareHelper = getDataShareHelper(env, contextS->GetToken(), stageMode, callbackInfo->tableName);
        if (dataShareHelper == nullptr) {
            napi_delete_reference(env, callbackInfo->callbackRef);
            delete callbackInfo;
            return wrap_bool_to_js(env, false);
        }

        std::string strUri = GetStageUriStr(callbackInfo->tableName, GetObserverIdStr(), callbackInfo->key);
        OHOS::Uri uri(strUri);
        sptr<SettingsObserver> settingsObserver = sptr<SettingsObserver>
        (new (std::nothrow)SettingsObserver(callbackInfo));
        g_observerMap[callbackInfo->key] = settingsObserver;
        napi_add_env_cleanup_hook(env, CleanUp, callbackInfo);
        dataShareHelper->RegisterObserver(uri, settingsObserver);
        dataShareHelper->Release();
		
        return wrap_bool_to_js(env, true);
    }

    napi_value npai_settings_unregister_observer(napi_env env, napi_callback_info info)
    {
        SETTING_LOG_INFO("n_s_u_o");
        // Check the number of the arguments
        size_t argc = ARGS_THREE;
        napi_value args[ARGS_THREE] = {nullptr};
        NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
        if (argc != ARGS_THREE) {
            SETTING_LOG_ERROR("%{public}s, wrong number of arguments.", __func__);
            return wrap_bool_to_js(env, false);
        }
        // Check the value type of the arguments
        napi_valuetype valueType;
        NAPI_CALL(env, napi_typeof(env, args[PARAM0], &valueType));
        NAPI_ASSERT(env, valueType == napi_object, "Wrong argument[0] type. Object expected.");
        NAPI_CALL(env, napi_typeof(env, args[PARAM1], &valueType));
        NAPI_ASSERT(env, valueType == napi_string, "Wrong argument[1] type. String expected.");
        NAPI_CALL(env, napi_typeof(env, args[PARAM2], &valueType));
        NAPI_ASSERT(env, valueType == napi_string, "Wrong argument[2] type. String expected.");

        bool stageMode = false;
        if (napi_ok != OHOS::AbilityRuntime::IsStageContext(env, args[PARAM0], stageMode)) {
            SETTING_LOG_ERROR("%{public}s, not stage mode.", __func__);
            return wrap_bool_to_js(env, false);
        }

        std::string key = unwrap_string_from_js(env, args[PARAM1]);
        std::string tableName = unwrap_string_from_js(env, args[PARAM2]);
        
        std::lock_guard<std::recursive_mutex> lockGuard(g_observerMapMutex);
        if (g_observerMap.find(key) == g_observerMap.end()) {
            SETTING_LOG_ERROR("%{public}s, null.", __func__);
            return wrap_bool_to_js(env, false);
        }
        
        if (g_observerMap[key] == nullptr) {
            g_observerMap.erase(key);
            return wrap_bool_to_js(env, false);
        }
        auto contextS = OHOS::AbilityRuntime::GetStageModeContext(env, args[PARAM0]);
        if (contextS == nullptr) {
            SETTING_LOG_ERROR("get context is error.");
            return wrap_bool_to_js(env, false);
        }
        auto dataShareHelper = getDataShareHelper(env, contextS->GetToken(), stageMode, tableName);
        if (dataShareHelper == nullptr) {
            SETTING_LOG_ERROR("%{public}s, data share is null.", __func__);
            return wrap_bool_to_js(env, false);
        }
        std::string strUri = GetStageUriStr(tableName, GetObserverIdStr(), key);
        napi_remove_env_cleanup_hook(env, CleanUp, g_observerMap[key]->cbInfo);
        napi_delete_reference(g_observerMap[key]->cbInfo->env, g_observerMap[key]->cbInfo->callbackRef);
        dataShareHelper->UnregisterObserver(OHOS::Uri(strUri), g_observerMap[key]);
        dataShareHelper->Release();
        CleanObserverMap(key);
		
        return wrap_bool_to_js(env, true);
    }
}
}