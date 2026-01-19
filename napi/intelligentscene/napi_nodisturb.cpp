/**
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

#include "napi_nodisturb.h"
#include "napi/native_common.h"
#include "common/napi_intelligent_scene_log.h"
#include "common/intelligence_inner_errors.h"
#include "common/common.h"
#include "notification_helper.h"
#include "os_account_manager.h"
#include "tokenid_kit.h"
#include "ipc_skeleton.h"
#include "accesstoken_kit.h"

namespace OHOS {
namespace IntelligentScene {

bool HasPermisson()
{
    Security::AccessToken::AccessTokenID tokenId = IPCSkeleton::GetCallingTokenID();
    int result = Security::AccessToken::AccessTokenKit::
        VerifyAccessToken(tokenId, OHOS_GET_DONOTDISTURB_STATE_PERMISSION);
    return result == PERMISSION_GRANTED;
}

void startDoNotDisturbEnabledWork(napi_env env, NotDisturbEnabledCallback* asynccallback)
{
    napi_value resourceName = nullptr;
    napi_create_string_latin1(env, "isDoNotDisturbEnabled", NAPI_AUTO_LENGTH, &resourceName);
    napi_create_async_work(env,
        nullptr,
        resourceName,
        [](napi_env env, void *data) {
            INTELLIGENT_SCENE_LOG_INFO("NapiIsDoNotDisturbEnabled work excute.");
            NotDisturbEnabledCallback *asynccallbackinfo = static_cast<NotDisturbEnabledCallback *>(data);
            if (asynccallbackinfo) {
                int32_t userId = MAIN_USER_ID;
                int32_t ret = OHOS::AccountSA::OsAccountManager::GetForegroundOsAccountLocalId(userId);
                if (ret != ERR_OK) {
                    INTELLIGENT_SCENE_LOG_WARN("Failed to call GetForegroundOsAccountLocalId, code is %{public}d", ret);
                }
                if (userId != MAIN_USER_ID) {
                    asynccallbackinfo->isDoNotDisturbEnabled = false;
                    asynccallbackinfo->info.errorCode = 0;
                } else {
                    asynccallbackinfo->info.errorCode =
                        OHOS::Notification::NotificationHelper::
                        IsDoNotDisturbEnabled(userId, asynccallbackinfo->isDoNotDisturbEnabled);
                    INTELLIGENT_SCENE_LOG_INFO("isDoNotDisturbEnabled code=%{public}d,isDoNotDisturbEnabled=%{public}d",
                        asynccallbackinfo->info.errorCode, asynccallbackinfo->isDoNotDisturbEnabled);
                }
            }
        },
        [](napi_env env, napi_status status, void *data) {
            INTELLIGENT_SCENE_LOG_INFO("NapiIsDoNotDisturbEnabled work complete.");
            NotDisturbEnabledCallback *asynccallbackinfo = static_cast<NotDisturbEnabledCallback *>(data);
            if (asynccallbackinfo) {
                napi_value result = nullptr;
                napi_get_boolean(env, asynccallbackinfo->isDoNotDisturbEnabled, &result);
                Common::CreateReturnValue(env, asynccallbackinfo->info, result);
                if (asynccallbackinfo->info.callback != nullptr) {
                    INTELLIGENT_SCENE_LOG_INFO("Delete napiIsDoNotDisturbEnabled callback reference.");
                    napi_delete_reference(env, asynccallbackinfo->info.callback);
                }
                napi_delete_async_work(env, asynccallbackinfo->asyncWork);
                delete asynccallbackinfo;
                asynccallbackinfo = nullptr;
            }
            INTELLIGENT_SCENE_LOG_INFO("NapiIsDoNotDisturbEnabled work end.");
        },
        (void *)asynccallback,
        &asynccallback->asyncWork);
}

void startNotifyAllowedWork(napi_env env, NotifyAllowedCallback* asynccallback)
{
    napi_value resourceName = nullptr;
    napi_create_string_latin1(env, "isNotifyAllowedInDoNotDisturb", NAPI_AUTO_LENGTH, &resourceName);
    napi_create_async_work(env,
        nullptr,
        resourceName,
        [](napi_env env, void *data) {
            INTELLIGENT_SCENE_LOG_INFO("NapiIsNotifyAllowedInDoNotDisturb work excute.");
            NotifyAllowedCallback *asynccallbackinfo = static_cast<NotifyAllowedCallback *>(data);
            if (asynccallbackinfo) {
                int32_t userId = MAIN_USER_ID;
                int32_t ret = OHOS::AccountSA::OsAccountManager::GetForegroundOsAccountLocalId(userId);
                if (ret != ERR_OK) {
                    INTELLIGENT_SCENE_LOG_WARN("Failed to call GetForegroundOsAccountLocalId, code is %{public}d", ret);
                }
                if (userId != MAIN_USER_ID) {
                    asynccallbackinfo->isNotifyAllowedInDoNotDisturb = false;
                    asynccallbackinfo->info.errorCode = 0;
                } else {
                    asynccallbackinfo->info.errorCode =
                        OHOS::Notification::NotificationHelper::
                        IsNotifyAllowedInDoNotDisturb(userId, asynccallbackinfo->isNotifyAllowedInDoNotDisturb);
                    INTELLIGENT_SCENE_LOG_INFO("isNotifyAllowed code=%{public}d,isNotifyAllowed=%{public}d",
                        asynccallbackinfo->info.errorCode, asynccallbackinfo->isNotifyAllowedInDoNotDisturb);
                }
            }
        },
        [](napi_env env, napi_status status, void *data) {
            INTELLIGENT_SCENE_LOG_INFO("NapiIsNotifyAllowedInDoNotDisturb work complete.");
            NotifyAllowedCallback *asynccallbackinfo = static_cast<NotifyAllowedCallback *>(data);
            if (asynccallbackinfo) {
                napi_value result = nullptr;
                napi_get_boolean(env, asynccallbackinfo->isNotifyAllowedInDoNotDisturb, &result);
                Common::CreateReturnValue(env, asynccallbackinfo->info, result);
                if (asynccallbackinfo->info.callback != nullptr) {
                    INTELLIGENT_SCENE_LOG_INFO("Delete napiIsNotifyAllowedInDoNotDisturb callback reference.");
                    napi_delete_reference(env, asynccallbackinfo->info.callback);
                }
                napi_delete_async_work(env, asynccallbackinfo->asyncWork);

                delete asynccallbackinfo;
                asynccallbackinfo = nullptr;
            }
            INTELLIGENT_SCENE_LOG_INFO("NapiIsNotifyAllowedInDoNotDisturb work end.");
        },
        (void *)asynccallback,
        &asynccallback->asyncWork);
}

napi_value napi_is_do_not_disturb_enabled(napi_env env, napi_callback_info info)
{
    INTELLIGENT_SCENE_LOG_INFO("start get nodisturb enable state.");
    napi_ref callback = nullptr;
    Common::ParseParaOnlyCallback(env, info, callback);
    NotDisturbEnabledCallback *asyncCallBackInfo =
        new (std::nothrow) NotDisturbEnabledCallback {
        .env = env, .asyncWork = nullptr, .callback = callback};
    if (!asyncCallBackInfo) {
        Common::NapiThrow(env, ERROR_INTERNAL_ERROR);
        return Common::JSParaError(env, callback);
    }
    napi_value promise = nullptr;
    Common::PaddingCallbackPromiseInfo(env, callback, asyncCallBackInfo->info, promise);
    if (!HasPermisson()) {
        napi_value error = Common::NapiThrowError(env, ERROR_PERMISSION_DENIED, asyncCallBackInfo->info, promise);
        delete asyncCallBackInfo;
        return error;
    }
    startDoNotDisturbEnabledWork(env, asyncCallBackInfo);
    napi_queue_async_work_with_qos(env, asyncCallBackInfo->asyncWork, napi_qos_user_initiated);
    
    if (asyncCallBackInfo->info.isCallback) {
        INTELLIGENT_SCENE_LOG_INFO("has callback");
        return Common::NapiGetNull(env);
    }
    return promise;
}

napi_value napi_is_notify_allowed(napi_env env, napi_callback_info info)
{
    INTELLIGENT_SCENE_LOG_INFO("start get notify allowed state.");
    napi_ref callback = nullptr;
    Common::ParseParaOnlyCallback(env, info, callback);
    NotifyAllowedCallback *asyncCallBackInfo =
        new (std::nothrow) NotifyAllowedCallback {
        .env = env, .asyncWork = nullptr, .callback = callback};
    if (!asyncCallBackInfo) {
        Common::NapiThrow(env, ERROR_INTERNAL_ERROR);
        return Common::JSParaError(env, callback);
    }
    napi_value promise = nullptr;
    Common::PaddingCallbackPromiseInfo(env, callback, asyncCallBackInfo->info, promise);
    if (!HasPermisson()) {
        napi_value error = Common::NapiThrowError(env, ERROR_PERMISSION_DENIED, asyncCallBackInfo->info, promise);
        delete asyncCallBackInfo;
        return error;
    }
    startNotifyAllowedWork(env, asyncCallBackInfo);
    napi_queue_async_work_with_qos(env, asyncCallBackInfo->asyncWork, napi_qos_user_initiated);
    
    if (asyncCallBackInfo->info.isCallback) {
        INTELLIGENT_SCENE_LOG_INFO("has callback");
        return Common::NapiGetNull(env);
    }
    return promise;
}
}
}