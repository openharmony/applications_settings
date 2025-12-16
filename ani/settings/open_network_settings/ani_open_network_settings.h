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

#ifndef ANI_OPEN_NETWORK_SETTINGS_H
#define ANI_OPEN_NETWORK_SETTINGS_H

#include <map>
#include "ability.h"
#include "ani.h"
#include "ui_extension_context.h"
#include "napi_settings_log.h"
#include "api_open_settings_page_util.h"
#include "napi_sys_event_util.h"

const int SETTINGS_PARAM_ERROR_CODE = 14800000;
const int SETTINGS_ORIGINAL_SERVICE_CODE = 14800010;
const int SETTINGS_PARAM_INVALID_CODE = 16900010;

enum SettingsCode {
    SETTINGS_SUCCESS = 0,
    SETTINGS_PARAM_ERROR,
    SETTINGS_ORIGINAL_SERVICE_ERROR
};

struct BaseContext {
    std::shared_ptr<OHOS::AbilityRuntime::AbilityContext> abilityContext = nullptr;
    std::shared_ptr<OHOS::AbilityRuntime::UIExtensionContext> uiExtensionContext = nullptr;
};

struct SettingsError {
    int errorCode;
    std::string message;
};

const SettingsError SETTINGS_ERROR_PARAM = {SETTINGS_PARAM_ERROR_CODE, "Parameter error."};
const SettingsError SETTINGS_ERROR_ORIGINAL_SERVICE = {SETTINGS_ORIGINAL_SERVICE_CODE, "Original service error."};
const std::map<SettingsCode, SettingsError> g_errorMap = {
    {SETTINGS_PARAM_ERROR, SETTINGS_ERROR_PARAM},
    {SETTINGS_ORIGINAL_SERVICE_ERROR, SETTINGS_ERROR_ORIGINAL_SERVICE}
};

namespace OHOS {
namespace Settings {

class ModalUICallback {
public:
    explicit ModalUICallback(std::shared_ptr<BaseContext> baseContext);
    void OnRelease(int32_t releaseCode);
    void OnResultForModal(int32_t resultCode, const OHOS::AAFwk::Want &result);
    void OnReceive(const OHOS::AAFwk::WantParams &request);
    void OnError(int32_t code, const std::string &name, const std::string &message);
    void SetSessionId(int32_t sessionId);

private:
    int32_t sessionId_ = 0;
    std::shared_ptr<BaseContext> baseContext = nullptr;

    void CloseModalUI();
};

bool ParseAbilityContext(ani_env *env, const ani_object &obj,
    std::shared_ptr<OHOS::AbilityRuntime::AbilityContext> &abilityContext,
    std::shared_ptr<OHOS::AbilityRuntime::UIExtensionContext> &uiExtensionContext);
OHOS::Ace::UIContent* GetUIContent(std::shared_ptr<BaseContext> &asyncContext);
ani_boolean opne_manager_settings(ani_env *env, ani_object context);
void openInputMethodSettings(ani_env *env, ani_object context);
void openInputMethodDetail(ani_env *env, ani_object context, ani_string bundleName, ani_string inputMethodId);
}
}

#endif