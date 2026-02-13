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
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SimUtils } from '@ohos/settings.common/src/main/ets/utils/SimUtils';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  BatteryStatusController,
  BatteryLevelController,
  IpAddressController,
  WlanMacController,
  BluetoothAddressController,
  PowerOnDurationController,
} from '@ohos/settings.aboutdevice/src/main/ets/controller/StatusInfoController';
import { AboutDeviceUtils } from '@ohos/settings.aboutdevice/src/main/ets/utils/AboutDeviceUtils';
import { NetworkEntryController } from './conroller/NetworkController';

function customPage(): SettingPageModel {
  return {
    id: 'StatusInfo',
    url: NavEntryKey.STATUS_INFO_SETTING,
    type: PageType.PAGE_TYPE_STANDARD,
    title: ResourceUtil.getStringSync($r('app.string.status_information')),
    groups: [
      {
        id: 'battery_information_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'battery_status',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.battery_status') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
            compControl: new BatteryStatusController(),
          },
          {
            id: 'battery_level',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.battery_level') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
            compControl: new BatteryLevelController(),
          }
        ]
      },
      {
        id: 'status_information_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'network_information_settings',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.network_information') },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: NavEntryKey.NETWORK_INFO_SETTING,
            },
            compControl: new NetworkEntryController(),
            needHide: () => !SimUtils.isSupportSim()
          },
          {
            id: 'ip_address',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.ip_address') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
            compControl: new IpAddressController(),
          },
          {
            id: 'WLAN_MAC',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.wlan_mac') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
            compControl: new WlanMacController(),
          },
          {
            id: 'bluetooth_address',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.bluetooth_address') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
            compControl: new BluetoothAddressController(),
          },
          {
            id: 'hardware_version',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.hardware_version') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: AboutDeviceUtils.getHardwareModel() } },
          }
        ]
      },
      {
        id: 'boot_information_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'power_on_duration',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.power_on_duration') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
            compControl: new PowerOnDurationController(),
          },
        ]
      },
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.STATUS_INFO_SETTING, {
  configGenerator: customPage,
});