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
import {
  BluetoothBondedDeviceController
} from '@ohos/settings.bluetooth/src/main/ets/controller/BluetoothBondedDeviceController';

export default function bluetoothBondedDeviceControllerTest() {
  describe('bluetoothBondedDeviceControllerTest', () => {

    beforeAll(() => {
    });

    afterAll(() => {
    });

    it('initTest_001', 0, () => {
      let controller = new BluetoothBondedDeviceController();
      expect(controller.getListenKey()).assertContain('Bluetooth_Bonded_Device_Controller');

      controller.init({compId: '123456', component: { id: 'componentId'}});
      expect(controller.compId).assertEqual('123456');
    });
  });
}