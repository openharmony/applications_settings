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

#include "napi_bundle_util.h"

namespace OHOS {
namespace Settings {
std::string BundleUtil::versionName = "";
std::string BundleUtil::bundleName = "";

void BundleUtil::InitCurrentBundleInfo()
{
    if (!bundleName.empty() || !versionName.empty()) {
        SETTING_LOG_INFO("bundleInfo is already init");
        return;
    }
    sptr<ISystemAbilityManager> abilityManager = SystemAbilityManagerClient::GetInstance().GetSystemAbilityManager();
    if (abilityManager == nullptr) {
        SETTING_LOG_ERROR("abilityManager error");
        return;
    }
    auto bundleObj = abilityManager->GetSystemAbility(BUNDLE_MGR_SERVICE_SYS_ABILITY_ID);
    if (bundleObj == nullptr) {
        SETTING_LOG_ERROR("bundleObj error");
        return;
    }
    auto bundleMgrProxy = iface_cast<AppExecFwk::IBundleMgr>(bundleObj);
    if (bundleMgrProxy == nullptr) {
        SETTING_LOG_ERROR("bundleMgrProxy error");
        return;
    }
    AppExecFwk::BundleInfo bundleInfo;
    ErrCode ret = bundleMgrProxy->GetBundleInfoForSelf(AppExecFwk::BundleFlag::GET_BUNDLE_DEFAULT, bundleInfo);
    if (ret != ERR_OK) {
        SETTING_LOG_ERROR("get bundleInfo error");
        return;
    }
    versionName = bundleInfo.versionName;
    bundleName = bundleInfo.name;
}

std::string BundleUtil::GetCurrentBundleName()
{
    InitCurrentBundleInfo();
    return bundleName;
}

std::string BundleUtil::GetCurrentVersionName()
{
    InitCurrentBundleInfo();
    return versionName;
}
}
}