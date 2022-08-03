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

#include "napi_settings.h"

#include <pthread.h>
#include <unistd.h>

#include "ability.h"
#include "abs_shared_result_set.h"
#include "context.h"
#include "data_ability_helper.h"
#include "data_ability_predicates.h"
#include "hilog_wrapper.h"
#include "values_bucket.h"

using namespace OHOS::AppExecFwk;

namespace ohos {
namespace settings {
const std::string SETTINGS_DATA_BASE_URI = "dataability:///com.ohos.settingsdata.DataAbility";
const std::string SETTINGS_DATA_FIELD_KEYWORD = "KEYWORD";
const std::string SETTINGS_DATA_FIELD_VALUE = "VALUE";

/**
 * @brief Wrap void to js value.
 * ability_context
 * @param env the environment that the Node-API call is invoked under
 * @return napi_value napi_value after wrapped
 */
napi_value wrap_void_to_js(napi_env env)
{
    napi_value result = nullptr;
    NAPI_CALL(env, napi_get_null(env, &result));
    return result;
}

/**
 * @brief Unwrap string from js value.
 *
 * @param env the environment that the Node-API call is invoked under
 * @param param js value to unwrap
 * @return std::string string value after unwrapped
 */
std::string unwrap_string_from_js(napi_env env, napi_value param)
{
    std::string defaultValue("");

    size_t size = 0;
    if (napi_get_value_string_utf8(env, param, nullptr, 0, &size) != napi_ok) {
        return defaultValue;
    }

    if (size == 0) {
        return defaultValue;
    }

    std::string value("");

    char *buf = new (std::nothrow) char[size + 1];
    if (buf == nullptr) {
        HILOG_INFO("settingsnapi : unwarp");
        return value;
    }
    memset_s(buf, size + 1, 0, size + 1);

    bool rev = napi_get_value_string_utf8(env, param, buf, size + 1, &size) == napi_ok;
    if (rev) {
        value = buf;
    } else {
        value = defaultValue;
    }

    delete[] buf;
    buf = nullptr;
    HILOG_INFO("settingsnapi : unwarp string is : %{public}s", value.c_str());
    return value;
}

/**
 * @brief Wrap string to js value.
 *
 * @param env the environment that the Node-API call is invoked under
 * @param value string value to be wrap
 * @return napi_value js value after wrapped
 */
napi_value wrap_string_to_js(napi_env env, const std::string &value)
{
    napi_value result = nullptr;
    NAPI_CALL(env, napi_create_string_utf8(env, value.c_str(), NAPI_AUTO_LENGTH, &result));
    return result;
}

/**
 * @brief Wrap bool to js value.
 *
 * @param env the environment that the Node-API call is invoked under
 * @param value bool value to be wrap
 * @return napi_value js value after wrapped
 */
napi_value wrap_bool_to_js(napi_env env, bool value)
{
    napi_value result = nullptr;
    NAPI_CALL(env, napi_get_boolean(env, value, &result));
    return result;
}

struct AsyncCallbackInfo {
    napi_env env;
    napi_async_work asyncWork;
    napi_deferred deferred;
    napi_ref callbackRef;
    DataAbilityHelper *dataAbilityHelper;
    std::string key;
    std::string value;
    std::string uri;
    int status;
};

/**
 * @brief getUri NAPI implementation.
 *
 * @param env the environment that the Node-API call is invoked under
 * @param info the callback info passed into the callback function
 * @return napi_value the return value from NAPI C++ to JS for the module.
 */
napi_value napi_get_uri_sync(napi_env env, napi_callback_info info)
{
    HILOG_INFO("napi_get_uri called...");

    napi_value retUri = nullptr;

    // Check the number of the arguments
    size_t argc = ARGS_ONE;
    napi_value args[ARGS_ONE] = {nullptr};
    NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
    if (argc != ARGS_ONE) {
        HILOG_ERROR("%{public}s, wrong number of arguments.", __func__);
        return wrap_void_to_js(env);
    }

    // Check the value type of the arguments
    napi_valuetype valueType;
    NAPI_CALL(env, napi_typeof(env, args[PARAM0], &valueType));
    NAPI_ASSERT(env, valueType == napi_string, "Wrong argument type. String expected.");

    std::string uriArgStr = unwrap_string_from_js(env, args[PARAM0]);
    uriArgStr = uriArgStr.empty() ? SETTINGS_DATA_BASE_URI : (SETTINGS_DATA_BASE_URI + "/" + uriArgStr);

    retUri = wrap_string_to_js(env, uriArgStr);
    return retUri;
}

napi_value napi_get_uri(napi_env env, napi_callback_info info)
{
    HILOG_INFO("settingsnapi : uri napi_set_value called...");
    // Check the number of the arguments
    size_t argc = ARGS_TWO;
    napi_value args[ARGS_TWO] = {nullptr};
    NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
    if (argc != ARGS_ONE && argc != ARGS_TWO) {
        HILOG_ERROR("settingsnapi : uri %{public}s, wrong number of arguments, expect 1 or 2 but get %{public}zd",
            __func__, argc);
        return wrap_void_to_js(env);
    }

    HILOG_INFO("settingsnapi : uri arg count is %{public}zd", argc);
    HILOG_INFO("settingsnapi : uri start create aysnc call back info");
    AsyncCallbackInfo* asyncCallbackInfo = new AsyncCallbackInfo {
        .env = env,
        .asyncWork = nullptr,
        .deferred = nullptr,
        .callbackRef = nullptr,
        .dataAbilityHelper = nullptr,
        .key = "",
        .value = "",
        .uri = "",
        .status = false,
    };

    // Check the value type of the arguments
    napi_valuetype valueType;
    NAPI_CALL(env, napi_typeof(env, args[PARAM0], &valueType));
    NAPI_ASSERT(env, valueType == napi_string, "settingsnapi : uri Wrong argument type. String expected.");

    std::string uriArgStr = unwrap_string_from_js(env, args[PARAM0]);
    uriArgStr = uriArgStr.empty() ? SETTINGS_DATA_BASE_URI : (SETTINGS_DATA_BASE_URI + "/" + uriArgStr);
    asyncCallbackInfo->uri = uriArgStr;
    HILOG_INFO("settingsnapi : uri after uri is %{public}s", asyncCallbackInfo->uri.c_str());
    HILOG_INFO("settingsnapi : uri after create aysnc call back info");

    napi_value resource = nullptr;
    NAPI_CALL(env, napi_create_string_utf8(env, "getUri", NAPI_AUTO_LENGTH, &resource));

    if (argc == 2) {
        HILOG_INFO("settingsnapi : uri do callback");
        napi_create_reference(env, args[PARAM1], 1, &asyncCallbackInfo->callbackRef);

        napi_create_async_work(
            env,
            nullptr,
            resource,
            [](napi_env env, void* data) {
                HILOG_INFO("settingsnapi : uri callback async execute callback");
            },
            [](napi_env env, napi_status status, void* data) {
                if (data == nullptr) {
                    HILOG_INFO("settingsnapi : uri callback async end data is null");
                    return;
                }
                HILOG_INFO("settingsnapi : uri callback async end called callback");
                AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
                napi_value undefine;
                napi_get_undefined(env, &undefine);
                napi_value callback = nullptr;
                napi_value result = wrap_string_to_js(env, asyncCallbackInfo->uri);
                napi_get_reference_value(env, asyncCallbackInfo->callbackRef, &callback);
                napi_call_function(env, nullptr, callback, 1, &result, &undefine);
                napi_delete_reference(env, asyncCallbackInfo->callbackRef);
                napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
                delete asyncCallbackInfo;
                HILOG_INFO("settingsnapi : uri callback change callback complete");
            },
            (void*)asyncCallbackInfo,
            &asyncCallbackInfo->asyncWork
        );

        HILOG_INFO("settingsnapi : uri callback start async work");
        NAPI_CALL(env, napi_queue_async_work(env, asyncCallbackInfo->asyncWork));
        HILOG_INFO("settingsnapi : uri callback end async work");
        return wrap_void_to_js(env);
    } else {
        HILOG_INFO("settingsnapi : uri do promise");
        napi_value promise;
        napi_deferred deferred;
        NAPI_CALL(env, napi_create_promise(env, &deferred, &promise));
        asyncCallbackInfo->deferred = deferred;

        napi_create_async_work(
            env,
            nullptr,
            resource,
            // aysnc executed task
            [](napi_env env, void* data) {
                HILOG_INFO("settingsnapi : uri promise async execute callback");
            },
            // async end called callback
            [](napi_env env, napi_status status, void* data) {
                HILOG_INFO("settingsnapi : uri promise async end called callback");
                AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
                HILOG_INFO("settingsnapi : uri promise end get callback value is %{public}s", asyncCallbackInfo->uri.c_str());
                napi_value result = wrap_string_to_js(env, asyncCallbackInfo->uri);
                napi_resolve_deferred(asyncCallbackInfo->env, asyncCallbackInfo->deferred, result);
                napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
                delete asyncCallbackInfo;
            },
            (void*)asyncCallbackInfo,
            &asyncCallbackInfo->asyncWork);
        napi_queue_async_work(env, asyncCallbackInfo->asyncWork);
        HILOG_INFO("settingsnapi: uri promise end sync work");
        return promise;
    }
}

/**
 * @brief getValue NAPI implementation.
 *
 * @param env the environment that the Node-API call is invoked under
 * @param info the callback info passed into the callback function
 * @return napi_value the return value from NAPI C++ to JS for the module.
 */
napi_value napi_get_value_sync(napi_env env, napi_callback_info info)
{
    HILOG_INFO("napi_get_value called...");

    // Check the number of the arguments
    size_t argc = ARGS_THREE;
    napi_value args[ARGS_THREE] = {nullptr};
    NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
    if (argc != ARGS_THREE) {
        HILOG_ERROR("%{public}s, wrong number of arguments.", __func__);
        return wrap_void_to_js(env);
    }

    // Check the value type of the arguments
    napi_valuetype valueType;
    NAPI_CALL(env, napi_typeof(env, args[PARAM0], &valueType));
    NAPI_ASSERT(env, valueType == napi_object, "Wrong argument[0] type. Object expected.");
    NAPI_CALL(env, napi_typeof(env, args[PARAM1], &valueType));
    NAPI_ASSERT(env, valueType == napi_string, "Wrong argument[1] type. String expected.");
    NAPI_CALL(env, napi_typeof(env, args[PARAM2], &valueType));
    NAPI_ASSERT(env, valueType == napi_string, "Wrong argument[2] type. String expected.");

    std::shared_ptr<Uri> uri = std::make_shared<Uri>(SETTINGS_DATA_BASE_URI);
    DataAbilityHelper *dataAbilityHelper = nullptr;
    NAPI_CALL(env, napi_unwrap(env, args[PARAM0], reinterpret_cast<void **>(&dataAbilityHelper)));

    std::vector<std::string> columns;
    columns.push_back(SETTINGS_DATA_FIELD_VALUE);
    OHOS::NativeRdb::DataAbilityPredicates predicates;
    predicates.EqualTo(SETTINGS_DATA_FIELD_KEYWORD, unwrap_string_from_js(env, args[PARAM1]));

    HILOG_INFO("napi_get_value called... before dataAbilityHelper->Query");
    std::shared_ptr<OHOS::NativeRdb::AbsSharedResultSet> resultset =
        dataAbilityHelper->Query(*uri, columns, predicates);
    HILOG_INFO("napi_get_value called... after dataAbilityHelper->Query");

    napi_value retVal = nullptr;
    int numRows = 0;

    if (resultset != nullptr) {
        HILOG_INFO("napi_get_value called... resultset is NOT empty");
        resultset->GetRowCount(numRows);
    }

    if (resultset == nullptr || numRows == 0) {
        HILOG_INFO("napi_get_value called... return default value");
        retVal = args[PARAM2];
    } else {
        HILOG_INFO("napi_get_value called... return value from resultset");
        std::string val;
        int32_t columnIndex = 0;
        resultset->GoToFirstRow();
        resultset->GetString(columnIndex, val);
        retVal = wrap_string_to_js(env, val);
    }

    if (resultset != nullptr) {
        resultset->Close();
    }
    dataAbilityHelper = nullptr;
    HILOG_INFO("napi_get_value called... END!");
    return retVal;
}

napi_value napi_get_value(napi_env env, napi_callback_info info)
{
    // getValue api need 3 parameters when Promise mode and need 4 parameters when callback mode
    const size_t paramOfPromise = ARGS_TWO;
    const size_t paramOfCallback = ARGS_THREE;

    size_t argc = ARGS_THREE;
    napi_value args[ARGS_THREE] = {nullptr};
    NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
    if (argc != paramOfCallback && argc != paramOfPromise) {
        HILOG_ERROR("settingsnapi : %{public}s, wrong number of arguments, expect 2 or 3 but get %{public}zd",
            __func__, argc);
        return wrap_void_to_js(env);
    }

    HILOG_INFO("settingsnapi : napi_get_value arg count is %{public}zd", argc);
    HILOG_INFO("settingsnapi : napi_get_value start create aysnc call back info");
    AsyncCallbackInfo* asyncCallbackInfo = new AsyncCallbackInfo {
        .env = env,
        .asyncWork = nullptr,
        .deferred = nullptr,
        .callbackRef = nullptr,
        .dataAbilityHelper = nullptr,
        .key = "",
        .value = "",
        .uri = "",
        .status = false,
    };
    HILOG_INFO("settingsnapi : after create aysnc call back info");
    // Check the value type of the arguments
    napi_valuetype valueType;
    NAPI_CALL(env, napi_typeof(env, args[PARAM0], &valueType));
    NAPI_ASSERT(env, valueType == napi_object, "Wrong argument[0], type. Object expected");
    NAPI_CALL(env, napi_typeof(env, args[PARAM1], &valueType));
    NAPI_ASSERT(env, valueType == napi_string, "Wrong argument[1], type. String expected");
    
    NAPI_CALL(env, napi_unwrap(env, args[PARAM0], reinterpret_cast<void **>(&asyncCallbackInfo->dataAbilityHelper)));
    HILOG_INFO("settingsnapi : input paramter is (DataAbilityHelper)");

    asyncCallbackInfo->key = unwrap_string_from_js(env, args[PARAM1]);
    HILOG_INFO("settingsnapi : input parameter is : (key %{public}s", asyncCallbackInfo->key.c_str());

    napi_value resource = nullptr;
    NAPI_CALL(env, napi_create_string_utf8(env, "getValue", NAPI_AUTO_LENGTH, &resource));

    if (argc == paramOfCallback) {
        HILOG_INFO("settingsnapi : do callback");

        napi_create_reference(env, args[PARAM2], 1, &asyncCallbackInfo->callbackRef);

        napi_create_async_work(
            env,
            nullptr,
            resource,
            // aysnc executed task
            [](napi_env env, void* data) {
                if (data == nullptr) {
                    HILOG_INFO("settingsnapi : callback async execute data is null");
                    return;
                }
                HILOG_INFO("settingsnapi : callback async execute callback");
                AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
                
                std::vector<std::string> columns;
                columns.push_back(SETTINGS_DATA_FIELD_VALUE);
                OHOS::NativeRdb::DataAbilityPredicates predicates;
                predicates.EqualTo(SETTINGS_DATA_FIELD_KEYWORD, asyncCallbackInfo->key);

                std::shared_ptr<Uri> uri = std::make_shared<Uri>(SETTINGS_DATA_BASE_URI);
                HILOG_INFO("settingsnapi : callback napi_get_value called... before dataAbilityHelper->Query");
                std::shared_ptr<OHOS::NativeRdb::AbsSharedResultSet> resultset =
                    asyncCallbackInfo->dataAbilityHelper->Query(*uri, columns, predicates);
                HILOG_INFO("settingsnapi : callback napi_get_value called... after dataAbilityHelper->Query");

                int numRows = 0;
                if (resultset != nullptr) {
                    HILOG_INFO("settingsnapi : callback napi_get_value called... resultset is NOT empty");
                    resultset->GetRowCount(numRows);
                }
                if (resultset == nullptr || numRows == 0) {
                    HILOG_INFO("settingsnapi : callback napi_get_value called... return default value");
                } else {
                    HILOG_INFO("settingsnapi : callback napi_get_value called... return value from resultset");
                    std::string val;
                    int32_t columnIndex = 0;
                    resultset->GoToFirstRow();
                    resultset->GetString(columnIndex, val);
                    HILOG_INFO("settingsnapi : callback retVal is %{public}s", val.c_str());
                    asyncCallbackInfo->value = val;
                }
                if (resultset != nullptr) {
                    resultset->Close();
                }
            },
            // async end called callback
            [](napi_env env, napi_status status, void* data) {
                if (data == nullptr) {
                    HILOG_INFO("settingsnapi : callback async end data is null");
                    return;
                }
                HILOG_INFO("settingsnapi : callback async end called callback");
                AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
                napi_value undefine;
                napi_get_undefined(env, &undefine);
                HILOG_INFO("settingsnapi : callback aysnc end called");
                napi_value callback = nullptr;
                napi_value result = wrap_string_to_js(env, asyncCallbackInfo->value);
                HILOG_INFO("settingsnapi : callback aysnc end called");
                napi_get_reference_value(env, asyncCallbackInfo->callbackRef, &callback);
                napi_call_function(env, nullptr, callback, 1, &result, &undefine);
                HILOG_INFO("settingsnapi : callback aysnc end called");
                napi_delete_reference(env, asyncCallbackInfo->callbackRef);
                napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
                asyncCallbackInfo->dataAbilityHelper = nullptr;
                delete asyncCallbackInfo;
                HILOG_INFO("settingsnapi : callback change callback complete");
            },
            (void*)asyncCallbackInfo,
            &asyncCallbackInfo->asyncWork
        );

        HILOG_INFO("settingsnapi :  callback start async work");
        NAPI_CALL(env, napi_queue_async_work(env, asyncCallbackInfo->asyncWork));
        HILOG_INFO("settingsnapi : callback end async work");
        return wrap_void_to_js(env);
    } else {
        HILOG_INFO("settingsnapi : do promise");
        napi_value promise;
        napi_deferred deferred;
        NAPI_CALL(env, napi_create_promise(env, &deferred, &promise));
        asyncCallbackInfo->deferred = deferred;

        napi_create_async_work(
        env,
        nullptr,
        resource,
        // aysnc executed task
        [](napi_env env, void* data) {
            HILOG_INFO("settingsnapi : promise async execute callback");
            AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
            HILOG_INFO("settingsnapi : promise get callback key is %{public}s", asyncCallbackInfo->key.c_str());
            HILOG_INFO("settingsnapi : promise get callback value is %{public}s", asyncCallbackInfo->value.c_str());

            std::vector<std::string> columns;
            columns.push_back(SETTINGS_DATA_FIELD_VALUE);
            OHOS::NativeRdb::DataAbilityPredicates predicates;
            predicates.EqualTo(SETTINGS_DATA_FIELD_KEYWORD, asyncCallbackInfo->key);

            std::shared_ptr<Uri> uri = std::make_shared<Uri>(SETTINGS_DATA_BASE_URI);
            HILOG_INFO("settingsnapi : promise napi_get_value called... before dataAbilityHelper->Query");
            std::shared_ptr<OHOS::NativeRdb::AbsSharedResultSet> resultset =
                asyncCallbackInfo->dataAbilityHelper->Query(*uri, columns, predicates);
            HILOG_INFO("settingsnapi : promise napi_get_value called... after dataAbilityHelper->Query");

            int numRows = 0;
            if (resultset != nullptr) {
                HILOG_INFO("settingsnapi : promise napi_get_value called... resultset is NOT empty");
                resultset->GetRowCount(numRows);
            }
            if (resultset == nullptr || numRows == 0) {
                HILOG_INFO("settingsnapi : promise napi_get_value called... return default value");
            } else {
                HILOG_INFO("settingsnapi : promise napi_get_value called... return value from resultset");
                std::string val;
                int32_t columnIndex = 0;
                resultset->GoToFirstRow();
                resultset->GetString(columnIndex, val);
                asyncCallbackInfo->value = val;
            }
            if (resultset != nullptr) {
                resultset->Close();
            }
        },
        // async end called callback
        [](napi_env env, napi_status status, void* data) {
            HILOG_INFO("settingsnapi : promise async end called callback");
            AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
            HILOG_INFO("settingsnapi : promise end get callback value is %{public}s", asyncCallbackInfo->value.c_str());
            napi_value result = wrap_string_to_js(env, asyncCallbackInfo->value);
            napi_resolve_deferred(asyncCallbackInfo->env, asyncCallbackInfo->deferred, result);
            napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
            asyncCallbackInfo->dataAbilityHelper = nullptr;  
            delete asyncCallbackInfo;
        },
        (void*)asyncCallbackInfo,
        &asyncCallbackInfo->asyncWork);
        napi_queue_async_work(env, asyncCallbackInfo->asyncWork);
        return promise;
    }
}

/**
 * @brief setValue NAPI implementation.
 *
 * @param env the environment that the Node-API call is invoked under
 * @param info the callback info passed into the callback function
 * @return napi_value the return value from NAPI C++ to JS for the module.
 */
napi_value napi_set_value_sync(napi_env env, napi_callback_info info)
{
    HILOG_INFO("napi_set_value called...");

    // Check the number of the arguments
    size_t argc = ARGS_THREE;
    napi_value args[ARGS_THREE] = {nullptr};
    NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
    if (argc != ARGS_THREE) {
        HILOG_ERROR("%{public}s, wrong number of arguments.", __func__);
        return wrap_void_to_js(env);
    }

    // Check the value type of the arguments
    napi_valuetype valueType;
    NAPI_CALL(env, napi_typeof(env, args[PARAM0], &valueType));
    NAPI_ASSERT(env, valueType == napi_object, "Wrong argument[0] type. Object expected.");
    NAPI_CALL(env, napi_typeof(env, args[PARAM1], &valueType));
    NAPI_ASSERT(env, valueType == napi_string, "Wrong argument[1] type. String expected.");
    NAPI_CALL(env, napi_typeof(env, args[PARAM2], &valueType));
    NAPI_ASSERT(env, valueType == napi_string, "Wrong argument[2] type. String expected.");

    DataAbilityHelper *dataAbilityHelper = nullptr;
    NAPI_CALL(env, napi_unwrap(env, args[PARAM0], reinterpret_cast<void **>(&dataAbilityHelper)));

    std::string argsName = unwrap_string_from_js(env, args[PARAM1]);
    std::string argsDefaultValue = unwrap_string_from_js(env, args[PARAM2]);

    OHOS::NativeRdb::ValuesBucket val;
    val.PutString(SETTINGS_DATA_FIELD_KEYWORD, argsName);
    val.PutString(SETTINGS_DATA_FIELD_VALUE, argsDefaultValue);

    std::vector<std::string> columns;
    columns.push_back(SETTINGS_DATA_FIELD_VALUE);
    OHOS::NativeRdb::DataAbilityPredicates predicates;
    predicates.EqualTo(SETTINGS_DATA_FIELD_KEYWORD, argsName);

    std::shared_ptr<Uri> uri = std::make_shared<Uri>(SETTINGS_DATA_BASE_URI);
    HILOG_INFO("napi_set_value called... before dataAbilityHelper->Query");
    std::shared_ptr<OHOS::NativeRdb::AbsSharedResultSet> resultset =
        dataAbilityHelper->Query(*uri, columns, predicates);
    HILOG_INFO("napi_set_value called... after dataAbilityHelper->Query");

    int retInt = 0;
    int numRows = 0;

    if (resultset != nullptr) {
        HILOG_INFO("napi_set_value called... resultset is NOT empty");
        resultset->GetRowCount(numRows);
    }

    // insert
    if (resultset == nullptr || numRows == 0) {
        HILOG_INFO("napi_set_value called... before Insert");
        retInt = dataAbilityHelper->Insert(*uri, val);
        HILOG_INFO("napi_set_value called... after Insert");
    // update
    } else {
        HILOG_INFO("napi_set_value called... before Update");
        retInt = dataAbilityHelper->Update(*uri, val, predicates);
        HILOG_INFO("napi_set_value called... after Update");
    }
    // notify change
    if (retInt != 0) {
        HILOG_INFO("napi_set_value called... retInt is NOT zero");
        std::string uriWithNameStr =
            argsName.empty() ? SETTINGS_DATA_BASE_URI : (SETTINGS_DATA_BASE_URI + "/" + argsName);
        std::shared_ptr<Uri> uriWithName = std::make_shared<Uri>(uriWithNameStr);
        dataAbilityHelper->NotifyChange(*uriWithName);
        HILOG_INFO("napi_set_value called... after NotifyChange with uri: %{public}s", uriWithNameStr.c_str());
    }

    if (resultset != nullptr) {
        resultset->Close();
    }

    HILOG_INFO("napi_set_value called... END!");
    return wrap_bool_to_js(env, retInt != 0);
}

void SetValueExecuteCB(napi_env env, void *data)
{
    if (data == nullptr) {
        HILOG_INFO("settingsnapi : execute data is null");
        return;
    }
    HILOG_INFO("settingsnapi : execute start");
    AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;

    std::string argsName = asyncCallbackInfo->key;
    std::string argsDefaultValue = asyncCallbackInfo->value;

    OHOS::NativeRdb::ValuesBucket val;
    val.PutString(SETTINGS_DATA_FIELD_KEYWORD, argsName);
    val.PutString(SETTINGS_DATA_FIELD_VALUE, argsDefaultValue);

    std::vector<std::string> columns;
    columns.push_back(SETTINGS_DATA_FIELD_VALUE);
    OHOS::NativeRdb::DataAbilityPredicates predicates;
    predicates.EqualTo(SETTINGS_DATA_FIELD_KEYWORD, argsName);

    std::shared_ptr<Uri> uri = std::make_shared<Uri>(SETTINGS_DATA_BASE_URI);
    HILOG_INFO("settingsnapi : execute... before dataAbilityHelper->Query");
    std::shared_ptr<OHOS::NativeRdb::AbsSharedResultSet> resultset =
        asyncCallbackInfo->dataAbilityHelper->Query(*uri, columns, predicates);
    HILOG_INFO("settingsnapi : execute... after dataAbilityHelper->Query");

    int retInt = 0;
    int numRows = 0;
    if (resultset != nullptr) {
        HILOG_INFO("settingsnapi : execute... resultset is NOT empty");
        resultset->GetRowCount(numRows);
    }
    // insert
    if (resultset == nullptr || numRows == 0) {
        HILOG_INFO("settingsnapi : execute... before Insert");
        retInt = asyncCallbackInfo->dataAbilityHelper->Insert(*uri, val);
        HILOG_INFO("settingsnapi : execute... after Insert");
    // update
    } else {
        HILOG_INFO("settingsnapi : execute... before Update");
        retInt = asyncCallbackInfo->dataAbilityHelper->Update(*uri, val, predicates);
        HILOG_INFO("settingsnapi : execute... after Update");
    }
    // notify change
    if (retInt != 0) {
        HILOG_INFO("settingsnapi : execute... retInt is NOT zero");
        std::string uriWithNameStr =
            argsName.empty() ? SETTINGS_DATA_BASE_URI : (SETTINGS_DATA_BASE_URI + "/" + argsName);
        std::shared_ptr<Uri> uriWithName = std::make_shared<Uri>(uriWithNameStr);
        asyncCallbackInfo->dataAbilityHelper->NotifyChange(*uriWithName);
        HILOG_INFO(
            "settingsnapi : execute... after NotifyChange with uri: %{public}s",
            uriWithNameStr.c_str());
    }
    if (resultset != nullptr) {
        resultset->Close();
    }
    HILOG_INFO("settingsnapi : execute... END!");
    asyncCallbackInfo->status = retInt;
}

napi_value SetValueAsync(napi_env env, AsyncCallbackInfo* asyncCallbackInfo)
{
    HILOG_INFO("settingsnapi : set do callback");
    napi_value resource = nullptr;
    NAPI_CALL(env, napi_create_string_utf8(env, __func__, NAPI_AUTO_LENGTH, &resource));

    napi_create_async_work(
        env,
        nullptr,
        resource,
        SetValueExecuteCB,
        [](napi_env env, napi_status status, void* data) {
            if (data == nullptr) {
                HILOG_INFO("settingsnapi : callback set async end data is null");
                return;
            }
            HILOG_INFO("settingsnapi : callback set async end called callback");
            AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
            napi_value undefine;
            napi_get_undefined(env, &undefine);
            HILOG_INFO("settingsnapi : callback set aysnc end called");
            napi_value callback = nullptr;
            napi_value result = wrap_bool_to_js(env, asyncCallbackInfo->status != 0);
            HILOG_INFO("settingsnapi : callback set aysnc end called");
            napi_get_reference_value(env, asyncCallbackInfo->callbackRef, &callback);
            napi_call_function(env, nullptr, callback, 1, &result, &undefine);
            HILOG_INFO("settingsnapi : callback set aysnc end called");
            napi_delete_reference(env, asyncCallbackInfo->callbackRef);
            napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
            asyncCallbackInfo->dataAbilityHelper = nullptr;
            delete asyncCallbackInfo;
            HILOG_INFO("settingsnapi : callback set change callback complete");
        },
        (void*)asyncCallbackInfo,
        &asyncCallbackInfo->asyncWork
    );
    HILOG_INFO("settingsnapi : callback set start async work");
    NAPI_CALL(env, napi_queue_async_work(env, asyncCallbackInfo->asyncWork));
    HILOG_INFO("settingsnapi : callback set end async work");
    return wrap_void_to_js(env);
}

napi_value SetValuePromise(napi_env env, AsyncCallbackInfo* asyncCallbackInfo)
{
    HILOG_INFO("settingsnapi : set  do promise");
    napi_value promise;
    napi_deferred deferred;
    NAPI_CALL(env, napi_create_promise(env, &deferred, &promise));
    asyncCallbackInfo->deferred = deferred;

    napi_value resource = nullptr;
    NAPI_CALL(env, napi_create_string_utf8(env, __func__, NAPI_AUTO_LENGTH, &resource));

    napi_create_async_work(
        env,
        nullptr,
        resource,
        SetValueExecuteCB,
        [](napi_env env, napi_status status, void* data) {
            HILOG_INFO("settingsnapi : promise set async end called callback");
            AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
            HILOG_INFO("settingsnapi : promise set end get callback value is %{public}d", asyncCallbackInfo->status);
            napi_value result = wrap_bool_to_js(env, asyncCallbackInfo->status != 0);
            napi_resolve_deferred(asyncCallbackInfo->env, asyncCallbackInfo->deferred, result);
            napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
            asyncCallbackInfo->dataAbilityHelper = nullptr;
            delete asyncCallbackInfo;        
        },
        (void*)asyncCallbackInfo,
        &asyncCallbackInfo->asyncWork);
    napi_queue_async_work(env, asyncCallbackInfo->asyncWork);
    return promise;
}

/**
 * @brief setValue NAPI implementation.
 *
 * @param env the environment that the Node-API call is invoked under
 * @param info the callback info passed into the callback function
 * @return napi_value the return value from NAPI C++ to JS for the module.
 */
napi_value napi_set_value(napi_env env, napi_callback_info info)
{
    HILOG_INFO("settingsnapi : set  napi_set_value called...");

    // getValue api need 3 parameters when Promise mode and need 4 parameters when callback mode
    const size_t paramOfPromise = ARGS_THREE;
    const size_t paramOfCallback = ARGS_FOUR;

    size_t argc = ARGS_FOUR;
    napi_value args[ARGS_FOUR] = {nullptr};
    NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
    if (argc != paramOfPromise && argc != paramOfCallback) {
        HILOG_ERROR("settingsnapi : set  %{public}s, wrong number of arguments, expect 3 or 4 but get %{public}zd",
            __func__, argc);
        return wrap_void_to_js(env);
    }

    HILOG_INFO("settingsnapi : set  arg count is %{public}zd", argc);
    HILOG_INFO("settingsnapi : set  start create aysnc call back info");
    // Check the value type of the arguments
    AsyncCallbackInfo* asyncCallbackInfo = new AsyncCallbackInfo {
        .env = env,
        .asyncWork = nullptr,
        .deferred = nullptr,
        .callbackRef = nullptr,
        .dataAbilityHelper = nullptr,
        .key = "",
        .value = "",
        .uri = "",
        .status = false,
    };
    HILOG_INFO("settingsnapi : set  after create aysnc call back info");
    napi_valuetype valueType;
    NAPI_CALL(env, napi_typeof(env, args[PARAM0], &valueType));
    NAPI_ASSERT(env, valueType == napi_object, "Wrong argument[0], type. Object expected");
    NAPI_CALL(env, napi_typeof(env, args[PARAM1], &valueType));
    NAPI_ASSERT(env, valueType == napi_string, "Wrong argument[1], type. String expected");
    NAPI_CALL(env, napi_typeof(env, args[PARAM2], &valueType));
    NAPI_ASSERT(env, valueType == napi_string, "Wrong argument[2], type. String expected");

    NAPI_CALL(env, napi_unwrap(env, args[PARAM0], reinterpret_cast<void **>(&asyncCallbackInfo->dataAbilityHelper)));
    HILOG_INFO("settingsnapi : input paramter is (DataAbilityHelper)");

    asyncCallbackInfo->key = unwrap_string_from_js(env, args[PARAM1]);
    asyncCallbackInfo->value = unwrap_string_from_js(env, args[PARAM2]);
    HILOG_INFO("settingsnapi : set  input parameter is : (key %{public}s, value %{public}s)",
        asyncCallbackInfo->key.c_str(), asyncCallbackInfo->value.c_str());

    napi_value ret = nullptr;
    if (argc == paramOfCallback) {
        napi_create_reference(env, args[PARAM3], 1, &asyncCallbackInfo->callbackRef);
        ret = SetValueAsync(env, asyncCallbackInfo);
    } else {
        ret = SetValuePromise(env, asyncCallbackInfo);
    }
    HILOG_INFO("settingsnapi : set  value end");
    return ret;
}

/**
 * @brief enableAirplaneMode NAPI implementation.
 * @param env the environment that the Node-API call is invoked under
 * @param info the callback info passed into the callback function
 * @return napi_value the return value from NAPI C++ to JS for the module.
 */
napi_value napi_enable_airplane_mode(napi_env env, napi_callback_info info)
{
    const size_t paramOfPromise = ARGS_ONE;
    const size_t paramOfCallback = ARGS_TWO;

    size_t argc = ARGS_TWO;
    napi_value args[ARGS_TWO] = {nullptr};
    NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
    if (argc != paramOfCallback && argc != paramOfPromise) {
        HILOG_ERROR("settingsnapi : %{public}s, wrong number of arguments, expect 1 or 2 but get %{public}zd",
            __func__, argc);
        return wrap_void_to_js(env);
    }

    HILOG_INFO("settingsnapi : napi_enable_airplane_mode arg count is %{public}zd", argc);
    HILOG_INFO("settingsnapi : napi_enable_airplane_mode start create aysnc call back info");
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
    HILOG_INFO("settingsnapi : after create aysnc call back info");

    napi_valuetype valueType;
    NAPI_CALL(env, napi_typeof(env, args[PARAM0], &valueType));
    NAPI_ASSERT(env, valueType == napi_boolean, "Wrong argument[0], type. Boolean expected");

    napi_value resource = nullptr;  
    NAPI_CALL(env, napi_create_string_utf8(env, "enableAirplaneMode", NAPI_AUTO_LENGTH, &resource));

    if (argc == paramOfCallback) {
        HILOG_INFO("%{public}s, asyncCallback.", __func__);

        napi_create_reference(env, args[PARAM1], 1, &asyncCallbackInfo->callbackRef);
        napi_create_async_work(
            env,
            nullptr,
            resource,
            [](napi_env env, void* data) {},
            [](napi_env env, napi_status status, void* data) {
                if (data == nullptr) {
                    HILOG_INFO("settingsnapi : callback async end data is null");
                    return;
                }
                AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;

                napi_value callback = nullptr;
                napi_value undefined;
                napi_get_undefined(env, &undefined);

                napi_value result[PARAM2] = {0};

                // create error code
                napi_value error = nullptr;
                napi_create_object(env, &error);
                int unSupportCode = 801;
                napi_value errCode = nullptr;
                napi_create_int32(env, unSupportCode, &errCode);
                napi_set_named_property(env, error, "code", errCode);
                result[0] = error;
                napi_get_undefined(env, &result[1]);

                napi_get_reference_value(env, asyncCallbackInfo->callbackRef, &callback);
                napi_value callResult;
                napi_call_function(env, undefined, callback, PARAM2, result, &callResult);
                HILOG_INFO("settingsnapi : callback aysnc end called");

                napi_delete_reference(env, asyncCallbackInfo->callbackRef);
                napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
                delete asyncCallbackInfo;
                HILOG_INFO("settingsnapi : callback change callback complete");
            },
            (void*)asyncCallbackInfo,
            &asyncCallbackInfo->asyncWork
        );
        NAPI_CALL(env, napi_queue_async_work(env, asyncCallbackInfo->asyncWork));
        return wrap_void_to_js(env);
    } else {
        HILOG_INFO("%{public}s, promise.", __func__);
        napi_deferred deferred;
        napi_value promise;
        NAPI_CALL(env, napi_create_promise(env, &deferred, &promise));
        asyncCallbackInfo->deferred = deferred;

        napi_create_async_work(
            env,
            nullptr,
            resource,
            [](napi_env env, void *data) {},
            [](napi_env env, napi_status status, void *data) {
                HILOG_INFO("%{public}s, promise complete", __func__);
                AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;

                napi_value result;
                napi_value error = nullptr;
                napi_create_object(env, &error);
                int unSupportCode = 801;
                napi_value errCode = nullptr;
                napi_create_int32(env, unSupportCode, &errCode);
                napi_set_named_property(env, error, "code", errCode);
                result = error;

                napi_reject_deferred(env, asyncCallbackInfo->deferred, result);
                napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
                delete asyncCallbackInfo;
            },
            (void *)asyncCallbackInfo,
            &asyncCallbackInfo->asyncWork);
        napi_queue_async_work(env, asyncCallbackInfo->asyncWork);
        return promise;
    }
}

/**
 * @brief canShowFloating NAPI implementation.
 * @param env the environment that the Node-API call is invoked under
 * @param info the callback info passed into the callback function
 * @return napi_value the return value from NAPI C++ to JS for the module.
 */
napi_value napi_can_show_floating(napi_env env, napi_callback_info info)
{
    const size_t paramOfPromise = PARAM0;
    const size_t paramOfCallback = PARAM1;

    size_t argc = PARAM1;
    napi_value args[PARAM1] = {nullptr};
    NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
    if (argc != paramOfCallback && argc != paramOfPromise) {
        HILOG_ERROR("settingsnapi : %{public}s, wrong number of arguments, expect 0 or 1 but get %{public}zd",
            __func__, argc);
        return wrap_void_to_js(env);
    }

    HILOG_INFO("settingsnapi : napi_enable_airplane_mode arg count is %{public}zd", argc);
    HILOG_INFO("settingsnapi : napi_enable_airplane_mode start create aysnc call back info");
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
    HILOG_INFO("settingsnapi : after create aysnc call back info");

    napi_value resource = nullptr;  
    NAPI_CALL(env, napi_create_string_utf8(env, "enableAirplaneMode", NAPI_AUTO_LENGTH, &resource));

    if (argc == paramOfCallback) {
        HILOG_INFO("%{public}s, asyncCallback.", __func__);

        napi_create_reference(env, args[PARAM0], 1, &asyncCallbackInfo->callbackRef);
        napi_create_async_work(
            env,
            nullptr,
            resource,
            [](napi_env env, void* data) {},
            [](napi_env env, napi_status status, void* data) {
                if (data == nullptr) {
                    HILOG_INFO("settingsnapi : callback async end data is null");
                    return;
                }
                AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;

                napi_value callback = nullptr;
                napi_value undefined;
                napi_get_undefined(env, &undefined);

                napi_value result[PARAM2] = {0};

                // create error code
                napi_value error = nullptr;
                napi_create_object(env, &error);
                int unSupportCode = 801;
                napi_value errCode = nullptr;
                napi_create_int32(env, unSupportCode, &errCode);
                napi_set_named_property(env, error, "code", errCode);
                result[0] = error;
                result[1] = wrap_bool_to_js(env, false);

                napi_get_reference_value(env, asyncCallbackInfo->callbackRef, &callback);
                napi_value callResult;
                napi_call_function(env, undefined, callback, PARAM2, result, &callResult);
                HILOG_INFO("settingsnapi : callback aysnc end called");

                napi_delete_reference(env, asyncCallbackInfo->callbackRef);
                napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
                delete asyncCallbackInfo;
                HILOG_INFO("settingsnapi : callback change callback complete");
            },
            (void*)asyncCallbackInfo,
            &asyncCallbackInfo->asyncWork
        );
        NAPI_CALL(env, napi_queue_async_work(env, asyncCallbackInfo->asyncWork));
        return wrap_void_to_js(env);
    } else {
        HILOG_INFO("%{public}s, promise.", __func__);
        napi_deferred deferred;
        napi_value promise;
        NAPI_CALL(env, napi_create_promise(env, &deferred, &promise));
        asyncCallbackInfo->deferred = deferred;

        napi_create_async_work(
            env,
            nullptr,
            resource,
            [](napi_env env, void *data) {},
            [](napi_env env, napi_status status, void *data) {
                HILOG_INFO("%{public}s, promise complete", __func__);
                AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;

                napi_value result;
                napi_value error = nullptr;
                napi_create_object(env, &error);
                int unSupportCode = 801;
                napi_value errCode = nullptr;
                napi_create_int32(env, unSupportCode, &errCode);
                napi_set_named_property(env, error, "code", errCode);
                result = error;

                napi_reject_deferred(env, asyncCallbackInfo->deferred, result);
                napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
                delete asyncCallbackInfo;
            },
            (void *)asyncCallbackInfo,
            &asyncCallbackInfo->asyncWork);
        napi_queue_async_work(env, asyncCallbackInfo->asyncWork);
        return promise;
    }
}
}  // namespace Settings
}  // namespace OHOS
