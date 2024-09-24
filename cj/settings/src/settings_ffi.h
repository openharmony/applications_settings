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

#ifndef OHOS_SETTINGS_FFI_H
#define OHOS_SETTINGS_FFI_H

#include <cstdint>
#include "cj_common_ffi.h"
#include "context.h"

extern "C" {
    FFI_EXPORT bool FfiSettingsSetValue(
        OHOS::AbilityRuntime::Context* context,
        const char* name, const char* value, const char* domainName, int32_t* ret);
    FFI_EXPORT char* FfiSettingsGetValue(
        OHOS::AbilityRuntime::Context* context,
        const char* name, const char* value, const char* domainName, int32_t* ret);
    FFI_EXPORT bool FfiSettingsRegisterKeyObserver(
        OHOS::AbilityRuntime::Context* context, const char* name, const char* domainName, int64_t observer);
    FFI_EXPORT bool FfiSettingsUnregisterKeyObserver(
        OHOS::AbilityRuntime::Context* context, const char* name, const char* domainName);
    FFI_EXPORT char* FfiSettingsGetUriSync(const char* name, const char* tableName);
}

#endif // OHOS_SETTINGS_FFI_H
