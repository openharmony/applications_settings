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
#include <json/json.h>
#include "paramters.h"

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

napi_value CreateError(napi_env env, int code, std::string message)
{
    napi_value error;
    napi_value tempCode;
    napi_value tempMessage;
    napi_create_string_utf8(env, message.c_str(), NAPI_AUTO_LENGTH, &tempMessage);
    napi_create_uint32(env, code, &tempCode);
    napi_create_error(env, tempCode, tempMessage, &error);
    return error;
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

void SettingsCompletePromise(napi_env env, AsyncCallbackInfo* asyncCallbackInfo, napi_value result)
{
    SETTING_LOG_INFO("settings complete promise.");
    if (asyncCallbackInfo->status == SETTINGS_SUCCESS) {
        napi_resolve_deferred(env, asyncCallbackInfo->deferred, result);
    } else {
        SettingsError error = ReadErrorMessage(asyncCallbackInfo->status);
        result = CreateError(env, error.errorCode, error.message);
        napi_reject_deferred(env, asyncCallbackInfo->deferred, result);
    }
}

void SettingsCompleteCall(napi_env env, AsyncCallbackInfo* asyncCallbackInfo, napi_value result)
{
    SETTING_LOG_INFO("settings complete call.");
    napi_value ret[PARAM2] = {0};
    ret[PARAM1] = result;
    if (asyncCallbackInfo->status == SETTINGS_SUCCESS) {
        napi_get_undefined(env, &ret[PARAM0]);
    } else {
        SettingsError error = ReadErrorMessage(asyncCallbackInfo->status);
        ret[PARAM0] = CreateError(env, error.errorCode, error.message);
    }
    napi_value callback = nullptr;
    napi_value returnValue;
    napi_get_reference_value(env, asyncCallbackInfo->callbackRef, &callback);
    napi_call_function(env, nullptr, callback, PARAM2, ret, &returnValue);
    napi_delete_reference(env, asyncCallbackInfo->callbackRef);
}

napi_value SetAsyncCallback(napi_env env, AsyncCallbackInfo* asyncCallbackInfo)
{
    napi_value resource = nullptr;
    napi_status ret = napi_ok;
    ret = napi_create_string_utf8(env, "openNetworkManagerSettings", NAPI_AUTO_LENGTH, &resource);
    if (ret != napi_ok) {
        SETTING_LOG_ERROR("create string failed");
        napi_delete_reference(env, asyncCallbackInfo->callbackRef);
        delete asyncCallbackInfo;
        return wrap_void_to_js(env);
    }
    napi_value promise;
    napi_deferred deferred;
    if (napi_create_promise(env, &deferred, &promise) != napi_ok) {
        SETTING_LOG_ERROR("napi_create_promise error");
        delete asyncCallbackInfo;
        return wrap_void_to_js(env);
    }
    asyncCallbackInfo->deferred = deferred;
    ret = napi_create_async_work(env, nullptr, resource, [](napi_env env, void* data) { },
        [](napi_env env, napi_status status, void* data) {
            if (data == nullptr) {
                SETTING_LOG_ERROR("manager data is null");
                return;
            }
            AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
            napi_value result = wrap_bool_to_js(env, (asyncCallbackInfo->status == SETTINGS_SUCCESS));
            SettingsCompletePromise(env, asyncCallbackInfo, result);
            napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
            delete asyncCallbackInfo;
            SETTING_LOG_INFO("manager change complete");
        }, (void*)asyncCallbackInfo, &asyncCallbackInfo->asyncWork);
    if (ret != napi_ok) {
        SETTING_LOG_ERROR("create async work failed");
        napi_delete_reference(env, asyncCallbackInfo->callbackRef);
        delete asyncCallbackInfo;
        return wrap_void_to_js(env);
    }
    ret = napi_queue_async_work(env, asyncCallbackInfo->asyncWork);
    if (ret != napi_ok) {
        SETTING_LOG_ERROR("queue async work failed");
        napi_delete_reference(env, asyncCallbackInfo->callbackRef);
        napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
        delete asyncCallbackInfo;
        return wrap_void_to_js(env);
    }
    SETTING_LOG_INFO("queue async work success");
    return promise;
}

bool CheckParam(napi_env env, AsyncCallbackInfo* asyncCallbackInfo, napi_callback_info info,
    size_t &argc, napi_value* argv)
{
    napi_valuetype valueType;
    napi_status ret = napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);
    if (ret != napi_ok) {
        return false;
    }

    if (argc == ARGS_ONE) {
        ret = napi_typeof(env, argv[PARAM0], &valueType);
        if (ret != napi_ok || valueType != napi_object) {
            return false;
        }
        asyncCallbackInfo->callType = FA_PROMISE;
    } else if (argc == ARGS_TWO) {
        ret = napi_typeof(env, argv[PARAM0], &valueType);
        if (ret != napi_ok || valueType != napi_object) {
            return false;
        }
        ret = napi_typeof(env, argv[PARAM1], &valueType);
        if (ret != napi_ok || valueType != napi_function) {
            return false;
        }
        ret = napi_create_reference(env, argv[PARAM1], 1, &asyncCallbackInfo->callbackRef);
        if (ret != napi_ok) {
            SETTING_LOG_ERROR("create call failed.");
            return false;
        }
        asyncCallbackInfo->callType = FA_CALLBACK;
    } else {
        SETTING_LOG_ERROR("argc is invalid.");
        return false;
    }
    return true;
}

