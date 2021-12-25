/*
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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

/**
 * @brief getUri NAPI implementation.
 * 
 * @param env the environment that the Node-API call is invoked under
 * @param info the callback info passed into the callback function
 * @return napi_value the return value from NAPI C++ to JS for the module.
 */
napi_value napi_get_uri(napi_env env, napi_callback_info info)
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

/**
 * @brief Get ability context.
 * 
 * @param env the environment that the Node-API call is invoked under
 * @return std::shared_ptr<Context> ability context
 */
std::shared_ptr<Context> get_ability_context(napi_env env)
{
    napi_value global = nullptr;
    NAPI_CALL(env, napi_get_global(env, &global));

    napi_value abilityObj = nullptr;
    NAPI_CALL(env, napi_get_named_property(env, global, "ability", &abilityObj));

    Ability *ability = nullptr;
    NAPI_CALL(env, napi_get_value_external(env, abilityObj, (void **)&ability));
    HILOG_INFO("napi_get_value called. ability = %{public}p ........", ability);

    return ability->GetContext();
}

/**
 * @brief getValue NAPI implementation.
 * 
 * @param env the environment that the Node-API call is invoked under
 * @param info the callback info passed into the callback function
 * @return napi_value the return value from NAPI C++ to JS for the module.
 */
napi_value napi_get_value(napi_env env, napi_callback_info info)
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

    std::shared_ptr<Context> context = get_ability_context(env);
    std::shared_ptr<Uri> uri = std::make_shared<Uri>(SETTINGS_DATA_BASE_URI);
    std::shared_ptr<DataAbilityHelper> dataAbilityHelper = DataAbilityHelper::Creator(context, uri);

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

    HILOG_INFO("napi_get_value called... END!");
    return retVal;
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

    std::shared_ptr<Context> context = get_ability_context(env);
    std::shared_ptr<Uri> uri = std::make_shared<Uri>(SETTINGS_DATA_BASE_URI);
    std::shared_ptr<DataAbilityHelper> dataAbilityHelper = DataAbilityHelper::Creator(context, uri);

    std::string argsName = unwrap_string_from_js(env, args[PARAM1]);
    std::string argsDefaultValue = unwrap_string_from_js(env, args[PARAM2]);

    OHOS::NativeRdb::ValuesBucket val;
    val.PutString(SETTINGS_DATA_FIELD_KEYWORD, argsName);
    val.PutString(SETTINGS_DATA_FIELD_VALUE, argsDefaultValue);

    std::vector<std::string> columns;
    columns.push_back(SETTINGS_DATA_FIELD_VALUE);
    OHOS::NativeRdb::DataAbilityPredicates predicates;
    predicates.EqualTo(SETTINGS_DATA_FIELD_KEYWORD, argsName);

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
}  // namespace Settings
}  // namespace OHOS
