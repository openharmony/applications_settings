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
import { CachedBluetoothDeviceManager } from '@ohos/settings.bluetooth/src/main/ets/BluetoothAdapter';
import { BluetoothDevice } from '@ohos/settings.bluetooth/src/main/ets/model/BluetoothModel';

export default function cachedBluetoothDeviceManagerTest() {
  describe('cachedBluetoothDeviceManagerTest', () => {

    beforeAll(() => {
    });

    afterAll(() => {
    });

    it('cachedBluetoothDeviceManagerTest_001', 0, () => {
      let manager = new CachedBluetoothDeviceManager();
      let count1: number = manager.getDeviceCount();
      expect(count1).assertEqual(0);

      let deviceId: string = '123';
      manager.addDevice(new BluetoothDevice(deviceId));
      let device = manager.findDevice(deviceId);
      expect(device?.deviceId).assertEqual(deviceId);

      manager.removeDevice(deviceId);
      expect(manager.getDeviceCount()).assertEqual(0);

      manager.addDevice(new BluetoothDevice(deviceId));
      let devices = Array.from(manager.getCachedDevices());
      for (let device of devices) {
        expect(device.deviceId).assertEqual(deviceId);
      }
    });
  });
}