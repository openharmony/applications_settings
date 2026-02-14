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

import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { ItemDetailType, ItemType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { ResetFactoryGroupController } from './Reset/ResetFactoryGroupController';

/* instrument ignore file */
function customPage(): SettingPageModel {
  return {
    id: 'reset_settings',
    url: NavEntryKey.RESET_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.reset_settings_title'),
    groups: [
      {
        id: 'reset_net_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'reset_net_settings',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.reset_net_title') },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: NavEntryKey.RESET_NET,
            },
          }
        ]
      },
      {
        id: 'factory_reset_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'reset_factory_settings',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: {
              content: DeviceUtil.isDevicePad() ? $r('app.string.reset_factory_title_pc') :
              $r('app.string.reset_factory_title'),
            },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: NavEntryKey.RESET_FACTORY,
            },
          }
        ],
        visible: false,
        compControl: new ResetFactoryGroupController()
      }
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.RESET_ENTRY, {
  configGenerator: customPage,
});