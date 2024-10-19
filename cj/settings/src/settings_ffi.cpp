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

#include "settings_ffi.h"
#include "cj_settings.h"
#include "cj_settings_observer.h"

namespace OHOS {
namespace CJSystemapi {
namespace CJSettings {

extern "C" {
bool FfiSettingsSetValue(OHOS::AbilityRuntime::Context* context,
    const char* name, const char* value, const char* domainName, int32_t* ret)
{
    return Settings::SetValue(context, name, value, domainName, ret);
}

char* FfiSettingsGetValue(OHOS::AbilityRuntime::Context* context,
    const char* name, const char* value, const char* domainName, int32_t* ret)
{
    return Settings::GetValue(context, name, value, domainName, ret);
}

bool FfiSettingsRegisterKeyObserver(OHOS::AbilityRuntime::Context* context,
    const char* name, const char* domainName, int64_t observer)
{
    return RegisterKeyObserver(context, name, domainName, observer);
}

bool FfiSettingsUnregisterKeyObserver(OHOS::AbilityRuntime::Context* context,
    const char* name, const char* domainName)
{
    return UnregisterKeyObserver(context, name, domainName);
}

char* FfiSettingsGetUriSync(const char* name, const char* tableName)
{
    return Settings::GetUriSync(name, tableName);
}
}
} // namespace CJSettings
} // namespace CJSystemapi
} // namespace OHOS