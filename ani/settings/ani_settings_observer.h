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

#ifndef ANI_SETTINGS_OBSERVER_H
#define ANI_SETTINGS_OBSERVER_H

#include "ani_settings.h"
#include "uri.h"
#include "data_ability_observer_interface.h"
#include "data_ability_observer_stub.h"

namespace OHOS {
namespace Settings {

class SettingsObserver : public OHOS::AAFwk::DataAbilityObserverStub {
public:
    explicit SettingsObserver(ani_vm *vm, ani_ref callbackRef, AsyncCallbackInfo *callback)
        : vm_(vm), callback_(callbackRef), cbInfo(callback)
    {}
    ~SettingsObserver();
    void OnChange();
    ani_vm *vm_;
    ani_ref callback_;
    AsyncCallbackInfo *cbInfo;
    static void EnvObserver(void *arg);
    bool toBeDelete = false;
};

ani_boolean ani_settings_register_observer(
    ani_env *env, ani_object context, ani_string name, ani_string domainName, ani_object observer);
ani_boolean ani_settings_unregister_observer(ani_env *env, ani_object context, ani_string name, ani_string domainName);

}  // namespace Settings
}  // namespace OHOS

#endif