napi_value opne_manager_settings(napi_env env, napi_callback_info info)
{
    SETTING_LOG_INFO("start opne manager settings.");
    size_t argc = ARGS_TWO;
    napi_value argv[ARGS_TWO] = { 0 };
    AsyncCallbackInfo* asyncCallbackInfo = new AsyncCallbackInfo();
    // 参数校验
    bool isInvalid = CheckParam(env, asyncCallbackInfo, info, argc, argv);
    if (!isInvalid) {
        SETTING_LOG_ERROR("param is invalid.");
        asyncCallbackInfo->status = SETTINGS_PARAM_ERROR;
        return SetAsyncCallback(env, asyncCallbackInfo);
    }

    auto loadProductContext = std::make_shared<BaseContext>();
    if (!ParseAbilityContext(env, argv[PARAM0], loadProductContext->abilityContext,
        loadProductContext->uiExtensionContext)) {
        SETTING_LOG_ERROR("context parse error.");
        asyncCallbackInfo->status = SETTINGS_PARAM_ERROR;
        return SetAsyncCallback(env, asyncCallbackInfo);
    }

    // 处理请求信息
    OHOS::AAFwk::Want wantRequest;
    ExecuteLoadProduct(loadProductContext, wantRequest);
    if (!StartUiExtensionAbility(wantRequest, loadProductContext)) {
        asyncCallbackInfo->status = SETTINGS_ORIGINAL_SERVICE_ERROR;
        SETTING_LOG_ERROR("opne manager faild.");
    }

    SETTING_LOG_INFO("opne manager settings end.");
    return SetAsyncCallback(env, asyncCallbackInfo);
}

void ThrowParamErrorException(napi_env env)
{
    ThrowExistingError(env, SETTINGS_PARAM_INVALID_CODE, "param is invalid, start settings failed");
}

void StartUiExtensionWithParams(napi_env env, const napi_value &obj, OHOS::AAFwk::Want &request)
{
    auto loadProductContext = std::make_shared<BaseContext>();
    if (!ParseAbilityContext(env, argv[PARAM0], loadProductContext->abilityContext, loadProductContext->uiExtensionContext)) {
        SETTING_LOG_ERROR("context parse error.");
        ThrowExistingError(env);
        return;
    }
    request.SetElementName(SETTINGS_PACKAGE_NAME, SETTINGS_COMMON_EXTERNAL_PAGE_NAME);
    request.SetParam(UIEXTENSION_TYPE_KEY, UIEXTENSION_TYPE_VALUE);
    if (!StartUiExtensionAbility(requset, loadProductContext)) {
        SETTING_LOG_ERROR("open settings error.");
        ThrowExistingError(env);
    }
}

napi_value openInputMethodSettings(napi_env env, napi_callback_info info) 
{
    SETTING_LOG_INFO("start openInputMethodSettings.");
    // 设备校验
    if (IsPageSupportJump(DEVICE_TYPE, SettingsPageUrl::INPUT_PAGE)) {
        SETTING_LOG_ERROR("open settings error.");
        return wrap_void_to_js(env);
    }
    size_t argc = ARGS_ONE;
    napi_value argv[ARGS_ONE] = {nullptr};
    
    // 参数校验
    napi_status ret = napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);
    if (ret != napi_ok || argc != ARGS_ONE) {
        SETTING_LOG_ERROR("param is invalid.");
        ThrowExistingError(env);
        return wrap_void_to_js(env);
    }
    
    // 处理请求信息
    OHOS::AAFwk::Want wantRequest;
    wantRequest.SetUri(SettingsPageUrl::INPUT_PAGE);
    StartUiExtensionWithParams(env, argv[PARAM0], wantRequest);
    SETTING_LOG_INFO("openInputMethodSettings end.");
    return wrap_void_to_js(env);
}

napi_value openInputMethodDetail(napi_env env, napi_callback_info info)
{
    SETTING_LOG_INFO("start openInputMethodDetail.");
    // 设备校验
    if (IsPageSupportJump(DEVICE_TYPE, SettingsPageUrl::INPUT_DETAIL_PAGE)) {
        SETTING_LOG_ERROR("open settings error.");
        return wrap_void_to_js(env);
    }
    size_t argc = ARGS_THREE;
    napi_value argv[ARGS_THREE] = {nullptr};
    
    // 参数校验
    napi_status ret = napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);
    if (ret != napi_ok || argc != ARGS_THREE) {
        SETTING_LOG_ERROR("param is invalid.");
        ThrowExistingError(env);
        return wrap_void_to_js(env);
    }
    
    std::string bundleName = unwrap_string_from_js(env, argv[ARGS_ONE]);
    std::string inputMethodId = unwrap_string_from_js(env, argv[ARGS_TWO]);
    
    // 处理请求信息
    OHOS::AAFwk::Want wantRequest;
    Json::Value value;
    Json::Value extra;
    extra[INPUT_DETAIL_WANT_VALUE] = bundleName;
    extra[INPUT_DETAIL_WANT_NAME] = inputMethodId;
    value[INPUT_DETAIL_WANT_EXTRA] = extra;
    Json::StreamWriterBuilder builder;
    std::string param = Json::writeString(builder, value);
    wantRequest.SetParam(SETTINGS_PUSH_PARAM, param);
    wantRequest.SetParam(SETTINGS_PUSH_PARAM_JSON_TYPE, true);
    wantRequest.SetUri(SettingsPageUrl::INPUT_DETAIL_PAGE);
    StartUiExtensionWithParams(env, argv[PARAM0], wantRequest);
    SETTING_LOG_INFO("openInputMethodDetail end.");
    return wrap_void_to_js(env);
}
} // namespace Settings
} // namespace OHOS