/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

#ifndef NAPI_SETTINGS_H
#define NAPI_SETTINGS_H

#include <vector>

#include "napi/native_api.h"
#include "napi/native_common.h"
#include "napi/native_node_api.h"
#include "uri.h"

#include "data_ability_helper.h"
#include "data_ability_predicates.h"
#include "datashare_helper.h"
#include "datashare_predicates.h"

#define ARGS_ONE 1
#define ARGS_TWO 2
#define ARGS_THREE 3
#define ARGS_FOUR 4
#define ARGS_FIVE 5

#define PARAM0 0
#define PARAM1 1
#define PARAM2 2
#define PARAM3 3
#define PARAM4 4

enum CallType {
    INVALID_CALL,
    STAGE_SYNC,
    STAGE_CALLBACK,
    STAGE_CALLBACK_SPECIFIC,
    STAGE_PROMISE,
    STAGE_PROMISE_SPECIFIC,
    FA_SYNC,
    FA_CALLBACK,
    FA_PROMISE
};

struct AsyncCallbackInfo {
    napi_env env;
    napi_async_work asyncWork;
    napi_deferred deferred;
    napi_ref callbackRef;
    std::shared_ptr<OHOS::AppExecFwk::DataAbilityHelper> dataAbilityHelper;
    std::string key;
    std::string value;
    std::string uri;
    CallType callType;
    std::string tableName;
    int status;
    std::shared_ptr<OHOS::DataShare::DataShareHelper> dataShareHelper = nullptr;
};

namespace OHOS {
namespace Settings {
/**
 * @brief Wrap void to js value.
 * ability_context
 * @param env the environment that the Node-API call is invoked under
 * @return napi_value napi_value after wrapped
 */
napi_value wrap_void_to_js(napi_env env);

/**
 * @brief Wrap string to js value.
 *
 * @param env the environment that the Node-API call is invoked under
 * @param value string value to be wrap
 * @return napi_value js value after wrapped
 */
napi_value wrap_string_to_js(napi_env env, const std::string &value);

/**
 * @brief Wrap bool to js value.
 *
 * @param env the environment that the Node-API call is invoked under
 * @param value bool value to be wrap
 * @return napi_value js value after wrapped
 */
napi_value wrap_bool_to_js(napi_env env, bool value);

/**
 * @brief Unwrap string from js value.
 *
 * @param env the environment that the Node-API call is invoked under
 * @param param js value to unwrap
 * @return std::string string value after unwrapped
 */
std::string unwrap_string_from_js(napi_env env, napi_value param);

/**
 * @brief getUri NAPI implementation.
 * @param env the environment that the Node-API call is invoked under
 * @param info the callback info passed into the callback function
 * @return napi_value the return value from NAPI C++ to JS for the module.
 */
napi_value napi_get_uri(napi_env env, napi_callback_info info);

/**
 * @brief getUriSync NAPI implementation.
 * @param env the environment that the Node-API call is invoked under
 * @param info the callback info passed into the callback function
 * @return napi_value the return value from NAPI C++ to JS for the module.
 */
napi_value napi_get_uri_sync(napi_env env, napi_callback_info info);

/**
 * @brief getValue NAPI implementation.
 * @param env the environment that the Node-API call is invoked under
 * @param info the callback info passed into the callback function
 * @return napi_value the return value from NAPI C++ to JS for the module.
 */
napi_value napi_get_value(napi_env env, napi_callback_info info);
napi_value napi_get_value_ext(napi_env env, napi_callback_info info, const bool stageMode);

/**
 * @brief getValueSync NAPI implementation.
 * @param env the environment that the Node-API call is invoked under
 * @param info the callback info passed into the callback function
 * @return napi_value the return value from NAPI C++ to JS for the module.
 */
napi_value napi_get_value_sync(napi_env env, napi_callback_info info);

/**
 * @brief setValue NAPI implementation.
 * @param env the environment that the Node-API call is invoked under
 * @param info the callback info passed into the callback function
 * @return napi_value the return value from NAPI C++ to JS for the module.
 */
napi_value napi_set_value(napi_env env, napi_callback_info info);
napi_value napi_set_value_ext(napi_env env, napi_callback_info info, const bool stageMode);

/**
 * @brief setValueSync NAPI implementation.
 * @param env the environment that the Node-API call is invoked under
 * @param info the callback info passed into the callback function
 * @return napi_value the return value from NAPI C++ to JS for the module.
 */
napi_value napi_set_value_sync(napi_env env, napi_callback_info info);

/**
 * @brief initNapiClass NAPI implementation.
 * @param env the environment that the Node-API call is invoked under
 * @param exports the class property
 * @return napi_value the return value from NAPI C++ to JS for the module.
 */
napi_value InitNapiClass(napi_env env, napi_value exports);

/**
 * @brief enableAirplaneMode NAPI implementation.
 * @param env the environment that the Node-API call is invoked under
 * @param info the callback info passed into the callback function
 * @return napi_value the return value from NAPI C++ to JS for the module.
 */
napi_value napi_enable_airplane_mode(napi_env env, napi_callback_info info);

/**
 * @brief canShowFloating NAPI implementation.
 * @param env the environment that the Node-API call is invoked under
 * @param info the callback info passed into the callback function
 * @return napi_value the return value from NAPI C++ to JS for the module.
 */
napi_value napi_can_show_floating(napi_env env, napi_callback_info info);
std::string GetStageUriStr(std::string tableName, std::string idStr, std::string keyStr);
std::string GetProxyUriStr(std::string tableName, std::string idStr);
bool IsTableNameInvalid(std::string tableName);
std::shared_ptr<DataShare::DataShareHelper> getDataShareHelper(
    napi_env env, const napi_value context, const bool stageMode, std::string tableName = "global");
napi_value napi_get_value_sync_ext(bool stageMode, size_t argc, napi_env env, napi_value* args);
napi_value napi_set_value_sync_ext(bool stageMode, size_t argc, napi_env env, napi_value* args);
napi_value napi_register_key_observer(napi_env env, napi_callback_info info);
napi_value napi_unregister_key_observer(napi_env env, napi_callback_info info);
}  // namespace Settings
}  // namespace OHOS
#endif  //  NAPI_SETTINGS_H
