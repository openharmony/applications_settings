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

#include "abs_shared_result_set.h"
#include "data_ability_helper.h"
#include "data_ability_predicates.h"
#include "napi_settings_log.h"
#include "values_bucket.h"

#include "napi_base_context.h"
#include "datashare_helper.h"
#include "datashare_predicates.h"
#include "os_account_manager.h"


using namespace OHOS::AppExecFwk;
using namespace OHOS::DataShare;
using namespace OHOS::AccountSA;

namespace OHOS {
namespace Settings {
const std::string SETTINGS_DATA_BASE_URI = "dataability:///com.ohos.settingsdata.DataAbility";
const std::string SETTINGS_DATA_FIELD_KEYWORD = "KEYWORD";
const std::string SETTINGS_DATA_FIELD_VALUE = "VALUE";

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
        SETTING_LOG_INFO("settingsnapi : unwarp");
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
    SETTING_LOG_INFO("settingsnapi : unwarp string is : %{public}s", value.c_str());
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
    CallType callType;
    std::string tableName;
    int status;
    std::shared_ptr<DataShareHelper> dataShareHelper = nullptr;
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
    SETTING_LOG_INFO("napi_get_uri called...");

    napi_value retUri = nullptr;

    // Check the number of the arguments
    size_t argc = ARGS_TWO;
    napi_value args[ARGS_TWO] = {nullptr};
    NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
    if (argc != ARGS_ONE && argc != ARGS_TWO) {
        SETTING_LOG_ERROR("%{public}s, wrong number of arguments.", __func__);
        return wrap_void_to_js(env);
    }

    // Check the value type of the arguments
    napi_valuetype valueType;
    NAPI_CALL(env, napi_typeof(env, args[PARAM0], &valueType));
    NAPI_ASSERT(env, valueType == napi_string, "Wrong argument type. String expected.");

    if (argc == ARGS_TWO) {
        SETTING_LOG_INFO("settingsnapi : ARGS_TWO");
        std::string keyStr = unwrap_string_from_js(env, args[PARAM0]);
        // get userId string
        int tmpId = -1;
        OHOS::AccountSA::OsAccountManager::GetOsAccountLocalIdFromProcess(tmpId);
        std::string tmpIdStr = std::to_string(tmpId);
        std::string tableName = unwrap_string_from_js(env, args[PARAM1]);
        std::string retStr = GetStageUriStr(tableName, tmpIdStr, keyStr);
        retUri = wrap_string_to_js(env, retStr);
        return retUri;
    } else {
        SETTING_LOG_INFO("settingsnapi : ARGS_OTHER (should one)");
        NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
        if (argc != ARGS_ONE) {
            SETTING_LOG_ERROR("%{public}s, wrong number of arguments.", __func__);
            return wrap_void_to_js(env);
        }

        std::string uriArgStr = unwrap_string_from_js(env, args[PARAM0]);
        uriArgStr = "datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=" + uriArgStr;
        retUri = wrap_string_to_js(env, uriArgStr);
        return retUri;
    }
}

napi_value napi_get_uri(napi_env env, napi_callback_info info)
{
    SETTING_LOG_INFO("settingsnapi : uri napi_set_value called...");
    // Check the number of the arguments
    size_t argc = ARGS_THREE;
    napi_value args[ARGS_THREE] = {nullptr};
    NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
    if (argc != ARGS_ONE && argc != ARGS_TWO && argc != ARGS_THREE) {
        SETTING_LOG_ERROR(
            "settingsnapi : uri %{public}s, wrong number of arguments, expect 1 or 2 or 3 but get %{public}zd",
            __func__,
            argc);
        return wrap_void_to_js(env);
    }

    // Check the value type of the arguments
    napi_valuetype valueType;
    NAPI_CALL(env, napi_typeof(env, args[PARAM0], &valueType));
    NAPI_ASSERT(env, valueType == napi_string, "settingsnapi : uri Wrong argument type. String expected.");

    // check call type for stage model
    CallType callType = INVALID_CALL;
    if (argc == ARGS_ONE) {
        callType = STAGE_PROMISE;
    } else if (argc == ARGS_TWO) {
        napi_valuetype valueType;
        NAPI_CALL(env, napi_typeof(env, args[PARAM1], &valueType));
        if (valueType == napi_string) {
            callType = STAGE_PROMISE_SPECIFIC;
        } else {
            callType = STAGE_CALLBACK;
        }
    } else if (argc == ARGS_THREE) {
        callType = STAGE_CALLBACK_SPECIFIC;
    }

    SETTING_LOG_INFO("settingsnapi : uri arg count is %{public}zd", argc);
    SETTING_LOG_INFO("settingsnapi : uri start create aysnc call back info");
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

    std::string keyStr = unwrap_string_from_js(env, args[PARAM0]);
    // get userId string
    int tmpId = -1;
    OHOS::AccountSA::OsAccountManager::GetOsAccountLocalIdFromProcess(tmpId);
    std::string tmpIdStr = std::to_string(tmpId);
    std::string tableName = "";
    if (callType == STAGE_CALLBACK_SPECIFIC) {
        tableName = unwrap_string_from_js(env, args[PARAM2]);
    } else if (callType == STAGE_PROMISE_SPECIFIC) {
        tableName = unwrap_string_from_js(env, args[PARAM1]);
    } else {
        tableName = "global";
    }
    std::string retStr = GetStageUriStr(tableName, tmpIdStr, keyStr);
    asyncCallbackInfo->uri = retStr;
    SETTING_LOG_INFO("settingsnapi : uri after uri is %{public}s", asyncCallbackInfo->uri.c_str());
    SETTING_LOG_INFO("settingsnapi : uri after create aysnc call back info");

    napi_value resource = nullptr;
    NAPI_CALL(env, napi_create_string_utf8(env, "getUri", NAPI_AUTO_LENGTH, &resource));

    if (callType == STAGE_CALLBACK || callType == STAGE_CALLBACK_SPECIFIC) {
        SETTING_LOG_INFO("settingsnapi : uri do callback");
        napi_create_reference(env, args[PARAM1], 1, &asyncCallbackInfo->callbackRef);

        napi_create_async_work(
            env,
            nullptr,
            resource,
            [](napi_env env, void* data) {
                SETTING_LOG_INFO("settingsnapi : uri callback async execute callback");
            },
            [](napi_env env, napi_status status, void* data) {
                if (data == nullptr) {
                    SETTING_LOG_INFO("settingsnapi : uri callback async end data is null");
                    return;
                }
                SETTING_LOG_INFO("settingsnapi : uri callback async end called callback");
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
                SETTING_LOG_INFO("settingsnapi : uri callback change callback complete");
            },
            (void*)asyncCallbackInfo,
            &asyncCallbackInfo->asyncWork
        );

        SETTING_LOG_INFO("settingsnapi : uri callback start async work");
        NAPI_CALL(env, napi_queue_async_work(env, asyncCallbackInfo->asyncWork));
        SETTING_LOG_INFO("settingsnapi : uri callback end async work");
        return wrap_void_to_js(env);
    } else {
        SETTING_LOG_INFO("settingsnapi : uri do promise");
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
                SETTING_LOG_INFO("settingsnapi : uri promise async execute callback");
            },
            // async end called callback
            [](napi_env env, napi_status status, void* data) {
                SETTING_LOG_INFO("settingsnapi : uri promise async end called callback");
                AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
                SETTING_LOG_INFO("settingsnapi : uri promise end get callback value is %{public}s",
                    asyncCallbackInfo->uri.c_str());
                napi_value result = wrap_string_to_js(env, asyncCallbackInfo->uri);
                napi_resolve_deferred(asyncCallbackInfo->env, asyncCallbackInfo->deferred, result);
                napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
                delete asyncCallbackInfo;
            },
            (void*)asyncCallbackInfo,
            &asyncCallbackInfo->asyncWork);
        napi_queue_async_work(env, asyncCallbackInfo->asyncWork);
        SETTING_LOG_INFO("settingsnapi : uri promise end sync work");
        return promise;
    }
}

