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

import { ArgumentMatchers, describe, expect, it, MockKit, when, } from '@ohos/hypium'
import { MenuEntry, NearLinkConstants, NearLinkUtils } from '@ohos/settings.nearlink';
import { NearLinkDevice } from '@ohos/settings.nearlink/src/main/ets/model/NearLinkDevice';
import { BondDeviceViewModel } from '@ohos/settings.nearlink/src/main/ets/viewmodel/BondDeviceViewModel'
import manager from '@hms.nearlink.manager';

export default function bondDeviceViewModelTest() {

  describe('bondDeviceViewModelTest', (): void => {
    let bondDeviceViewModel: BondDeviceViewModel = new BondDeviceViewModel();

    it('test_init', 0, (): void => {
      let bondDevicesMenu: MenuEntry[] = [];
      let resA = bondDeviceViewModel.init(bondDevicesMenu);
      expect(resA === null).assertFalse();
      let resB = bondDeviceViewModel.init(bondDevicesMenu);
      expect(resB === null).assertFalse();
    })

    it('test_onPageShow', 0, (): void => {
      let mocker: MockKit = new MockKit();
      let contextfunc: Function = mocker.mockFunc(NearLinkUtils,NearLinkUtils.isOn);
      when(contextfunc)(ArgumentMatchers.any).afterReturn(false);
      let resA = bondDeviceViewModel.onPageShow();
      expect(resA === null).assertFalse();
      when(contextfunc)(ArgumentMatchers.any).afterReturn(true);
      let resB = bondDeviceViewModel.onPageShow();
      expect(resB === null).assertFalse();
      mocker.clear(NearLinkUtils);
    })

    it('test_onSwitchStateChange', 0, (): void => {
      let resA = bondDeviceViewModel.onSwitchStateChange(1);
      expect(resA === null).assertFalse();
      let resB = bondDeviceViewModel.onSwitchStateChange(7);
      expect(resB === null).assertFalse();
    })

    it('test_onBondStateChange', 0, (): void => {
      let stateParam: manager.PairingStateParam =
        AppStorage.get<manager.PairingStateParam>('null') as manager.PairingStateParam;
      let resA = bondDeviceViewModel.onBondStateChange(stateParam);
      expect(resA === null).assertFalse();
    })

    it('test_onConnectStateChange', 0, (): void => {
      let stateParam: manager.ConnectionStateParam =
        AppStorage.get<manager.ConnectionStateParam>('null') as manager.ConnectionStateParam;
      let resA = bondDeviceViewModel.onConnectStateChange(stateParam);
      expect(resA === null).assertFalse();
    })

    it('test_changeConnectState', 0, (): void => {
      let deviceId: string = AppStorage.get<string>('deviceId') as string;
      let resA = bondDeviceViewModel.changeConnectState(deviceId);
      expect(resA === null).assertFalse();
      let arr: MenuEntry[] = [];
      bondDeviceViewModel.bondDevicesMenu = arr;
      let resB = bondDeviceViewModel.changeConnectState('deviceId');
      expect(resB === null).assertFalse();
      let obj: MenuEntry = new MenuEntry({title: 'test', key: 'deviceId', rssi: 7, isConnect: true});
      arr.push(obj);
      bondDeviceViewModel.bondDevicesMenu = arr;
      let resC = bondDeviceViewModel.changeConnectState('deviceId');
      expect(resC === null).assertFalse();
      arr = [];
      obj = new MenuEntry({title: 'test', key: 'deviceId', rssi: 7, isConnect: false});
      arr.push(obj);
      bondDeviceViewModel.bondDevicesMenu = arr;
      let resD = bondDeviceViewModel.changeConnectState('deviceId');
      expect(resD === null).assertFalse();
    })

    it('test_startConnect', 0, (): void => {
      let deviceId: string = AppStorage.get<string>('deviceId') as string;
      let resA = bondDeviceViewModel.startConnect(deviceId);
      expect(resA === null).assertFalse();
      let arr: MenuEntry[] = [];
      bondDeviceViewModel.bondDevicesMenu = arr;
      let resB = bondDeviceViewModel.startConnect('deviceId');
      expect(resB === null).assertFalse();
      let obj: MenuEntry = new MenuEntry({title: 'test', key: 'deviceId', rssi: 7, isConnect: true});
      arr.push(obj);
      bondDeviceViewModel.bondDevicesMenu = arr;
      let resC = bondDeviceViewModel.startConnect('deviceId');
      expect(resC === null).assertFalse();
    })

    it('test_onConnectResult', 0, (): void => {
      let deviceId: string = AppStorage.get<string>('deviceId') as string;
      let resA = bondDeviceViewModel.onConnectResult(deviceId, 0);
      expect(resA === null).assertFalse();
      deviceId = 'deviceId';
      let resB = bondDeviceViewModel.onConnectResult(deviceId, 0);
      expect(resB === null).assertFalse();
      let resC = bondDeviceViewModel.onConnectResult(deviceId, 7);
      expect(resC === null).assertFalse();
    })

    it('test_isConnecting', 0, (): void => {
      let deviceId: string = AppStorage.get<string>('deviceId') as string;
      let resA = bondDeviceViewModel.isConnecting(deviceId, 0);
      expect(resA === null).assertFalse();
      deviceId = 'deviceId';
      let resB = bondDeviceViewModel.isConnecting(deviceId, 0);
      expect(resB === null).assertFalse();
      let resC = bondDeviceViewModel.isConnecting(deviceId, 7);
      expect(resC === null).assertFalse();
      deviceId = 'deviceIdTest';
      let resD = bondDeviceViewModel.isConnecting(deviceId, 7);
      expect(resD === null).assertFalse();
    })

    it('test_openConnectFailedDialog', 0, (): void => {
      let mocker: MockKit = new MockKit();
      let contextfunc: Function = mocker.mockFunc(NearLinkUtils,NearLinkUtils.isOn);
      when(contextfunc)(ArgumentMatchers.any).afterReturn(false);
      let resA: Object = (bondDeviceViewModel as object)['openConnectFailedDialog']('deviceId');
      expect(resA === null).assertFalse();
      when(contextfunc)(ArgumentMatchers.any).afterReturn(true);
      let resB: Object = (bondDeviceViewModel as object)['openConnectFailedDialog']('deviceId');
      expect(resB === null).assertFalse();
      mocker.clear(NearLinkUtils);
    })

    it('test_setBondDeviceMenu', 0, (): void => {
      let resA: Object = (bondDeviceViewModel as object)['setBondDeviceMenu']();
      expect(resA === null).assertFalse();
    })

    it('test_removeBondDevice', 0, (): void => {
      let arr: MenuEntry[] = [];
      bondDeviceViewModel.bondDevicesMenu = arr;
      let resA: Object = (bondDeviceViewModel as object)['removeBondDevice']('deviceId');
      expect(resA === null).assertFalse();
      let obj: MenuEntry = new MenuEntry({title: 'test', key: 'deviceId', rssi: 7, isConnect: true});
      arr.push(obj);
      bondDeviceViewModel.bondDevicesMenu = arr;
      let resB: Object = (bondDeviceViewModel as object)['removeBondDevice']('deviceId');
      expect(resB === null).assertFalse();
    })

    it('test_addBondDevice', 0, (): void => {
      let device: NearLinkDevice = new NearLinkDevice('deviceIdTest');
      let arr: MenuEntry[] = [];
      let obj: MenuEntry = new MenuEntry({title: 'test', key: 'deviceIdTest', rssi: 7, isConnect: true});
      arr.push(obj);
      bondDeviceViewModel.bondDevicesMenu = arr;
      let resB: Object = (bondDeviceViewModel as object)['addBondDevice'](device, 10000);
      expect(resB === null).assertFalse();
      device = new NearLinkDevice('deviceId');
      let resC: Object = (bondDeviceViewModel as object)['addBondDevice'](device, 10000);
      expect(resC === null).assertFalse();
    })

    it('test_compareMenu', 0, (): void => {
      let menu1: MenuEntry = AppStorage.get<MenuEntry>('menu1') as MenuEntry;
      let menu2: MenuEntry = AppStorage.get<MenuEntry>('menu2') as MenuEntry;
      let resA: Object = (bondDeviceViewModel as object)['compareMenu'](menu1, menu2);
      expect(resA === -1).assertTrue();
      menu1 = new MenuEntry({title: 'test', key: 'deviceId', rssi: 7, isConnect: true});
      let resB: Object = (bondDeviceViewModel as object)['compareMenu'](menu1, menu2);
      expect(resB === null).assertFalse();
      menu2 = new MenuEntry({title: 'test', key: 'deviceId', rssi: 7, isConnect: true});
      let resC: Object = (bondDeviceViewModel as object)['compareMenu'](menu1, menu2);
      expect(resC === null).assertFalse();
    })

    it('test_getSubTitle', 0, (): void => {
      let subtitle = ((bondDeviceViewModel as object)['getSubTitle'](NearLinkConstants.STATE_CONNECTED)) as object;
      expect(subtitle === null).assertFalse();
      subtitle =(bondDeviceViewModel as object)['getSubTitle'](NearLinkConstants.STATE_CONNECTING);
      expect(subtitle === null).assertFalse();
      subtitle =(bondDeviceViewModel as object)['getSubTitle'](NearLinkConstants.STATE_DISCONNECTED);
      expect(subtitle === null).assertFalse();
    })

  })
}

