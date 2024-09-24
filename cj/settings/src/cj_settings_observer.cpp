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

#include "cj_settings_observer.h"
#include <map>
#include <mutex>
#include "cj_lambda.h"
#include "cj_settings.h"
#include "cj_settings_log.h"
#include "cj_settings_utils.h"

namespace OHOS {
namespace CJSystemapi {
namespace CJSettings {

std::map<std::string, sptr<SettingsObserver>> g_observerMap;
std::mutex g_observerMapMutex;

void SettingsObserver::OnChange()
{
    if (this->cjCallback == nullptr || this->toBeDelete) {
        return;
    }
    this->cjCallback();
    return;
}

bool RegisterKeyObserver(
    OHOS::AbilityRuntime::Context* context, const char* name, const char* domainName, int64_t observer)
{
    if (context == nullptr || name == nullptr || domainName == nullptr) {
        LOGE("Invalid parameter.");
        return false;
    }
    std::string key = name;
    std::string tableName = domainName;
    std::lock_guard<std::mutex> lockGuard(g_observerMapMutex);
    if (g_observerMap.find(key) != g_observerMap.end() && g_observerMap[key] != nullptr) {
        LOGE("%{public}s, already registered.", key.c_str());
        return false;
    }
    auto dataShareHelper = GetDataShareHelper(context, tableName);
    if (dataShareHelper == nullptr) {
        return false;
    }
    std::string strUri = GetStageUriStr(tableName, GetUserIdStr(), key);
    OHOS::Uri uri(strUri);
    sptr<SettingsObserver> settingsObserver = sptr<SettingsObserver>(new (std::nothrow)SettingsObserver());
    auto func = reinterpret_cast<void(*)(void)>(observer);
    settingsObserver->cjInfo.key = key;
    settingsObserver->cjInfo.tableName = tableName;
    settingsObserver->cjCallback = CJLambda::Create(func);
    g_observerMap[key] = settingsObserver;
    dataShareHelper->RegisterObserver(uri, settingsObserver);
    dataShareHelper->Release();
    return true;
}

bool UnregisterKeyObserver(
    OHOS::AbilityRuntime::Context* context, const char* name, const char* domainName)
{
    if (context == nullptr || name == nullptr || domainName == nullptr) {
        LOGE("Invalid parameter.");
        return false;
    }
    std::string key = name;
    std::string tableName = domainName;
    std::lock_guard<std::mutex> lockGuard(g_observerMapMutex);
    if (g_observerMap.find(key) == g_observerMap.end()) {
        return false;
    }
    if (g_observerMap[key] == nullptr) {
        g_observerMap.erase(key);
        return false;
    }
    auto dataShareHelper = GetDataShareHelper(context, tableName);
    if (dataShareHelper == nullptr) {
        return false;
    }
    std::string strUri = GetStageUriStr(tableName, GetUserIdStr(), key);
    OHOS::Uri uri(strUri);
    dataShareHelper->UnregisterObserver(uri, g_observerMap[key]);
    dataShareHelper->Release();
    g_observerMap[key]->toBeDelete = true;
    g_observerMap[key] = nullptr;
    g_observerMap.erase(key);
    return true;
}
}
}
}
