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
import { UninstallUnusedAppController } from '@ohos/settings.storage/src/main/ets/controller/UninstallUnusedAppController';
import { AppUninstallComponent } from '@ohos/settings.storage/src/main/ets/components/AppUninstallComponent';

@Builder
export function deleteComponentBuilder(param: object): void {
  AppUninstallComponent();
}

function customPage(): SettingPageModel {
  let controller = new UninstallUnusedAppController();
  return {
    id: 'StorageUninstallApp',
    url: NavEntryKey.STORAGE_UNINSTALL,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.uninstall_unusual_apps'),
    groups: [
      {
        id: 'AppGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
        compControl: controller,
      }
    ],
    stickBottomContent: {
      id: 'SaveProxyInfo',
      builder: wrapBuilder(deleteComponentBuilder),
    },
  }
}

PageLoader.load(NavEntryKey.STORAGE_UNINSTALL, {
  configGenerator: customPage,
});