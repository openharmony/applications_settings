/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

#ifndef NAPI_SETTINGS_OBSERVER_H
#define NAPI_SETTINGS_OBSERVER_H

#include "napi_settings.h"

#include "napi/native_api.h"
#include "napi/native_common.h"
#include "napi/native_node_api.h"
#include "uri.h"

#include "data_ability_observer_interface.h"
#include "data_ability_observer_stub.h"


namespace OHOS {
namespace Settings {

class SettingsObserver : public OHOS::AAFwk::DataAbilityObserverStub {
public:
    explicit SettingsObserver(AsyncCallbackInfo* callback) : cbInfo(callback) {}
    ~SettingsObserver() {}
    void OnChange();
    AsyncCallbackInfo* cbInfo;
    std::shared_ptr<OHOS::DataShare::DataShareHelper> dataShareHelper;
};

napi_value npai_settings_register_observer(napi_env env, napi_callback_info info);
napi_value npai_settings_unregister_observer(napi_env env, napi_callback_info info);

}
}

#endif