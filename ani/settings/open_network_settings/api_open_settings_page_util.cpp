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

#include "api_open_settings_page_util.h"

namespace OHOS {
namespace Settings {
const std::string SettingsPageUrl::INPUT_PAGE = "set_input";
const std::string SettingsPageUrl::INPUT_DETAIL_PAGE = "other_input_detail_settings";

const std::string DeviceType::PHONE = "phone";
const std::string DeviceType::TABLET = "tablet";

const static std::unordered_set<std::string> supportedPageForPhoneList = {
    SettingsPageUrl::INPUT_PAGE,
    SettingsPageUrl::INPUT_DETAIL_PAGE
};

const static std::unordered_set<std::string> supportedPageForTabletList = {
    SettingsPageUrl::INPUT_PAGE,
    SettingsPageUrl::INPUT_DETAIL_PAGE
};

const static std::map<std::string, std::unordered_set<std::string>> supportedPageForDeviceMap = {
    {DeviceType::PHONE, supportedPageForPhoneList},
    {DeviceType::TABLET, supportedPageForTabletList}
};

bool IsPageSupportJump(const std::string &deviceType, const std::string &pageUri)
{
    SETTING_LOG_INFO("isPageSupportJump, device is %{public}s, target page is %{public}s",
        deviceType.c_str(), pageUri.c_str());
    auto iter = supportedPageForDeviceMap.find(deviceType);
    if (iter == supportedPageForDeviceMap.end()) {
        SETTING_LOG_ERROR("target device is not support");
        return false;
    }
    const auto &supportedList = iter->second;
    return supportedList.find(pageUri) != supportedList.end();
}
}
}