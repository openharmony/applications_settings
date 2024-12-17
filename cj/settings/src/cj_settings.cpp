/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "cj_settings.h"
#include <cstdint>
#include <vector>
#include "cj_common_ffi.h"
#include "cj_settings_log.h"
#include "cj_settings_utils.h"
#include "os_account_manager.h"
#include "securec.h"
#include "uri.h"

namespace OHOS {
namespace CJSystemapi {
namespace CJSettings {
const std::string SETTINGS_DATA_BASE_URI = "dataability:///com.ohos.settingsdata.DataAbility";
const std::string SETTINGS_DATA_FIELD_KEYWORD = "KEYWORD";
const std::string SETTINGS_DATA_FIELD_VALUE = "VALUE";
const int32_t PERMISSION_EXCEPTION_CODE = 201;
const int32_t PERMISSION_DENIED_CODE = -2;
const int32_t USERID_HELPER_NUMBER = 100;
const int32_t PARAM_ERROR = 401;
const int32_t MEMORY_CODE = 14700104;

char* TransformFromString(std::string str, int32_t* ret)
{
    uint64_t len = str.size() + 1;
    char* retValue = static_cast<char *>(malloc(len));
    if (retValue == nullptr) {
        *ret = MEMORY_CODE;
        return nullptr;
    }
    *ret = memcpy_s(retValue, len, str.c_str(), len);
    if (*ret != 0) {
        *ret = MEMORY_CODE;
    }
    return retValue;
}

bool CheckoutStatus(int32_t status, int32_t* result)
{
    *result = 0;
    if (status >= 0) {
        return true;
    }
    if (status == PERMISSION_DENIED_CODE) {
        *result = PERMISSION_EXCEPTION_CODE;
    }
    return false;
}

std::string GetUserIdStr()
{
    std::vector<int32_t> tmpId;
    OHOS::AccountSA::OsAccountManager::QueryActiveOsAccountIds(tmpId);
    std::string tmpIdStr = "100";
    if (tmpId.size() > 0 && tmpId[0] >= 0) {
        tmpIdStr = std::to_string(tmpId[0]);
    } else {
        LOGE("userid is invalid, use id 100 instead");
    }
    return tmpIdStr;
}

bool IsTableNameInvalid(std::string tableName)
{
    if (tableName != "global" && tableName != "system" && tableName != "secure") {
        return true;
    }
    return false;
}

std::string GetStageUriStr(std::string tableName, std::string idStr, std::string keyStr)
{
    if (std::stoi(idStr) < USERID_HELPER_NUMBER) {
        idStr = "100";
    }
    if (tableName == "global") {
        std::string retStr =
            "datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=" + keyStr;
        return retStr;
    } else if (tableName == "system") {
        std::string retStr = "datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_" +
            idStr + "?Proxy=true&key=" + keyStr;
        return retStr;
    } else if (tableName == "secure") {
        std::string retStr = "datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_SECURE_" +
            idStr + "?Proxy=true&key=" + keyStr;
        return retStr;
    } else {
        // return global uri
        std::string retStr =
            "datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=" + keyStr;
        return retStr;
    }
}

std::string GetProxyUriStr(std::string tableName, std::string idStr)
{
    if (std::stoi(idStr) < USERID_HELPER_NUMBER) {
        idStr = "100";
    }
    if (tableName == "global") {
        std::string retStr = "datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true";
        return retStr;
    } else if (tableName == "system") {
        std::string retStr =
            "datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_" + idStr + "?Proxy=true";
        return retStr;
    } else {
        std::string retStr =
            "datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_SECURE_" + idStr + "?Proxy=true";
        return retStr;
    }
}

bool SetValueExecuteExt(SettingsInfo* info, const std::string setValue, int32_t* ret)
{
    if (info->dataShareHelper == nullptr) {
        LOGE("helper is null");
        *ret = 0;
        return false;
    }
    OHOS::DataShare::DataShareValuesBucket val;
    val.Put(SETTINGS_DATA_FIELD_KEYWORD, info->key);
    val.Put(SETTINGS_DATA_FIELD_VALUE, setValue);
    std::string tmpIdStr = GetUserIdStr();
    std::string strUri = GetStageUriStr(info->tableName, tmpIdStr, info->key);
    LOGD("Set uri : %{public}s, key: %{public}s", strUri.c_str(), info->key.c_str());
    OHOS::Uri uri(strUri);

    OHOS::DataShare::DataSharePredicates predicates;
    predicates.EqualTo(SETTINGS_DATA_FIELD_KEYWORD, info->key);

    int32_t retInt = info->dataShareHelper->Update(uri, predicates, val);
    LOGD("update ret: %{public}d", retInt);
    if (retInt <= 0) {
        retInt = info->dataShareHelper->Insert(uri, val);
        LOGD("insert ret: %{public}d", retInt);
    }
    return CheckoutStatus(retInt, ret);
}

std::shared_ptr<DataShare::DataShareHelper> GetDataShareHelper(
    OHOS::AbilityRuntime::Context* context, std::string tableName)
{
    std::shared_ptr<DataShare::DataShareHelper> dataShareHelper = nullptr;
    std::string tmpIdStr = GetUserIdStr();
    std::string strUri = "datashare:///com.ohos.settingsdata.DataAbility";
    std::string strProxyUri = GetProxyUriStr(tableName, tmpIdStr);
    OHOS::Uri proxyUri(strProxyUri);
    LOGD("<Ver-11-14> strProxyUri: %{public}s", strProxyUri.c_str());
    dataShareHelper = OHOS::DataShare::DataShareHelper::Creator(context->GetToken(), strProxyUri, strUri);
    return dataShareHelper;
}

bool Settings::SetValue(
    OHOS::AbilityRuntime::Context* context, const char* name, const char* value, const char* domainName, int32_t* ret)
{
    if (context == nullptr || name == nullptr || value == nullptr) {
        LOGE("Invalid parameter.");
        *ret = PARAM_ERROR;
        return false;
    }
    SettingsInfo info;
    info.key = name;
    if (domainName == nullptr) {
        info.tableName = "global";
    } else {
        info.tableName = domainName;
        if (IsTableNameInvalid(info.tableName)) {
            LOGE("Invalid domainName.");
            *ret = PARAM_ERROR;
            return false;
        }
    }
    info.dataShareHelper = GetDataShareHelper(context, info.tableName);
    return SetValueExecuteExt(&info, value, ret);
}

void QueryValue(SettingsInfo* info, OHOS::Uri uri)
{
    std::vector<std::string> columns;
    columns.push_back(SETTINGS_DATA_FIELD_VALUE);

    DataShare::DataSharePredicates predicates;
    predicates.EqualTo(SETTINGS_DATA_FIELD_KEYWORD, info->key);

    DataShare::DatashareBusinessError businessError;
    std::shared_ptr<DataShare::DataShareResultSet> resultset = nullptr;
    resultset = info->dataShareHelper->Query(uri, predicates, columns, &businessError);
    int32_t errorCode = businessError.GetCode();
    if (resultset == nullptr) {
        LOGD("Get value is empty");
        info->status = (errorCode == 0) ? -1 : errorCode;
        return;
    }
    int numRows = 0;
    resultset->GetRowCount(numRows);
    if (errorCode != 0) {
        info->status = errorCode;
    } else if (numRows <= 0) {
        info->status = -1;
    } else {
        std::string val;
        int32_t columnIndex = 0;
        resultset->GoToFirstRow();
        resultset->GetString(columnIndex, val);
        info->value = val;
        info->status = 0;
    }
    resultset->Close();
}

void GetValueExecuteExt(SettingsInfo* info)
{
    if (info->dataShareHelper == nullptr) {
        LOGE("dataShareHelper is empty");
        info->status = -1;
        return;
    }
    std::string tmpIdStr = GetUserIdStr();
    std::string strUri = GetStageUriStr(info->tableName, tmpIdStr, info->key);
    LOGD("Get uri : %{public}s, key: %{public}s", strUri.c_str(), info->key.c_str())
    OHOS::Uri uri(strUri);
    QueryValue(info, uri);
}

char* Settings::GetValue(
    OHOS::AbilityRuntime::Context* context, const char* name, const char* value, const char* domainName, int32_t* ret)
{
    if (context == nullptr || name == nullptr || value == nullptr) {
        LOGE("Invalid parameter.");
        *ret = PARAM_ERROR;
        return nullptr;
    }
    SettingsInfo info;
    if (domainName == nullptr) {
        info.tableName = "global";
    } else {
        info.tableName = domainName;
        if (IsTableNameInvalid(info.tableName)) {
            LOGE("Invalid domainName.");
            *ret = PARAM_ERROR;
            return nullptr;
        }
    }
    info.key = name;
    info.dataShareHelper = GetDataShareHelper(context, info.tableName);
    GetValueExecuteExt(&info);
    uint64_t len = info.value.size();
    if (len <= 0) {
        CheckoutStatus(info.status, ret);
        if (*ret == 0) {
            return TransformFromString(value, ret);
        }
        return nullptr;
    }
    return TransformFromString(info.value, ret);
}

char* Settings::GetUriSync(const char* name, const char* tableName)
{
    int32_t tempErrorCode = 0;
    if (name == nullptr) {
        LOGE("Invalid parameter.");
        return nullptr;
    }
    std::string uriStr = name;
    if (tableName == nullptr) {
        uriStr = "datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=" + uriStr;
        return TransformFromString(uriStr, &tempErrorCode);
    } else {
        std::string tmpIdStr = GetUserIdStr();
        std::string strUri = GetStageUriStr(tableName, tmpIdStr, uriStr);
        LOGD("Set uri : %{public}s, key: %{public}s", strUri.c_str(), uriStr.c_str());
        return TransformFromString(strUri, &tempErrorCode);
    }
}
} // namespace CJSettings
} // namespace CJSystemapi
} // namespace OHOS