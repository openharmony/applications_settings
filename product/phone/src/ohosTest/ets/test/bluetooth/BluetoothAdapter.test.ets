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

import { afterAll, beforeAll, beforeEach, describe, expect, it, MockKit, TestType, when } from '@ohos/hypium';
import {
  AvailableDeviceController,
  BluetoothAdapter,
  BluetoothBondedDeviceController,
  BluetoothDevice,
  BluetoothProfile,
  BluetoothProfileManager,
  BluetoothProfileStateChangeListener,
  BluetoothWindowBondDeviceViewModel,
  BondedDeviceController,
  HearingAidProfile,
  ProfileConnectionState,
  ProfileId,
  StateChangeParam
} from '@ohos/settings.bluetooth';

export default function bluetoothAdapterTest() {
  describe('bluetoothAdapterTest', () => {

    beforeAll(() => {
      BluetoothAdapter.getInstance().start();
    });

    afterAll(() => {
      BluetoothAdapter.getInstance().stop();
    });

    /*
    * @tc.number:bluetoothAdapterTest_001
    * @tc.name: 蓝牙齿轮按钮可点击验证
    * @tc.type: TestType.FUNCTION
    * @tc.desc: 收到蓝牙协议失败消息，更新齿轮可点击性
    */
    it('bluetoothAdapterTest_001', TestType.FUNCTION, () => {
      const profileId: number = 1;
      const deviceId: string = '1234567';

      class TestListener implements BluetoothProfileStateChangeListener {
        getListenKey(): string {
          return '';
        }

        onBluetoothProfileStateChange(profileId: ProfileId, stateChangeParam: StateChangeParam): void {
        }

        onConnectResult(deviceId: string, result: number): void {
        }
      };

      let device: BluetoothDevice = new BluetoothDevice(deviceId);
      let profile: BluetoothProfile = new BluetoothProfile(new TestListener());
      profile.lastState = ProfileConnectionState.STATE_CONNECTING;
      BluetoothAdapter.getInstance().profileManager.profiles.set(profileId, profile);
      let mocker: MockKit = new MockKit();
      let mockGetDeviceState: Function = mocker.mockFunc(profile, profile.getDeviceState);
      when(mockGetDeviceState)(deviceId).afterReturn(ProfileConnectionState.STATE_CONNECTED);

      // 正在断连->断连，有一个协议连接上: 齿轮可点击
      BluetoothAdapter.getInstance().handleDisconnectedState(profileId, device);
      expect(device.getEnable()).assertEqual(true);

      // 正在断连->断连，所有协议没连接上: 齿轮可点击
      when(mockGetDeviceState)(deviceId).afterReturn(ProfileConnectionState.STATE_DISCONNECTED);
      BluetoothAdapter.getInstance().handleDisconnectedState(profileId, device);
      expect(device.getEnable()).assertEqual(true);

      // 正在断连->断连，有一个协议没连接上: 齿轮 不可点击
      let profileManage: BluetoothProfileManager = BluetoothAdapter.getInstance().profileManager;
      let mockIsAllDisconnected: Function = mocker.mockFunc(profileManage, profileManage.isAllProfileDisconnected);
      when(mockIsAllDisconnected)(deviceId).afterReturn(false);
      BluetoothAdapter.getInstance().handleDisconnectedState(profileId, device);
      expect(device.getEnable()).assertEqual(false);
      mocker.clearAll();
    });
    /*
    * @tc.number:bluetoothAdapterTest_002
    * @tc.name: 断开蓝牙连接
    * @tc.type: TestType.FUNCTION
    * @tc.desc: 收到断开蓝牙请求时执行断开蓝牙连接
    */
    it('bluetoothAdapterTest_002', TestType.FUNCTION, () => {
      const deviceId: string = '1234567';
      let mocker: MockKit = new MockKit();
      let disconnectDevice = BluetoothAdapter.getInstance().disconnectDevice(deviceId);
      expect(disconnectDevice).assertFalse();
      mocker.clearAll();
    });

    it('setIsPairBluetoothAdapterTest_001', 0, () => {
      BluetoothAdapter.getInstance().setIsPairBluetoothAdapter(true);
      let isPairBluetoothAdapter: boolean = BluetoothAdapter.getInstance().isPairBluetoothAdapter;
      expect(isPairBluetoothAdapter).assertEqual(true);
    });

    it('setIsIgnoreDiscoveryTest_001', 0, () => {
      BluetoothAdapter.getInstance().setIsIgnoreDiscovery(true);
      let isIgnoreDiscovery: boolean = BluetoothAdapter.getInstance().isIgnoreDiscovery;
      expect(isIgnoreDiscovery).assertEqual(true);
    });

    it('setIsIgnoreDiscoveryTest_002', 0, () => {
      let key: string = BluetoothAdapter.getInstance().getListenKey();
      expect(key !== null).assertTrue();
    });

    it('setBondedDeviceTest_001', 0, () => {
      BluetoothAdapter.getInstance().cachedBondedDevices.clear();
      let deviceId: string = '10:DC:A5:F3:49:B7';
      let device = new BluetoothDevice(deviceId);
      BluetoothAdapter.getInstance().setBondedDevice(deviceId, device);
      let count: number = BluetoothAdapter.getInstance().getBondedDevicesCount();
      expect(count).assertEqual(1);

      let devices = BluetoothAdapter.getInstance().getBondedDevices();
      for (let device of Array.from(devices)) {
        expect(device.deviceId).assertEqual(deviceId);
      }

      expect(BluetoothAdapter.getInstance().isBondedDevice(deviceId)).assertEqual(true);
      expect(BluetoothAdapter.getInstance().getBondedDevice(deviceId)).assertEqual(device);

      let newDeviceName: string = '测试名称';
      BluetoothAdapter.getInstance().setBondedDeviceName(deviceId, newDeviceName);
      let deviceName: string = BluetoothAdapter.getInstance().getBondedDevice(deviceId).deviceName;
      expect(deviceName).assertEqual(newDeviceName);
    });

    it('registerListenerTest_001', 0, () => {
      let listener = new AvailableDeviceController();
      BluetoothAdapter.getInstance().registerRemoveSummaryListener(listener);
      expect(BluetoothAdapter.getInstance().bluetoothRemoveSummaryListeners.length).assertEqual(1);
      BluetoothAdapter.getInstance().unRegisterRemoveSummaryListener(listener);
      expect(BluetoothAdapter.getInstance().bluetoothRemoveSummaryListeners.length).assertEqual(0);
    });

    it('registerListenerTest_002', 0, () => {
      let listener = new AvailableDeviceController();
      BluetoothAdapter.getInstance().registerStateChangeListener(listener);
      expect(BluetoothAdapter.getInstance().stateChangeListeners.length).assertEqual(1);
      BluetoothAdapter.getInstance().unRegisterStateChangeListener(listener);
      expect(BluetoothAdapter.getInstance().stateChangeListeners.length).assertEqual(0);
    });

    it('registerListenerTest_003', 0, () => {
      let listener = new AvailableDeviceController();
      BluetoothAdapter.getInstance().registerDeviceChangeListener(listener);
      expect(BluetoothAdapter.getInstance().deviceChangeListeners.length).assertEqual(1);
      BluetoothAdapter.getInstance().unRegisterDeviceChangeListener(listener);
      expect(BluetoothAdapter.getInstance().deviceChangeListeners.length).assertEqual(0);
    });

    it('registerListenerTest_004', 0, () => {
      let listener2 = new BluetoothBondedDeviceController();
      BluetoothAdapter.getInstance().registerDeviceNameUpdateListener(listener2);
      expect(BluetoothAdapter.getInstance().deviceNameUpdateListeners.length).assertEqual(1);
      BluetoothAdapter.getInstance().unRegisterDeviceNameUpdateListener(listener2);
      expect(BluetoothAdapter.getInstance().deviceNameUpdateListeners.length).assertEqual(0);
    });

    it('registerListenerTest_005', 0, () => {
      let listener = new AvailableDeviceController();
      BluetoothAdapter.getInstance().registerBondChangeListener(listener);
      expect(BluetoothAdapter.getInstance().bondChangeListeners.length).assertEqual(1);
      BluetoothAdapter.getInstance().unRegisterBondChangeListener(listener);
      expect(BluetoothAdapter.getInstance().bondChangeListeners.length).assertEqual(0);
    });

    it('registerListenerTest_006', 0, () => {
      let listener = new AvailableDeviceController();
      BluetoothAdapter.getInstance().registerLoadChangeListener(listener);
      expect(BluetoothAdapter.getInstance().loadingStateChangerListeners.length).assertEqual(1);
      BluetoothAdapter.getInstance().unRegisterLoadChangeListener(listener);
      expect(BluetoothAdapter.getInstance().loadingStateChangerListeners.length).assertEqual(0);
    });

    it('registerListenerTest_007', 0, () => {
      let listener2 = new BluetoothBondedDeviceController();
      BluetoothAdapter.getInstance().registerProfileStateChangeListener(listener2);
      expect(BluetoothAdapter.getInstance().profileStateChangeListeners.length).assertEqual(1);
      BluetoothAdapter.getInstance().unRegisterProfileStateChangeListener(listener2);
      expect(BluetoothAdapter.getInstance().profileStateChangeListeners.length).assertEqual(0);
    });

    it('registerListenerTest_008', 0, () => {
      let listener3 = new BondedDeviceController();
      BluetoothAdapter.getInstance().registerStateChangeListener(listener3);
      expect(BluetoothAdapter.getInstance().stateChangeListeners.length).assertEqual(1);
      BluetoothAdapter.getInstance().unRegisterStateChangeListener(listener3);
      expect(BluetoothAdapter.getInstance().stateChangeListeners.length).assertEqual(0);
    });

    it('setAutoDiscoveryTest_009', 0, () => {
      let listener3 = new BondedDeviceController();
      BluetoothAdapter.getInstance().registerDeviceChangeListener(listener3);
      expect(BluetoothAdapter.getInstance().deviceChangeListeners.length).assertEqual(1);
      BluetoothAdapter.getInstance().unRegisterDeviceChangeListener(listener3);
      expect(BluetoothAdapter.getInstance().deviceChangeListeners.length).assertEqual(0);
    });

    it('setAutoDiscoveryTest_010', 0, () => {
      let listener3 = new BondedDeviceController();
      BluetoothAdapter.getInstance().registerBondChangeListener(listener3);
      expect(BluetoothAdapter.getInstance().bondChangeListeners.length).assertEqual(1);
      BluetoothAdapter.getInstance().unRegisterBondChangeListener(listener3);
      expect(BluetoothAdapter.getInstance().bondChangeListeners.length).assertEqual(0);
    });

    it('setAutoDiscoveryTest_011', 0, () => {
      let listener3 = new BondedDeviceController();
      BluetoothAdapter.getInstance().registerProfileStateChangeListener(listener3);
      expect(BluetoothAdapter.getInstance().profileStateChangeListeners.length).assertEqual(1);
      BluetoothAdapter.getInstance().unRegisterProfileStateChangeListener(listener3);
      expect(BluetoothAdapter.getInstance().profileStateChangeListeners.length).assertEqual(0);
    });

    it('setAutoDiscoveryTest_012', 0, () => {
      let listener3 = new BondedDeviceController();
      BluetoothAdapter.getInstance().registerBondedDeviceChangeListener(listener3);
      expect(BluetoothAdapter.getInstance().bondedDeviceChangeListeners.length).assertEqual(1);
      BluetoothAdapter.getInstance().unregisterBondedDeviceChangeListener(listener3);
      expect(BluetoothAdapter.getInstance().bondedDeviceChangeListeners.length).assertEqual(0);
    });

    it('setAutoDiscoveryTest_013', 0, () => {
      let listener4 = new BluetoothWindowBondDeviceViewModel();
      BluetoothAdapter.getInstance().registerStateChangeListener(listener4);
      expect(BluetoothAdapter.getInstance().stateChangeListeners.length).assertEqual(1);
      BluetoothAdapter.getInstance().unRegisterStateChangeListener(listener4);
      expect(BluetoothAdapter.getInstance().stateChangeListeners.length).assertEqual(0);
    });

    it('setAutoDiscoveryTest_014', 0, () => {
      let listener4 = new BluetoothWindowBondDeviceViewModel();
      BluetoothAdapter.getInstance().registerDeviceChangeListener(listener4);
      expect(BluetoothAdapter.getInstance().deviceChangeListeners.length).assertEqual(1);
      BluetoothAdapter.getInstance().unRegisterDeviceChangeListener(listener4);
      expect(BluetoothAdapter.getInstance().deviceChangeListeners.length).assertEqual(0);
    });

    it('setAutoDiscoveryTest_015', 0, () => {
      let listener4 = new BluetoothWindowBondDeviceViewModel();
      BluetoothAdapter.getInstance().registerBondChangeListener(listener4);
      expect(BluetoothAdapter.getInstance().bondChangeListeners.length).assertEqual(1);
      BluetoothAdapter.getInstance().unRegisterBondChangeListener(listener4);
      expect(BluetoothAdapter.getInstance().bondChangeListeners.length).assertEqual(0);

    });

    it('setAutoDiscoveryTest_016', 0, () => {
      let listener4 = new BluetoothWindowBondDeviceViewModel();
      BluetoothAdapter.getInstance().registerProfileStateChangeListener(listener4);
      expect(BluetoothAdapter.getInstance().profileStateChangeListeners.length).assertEqual(1);
      BluetoothAdapter.getInstance().unRegisterProfileStateChangeListener(listener4);
      expect(BluetoothAdapter.getInstance().profileStateChangeListeners.length).assertEqual(0);
    });

    it('setAutoDiscoveryTest_017', 0, () => {
      let listener4 = new BluetoothWindowBondDeviceViewModel();
      BluetoothAdapter.getInstance().registerBondedDeviceChangeListener(listener4);
      expect(BluetoothAdapter.getInstance().bondedDeviceChangeListeners.length).assertEqual(1);
      BluetoothAdapter.getInstance().unregisterBondedDeviceChangeListener(listener4);
      expect(BluetoothAdapter.getInstance().bondedDeviceChangeListeners.length).assertEqual(0);
    });

    it('setAutoDiscoveryTest_018', 0, () => {
      let listener4 = new BluetoothWindowBondDeviceViewModel();
      BluetoothAdapter.getInstance().registerDeviceNameUpdateListener(listener4);
      expect(BluetoothAdapter.getInstance().deviceNameUpdateListeners.length).assertEqual(1);
      BluetoothAdapter.getInstance().unRegisterDeviceNameUpdateListener(listener4);
      expect(BluetoothAdapter.getInstance().deviceNameUpdateListeners.length).assertEqual(0);
    });
  });

  describe('Cached_bonded_devices_test', () => {
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

    beforeAll(() => {
      BluetoothAdapter.getInstance().start();
    });

    afterAll(() => {
      BluetoothAdapter.getInstance().stop();
    });

    beforeEach(() => {
      BluetoothAdapter.getInstance().cachedBondedDevices.clear();
    })

    it('bonded_device_set_test_001', 0, () => {
      const mainDevice = new BluetoothDevice(mainDeviceId);
      mainDevice.addProfile(ProfileId.PROFILE_HEARING_AID, new HearingAidProfile(new TestListener()));
      mainDevice.setHearingAidId(hearingAidId);

      const subDevice = new BluetoothDevice(subDeviceId);
      subDevice.addProfile(ProfileId.PROFILE_HEARING_AID, new HearingAidProfile(new TestListener()));
      subDevice.setHearingAidId(hearingAidId);

      BluetoothAdapter.getInstance().setBondedDevice(mainDeviceId, mainDevice);
      expect(BluetoothAdapter.getInstance().getBondedDevicesCount()).assertEqual(1);
      BluetoothAdapter.getInstance().setBondedDevice(subDeviceId, subDevice);
      expect(BluetoothAdapter.getInstance().getBondedDevicesCount()).assertEqual(1);
      expect(BluetoothAdapter.getInstance().isBondedDevice(mainDeviceId)).assertTrue();
      expect(BluetoothAdapter.getInstance().isBondedDevice(subDeviceId)).assertTrue();
      expect(BluetoothAdapter.getInstance().isBondedMainDevice(mainDeviceId)).assertTrue();
      expect(BluetoothAdapter.getInstance().isBondedMainDevice(subDeviceId)).assertFalse();
      expect(BluetoothAdapter.getInstance().isBondedSubDevice(mainDeviceId)).assertFalse();
      expect(BluetoothAdapter.getInstance().isBondedSubDevice(subDeviceId)).assertTrue();
    });

    it('bonded_device_set_test_002', 0, () => {
      const mainDevice = new BluetoothDevice(mainDeviceId);
      mainDevice.addProfile(ProfileId.PROFILE_HEARING_AID, new HearingAidProfile(new TestListener()));

      const subDevice = new BluetoothDevice(subDeviceId);
      subDevice.addProfile(ProfileId.PROFILE_HEARING_AID, new HearingAidProfile(new TestListener()));

      BluetoothAdapter.getInstance().setBondedDevice(mainDeviceId, mainDevice);
      expect(BluetoothAdapter.getInstance().getBondedDevicesCount()).assertEqual(1);
      BluetoothAdapter.getInstance().setBondedDevice(subDeviceId, subDevice);
      expect(BluetoothAdapter.getInstance().getBondedDevicesCount()).assertEqual(2);
      expect(BluetoothAdapter.getInstance().isBondedDevice(mainDeviceId)).assertTrue();
      expect(BluetoothAdapter.getInstance().isBondedDevice(subDeviceId)).assertTrue();
      expect(BluetoothAdapter.getInstance().isBondedMainDevice(mainDeviceId)).assertTrue();
      expect(BluetoothAdapter.getInstance().isBondedMainDevice(subDeviceId)).assertTrue();
      expect(BluetoothAdapter.getInstance().isBondedSubDevice(mainDeviceId)).assertFalse();
      expect(BluetoothAdapter.getInstance().isBondedSubDevice(subDeviceId)).assertFalse();
    });

    it('bonded_device_set_test_003', 0, () => {
      const mainDevice = new BluetoothDevice(mainDeviceId);
      mainDevice.setHearingAidId(hearingAidId);

      const subDevice = new BluetoothDevice(subDeviceId);
      subDevice.setHearingAidId(hearingAidId);

      BluetoothAdapter.getInstance().setBondedDevice(mainDeviceId, mainDevice);
      expect(BluetoothAdapter.getInstance().getBondedDevicesCount()).assertEqual(1);
      BluetoothAdapter.getInstance().setBondedDevice(subDeviceId, subDevice);
      expect(BluetoothAdapter.getInstance().getBondedDevicesCount()).assertEqual(2);
      expect(BluetoothAdapter.getInstance().isBondedDevice(mainDeviceId)).assertTrue();
      expect(BluetoothAdapter.getInstance().isBondedDevice(subDeviceId)).assertTrue();
      expect(BluetoothAdapter.getInstance().isBondedMainDevice(mainDeviceId)).assertTrue();
      expect(BluetoothAdapter.getInstance().isBondedMainDevice(subDeviceId)).assertTrue();
      expect(BluetoothAdapter.getInstance().isBondedSubDevice(mainDeviceId)).assertFalse();
      expect(BluetoothAdapter.getInstance().isBondedSubDevice(subDeviceId)).assertFalse();
    });

    it('bonded_device_get_test_001', 0, () => {
      const mainDevice = new BluetoothDevice(mainDeviceId);
      mainDevice.addProfile(ProfileId.PROFILE_HEARING_AID, new HearingAidProfile(new TestListener()));
      mainDevice.setHearingAidId(hearingAidId);

      const subDevice = new BluetoothDevice(subDeviceId);
      subDevice.addProfile(ProfileId.PROFILE_HEARING_AID, new HearingAidProfile(new TestListener()));
      subDevice.setHearingAidId(hearingAidId);

      BluetoothAdapter.getInstance().setBondedDevice(mainDeviceId, mainDevice);
      BluetoothAdapter.getInstance().setBondedDevice(subDeviceId, subDevice);
      expect(BluetoothAdapter.getInstance().getBondedDevice(mainDeviceId)).assertEqual(mainDevice);
      expect(BluetoothAdapter.getInstance().getBondedDevice(subDeviceId)).assertUndefined();

      expect(BluetoothAdapter.getInstance().getBondedDeviceOrSubDevice(mainDeviceId)).assertEqual(mainDevice);
      expect(BluetoothAdapter.getInstance().getBondedDeviceOrSubDevice(subDeviceId)).assertEqual(subDevice);

      expect(BluetoothAdapter.getInstance().findMainDeviceBySubDevice(mainDeviceId)).assertUndefined();
      expect(BluetoothAdapter.getInstance().findMainDeviceBySubDevice(subDeviceId)).assertEqual(mainDevice);
    });

    it('bonded_device_get_test_002', 0, () => {
      const mainDevice = new BluetoothDevice(mainDeviceId);

      const subDevice = new BluetoothDevice(subDeviceId);

      BluetoothAdapter.getInstance().setBondedDevice(mainDeviceId, mainDevice);
      BluetoothAdapter.getInstance().setBondedDevice(subDeviceId, subDevice);
      expect(BluetoothAdapter.getInstance().getBondedDevice(mainDeviceId)).assertEqual(mainDevice);
      expect(BluetoothAdapter.getInstance().getBondedDevice(subDeviceId)).assertEqual(subDevice);

      expect(BluetoothAdapter.getInstance().getBondedDeviceOrSubDevice(mainDeviceId)).assertEqual(mainDevice);
      expect(BluetoothAdapter.getInstance().getBondedDeviceOrSubDevice(subDeviceId)).assertEqual(subDevice);

      expect(BluetoothAdapter.getInstance().findMainDeviceBySubDevice(mainDeviceId)).assertUndefined();
      expect(BluetoothAdapter.getInstance().findMainDeviceBySubDevice(subDeviceId)).assertUndefined();
    });
  });
}