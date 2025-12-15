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

#include "include/napi_sys_event_util.h"

namespace OHOS {
namespace Settings {
const std::string NAME_ID = "PNAMEID";
const std::string VERSION_NAME = "PVERSIONID";
const std::string TARGET_PAGE = "TARGET_PAGE";
const std::string RESULT = "RESULT";

void ReportSysEvent(const std::string &page, bool result)
{
    if (page.empty()) {
        SETTING_LOG_ERROR("target page is invalid");
        return;
    }
    std::string bundleName = BundleUtil::GetCurrentBundleName();
    std::string versionName = BundleUtil::GetCurrentVersionName();
    HiSysEventWrite(HiviewDFX::HiSysEvent::Domain::SETTINGS_APP, "OPEN_MODAL_SETTINGS_PAGE",
        OHOS::HiviewDFX::HiSysEvent::EventType::BEHAVIOR,
        NAME_ID, bundleName,
        VERSION_NAME, versionName,
        TARGET_PAGE, page,
        RESULT, result);
}
}
}