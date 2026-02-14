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
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { ItemResultType, ItemType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { settingPageBuilder } from '@ohos/settings.common/src/main/ets/framework/view/SettingPage';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { WifiUtils, WLAN_SCAN_KEY } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import { WifiScanController } from '@ohos/settings.wifi/src/main/ets/controller/new/WifiScanController';

function customPage(): SettingPageModel {
  return {
    id: 'wifi_precision',
    url: NavEntryKey.WIFI_PRECISION_MENU_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: ResourceUtil.getStringSync($r('app.string.wifi_precision_title')),
    groups: [
      {
        id: 'WlanConfig',
        type: GroupType.GROUP_TYPE_STANDARD,
        footer: {
          id: 'wlan_scan_content',
          content: $r('app.string.wlan_scan_content'),
          style: {
            fontSize: $r('sys.float.Body_S'),
            fontColor: $r('sys.color.font_secondary'),
            fontWeight: FontWeight.Regular,
          }
        },
        items: [
          {
            id: WLAN_SCAN_KEY,
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.wlan_scan_title') },
            result: {
              type: ItemResultType.RESULT_TYPE_TOGGLE,
              result: {
                state: WifiUtils.getScanAlwaysAllowed(),
              }
            },
            compControl: new WifiScanController(),
          }
        ],
      }
    ],
  };
}

// 提高精准度界面
PageLoader.load(NavEntryKey.WIFI_PRECISION_MENU_ENTRY, {
  configGenerator: customPage,
  pageBuilder: wrapBuilder(settingPageBuilder),
});