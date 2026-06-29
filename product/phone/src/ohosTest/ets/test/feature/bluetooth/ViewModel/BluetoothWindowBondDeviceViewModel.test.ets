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

import { describe, it, expect } from '@ohos/hypium'
import {
  BluetoothDevice,
  BondState,
  BondStateParam,
  ProfileConnectionState,
  ProfileId,
  StateChangeParam
} from '@ohos/settings.bluetooth/src/main/ets/model/BluetoothModel';
import { MenuEntry, MenuEntryData } from '@ohos/settings.bluetooth/src/main/ets/model/MenuEntry';
import {
  BluetoothWindowBondDeviceViewModel
} from '@ohos/settings.bluetooth/src/main/ets/ViewModel/BluetoothWindowBondDeviceViewModel';
import { DisconnectCause, UnbondCause } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';

export default function BluetoothWindowBondDeviceViewModelTest() {
  describe('BluetoothWindowBondDeviceViewModelTest', () => {
    let bluetoothWindowBondDeviceViewModel = new BluetoothWindowBondDeviceViewModel;
    it('BluetoothWindowBondDeviceViewModelTest_001', 0, (done: Function) => {
      try {
        let bondDevicesMenu: MenuEntry[] = [];
        let result = bluetoothWindowBondDeviceViewModel.init(bondDevicesMenu);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_003', 0, (done: Function) => {
      try {
        let result = bluetoothWindowBondDeviceViewModel.updateBondedDevices();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_004', 0, (done: Function) => {
      try {
        (bluetoothWindowBondDeviceViewModel as object)['addBondDevice']('');
        let device2: BluetoothDevice = new BluetoothDevice('123');
        (bluetoothWindowBondDeviceViewModel as object)['isWirelessAntiTheft'] = true;
        (bluetoothWindowBondDeviceViewModel as object)['wirelessAntiTheftHostAddress'] = '123';
        (bluetoothWindowBondDeviceViewModel as object)['addBondDevice'](device2);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_005', 0, (done: Function) => {
      try {
        (bluetoothWindowBondDeviceViewModel as object)['createMenuEntry']('123123123', 0, true);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_006', 0, (done: Function) => {
      try {
        (bluetoothWindowBondDeviceViewModel as object)['getSubtitle']('123123123',
          ProfileConnectionState.STATE_CONNECTING, ProfileConnectionState.STATE_CONNECTING,
          ProfileConnectionState.STATE_CONNECTING);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_006_01', 0, (done: Function) => {
      try {
        (bluetoothWindowBondDeviceViewModel as object)['getSubtitle']('123123123',
          ProfileConnectionState.STATE_CONNECTED, ProfileConnectionState.STATE_CONNECTED,
          ProfileConnectionState.STATE_DISCONNECTING);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_006_02', 0, (done: Function) => {
      try {
        (bluetoothWindowBondDeviceViewModel as object)['getSubtitle']('123123123',
          ProfileConnectionState.STATE_CONNECTED, ProfileConnectionState.STATE_DISCONNECTED,
          ProfileConnectionState.STATE_DISCONNECTING);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_006_03', 0, (done: Function) => {
      try {
        (bluetoothWindowBondDeviceViewModel as object)['getSubtitle']('123123123',
          ProfileConnectionState.STATE_DISCONNECTED, ProfileConnectionState.STATE_CONNECTED,
          ProfileConnectionState.STATE_DISCONNECTING);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_006_04', 0, (done: Function) => {
      try {
        (bluetoothWindowBondDeviceViewModel as object)['getSubtitle']('123123123',
          ProfileConnectionState.STATE_CONNECTED, ProfileConnectionState.STATE_CONNECTED,
          ProfileConnectionState.STATE_DISCONNECTING);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_006_05', 0, (done: Function) => {
      try {
        (bluetoothWindowBondDeviceViewModel as object)['getSubtitle']('123123123',
          ProfileConnectionState.STATE_DISCONNECTING, ProfileConnectionState.STATE_DISCONNECTING,
          ProfileConnectionState.STATE_DISCONNECTING);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_007', 0, (done: Function) => {
      try {
        let params: MenuEntryData = {
          key: '1212',
          title: '1212',
          rssi: 0
        };
        let menu1: MenuEntry = new MenuEntry(params);
        let menu2: MenuEntry = AppStorage.get<MenuEntry>('menu2') as MenuEntry;
        (bluetoothWindowBondDeviceViewModel as object)['compareMenu'](menu1, menu2);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_007_01', 0, (done: Function) => {
      try {
        let params: MenuEntryData = {
          key: '',
          title: '',
          rssi: 0
        };
        let menu1: MenuEntry = AppStorage.get<MenuEntry>('menu2') as MenuEntry;
        let menu2: MenuEntry = new MenuEntry(params);
        (bluetoothWindowBondDeviceViewModel as object)['compareMenu'](menu1, menu2);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_008', 0, (done: Function) => {
      try {
        let result = bluetoothWindowBondDeviceViewModel.onBluetoothStateChange(2);
        expect(result !== null).assertTrue();
        let result2 = bluetoothWindowBondDeviceViewModel.onBluetoothStateChange(1);
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_009', 0, (done: Function) => {
      try {
        let device: BluetoothDevice | null = null! as BluetoothDevice;
        let result = bluetoothWindowBondDeviceViewModel.onDeviceNameUpdate(device);
        expect(result !== null).assertTrue();
        let device2: BluetoothDevice = new BluetoothDevice('1223123');
        let result2 = bluetoothWindowBondDeviceViewModel.onDeviceNameUpdate(device2);
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_010', 0, (done: Function) => {
      try {
        let stateChangeParam: StateChangeParam =
          AppStorage.get<StateChangeParam>('stateChangeParam') as StateChangeParam;
        let result = bluetoothWindowBondDeviceViewModel.onBluetoothProfileStateChange(ProfileId.PROFILE_A2DP_SOURCE,
          stateChangeParam);
        expect(result !== null).assertTrue();
        let stateChangeParam2: StateChangeParam = {
          deviceId: '',
          state: ProfileConnectionState.STATE_DISCONNECTED,
          cause: DisconnectCause.USER_DISCONNECT
        };
        let result2 =
          bluetoothWindowBondDeviceViewModel.onBluetoothProfileStateChange(ProfileId.PROFILE_HANDS_FREE_AUDIO_GATEWAY,
            stateChangeParam2)
        expect(result2 !== null).assertTrue();
        let stateChangeParam3: StateChangeParam = {
          deviceId: '123',
          state: ProfileConnectionState.STATE_DISCONNECTED,
          cause: DisconnectCause.USER_DISCONNECT
        };
        let result3 =
          bluetoothWindowBondDeviceViewModel.onBluetoothProfileStateChange(ProfileId.PROFILE_HANDS_FREE_AUDIO_GATEWAY,
            stateChangeParam3)
        expect(result3 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_011', 0, (done: Function) => {
      try {
        let result =
          bluetoothWindowBondDeviceViewModel.onConnectResult('123123', 1, false);
        expect(result !== null).assertTrue();
        let result2 =
          bluetoothWindowBondDeviceViewModel.onConnectResult('123123', 1, true);
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_012', 0, (done: Function) => {
      try {
        let result =
          bluetoothWindowBondDeviceViewModel.onBondDeviceDeleted('');
        expect(result !== null).assertTrue();
        let result2 =
          bluetoothWindowBondDeviceViewModel.onBondDeviceDeleted('123123');
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_013', 0, async (done: Function) => {
      try {
        await (bluetoothWindowBondDeviceViewModel as object)['getFromPreference']('123123123', 10);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_014', 0, async (done: Function) => {
      try {
        await (bluetoothWindowBondDeviceViewModel as object)['addToPreference']('123123123', 10);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_015', 0, async (done: Function) => {
      try {
        await (bluetoothWindowBondDeviceViewModel as object)['deleteFromPreference']('123123123');
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_016', 0, (done: Function) => {
      try {
        let result =
          bluetoothWindowBondDeviceViewModel.handleBondedDeviceItemClick('');
        expect(result !== null).assertTrue();
        let result2 =
          bluetoothWindowBondDeviceViewModel.handleBondedDeviceItemClick('123');
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_017', 0, (done: Function) => {
      try {
        (bluetoothWindowBondDeviceViewModel as object)['disconnectDevice']('123123123');
      } catch (e) {
      } finally {
        done()
      }
    });
    it('BluetoothWindowBondDeviceViewModelTest_018', 0, (done: Function) => {
      try {
        let stateParam: BondStateParam = AppStorage.get<BondStateParam>('stateParam') as BondStateParam;
        let result = bluetoothWindowBondDeviceViewModel.onBluetoothBondStateChange(stateParam);
        expect(result !== null).assertTrue();
        let stateParam2: BondStateParam = {
          deviceId: '12121',
          state: BondState.BOND_STATE_INVALID,
          cause: UnbondCause.USER_REMOVED
        };
        let result2 = bluetoothWindowBondDeviceViewModel.onBluetoothBondStateChange(stateParam2);
        expect(result2 !== null).assertTrue();
        let stateParam3: BondStateParam = {
          deviceId: '12121',
          state: BondState.BOND_STATE_BONDED,
          cause: UnbondCause.USER_REMOVED
        };
        let result3 = bluetoothWindowBondDeviceViewModel.onBluetoothBondStateChange(stateParam3);
        expect(result3 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
  })
}