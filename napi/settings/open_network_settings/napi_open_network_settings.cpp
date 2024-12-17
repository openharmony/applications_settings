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

#include "napi_open_network_settings.h"
#include "../napi_settings.h"
#include "napi_base_context.h"
#include "ui_content.h"

namespace OHOS {
namespace Settings {
const std::string UIEXTENSION_TYPE_KEY = "ability.want.params.uiExtensionType";
const std::string CONTEXT_TYPE_KEY = "storeKit.ability.contextType";

const std::string UIEXTENSION_TYPE_VALUE = "sys/commonUI";
const std::string SETTINGS_PACKAGE_NAME = "com.huawei.hmos.settings";
const std::string SETTINGS_ABILITY_NAME = "OpenNetworkUIExtensionAbility";
const std::string UI_ABILITY_CONTEXT_VALUE = "uiAbility";
const std::string UI_EXTENSION_CONTEXT_VALUE = "uiExtension";

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
ssss
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
        SETTING_LOG_INFO("get uiContext failed.");
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

bool ParseAbilityContext(napi_env env, const napi_value &obj,
    std::shared_ptr<OHOS::AbilityRuntime::AbilityContext> &abilityContext,
    std::shared_ptr<OHOS::AbilityRuntime::UIExtensionContext> &uiExtensionContext)
{
    SETTING_LOG_INFO("begin ParseAbilityContextReq");
    bool stageMode = false;
    napi_status status = OHOS::AbilityRuntime::IsStageContext(env, obj, stageMode);
    if (status != napi_ok || !stageMode) {
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

bool SetAsyncCallback(napi_env env, AsyncCallbackInfo* asyncCallbackInfo)
{
    napi_value resource = nullptr;
    napi_status ret = napi_ok;
    ret = napi_create_string_utf8(env, "openNetworkManagerSettings", NAPI_AUTO_LENGTH, &resource);
    if (ret != napi_ok) {
        SETTING_LOG_ERROR("create string failed");
        return false;
    }
    ret = napi_create_async_work(
        env,
        nullptr,
        resource,
        [](napi_env env, void* data) { },
        [](napi_env env, napi_status status, void* data) {
            if (data == nullptr) {
                SETTING_LOG_ERROR("manager data is null");
                return;
            }
            AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
            napi_value undefine;
            napi_get_undefined(env, &undefine);
            napi_value callback = nullptr;
            napi_value result = wrap_bool_to_js(env, (asyncCallbackInfo->status == 0));
            napi_get_reference_value(env, asyncCallbackInfo->callbackRef, &callback);
            napi_call_function(env, nullptr, callback, 1, &result, &undefine);
            napi_delete_reference(env, asyncCallbackInfo->callbackRef);
            napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
            delete asyncCallbackInfo;
            SETTING_LOG_INFO("manager change complete");
        },
        (void*)asyncCallbackInfo,
        &asyncCallbackInfo->asyncWork);
    if (ret != napi_ok) {
        SETTING_LOG_ERROR("create async work failed");
        return false;
    }
    ret = napi_queue_async_work(env, asyncCallbackInfo->asyncWork);
    if (ret != napi_ok) {
        SETTING_LOG_ERROR("queue async work failed");
        return false;
    }
    SETTING_LOG_INFO("queue async work success");
    return true;
}

napi_value opne_manager_settings(napi_env env, napi_callback_info info)
{
    SETTING_LOG_INFO("start opne manager settings.");
    size_t argc = ARGS_TWO;
    napi_value argv[ARGS_TWO] = { 0 };
    AsyncCallbackInfo* asyncCallbackInfo = new AsyncCallbackInfo {
        .env = env,
        .asyncWork = nullptr,
        .deferred = nullptr,
        .callbackRef = nullptr,
        .dataAbilityHelper = nullptr,
        .key = "",
        .value = "",
        .uri = "",
        .status = 0,
    };
    NAPI_CALL(env, napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr));
    if (argc != ARGS_TWO && argv[PARAM0] == nullptr && argv[PARAM1] == nullptr) {
        SETTING_LOG_ERROR("Args num less than two.");
        delete asyncCallbackInfo;
        return wrap_void_to_js(env);
    }

    // 检测入参类型
    napi_valuetype valueType;
    NAPI_CALL(env, napi_typeof(env, argv[PARAM0], &valueType));
    NAPI_ASSERT(env, valueType == napi_object, "Wrong argument[0] type. Object expected.");
    NAPI_CALL(env, napi_typeof(env, argv[PARAM1], &valueType));
    NAPI_ASSERT(env, valueType == napi_function, "Wrong argument[1] type. napi_function expected.");

    auto loadProductContext = std::make_shared<BaseContext>();
    if (!ParseAbilityContext(env, argv[PARAM0], loadProductContext->abilityContext,
        loadProductContext->uiExtensionContext)) {
        SETTING_LOG_ERROR("context parse error.");
        delete asyncCallbackInfo;
        return wrap_void_to_js(env);
    }

    // 处理请求信息
    OHOS::AAFwk::Want wantRequest;
    ExecuteLoadProduct(loadProductContext, wantRequest);
    if (!StartUiExtensionAbility(wantRequest, loadProductContext)) {
        SETTING_LOG_ERROR("opne manager faild.");
        delete asyncCallbackInfo;
        return wrap_void_to_js(env);
    }
    // 返回异步处理
    napi_create_reference(env, argv[PARAM1], 1, &(asyncCallbackInfo->callbackRef));
    if (!SetAsyncCallback(env, asyncCallbackInfo)) {
        SETTING_LOG_ERROR("callback set faild.");
        napi_delete_reference(env, asyncCallbackInfo->callbackRef);
        delete asyncCallbackInfo;
        return wrap_void_to_js(env);
    }
    SETTING_LOG_INFO("opne manager settings end.");
    return wrap_void_to_js(env);
}
}
}