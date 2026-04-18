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
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { MoreBundleListController } from '@ohos/settings.application/src/main/ets/controller/MoreBundleListController';
import { MoreAppLoadingComponent } from '@ohos/settings.application/src/main/ets/view/MoreAppLoadingComponent';

@Builder
function loadingBuilder(param: object): void {
  MoreAppLoadingComponent();
}

function customPage(): SettingPageModel {
  return {
    id: 'MoreApplication',
    url: NavEntryKey.MORE_APPLICATION_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.more_application_text'),
    groups: [
      {
        id: 'MoreApplicationGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
        compControl: new MoreBundleListController(),
      },
      {
        id: 'MoreLoadingGroup',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(loadingBuilder),
      }
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.MORE_APPLICATION_ENTRY, {
  configGenerator: customPage,
});