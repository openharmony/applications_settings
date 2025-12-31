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

#include "common.h"
#include "napi_intelligent_scene_log.h"
#include "intelligence_inner_errors.h"

namespace OHOS {
namespace IntelligentScene {
napi_value Common::ParseParaOnlyCallback(const napi_env &env, const napi_callback_info &info, napi_ref &callback)
{
    INTELLIGENT_SCENE_LOG_INFO("called");

    size_t argc = ONLY_CALLBACK_MAX_PARA;
    napi_value argv[ONLY_CALLBACK_MAX_PARA] = {nullptr};
    napi_value thisVar = nullptr;
    NAPI_CALL(env, napi_get_cb_info(env, info, &argc, argv, &thisVar, NULL));
    napi_valuetype valuetype = napi_undefined;
    if (argc >= ONLY_CALLBACK_MAX_PARA) {
        NAPI_CALL(env, napi_typeof(env, argv[PARAMS0], &valuetype));
        if (valuetype != napi_function) {
            INTELLIGENT_SCENE_LOG_INFO("Callback is not function excute promise.");
            return Common::NapiGetNull(env);
        }
        napi_create_reference(env, argv[PARAMS0], 1, &callback);
    }

    return Common::NapiGetNull(env);
}

napi_value Common::NapiGetNull(napi_env env)
{
    napi_value result = nullptr;
    napi_get_null(env, &result);
    return result;
}

napi_value Common::NapiGetUndefined(napi_env env)
{
    napi_value result = nullptr;
    napi_get_undefined(env, &result);
    return result;
}

void Common::NapiThrow(napi_env env, int32_t errCode)
{
    INTELLIGENT_SCENE_LOG_INFO("called");
    napi_throw(env, CreateErrorValue(env, errCode, true));
}

void Common::NapiThrow(napi_env env, int32_t errCode, std::string &msg)
{
    INTELLIGENT_SCENE_LOG_INFO("called");
    napi_throw(env, CreateErrorValue(env, errCode, msg));
}

void Common::SetPromise(const napi_env &env,
    const napi_deferred &deferred, const int32_t errorCode, const napi_value &result, bool newType)
{
    INTELLIGENT_SCENE_LOG_INFO("start");
    if (errorCode == ERR_OK) {
        napi_resolve_deferred(env, deferred, result);
    } else {
        napi_reject_deferred(env, deferred, CreateErrorValue(env, errorCode, newType));
    }
    INTELLIGENT_SCENE_LOG_INFO("end");
}

void Common::SetCallback(
    const napi_env &env, const napi_ref &callbackIn, const int32_t &errorCode, const napi_value &result, bool newType)
{
    INTELLIGENT_SCENE_LOG_INFO("start");
    napi_value undefined = nullptr;
    napi_get_undefined(env, &undefined);

    napi_value callback = nullptr;
    napi_value resultout = nullptr;
    napi_get_reference_value(env, callbackIn, &callback);
    if (callback == nullptr) {
        INTELLIGENT_SCENE_LOG_INFO("callback is nullptr.");
        return;
    }
    napi_value results[ARG_TWO] = {nullptr};
    results[PARAMS0] = CreateErrorValue(env, errorCode, newType);
    results[PARAMS1] = result;
    napi_status napi_result = napi_call_function(env, undefined, callback, ARG_TWO, &results[PARAMS0], &resultout);
    if (napi_result != napi_ok) {
        INTELLIGENT_SCENE_LOG_INFO("napi_call_function failed, result = %{public}d", napi_result);
    }
    NAPI_CALL_RETURN_VOID(env, napi_result);
    INTELLIGENT_SCENE_LOG_INFO("end");
}

void Common::SetCallback(
    const napi_env &env, const napi_ref &callbackIn, const napi_value &result)
{
    INTELLIGENT_SCENE_LOG_INFO("start");
    napi_value undefined = nullptr;
    napi_get_undefined(env, &undefined);

    napi_value callback = nullptr;
    napi_value resultout = nullptr;
    napi_get_reference_value(env, callbackIn, &callback);
    if (callback == nullptr) {
        INTELLIGENT_SCENE_LOG_INFO("callback is nullptr.");
        return;
    }
    napi_status napi_result = napi_call_function(env, undefined, callback, ARG_ONE, &result, &resultout);
    if (napi_result != napi_ok) {
        INTELLIGENT_SCENE_LOG_INFO("napi_call_function failed, result = %{public}d", napi_result);
    }
    NAPI_CALL_RETURN_VOID(env, napi_result);
    INTELLIGENT_SCENE_LOG_INFO("end");
}

void Common::PaddingCallbackPromiseInfo(
    const napi_env &env, const napi_ref &callback, CallbackPromiseInfo &info, napi_value &promise)
{
    INTELLIGENT_SCENE_LOG_INFO("called");
    if (callback) {
        INTELLIGENT_SCENE_LOG_INFO("has callback");
        info.callback = callback;
        info.isCallback = true;
    } else {
        napi_deferred deferred = nullptr;
        NAPI_CALL_RETURN_VOID(env, napi_create_promise(env, &deferred, &promise));
        info.deferred = deferred;
        info.isCallback = false;
    }
}

void Common::CreateReturnValue(const napi_env &env, const CallbackPromiseInfo &info, const napi_value &result)
{
    INTELLIGENT_SCENE_LOG_INFO("start, errorCode=%{public}d", info.errorCode);
    int32_t errorCode = info.errorCode == ERR_OK ? ERR_OK : ERROR_INTERNAL_ERROR;
    if (info.isCallback) {
        SetCallback(env, info.callback, errorCode, result, true);
    } else {
        SetPromise(env, info.deferred, errorCode, result, true);
    }
    INTELLIGENT_SCENE_LOG_INFO("end");
}

napi_value Common::CreateErrorValue(napi_env env, int32_t errCode, bool newType)
{
    INTELLIGENT_SCENE_LOG_INFO("called, errorCode[%{public}d]", errCode);
    napi_value error = Common::NapiGetNull(env);
    if (errCode == ERR_OK && newType) {
        return error;
    }

    napi_value code = nullptr;
    napi_create_int32(env, errCode, &code);

    std::string errMsg = OHOS::IntelligentScene::GetIntelligenceErrMessage(errCode);

    napi_value message = nullptr;
    napi_create_string_utf8(env, errMsg.c_str(), NAPI_AUTO_LENGTH, &message);

    napi_create_error(env, nullptr, message, &error);
    napi_set_named_property(env, error, "code", code);
    return error;
}

napi_value Common::CreateErrorValue(napi_env env, int32_t errCode, std::string &msg)
{
    INTELLIGENT_SCENE_LOG_INFO("called, errorCode[%{public}d]", errCode);
    napi_value error = Common::NapiGetNull(env);
    if (errCode == ERR_OK) {
        return error;
    }

    napi_value code = nullptr;
    napi_create_int32(env, errCode, &code);

    std::string errMsg = OHOS::IntelligentScene::GetIntelligenceErrMessage(errCode);

    napi_value message = nullptr;
    napi_create_string_utf8(env, errMsg.append(" ").append(msg).c_str(), NAPI_AUTO_LENGTH, &message);

    napi_create_error(env, nullptr, message, &error);
    napi_set_named_property(env, error, "code", code);
    return error;
}

napi_value Common::JSParaError(const napi_env &env, const napi_ref &callback)
{
    if (callback) {
        return Common::NapiGetNull(env);
    }
    napi_value promise = nullptr;
    napi_deferred deferred = nullptr;
    napi_create_promise(env, &deferred, &promise);
    SetPromise(env, deferred, ERROR, Common::NapiGetNull(env), false);
    return promise;
}

napi_value Common::NapiThrowError(const napi_env &env, int32_t errorCode,
    CallbackPromiseInfo &info, const napi_value &promise)
{
    napi_value result = nullptr;
    napi_get_boolean(env, false, &result);
    info.errorCode = errorCode;
    Common::CreateReturnValue(env, info, result);
    if (info.callback) {
        return Common::NapiGetNull(env);
    } else {
        return promise;
    }
}
}  // namespace IntelligentScene
}  // namespace OHOS