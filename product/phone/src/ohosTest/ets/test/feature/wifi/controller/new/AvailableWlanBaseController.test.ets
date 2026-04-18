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

import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when,
  ArgumentMatchers } from '@ohos/hypium'
import { CommonUtils, SettingsDataUtils } from '@ohos/settings.common'
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus'
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource'
import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel'
import { SettingToggleState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel'
import { wifiTracker, WifiUtils } from '@ohos/settings.wifi'
import AvailableWlanController from '@ohos/settings.wifi/src/main/ets/controller/new/AvailableWlanController'
import { AccessPoint, ApMenu, ApMenuData, WLAN_SWITCH_ID } from '@ohos/settings.wifi/src/main/ets/model/WifiModel'
import { WlanItemModel } from '@ohos/settings.wifi/src/main/ets/model/WlanItemModel'
import wifiManager from '@ohos.wifiManager';

export default function AvailableWlanBaseControllerTest() {
  describe('AvailableWlanBaseControllerTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    it('test_init', 0, () => {
      let test = new AvailableWlanBaseTestClass();
      let compParam: CompCtrlParam = {
        compId: '001',
        component: {
          id: '000000-5555',
        },
      };
      let mocker: MockKit = new MockKit();
      let isWifiConnectedFunc: Function = mocker.mockFunc(WifiUtils, WifiUtils.isWifiConnected);
      when(isWifiConnectedFunc)(ArgumentMatchers.any).afterReturn(true);
      test.init(compParam);
      when(isWifiConnectedFunc)(ArgumentMatchers.any).afterReturn(false);
      test.init(compParam);
      test.onConnectResult(1);
      test.onConnectResult(0);
      compParam.component.visible = true;
      test.init(compParam);
      let wifiUnsafeDialogFunc: Function = mocker.mockFunc(WifiUtils, WifiUtils.needShowConnectFailedDialog);
      when(wifiUnsafeDialogFunc)(ArgumentMatchers.any).afterReturn(true);
      test.onConnectResult(0);
      when(wifiUnsafeDialogFunc)(ArgumentMatchers.any).afterReturn(false);
      test.onConnectResult(0);
      test.destroy();
      test.destroy();
      expect(test !== null).assertTrue();
      mocker.clear(WifiUtils);
    })
    it('test_onApMenusChanged', 0, () => {
      let test = new AvailableWlanBaseTestClass();
      test.onApMenusChanged([]);
      let dataSource = new OrderedDataSource();
      let compParam: CompCtrlParam = {
        dataSource: dataSource,
        compId: '002',
        component: {
          id: '000000-5555',
        }
      };
      test.init(compParam);
      test.onApMenusChanged([]);
      let menuData1: Partial<ApMenuData> = {
        ssid: "Netgear_2G",
        bssid: "00:11:22:33:44:55",
        bssidType: 1,
        level: 70,
        securityType: 2,
        config: {
          ssid: "Netgear_2G",
          bssid: "00:11:22:33:44:55",
          securityType: 2,
          isHiddenSsid: false,
          preSharedKey: 'share1'
        },
        supportedWifiCategory: 1,
        isHiLinkNetwork: false,
        scanResults: []
      };
      let menuData2: Partial<ApMenuData> = {
        key: 'menuData2',
        ssid: "Netgear_5G",
        bssid: "00:11:22:33:44:11",
        bssidType: 1,
        level: 70,
        securityType: 2,
        config: {
          ssid: "Netgear_5G",
          bssid: "00:11:22:33:44:22",
          securityType: 2,
          isHiddenSsid: false,
          preSharedKey: 'share2'
        },
        supportedWifiCategory: 1,
        isHiLinkNetwork: false,
        scanResults: []
      };
      let menu1 = new ApMenu(menuData1);
      let menu2 = new ApMenu(menuData2);
      test.onApMenusChanged([menu1,menu2]);
      test.onApMenusChanged([menu1,menu2]);
      expect(test !== null).assertTrue();
      test.registerDataChange();
      EventBus.getInstance().emit(WLAN_SWITCH_ID);
      let toggleState: SettingToggleState = {
        state: true
      };
      EventBus.getInstance().emit(WLAN_SWITCH_ID,toggleState);
      test.unRegisterDataChange();
      expect(test !== null).assertTrue();
    })
    it('test_registerEvent', 0, () => {
      let test = new AvailableWlanBaseTestClass();
      test.registerDataChange();
      EventBus.getInstance().emit(WLAN_SWITCH_ID);
      let toggleState: SettingToggleState = {
        state: false
      };
      EventBus.getInstance().emit(WLAN_SWITCH_ID,toggleState);
      toggleState.state = true;
      EventBus.getInstance().emit(WLAN_SWITCH_ID,toggleState);
      test.unRegisterDataChange();
      let mocker: MockKit = new MockKit();
      let isPageExistFunc: Function = mocker.mockFunc(CommonUtils,
        CommonUtils.isPageExist);
      when(isPageExistFunc)(ArgumentMatchers.any).afterReturn(true);
      test.unRegisterDataChange();
      expect(test !== null).assertTrue();
      mocker.clear(CommonUtils);
    })
    it('test_WifiConnectionChange', 0, () => {
      let test = new AvailableWlanBaseTestClass();
      {
        (test as object)['onWifiConnectionChange'](0);
        let dataSource = new OrderedDataSource();
        (test as object)['dataSource'] = dataSource;
        (test as object)['onWifiConnectionChange'](0);
        let item = test.createApMenu({}, true);
        item.accessPoint = undefined;
        dataSource.pushData(item);
        (test as object)['dataSource'] = dataSource;
        (test as object)['onWifiConnectionChange'](0);
        let item1 = test.createApMenu({}, true);
        dataSource.pushData(item1);
        (test as object)['dataSource'] = dataSource;
        (test as object)['onWifiConnectionChange'](0);
        test.onPageShow(item1);
        (test as object)['onWifiConnectionChange'](0);
      }
      (test as object)['onWifiConnectionChange'](1);
      (test as object)['onWifiConnectionChange'](2);
      expect(test !== null).assertTrue()
    })
    it('test_updateConnectedAp', 0, async () => {
      let test = new AvailableWlanBaseTestClass();
      await (test as object)['updateConnectedAp'](true);
      (test as object)['createAccessPoint']();
      (test as object)['getDeviceConfigs']();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(wifiTracker,
        wifiTracker.getLinkedInfoByTaskPool);
      let linkInfo = test.testLinkInfo();
      when(mockFunc)(ArgumentMatchers.any).afterReturn(linkInfo);
      await (test as object)['updateConnectedAp'](true);
      linkInfo.connState = wifiManager.ConnState.CONNECTED;
      await (test as object)['updateConnectedAp'](true);
      let getKeyFunc = mocker.mockFunc(WifiUtils, WifiUtils.getApKey);
      when(getKeyFunc)(ArgumentMatchers.any).afterReturn('apKey1');
      await (test as object)['updateConnectedAp'](false);
      let setDataFunc = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
      when(setDataFunc)(ArgumentMatchers.any).afterReturn(linkInfo.ssid);
      await (test as object)['updateConnectedAp'](false);
      expect(test.accessPoint !== null).assertTrue();
      mocker.clear(SettingsDataUtils);
      mocker.clear(wifiTracker);
      mocker.clear(WifiUtils);
    })
    it('test_updateNetworkStatus', 0, async () => {
      let test = new AvailableWlanBaseTestClass();
      let mocker: MockKit = new MockKit();
      let bearerFunc: Function = mocker.mockFunc(WifiUtils, WifiUtils.isBearerWifi);
      when(bearerFunc)(ArgumentMatchers.any).afterReturn(true);
      (test as object)['onNetCapabilitiesChange']();
      when(bearerFunc)(ArgumentMatchers.any).afterReturn(false);
      (test as object)['onNetCapabilitiesChange']();
      let mockFunc: Function = mocker.mockFunc(WifiUtils, WifiUtils.isWifiNetworkValidated);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(true);
      (test as object)['updateNetworkStatus']();
      let linkFunc: Function = mocker.mockFunc(wifiTracker,
        wifiTracker.getLinkedInfoByTaskPool);
      let linkInfo = test.testLinkInfo();
      when(linkFunc)(ArgumentMatchers.any).afterReturnNothing();
      (test as object)['updateNetworkStatus']();
      when(linkFunc)(ArgumentMatchers.any).afterReturn(linkInfo);
      (test as object)['updateNetworkStatus']();
      when(mockFunc)(ArgumentMatchers.any).afterReturn(false);
      (test as object)['updateNetworkStatus']();
      test.accessPoint = new AccessPoint(null)
      when(linkFunc)(ArgumentMatchers.any).afterReturnNothing();
      (test as object)['updateNetworkStatus']();
      when(linkFunc)(ArgumentMatchers.any).afterReturn(linkInfo);
      (test as object)['updateNetworkStatus']();
      expect(test.accessPoint !== null).assertTrue();
      mocker.clear(wifiTracker);
      mocker.clear(WifiUtils);
    })
    it('test_updateConnectedSummary', 0, async () => {
      let test = new AvailableWlanBaseTestClass();
      await (test as object)['updateConnectedSummary']('summary');
      test.accessPoint = new AccessPoint(null);
      await (test as object)['updateConnectedSummary']('summary');
      let dataSource = new OrderedDataSource();
      let item = test.createApMenu({}, true);
      item.accessPoint = undefined;
      dataSource.pushData(item);
      (test as object)['dataSource'] = dataSource;
      await (test as object)['updateConnectedSummary']('summary');
      let item1 = test.createApMenu({}, true);
      dataSource.pushData(item1);
      (test as object)['dataSource'] = dataSource;
      await (test as object)['updateConnectedSummary']('summary');
      item1.icon = undefined;
      item1.desc = undefined;
      await (test as object)['updateConnectedSummary']('summary');
      expect(test.accessPoint !== null).assertTrue()
    })
    it('test_onWifiRssiChange', 0, (done: Function) => {
      try {
        let test = new AvailableWlanBaseTestClass();
        (test as object)['isRegister'] = true;
        (test as object)['onWifiRssiChange'](0);
        (test as object)['isRegister'] = false;
        (test as object)['isNetworkUnavailable'] = true;
        (test as object)['onWifiRssiChange'](0);
        (test as object)['isNetworkUnavailable'] = false;
        (test as object)['onWifiRssiChange'](0);
        let mocker: MockKit = new MockKit();
        let bearerFunc: Function = mocker.mockFunc(WifiUtils, WifiUtils.isWifiConnected);
        when(bearerFunc)(ArgumentMatchers.any).afterReturn(false);
        (test as object)['onWifiRssiChange'](0);
        when(bearerFunc)(ArgumentMatchers.any).afterReturn(true);
        (test as object)['onWifiRssiChange'](0);
        mocker.clear(WifiUtils);
      } catch(e) {

      } finally {
        done();
      }
    })
    it('test_updateLinkedInfo', 0, async () => {
      let test = new AvailableWlanBaseTestClass();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(wifiTracker,
        wifiTracker.getLinkedInfoByTaskPool);
      let linkInfo = test.testLinkInfo();
      when(mockFunc)(ArgumentMatchers.any).afterReturnNothing();
      await (test as object)['updateLinkedInfo']();
      when(mockFunc)(ArgumentMatchers.any).afterReturn(linkInfo);
      await (test as object)['updateLinkedInfo']();
      mocker.clear(wifiTracker);
    })
    it('test_refreshConnectedMenu', 0, () => {
      let test = new AvailableWlanBaseTestClass();
      let dataSource = new OrderedDataSource();
      let item = test.createApMenu({}, true);
      item.accessPoint = undefined;
      item.isLoading = false
      dataSource.pushData(item);
      (test as object)['dataSource'] = dataSource;
      (test as object)['refreshConnectedMenu']();
      item.isLoading = true;
      (test as object)['refreshConnectedMenu']();
      test.accessPoint = new AccessPoint(null);
      test.accessPoint.lastLinkedInfo = test.testLinkInfo();
      (test as object)['refreshConnectedMenu']();
      let item1 = test.createApMenu({}, true);
      dataSource.pushData(item1);
      (test as object)['dataSource'] = dataSource;
      (test as object)['refreshConnectedMenu']();
      test.accessPoint = undefined;
      (test as object)['refreshConnectedMenu']();
    })
  })
}

