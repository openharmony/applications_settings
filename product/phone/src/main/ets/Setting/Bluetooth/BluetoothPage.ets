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

import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { ItemResultType, ItemType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { settingPageBuilder } from '@ohos/settings.common/src/main/ets/framework/view/SettingPage';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { BluetoothSwitchController } from '@ohos/settings.bluetooth/src/main/ets/controller/BluetoothSwitchController';
import { BondedDeviceController } from '@ohos/settings.bluetooth/src/main/ets/controller/BondedDeviceController';
import { AvailableDeviceController } from '@ohos/settings.bluetooth/src/main/ets/controller/AvailableDeviceController';
import { availableDeviceHeader, helpComponent } from '@ohos/settings.bluetooth/src/main/ets/view/CustomBuilder';
import { HintComponent } from './view/HintComponent';
import { BluetoothPhonePageController } from './controller/BluetoothPhonePageController';

@Builder function hintFooter(param: object) {
  HintComponent();
}

function customPage(): SettingPageModel {
  let switchController: BluetoothSwitchController = new BluetoothSwitchController();
  let bondedDeviceController: BondedDeviceController = new BondedDeviceController();
  let availableDeviceController: AvailableDeviceController = new AvailableDeviceController();
  return {
    id: 'Bluetooth',
    url: NavEntryKey.BLUETOOTH_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.bluetooth_settings_title'),
    compControl: new BluetoothPhonePageController(switchController, bondedDeviceController, availableDeviceController),
    // 隐藏蓝牙头部右侧的问号图标
    // menus: [
    //   {
    //     builder: wrapBuilder(helpComponent),
    //   }
    // ],
    fixedGroups: [
      // 开关
      {
        id: 'SwitchGroup',
        type: GroupType.GROUP_TYPE_STANDARD,
        footer: { id: 'hint', builder: wrapBuilder(hintFooter) },
        items: [
          {
            id: 'SwitchItem',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.bluetooth_settings_title') },
            result: { type: ItemResultType.RESULT_TYPE_TOGGLE, result: { state: true } },
            compControl: switchController,
            layout: { background: { pressedBackgroundColor: Color.Transparent }},
          }
        ]
      },
    ],
    groups: [
      // 已配对设备
      {
        id: 'BondDeviceGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        cached: false,
        visible: false,
        header: { id: 'BondDeviceHeader', content: $r('app.string.bluetooth_paired_devices') },
        compControl: bondedDeviceController,
      },
      // 其他设备
      {
        id: 'AvailableDeviceGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
        cached: false,
        visible: false,
        header: { id: 'AvailableDeviceHeader', builder: wrapBuilder(availableDeviceHeader) },
        compControl: availableDeviceController,
      }
    ]
  };
}

// 页面配置导入
PageLoader.load(NavEntryKey.BLUETOOTH_ENTRY, {
  configGenerator: customPage,
  pageBuilder: wrapBuilder(settingPageBuilder),
});
