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

#ifndef NORMAL_DATASHARE_SETTINGS_H
#define NORMAL_DATASHARE_SETTINGS_H

#include <map>
#include "datashare_helper.h"
#include "data_ability_observer_stub.h"

namespace OHOS {
namespace Settings {

class NormalSettingObserver : public AAFwk::DataAbilityObserverStub {
public:
    NormalSettingObserver();
    ~NormalSettingObserver() override;
    void OnChange() override;
    
    // using ObserverCallback = std::function<void()>;
    // void SetObserverCallback(ObserverCallback &observerCallback);
    using ObserverCallback = std::function<void(std::string)>;
    void SetObserverCallback(ObserverCallback &observerCallback, const std::string &key, const std::string &tableName);

private:
    ObserverCallback observerCallback_ = nullptr;
    std::string observerKey;
    std::string observerTableName;
};

#define DEVICE_SHARE_TABLE "global"
#define USER_PROPERTY_TABLE "system"
#define USER_SECURITY_TABLE "secure"

void SettingsRegisterObserver(const std::string &key, const std::string &tableName,
    NormalSettingObserver::ObserverCallback &observerCallback);
void SettingsUnregisterObserver(const std::string &key, const std::string &tableName);
bool SettingsSetValue(const std::string &key, const std::string &tableName, const std::string &val);
std::string SettingsGetValue(const std::string &key, const std::string &tableName);

} // namespace Settings
} // namespace OHOS

#endif // NORMAL_DATASHARE_SETTINGS_H