export class AvailableWlanBaseTestClass extends AvailableWlanController {
  public registerDataChange(): void {
    super.registerDataChange();
  }
  public unRegisterDataChange(): void {
    super.unRegisterDataChange();
  }
  protected isModelLoading(key: string): boolean {
    if (key) {
      return true;
    }
    return false;
  }
  public createApMenu(item: Partial<ApMenuData>, isLast: boolean): WlanItemModel {
    let model = super.createApMenu(item,isLast);
    model.accessPoint = new AccessPoint(null);
    return model;
  }

  testLinkInfo(): wifiManager.WifiLinkedInfo {
    return {
      ssid: "MyHomeNetwork",
      bssid: "00:11:22:33:44:55",
      networkId: 12345,
      rssi: -60,
      band: 1,
      linkSpeed: 54,
      rxLinkSpeed: 72,
      maxSupportedTxLinkSpeed: 144,
      maxSupportedRxLinkSpeed: 216,
      frequency: 2412,
      isHidden: false,
      isRestricted: true,
      chload: 50,
      snr: 20,
      macType: 0,
      macAddress: "AA:BB:CC:DD:EE:FF",
      ipAddress: 1921681100,
      suppState: 0,
      connState: 0,
      channelWidth: 0,
      wifiStandard: 0,
      supportedWifiCategory:0,
      isHiLinkNetwork: true,
      isHiLinkProNetwork: false
    }
  }

}

