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

import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { ConnectionStrategy } from '@ohos/settings.bluetooth/src/main/ets/BluetoothAdapter';
import {
  BluetoothStrategySwitchMenuController
} from '@ohos/settings.bluetooth/src/main/ets/controller/BondedDevice/BluetoothStrategySwitchMenuController';
import {
  BluetoothDevice,
  ProfileConnectionState,
  ProfileId,
  StateChangeParam
} from '@ohos/settings.bluetooth/src/main/ets/model/BluetoothModel';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';

export default function BluetoothStrategySwitchMenuControllerTest() {
  describe('bluetoothStrategySwitchMenuControllerTest', () => {
    it('initTest_001', 0, () => {
      let deviceId: string = 'deviceId';
      let device = new BluetoothDevice(deviceId);
      let controller = new BluetoothStrategySwitchMenuController(device);
      expect(controller.tag).assertEqual('BluetoothStrategySwitchMenuController: ');
      expect(controller.getListenKey()).assertEqual('Bluetooth_Strategy_Switch_Menu_Controller');
      controller.init({
        compId: '123456', component: {
          id: 'componentId'
        }
      });
      controller.isShowDivider = false;
      controller.init({
        compId: '123456', component: {
          id: 'componentId'
        }
      });
      controller.onBluetoothStateChange(0);
      controller.onBluetoothStateChange(2);
      controller.onConnectResult('deviceId', 0, true);
      controller.getProfileData();
      controller.updateStatus();
      controller.device = undefined;
      controller.getProfileData();
      controller.updateStatus();
      controller.setSelectorColor($r('app.color.default_switch_color'));
      controller.setToggleMenuStatus(true);
      controller.setToggleMenuStatus(false);
      controller.setSummary();
      controller.setSummary($r('app.string.bt_connection_strategy_summary'));
      controller.setFontColor();
      controller.reportStrategySwitchChangeEvent(true);
      controller.refreshOtherSwitchStatus(true);
      controller.refreshALLSwitchStatus();
      controller.setChecked(true);
      expect(controller.getChecked()).assertTrue();
      controller.destroy();
    });
    it('bluetoothStrategySwitchMenuControllerTest_001', 0, (done: Function) => {
      try {
        let device = new BluetoothDevice('123123');
        let controller = new BluetoothStrategySwitchMenuController(device);
        let stateChangeParam: StateChangeParam = AppStorage.get('stateChangeParam') as StateChangeParam;
        controller.onBluetoothProfileStateChange(ProfileId.PROFILE_A2DP_SOURCE, stateChangeParam);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bluetoothStrategySwitchMenuControllerTest_002', 0, (done: Function) => {
      try {
        let device = new BluetoothDevice('123123');
        let controller = new BluetoothStrategySwitchMenuController(device);
        let stateChangeParam: StateChangeParam = {
          deviceId: '12332',
          state: ProfileConnectionState.STATE_DISCONNECTED
        } as StateChangeParam;
        let deviceProfileMap: Map<ProfileId, ProfileConnectionState> = new Map();
        controller.profileMap.set(stateChangeParam.deviceId, deviceProfileMap);
        controller.onBluetoothProfileStateChange(ProfileId.PROFILE_A2DP_SOURCE, stateChangeParam);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bluetoothStrategySwitchMenuControllerTest_003', 0, (done: Function) => {
      try {
        let device = new BluetoothDevice('123123');
        let controller = new BluetoothStrategySwitchMenuController(device);
        let stateChangeParam: StateChangeParam = {
          deviceId: 'test',
          state: ProfileConnectionState.STATE_DISCONNECTED
        } as StateChangeParam;
        let deviceProfileMap: Map<ProfileId, ProfileConnectionState> = new Map();
        controller.profileMap.set(stateChangeParam.deviceId, deviceProfileMap);
        controller.onBluetoothProfileStateChange(ProfileId.PROFILE_A2DP_SOURCE, stateChangeParam);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bluetoothStrategySwitchMenuControllerTest_004', 0, (done: Function) => {
      try {
        let device = new BluetoothDevice('123123');
        let controller = new BluetoothStrategySwitchMenuController(device);
        let mocker = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(BluetoothUtils, BluetoothUtils.isBluetoothStateOff);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
        let mockfunc2: Function =
          mocker.mockFunc(controller, controller.getConnectionProfile()?.getConnectionState);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(0);
        controller.updateStatus();
        mocker.clear(BluetoothUtils);
        mocker.clear(controller);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bluetoothStrategySwitchMenuControllerTest_005', 0, (done: Function) => {
      try {
        let device = new BluetoothDevice('123123');
        let controller = new BluetoothStrategySwitchMenuController(device);
        let mocker = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(BluetoothUtils, BluetoothUtils.isBluetoothStateOff);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
        let mockfunc2: Function =
          mocker.mockFunc(BluetoothUtils, BluetoothUtils.isBluetoothDiscoveryOn);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(true);
        let mockfunc3: Function =
          mocker.mockFunc(controller, controller.getConnectionProfile()?.getConnectionState);
        when(mockfunc3)(ArgumentMatchers.any).afterReturn(0);
        let result = controller.updateStatus();
        expect(result !== null).assertTrue();
        mocker.clear(BluetoothUtils);
        mocker.clear(controller);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bluetoothStrategySwitchMenuControllerTest_008', 0, (done: Function) => {
      try {
        let device = new BluetoothDevice('123123');
        let controller = new BluetoothStrategySwitchMenuController(device);
        controller.isChecked = false;
        (controller as object)['updateToggleStatusTimeout'](ConnectionStrategy.CONNECTION_STRATEGY_ALLOWED);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bluetoothStrategySwitchMenuControllerTest_009', 0, (done: Function) => {
      try {
        let device = new BluetoothDevice('123123');
        let controller = new BluetoothStrategySwitchMenuController(device);
        controller.isChecked = true;
        controller.refreshFromOther = false;
        (controller as object)['updateToggleStatusTimeout'](ConnectionStrategy.CONNECTION_STRATEGY_UNSUPPORTED);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bluetoothStrategySwitchMenuControllerTest_010', 0, (done: Function) => {
      try {
        let device = new BluetoothDevice('123123');
        let controller = new BluetoothStrategySwitchMenuController(device);
        (controller as object)['freshCompletedStatus']();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bluetoothStrategySwitchMenuControllerTest_011', 0, (done: Function) => {
      try {
        let device = new BluetoothDevice('123123');
        let controller = new BluetoothStrategySwitchMenuController(device);
        controller.reportStrategySwitchChangeEvent(false)
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bluetoothStrategySwitchMenuControllerTest_012', 0, (done: Function) => {
      try {
        let device = new BluetoothDevice('123123');
        let controller = new BluetoothStrategySwitchMenuController(device);
        controller.isChecked = true;
        (controller as object)['toggleStateChangeCallback'](() => {
        });
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bluetoothStrategySwitchMenuControllerTest_013', 0, (done: Function) => {
      try {
        let device = new BluetoothDevice('123123');
        let controller = new BluetoothStrategySwitchMenuController(device);
        controller.isChecked = true;
        (controller as object)['updateConnectAndToggleStatus'](ConnectionStrategy.CONNECTION_STRATEGY_UNSUPPORTED);
      } catch (e) {
      } finally {
        done()
      }
    });
  });
}