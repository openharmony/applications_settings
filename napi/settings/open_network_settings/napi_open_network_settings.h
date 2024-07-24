/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

#ifndef NAPI_OPEN_NETWORK_SETTINGS_H
#define NAPI_OPEN_NETWORK_SETTINGS_H

#include "napi/native_api.h"
#include "ability.h"
#include "ui_extension_context.h"
#include "../napi_settings_log.h"


namespace OHOS {
namespace Settings {

struct BaseContext {
    std::shared_ptr<OHOS::AbilityRuntime::AbilityContext> abilityContext = nullptr;
    std::shared_ptr<OHOS::AbilityRuntime::UIExtensionContext> uiExtensionContext = nullptr;
};

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

bool ParseAbilityContext(napi_env env, const napi_value &obj,
    std::shared_ptr<OHOS::AbilityRuntime::AbilityContext> &abilityContext,
    std::shared_ptr<OHOS::AbilityRuntime::UIExtensionContext> &uiExtensionContext);
OHOS::Ace::UIContent* GetUIContent(std::shared_ptr<BaseContext> &asyncContext);
napi_value opne_manager_settings(napi_env env, napi_callback_info info);
}
}

#endif