std::shared_ptr<DataShareHelper> getDataShareHelper(
    napi_env env, const napi_value context, const bool stageMode, std::string tableName = "global")
{
    std::shared_ptr<OHOS::DataShare::DataShareHelper> dataShareHelper = nullptr;
    std::shared_ptr<OHOS::DataShare::DataShareResultSet> resultset = nullptr;
    int tmpId = -1;
    OHOS::AccountSA::OsAccountManager::GetOsAccountLocalIdFromProcess(tmpId);
    std::string strUri = "datashare:///com.ohos.settingsdata.DataAbility";
    std::string strProxyUri = GetProxyUriStr(tableName, std::to_string(tmpId));
    OHOS::Uri proxyUri(strProxyUri);
    SETTING_LOG_INFO("settingsnapi : <Ver-10-24> strProxyUri: %{public}s", strProxyUri.c_str());
    auto contextS = OHOS::AbilityRuntime::GetStageModeContext(env, context);

    dataShareHelper = OHOS::DataShare::DataShareHelper::Creator(contextS->GetToken(), strProxyUri);
    SETTING_LOG_INFO("settingsnapi : getDataShareHelper Creator<strProxyUri> called");

    DataSharePredicates predicates;
    predicates.Limit(1, 0);
    std::vector<std::string> columns;
    if (dataShareHelper == nullptr) {
        SETTING_LOG_INFO(
            "settingsnapi : getDataShareHelper dataShareHelper = nullptr, strUri %{public}s", strUri.c_str());
        dataShareHelper = OHOS::DataShare::DataShareHelper::Creator(contextS->GetToken(), strUri);
        return dataShareHelper;
    }

    resultset = dataShareHelper->Query(proxyUri, predicates, columns);
    int numRows = 0;
    if (resultset != nullptr) {
        resultset->GetRowCount(numRows);
    }
    SETTING_LOG_INFO("settingsnapi : numRows %{public}d", numRows);
    if (resultset == nullptr || numRows <= 0) {
        SETTING_LOG_INFO("settingsnapi : getDataShareHelper resultset == nullptr, strUri %{public}s", strUri.c_str());
        dataShareHelper = OHOS::DataShare::DataShareHelper::Creator(contextS->GetToken(), strUri);
        return dataShareHelper;
    }
    resultset->Close();
    return dataShareHelper;
}

void GetValueExecuteExt(napi_env env, void *data)
{
    if (data == nullptr) {
        SETTING_LOG_INFO("settingsnapi : execute data is null");
        return;
    }

    SETTING_LOG_INFO("settingsnapi : GetValueExecuteExt start");
    AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;

    std::vector<std::string> columns;
    columns.push_back(SETTINGS_DATA_FIELD_VALUE);

    OHOS::DataShare::DataSharePredicates predicates;
    predicates.EqualTo(SETTINGS_DATA_FIELD_KEYWORD, asyncCallbackInfo->key);

    int tmpId = -1;
    OHOS::AccountSA::OsAccountManager::GetOsAccountLocalIdFromProcess(tmpId);
    std::string strUri = GetStageUriStr(asyncCallbackInfo->tableName, std::to_string(tmpId), asyncCallbackInfo->key);
    SETTING_LOG_INFO(
        "settingsnapi : Get uri : %{public}s, key: %{public}s", strUri.c_str(), (asyncCallbackInfo->key).c_str());
    OHOS::Uri uri(strUri);

    std::shared_ptr<OHOS::DataShare::DataShareResultSet> resultset = nullptr;
    if (asyncCallbackInfo->dataShareHelper != nullptr) {
        SETTING_LOG_INFO("settingsnapi : asyncCallbackInfo->dataShareHelper != nullptr");
        resultset = asyncCallbackInfo->dataShareHelper->Query(uri, predicates, columns);
    }
    int numRows = 0;
    if (resultset != nullptr) {
        SETTING_LOG_INFO("settingsnapi : GetValueExecuteExt called... resultset is NOT empty");
        resultset->GetRowCount(numRows);
    }

    SETTING_LOG_INFO("settingsnapi : numRows %{public}d", numRows);
    if (resultset == nullptr || numRows <= 0) {
        SETTING_LOG_INFO("settingsnapi : settingsnapi : GetValueExecuteExt called... return error");
        asyncCallbackInfo->status = -1;
    } else {
        std::string val;
        int32_t columnIndex = 0;
        resultset->GoToFirstRow();
        resultset->GetString(columnIndex, val);

        SETTING_LOG_INFO("napi_get_value_ext called... %{public}s", val.c_str());
        asyncCallbackInfo->value = val;
        asyncCallbackInfo->status = napi_ok;
    }
    
    if (resultset != nullptr) {
        resultset->Close();
    }
}

void DeleteCallbackInfo(napi_env env, AsyncCallbackInfo *asyncCallbackInfo)
{
    if (env != nullptr) {
        napi_delete_reference(env, asyncCallbackInfo->callbackRef);
        napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
    }
    asyncCallbackInfo->dataShareHelper = nullptr;
    delete asyncCallbackInfo;
}

void CompleteCall(napi_env env, napi_status status, void *data, const napi_value retVaule)
{
    AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
    napi_value result[PARAM2] = {0};
    if (status == napi_ok && asyncCallbackInfo->status == napi_ok) {
        napi_get_undefined(env, &result[PARAM0]);
        result[PARAM1] = retVaule;
    } else {
        napi_value message = nullptr;
        napi_create_string_utf8(env, "async call failed", NAPI_AUTO_LENGTH, &message);
        napi_create_error(env, nullptr, message, &result[PARAM0]);
        napi_get_undefined(env, &result[PARAM1]);
    }
    SETTING_LOG_INFO("settingsnapi : callback aysnc end called");
    napi_value callback = nullptr;
    napi_get_reference_value(env, asyncCallbackInfo->callbackRef, &callback);
    napi_value returnValue;
    napi_call_function(env, nullptr, callback, PARAM2, result, &returnValue);
    SETTING_LOG_INFO("settingsnapi : callback aysnc end called");
    DeleteCallbackInfo(env, asyncCallbackInfo);
    SETTING_LOG_INFO("settingsnapi : callback change callback complete");
}

