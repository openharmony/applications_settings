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

#ifndef OHOS_CJ_SETTINGS_H
#define OHOS_CJ_SETTINGS_H

#include <cstdint>
#include <string>
#include "context.h"
#include "datashare_helper.h"

namespace OHOS {
namespace CJSystemapi {
namespace CJSettings {

class Settings {
public:
    static bool SetValue(OHOS::AbilityRuntime::Context* context,
        const char* name, const char* value, const char* domainName, int32_t* ret);
    static char* GetValue(OHOS::AbilityRuntime::Context* context,
        const char* name, const char* value, const char* domainName, int32_t* ret);
    static char* GetUriSync(const char* name, const char* tableName);
};
std::shared_ptr<DataShare::DataShareHelper> GetDataShareHelper(
    OHOS::AbilityRuntime::Context* context, std::string tableName);
std::string GetUserIdStr();
std::string GetStageUriStr(std::string tableName, std::string idStr, std::string keyStr);
} // namespace CJSettings
} // namespace CJSystemapi
} // namespace OHOS

#endif // OHOS_CJ_SETTINGS_H
