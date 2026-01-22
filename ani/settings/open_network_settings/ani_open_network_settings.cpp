/*
 * Copyright (c) 2025-2026 Huawei Device Co., Ltd.
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

#include "ani_open_network_settings.h"
#include "../ani_settings.h"
#include "ani_base_context.h"
#include "ui_content.h"
#include <json/json.h>
#include "parameters.h"

namespace OHOS {
namespace Settings {
const std::string UIEXTENSION_TYPE_KEY = "ability.want.params.uiExtensionType";
const std::string CONTEXT_TYPE_KEY = "storeKit.ability.contextType";

const std::string UIEXTENSION_TYPE_VALUE = "sys/commonUI";
const std::string SETTINGS_PACKAGE_NAME = "com.huawei.hmos.settings";
const std::string SETTINGS_ABILITY_NAME = "OpenNetworkUIExtensionAbility";
const std::string SETTINGS_COMMON_EXTERNAL_PAGE_NAME = "ExternalCommonUIExtensionAbility";
const std::string UI_ABILITY_CONTEXT_VALUE = "uiAbility";
const std::string UI_EXTENSION_CONTEXT_VALUE = "uiExtension";
const std::string DEVICE_TYPE = OHOS::system::GetParameter("const.product.devicetype", "");

const std::string SETTINGS_PUSH_PARAM = "pushParam";
const std::string SETTINGS_PUSH_PARAM_JSON_TYPE = "isParamJsonObject";

const std::string INPUT_DETAIL_WANT_EXTRA = "extra";
const std::string INPUT_DETAIL_WANT_VALUE = "value";
const std::string INPUT_DETAIL_WANT_NAME = "name";
const std::map<SettingsCode, SettingsError> g_errorMap = {
    {SETTINGS_PARAM_ERROR, SETTINGS_ERROR_PARAM},
    {SETTINGS_ORIGINAL_SERVICE_ERROR, SETTINGS_ERROR_ORIGINAL_SERVICE}
};

bool StartUiExtensionAbility(OHOS::AAFwk::Want &request, std::shared_ptr<BaseContext> &asyncContext)
{
    SETTING_LOG_INFO("begin StartUiExtensionAbility");
    if (asyncContext == nullptr) {
        SETTING_LOG_ERROR("asyncContext is nullptr");
        return false;
    }

    if (asyncContext->abilityContext == nullptr && asyncContext->uiExtensionContext == nullptr) {
        SETTING_LOG_ERROR("abilityContext is nullptr");
        return false;
    }

    auto uiContent = GetUIContent(asyncContext);
    if (uiContent == nullptr) {
        SETTING_LOG_ERROR("UIContent is nullptr");
        return false;
    }
    std::string info = uiContent->GetContentInfo();
    auto callback = std::make_shared<ModalUICallback>(asyncContext);
    OHOS::Ace::ModalUIExtensionCallbacks extensionCallbacks = {
        std::bind(&ModalUICallback::OnRelease, callback, std::placeholders::_1),
        std::bind(&ModalUICallback::OnResultForModal, callback, std::placeholders::_1, std::placeholders::_2),
        std::bind(&ModalUICallback::OnReceive, callback, std::placeholders::_1),
        std::bind(&ModalUICallback::OnError, callback, std::placeholders::_1, std::placeholders::_2,
            std::placeholders::_3),
    };

    OHOS::Ace::ModalUIExtensionConfig config;
    config.isProhibitBack = false;
    int32_t sessionId = uiContent->CreateModalUIExtension(request, extensionCallbacks, config);
    if (sessionId == 0) {
        SETTING_LOG_INFO("get sessionId faild");
        return false;
    }
    callback->SetSessionId(sessionId);
    SETTING_LOG_INFO("end StartUiExtensionAbility");
    return true;
}

OHOS::Ace::UIContent* GetUIContent(std::shared_ptr<BaseContext> &asyncContext)
{
    OHOS::Ace::UIContent* uiContent = nullptr;
    if (asyncContext->abilityContext != nullptr) {
        SETTING_LOG_INFO("get uiContext by ability context");
        uiContent = asyncContext->abilityContext->GetUIContent();
    } else if (asyncContext->uiExtensionContext != nullptr) {
        SETTING_LOG_INFO("get uiContext by ui extension ability context");
        uiContent = asyncContext->uiExtensionContext->GetUIContent();
    } else {
        SETTING_LOG_ERROR("get uiContext failed.");
    }

    return uiContent;
}

void ExecuteLoadProduct(std::shared_ptr<BaseContext> &baseContext, OHOS::AAFwk::Want &request)
{
    SETTING_LOG_INFO("ExecuteLoadProduct called");
    request.SetElementName(SETTINGS_PACKAGE_NAME, SETTINGS_ABILITY_NAME);
    request.SetParam(UIEXTENSION_TYPE_KEY, UIEXTENSION_TYPE_VALUE);
    request.SetParam(CONTEXT_TYPE_KEY,
        baseContext->uiExtensionContext != nullptr ? UI_EXTENSION_CONTEXT_VALUE : UI_ABILITY_CONTEXT_VALUE);
    SETTING_LOG_INFO("ExecuteLoadProduct end");
}

ModalUICallback::ModalUICallback(std::shared_ptr<BaseContext> baseContext)
{
    this->baseContext = baseContext;
    SETTING_LOG_INFO("constructor ModalUICallback");
}

void ModalUICallback::CloseModalUI()
{
    SETTING_LOG_INFO("CloseModalUI");
    auto uiContent = GetUIContent(this->baseContext);
    if (uiContent == nullptr) {
        SETTING_LOG_ERROR("UIContent is nullptr");
        return;
    }
    uiContent->CloseModalUIExtension(this->sessionId_);
}

void ModalUICallback::SetSessionId(int32_t sessionId)
{
    this->sessionId_ = sessionId;
    SETTING_LOG_INFO("Set sessionId %{public}d", sessionId);
}

void ModalUICallback::OnRelease(int32_t releaseCode)
{
    SETTING_LOG_INFO("OnRelease");
    this->CloseModalUI();
}

void ModalUICallback::OnResultForModal(int32_t resultCode, const OHOS::AAFwk::Want &result)
{
    SETTING_LOG_INFO("ModalUICallback::OnResultForModal");
}

void ModalUICallback::OnReceive(const OHOS::AAFwk::WantParams &request)
{
    SETTING_LOG_INFO("ModalUICallback::OnReceive");
}

void ModalUICallback::OnError(int32_t code, const std::string &name, const std::string &message)
{
    SETTING_LOG_INFO("ModalUICallback::OnError %{public}s", message.c_str());
}

bool ParseAbilityContext(ani_env *env, const ani_object &obj,
    std::shared_ptr<OHOS::AbilityRuntime::AbilityContext> &abilityContext,
    std::shared_ptr<OHOS::AbilityRuntime::UIExtensionContext> &uiExtensionContext)
{
    SETTING_LOG_INFO("begin ParseAbilityContextReq");
    ani_boolean stageMode = false;
    ani_status status = OHOS::AbilityRuntime::IsStageContext(env, obj, stageMode);
    if (status != ANI_OK || !stageMode) {
        SETTING_LOG_ERROR("it is not a stage mode");
        return false;
    }

    auto context = OHOS::AbilityRuntime::GetStageModeContext(env, obj);
    if (context == nullptr) {
        SETTING_LOG_ERROR("get context failed");
        return false;
    }

    abilityContext = OHOS::AbilityRuntime::Context::ConvertTo<OHOS::AbilityRuntime::AbilityContext>(context);
    if (abilityContext != nullptr) {
        return true;
    }
    SETTING_LOG_ERROR("get stage model ability context failed");

    uiExtensionContext = OHOS::AbilityRuntime::Context::ConvertTo<OHOS::AbilityRuntime::UIExtensionContext>(context);
    if (uiExtensionContext == nullptr) {
        SETTING_LOG_ERROR("get uiExtensionContext failed");
        return false;
    }

    return true;
}

SettingsError ReadErrorMessage(int code)
{
    for (auto it = g_errorMap.begin(); it != g_errorMap.end(); it++) {
        if (it->first == code) {
            return it->second;
        }
    }
    return {};
}

void DeleteAsyncCallback(AsyncCallbackInfo *asyncCallbackInfo)
{
    if (asyncCallbackInfo != nullptr) {
        delete asyncCallbackInfo;
        asyncCallbackInfo = nullptr;
    }
}

ani_boolean SetAsyncCallback(ani_env *env, AsyncCallbackInfo* asyncCallbackInfo)
{
    if (asyncCallbackInfo->status != SETTINGS_SUCCESS) {
        SettingsError error = ReadErrorMessage(asyncCallbackInfo->status);
        ThrowExistingError(env, error.errorCode, error.message);
        DeleteAsyncCallback(asyncCallbackInfo);
        return false;
    }
    return true;
}

ani_boolean opne_manager_settings(ani_env *env, ani_object context)
{
    SETTING_LOG_INFO("start opne manager settings.");
    AsyncCallbackInfo* asyncCallbackInfo = new AsyncCallbackInfo();

    auto loadProductContext = std::make_shared<BaseContext>();
    if (!ParseAbilityContext(env, context, loadProductContext->abilityContext,
        loadProductContext->uiExtensionContext)) {
        SETTING_LOG_ERROR("context parse error.");
        asyncCallbackInfo->status = SETTINGS_PARAM_ERROR;
        return SetAsyncCallback(env, asyncCallbackInfo);
    }

    // 处理请求信息
    OHOS::AAFwk::Want wantRequest;
    ExecuteLoadProduct(loadProductContext, wantRequest);
    if (!StartUiExtensionAbility(wantRequest, loadProductContext)) {
        SETTING_LOG_ERROR("opne manager faild.");
        asyncCallbackInfo->status = SETTINGS_ORIGINAL_SERVICE_ERROR;
        return SetAsyncCallback(env, asyncCallbackInfo);
    }
    SETTING_LOG_INFO("opne manager settings end.");
    return SetAsyncCallback(env, asyncCallbackInfo);
}

void ThrowParamErrorException(ani_env *env, const std::string &page)
{
    ReportSysEvent(page, false);
    ThrowExistingError(env, SETTINGS_PARAM_INVALID_CODE, "param is invalid, start settings failed");
}

void StartUiExtensionWithParams(ani_env *env, const ani_object &context, OHOS::AAFwk::Want &request)
{
    auto loadProductContext = std::make_shared<BaseContext>();
    const std::string targetPage = request.GetUriString();
    if (!ParseAbilityContext(env, context,
        loadProductContext->abilityContext, loadProductContext->uiExtensionContext)) {
        SETTING_LOG_ERROR("context parse error.");
        ThrowParamErrorException(env, targetPage);
        return;
    }
    request.SetElementName(SETTINGS_PACKAGE_NAME, SETTINGS_COMMON_EXTERNAL_PAGE_NAME);
    request.SetParam(UIEXTENSION_TYPE_KEY, UIEXTENSION_TYPE_VALUE);
    if (!StartUiExtensionAbility(request, loadProductContext)) {
        SETTING_LOG_ERROR("open settings error.");
        ThrowParamErrorException(env, targetPage);
        return;
    }
    ReportSysEvent(targetPage, true);
}

void openInputMethodSettings(ani_env *env, ani_object context)
{
    SETTING_LOG_INFO("start openInputMethodSettings.");
    // 设备校验
    const std::string targetPage = SettingsPageUrl::INPUT_PAGE;
    if (!IsPageSupportJump(DEVICE_TYPE, targetPage)) {
        SETTING_LOG_ERROR("device is not support.");
        ReportSysEvent(targetPage, false);
        return;
    }

    // 处理请求信息
    OHOS::AAFwk::Want wantRequest;
    wantRequest.SetUri(targetPage);
    StartUiExtensionWithParams(env, context, wantRequest);
    SETTING_LOG_INFO("openInputMethodSettings end.");
}

void openInputMethodDetail(ani_env *env, ani_object context, ani_string bundleName, ani_string inputMethodId)
{
    SETTING_LOG_INFO("start openInputMethodDetail.");
    const std::string targetPage = SettingsPageUrl::INPUT_DETAIL_PAGE;
    // 设备校验
    if (!IsPageSupportJump(DEVICE_TYPE, targetPage)) {
        SETTING_LOG_ERROR("device is not support.");
        ReportSysEvent(targetPage, false);
        return;
    }

    // 参数校验
    std::string strBundleName = unwrap_string_from_js(env, bundleName);
    std::string strInputMethodId = unwrap_string_from_js(env, inputMethodId);
    if (strBundleName.empty() || strInputMethodId.empty()) {
        SETTING_LOG_ERROR("param is invalid.");
        ThrowParamErrorException(env, targetPage);
        return;
    }

    // 处理请求信息
    OHOS::AAFwk::Want wantRequest;
    Json::Value value;
    Json::Value extra;
    extra[INPUT_DETAIL_WANT_VALUE] = strBundleName;
    extra[INPUT_DETAIL_WANT_NAME] = strInputMethodId;
    value[INPUT_DETAIL_WANT_EXTRA] = extra;
    Json::StreamWriterBuilder builder;
    std::string param = Json::writeString(builder, value);
    wantRequest.SetParam(SETTINGS_PUSH_PARAM, param);
    wantRequest.SetParam(SETTINGS_PUSH_PARAM_JSON_TYPE, true);
    wantRequest.SetUri(SettingsPageUrl::INPUT_DETAIL_PAGE);
    StartUiExtensionWithParams(env, context, wantRequest);
    SETTING_LOG_INFO("openInputMethodDetail end.");
}
}
}