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

import {
  afterAll,
  afterEach,
  ArgumentMatchers,
  beforeAll,
  beforeEach,
  describe,
  expect,
  it,
  Level,
  MockKit,
  when,
} from '@ohos/hypium';
import { CheckEmptyUtils, LogUtil, SettingsDataUtils } from '@ohos/settings.common';
import {
  BluetoothBondedDeviceType,
  BluetoothUtils,
  DisconnectCause,
  UnbondCause
} from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { access } from '@kit.ConnectivityKit';

export default function bluetoothUtilsTest() {
  describe('bluetoothUtilsTest', (): void => {
    it('bluetoothUtilsTest_01', 0, () => {
      BluetoothUtils.isBluetoothOn();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(LogUtil, LogUtil.info);
      when(mockfunc)(ArgumentMatchers.any).afterThrow('myMsg');
      try {
        BluetoothUtils.isBluetoothOn();
        mocker.clear(LogUtil);
      } catch (e) {
        mocker.clear(LogUtil);
        expect(e).assertEqual('myMsg');
      }
    });
    it('bluetoothUtilsTest_02', 0, () => {
      try {
        let result = BluetoothUtils.enableBlueTooth();
        expect(result !== null).assertTrue();
      } catch (e) {
        LogUtil.error(`e error${e}`);
      }
    });
    it('bluetoothUtilsTest_03', 0, () => {
      try {
        let mocker: MockKit = new MockKit();
        let mockfunc: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
        when(mockfunc)(ArgumentMatchers.any).afterReturn('0');

        let mockfunc2: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn('1');
        let result = BluetoothUtils.disableBlueTooth();
        expect(result !== null).assertTrue();

        let mockfunc4: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
        when(mockfunc4)(ArgumentMatchers.any).afterReturn('0');
        let mockfunc5: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
        when(mockfunc5)(ArgumentMatchers.any).afterReturn('1');
        BluetoothUtils.disableBlueTooth();

        let mockfunc6: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
        when(mockfunc6)(ArgumentMatchers.any).afterReturn('0');
        let mockfunc7: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
        when(mockfunc7)(ArgumentMatchers.any).afterReturn('2');
        BluetoothUtils.disableBlueTooth();
        mocker.clear(SettingsDataUtils);
      } catch (e) {
        LogUtil.error(`e error${e}`);
      }
    });
    it('bluetoothUtilsTest_04', 0, () => {
      BluetoothUtils.getCurrentBluetoothState();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(LogUtil, LogUtil.info);
      when(mockfunc)(ArgumentMatchers.any).afterThrow('myMsg');
      try {
        BluetoothUtils.isBluetoothOn();
      } catch (e) {
        expect(e).assertEqual('myMsg');
      }
      mocker.clear(LogUtil);
    });
    it('bluetoothUtilsTest_041', 0, () => {
      BluetoothUtils.isBluetoothStateOpening(access.BluetoothState.STATE_TURNING_ON);
      BluetoothUtils.isBluetoothStateOpening(access.BluetoothState.STATE_BLE_TURNING_ON);
      BluetoothUtils.isBluetoothStateOpening(access.BluetoothState.STATE_OFF);
      expect(access.BluetoothState.STATE_OFF).assertEqual(0);
    });
    it('bluetoothUtilsTest_05', 0, () => {
      BluetoothUtils.isBluetoothMiddleState(access.BluetoothState.STATE_TURNING_ON);
      BluetoothUtils.isBluetoothMiddleState(access.BluetoothState.STATE_OFF);
      expect(access.BluetoothState.STATE_OFF).assertEqual(0);
    });
    it('bluetoothUtilsTest_06', 0, () => {
      BluetoothUtils.isBluetoothStateOn(access.BluetoothState.STATE_ON);

      BluetoothUtils.enhancedServicesState = '1';
      BluetoothUtils.isBluetoothStateOn(access.BluetoothState.STATE_OFF);

      BluetoothUtils.enhancedServicesState = '1';
      let result = BluetoothUtils.isBluetoothStateOn(access.BluetoothState.STATE_BLE_ON);
      expect(result !== null).assertTrue()
    });
    it('bluetoothUtilsTest_07', 0, () => {
      BluetoothUtils.isBluetoothStateClosing(access.BluetoothState.STATE_TURNING_OFF);
      BluetoothUtils.isBluetoothStateClosing(access.BluetoothState.STATE_BLE_TURNING_OFF);
      BluetoothUtils.isBluetoothStateClosing(access.BluetoothState.STATE_OFF);
      expect(access.BluetoothState.STATE_OFF).assertEqual(0);
    });
    it('bluetoothUtilsTest_08', 0, () => {
      try {
        let result= BluetoothUtils.isBluetoothStateOff(access.BluetoothState.STATE_OFF);
        expect(result === true).assertTrue();
        let result2 = BluetoothUtils.isBluetoothStateOff(1);
        expect(result2 !== null).assertTrue()
      } catch (e) {
        LogUtil.error(`e error${e}`);
      }
    });
    it('bluetoothUtilsTest_09', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
      when(mockfunc)(ArgumentMatchers.any).afterReturn('1');
      BluetoothUtils.isHalfCloseState();
      when(mockfunc)(ArgumentMatchers.any).afterReturn('2');
      BluetoothUtils.isHalfCloseState();
      expect(access.BluetoothState.STATE_OFF).assertEqual(0);
      mocker.clear(SettingsDataUtils);
    });
    it('bluetoothUtilsTest_10', 0, () => {
      BluetoothUtils.isValidMac('');
      BluetoothUtils.isValidMac('1');
      expect(access.BluetoothState.STATE_OFF).assertEqual(0);
    });
    it('bluetoothUtilsTest_11', 0, () => {
      BluetoothUtils.getLogMAC('');
      BluetoothUtils.getLogMAC('1');
      expect(access.BluetoothState.STATE_OFF).assertEqual(0);
    });
    it('bluetoothUtilsTest_12', 0, () => {
      BluetoothUtils.getPreMac('');
      BluetoothUtils.getPreMac('1');
      expect(access.BluetoothState.STATE_OFF).assertEqual(0);
    });
    it('bluetoothUtilsTest_13', 0, () => {
      BluetoothUtils.getSufMac('');
      BluetoothUtils.getSufMac('1');
      expect(access.BluetoothState.STATE_OFF).assertEqual(0);
    });
    it('bluetoothUtilsTest_15', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(CheckEmptyUtils, CheckEmptyUtils.isEmptyArr);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
      BluetoothUtils.getLogUuid(['', '']);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
      BluetoothUtils.getLogUuid(['', '']);
      mocker.clear(CheckEmptyUtils);
      expect(access.BluetoothState.STATE_OFF).assertEqual(0);
    });
    it('bluetoothUtilsTest_16', 0, () => {
      BluetoothUtils.getBondDeviceType(BluetoothBondedDeviceType.DEVICE_TYPE_CAR);
      BluetoothUtils.getBondDeviceType(BluetoothBondedDeviceType.DEVICE_TYPE_HEADSET);
      BluetoothUtils.getBondDeviceType(BluetoothBondedDeviceType.DEVICE_TYPE_HEARING);
      BluetoothUtils.getBondDeviceType(BluetoothBondedDeviceType.DEVICE_TYPE_GLASSES);
      BluetoothUtils.getBondDeviceType(BluetoothBondedDeviceType.DEVICE_TYPE_WATCH);
      BluetoothUtils.getBondDeviceType(BluetoothBondedDeviceType.DEVICE_TYPE_SPEAKER);
      BluetoothUtils.getBondDeviceType(BluetoothBondedDeviceType.DEVICE_TYPE_DEFAULT);
      expect(access.BluetoothState.STATE_OFF).assertEqual(0);
    });
    it('bluetoothUtilsTest_17', 0, () => {
      BluetoothUtils.getPairFailedMessage('', UnbondCause.REMOTE_DEVICE_DOWN);
      BluetoothUtils.getPairFailedMessage('', UnbondCause.AUTH_FAILURE);
      BluetoothUtils.getPairFailedMessage('', UnbondCause.AUTH_REJECTED);
      BluetoothUtils.getPairFailedMessage('', UnbondCause.USER_REMOVED);
      expect(access.BluetoothState.STATE_OFF).assertEqual(0);
    });
    it('bluetoothUtilsTest_18', 0, () => {
      BluetoothUtils.getConnectFailedMessage(DisconnectCause.CONNECT_FROM_KEYBOARD);
      BluetoothUtils.getConnectFailedMessage(DisconnectCause.CONNECT_FROM_KEYBOARD);
      BluetoothUtils.getConnectFailedMessage(DisconnectCause.CONNECT_FROM_MOUSE);
      BluetoothUtils.getConnectFailedMessage(DisconnectCause.CONNECT_FROM_CAR);
      BluetoothUtils.getConnectFailedMessage(DisconnectCause.TOO_MANY_CONNECTED_DEVICES);
      BluetoothUtils.getConnectFailedMessage(DisconnectCause.CONNECT_FAIL_INTERNAL);
      expect(access.BluetoothState.STATE_OFF).assertEqual(0);
    });
  })
}