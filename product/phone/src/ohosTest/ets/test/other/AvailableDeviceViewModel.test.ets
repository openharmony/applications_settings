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

import { ArgumentMatchers, describe, expect, it, MockKit,when } from '@ohos/hypium';
import { AvailableDeviceViewModel } from '@ohos/settings.nearlink/src/main/ets/viewmodel/AvailableDeviceViewModel';
import { NearLinkDevice } from '@ohos/settings.nearlink/src/main/ets/model/NearLinkDevice';
import { MenuEntry, NearLinkUtils } from '@ohos/settings.nearlink';

export default function availableDeviceViewModelTest() {
  let availableDevice = new AvailableDeviceViewModel();
  describe('availableDeviceViewModelTest', () => {

    it('test_onSwitchStateChange', 0, (): void => {
      let resA = availableDevice.onSwitchStateChange(1);
      expect(resA === null).assertFalse();
      let resB = availableDevice.onSwitchStateChange(2);
      expect(resB === null).assertFalse();
    })

    it('test_onAvailableDeviceAdded', 0, (): void => {
      let device: NearLinkDevice = AppStorage.get<NearLinkDevice>('null') as NearLinkDevice;
      let resA = availableDevice.onAvailableDeviceAdded(device);
      expect(resA === null).assertFalse();
      device = new NearLinkDevice('deviceId', 'deviceName', 0, new ArrayBuffer(46), true);
      let arr: MenuEntry[] = [];
      availableDevice.availableDevicesMenu = arr;
      let resB = availableDevice.onAvailableDeviceAdded(device);
      expect(resB === null).assertFalse();
      let obj: MenuEntry = new MenuEntry({title: 'test', key: 'deviceId', rssi: 7});
      arr.push(obj);
      availableDevice.availableDevicesMenu = arr;
      let resC = availableDevice.onAvailableDeviceAdded(device);
      expect(resC === null).assertFalse();
    })

    it('test_onAvailableDevicesRefresh', 0, (): void => {
      let arr: MenuEntry[] = [];
      availableDevice.availableDevicesMenu = arr;
      let resA = availableDevice.onAvailableDevicesRefresh();
      expect(resA === null).assertFalse();
      let obj: MenuEntry = new MenuEntry({title: 'test', key: 'deviceId', rssi: 7});
      arr.push(obj);
      arr.push(obj);
      availableDevice.availableDevicesMenu = arr;
      let resB = availableDevice.onAvailableDevicesRefresh();
      expect(resB === null).assertFalse();
    })

    it('test_onChangeLoadStatus', 0, (): void => {
      let resA = availableDevice.onChangeLoadStatus(false);
      expect(resA === null).assertFalse();
      let arr: MenuEntry[] = [];
      availableDevice.availableDevicesMenu = arr;
      let resB = availableDevice.onChangeLoadStatus(true);
      expect(resB === null).assertFalse();
      let obj: MenuEntry = new MenuEntry({title: 'test', key: 'deviceId', rssi: 7});
      arr.push(obj);
      availableDevice.availableDevicesMenu = arr;
      let resC = availableDevice.onChangeLoadStatus(false);
      expect(resC === null).assertFalse();
    })

    it('test_onDeviceAttributesChanged', 0, (): void => {
      let device: NearLinkDevice = new NearLinkDevice('');
      let resA = availableDevice.onDeviceAttributesChanged(device);
      expect(resA === null).assertFalse();
      device = new NearLinkDevice('deviceId', 'deviceName', 0, new ArrayBuffer(46), true);
      let resB = availableDevice.onDeviceAttributesChanged(device);
      expect(resB === null).assertFalse();
      availableDevice.availableDevicesMenu = [];
      let resC = availableDevice.onDeviceAttributesChanged(device);
      expect(resC === null).assertFalse();
    })

    it('test_pairDevice', 0, (): void => {
      let resA = availableDevice.pairDevice('');
      expect(resA === null).assertFalse();
      let resB = availableDevice.pairDevice('deviceId');
      expect(resB === null).assertFalse();
    })

    it('test_onPairResult', 0, (): void => {
      let resA = availableDevice.onPairResult('', 0);
      expect(resA === null).assertFalse();
      let resB = availableDevice.onPairResult('deviceId', 0);
      expect(resB === null).assertFalse();
      let resC = availableDevice.onPairResult('deviceId', 7);
      expect(resC === null).assertFalse();
    })

    it('test_openPairFailedDialog', 0, (): void => {
      let mocker: MockKit = new MockKit();
      let contextfunc: Function = mocker.mockFunc(NearLinkUtils,NearLinkUtils.isOn);
      when(contextfunc)(ArgumentMatchers.any).afterReturn(false);
      let resA: Object = (availableDevice as object)['openPairFailedDialog']('deviceId');
      expect(resA === null).assertFalse();
      when(contextfunc)(ArgumentMatchers.any).afterReturn(true);
      let resB: Object = (availableDevice as object)['openPairFailedDialog']('deviceId');
      expect(resB === null).assertFalse();
      mocker.clear(NearLinkUtils);
    })

    it('test_findMenuEntry', 0, (): void => {
      let arr: MenuEntry[] = [];
      let obj: MenuEntry = new MenuEntry({title: 'test', key: 'test', rssi: 7});
      let obj1: MenuEntry = new MenuEntry({title: 'test', key: 'deviceId', rssi: 7});
      arr.push(obj);
      arr.push(obj1);
      availableDevice.availableDevicesMenu = arr;
      let resA:Object = (availableDevice as object)['findMenuEntry']('deviceId');
      expect(resA === 0).assertFalse();
    })

    it('test_addSearchMessageMenuIfNeed', 0, (): void => {
      let arr: MenuEntry[] = [];
      availableDevice.availableDevicesMenu = arr;
      availableDevice.isSearchMessageShow = false;
      let resA: Object = (availableDevice as object)['addSearchMessageMenuIfNeed']();
      expect(resA === null).assertFalse();
      availableDevice.isSearchMessageShow = true;
      let obj: MenuEntry = new MenuEntry({title: 'test', key: 'deviceId', rssi: 7});
      arr.push(obj);
      availableDevice.availableDevicesMenu = arr;
      let resB: Object = (availableDevice as object)['addSearchMessageMenuIfNeed']();
      expect(resB === null).assertFalse();
    })

    it('test_removeSearchMessageMenuIfNeed', 0, (): void => {
      let arr: MenuEntry[] = [];
      availableDevice.availableDevicesMenu = arr;
      availableDevice.isSearchMessageShow = false;
      let resA: Object = (availableDevice as object)['removeSearchMessageMenuIfNeed']();
      expect(resA === null).assertFalse();
      availableDevice.isSearchMessageShow = true;
      let obj: MenuEntry = new MenuEntry({title: 'test', key: 'deviceId', rssi: 7});
      arr.push(obj);
      availableDevice.availableDevicesMenu = arr;
      let resB: Object = (availableDevice as object)['removeSearchMessageMenuIfNeed']();
      expect(resB === null).assertFalse();
    })

    it('test_updateDevice', 0, (): void => {
      let device: NearLinkDevice = new NearLinkDevice('deviceId', 'deviceName', 0, new ArrayBuffer(46), true);
      let arr: MenuEntry[] = [];
      let obj: MenuEntry = new MenuEntry({title: 'test', key: 'test', rssi: 7});
      let obj1: MenuEntry = new MenuEntry({title: 'deviceName', key: 'deviceId', rssi: 0});
      let obj2: MenuEntry = new MenuEntry({title: 'test', key: 'deviceId', rssi: 7});
      arr.push(obj);
      arr.push(obj1);
      arr.push(obj2);
      availableDevice.availableDevicesMenu = arr;
      let resA: Object = (availableDevice as object)['updateDevice'](device);
      expect(resA === null).assertFalse();
    })

    it('test_checkSequenceChange', 0, (): void => {
      let newDevicesMenu: MenuEntry[] = [];
      let arr: MenuEntry[] = [];
      availableDevice.availableDevicesMenu = arr;
      let resA: Object = (availableDevice as object)['checkSequenceChange'](newDevicesMenu);
      expect(resA === false).assertTrue();
      let obj: MenuEntry = new MenuEntry({title: 'deviceName', key: 'deviceId', rssi: 0});
      let obj1: MenuEntry = new MenuEntry({title: 'test', key: 'test', rssi: 7});
      let obj2: MenuEntry = new MenuEntry({title: 'test', key: 'deviceId', rssi: 7});
      arr.push(obj);
      arr.push(obj1);
      newDevicesMenu.push(obj);
      newDevicesMenu.push(obj2);
      let resB: Object = (availableDevice as object)['checkSequenceChange'](newDevicesMenu);
      expect(resB === true).assertTrue();
      newDevicesMenu = [];
      let resC: Object = (availableDevice as object)['checkSequenceChange'](newDevicesMenu);
      expect(resC === true).assertTrue();
    })

  });
}