void CompletePromise(napi_env env, napi_status status, void *data, const napi_value retVaule)
{
    SETTING_LOG_INFO("settingsnapi : promise async end called callback");
    AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
    napi_value result = nullptr;
    if (status == napi_ok && asyncCallbackInfo->status == napi_ok) {
        napi_resolve_deferred(env, asyncCallbackInfo->deferred, retVaule);
    } else {
        napi_get_undefined(env, &result);
        napi_reject_deferred(env, asyncCallbackInfo->deferred, result);
    }
    DeleteCallbackInfo(env, asyncCallbackInfo);
}

void SetValueExecuteExt(napi_env env, void *data, const std::string setValue)
{
    if (data == nullptr) {
        SETTING_LOG_INFO("settingsnapi : SetValueExecuteExt data is null");
        return;
    }
    SETTING_LOG_INFO("settingsnapi : execute start");
    AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;

    OHOS::DataShare::DataShareValuesBucket val;
    val.Put(SETTINGS_DATA_FIELD_KEYWORD, asyncCallbackInfo->key);
    val.Put(SETTINGS_DATA_FIELD_VALUE, setValue);

    int tmpId = -1;
    OHOS::AccountSA::OsAccountManager::GetOsAccountLocalIdFromProcess(tmpId);
    std::string strUri = GetStageUriStr(asyncCallbackInfo->tableName, std::to_string(tmpId), asyncCallbackInfo->key);
    SETTING_LOG_INFO(
        "settingsnapi : Set uri : %{public}s, key: %{public}s", strUri.c_str(), (asyncCallbackInfo->key).c_str());
    OHOS::Uri uri(strUri);

    OHOS::DataShare::DataSharePredicates predicates;
    predicates.EqualTo(SETTINGS_DATA_FIELD_KEYWORD, asyncCallbackInfo->key);

    int retInt = 0;
    if (asyncCallbackInfo->status == -1) {
        SETTING_LOG_INFO("settingsnapi : asyncCallbackInfo->status == -1");
        if (asyncCallbackInfo->dataShareHelper != nullptr) {
            SETTING_LOG_INFO("settingsnapi : before insert");
            retInt = asyncCallbackInfo->dataShareHelper->Insert(uri, val);
            SETTING_LOG_INFO("settingsnapi : after insert status: %{public}d", retInt);
        }
        SETTING_LOG_INFO("napi_set_value_ext called... after Insert");
    } else {
        SETTING_LOG_INFO("settingsnapi : asyncCallbackInfo->status != -1");
        if (asyncCallbackInfo->dataShareHelper != nullptr) {
            SETTING_LOG_INFO("settingsnapi : before update");
            retInt = asyncCallbackInfo->dataShareHelper->Update(uri, predicates, val);
            SETTING_LOG_INFO("settingsnapi : after update status: %{public}d", retInt);
        }
        SETTING_LOG_INFO("napi_set_value_ext called... after Update");
    }
    asyncCallbackInfo->status = retInt;
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
    SETTING_LOG_INFO("napi_get_value called...");

    // Check the number of the arguments
    size_t argc = ARGS_FOUR;
    napi_value args[ARGS_FOUR] = {nullptr};
    NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
    if (argc != ARGS_THREE && argc != ARGS_FOUR) {
        SETTING_LOG_ERROR("%{public}s, wrong number of arguments.", __func__);
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

    bool stageMode = false;
    napi_status status = OHOS::AbilityRuntime::IsStageContext(env, args[PARAM0], stageMode);
    if (status == napi_ok) {
        return napi_get_value_sync_ext(stageMode, argc, env, args);
    }

    std::shared_ptr<Uri> uri = std::make_shared<Uri>(SETTINGS_DATA_BASE_URI);
    DataAbilityHelper *dataAbilityHelper = nullptr;
    NAPI_CALL(env, napi_unwrap(env, args[PARAM0], reinterpret_cast<void **>(&dataAbilityHelper)));

    std::vector<std::string> columns;
    columns.push_back(SETTINGS_DATA_FIELD_VALUE);
    OHOS::NativeRdb::DataAbilityPredicates predicates;
    predicates.EqualTo(SETTINGS_DATA_FIELD_KEYWORD, unwrap_string_from_js(env, args[PARAM1]));

    SETTING_LOG_INFO("napi_get_value called... before dataAbilityHelper->Query");
    std::shared_ptr<OHOS::NativeRdb::AbsSharedResultSet> resultset = nullptr;
    if (dataAbilityHelper != nullptr) {
        resultset = dataAbilityHelper->Query(*uri, columns, predicates);
    };
    SETTING_LOG_INFO("napi_get_value called... after dataAbilityHelper->Query");

    napi_value retVal = nullptr;
    int numRows = 0;

    if (resultset != nullptr) {
        SETTING_LOG_INFO("napi_get_value called... resultset is NOT empty");
        resultset->GetRowCount(numRows);
    }

    if (resultset == nullptr || numRows == 0) {
        SETTING_LOG_INFO("napi_get_value called... return default value");
        retVal = args[PARAM2];
    } else {
        SETTING_LOG_INFO("napi_get_value called... return value from resultset");
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
    SETTING_LOG_INFO("napi_get_value called... END!");
    return retVal;
}

void get_val_CB_exe_CB(napi_env env, AsyncCallbackInfo *asyncCallbackInfo)
{
    std::vector<std::string> columns;
    columns.push_back(SETTINGS_DATA_FIELD_VALUE);
    OHOS::NativeRdb::DataAbilityPredicates predicates;
    predicates.EqualTo(SETTINGS_DATA_FIELD_KEYWORD, asyncCallbackInfo->key);

    std::shared_ptr<Uri> uri = std::make_shared<Uri>(SETTINGS_DATA_BASE_URI);
    SETTING_LOG_INFO("settingsnapi : callback napi_get_value called... before dataAbilityHelper->Query");
    std::shared_ptr<OHOS::NativeRdb::AbsSharedResultSet> resultset = nullptr;
    if (asyncCallbackInfo->dataAbilityHelper != nullptr) {
        resultset = asyncCallbackInfo->dataAbilityHelper->Query(*uri, columns, predicates);
    };
    SETTING_LOG_INFO("settingsnapi : callback napi_get_value called... after dataAbilityHelper->Query");

    int numRows = 0;
    if (resultset != nullptr) {
        SETTING_LOG_INFO("settingsnapi : callback napi_get_value called... resultset is NOT empty");
        resultset->GetRowCount(numRows);
    }
    if (resultset == nullptr || numRows == 0) {
        SETTING_LOG_INFO("settingsnapi : callback napi_get_value called... return default value");
    } else {
        SETTING_LOG_INFO("settingsnapi : callback napi_get_value called... return value from resultset");
        std::string val;
        int32_t columnIndex = 0;
        resultset->GoToFirstRow();
        resultset->GetString(columnIndex, val);
        SETTING_LOG_INFO("settingsnapi : callback retVal is %{public}s", val.c_str());
        asyncCallbackInfo->value = val;
    }
    if (resultset != nullptr) {
        resultset->Close();
    }
}

napi_value napi_get_value(napi_env env, napi_callback_info info)
{
    // getValue api need 3 parameters when Promise mode and need 4 parameters when callback mode
    const size_t paramOfCallback = ARGS_THREE;

    size_t argc = ARGS_FOUR;
    napi_value args[ARGS_FOUR] = {nullptr};
    NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
    if (argc != ARGS_TWO && argc != ARGS_THREE && argc != ARGS_FOUR) {
        SETTING_LOG_ERROR(
            "settingsnapi : %{public}s, wrong number of arguments, expect 2 or 3 or 4 but get %{public}zd",
            __func__,
            argc);
        return wrap_void_to_js(env);
    }

    SETTING_LOG_INFO("settingsnapi : napi_get_value arg count is %{public}zd", argc);
    SETTING_LOG_INFO("settingsnapi : napi_get_value start create aysnc call back info");
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
    SETTING_LOG_INFO("settingsnapi : after create aysnc call back info");
    // Check the value type of the arguments
    napi_valuetype valueType;
    NAPI_CALL(env, napi_typeof(env, args[PARAM0], &valueType));
    NAPI_ASSERT(env, valueType == napi_object, "Wrong argument[0] type. Object expected.");
    NAPI_CALL(env, napi_typeof(env, args[PARAM1], &valueType));
    NAPI_ASSERT(env, valueType == napi_string, "Wrong argument[1], type. String expected");

    bool stageMode = false;
    napi_status status = OHOS::AbilityRuntime::IsStageContext(env, args[PARAM0], stageMode);
    if (status == napi_ok) {
        SETTING_LOG_INFO("argv[0] is a context, Stage Model: %{public}d", stageMode);
        return napi_get_value_ext(env, info, stageMode);
    }
    
    NAPI_CALL(env, napi_unwrap(env, args[PARAM0], reinterpret_cast<void **>(&asyncCallbackInfo->dataAbilityHelper)));
    SETTING_LOG_INFO("settingsnapi : input paramter is (DataAbilityHelper)");

    asyncCallbackInfo->key = unwrap_string_from_js(env, args[PARAM1]);
    SETTING_LOG_INFO("settingsnapi : input parameter is : (key %{public}s", asyncCallbackInfo->key.c_str());

    napi_value resource = nullptr;
    NAPI_CALL(env, napi_create_string_utf8(env, "getValue", NAPI_AUTO_LENGTH, &resource));

    if (argc == paramOfCallback) {
        SETTING_LOG_INFO("settingsnapi : do callback");

        napi_create_reference(env, args[PARAM2], 1, &asyncCallbackInfo->callbackRef);

        napi_create_async_work(
            env,
            nullptr,
            resource,
            // aysnc executed task
            [](napi_env env, void *data) {
                if (data == nullptr) {
                    SETTING_LOG_INFO("settingsnapi : callback async execute data is null");
                    return;
                }
                SETTING_LOG_INFO("settingsnapi : callback async execute callback");
                AsyncCallbackInfo *asyncCallbackInfo = (AsyncCallbackInfo *)data;
                get_val_CB_exe_CB(env, asyncCallbackInfo);
            },
            // async end called callback
            [](napi_env env, napi_status status, void *data) {
                if (data == nullptr) {
                    SETTING_LOG_INFO("settingsnapi : callback async end data is null");
                    return;
                }
                SETTING_LOG_INFO("settingsnapi : callback async end called callback");
                AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
                napi_value undefine;
                napi_get_undefined(env, &undefine);
                SETTING_LOG_INFO("settingsnapi : callback aysnc end called");
                napi_value callback = nullptr;
                napi_value result = wrap_string_to_js(env, asyncCallbackInfo->value);
                SETTING_LOG_INFO("settingsnapi : callback aysnc end called");
                napi_get_reference_value(env, asyncCallbackInfo->callbackRef, &callback);
                napi_call_function(env, nullptr, callback, 1, &result, &undefine);
                SETTING_LOG_INFO("settingsnapi : callback aysnc end called");
                napi_delete_reference(env, asyncCallbackInfo->callbackRef);
                napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
                asyncCallbackInfo->dataAbilityHelper = nullptr;
                delete asyncCallbackInfo;
                SETTING_LOG_INFO("settingsnapi : callback change callback complete");
            },
            (void *)asyncCallbackInfo,
            &asyncCallbackInfo->asyncWork);

        SETTING_LOG_INFO("settingsnapi :  callback start async work");
        NAPI_CALL(env, napi_queue_async_work(env, asyncCallbackInfo->asyncWork));
        SETTING_LOG_INFO("settingsnapi : callback end async work");
        return wrap_void_to_js(env);
    } else {
        SETTING_LOG_INFO("settingsnapi : do promise");
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
            SETTING_LOG_INFO("settingsnapi : promise async execute callback");
            AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
            SETTING_LOG_INFO("settingsnapi : promise get callback key is %{public}s", asyncCallbackInfo->key.c_str());
            SETTING_LOG_INFO("settingsnapi : promise get callback value is %{public}s",
                asyncCallbackInfo->value.c_str());

            std::vector<std::string> columns;
            columns.push_back(SETTINGS_DATA_FIELD_VALUE);
            OHOS::NativeRdb::DataAbilityPredicates predicates;
            predicates.EqualTo(SETTINGS_DATA_FIELD_KEYWORD, asyncCallbackInfo->key);

            std::shared_ptr<Uri> uri = std::make_shared<Uri>(SETTINGS_DATA_BASE_URI);
            SETTING_LOG_INFO("settingsnapi : promise napi_get_value called... before dataAbilityHelper->Query");
            std::shared_ptr<OHOS::NativeRdb::AbsSharedResultSet> resultset = nullptr;
            if (asyncCallbackInfo->dataAbilityHelper != nullptr) {
                resultset = asyncCallbackInfo->dataAbilityHelper->Query(*uri, columns, predicates);
            }
            SETTING_LOG_INFO("settingsnapi : promise napi_get_value called... after dataAbilityHelper->Query");

            int numRows = 0;
            if (resultset != nullptr) {
                SETTING_LOG_INFO("settingsnapi : promise napi_get_value called... resultset is NOT empty");
                resultset->GetRowCount(numRows);
            }
            if (resultset == nullptr || numRows == 0) {
                SETTING_LOG_INFO("settingsnapi : promise napi_get_value called... return default value");
            } else {
                SETTING_LOG_INFO("settingsnapi : promise napi_get_value called... return value from resultset");
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
            SETTING_LOG_INFO("settingsnapi : promise async end called callback");
            AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
            SETTING_LOG_INFO("settingsnapi : promise end get callback value is %{public}s",
                asyncCallbackInfo->value.c_str());
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

// api9
napi_value napi_get_value_ext(napi_env env, napi_callback_info info, const bool stageMode)
{
    SETTING_LOG_INFO("settingsnapi : napi_get_value_ext start");
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

    SETTING_LOG_INFO("napi_get_value_ext called");
    size_t argc = ARGS_FOUR;
    napi_value args[ARGS_FOUR] = {nullptr};
    NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));

    std::shared_ptr<OHOS::DataShare::DataShareHelper> dataShareHelper = nullptr;
    asyncCallbackInfo->dataShareHelper = getDataShareHelper(env, args[PARAM0], stageMode);

    asyncCallbackInfo->key = unwrap_string_from_js(env, args[PARAM1]);

    napi_value resource = nullptr;
    NAPI_CALL(env, napi_create_string_utf8(env, "getValue", NAPI_AUTO_LENGTH, &resource));

    // set call type and table name, and check whether the parameter is valid
    napi_valuetype valueType;
    if (argc == ARGS_TWO) {
        asyncCallbackInfo->callType = STAGE_PROMISE;
        asyncCallbackInfo->tableName = "global";
    } else if (argc == ARGS_THREE) {
        NAPI_CALL(env, napi_typeof(env, args[PARAM2], &valueType));
        if (valueType == napi_string) {
            asyncCallbackInfo->tableName = unwrap_string_from_js(env, args[PARAM2]);
            if (IsTableNameInvalid(asyncCallbackInfo->tableName)) {
                SETTING_LOG_ERROR("settingsnapi : INVALID tableName [ARGS_THREE]");
                return wrap_void_to_js(env);
            } else {
                asyncCallbackInfo->callType = STAGE_PROMISE_SPECIFIC;
            }
        } else {
            asyncCallbackInfo->callType = STAGE_CALLBACK;
            asyncCallbackInfo->tableName = "global";
        }
    } else if (argc == ARGS_FOUR) {
        asyncCallbackInfo->callType = STAGE_CALLBACK_SPECIFIC;
        asyncCallbackInfo->tableName = unwrap_string_from_js(env, args[PARAM3]);
    } else {
        asyncCallbackInfo->callType = INVALID_CALL;
    }

    // check whether invalid call
    if (asyncCallbackInfo->callType == INVALID_CALL) {
        SETTING_LOG_ERROR("settingsnapi : INVALID CALL");
        return wrap_void_to_js(env);
    }

    if (asyncCallbackInfo->callType == STAGE_CALLBACK || asyncCallbackInfo->callType == STAGE_CALLBACK_SPECIFIC) {
        napi_create_reference(env, args[PARAM2], 1, &asyncCallbackInfo->callbackRef);
        napi_create_async_work(
            env,
            nullptr,
            resource,
            GetValueExecuteExt,
            [](napi_env env, napi_status status, void* data) {
                AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
                napi_value result = wrap_string_to_js(env, asyncCallbackInfo->value);
                CompleteCall(env, status, data, result);
            },
            (void*)asyncCallbackInfo,
            &asyncCallbackInfo->asyncWork
        );
        NAPI_CALL(env, napi_queue_async_work(env, asyncCallbackInfo->asyncWork));
        SETTING_LOG_INFO("settingsnapi : callback end async work");
        return wrap_void_to_js(env);
    } else if (asyncCallbackInfo->callType != INVALID_CALL) {
        napi_value promise;
        napi_deferred deferred;
        NAPI_CALL(env, napi_create_promise(env, &deferred, &promise));
        asyncCallbackInfo->deferred = deferred;
        napi_create_async_work(
            env,
            nullptr,
            resource,
            GetValueExecuteExt,
            [](napi_env env, napi_status status, void* data) {
                AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
                napi_value result = nullptr;
                result = wrap_string_to_js(env, asyncCallbackInfo->value);
                CompletePromise(env, status, data, result);
            },
            (void*)asyncCallbackInfo,
            &asyncCallbackInfo->asyncWork
        );
        NAPI_CALL(env, napi_queue_async_work(env, asyncCallbackInfo->asyncWork));
        return promise;
    } else {
        SETTING_LOG_ERROR("settingsnapi : INVALID CALL");
        return wrap_void_to_js(env);
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
    SETTING_LOG_INFO("napi_set_value called...");

    // Check the number of the arguments
    size_t argc = ARGS_FOUR;
    napi_value args[ARGS_FOUR] = {nullptr};
    NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
    if (argc != ARGS_THREE && argc != ARGS_FOUR) {
        SETTING_LOG_ERROR("%{public}s, wrong number of arguments.", __func__);
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

    bool stageMode = false;
    napi_status status = OHOS::AbilityRuntime::IsStageContext(env, args[PARAM0], stageMode);
    if (status == napi_ok) {
        return napi_set_value_sync_ext(stageMode, argc, env, args);
    }

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
    SETTING_LOG_INFO("napi_set_value called... before dataAbilityHelper->Query");
    std::shared_ptr<OHOS::NativeRdb::AbsSharedResultSet> resultset = nullptr;
    if (dataAbilityHelper != nullptr) {
        resultset = dataAbilityHelper->Query(*uri, columns, predicates);
    }
    SETTING_LOG_INFO("napi_set_value called... after dataAbilityHelper->Query");

    int retInt = 0;
    int numRows = 0;

    if (resultset != nullptr) {
        SETTING_LOG_INFO("napi_set_value called... resultset is NOT empty");
        resultset->GetRowCount(numRows);
    }

    // insert
    if (resultset == nullptr || numRows == 0) {
        SETTING_LOG_INFO("napi_set_value called... before Insert");
        retInt = dataAbilityHelper->Insert(*uri, val);
        SETTING_LOG_INFO("napi_set_value called... after Insert");
    // update
    } else {
        SETTING_LOG_INFO("napi_set_value called... before Update");
        retInt = dataAbilityHelper->Update(*uri, val, predicates);
        SETTING_LOG_INFO("napi_set_value called... after Update");
    }
    // notify change
    if (retInt != 0) {
        SETTING_LOG_INFO("napi_set_value called... retInt is NOT zero");
        std::string uriWithNameStr =
            argsName.empty() ? SETTINGS_DATA_BASE_URI : (SETTINGS_DATA_BASE_URI + "/" + argsName);
        std::shared_ptr<Uri> uriWithName = std::make_shared<Uri>(uriWithNameStr);
        dataAbilityHelper->NotifyChange(*uriWithName);
        SETTING_LOG_INFO("napi_set_value called... after NotifyChange with uri: %{public}s", uriWithNameStr.c_str());
    }

    if (resultset != nullptr) {
        resultset->Close();
    }

    SETTING_LOG_INFO("napi_set_value called... END!");
    return wrap_bool_to_js(env, retInt != 0);
}

void SetValueExecuteCB(napi_env env, void *data)
{
    if (data == nullptr) {
        SETTING_LOG_INFO("settingsnapi : execute data is null");
        return;
    }
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
    SETTING_LOG_INFO("settingsnapi : execute... before dataAbilityHelper->Query");
    std::shared_ptr<OHOS::NativeRdb::AbsSharedResultSet> resultset = nullptr;
    if (asyncCallbackInfo->dataAbilityHelper != nullptr) {
        resultset = asyncCallbackInfo->dataAbilityHelper->Query(*uri, columns, predicates);
    }
    SETTING_LOG_INFO("settingsnapi : execute... after dataAbilityHelper->Query");

    int retInt = 0;
    int numRows = 0;
    if (resultset != nullptr) {
        SETTING_LOG_INFO("settingsnapi : execute... resultset is NOT empty");
        resultset->GetRowCount(numRows);
    }
    // insert
    if (resultset == nullptr || numRows == 0) {
        SETTING_LOG_INFO("settingsnapi : execute... before Insert");
        retInt = asyncCallbackInfo->dataAbilityHelper->Insert(*uri, val);
        SETTING_LOG_INFO("settingsnapi : execute... after Insert");
    // update
    } else {
        SETTING_LOG_INFO("settingsnapi : execute... before Update");
        retInt = asyncCallbackInfo->dataAbilityHelper->Update(*uri, val, predicates);
        SETTING_LOG_INFO("settingsnapi : execute... after Update");
    }
    // notify change
    if (retInt != 0) {
        SETTING_LOG_INFO("settingsnapi : execute... retInt is NOT zero");
        std::string uriWithNameStr =
            argsName.empty() ? SETTINGS_DATA_BASE_URI : (SETTINGS_DATA_BASE_URI + "/" + argsName);
        std::shared_ptr<Uri> uriWithName = std::make_shared<Uri>(uriWithNameStr);
        asyncCallbackInfo->dataAbilityHelper->NotifyChange(*uriWithName);
        SETTING_LOG_INFO(
            "settingsnapi : execute... after NotifyChange with uri: %{public}s",
            uriWithNameStr.c_str());
    }
    if (resultset != nullptr) {
        resultset->Close();
    }
    asyncCallbackInfo->status = retInt;
}

napi_value SetValueAsync(napi_env env, AsyncCallbackInfo* asyncCallbackInfo)
{
    SETTING_LOG_INFO("settingsnapi : set do callback");
    napi_value resource = nullptr;
    NAPI_CALL(env, napi_create_string_utf8(env, __func__, NAPI_AUTO_LENGTH, &resource));

    napi_create_async_work(
        env,
        nullptr,
        resource,
        SetValueExecuteCB,
        [](napi_env env, napi_status status, void* data) {
            if (data == nullptr) {
                SETTING_LOG_INFO("settingsnapi : callback set async end data is null");
                return;
            }
            SETTING_LOG_INFO("settingsnapi : callback set async end called callback");
            AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
            napi_value undefine;
            napi_get_undefined(env, &undefine);
            SETTING_LOG_INFO("settingsnapi : callback set aysnc end called");
            napi_value callback = nullptr;
            napi_value result = wrap_bool_to_js(env, asyncCallbackInfo->status != 0);
            SETTING_LOG_INFO("settingsnapi : callback set aysnc end called");
            napi_get_reference_value(env, asyncCallbackInfo->callbackRef, &callback);
            napi_call_function(env, nullptr, callback, 1, &result, &undefine);
            SETTING_LOG_INFO("settingsnapi : callback set aysnc end called");
            napi_delete_reference(env, asyncCallbackInfo->callbackRef);
            napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
            asyncCallbackInfo->dataAbilityHelper = nullptr;
            delete asyncCallbackInfo;
            SETTING_LOG_INFO("settingsnapi : callback set change callback complete");
        },
        (void*)asyncCallbackInfo,
        &asyncCallbackInfo->asyncWork
    );
    SETTING_LOG_INFO("settingsnapi : callback set start async work");
    NAPI_CALL(env, napi_queue_async_work(env, asyncCallbackInfo->asyncWork));
    SETTING_LOG_INFO("settingsnapi : callback set end async work");
    return wrap_void_to_js(env);
}

napi_value SetValuePromise(napi_env env, AsyncCallbackInfo* asyncCallbackInfo)
{
    SETTING_LOG_INFO("settingsnapi : set  do promise");
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
            SETTING_LOG_INFO("settingsnapi : promise set async end called callback");
            AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
            SETTING_LOG_INFO("settingsnapi : promise set end get callback value is %{public}d",
                asyncCallbackInfo->status);
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
    SETTING_LOG_INFO("settingsnapi : set  napi_set_value called...");

    // getValue api need 3 parameters when Promise mode and need 4 parameters when callback mode
    const size_t paramOfCallback = ARGS_FOUR;

    size_t argc = ARGS_FIVE;
    napi_value args[ARGS_FIVE] = {nullptr};
    NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));
    if (argc != ARGS_THREE && argc != ARGS_FOUR && argc != ARGS_FIVE) {
        SETTING_LOG_ERROR(
            "settingsnapi : set %{public}s, wrong number of arguments, expect 3 or 4 or 5 but get %{public}zd",
            __func__,
            argc);
        return wrap_void_to_js(env);
    }

    SETTING_LOG_INFO("settingsnapi : set  arg count is %{public}zd", argc);
    SETTING_LOG_INFO("settingsnapi : set  start create aysnc call back info");
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
    SETTING_LOG_INFO("settingsnapi : set  after create aysnc call back info");
    napi_valuetype valueType;
    NAPI_CALL(env, napi_typeof(env, args[PARAM0], &valueType));
    NAPI_ASSERT(env, valueType == napi_object, "Wrong argument[0] type. Object expected.");
    NAPI_CALL(env, napi_typeof(env, args[PARAM1], &valueType));
    NAPI_ASSERT(env, valueType == napi_string, "Wrong argument[1], type. String expected");
    NAPI_CALL(env, napi_typeof(env, args[PARAM2], &valueType));
    NAPI_ASSERT(env, valueType == napi_string, "Wrong argument[2], type. String expected");

    // api9 napi_set_value_ext
    bool stageMode = false;
    napi_status status = OHOS::AbilityRuntime::IsStageContext(env, args[PARAM0], stageMode);
    if (status == napi_ok) {
        SETTING_LOG_INFO("argv[0] is a context, Stage Model: %{public}d", stageMode);
        return napi_set_value_ext(env, info, stageMode);
    }

    NAPI_CALL(env, napi_unwrap(env, args[PARAM0], reinterpret_cast<void **>(&asyncCallbackInfo->dataAbilityHelper)));
    SETTING_LOG_INFO("settingsnapi : input paramter is (DataAbilityHelper)");

    asyncCallbackInfo->key = unwrap_string_from_js(env, args[PARAM1]);
    asyncCallbackInfo->value = unwrap_string_from_js(env, args[PARAM2]);
    SETTING_LOG_INFO("settingsnapi : set  input parameter is : (key %{public}s, value %{public}s)",
        asyncCallbackInfo->key.c_str(), asyncCallbackInfo->value.c_str());

    napi_value ret = nullptr;
    if (argc == paramOfCallback) {
        napi_create_reference(env, args[PARAM3], 1, &asyncCallbackInfo->callbackRef);
        ret = SetValueAsync(env, asyncCallbackInfo);
    } else {
        ret = SetValuePromise(env, asyncCallbackInfo);
    }
    SETTING_LOG_INFO("settingsnapi : set  value end");
    return ret;
}

napi_value napi_set_value_ext(napi_env env, napi_callback_info info, const bool stageMode)
{
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

    size_t argc = ARGS_FIVE;
    napi_value args[ARGS_FIVE] = {nullptr};
    NAPI_CALL(env, napi_get_cb_info(env, info, &argc, args, nullptr, nullptr));

    asyncCallbackInfo->dataShareHelper = getDataShareHelper(env, args[PARAM0], stageMode);
    asyncCallbackInfo->key = unwrap_string_from_js(env, args[PARAM1]);
    asyncCallbackInfo->uri = unwrap_string_from_js(env, args[PARAM2]); //temp
    napi_value resource = nullptr;
    NAPI_CALL(env, napi_create_string_utf8(env, "napi_set_value_ext", NAPI_AUTO_LENGTH, &resource));

    // set call type and table name
    napi_valuetype valueType;
    if (argc == ARGS_THREE) {
        asyncCallbackInfo->callType = STAGE_PROMISE;
        asyncCallbackInfo->tableName = "global";
    } else if (argc == ARGS_FOUR) {
        NAPI_CALL(env, napi_typeof(env, args[PARAM3], &valueType));
        if (valueType == napi_string) {
            asyncCallbackInfo->tableName = unwrap_string_from_js(env, args[PARAM3]);
            if (IsTableNameInvalid(asyncCallbackInfo->tableName)) {
                SETTING_LOG_ERROR("settingsnapi : INVALID tableName [ARGS_FOUR]");
                return wrap_void_to_js(env);
            } else {
                asyncCallbackInfo->callType = STAGE_PROMISE_SPECIFIC;
            }
        } else {
            asyncCallbackInfo->callType = STAGE_CALLBACK;
            asyncCallbackInfo->tableName = "global";
        }
    } else if (argc == ARGS_FIVE) {
        asyncCallbackInfo->callType = STAGE_CALLBACK_SPECIFIC;
        asyncCallbackInfo->tableName = unwrap_string_from_js(env, args[PARAM4]);
    } else {
        asyncCallbackInfo->callType = INVALID_CALL;
    }

    // check whether invalid call
    if (asyncCallbackInfo->callType == INVALID_CALL) {
        SETTING_LOG_ERROR("settingsnapi : INVALID CALL");
        return wrap_void_to_js(env);
    }

    if (asyncCallbackInfo->callType == STAGE_CALLBACK || asyncCallbackInfo->callType == STAGE_CALLBACK_SPECIFIC) {
        napi_create_reference(env, args[PARAM3], 1, &asyncCallbackInfo->callbackRef);
        napi_create_async_work(
            env,
            nullptr,
            resource,
            [](napi_env env, void* data) {
                AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
                GetValueExecuteExt(env, (void*)asyncCallbackInfo);
                SetValueExecuteExt(env, (void*)asyncCallbackInfo, asyncCallbackInfo->uri);
            },
            [](napi_env env, napi_status status, void* data) {
                AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
                napi_value result = wrap_bool_to_js(env, asyncCallbackInfo->status != 0);
                asyncCallbackInfo->status = napi_ok;
                CompleteCall(env, status, data, result);
            },
            (void*)asyncCallbackInfo,
            &asyncCallbackInfo->asyncWork
        );
        NAPI_CALL(env, napi_queue_async_work(env, asyncCallbackInfo->asyncWork));
        SETTING_LOG_INFO("settingsnapi : callback end async work");
        return wrap_void_to_js(env);
    } else if (asyncCallbackInfo->callType != INVALID_CALL) {
        napi_value promise;
        napi_deferred deferred;
        NAPI_CALL(env, napi_create_promise(env, &deferred, &promise));
        asyncCallbackInfo->deferred = deferred;
        napi_create_async_work(
            env,
            nullptr,
            resource,
            [](napi_env env, void* data) {
                AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
                SETTING_LOG_INFO("settingsnapi : in async work");
                GetValueExecuteExt(env, (void*)asyncCallbackInfo);
                SetValueExecuteExt(env, (void*)asyncCallbackInfo, asyncCallbackInfo->uri);
            },
            [](napi_env env, napi_status status, void* data) {
                AsyncCallbackInfo* asyncCallbackInfo = (AsyncCallbackInfo*)data;
                napi_value result = wrap_bool_to_js(env, asyncCallbackInfo->status != 0);
                asyncCallbackInfo->status = napi_ok;
                CompletePromise(env, status, data, result);
            },
            (void*)asyncCallbackInfo,
            &asyncCallbackInfo->asyncWork
        );
        NAPI_CALL(env, napi_queue_async_work(env, asyncCallbackInfo->asyncWork));
        return promise;
    } else {
        SETTING_LOG_ERROR("settingsnapi : INVALID CALL");
        return wrap_void_to_js(env);
    }
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
        SETTING_LOG_ERROR("settingsnapi : %{public}s, wrong number of arguments, expect 1 or 2 but get %{public}zd",
            __func__, argc);
        return wrap_void_to_js(env);
    }

    SETTING_LOG_INFO("settingsnapi : napi_enable_airplane_mode arg count is %{public}zd", argc);
    SETTING_LOG_INFO("settingsnapi : napi_enable_airplane_mode start create aysnc call back info");
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
    SETTING_LOG_INFO("settingsnapi : after create aysnc call back info");

    napi_valuetype valueType;
    NAPI_CALL(env, napi_typeof(env, args[PARAM0], &valueType));
    NAPI_ASSERT(env, valueType == napi_boolean, "Wrong argument[0], type. Boolean expected");

    napi_value resource = nullptr;  
    NAPI_CALL(env, napi_create_string_utf8(env, "enableAirplaneMode", NAPI_AUTO_LENGTH, &resource));

    if (argc == paramOfCallback) {
        SETTING_LOG_INFO("%{public}s, asyncCallback.", __func__);

        napi_create_reference(env, args[PARAM1], 1, &asyncCallbackInfo->callbackRef);
        napi_create_async_work(
            env,
            nullptr,
            resource,
            [](napi_env env, void* data) {},
            [](napi_env env, napi_status status, void* data) {
                if (data == nullptr) {
                    SETTING_LOG_INFO("settingsnapi : callback async end data is null");
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
                SETTING_LOG_INFO("settingsnapi : callback aysnc end called");

                napi_delete_reference(env, asyncCallbackInfo->callbackRef);
                napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
                delete asyncCallbackInfo;
                SETTING_LOG_INFO("settingsnapi : callback change callback complete");
            },
            (void*)asyncCallbackInfo,
            &asyncCallbackInfo->asyncWork
        );
        NAPI_CALL(env, napi_queue_async_work(env, asyncCallbackInfo->asyncWork));
        return wrap_void_to_js(env);
    } else {
        SETTING_LOG_INFO("%{public}s, promise.", __func__);
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
                SETTING_LOG_INFO("%{public}s, promise complete", __func__);
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
        SETTING_LOG_ERROR("settingsnapi : %{public}s, wrong number of arguments, expect 0 or 1 but get %{public}zd",
            __func__, argc);
        return wrap_void_to_js(env);
    }

    SETTING_LOG_INFO("settingsnapi : napi_enable_airplane_mode arg count is %{public}zd", argc);
    SETTING_LOG_INFO("settingsnapi : napi_enable_airplane_mode start create aysnc call back info");
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
    SETTING_LOG_INFO("settingsnapi : after create aysnc call back info");

    napi_value resource = nullptr;  
    NAPI_CALL(env, napi_create_string_utf8(env, "enableAirplaneMode", NAPI_AUTO_LENGTH, &resource));

    if (argc == paramOfCallback) {
        SETTING_LOG_INFO("%{public}s, asyncCallback.", __func__);

        napi_create_reference(env, args[PARAM0], 1, &asyncCallbackInfo->callbackRef);
        napi_create_async_work(
            env,
            nullptr,
            resource,
            [](napi_env env, void* data) {},
            [](napi_env env, napi_status status, void* data) {
                if (data == nullptr) {
                    SETTING_LOG_INFO("settingsnapi : callback async end data is null");
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
                SETTING_LOG_INFO("settingsnapi : callback aysnc end called");

                napi_delete_reference(env, asyncCallbackInfo->callbackRef);
                napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
                delete asyncCallbackInfo;
                SETTING_LOG_INFO("settingsnapi : callback change callback complete");
            },
            (void*)asyncCallbackInfo,
            &asyncCallbackInfo->asyncWork
        );
        NAPI_CALL(env, napi_queue_async_work(env, asyncCallbackInfo->asyncWork));
        return wrap_void_to_js(env);
    } else {
        SETTING_LOG_INFO("%{public}s, promise.", __func__);
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
                SETTING_LOG_INFO("%{public}s, promise complete", __func__);
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

// get uri for stage model
std::string GetStageUriStr(std::string tableName, std::string IdStr, std::string keyStr)
{
    if (tableName == "global") {
        std::string retStr =
            "datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=" + keyStr;
        return retStr;
    } else if (tableName == "system") {
        std::string retStr = "datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_" + IdStr +
                             "?Proxy=true&key=" + keyStr;
        return retStr;
    } else if (tableName == "secure") {
        std::string retStr = "datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_SECURE_" + IdStr +
                             "?Proxy=true&key=" + keyStr;
        return retStr;
    } else {
        // return global uri
        std::string retStr =
            "datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=" + keyStr;
        return retStr;
    }
}

// get proxy uri
std::string GetProxyUriStr(std::string tableName, std::string IdStr)
{
    if (tableName == "global") {
        // return global uri
        std::string retStr = "datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true";
        return retStr;
    } else if (tableName == "system") {
        std::string retStr =
            "datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_" + IdStr + "?Proxy=true";
        return retStr;
    } else {
        std::string retStr =
            "datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_SECURE_" + IdStr + "?Proxy=true";
        return retStr;
    }
}

// check whether tableName is invalid, invalid -> true valid -> false
bool IsTableNameInvalid(std::string tableName)
{
    if (tableName != "global" && tableName != "system" && tableName != "secure") {
        return true;
    } else {
        return false;
    }
}

napi_value napi_get_value_sync_ext(bool stageMode, size_t argc, napi_env env, napi_value* args)
{
    SETTING_LOG_INFO("argv[0] is a context, Stage Model: %{public}d", stageMode);
    AsyncCallbackInfo *asyncCallbackInfo = new AsyncCallbackInfo();
    napi_valuetype valueType;

    // define table name
    if (argc == ARGS_FOUR) {
        // check whether tableName is ok
        NAPI_CALL(env, napi_typeof(env, args[PARAM3], &valueType));
        if (valueType != napi_string) {
            SETTING_LOG_ERROR("settingsnapi : tableName IS NOT STRING");
            return wrap_void_to_js(env);
        } else {
            asyncCallbackInfo->tableName = unwrap_string_from_js(env, args[PARAM3]);
            if (IsTableNameInvalid(asyncCallbackInfo->tableName)) {
                SETTING_LOG_ERROR("settingsnapi : INVALID tableName");
                return wrap_void_to_js(env);
            }
        }
    } else {
        asyncCallbackInfo->tableName = "global";
    }

    asyncCallbackInfo->key = unwrap_string_from_js(env, args[PARAM1]);
    std::shared_ptr<OHOS::DataShare::DataShareHelper> dataShareHelper = nullptr;
    asyncCallbackInfo->dataShareHelper = getDataShareHelper(env, args[PARAM0], stageMode, asyncCallbackInfo->tableName);
    GetValueExecuteExt(env, (void *)asyncCallbackInfo);
    SETTING_LOG_INFO(
        "settingsnapi : napi_get_value_sync called... return  %{public}s", asyncCallbackInfo->value.c_str());
    napi_value retVal = nullptr;
    if (asyncCallbackInfo->value.size() <= 0) {
        retVal = args[PARAM2];
    } else {
        retVal = wrap_string_to_js(env, asyncCallbackInfo->value);
    }
    if (asyncCallbackInfo->dataShareHelper = nullptr) {
        asyncCallbackInfo->dataShareHelper->Release();
    }
    delete asyncCallbackInfo;
    return retVal;
}

napi_value napi_set_value_sync_ext(bool stageMode, size_t argc, napi_env env, napi_value *args)
{
    SETTING_LOG_INFO("argv[0] is a context, Stage Model: %{public}d", stageMode);
    AsyncCallbackInfo *asyncCallbackInfo = new AsyncCallbackInfo();
    asyncCallbackInfo->key = unwrap_string_from_js(env, args[PARAM1]);
    napi_valuetype valueType;

    // define table name
    if (argc == ARGS_FOUR) {
        NAPI_CALL(env, napi_typeof(env, args[PARAM3], &valueType));
        if (valueType != napi_string) {
            SETTING_LOG_ERROR("settingsnapi : tableName IS NOT STRING");
            return wrap_void_to_js(env);
        } else {
            asyncCallbackInfo->tableName = unwrap_string_from_js(env, args[PARAM3]);
            if (IsTableNameInvalid(asyncCallbackInfo->tableName)) {
                SETTING_LOG_ERROR("settingsnapi : INVALID tableName");
                return wrap_void_to_js(env);
            }
        }
    } else {
        asyncCallbackInfo->tableName = "global";
    }
    std::shared_ptr<OHOS::DataShare::DataShareHelper> dataShareHelper = nullptr;
    asyncCallbackInfo->dataShareHelper = getDataShareHelper(env, args[PARAM0], stageMode, asyncCallbackInfo->tableName);
    GetValueExecuteExt(env, (void *)asyncCallbackInfo);
    SetValueExecuteExt(env, (void *)asyncCallbackInfo, unwrap_string_from_js(env, args[PARAM2]));
    napi_value result = wrap_bool_to_js(env, asyncCallbackInfo->status != 0);
    if (asyncCallbackInfo->dataShareHelper = nullptr) {
        asyncCallbackInfo->dataShareHelper->Release();
    }
    delete asyncCallbackInfo;
    return result;
}

}  // namespace Settings
}  // namespace OHOS
