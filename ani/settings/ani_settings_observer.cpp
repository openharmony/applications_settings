/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

#include <map>
#include "ani_settings_observer.h"
#include "ani_settings_log.h"
#include "abs_shared_result_set.h"
#include "values_bucket.h"
#include "ani_base_context.h"
#include "os_account_manager.h"

using namespace OHOS::AppExecFwk;
using namespace OHOS::DataShare;
using namespace OHOS::AccountSA;

namespace OHOS {
namespace Settings {
std::map<std::string, sptr<SettingsObserver>> g_observerMap;
std::mutex g_observerMapMutex;

SettingsObserver::~SettingsObserver()
{
    if (this->cbInfo == nullptr) {
        return;
    }
    delete this->cbInfo;
    this->cbInfo = nullptr;
}

bool IsExistObserver(SettingsObserver *settingsObserver)
{
    for (auto it = g_observerMap.begin(); it != g_observerMap.end(); ++it) {
        if (&(*(it->second)) == settingsObserver) {
            return true;
        }
    }
    return false;
}

ani_object BoolToObject(ani_env *env, bool value)
{
    ani_object aniObject = nullptr;
    ani_boolean boolValue = static_cast<bool>(value);
    const char *className = "Lstd/core/Boolean;";
    ani_class aniClass;
    if (ANI_OK != env->FindClass(className, &aniClass)) {
        SETTING_LOG_ERROR("Not found '%{public}s.'", className);
        return aniObject;
    }

    ani_method personInfoCtor;
    if (ANI_OK != env->Class_FindMethod(aniClass, "<ctor>", "Z:V", &personInfoCtor)) {
        SETTING_LOG_ERROR("Class_GetMethod Failed '%{public}s' <ctor>.", className);
        return aniObject;
    }

    if (ANI_OK != env->Object_New(aniClass, personInfoCtor, &aniObject, boolValue)) {
        SETTING_LOG_ERROR("Object_New Failed '%{public}s' <ctor>.", className);
    }

    return aniObject;
}

ani_object CreateError(ani_env *env, const std::string &msg)
{
    ani_class cls{};
    ani_method method{};
    ani_object obj = nullptr;
    ani_status status = ANI_ERROR;
    if (env == nullptr) {
        SETTING_LOG_ERROR("null env");
        return nullptr;
    }

    ani_string aniMsg = nullptr;
    if ((status = env->String_NewUTF8(msg.c_str(), msg.size(), &aniMsg)) != ANI_OK) {
        SETTING_LOG_ERROR("String_NewUTF8 failed %{public}d", status);
        return nullptr;
    }

    ani_ref undefRef;
    if ((status = env->GetUndefined(&undefRef)) != ANI_OK) {
        SETTING_LOG_ERROR("GetUndefined failed %{public}d", status);
        return nullptr;
    }

    if ((status = env->FindClass("Lescompat/Error;", &cls)) != ANI_OK) {
        SETTING_LOG_ERROR("FindClass failed %{public}d", status);
        return nullptr;
    }
    if ((status = env->Class_FindMethod(cls, "<ctor>", "Lstd/core/String;Lescompat/ErrorOptions;:V", &method)) !=
        ANI_OK) {
        SETTING_LOG_ERROR("Class_FindMethod failed %{public}d", status);
        return nullptr;
    }

    if ((status = env->Object_New(cls, method, &obj, aniMsg, undefRef)) != ANI_OK) {
        SETTING_LOG_ERROR("Object_New failed %{public}d", status);
        return nullptr;
    }
    return obj;
}

ani_object CreateBusinessError(ani_env *env, int code, const std::string &msg)
{
    ani_class cls{};
    ani_method method{};
    ani_object obj = nullptr;
    ani_status status = ANI_ERROR;
    if (env == nullptr) {
        SETTING_LOG_ERROR("null env");
        return nullptr;
    }
    if ((status = env->FindClass("L@ohos/base/BusinessError;", &cls)) != ANI_OK) {
        SETTING_LOG_ERROR("FindClass failed %{public}d", status);
        return nullptr;
    }
    if ((status = env->Class_FindMethod(cls, "<ctor>", "ILescompat/Error;:V", &method)) != ANI_OK) {
        SETTING_LOG_ERROR("Class_FindMethod failed %{public}d", status);
        return nullptr;
    }
    ani_object error = CreateError(env, msg);
    if (error == nullptr) {
        SETTING_LOG_ERROR("error null");
        return nullptr;
    }
    ani_double dCode(code);
    if ((status = env->Object_New(cls, method, &obj, dCode, error)) != ANI_OK) {
        SETTING_LOG_ERROR("Object_New failed %{public}d", status);
        return nullptr;
    }
    return obj;
}

void SettingsObserver::OnChange()
{
    SETTING_LOG_INFO("n_s_o_c");
    if (this->cbInfo == nullptr) {
        SETTING_LOG_ERROR("%{public}s, cbInfo is null.", __func__);
        return;
    }

    SETTING_LOG_INFO("n_s_o_c_a");
    std::lock_guard<std::mutex> lockGuard(g_observerMapMutex);
    SettingsObserver *settingsObserver = reinterpret_cast<SettingsObserver *>(this);
    if (!IsExistObserver(settingsObserver) || settingsObserver == nullptr || settingsObserver->cbInfo == nullptr ||
        settingsObserver->toBeDelete) {
        SETTING_LOG_ERROR("ani_call_function: cbInfo invalid.");
        return;
    }

    ani_env *env = nullptr;
    ani_options aniArgs{0, nullptr};
    if (settingsObserver->vm_ == nullptr) {
        SETTING_LOG_ERROR("VM is nullptr");
        return;
    }
    if (ANI_OK != settingsObserver->vm_->AttachCurrentThread(&aniArgs, ANI_VERSION_1, &env)) {
        SETTING_LOG_ERROR("AttachCurrentThread failed");
        if (ANI_OK != settingsObserver->vm_->GetEnv(ANI_VERSION_1, &env)) {
            SETTING_LOG_ERROR("GetEnv failed");
            return;
        }
    }

    ani_size nr_refs = 16;
    env->CreateLocalScope(nr_refs);

    ani_ref result;
    auto fnObj = static_cast<ani_fn_object>(settingsObserver->callback_);
    if (fnObj == nullptr) {
        SETTING_LOG_ERROR("%{public}s: fnObj == nullptr", __func__);
        return;
    }

    std::vector<ani_ref> args;
    std::string msg = "";
    ani_object errObj = CreateBusinessError(env, 802, msg);

    ani_ref dataObj = BoolToObject(env, false);
    args.push_back(errObj);
    args.push_back(dataObj);

    ani_status callStatus = env->FunctionalObject_Call(fnObj, args.size(), args.data(), &result);
    if (ANI_OK != callStatus) {
        SETTING_LOG_ERROR("ani_call_function failed status : %{public}d", callStatus);
        return;
    }

    SETTING_LOG_INFO("%{public}s, ani_eventhandler_work success.", __func__);
    env->DestroyLocalScope();
    settingsObserver->vm_->DetachCurrentThread();
}

std::string GetObserverIdStr()
{
    std::vector<int> tmpId;
    int currentUserId = -1;
    OHOS::AccountSA::OsAccountManager::GetOsAccountLocalIdFromProcess(currentUserId);
    std::string tmpIdStr = "100";
    if (currentUserId > 0) {
        tmpIdStr = std::to_string(currentUserId);
        SETTING_LOG_INFO("userId is %{public}s", tmpIdStr.c_str());
    } else if (currentUserId == 0) {
        OHOS::AccountSA::OsAccountManager::GetForegroundOsAccountLocalId(currentUserId);
        tmpIdStr = std::to_string(currentUserId);
        SETTING_LOG_INFO("user0 userId is %{public}s", tmpIdStr.c_str());
    } else {
        SETTING_LOG_INFO("%{public}s, user id 100.", __func__);
    }
    return tmpIdStr;
}

ani_boolean ani_settings_register_observer(
    ani_env *env, ani_object context, ani_string name, ani_string domainName, ani_object observer)
{
    SETTING_LOG_INFO("n_s_r_o");

    ani_boolean stageMode = false;
    ani_status status = OHOS::AbilityRuntime::IsStageContext(env, context, stageMode);
    if (status != ANI_OK) {
        SETTING_LOG_ERROR("%{public}s, not stage mode.", __func__);
        return false;
    }
    AsyncCallbackInfo *callbackInfo = new AsyncCallbackInfo();
    if (callbackInfo == nullptr) {
        SETTING_LOG_ERROR("%{public}s, failed to get callbackInfo.", __func__);
        return false;
    }

    callbackInfo->env = env;
    ani_vm *vm = nullptr;
    if (env->GetVM(&vm) != ANI_OK) {
        SETTING_LOG_ERROR("GetVM failed");
        return false;
    }
    callbackInfo->key = unwrap_string_from_js(env, name);
    callbackInfo->tableName = unwrap_string_from_js(env, domainName);
    env->GlobalReference_Create(observer, &(callbackInfo->callbackRef));

    std::lock_guard<std::mutex> lockGuard(g_observerMapMutex);
    if (g_observerMap.find(callbackInfo->key) != g_observerMap.end() && g_observerMap[callbackInfo->key] != nullptr) {
        SETTING_LOG_INFO("%{public}s, already registered.", __func__);
        env->GlobalReference_Delete(callbackInfo->callbackRef);
        delete callbackInfo;
        return false;
    }

    auto dataShareHelper = getDataShareHelper(env, context, callbackInfo->tableName);
    if (dataShareHelper == nullptr) {
        env->GlobalReference_Delete(callbackInfo->callbackRef);
        delete callbackInfo;
        return false;
    }

    std::string strUri = GetStageUriStr(callbackInfo->tableName, GetObserverIdStr(), callbackInfo->key);
    OHOS::Uri uri(strUri);
    sptr<SettingsObserver> settingsObserver =
        sptr<SettingsObserver>(new (std::nothrow) SettingsObserver(vm, observer, callbackInfo));
    env->GlobalReference_Create(observer, &(settingsObserver->callback_));

    g_observerMap[callbackInfo->key] = settingsObserver;
    dataShareHelper->RegisterObserver(uri, settingsObserver);
    dataShareHelper->Release();
    if (callbackInfo != nullptr) {
        delete callbackInfo;
        callbackInfo = nullptr;
    }
    return true;
}

ani_boolean ani_settings_unregister_observer(ani_env *env, ani_object context, ani_string name, ani_string domainName)
{
    SETTING_LOG_INFO("n_s_u_o");

    ani_boolean stageMode = false;
    ani_status status = OHOS::AbilityRuntime::IsStageContext(env, context, stageMode);
    if (status != ANI_OK) {
        SETTING_LOG_ERROR("%{public}s, not stage mode.", __func__);
        return false;
    }

    std::string key = unwrap_string_from_js(env, name);
    std::string tableName = unwrap_string_from_js(env, domainName);

    std::lock_guard<std::mutex> lockGuard(g_observerMapMutex);
    if (g_observerMap.find(key) == g_observerMap.end()) {
        SETTING_LOG_ERROR("%{public}s, null.", __func__);
        return false;
    }

    if (g_observerMap[key] == nullptr) {
        g_observerMap.erase(key);
        return false;
    }

    auto dataShareHelper = getDataShareHelper(env, context, tableName);
    if (dataShareHelper == nullptr) {
        SETTING_LOG_ERROR("%{public}s, data share is null.", __func__);
        return false;
    }
    std::string strUri = GetStageUriStr(tableName, GetObserverIdStr(), key);
    OHOS::Uri uri(strUri);

    env->GlobalReference_Delete(g_observerMap[key]->cbInfo->callbackRef);
    env->GlobalReference_Delete(g_observerMap[key]->callback_);
    dataShareHelper->UnregisterObserver(uri, g_observerMap[key]);
    dataShareHelper->Release();
    g_observerMap[key]->toBeDelete = true;
    g_observerMap[key] = nullptr;
    g_observerMap.erase(key);

    return true;
}
}  // namespace Settings
}  // namespace OHOS