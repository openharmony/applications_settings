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

import bluetooth from '@ohos.bluetooth';
import constant from '@ohos.bluetooth.constant';
import { beforeEach, describe, expect, it, MockKit, TestType, when } from '@ohos/hypium';
import {
  BluetoothProfile,
  BluetoothProfileStateChangeListener,
  HearingAidProfile,
  ProfileConnectionState
} from '@ohos/settings.bluetooth';
import {
  A2dpProfile,
  BluetoothAdapter,
  CachedBluetoothDeviceManager,
  ConnectionStrategy,
  HfpProfile,
  HidProfile
} from '@ohos/settings.bluetooth/src/main/ets/BluetoothAdapter';
import {
  BluetoothDevice,
  DeviceType,
  ProfileId,
  SearchMessageChangeData,
  StateChangeParam,
  TaskOutPut,
  VolumeSyncParam
} from '@ohos/settings.bluetooth/src/main/ets/model/BluetoothModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Constant } from '../../../constant/Constant';

const DEVICE_ID: string = '11:22:33:AA:BB:FF';

export default function BluetoothModelTest() {
  describe('BluetoothModelTest', () => {

    /*
    * @tc.number: BluetoothModelTest_001
    * @tc.name: isConnected
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return false
    */
    it('BluetoothModelTest_001', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_001 start`);
      let bluetoothDevice = new BluetoothDevice(DEVICE_ID);
      let result = await bluetoothDevice.isConnected();
      expect(result).assertFalse();
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_001 end`);
    });

    /*
    * @tc.number: BluetoothModelTest_002
    * @tc.name: 获取蓝牙设备列表项状态辅助文本
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return ''
    */
    it('BluetoothModelTest_002', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_002 start`);
      let bluetoothDevice = new BluetoothDevice(DEVICE_ID);
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(bluetoothDevice, bluetoothDevice.getSummary);
      when(mockFunc)().afterReturn('');
      let result = await bluetoothDevice.getSummary();
      expect(result).assertEqual('');
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_002 end`);
    });

    /*
    * @tc.number: BluetoothModelTest_003
    * @tc.name: getIcon
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return 0
    */
    it('BluetoothModelTest_003', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_003 start`);
      let bluetoothDevice = new BluetoothDevice(DEVICE_ID);
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(bluetoothDevice, bluetoothDevice.getIcon);
      when(mockFunc)().afterReturn(0);
      let result = await bluetoothDevice.getIcon();
      expect(result).assertEqual(0);
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_003 end`);
    });

    /*
    * @tc.number: BluetoothModelTest_004
    * @tc.name: 设置远端UUID
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return 0
    */
    it('BluetoothModelTest_004', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_004 start`);
      let bluetoothDevice = new BluetoothDevice(DEVICE_ID);
      let remoteUuids: Array<constant.ProfileUuids> = [constant.ProfileUuids.PROFILE_UUID_HFP_HF];
      bluetoothDevice.setRemoteUuids(remoteUuids);
      let result = bluetoothDevice.getRemoteUuids();
      expect(result).not().assertNull()
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_004 end`);
    });

    /*
    * @tc.number: BluetoothModelTest_005
    * @tc.name: 设置蓝牙状态
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return 0
    */
    it('BluetoothModelTest_005', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_005 start`);
      let bluetoothDevice = new BluetoothDevice(DEVICE_ID);
      bluetoothDevice.setEnable(false);
      let result = bluetoothDevice.getEnable();
      expect(result).assertFalse();
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_005 end`);
    });

    /*
    * @tc.number: BluetoothModelTest_006
    * @tc.name: createUuidStrs
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return 0
    */
    it('BluetoothModelTest_006', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_006 start`);
      let bluetoothDevice = new BluetoothDevice(DEVICE_ID);
      let remoteUuids: Array<constant.ProfileUuids> = [constant.ProfileUuids.PROFILE_UUID_HFP_HF];
      let result = bluetoothDevice.createUuidStrs(remoteUuids);
      expect(result).not().assertNull();
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_006 end`);
    });

    /*
    * @tc.number: BluetoothModelTest_007
    * @tc.name: 获取蓝牙设备列表项状态辅助文本
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return ''
    */
    it('BluetoothModelTest_007', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_007 start`);
      let bluetoothDevice = new BluetoothDevice('');
      let result = bluetoothDevice.getSummary();
      expect(result).assertEqual('');
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_007 end`);
    });

    /*
    * @tc.number: BluetoothModelTest_008
    * @tc.name: 获取蓝牙设备列表项状态辅助文本
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return ''
    */
    it('BluetoothModelTest_008', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_008 start`);
      let bluetoothDevice = new BluetoothDevice(DEVICE_ID);
      let result = bluetoothDevice.getSummary();
      expect(result).assertEqual('');
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_008 end`);
    });

    /*
    * @tc.number: BluetoothModelTest_009
    * @tc.name: setHidProfile
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return ''
    */
    it('BluetoothModelTest_009', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_009 start`);
      let bluetoothDevice = new BluetoothDevice(DEVICE_ID);
      let remoteUuids: Array<string> = [constant.ProfileUuids.PROFILE_UUID_HID.toLowerCase()];
      let profileMap: Map<ProfileId, BluetoothProfile> = new Map();

      class TestListener implements BluetoothProfileStateChangeListener {
        getListenKey(): string {
          return '';
        }

        onBluetoothProfileStateChange(profileId: ProfileId, stateChangeParam: StateChangeParam): void {
        }

        onConnectResult(deviceId: string, result: number): void {
        }
      };
      let hidProfile: HidProfile = new HidProfile(new TestListener());
      hidProfile.initConnectionProfile();
      profileMap.set(ProfileId.PROFILE_HID_HOST, hidProfile);
      bluetoothDevice.setHidProfile(ProfileId.PROFILE_HID_HOST, remoteUuids, profileMap);
      let size: number = bluetoothDevice.profileMap.size;
      expect(size).assertLarger(0);
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_009 end`);
    });

    /*
    * @tc.number: BluetoothModelTest_010
    * @tc.name: addConnectionStatus
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return ''
    */
    it('BluetoothModelTest_010', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_010 start`);
      let bluetoothDevice = new BluetoothDevice(DEVICE_ID);
      bluetoothDevice.addConnectionStatus(ProfileId.PROFILE_HANDS_FREE_AUDIO_GATEWAY,
        ConnectionStrategy.CONNECTION_STRATEGY_ALLOWED);
      let size: number = bluetoothDevice.connectionStatusMap.size;
      expect(size).assertLarger(0);
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_010 end`);
    });

    /*
    * @tc.number: BluetoothModelTest_011
    * @tc.name: createDevice
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return ''
    */
    it('BluetoothModelTest_011', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_011 start`);
      let bluetoothDevice = BluetoothDevice.createDevice(DEVICE_ID);
      expect(bluetoothDevice).not().assertNull();
      let result = BluetoothDevice.createDevice('');
      expect(result).assertNull();
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_011 end`);
    });

    /*
    * @tc.number: BluetoothModelTest_012
    * @tc.name: update
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return ''
    */
    it('BluetoothModelTest_012', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_012 start`);
      let bluetoothDevice = new BluetoothDevice(DEVICE_ID);
      BluetoothDevice.createDevice(DEVICE_ID)
      bluetoothDevice.update();
      expect().not().assertFail();
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_012 end`);
    });

    /*
    * @tc.number: BluetoothModelTest_013
    * @tc.name: getDeviceType
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return ''
    */
    it('BluetoothModelTest_013', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_013 start`);
      let bluetoothDevice: BluetoothDevice = new BluetoothDevice(DEVICE_ID);
      BluetoothDevice.createDevice(DEVICE_ID)
      bluetoothDevice.update();
      let result: DeviceType = BluetoothDevice.getDeviceSpecificType(DEVICE_ID);
      expect(result).not().assertNull();
      let result2 = BluetoothDevice.getDeviceSpecificType('');
      expect(result2).assertEqual(0);
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_013 end`);
    });

    /*
    * @tc.number: BluetoothModelTest_014
    * @tc.name: getDeviceName
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return ''
    */
    it('BluetoothModelTest_014', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_014 start`);
      let bluetoothDevice = new BluetoothDevice(DEVICE_ID);
      let bluetoothAdapter: BluetoothAdapter = BluetoothAdapter.getInstance();
      BluetoothDevice.createDevice(DEVICE_ID)
      bluetoothDevice.update();
      let result1 = BluetoothDevice.getDeviceName(DEVICE_ID);
      expect(result1).not().assertNull();
      let result2 = BluetoothDevice.getDeviceName('');
      expect(result2).assertNull();
      let cachedManager: CachedBluetoothDeviceManager = new CachedBluetoothDeviceManager();
      bluetoothAdapter.cachedManager = cachedManager;

      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(cachedManager, cachedManager.findDevice);
      bluetoothDevice.deviceName = DEVICE_ID;
      when(mockFunc)().afterReturn(bluetoothDevice);
      let result3 = BluetoothDevice.getDeviceName(DEVICE_ID);
      expect(result3).not().assertNull();
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_014 end`);
    });

    /*
    * @tc.number: BluetoothModelTest_015
    * @tc.name: getConnectableProfiles
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return ''
    */
    it('BluetoothModelTest_015', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_015 start`);
      let bluetoothDevice = new BluetoothDevice(DEVICE_ID);
      let profileMap: Map<ProfileId, BluetoothProfile> = new Map();

      class TestListener implements BluetoothProfileStateChangeListener {
        getListenKey(): string {
          return '';
        }

        onBluetoothProfileStateChange(profileId: ProfileId, stateChangeParam: StateChangeParam): void {
        }

        onConnectResult(deviceId: string, result: number): void {
        }
      };
      let hidProfile: HidProfile = new HidProfile(new TestListener());
      hidProfile.initConnectionProfile();
      profileMap.set(ProfileId.PROFILE_HID_HOST, hidProfile);
      bluetoothDevice.profileMap = profileMap;
      let result: Map<ProfileId, BluetoothProfile> = bluetoothDevice.getConnectableProfiles();
      expect(result).not().assertNull();
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_015 end`);
    });

    /*
    * @tc.number: BluetoothModelTest_016
    * @tc.name: setDiscover
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return ''
    */
    it('BluetoothModelTest_016', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_016 start`);
      let bluetoothDevice = new BluetoothDevice(DEVICE_ID);
      bluetoothDevice.setDiscover(true);
      expect(bluetoothDevice.getDiscover()).assertTrue()
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_016 end`);
    });

    /*
    * @tc.number: BluetoothModelTest_017
    * @tc.name: updateProfilesAndConnectionStatusForRemoteUUID
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return ''
    */
    it('BluetoothModelTest_017', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_017 start`);
      let bluetoothDevice = new BluetoothDevice(DEVICE_ID);
      let result = bluetoothDevice.updateProfilesAndConnectionStatusForRemoteUUID();
      expect(result).assertPromiseIsResolved();
      let remoteUuids: Array<constant.ProfileUuids> = [
        constant.ProfileUuids.PROFILE_UUID_HFP_AG,
        constant.ProfileUuids.PROFILE_UUID_HFP_HF,
        constant.ProfileUuids.PROFILE_UUID_HSP_AG,
        constant.ProfileUuids.PROFILE_UUID_HSP_HS,
        constant.ProfileUuids.PROFILE_UUID_A2DP_SRC,
        constant.ProfileUuids.PROFILE_UUID_A2DP_SINK,
        constant.ProfileUuids.PROFILE_UUID_AVRCP_CT,
        constant.ProfileUuids.PROFILE_UUID_AVRCP_TG,
        constant.ProfileUuids.PROFILE_UUID_HID,
        constant.ProfileUuids.PROFILE_UUID_HOGP
      ];
      bluetoothDevice.setRemoteUuids(remoteUuids);
      let profileMap: Map<ProfileId, BluetoothProfile> = new Map();

      class TestListener implements BluetoothProfileStateChangeListener {
        getListenKey(): string {
          return '';
        }

        onBluetoothProfileStateChange(profileId: ProfileId, stateChangeParam: StateChangeParam): void {
        }

        onConnectResult(deviceId: string, result: number): void {
        }
      };
      let hidProfile: HidProfile = new HidProfile(new TestListener());
      hidProfile.initConnectionProfile();
      profileMap.set(ProfileId.PROFILE_HID_HOST, hidProfile);
      let a2dpProfile: A2dpProfile = new A2dpProfile(new TestListener());
      a2dpProfile.initConnectionProfile();
      profileMap.set(ProfileId.PROFILE_A2DP_SOURCE, a2dpProfile)
      let hfpProfile: HfpProfile = new HfpProfile(new TestListener());
      hfpProfile.initConnectionProfile();
      profileMap.set(ProfileId.PROFILE_HANDS_FREE_AUDIO_GATEWAY, hfpProfile)
      bluetoothDevice.profileMap = profileMap;
      result = bluetoothDevice.updateProfilesAndConnectionStatusForRemoteUUID();
      expect(result).assertPromiseIsResolved()
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_017 end`);
    });

    /*
    * @tc.number: BluetoothModelTest_018
    * @tc.name: updateConnectionStatus
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return ''
    */
    it('BluetoothModelTest_018', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_018 start`);
      let bluetoothDevice = new BluetoothDevice(DEVICE_ID);

      class TestListener implements BluetoothProfileStateChangeListener {
        getListenKey(): string {
          return '';
        }

        onBluetoothProfileStateChange(profileId: ProfileId, stateChangeParam: StateChangeParam): void {
        }

        onConnectResult(deviceId: string, result: number): void {
        }
      };
      let hidProfile: HidProfile = new HidProfile(new TestListener());
      hidProfile.initConnectionProfile();
      bluetoothDevice.addProfile(ProfileId.PROFILE_HID_HOST, hidProfile);
      let result = bluetoothDevice.updateConnectionStatus()
      expect(result).assertPromiseIsPending()
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_018 end`);
    });

    /*
    * @tc.number: BluetoothModelTest_019
    * @tc.name: getHidClass
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return ''
    */
    it('BluetoothModelTest_019', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_019 start`);

      class MyDeviceClass implements bluetooth.DeviceClass {
        majorClass: bluetooth.MajorClass = bluetooth.MajorClass.MAJOR_MISC;
        majorMinorClass: bluetooth.MajorMinorClass = bluetooth.MajorMinorClass.COMPUTER_UNCATEGORIZED;
        classOfDevice: number = 0;
      }

      let deviceClass: bluetooth.DeviceClass = new MyDeviceClass();
      deviceClass.majorMinorClass = bluetooth.MajorMinorClass.PERIPHERAL_KEYBOARD;
      let result = BluetoothDevice.getHidClass(deviceClass);
      expect(result).assertEqual(DeviceType.KEYBOARD);

      deviceClass.majorMinorClass = bluetooth.MajorMinorClass.PERIPHERAL_KEYBOARD_POINTING;
      result = BluetoothDevice.getHidClass(deviceClass);
      expect(result).assertEqual(DeviceType.KEYBOARD);

      deviceClass.majorMinorClass = bluetooth.MajorMinorClass.PERIPHERAL_POINTING_DEVICE;
      result = BluetoothDevice.getHidClass(deviceClass);
      expect(result).assertEqual(DeviceType.MOUSE);

      deviceClass.majorMinorClass = bluetooth.MajorMinorClass.PERIPHERAL_DIGITAL_PEN;
      result = BluetoothDevice.getHidClass(deviceClass);
      expect(result).assertEqual(DeviceType.PEN);

      deviceClass.majorMinorClass = bluetooth.MajorMinorClass.PERIPHERAL_GESTURAL_INPUT;
      result = BluetoothDevice.getHidClass(deviceClass);
      expect(result).assertEqual(DeviceType.BLUETOOTH);
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_019 end`);
    });

    /*
    * @tc.number: BluetoothModelTest_021
    * @tc.name: getIcon
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return ''
    */
    it('BluetoothModelTest_021', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_021 start`);
      let bluetoothDevice = new BluetoothDevice(DEVICE_ID);
      bluetoothDevice.deviceType = 8;
      let result = bluetoothDevice.getIcon();
      expect(result).not().assertNull();
      bluetoothDevice.deviceType = DeviceType.PHONE;
      result = bluetoothDevice.getIcon();
      expect(result).not().assertNull();
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_021 end`);
    });

    /*
    * @tc.number: BluetoothModelTest_023
    * @tc.name: test create Objects
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return ''
    */
    it('BluetoothModelTest_023', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_023 start`);
      let object1: SearchMessageChangeData = new SearchMessageChangeData(true);
      expect(object1).not().assertNull();
      let object2: TaskOutPut = new TaskOutPut();
      expect(object2).not().assertNull();
      let object3: VolumeSyncParam = new VolumeSyncParam();
      expect(object3).not().assertNull();
      LogUtil.info(`${Constant.TAG} BluetoothModelTest_023 end`);
    });

    it('BluetoothModelTest_024', TestType.FUNCTION, BluetoothModelTest_024);
  });

  describe('hearing_aid_devices_test', () => {
    const hearingAidId: number = 123456789;
    const mainDeviceId: string = '1234567';
    const subDeviceId: string = '7654321';

    class TestListener implements BluetoothProfileStateChangeListener {
      getListenKey(): string {
        return '';
      }

      onBluetoothProfileStateChange(profileId: ProfileId, stateChangeParam: StateChangeParam): void {
      }

      onConnectResult(deviceId: string, result: number): void {
      }
    };

    beforeEach(() => {
      BluetoothAdapter.getInstance().cachedBondedDevices.clear();
    })


    it('hearingAid_device_test_001', 0, () => {
      const device = new BluetoothDevice(mainDeviceId);
      expect(device.isHearingAidDevice()).assertFalse();
      device.addProfile(ProfileId.PROFILE_HEARING_AID, new HearingAidProfile(new TestListener()));
      expect(device.isHearingAidDevice()).assertTrue();
      expect(device.deviceType).assertEqual(DeviceType.BLUETOOTH);
      device?.update();
      expect(device.deviceType).assertEqual(DeviceType.HEARING_AID);
    });

    it('hearingAid_device_test_002', 0, () => {
      const mainDevice = new BluetoothDevice(mainDeviceId);
      mainDevice.addProfile(ProfileId.PROFILE_HEARING_AID, new HearingAidProfile(new TestListener()));
      mainDevice.setHearingAidId(hearingAidId);

      const subDevice = new BluetoothDevice(subDeviceId);
      subDevice.addProfile(ProfileId.PROFILE_HEARING_AID, new HearingAidProfile(new TestListener()));
      subDevice.setHearingAidId(hearingAidId);
      let mocker: MockKit = new MockKit();
      let isConnectedFunc: Function =
        mocker.mockFunc(BluetoothAdapter.getInstance(), BluetoothAdapter.getInstance().isDeviceConnected);
      mainDevice.setSubDevice(subDevice);

      when(isConnectedFunc)(mainDeviceId).afterReturn(false);
      when(isConnectedFunc)(subDeviceId).afterReturn(false);
      expect(mainDevice.isConnected()).assertFalse();
      expect(subDevice.isConnected()).assertFalse();

      when(isConnectedFunc)(mainDeviceId).afterReturn(true);
      when(isConnectedFunc)(subDeviceId).afterReturn(false);
      expect(mainDevice.isConnected()).assertTrue();
      expect(subDevice.isConnected()).assertFalse();

      when(isConnectedFunc)(mainDeviceId).afterReturn(true);
      when(isConnectedFunc)(subDeviceId).afterReturn(true);
      expect(mainDevice.isConnected()).assertTrue();
      expect(subDevice.isConnected()).assertTrue();

      when(isConnectedFunc)(mainDeviceId).afterReturn(false);
      when(isConnectedFunc)(subDeviceId).afterReturn(true);
      expect(mainDevice.isConnected()).assertTrue();
      expect(subDevice.isConnected()).assertTrue();

      expect(mainDevice.getHearingAidId()).assertEqual(hearingAidId);
      expect(subDevice.getHearingAidId()).assertEqual(hearingAidId);
      mocker.ignoreMock(BluetoothAdapter.getInstance(), BluetoothAdapter.getInstance().isDeviceConnected);
      mocker.clearAll();
    });

    it('hearingAid_device_test_003', 0, () => {
      expect(BluetoothDevice.mergeHearingAidState(ProfileConnectionState.STATE_CONNECTED,
        ProfileConnectionState.STATE_CONNECTED)).assertEqual(ProfileConnectionState.STATE_CONNECTED);

      expect(BluetoothDevice.mergeHearingAidState(ProfileConnectionState.STATE_CONNECTED,
        ProfileConnectionState.STATE_DISCONNECTED)).assertEqual(ProfileConnectionState.STATE_CONNECTED);

      expect(BluetoothDevice.mergeHearingAidState(ProfileConnectionState.STATE_CONNECTED,
        ProfileConnectionState.STATE_CONNECTING)).assertEqual(ProfileConnectionState.STATE_CONNECTED);

      expect(BluetoothDevice.mergeHearingAidState(ProfileConnectionState.STATE_CONNECTED,
        ProfileConnectionState.STATE_DISCONNECTING)).assertEqual(ProfileConnectionState.STATE_CONNECTED);

      expect(BluetoothDevice.mergeHearingAidState(ProfileConnectionState.STATE_DISCONNECTED,
        ProfileConnectionState.STATE_DISCONNECTED)).assertEqual(ProfileConnectionState.STATE_DISCONNECTED);

      expect(BluetoothDevice.mergeHearingAidState(ProfileConnectionState.STATE_DISCONNECTED,
        ProfileConnectionState.STATE_DISCONNECTING)).assertEqual(ProfileConnectionState.STATE_DISCONNECTING);

      expect(BluetoothDevice.mergeHearingAidState(ProfileConnectionState.STATE_DISCONNECTED,
        ProfileConnectionState.STATE_CONNECTING)).assertEqual(ProfileConnectionState.STATE_DISCONNECTED);

      expect(BluetoothDevice.mergeHearingAidState(ProfileConnectionState.STATE_DISCONNECTING,
        ProfileConnectionState.STATE_CONNECTING)).assertEqual(ProfileConnectionState.STATE_DISCONNECTING);

      expect(BluetoothDevice.mergeHearingAidState(ProfileConnectionState.STATE_DISCONNECTING,
        ProfileConnectionState.STATE_DISCONNECTING)).assertEqual(ProfileConnectionState.STATE_DISCONNECTING);

      expect(BluetoothDevice.mergeHearingAidState(ProfileConnectionState.STATE_CONNECTING,
        ProfileConnectionState.STATE_CONNECTING)).assertEqual(ProfileConnectionState.STATE_CONNECTING);
    });
  });
}

function BluetoothModelTest_024(): void {
  LogUtil.info(`${Constant.TAG} BluetoothModelTest_024 start`);
  let bluetoothDevice = new BluetoothDevice(DEVICE_ID);
  bluetoothDevice.deviceType = DeviceType.HEADPHONE;
  let mocker: MockKit = new MockKit();
  let mockFunc: Function = mocker.mockFunc(bluetoothDevice, bluetoothDevice.isEarphoneId);
  when(mockFunc)().afterReturn(true);
  LogUtil.info(`${Constant.TAG} BluetoothModelTest_024 isEarphoneId ${bluetoothDevice.isEarphoneId()}`);
  let result = bluetoothDevice.getIcon();
  expect(result).not().assertNull();
  LogUtil.info(`${Constant.TAG} BluetoothModelTest_024 end`);
}