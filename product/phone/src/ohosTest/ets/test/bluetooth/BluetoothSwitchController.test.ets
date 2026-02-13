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
import { BluetoothSwitchController } from '@ohos/settings.bluetooth/src/main/ets/controller/BluetoothSwitchController';

export default function bluetoothSwitchControllerTest() {
  describe('bluetoothSwitchControllerTest', () => {

    beforeAll(() => {
    });

    afterAll(() => {
    });

    it('initTest_001', 0, () => {
      let controller = new BluetoothSwitchController();
      controller.init({compId: '123456', component: { id: 'componentId'}});
      expect(controller.compId).assertEqual('123456');
      expect(controller.tag).assertEqual('BluetoothSwitchController: ');
      expect(controller.getListenKey()).assertEqual('Bluetooth_Switch_Controller');

      controller.setChecked(true);
      expect(controller.getChecked()).assertTrue();

      controller.onBluetoothStateChange(1);
      expect(controller.currentState).assertEqual(1);
      controller.onBluetoothStateChange(2);
      expect(controller.currentState).assertEqual(2);


      controller.taskTimerId = setTimeout(() => {
      }, 50);
      controller.onBluetoothStateChange(1);
      expect(controller.currentState).assertEqual(1);

      controller.taskTimerId = null;
      controller.updateToTargetState(0);

      controller.taskTimerId = setTimeout(() => {
      }, 50);
      controller.currentState = 1;
      controller.updateToTargetState(0);

      controller.currentState = 2;
      controller.targetState = 2;
      controller.updateToTargetState(0);

      controller.currentState = 2;
      controller.targetState = 1;
      controller.updateToTargetState(0);

      controller.destroy();
    });
  });
}