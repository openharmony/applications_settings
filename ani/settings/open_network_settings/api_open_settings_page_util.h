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

#ifndef NAPI_OPEN_SETTINGS_PAGE_UTIL_H
#define NAPI_OPEN_SETTINGS_PAGE_UTIL_H

#include <map>
#include <string>
#include <unordered_set>
#include "../ani_settings_log.h"

namespace OHOS {
namespace Settings {
class SettingsPageUrl {
public:
    static const std::string INPUT_PAGE;
    static const std::string INPUT_DETAIL_PAGE;
};

class DeviceType {
public:
    static const std::string PHONE;
    static const std::string TABLET;
};

bool IsPageSupportJump(const std::string &deviceType, const std::string &pageUri);
}
}

#endif