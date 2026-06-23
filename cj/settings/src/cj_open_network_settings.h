/*
 * Copyright (c) 2024-2026 Huawei Device Co., Ltd.
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

#ifndef OHOS_CJ_OPEN_NETWORK_SETTINGS_H
#define OHOS_CJ_OPEN_NETWORK_SETTINGS_H

#include <cstdint>
#include <map>
#include <string>
#include "ability.h"
#include "ui_extension_context.h"
#include "cj_settings_log.h"

const int SETTINGS_PARAM_ERROR_CODE = 14800000;
const int SETTINGS_ORIGINAL_SERVICE_CODE = 14800010;

enum SettingsCode {
    SETTINGS_SUCCESS = 0,
    SETTINGS_PARAM_ERROR,
    SETTINGS_ORIGINAL_SERVICE_ERROR
};

struct SettingsError {
    int errorCode;
    std::string message;
};

const SettingsError SETTINGS_ERROR_PARAM = {SETTINGS_PARAM_ERROR_CODE, "Parameter error."};
const SettingsError SETTINGS_ERROR_ORIGINAL_SERVICE = {SETTINGS_ORIGINAL_SERVICE_CODE, "Original service error."};

namespace OHOS {
namespace CJSystemapi {
namespace CJSettings {

class ModalUICallback {
public:
    explicit ModalUICallback(std::shared_ptr<AbilityRuntime::AbilityContext> abilityContext,
        std::shared_ptr<AbilityRuntime::UIExtensionContext> uiExtensionContext);
    void OnRelease(int32_t releaseCode);
    void OnResultForModal(int32_t resultCode, const AAFwk::Want &result);
    void OnReceive(const AAFwk::WantParams &request);
    void OnError(int32_t code, const std::string &name, const std::string &message);
    void SetSessionId(int32_t sessionId);

private:
    int32_t sessionId_ = 0;
    std::shared_ptr<AbilityRuntime::AbilityContext> abilityContext_ = nullptr;
    std::shared_ptr<AbilityRuntime::UIExtensionContext> uiExtensionContext_ = nullptr;

    void CloseModalUI();
};

bool OpenNetworkManagerSettings(int64_t contextId, int32_t* ret);

} // namespace CJSettings
} // namespace CJSystemapi
} // namespace OHOS

#endif // OHOS_CJ_OPEN_NETWORK_SETTINGS_H
