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

#include "settings.h"
#include "settings_log.h"
#include "os_account_manager.h"
#include "values_bucket.h"
#include "datashare_business_error.h"

// #include "../napi_settings_log.h"

namespace OHOS {
namespace Settings {
const std::string MIN_USER_ID = "100";
const std::string SETTINGS_DATA_FIELD_KEYWORD = "KEYWORD";
const std::string SETTINGS_DATA_FIELD_VALUE = "VALUE";

std::map<std::string, sptr<NormalSettingObserver>> settingDataObserverMap_;
std::map<std::string, sptr<NormalSettingObserver>> settingUserDataObserverMap_;
std::map<std::string, sptr<NormalSettingObserver>> settingUserSecureObserverMap_;
std::mutex observerMapMutex_;

NormalSettingObserver::NormalSettingObserver() = default;
NormalSettingObserver::~NormalSettingObserver() = default;
/*
void NormalSettingObserver::OnChange()
{
    SETTING_LOG_INFO("DataShare register observer OnChange start");
    if (observerCallback_ != nullptr) {
        observerCallback_();
    }
    SETTING_LOG_INFO("DataShare register observer OnChange done");
    return;
}

void NormalSettingObserver::SetObserverCallback(ObserverCallback &observerCallback)
{
    observerCallback_ = observerCallback;
    return;
}
*/
void NormalSettingObserver::OnChange()
{
    SETTING_LOG_INFO("DataShare register observer OnChange start");
    std::string val = "";
    val = SettingsGetValue(observerKey, observerTableName);
    if (observerCallback_ != nullptr) {
        observerCallback_(val);
    }
    SETTING_LOG_INFO("DataShare register observer OnChange done");
    return;
}

void NormalSettingObserver::SetObserverCallback(ObserverCallback &observerCallback,
    const std::string &key, const std::string &tableName)
{
    observerCallback_ = observerCallback;
    observerKey = key;
    observerTableName = tableName;
    return;
}

sptr<NormalSettingObserver> GetSettingObserver(const std::string &key, const std::string &tableName)
{
    SETTING_LOG_INFO("GetSettingObserver start");
    std::map<std::string, sptr<NormalSettingObserver>> *tmpMap = nullptr;
    
    if (tableName == DEVICE_SHARE_TABLE) {
        tmpMap = &settingDataObserverMap_;
    } else if (tableName == USER_PROPERTY_TABLE) {
        tmpMap = &settingUserDataObserverMap_;
    } else if (tableName == USER_SECURITY_TABLE) {
        tmpMap = &settingUserSecureObserverMap_;
    } else {
        SETTING_LOG_ERROR("GetSettingObserver table is error, key %{public}s, table %{public}s",
             key.c_str(), tableName.c_str());
        return nullptr;
    }
    std::lock_guard<std::mutex> lockGuard(observerMapMutex_);
    if (tmpMap->find(key) != tmpMap->end()) {
        return tmpMap->find(key)->second;
    }
    SETTING_LOG_INFO("GetSettingObserver table is null, key %{public}s, table %{public}s",
        key.c_str(), tableName.c_str());
    return nullptr;
}

void SetSettingObserver(const std::string &key, const std::string &tableName, sptr<NormalSettingObserver> observer)
{
    SETTING_LOG_INFO("SetSettingObserver start");
    if (tableName == DEVICE_SHARE_TABLE) {
        std::lock_guard<std::mutex> lockGuard(observerMapMutex_);
        settingDataObserverMap_[key] = observer;
    } else if (tableName == USER_PROPERTY_TABLE) {
        std::lock_guard<std::mutex> lockGuard(observerMapMutex_);
        settingUserDataObserverMap_[key] = observer;
    } else if (tableName == USER_SECURITY_TABLE) {
        std::lock_guard<std::mutex> lockGuard(observerMapMutex_);
        settingUserSecureObserverMap_[key] = observer;
    } else {
        SETTING_LOG_ERROR("set observer error, key %{public}s, table %{public}s",
            key.c_str(), tableName.c_str());
    }
    return;
}

void ReleaseSettingObserver(const std::string &key, const std::string &tableName)
{
    SETTING_LOG_INFO("ReleaseSettingObserver start");
    if (tableName == DEVICE_SHARE_TABLE) {
        std::lock_guard<std::mutex> lockGuard(observerMapMutex_);
        settingDataObserverMap_.erase(key);
    } else if (tableName == USER_PROPERTY_TABLE) {
        std::lock_guard<std::mutex> lockGuard(observerMapMutex_);
        settingUserDataObserverMap_.erase(key);
    } else if (tableName == USER_SECURITY_TABLE) {
        std::lock_guard<std::mutex> lockGuard(observerMapMutex_);
        settingUserSecureObserverMap_.erase(key);
    } else {
        SETTING_LOG_ERROR("release observer error, key %{public}s, table %{public}s",
            key.c_str(), tableName.c_str());
    }
    return;
}

std::string GetSettingUserId()
{
    std::vector<int> tmpId;
    OHOS::AccountSA::OsAccountManager::QueryActiveOsAccountIds(tmpId);
    std::string tmpIdStr = MIN_USER_ID;
    if (tmpId.size() > 0) {
        tmpIdStr = std::to_string(tmpId[0]);
    } else {
        SETTING_LOG_ERROR("userid is invalid, user id 100 instead");
    }
    if (std::stoi(tmpIdStr) < std::stoi(MIN_USER_ID)) {
        tmpIdStr = MIN_USER_ID;
    }
    return tmpIdStr;
}

std::string GetSettingUri(const std::string &key, const std::string &tableName)
{
    std::string curUri = "";
    std::string curUserId = GetSettingUserId();
    SETTING_LOG_INFO("user id is %{public}s", curUserId.c_str());
    if (tableName == USER_SECURITY_TABLE) {
        curUri = "datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_SECURE_" +
            curUserId + "?Proxy=true&key=" + key;
    } else if (ableName == DEVICE_SHARE_TABLE) {
        curUri = "datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=" + key;
    } else if (tableName == USER_PROPERTY_TABLE) {
        curUri = "datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_" +
            curUserId + "?Proxy=true&key=" + key;
    } else {
        SETTING_LOG_ERROR("uri is invalid, with table %{public}s", tableName.c_str());
    }
    return curUri;
}

std::shared_ptr<DataShare::DataShareHelper> SettingCreateDataShareHelper(const std::string &url)
{
    SETTING_LOG_INFO("DataShareManager CreateDataShareHelper start");
    DataShare::CreateOptions options;
    options.isProxy_ = true;
    return DataShare::DataShareHelper::Creator(url, options);
}

void SettingsRegisterObserver(const std::string &key, const std::string &tableName,
    NormalSettingObserver::ObserverCallback &observerCallback)
{
    SETTING_LOG_INFO("setting RegisterObserver observer start, key %{public}s, table %{public}s",
        key.c_str(), tableName.c_str());
    sptr<NormalSettingObserver> observer = GetSettingObserver(key, tableName);
    if (observer != nullptr) {
        SETTING_LOG_ERROR("observer is already registered with key %{public}s, table %{public}s",
            key.c_str(), tableName.c_str());
        return;
    }
    std::string tmpUri = GetSettingUri(key, tableName);
    if (tmpUri == "") {
        SETTING_LOG_ERROR("register observer failed, uri is empty");
        return;
    }
    std::shared_ptr<DataShare::DataShareHelper> dataShareHelper = SettingCreateDataShareHelper(tmpUri);
    if (dataShareHelper == nullptr) {
        SETTING_LOG_ERROR("register observer failed, dataShareHelper is null");
        return;
    }
    sptr<NormalSettingObserver> newObserver(new NormalSettingObserver());
    observer = newObserver;
    if (observer == nullptr) {
        SETTING_LOG_ERROR("register observer failed, new observer is null");
        return;
    }
    // observer->SetObserverCallback(observerCallback);
    observer->SetObserverCallback(observerCallback, key, tableName);
    dataShareHelper->RegisterObserver(OHOS::Uri(tmpUri), observer);
    dataShareHelper->Release();
    SetSettingObserver(key, tableName, observer);
    SETTING_LOG_INFO("setting RegisterObserver success key %{public}s, table %{public}s",
        key.c_str(), tableName.c_str());
    return;
}

void SettingsUnregisterObserver(const std::string &key, const std::string &tableName)
{
    SETTING_LOG_INFO("setting unregister observer start, key %{public}s, table %{public}s",
        key.c_str(), tableName.c_str());
    sptr<NormalSettingObserver> observer = GetSettingObserver(key, tableName);
    if (observer == nullptr) {
        SETTING_LOG_ERROR("observer is already unregistered with key %{public}s, table %{public}s",
            key.c_str(), tableName.c_str());
        return;
    }
    std::string tmpUri = GetSettingUri(key, tableName);
    if (tmpUri == "") {
        SETTING_LOG_ERROR("unregister observer failed, uri is empty");
        return;
    }
    std::shared_ptr<DataShare::DataShareHelper> dataShareHelper = SettingCreateDataShareHelper(tmpUri);
    if (dataShareHelper == nullptr) {
        SETTING_LOG_ERROR("unregister observer failed, dataShareHelper is null");
        return;
    }
    
    dataShareHelper->UnregisterObserver(OHOS::Uri(tmpUri), observer);
    dataShareHelper->Release();
    ReleaseSettingObserver(key, tableName);
    SETTING_LOG_INFO("setting unregister observer success key %{public}s, table %{public}s",
        key.c_str(), tableName.c_str());
    return;
}

bool SettingsSetValue(const std::string &key, const std::string &tableName, const std::string &val)
{
    SETTING_LOG_INFO("set value start, key %{public}s, table %{public}s",
        key.c_str(), tableName.c_str());
    std::string tmpUri = GetSettingUri(key, tableName);
    if (tmpUri == "") {
        SETTING_LOG_ERROR("set value failed, uri is empty");
        return false;
    }
    std::shared_ptr<DataShare::DataShareHelper> dataShareHelper = SettingCreateDataShareHelper(tmpUri);
    if (dataShareHelper == nullptr) {
        SETTING_LOG_ERROR("set value failed, dataShareHelper is null");
        return false;
    }
    
    OHOS::DataShare::DataShareValueBucket bucketVal;
    bucketVal.Put(SETTINGS_DATA_FIELD_KEYWORD, key);
    bucketVal.Put(SETTINGS_DATA_FIELD_VALUE, val);
    
    OHOS::DataShare::DataSharePredicates predicates;
    predicates.EqualTo(SETTINGS_DATA_FIELD_KEYWORD, key);
    
    // update first, if failed, then retry to insert
    OHOS::Uri uri(tmpUri);
    int retInt = dataShareHelper->Update(uri, predicates, bucketVal);
    if (retInt <= 0) {
        SETTING_LOG_INFO("update failed, next insert, ret: %{public}d", retInt);
        retInt = dataShareHelper->Insert(uri, bucketVal);
        if (retInt <= 0) {
            SETTING_LOG_ERROR("insert failed, ret: %{public}d", retInt);
            return false;
        }
    }
    SETTING_LOG_INFO("set value success, key %{public}s", key.c_str());
    return true;
}

std::string SettingsGetValue(const std::string &key, const std::string &tableName)
{
    SETTING_LOG_INFO("get value start, key %{public}s, table %{public}s",
        key.c_str(), tableName.c_str());
    std::string val = "";
    std::string tmpUri = GetSettingUri(key, tableName);
    if (tmpUri == "") {
        SETTING_LOG_ERROR("get value failed, uri is empty");
        return val;
    }
    std::shared_ptr<DataShare::DataShareHelper> dataShareHelper = SettingCreateDataShareHelper(tmpUri);
    if (dataShareHelper == nullptr) {
        SETTING_LOG_ERROR("get value failed, dataShareHelper is null");
        return val;
    }
    
    int numRows = 0;
    OHOS::Uri uri(tmpUri);
    std::vector<std::string> columns;
    columns.push_back(SETTINGS_DATA_FIELD_VALUE);
    
    OHOS::DataShare::DataSharePredicates predicates;
    predicates.EqualTo(SETTINGS_DATA_FIELD_KEYWORD, key);
    
    OHOS::DataShare::DatashareBusinessError businessError;
    std::shared_ptr<OHOS::DataShare::DataShareResultSet> resultSet = nullptr;
    resultSet = dataShareHelper->Query(uri, predicates, columns, &businessError);
    if (resultSet == nullptr) {
        SETTING_LOG_ERROR("get value failed, resultSet is null");
        return val;
    }
    resultSet->GetRowCount(numRows);
    if (businessError.GetCode() != 0 || numRows <= 0) {
        SETTING_LOG_ERROR("get value failed, numRows %{public}d, error code %{public}d",
            numRows, businessError.GetCode());
        resultSet->Close();
        return val;
    }
    int32_t columnIndex = 0;
    resultSet->GoToFirstRow();
    resultSet->GetString(columnIndex, val);
    resultSet->Close();
    SETTING_LOG_INFO("get value success, key %{public}s", key.c_str());
    return val;
}

}
}