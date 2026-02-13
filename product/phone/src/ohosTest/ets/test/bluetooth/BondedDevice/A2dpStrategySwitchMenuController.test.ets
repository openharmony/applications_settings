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
  A2dpStrategySwitchMenuController
} from '@ohos/settings.bluetooth/src/main/ets/controller/BondedDevice/A2dpStrategySwitchMenuController';
import { BluetoothDevice } from '@ohos/settings.bluetooth/src/main/ets/model/BluetoothModel';

export default function a2dpStrategySwitchMenuControllerTest() {
  describe('a2dpStrategySwitchMenuControllerTest', () => {

    beforeAll(() => {
    });

    afterAll(() => {
    });

    testInit_001();
  });
}

function testInit_001(): void {
  it('initTest_001', 0, () => {
    let deviceId: string = 'deviceId';
    let device = new BluetoothDevice(deviceId);
    let controller = new A2dpStrategySwitchMenuController(device);
    expect(controller.tag).assertEqual('A2dpStrategySwitchMenuController: ');
    expect(controller.getListenKey()).assertEqual('A2dp_Strategy_Switch_Menu_Controller');

    controller.init({compId: '', component: { id: 'componentId'}});
    controller.init({compId: '123456', component: { id: 'componentId'}});
    expect(controller.compId).assertEqual('123456');
  });
}