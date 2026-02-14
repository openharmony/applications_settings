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

import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { ItemResultType, ItemType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';

import { BluetoothSwitchController } from '@ohos/settings.bluetooth/src/main/ets/controller/BluetoothSwitchController';
import { availableDeviceHeader, oppAvailableDeviceHeader } from '@ohos/settings.bluetooth/src/main/ets/view/CustomBuilder';
import { OppBondedDeviceController } from '@ohos/settings.bluetooth/src/main/ets/controller/OppBondedDeviceController';
import { OppAvailableDeviceController } from '@ohos/settings.bluetooth/src/main/ets/controller/OppAvailableDeviceController';

import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { ModalLoader } from '@ohos/settings.common/src/main/ets/framework/common/ModalLoader';
import { settingSheetBuilder } from '@ohos/settings.common/src/main/ets/framework/view/SettingSheet';
import { OppBluetoothPhonePageController } from '../Bluetooth/controller/OppBluetoothPhonePageController';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
/* instrument ignore file */
export const URL_BLUETOOTH_OPP_PAGE: string = 'open_bluetooth_info_entry';

function bluetoothInfoPage(): SettingPageModel {
  let switchController: BluetoothSwitchController = new BluetoothSwitchController();
  let oppBondedDeviceController: OppBondedDeviceController = new OppBondedDeviceController();
  let oppAvailableDeviceController: OppAvailableDeviceController = new OppAvailableDeviceController();
  return {
    id: 'Bluetooth',
    url: NavEntryKey.OPEN_BLUETOOTH_INFO_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.bluetooth_settings_title'),
    layout: {
      backgroundColor: DeviceUtil.isDevicePc() ? Color.Transparent : $r('app.color.component_ultra_thick_panel'),
      hideTitleBar: true
    },
    compControl: new OppBluetoothPhonePageController(switchController, oppBondedDeviceController,
      oppAvailableDeviceController),
    fixedGroups: [
    // 开关
      {
        id: 'SwitchGroup',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'SwitchItem',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.bluetooth_settings_title') },
            result: { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: true } },
            compControl: switchController,
          }
        ]
      },
    ],
    groups: [
      // 已配对设备
      {
        id: 'OppBondDeviceGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        cached: false,
        visible: false,
        header: { id: 'OppBondDeviceHeader', content: $r('app.string.bluetooth_paired_devices') },
        compControl: oppBondedDeviceController,
      },
      // 其他设备
      {
        id: 'OppAvailableDeviceGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
        cached: false,
        visible: false,
        header: { id: 'OppAvailableDeviceHeader', builder: wrapBuilder(oppAvailableDeviceHeader) },
        compControl: oppAvailableDeviceController,
      }
    ]
  };
}

// 页面配置导入
ModalLoader.load(URL_BLUETOOTH_OPP_PAGE, {
  configGenerator: bluetoothInfoPage,
  pageBuilder: wrapBuilder(settingSheetBuilder),
});