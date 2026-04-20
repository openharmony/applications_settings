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

#ifndef INTELLIGENT_SCENE_JS_NAPI_COMMON_H
#define INTELLIGENT_SCENE_JS_NAPI_COMMON_H

#include "napi/native_api.h"
#include "napi/native_node_api.h"

namespace OHOS {
namespace IntelligentScene {

inline const std::string OHOS_GET_DONOTDISTURB_STATE_PERMISSION = "ohos.permission.GET_DONOTDISTURB_STATE";
constexpr int8_t ERROR = -1;
constexpr uint8_t PARAMS0 = 0;
constexpr uint8_t PARAMS1 = 1;
constexpr uint8_t MAIN_USER_ID = 100;
constexpr uint8_t PERMISSION_GRANTED = 0;

struct CallbackPromiseInfo {
    napi_ref callback = nullptr;
    napi_deferred deferred = nullptr;
    bool isCallback = false;
    int32_t errorCode = 0;
};

class Common {
    Common();

    ~Common();

public:
    static napi_value ParseParaOnlyCallback(const napi_env &env, const napi_callback_info &info, napi_ref &callback);

    static napi_value NapiGetNull(napi_env env);

    static napi_value CreateErrorValue(napi_env env, int32_t errCode, bool newType);

    static napi_value CreateErrorValue(napi_env env, int32_t errCode, std::string &msg);

    static napi_value NapiGetUndefined(napi_env env);

    static napi_value JSParaError(const napi_env &env, const napi_ref &callback);

    static napi_value NapiThrowError(const napi_env &env, int32_t errorCode, CallbackPromiseInfo &info,
        const napi_value &promise);

    static void SetPromise(const napi_env &env,
        const napi_deferred &deferred, const int32_t errorCode, const napi_value &result, bool newType);

    static void SetCallback(const napi_env &env,
        const napi_ref &callbackIn, const int32_t &errorCode, const napi_value &result, bool newType);

    static void SetCallback(
        const napi_env &env, const napi_ref &callbackIn, const napi_value &result);

    static void PaddingCallbackPromiseInfo(
        const napi_env &env, const napi_ref &callback, CallbackPromiseInfo &info, napi_value &promise);

    static void NapiThrow(napi_env env, int32_t errCode);

    static void NapiThrow(napi_env env, int32_t errCode, std::string &msg);

    static void CreateReturnValue(const napi_env &env, const CallbackPromiseInfo &info, const napi_value &result);

private:
    static const int32_t ONLY_CALLBACK_MAX_PARA = 1;
    static const int32_t ONLY_CALLBACK_MIN_PARA = 0;
    static const int32_t ERR_OK = 0;
    static const int32_t ARG_ONE = 1;
    static const int32_t ARG_TWO = 2;
};
}  // namespace IntelligentScene
}  // namespace OHOS

#endif  // INTELLIGENT_SCENE_JS_NAPI_COMMON_H