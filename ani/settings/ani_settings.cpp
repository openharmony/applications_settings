/*
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

#include <pthread.h>
#include <unistd.h>
#include "ani_settings.h"
#include "ani_settings_log.h"
#include "ani_settings_observer.h"
#include "ani.h"
#include "ani_base_context.h"
#include "abs_shared_result_set.h"
#include "ani_open_network_settings.h"
#include "values_bucket.h"
#include "datashare_business_error.h"
#include "os_account_manager.h"

using namespace OHOS::AppExecFwk;
using namespace OHOS::DataShare;
using namespace OHOS::AccountSA;

namespace OHOS {
namespace Settings {
const std::string SETTINGS_DATA_BASE_URI = "dataability:///com.ohos.settingsdata.DataAbility";
const std::string SETTINGS_DATA_FIELD_KEYWORD = "KEYWORD";
const std::string SETTINGS_DATA_FIELD_VALUE = "VALUE";
const std::string PERMISSION_EXCEPTION = "Permission denied";
const int PERMISSION_EXCEPTION_CODE = 201;
const int QUERY_SUCCESS_CODE = 1;
const int STATUS_ERROR_CODE = -1;
const int PERMISSION_DENIED_CODE = -2;
const int USERID_HELPER_NUMBER = 100;
const int UNSUPPORT_CODE = 801;

void ThrowExistingError(ani_env *env, int errorCode, std::string errorMessage)
{
    static const char *errorClsName = "L@ohos/base/BusinessError;";
    ani_class cls{};
    if (ANI_OK != env->FindClass(errorClsName, &cls)) {
        SETTING_LOG_ERROR("find class BusinessError %{public}s failed", errorClsName);
        return;
    }
    ani_method ctor;
    if (ANI_OK != env->Class_FindMethod(cls, "<ctor>", ":V", &ctor)) {
        SETTING_LOG_ERROR("find method BusinessError.constructor failed");
        return;
    }
    ani_object errorObject;
    if (ANI_OK != env->Object_New(cls, ctor, &errorObject)) {
        SETTING_LOG_ERROR("create BusinessError object failed");
        return;
    }
    ani_double aniErrCode = static_cast<ani_double>(errorCode);
    ani_string errMsgStr;
    if (ANI_OK != env->String_NewUTF8(errorMessage.c_str(), errorMessage.size(), &errMsgStr)) {
        SETTING_LOG_ERROR("convert errMsg to ani_string failed");
        return;
    }
    if (ANI_OK != env->Object_SetFieldByName_Double(errorObject, "code", aniErrCode)) {
        SETTING_LOG_ERROR("set error code failed");
        return;
    }
    if (ANI_OK != env->Object_SetPropertyByName_Ref(errorObject, "message", errMsgStr)) {
        SETTING_LOG_ERROR("set error message failed");
        return;
    }
    env->ThrowError(static_cast<ani_error>(errorObject));
}

bool ThrowError(ani_env *env, int status)
{
    if (status >= 0) {
        return true;
    }
    if (status == PERMISSION_DENIED_CODE) {
        ThrowExistingError(env, PERMISSION_EXCEPTION_CODE, PERMISSION_EXCEPTION);
    }
    return false;
}

void QueryValue(ani_env *env, AsyncCallbackInfo *asyncCallbackInfo, OHOS::Uri uri)
{
    SETTING_LOG_INFO("a_C_B_I->d_S_H != nullptr");
    if (asyncCallbackInfo->dataShareHelper == nullptr) {
        SETTING_LOG_ERROR("helper is null");
        asyncCallbackInfo->status = STATUS_ERROR_CODE;
        return;
    }

    std::vector<std::string> columns;
    columns.push_back(SETTINGS_DATA_FIELD_VALUE);

    OHOS::DataShare::DataSharePredicates predicates;
    predicates.EqualTo(SETTINGS_DATA_FIELD_KEYWORD, asyncCallbackInfo->key);

    DatashareBusinessError businessError;
    std::shared_ptr<OHOS::DataShare::DataShareResultSet> resultSet = nullptr;
    resultSet = asyncCallbackInfo->dataShareHelper->Query(uri, predicates, columns, &businessError);
    int numRows = 0;
    if (resultSet != nullptr) {
        SETTING_LOG_INFO("G_V_E_E resultSet is NOT empty");
        resultSet->GetRowCount(numRows);
    }
    int datashareErrorCode = businessError.GetCode();
    SETTING_LOG_INFO("numRows %{public}d, error code %{public}d", numRows, datashareErrorCode);
    if (datashareErrorCode != 0 && datashareErrorCode != PERMISSION_DENIED_CODE) {
        asyncCallbackInfo->status = STATUS_ERROR_CODE;
    } else if (datashareErrorCode == PERMISSION_DENIED_CODE) {
        asyncCallbackInfo->status = PERMISSION_DENIED_CODE;
    } else if (resultSet == nullptr || numRows <= 0) {
        SETTING_LOG_INFO("G_V_E_E value is empty");
        asyncCallbackInfo->status = STATUS_ERROR_CODE;
    } else {
        std::string val;
        int32_t columnIndex = 0;
        resultSet->GoToFirstRow();
        resultSet->GetString(columnIndex, val);

        SETTING_LOG_INFO("n_g_v_e %{public}s", val.c_str());
        asyncCallbackInfo->value = val;
        asyncCallbackInfo->status = QUERY_SUCCESS_CODE;
    }

    if (resultSet != nullptr) {
        resultSet->Close();
    }
}

void GetValueExecuteExt(ani_env *env, void *data)
{
    if (data == nullptr) {
        SETTING_LOG_INFO("execute data is null");
        return;
    }

    SETTING_LOG_INFO("G_V_E_E start");
    AsyncCallbackInfo *asyncCallbackInfo = (AsyncCallbackInfo *)data;

    if (asyncCallbackInfo->dataShareHelper == nullptr) {
        SETTING_LOG_ERROR("dataShareHelper is empty");
        asyncCallbackInfo->status = STATUS_ERROR_CODE;
        return;
    }

    std::vector<int> tmpId;
    int currentUserId = -1;
    OHOS::AccountSA::OsAccountManager::GetOsAccountLocalIdFromProcess(currentUserId);
    std::string tmpIdStr = "100";
    if (currentUserId > 0) {
        tmpIdStr = std::to_string(currentUserId);
        SETTING_LOG_INFO("userId is %{public}s", tmpIdStr.c_str());
    } else if (currentUserId == 0) {
        OHOS::AccountSA::OsAccountManager::GetForegroundOsAccountLocalId(currentUserId);
        tmpIdStr = std::to_string(currentUserId);
        SETTING_LOG_INFO("user0 userId is %{public}s", tmpIdStr.c_str());
    } else {
        SETTING_LOG_ERROR("userid is invalid, use id 100 instead");
    }
    std::string strUri = GetStageUriStr(asyncCallbackInfo->tableName, tmpIdStr, asyncCallbackInfo->key);
    SETTING_LOG_INFO("Get uri : %{public}s, key: %{public}s", strUri.c_str(), (asyncCallbackInfo->key).c_str());
    OHOS::Uri uri(strUri);

    QueryValue(env, asyncCallbackInfo, uri);
}

void DeleteCallbackInfo(AsyncCallbackInfo *asyncCallbackInfo)
{
    if (asyncCallbackInfo != nullptr) {
        asyncCallbackInfo->dataShareHelper = nullptr;
        delete asyncCallbackInfo;
        asyncCallbackInfo = nullptr;
    }
}

ani_string ani_get_value(ani_env *env, ani_object context, ani_string name, ani_string domainName)
{
    ani_boolean stageMode = false;
    ani_status status = OHOS::AbilityRuntime::IsStageContext(env, context, stageMode);
    if (status == ANI_OK) {
        return ani_get_value_ext(env, context, name, domainName);
    }
    return nullptr;
}

ani_string ani_get_value_ext(ani_env *env, ani_object context, ani_string name, ani_string domainName)
{
    AsyncCallbackInfo *asyncCallbackInfo = new AsyncCallbackInfo{
        .env = env,
        .key = "",
        .value = "",
        .uri = "",
        .status = false,
    };
    asyncCallbackInfo->dataShareHelper = getDataShareHelper(env, context);
    asyncCallbackInfo->key = unwrap_string_from_js(env, name);
    asyncCallbackInfo->tableName = unwrap_string_from_js(env, domainName);
    if (IsTableNameInvalid(asyncCallbackInfo->tableName)) {
        SETTING_LOG_ERROR("INVALID tableName [ARGS_THREE]");
        return nullptr;
    }
    GetValueExecuteExt(env, (void *)asyncCallbackInfo);
    ani_string retVal = nullptr;
    if (asyncCallbackInfo->value.size() <= 0) {
        ThrowError(env, asyncCallbackInfo->status);
    } else {
        retVal = wrap_string_to_js(env, asyncCallbackInfo->value);
    }
    DeleteCallbackInfo(asyncCallbackInfo);
    return retVal;
}

ani_boolean ani_set_value(ani_env *env, ani_object context, ani_string name, ani_string value, ani_string domainName)
{
    SETTING_LOG_INFO("set  ani_set_value");
    ani_boolean stageMode = false;
    ani_status status = OHOS::AbilityRuntime::IsStageContext(env, context, stageMode);
    if (status == ANI_OK) {
        return ani_set_value_ext(env, context, name, value, domainName);
    }
    return false;
}

ani_boolean ani_set_value_ext(
    ani_env *env, ani_object context, ani_string name, ani_string value, ani_string domainName)
{
    AsyncCallbackInfo *asyncCallbackInfo = new AsyncCallbackInfo{
        .env = env,
        .key = "",
        .value = "",
        .uri = "",
        .status = false,
        .useSilent = true,
    };
    asyncCallbackInfo->key = unwrap_string_from_js(env, name);
    asyncCallbackInfo->uri = unwrap_string_from_js(env, value);
    asyncCallbackInfo->tableName = unwrap_string_from_js(env, domainName);
    asyncCallbackInfo->dataShareHelper =
        getDataShareHelper(env, context, asyncCallbackInfo->tableName, asyncCallbackInfo);
    asyncCallbackInfo->value = unwrap_string_from_js(env, value);
    if (IsTableNameInvalid(asyncCallbackInfo->tableName)) {
        SETTING_LOG_ERROR("INVALID tableName [ARGS_FOUR]");
        return false;
    }
    SetValueExecuteExt(env, (void *)asyncCallbackInfo, asyncCallbackInfo->uri);
    ani_boolean retVal = true;
    if (asyncCallbackInfo->status <= 0) {
        ThrowError(env, asyncCallbackInfo->status);
        retVal = false;
    }
    DeleteCallbackInfo(asyncCallbackInfo);
    return retVal;
}

void ani_enable_airplane_mode(ani_env *env, ani_boolean enable)
{
    AsyncCallbackInfo *asyncCallbackInfo = new AsyncCallbackInfo{
        .env = env,
        .callbackRef = nullptr,
        .dataAbilityHelper = nullptr,
        .key = "",
        .value = "",
        .uri = "",
        .status = 0,
    };
    if (asyncCallbackInfo == nullptr) {
        SETTING_LOG_ERROR("asyncCallbackInfo is null");
    }
    ThrowExistingError(env, UNSUPPORT_CODE, "");
    if (asyncCallbackInfo != nullptr) {
        delete asyncCallbackInfo;
        asyncCallbackInfo = nullptr;
    }
}

ani_boolean ani_can_show_floating(ani_env *env)
{
    AsyncCallbackInfo *asyncCallbackInfo = new AsyncCallbackInfo{
        .env = env,
        .callbackRef = nullptr,
        .dataAbilityHelper = nullptr,
        .key = "",
        .value = "",
        .uri = "",
        .status = 0,
    };
    if (asyncCallbackInfo == nullptr) {
        SETTING_LOG_ERROR("asyncCallbackInfo is null");
        return false;
    }
    ThrowExistingError(env, UNSUPPORT_CODE, "");
    if (asyncCallbackInfo != nullptr) {
        delete asyncCallbackInfo;
        asyncCallbackInfo = nullptr;
    }
    return true;
}

ani_string ani_get_value_sync(
    ani_env *env, ani_object context, ani_string key, ani_string defaultValue, ani_string domainName)
{
    SETTING_LOG_INFO("n_g_v");

    ani_boolean stageMode = false;
    ani_status status = OHOS::AbilityRuntime::IsStageContext(env, context, stageMode);
    if (status == ANI_OK) {
        return ani_get_value_sync_ext(env, context, key, defaultValue, domainName);
    }
    ani_string retVal = nullptr;
    return retVal;
}

bool IsTableNameInvalid(std::string tableName)
{
    if (tableName != "global" && tableName != "system" && tableName != "secure") {
        return true;
    }
    return false;
}

ani_string ani_get_value_sync_ext(
    ani_env *env, ani_object context, ani_string key, ani_string defaultValue, ani_string domainName)
{
    SETTING_LOG_INFO("ani_get_value_sync_ext");
    AsyncCallbackInfo *asyncCallbackInfo = new AsyncCallbackInfo();
    asyncCallbackInfo->tableName = unwrap_string_from_js(env, domainName);
    asyncCallbackInfo->key = unwrap_string_from_js(env, key);
    asyncCallbackInfo->dataShareHelper = getDataShareHelper(env, context, asyncCallbackInfo->tableName);
    GetValueExecuteExt(env, (void *)asyncCallbackInfo);
    SETTING_LOG_INFO("n_g_v return %{public}s", asyncCallbackInfo->value.c_str());
    ani_string retVal = nullptr;
    if (asyncCallbackInfo->value.size() <= 0) {
        retVal = defaultValue;
        ThrowError(env, asyncCallbackInfo->status);
    } else {
        retVal = wrap_string_to_js(env, asyncCallbackInfo->value);
    }
    DeleteCallbackInfo(asyncCallbackInfo);
    return retVal;
}

std::shared_ptr<DataShareHelper> getDataShareHelper(
    ani_env *env, const ani_object context, std::string tableName, AsyncCallbackInfo *asyncCallbackInfo)
{
    std::shared_ptr<OHOS::DataShare::DataShareHelper> dataShareHelper = nullptr;
    std::vector<int> tmpId;
    int currentUserId = -1;
    OHOS::AccountSA::OsAccountManager::GetOsAccountLocalIdFromProcess(currentUserId);
    std::string tmpIdStr = "100";
    if (currentUserId > 0) {
        tmpIdStr = std::to_string(currentUserId);
        SETTING_LOG_INFO("userId is %{public}s", tmpIdStr.c_str());
    } else if (currentUserId == 0) {
        OHOS::AccountSA::OsAccountManager::GetForegroundOsAccountLocalId(currentUserId);
        tmpIdStr = std::to_string(currentUserId);
        SETTING_LOG_INFO("user0 userId is %{public}s", tmpIdStr.c_str());
    } else {
        SETTING_LOG_ERROR("userid is invalid, use id 100 instead");
    }
    std::string strUri = "datashare:///com.ohos.settingsdata.DataAbility";
    std::string strProxyUri = GetProxyUriStr(tableName, tmpIdStr);
    OHOS::Uri proxyUri(strProxyUri);
    SETTING_LOG_INFO("<Ver-11-14> strProxyUri: %{public}s", strProxyUri.c_str());
    auto contextS = OHOS::AbilityRuntime::GetStageModeContext(env, context);
    if (contextS == nullptr) {
        SETTING_LOG_ERROR("get context is error.");
        return dataShareHelper;
    }
    dataShareHelper = OHOS::DataShare::DataShareHelper::Creator(contextS->GetToken(), strProxyUri);
    if (!dataShareHelper) {
        SETTING_LOG_ERROR("dataShareHelper from strProxyUri is null");
        dataShareHelper = OHOS::DataShare::DataShareHelper::Creator(contextS->GetToken(), strUri);
        if (asyncCallbackInfo) {
            asyncCallbackInfo->useSilent = false;
        }
    }
    SETTING_LOG_INFO("g_D_S_H Creator called, valid %{public}d", dataShareHelper != nullptr);
    return dataShareHelper;
}

ani_string wrap_string_to_js(ani_env *env, const std::string &value)
{
    ani_string result_string{};
    env->String_NewUTF8(value.c_str(), value.length(), &result_string);
    return result_string;
}

std::string unwrap_string_from_js(ani_env *env, ani_string param)
{
    std::string defaultValue("");
    ani_size strSize;
    auto status = env->String_GetUTF8Size(param, &strSize);
    if (status != ANI_OK || strSize == 0) {
        return defaultValue;
    }
    std::vector<char> buffer(strSize + 1);  // +1 for null terminator
    char *utf8Buffer = buffer.data();

    ani_size bytesWritten = 0;
    if (env->String_GetUTF8(param, utf8Buffer, strSize + 1, &bytesWritten) != ANI_OK) {
        return defaultValue;
    }

    utf8Buffer[bytesWritten] = '\0';
    return std::string(utf8Buffer);
}

std::string GetStageUriStr(std::string tableName, std::string idStr, std::string keyStr)
{
    if (std::stoi(idStr) < USERID_HELPER_NUMBER) {
        idStr = "100";
    }
    std::string retStr;
    if (tableName == "global") {
        retStr = "datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=" + keyStr;
    } else if (tableName == "system") {
        retStr = "datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_" + idStr +
                 "?Proxy=true&key=" + keyStr;
    } else if (tableName == "secure") {
        retStr = "datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_SECURE_" + idStr +
                 "?Proxy=true&key=" + keyStr;
    } else {
        // return global uri
        retStr = "datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=" + keyStr;
    }
    return retStr;
}

std::string GetProxyUriStr(std::string tableName, std::string idStr)
{
    if (std::stoi(idStr) < USERID_HELPER_NUMBER) {
        idStr = "100";
    }
    std::string retStr;
    if (tableName == "global") {
        // return global uri
        retStr = "datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true";
    } else if (tableName == "system") {
        retStr = "datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_" + idStr + "?Proxy=true";
    } else {
        retStr =
            "datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_SECURE_" + idStr + "?Proxy=true";
    }
    return retStr;
}

ani_boolean ani_set_value_sync(
    ani_env *env, ani_object context, ani_string key, ani_string value, ani_string domainName)
{
    SETTING_LOG_INFO("n_g_v");
    ani_boolean stageMode = false;
    ani_status status = OHOS::AbilityRuntime::IsStageContext(env, context, stageMode);
    if (status == ANI_OK) {
        return ani_set_value_sync_ext(env, context, key, value, domainName);
    }
    return false;
}

ani_boolean ani_set_value_sync_ext(
    ani_env *env, ani_object context, ani_string key, ani_string value, ani_string domainName)
{
    AsyncCallbackInfo *asyncCallbackInfo = new AsyncCallbackInfo();
    if (asyncCallbackInfo == nullptr) {
        SETTING_LOG_ERROR("asyncCallbackInfo is null");
        return false;
    }
    asyncCallbackInfo->key = unwrap_string_from_js(env, key);
    asyncCallbackInfo->tableName = unwrap_string_from_js(env, domainName);
    asyncCallbackInfo->dataShareHelper =
        getDataShareHelper(env, context, asyncCallbackInfo->tableName, asyncCallbackInfo);
    SetValueExecuteExt(env, (void *)asyncCallbackInfo, unwrap_string_from_js(env, value));
    DeleteCallbackInfo(asyncCallbackInfo);
    return ThrowError(env, asyncCallbackInfo->status);
}

void SetValueExecuteExt(ani_env *env, void *data, const std::string setValue)
{
    if (data == nullptr) {
        SETTING_LOG_INFO("s_V_E_E data is null");
        return;
    }
    SETTING_LOG_INFO("execute start");
    AsyncCallbackInfo *asyncCallbackInfo = (AsyncCallbackInfo *)data;

    if (asyncCallbackInfo->dataShareHelper == nullptr) {
        SETTING_LOG_INFO("helper is null");
        asyncCallbackInfo->status = STATUS_ERROR_CODE;
        return;
    }

    OHOS::DataShare::DataShareValuesBucket val;
    val.Put(SETTINGS_DATA_FIELD_KEYWORD, asyncCallbackInfo->key);
    val.Put(SETTINGS_DATA_FIELD_VALUE, setValue);

    std::vector<int> tmpId;
    int currentUserId = -1;
    OHOS::AccountSA::OsAccountManager::GetOsAccountLocalIdFromProcess(currentUserId);
    std::string tmpIdStr = "100";
    if (currentUserId > 0) {
        tmpIdStr = std::to_string(currentUserId);
        SETTING_LOG_INFO("userId is %{public}s", tmpIdStr.c_str());
    } else if (currentUserId == 0) {
        OHOS::AccountSA::OsAccountManager::GetForegroundOsAccountLocalId(currentUserId);
        tmpIdStr = std::to_string(currentUserId);
        SETTING_LOG_INFO("user0 userId is %{public}s", tmpIdStr.c_str());
    } else {
        SETTING_LOG_ERROR("userid is invalid, use id 100 instead");
    }
    std::string strUri = GetStageUriStr(asyncCallbackInfo->tableName, tmpIdStr, asyncCallbackInfo->key);
    SETTING_LOG_WARN("Set key: %{public}s", (asyncCallbackInfo->key).c_str());
    OHOS::Uri uri(strUri);

    OHOS::DataShare::DataSharePredicates predicates;
    predicates.EqualTo(SETTINGS_DATA_FIELD_KEYWORD, asyncCallbackInfo->key);

    // update first.
    int retInt = asyncCallbackInfo->dataShareHelper->Update(uri, predicates, val);
    SETTING_LOG_WARN("update ret: %{public}d", retInt);
    if (retInt <= 0) {
        // retry to insert.
        retInt = asyncCallbackInfo->dataShareHelper->Insert(uri, val);
        SETTING_LOG_ERROR("insert ret: %{public}d", retInt);
    }
    if (retInt > 0 && !asyncCallbackInfo->useSilent) {
        SETTING_LOG_INFO("not use silent and notifyChange!");
        asyncCallbackInfo->dataShareHelper->NotifyChange(uri);
    }
    asyncCallbackInfo->status = retInt;
}

ani_string ani_get_uri_sync(ani_env *env, ani_string key)
{
    SETTING_LOG_INFO("called");
    ani_string retUri = nullptr;
    std::string uriArgStr = unwrap_string_from_js(env, key);
    uriArgStr = "datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=" + uriArgStr;
    retUri = wrap_string_to_js(env, uriArgStr);
    return retUri;
}

ani_boolean ani_unregister_key_observer(ani_env *env, ani_object context, ani_string name, ani_string domainName)
{
    return ani_settings_unregister_observer(env, context, name, domainName);
}

ani_boolean ani_register_key_observer(
    ani_env *env, ani_object context, ani_string name, ani_string domainName, ani_object observer)
{
    return ani_settings_register_observer(env, context, name, domainName, observer);
}

}  // namespace Settings
}  // namespace OHOS

static ani_boolean BindMethods(ani_env *env)
{
    using namespace OHOS::Settings;
    const char *spaceName = "L@ohos/settings/settings;";
    ani_namespace spc;

    ani_status ret = env->FindNamespace(spaceName, &spc);

    if (ret != ANI_OK) {
        SETTING_LOG_ERROR("Not found %{public}s, ret = %{public}d", spaceName, ret);
        return ANI_NOT_FOUND;
    }

    std::array methods = {
        ani_native_function{"getValue_inner", nullptr, reinterpret_cast<void *>(ani_get_value)},
        ani_native_function{"setValue_inner", nullptr, reinterpret_cast<void *>(ani_set_value)},
        ani_native_function{"enableAirplaneMode_inner", nullptr, reinterpret_cast<void *>(ani_enable_airplane_mode)},
        ani_native_function{"canShowFloating_inner", nullptr, reinterpret_cast<void *>(ani_can_show_floating)},
        ani_native_function{"getValueSync_inner", nullptr, reinterpret_cast<void *>(ani_get_value_sync)},
        ani_native_function{"setValueSync_inner", nullptr, reinterpret_cast<void *>(ani_set_value_sync)},
        ani_native_function{"getUriSync", nullptr, reinterpret_cast<void *>(ani_get_uri_sync)},
        ani_native_function{"registerKeyObserver", nullptr, reinterpret_cast<void *>(ani_register_key_observer)},
        ani_native_function{"unregisterKeyObserver", nullptr, reinterpret_cast<void *>(ani_unregister_key_observer)},
        ani_native_function{
            "openNetworkManagerSettings_inner", nullptr, reinterpret_cast<void *>(opne_manager_settings)},
    };

    if (env->Namespace_BindNativeFunctions(spc, methods.data(), methods.size()) != ANI_OK) {
        SETTING_LOG_ERROR("Cannot bind native methods to %{public}s ", spaceName);
        return ANI_ERROR;
    }
    return ANI_OK;
}

extern "C" {
ANI_EXPORT ani_status ANI_Constructor(ani_vm *vm, uint32_t *result)
{
    using namespace OHOS::Settings;
    SETTING_LOG_INFO("Call");
    if (vm == nullptr || result == nullptr) {
        SETTING_LOG_ERROR("vm or result is nullptr");
        return ANI_ERROR;
    }

    ani_env *env = nullptr;
    if (vm->GetEnv(ANI_VERSION_1, &env) != ANI_OK) {
        SETTING_LOG_ERROR("Unsupported ANI_VERSION_1");
        return ANI_OUT_OF_REF;
    }

    if (env == nullptr) {
        SETTING_LOG_ERROR("env is nullptr");
        return ANI_ERROR;
    }

    if (BindMethods(env) != ANI_OK) {
        return ANI_ERROR;
    }

    *result = ANI_VERSION_1;
    SETTING_LOG_INFO("End");
    return ANI_OK;
}
}