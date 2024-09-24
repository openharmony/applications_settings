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

#ifndef OHOS_CJ_SETTINGS_OBSERVER_H
#define OHOS_CJ_SETTINGS_OBSERVER_H

#include <functional>
#include "cj_settings_utils.h"
#include "data_ability_observer_interface.h"
#include "data_ability_observer_stub.h"

namespace OHOS {
namespace CJSystemapi {
namespace CJSettings {

class SettingsObserver : public OHOS::AAFwk::DataAbilityObserverStub {
public:
    explicit SettingsObserver() {}
    ~SettingsObserver() {}
    void OnChange();
    SettingsInfo cjInfo;
    bool toBeDelete = false;
    std::function<void(void)> cjCallback;
};

bool RegisterKeyObserver(OHOS::AbilityRuntime::Context* context,
    const char* name, const char* domainName, int64_t observer);
bool UnregisterKeyObserver(OHOS::AbilityRuntime::Context* context,
    const char* name, const char* domainName);
} // namespace CJSettings
} // namespace CJSystemapi
} // namespace OHOS
#endif // OHOS_CJ_SETTINGS_OBSERVER_H