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

#ifndef OHOS_CJ_SETTINGS_UTILS_H
#define OHOS_CJ_SETTINGS_UTILS_H

#include <memory>
#include <string>
#include "context.h"
#include "datashare_helper.h"

namespace OHOS {
namespace CJSystemapi {
namespace CJSettings {

struct SettingsInfo {
    std::string key;
    std::string value;
    std::string uri;
    std::string tableName;
    int32_t status = 0;
    std::shared_ptr<OHOS::DataShare::DataShareHelper> dataShareHelper = nullptr;
};
} // namespace CJSettings
} // namespace CJSystemapi
} // namespace OHOS
#endif // OHOS_CJ_SETTINGS_UTILS_H