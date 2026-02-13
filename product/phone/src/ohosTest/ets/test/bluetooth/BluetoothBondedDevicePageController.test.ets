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

import { afterAll, ArgumentMatchers, beforeAll, describe, expect, it, MockKit, when } from '@ohos/hypium';
import {
  BluetoothAdapter,
  BluetoothBondedDevicePageController,
  BluetoothDevice,
  BluetoothProfile,
  BluetoothProfileStateChangeListener,
  ProfileConnectionState,
  ProfileId,
} from '@ohos/settings.bluetooth';
import { ShareType } from '@ohos/settings.bluetooth/src/main/ets/constants/BluetoothConstants';
import { DeviceUtil } from '@ohos/settings.common';
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { BluetoothUtils, DisconnectCause } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { VolumeStateInfo } from '../../../../main/ets/Setting/Volume/model/VolumeType';

export default function bluetoothBondedDevicePageControllerTest() {
  describe('bluetoothBondedDevicePageControllerTest', () => {

    beforeAll(() => {
    });

    afterAll(() => {
    });

    it('initTest_001', 0, (done: Function) => {
      try {
        let controller = new BluetoothBondedDevicePageController();
        controller.init({
          compId: '', component: {
            id: 'componentId'
          }
        });
        expect(controller.getListenKey()).assertEqual('Bluetooth_Bonded_Device_Page_Controller');
        controller.init({
          compId: '123456', component: {
            id: 'componentId', url: 'pathUrl', type: PageType.PAGE_TYPE_STANDARD
          } as SettingPageModel
        });
        expect(controller.tag).assertEqual('BluetoothBondedDevicePageController: ');
        controller.onBluetoothProfileStateChange(ProfileId.PROFILE_A2DP_SOURCE, {
          deviceId: 'deviceId',
          state: ProfileConnectionState.STATE_DISCONNECTED, cause: DisconnectCause.USER_DISCONNECT,
        });
        controller.onConnectResult('deviceId', 1, true);
        controller.destroy();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bluetoothBondedDevicePageControllerTest_002', 0, (done: Function) => {
      try {
        let controller = new BluetoothBondedDevicePageController();
        controller.init({
          compId: '123123',
          component: AppStorage.get<SettingPageModel>('component') as SettingPageModel
        });
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePc);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
        controller.init({
          compId: '123123',
          param: {
            deviceName: 'deviceName',
            getConnectableProfiles: () => VolumeStateInfo
          } as ESObject,
          component: {
            id: '242341213212',
            url: 'pathUrl',
            type: PageType.PAGE_TYPE_STANDARD,
          } as SettingPageModel
        });
        mocker.clear(DeviceUtil);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bluetoothBondedDevicePageControllerTest_003', 0, (done: Function) => {
      try {
        let controller = new BluetoothBondedDevicePageController;
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePhone);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
        (controller as object)['getVolumeMenuTitle']();
        let mockfunc2: Function =
          mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePhone);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(false);
        let mockfunc3: Function =
          mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePad);
        when(mockfunc3)(ArgumentMatchers.any).afterReturn(true);
        (controller as object)['getVolumeMenuTitle']();
        let mockfunc4: Function =
          mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePad);
        when(mockfunc4)(ArgumentMatchers.any).afterReturn(false);
        let mockfunc5: Function =
          mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePc);
        when(mockfunc5)(ArgumentMatchers.any).afterReturn(true);
        (controller as object)['getVolumeMenuTitle']();
        let mockfunc6: Function =
          mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePc);
        when(mockfunc6)(ArgumentMatchers.any).afterReturn(false);
        (controller as object)['getVolumeMenuTitle']();
        mocker.clear(DeviceUtil);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bluetoothBondedDevicePageControllerTest_004', 0, (done: Function) => {
      try {
        let controller = new BluetoothBondedDevicePageController();
        controller.updateShareType(ShareType.SHARE_NAME_AND_PHONE_NUMBER);
        controller.updateShareType(ShareType.SHARE_ALL);
        controller.updateShareType(ShareType.SHARE_NOTHING);
        controller.updateShareType(3);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bluetoothBondedDevicePageControllerTest_005', 0, (done: Function) => {
      try {
        let controller = new BluetoothBondedDevicePageController();
        controller.device = null!;
        (controller as object)['onSelectDeviceType'](7);
        controller.device = new BluetoothDevice('121323', 10);
        (controller as object)['onSelectDeviceType'](5);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bluetoothBondedDevicePageControllerTest_006', 0, (done: Function) => {
      try {
        let controller = new BluetoothBondedDevicePageController();
        let params: BluetoothProfileStateChangeListener = {
          getListenKey: () => {
            return 'test';
          }
        } as ESObject;
        controller.profileMap = new Map([
          [ProfileId.PROFILE_HANDS_FREE_AUDIO_GATEWAY, new BluetoothProfile(params)],
          [ProfileId.PROFILE_A2DP_SOURCE, new BluetoothProfile(params)],
          [ProfileId.PROFILE_HID_HOST, new BluetoothProfile(params)]
        ])
        let profileGroupModel: SettingGroupModel = {
          id: 'profile_group',
          type: GroupType.GROUP_TYPE_STANDARD,
          items: [],
        };
        DeviceUtil.deviceType = 'tablet';
        (controller as object)['setProfileCustomItemModels'](profileGroupModel);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bluetoothBondedDevicePageControllerTest_006_01', 0, (done: Function) => {
      try {
        let controller = new BluetoothBondedDevicePageController();
        let params: BluetoothProfileStateChangeListener = {
          getListenKey: () => {
            return 'test';
          }
        } as ESObject;
        controller.profileMap = new Map([
          [2, new BluetoothProfile(params)],
          [3, new BluetoothProfile(params)],
          [5, new BluetoothProfile(params)]
        ])
        let profileGroupModel: SettingGroupModel = {
          id: 'profile_group',
          type: GroupType.GROUP_TYPE_STANDARD,
          items: [],
        };
        (controller as object)['setProfileCustomItemModels'](profileGroupModel);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bluetoothBondedDevicePageControllerTest_007', 0, (done: Function) => {
      try {
        let controller = new BluetoothBondedDevicePageController();
        let params: BluetoothProfileStateChangeListener = {
          getListenKey: () => {
            return 'test';
          }
        } as ESObject;
        controller.profileMap = new Map([
          [ProfileId.PROFILE_A2DP_SOURCE, new BluetoothProfile(params)],
        ]);
        (controller as object)['setAutoPlayMenu']();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bluetoothBondedDevicePageControllerTest_008', 0, (done: Function) => {
      try {
        let controller = new BluetoothBondedDevicePageController();
        let params: BluetoothProfileStateChangeListener = {
          getListenKey: () => {
            return 'test';
          }
        } as ESObject;
        controller.profileMap = new Map([
          [ProfileId.PROFILE_HID_HOST, new BluetoothProfile(params)],
        ]);
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(BluetoothAdapter, BluetoothAdapter.getInstance().isDeviceConnected);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
        (controller as object)['setAutoPlayMenu']();
        let mockfunc2: Function =
          mocker.mockFunc(BluetoothAdapter, BluetoothAdapter.getInstance().isDeviceConnected);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(true);
        (controller as object)['setAutoPlayMenu']();
        mocker.clear(BluetoothAdapter);
      } catch (e) {
      } finally {
        done()
      }
    });

    it('bluetoothBondedDevicePageControllerTest_009', 0, (done: Function) => {
      try {
        let controller = new BluetoothBondedDevicePageController();
        let params: BluetoothProfileStateChangeListener = {
          getListenKey: () => {
            return 'test';
          }
        } as ESObject;
        controller.profileMap = new Map([
          [ProfileId.PROFILE_HID_HOST, new BluetoothProfile(params)],
        ]);
        controller.setDeviceTypeMenus()
      } catch (e) {
      } finally {
        done()
      }
    });

    it('bluetoothBondedDevicePageControllerTest_010', 0, (done: Function) => {
      try {
        let controller = new BluetoothBondedDevicePageController();
        let params: BluetoothProfileStateChangeListener = {
          getListenKey: () => {
            return 'test';
          }
        } as ESObject;
        controller.profileMap = new Map([
          [ProfileId.PROFILE_A2DP_SOURCE, new BluetoothProfile(params)],
          [ProfileId.PROFILE_HANDS_FREE_AUDIO_GATEWAY, new BluetoothProfile(params)],
        ]);
        controller.setDeviceTypeMenus()
      } catch (e) {
      } finally {
        done()
      }
    });

    it('bluetoothBondedDevicePageControllerTest_011', 0, (done: Function) => {
      try {
        let controller = new BluetoothBondedDevicePageController();
        let component: SettingBaseModel = {
          id: '122'
        } as SettingBaseModel;
        let mocker: MockKit = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(BluetoothUtils, BluetoothUtils.isBluetoothStateOn);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
        controller.onPageShow(component);
        let mockfunc2: Function =
          mocker.mockFunc(BluetoothUtils, BluetoothUtils.isBluetoothStateOn);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(false);
        controller.onPageShow(component);
        mocker.clear(BluetoothUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bluetoothBondedDevicePageControllerTest_012', 0, (done: Function) => {
      try {
        let controller = new BluetoothBondedDevicePageController();
        let params: BluetoothProfileStateChangeListener = {
          getListenKey: () => {
            return 'test';
          }
        } as ESObject;
        controller.profileMap = new Map([
          [ProfileId.PROFILE_A2DP_SOURCE, new BluetoothProfile(params)],
        ]);
        controller.device!.absoluteVolumeSupport = true;
        (controller as object)['setVolumeMenu']();
      } catch (e) {
      } finally {
        done()
      }
    });
  });
}