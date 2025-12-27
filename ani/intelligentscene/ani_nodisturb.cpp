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

#include <ani.h>
#include "os_account_manager.h"
#include "ani_intelligent_scene_log.h"
#include "notification_helper.h"
#include "common/ani_common.h"
#include "common/ani_throw_error.h"
#include "tokenid_kit.h"
#include "ipc_skeleton.h"
#include "accesstoken_kit.h"

namespace OHOS {
namespace IntelligentScene {

bool HasPermisson()
{
    Security::AccessToken::AccessTokenID tokenId = IPCSkeleton::GetCallingTokenID();
    int result = Security::AccessToken::AccessTokenKit::
        VerifyAccessToken(tokenId, OHOS_GET_DONOTDISTURB_STATE);
    return result == PERMISSION_GRANTED;
}

ani_boolean ani_is_do_not_disturb_enabled(ani_env *env)
{
    if (!HasPermisson()) {
        ThrowError(env, ERROR_PERMISSION_DENIED);
        return ANI_FALSE;
    }
    bool isDoNotDisturbEnabled = false;
    INTELLIGENTSCENE_LOG_INFO("isDoNotDisturbEnabled enter");
    int userId = -1;
    int ret = OHOS::AccountSA::OsAccountManager::GetForegroundOsAccountLocalId(userId);
    if (ret != ERR_OK) {
        INTELLIGENTSCENE_LOG_ERROR("get account local info failed.");
        ThrowError(env, ERROR_INTERNAL_ERROR);
        return ANI_FALSE;
    }
    if (userId != MAIN_USER_ID) {
        INTELLIGENTSCENE_LOG_WARN("current is not main user.");
        return ANI_FALSE;
    }
    int returncode = Notification::NotificationHelper::IsDoNotDisturbEnabled(userId, isDoNotDisturbEnabled);
    if (returncode != ERR_OK) {
        INTELLIGENTSCENE_LOG_ERROR("isDoNotDisturbEnabled error. returncode: %{public}d", returncode);
        ThrowError(env, returncode);
        return ANI_FALSE;
    }
    INTELLIGENTSCENE_LOG_INFO("isDoNotDisturbEnabled end");
    return isDoNotDisturbEnabled ? ANI_TRUE : ANI_FALSE;
}

ani_boolean ani_is_notify_allowed(ani_env *env)
{
    if (!HasPermisson()) {
        ThrowError(env, ERROR_PERMISSION_DENIED);
        return ANI_FALSE;
    }
    bool isNotifyAllowedInDoNotDisturb = false;
    INTELLIGENTSCENE_LOG_INFO("IsNotifyAllowedInDoNotDisturb enter");
    int userId = -1;
    int ret = OHOS::AccountSA::OsAccountManager::GetForegroundOsAccountLocalId(userId);
    if (ret != ERR_OK) {
        INTELLIGENTSCENE_LOG_ERROR("get account local info failed.");
        ThrowError(env, ERROR_INTERNAL_ERROR);
        return ANI_FALSE;
    }
    if (userId != MAIN_USER_ID) {
        INTELLIGENTSCENE_LOG_WARN("current is not main user.");
        return ANI_FALSE;
    }
    int returncode =
        Notification::NotificationHelper::IsNotifyAllowedInDoNotDisturb(userId, isNotifyAllowedInDoNotDisturb);
    if (returncode != ERR_OK) {
        INTELLIGENTSCENE_LOG_ERROR("IsNotifyAllowedInDoNotDisturb error. returncode: %{public}d", returncode);
        ThrowError(env, returncode);
        return ANI_FALSE;
    }
    INTELLIGENTSCENE_LOG_INFO("IsNotifyAllowedInDoNotDisturb end");
    return isNotifyAllowedInDoNotDisturb ? ANI_TRUE : ANI_FALSE;
    return true;
}
}
}