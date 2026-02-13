/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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

import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageLoader, PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { CustomInformation } from './view/CustomInformationComponent';

@Builder function customInformationBuilder(param: object): void {
  CustomInformation({ params: (param as PageParams)?.param as PushParam });
}

function customPage(): SettingPageModel {
  return {
    id: 'EnterpriseCustomInformation',
    url: NavEntryKey.ENTERPRISE_CUSTOM_INFO_ENTRY,
    type: PageType.PAGE_TYPE_CUSTOM,
    title: 'EnterpriseCustomInformation',
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.ENTERPRISE_CUSTOM_INFO_ENTRY, {
  configGenerator: customPage,
  pageBuilder: wrapBuilder(customInformationBuilder),
});