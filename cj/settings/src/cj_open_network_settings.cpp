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

#include "cj_open_network_settings.h"
#include "cj_ability_context.h"
#include "ffi_remote_data.h"
#include "ui_content.h"

namespace OHOS {
namespace CJSystemapi {
namespace CJSettings {

const std::string UIEXTENSION_TYPE_KEY = "ability.want.params.uiExtensionType";
const std::string CONTEXT_TYPE_KEY = "storeKit.ability.contextType";

const std::string UIEXTENSION_TYPE_VALUE = "sys/commonUI";
const std::string SETTINGS_PACKAGE_NAME = "com.huawei.hmos.settings";
const std::string SETTINGS_ABILITY_NAME = "OpenNetworkUIExtensionAbility";
const std::string UI_ABILITY_CONTEXT_VALUE = "uiAbility";
const std::string UI_EXTENSION_CONTEXT_VALUE = "uiExtension";

const std::map<SettingsCode, SettingsError> g_errorMap = {
    {SETTINGS_PARAM_ERROR, SETTINGS_ERROR_PARAM},
    {SETTINGS_ORIGINAL_SERVICE_ERROR, SETTINGS_ERROR_ORIGINAL_SERVICE}
};

static SettingsError ReadErrorMessage(int code)
{
    for (auto it = g_errorMap.begin(); it != g_errorMap.end(); it++) {
        if (it->first == code) {
            return it->second;
        }
    }
    return {};
}

ModalUICallback::ModalUICallback(std::shared_ptr<AbilityRuntime::AbilityContext> abilityContext,
    std::shared_ptr<AbilityRuntime::UIExtensionContext> uiExtensionContext)
{
    this->abilityContext_ = abilityContext;
    this->uiExtensionContext_ = uiExtensionContext;
    LOGI("constructor ModalUICallback");
}

void ModalUICallback::CloseModalUI()
{
    LOGI("CloseModalUI");
    OHOS::Ace::UIContent* uiContent = nullptr;
    if (abilityContext_ != nullptr) {
        uiContent = abilityContext_->GetUIContent();
    } else if (uiExtensionContext_ != nullptr) {
        uiContent = uiExtensionContext_->GetUIContent();
    }
    if (uiContent == nullptr) {
        LOGE("UIContent is nullptr");
        return;
    }
    uiContent->CloseModalUIExtension(this->sessionId_);
}

void ModalUICallback::SetSessionId(int32_t sessionId)
{
    this->sessionId_ = sessionId;
    LOGI("Set sessionId %{public}d", sessionId);
}

void ModalUICallback::OnRelease(int32_t releaseCode)
{
    LOGI("OnRelease");
    this->CloseModalUI();
}

void ModalUICallback::OnResultForModal(int32_t resultCode, const AAFwk::Want &result)
{
    LOGI("ModalUICallback::OnResultForModal");
}

void ModalUICallback::OnReceive(const AAFwk::WantParams &request)
{
    LOGI("ModalUICallback::OnReceive");
}

void ModalUICallback::OnError(int32_t code, const std::string &name, const std::string &message)
{
    LOGI("ModalUICallback::OnError %{public}s", message.c_str());
}

static Ace::UIContent* GetUIContent(std::shared_ptr<AbilityRuntime::AbilityContext> &abilityContext,
    std::shared_ptr<AbilityRuntime::UIExtensionContext> &uiExtensionContext)
{
    Ace::UIContent* uiContent = nullptr;
    if (abilityContext != nullptr) {
        LOGI("get uiContext by ability context");
        uiContent = abilityContext->GetUIContent();
    } else if (uiExtensionContext != nullptr) {
        LOGI("get uiContext by ui extension ability context");
        uiContent = uiExtensionContext->GetUIContent();
    } else {
        LOGE("get uiContext failed.");
    }
    return uiContent;
}

static bool StartUiExtensionAbility(AAFwk::Want &request,
    std::shared_ptr<AbilityRuntime::AbilityContext> &abilityContext,
    std::shared_ptr<AbilityRuntime::UIExtensionContext> &uiExtensionContext)
{
    LOGI("begin StartUiExtensionAbility");
    if (abilityContext == nullptr && uiExtensionContext == nullptr) {
        LOGE("abilityContext is nullptr");
        return false;
    }

    auto uiContent = GetUIContent(abilityContext, uiExtensionContext);
    if (uiContent == nullptr) {
        LOGE("UIContent is nullptr");
        return false;
    }
    std::string info = uiContent->GetContentInfo();
    auto callback = std::make_shared<ModalUICallback>(abilityContext, uiExtensionContext);
    Ace::ModalUIExtensionCallbacks extensionCallbacks = {
        std::bind(&ModalUICallback::OnRelease, callback, std::placeholders::_1),
        std::bind(&ModalUICallback::OnResultForModal, callback, std::placeholders::_1, std::placeholders::_2),
        std::bind(&ModalUICallback::OnReceive, callback, std::placeholders::_1),
        std::bind(&ModalUICallback::OnError, callback, std::placeholders::_1, std::placeholders::_2,
            std::placeholders::_3),
    };

    Ace::ModalUIExtensionConfig config;
    config.isProhibitBack = false;
    int32_t sessionId = uiContent->CreateModalUIExtension(request, extensionCallbacks, config);
    if (sessionId == 0) {
        LOGI("get sessionId faild");
        return false;
    }
    callback->SetSessionId(sessionId);
    LOGI("end StartUiExtensionAbility");
    return true;
}

static void ExecuteLoadProduct(std::shared_ptr<AbilityRuntime::AbilityContext> &abilityContext,
    std::shared_ptr<AbilityRuntime::UIExtensionContext> &uiExtensionContext, AAFwk::Want &request)
{
    LOGI("ExecuteLoadProduct called");
    request.SetElementName(SETTINGS_PACKAGE_NAME, SETTINGS_ABILITY_NAME);
    request.SetParam(UIEXTENSION_TYPE_KEY, UIEXTENSION_TYPE_VALUE);
    request.SetParam(CONTEXT_TYPE_KEY,
        uiExtensionContext != nullptr ? UI_EXTENSION_CONTEXT_VALUE : UI_ABILITY_CONTEXT_VALUE);
    LOGI("ExecuteLoadProduct end");
}

bool OpenNetworkManagerSettings(int64_t contextId, int32_t* ret)
{
    LOGI("start OpenNetworkManagerSettings.");
    *ret = 0;
    if (contextId <= 0) {
        LOGE("Invalid contextId.");
        *ret = SETTINGS_PARAM_ERROR_CODE;
        return false;
    }

    auto cjAbilityContext = OHOS::FFI::FFIData::GetData<AbilityRuntime::CJAbilityContext>(contextId);
    if (cjAbilityContext == nullptr) {
        LOGE("CJAbilityContext is nullptr.");
        *ret = SETTINGS_PARAM_ERROR_CODE;
        return false;
    }

    auto abilityContext = cjAbilityContext->GetAbilityContext();
    if (abilityContext == nullptr) {
        LOGE("abilityContext is nullptr.");
        *ret = SETTINGS_PARAM_ERROR_CODE;
        return false;
    }

    AAFwk::Want wantRequest;
    std::shared_ptr<AbilityRuntime::UIExtensionContext> uiExtensionContext = nullptr;
    ExecuteLoadProduct(abilityContext, uiExtensionContext, wantRequest);
    if (!StartUiExtensionAbility(wantRequest, abilityContext, uiExtensionContext)) {
        LOGE("open network manager settings failed.");
        *ret = SETTINGS_ORIGINAL_SERVICE_CODE;
        return false;
    }

    LOGI("open network manager settings end.");
    return true;
}

} // namespace CJSettings
} // namespace CJSystemapi
} // namespace OHOS
