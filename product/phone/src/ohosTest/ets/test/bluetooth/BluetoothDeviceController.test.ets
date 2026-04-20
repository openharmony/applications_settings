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

import { afterAll, beforeAll, describe, expect, it } from '@ohos/hypium';
import { BluetoothDeviceController } from '@ohos/settings.bluetooth/src/main/ets/controller/BluetoothDeviceController';
import { BluetoothItemModel } from '@ohos/settings.bluetooth/src/main/ets/model/BluetoothItemModel';
import { BluetoothDevice } from '@ohos/settings.bluetooth/src/main/ets/model/BluetoothModel';
import { ItemType, SettingIconType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';

export default function bluetoothDeviceControllerTest() {
  describe('bluetoothDeviceControllerTest', () => {

    beforeAll(() => {
    });

    afterAll(() => {
    });

    it('initTest_001', 0, () => {
      let controller = new BluetoothDeviceController();
      controller.init({compId: '123456', component: { id: 'componentId'}});
      controller.destroy();

      let deviceId: string = 'deviceId';
      let device = new BluetoothDevice(deviceId);
      controller.onClick({
        id: device.deviceId,
        type: ItemType.ITEM_TYPE_STANDARD,
        icon: {
          icon: device.getIcon(),
          iconType: SettingIconType.ICON_TYPE_TIP,
          style: { width: 24, height: 24, fillColor: $r('sys.color.icon_primary') },
        },
        title: { content: device.deviceName ?? device.deviceId },
        rssi: device.getRssi(),
        device: device,
      } as BluetoothItemModel);

      expect(controller.tag).assertEqual('BluetoothDeviceController : ');
    });
  });
}