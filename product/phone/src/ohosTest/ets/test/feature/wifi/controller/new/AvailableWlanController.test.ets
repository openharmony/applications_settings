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
import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel'
import { WifiMenuManager } from '@ohos/settings.wifi'
import { AdvSecurityModeManager } from '@ohos/settings.wifi/src/main/ets/AdvSecurityModeManager'
import AvailableWlanController from '@ohos/settings.wifi/src/main/ets/controller/new/AvailableWlanController'
import { AccessPoint, ApMenuData,
  OTHER_WLAN_CONNECT_EVENT,
  WifiSecurityType } from '@ohos/settings.wifi/src/main/ets/model/WifiModel'
import { WlanItemModel } from '@ohos/settings.wifi/src/main/ets/model/WlanItemModel'
import wifiManager from '@ohos.wifiManager';
import { WapiPskType } from '@ohos/settings.wifi/src/main/ets/WifiMenuManager'
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus'
import { AVAILABLE_WLAN_DETAIL_CLICK_EVENT } from '@ohos/settings.wifi/src/main/ets/component/WlanItemResultComponent'
import { AddOtherWlanConfigManager } from '@ohos/settings.wifi/src/main/ets/AddOtherWlanConfigManager'
import { WifiPasswordConfigManager } from '@ohos/settings.wifi/src/main/ets/WifiPasswordConfigManager'

export default function AvailableWlanControllerTest() {
  describe('AvailableWlanControllerTest', () => {
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
      let compParam: CompCtrlParam = {
        compId: '001',
        component: {
          id: '000000-5555'
        },
      };
      let test = new AvailableWlanControllerTestClass();
      test.init(compParam);
    })
    it('test_onMenuClick', 0, () => {
      let test = new AvailableWlanControllerTestClass();
      let item = test.createApMenu({},true);
      expect(test.onMenuClick(item)).assertTrue();
      item.config = getDefaultWifiConfig();
      expect(test.onMenuClick(item)).assertTrue();
      item.securityType = wifiManager.WifiSecurityType.WIFI_SEC_TYPE_OPEN;
      expect(test.onMenuClick(item)).assertTrue();
      let mocker: MockKit = new MockKit();
      let wifiUnsafeDialogFunc: Function = mocker.mockFunc(AdvSecurityModeManager.getInstance(),
        AdvSecurityModeManager.getInstance().isNeedShowWifiUnsafeDialog);
      when(wifiUnsafeDialogFunc)(ArgumentMatchers.any).afterReturn(true);
      expect(test.onMenuClick(item)).assertFalse();
      item.accessPoint = new AccessPoint(null);
      test.isPortalUnauthenticated = false;
      let isInOObeStageFunc: Function = mocker.mockFunc(WifiMenuManager,
        WifiMenuManager.isInOObeStage);
      when(isInOObeStageFunc)(ArgumentMatchers.any).afterReturn(true);
      expect(test.onMenuClick(item)).assertTrue();
      when(isInOObeStageFunc)(ArgumentMatchers.any).afterReturn(false);
      expect(test.onMenuClick(item)).assertTrue();
      test.isPortalUnauthenticated = true;
      expect(test.onMenuClick(item)).assertTrue();
      mocker.clear(AdvSecurityModeManager.getInstance());
      mocker.clear(WifiMenuManager);
    })
    it('test_onDetailClick', 0, () => {
      let test = new AvailableWlanControllerTestClass();
      let item = test.createApMenu({
        key: '3212-wew',
        bssid: 'bssid1',
      },true);
      expect(test.onDetailClick(item)).assertFalse();
      item.securityType = wifiManager.WifiSecurityType.WIFI_SEC_TYPE_OPEN;
      let mocker: MockKit = new MockKit();
      let wifiUnsafeDialogFunc: Function = mocker.mockFunc(AdvSecurityModeManager.getInstance(),
        AdvSecurityModeManager.getInstance().isNeedShowWifiUnsafeDialog);
      when(wifiUnsafeDialogFunc)(ArgumentMatchers.any).afterReturn(true);
      expect(test.onDetailClick(item)).assertFalse();
      when(wifiUnsafeDialogFunc)(ArgumentMatchers.any).afterReturn(false);
      expect(test.onDetailClick(item)).assertTrue();
      item.securityType = wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WEP;
      let config = getDefaultWifiConfig();
      item.config = config;
      expect(test.onDetailClick(item)).assertTrue();
      item.accessPoint = new AccessPoint(null);
      expect(test.onDetailClick(item)).assertTrue();
      mocker.clear(AdvSecurityModeManager.getInstance());
    })
    it('test_getConnectedApMenu', 0, () => {
      let test = new AvailableWlanControllerTestClass();
      expect(test.getConnectedApMenu()).assertEqual(null);
      let ap = new AccessPoint(null);
      ap.lastLinkedInfo = getDefaultLinkedInfo();
      test.accessPoint = ap;
      expect(test.getConnectedApMenu()).not().assertEqual(null);
      test.isWlanLog = true;
      expect(test.getConnectedApMenu()).not().assertEqual(null);
    })
    it('test_registerEvent', 0, () => {
      let test = new AvailableWlanControllerTestClass();
      test.registerDataChange();
      EventBus.getInstance().emit(AVAILABLE_WLAN_DETAIL_CLICK_EVENT);
      let item = test.createApMenu({},true);
      EventBus.getInstance().emit(AVAILABLE_WLAN_DETAIL_CLICK_EVENT, item);
      EventBus.getInstance().emit(OTHER_WLAN_CONNECT_EVENT);
      let mocker: MockKit = new MockKit();
      let config = getDefaultWifiConfig();
      let getConfigFunc: Function = mocker.mockFunc(AddOtherWlanConfigManager.getInstance(),
        AddOtherWlanConfigManager.getInstance().getConfig);
      when(getConfigFunc)(ArgumentMatchers.any).afterReturn(config);
      EventBus.getInstance().emit(OTHER_WLAN_CONNECT_EVENT);
      let getConfigFunc1: Function = mocker.mockFunc(WifiPasswordConfigManager.getInstance(),
        WifiPasswordConfigManager.getInstance().getConfig);
      when(getConfigFunc1)(ArgumentMatchers.any).afterReturn(config);
      EventBus.getInstance().emit(OTHER_WLAN_CONNECT_EVENT);
      test.unRegisterDataChange();
      mocker.clear(AddOtherWlanConfigManager.getInstance());
      mocker.clear(WifiPasswordConfigManager.getInstance());
    })
  })
}

export class AvailableWlanControllerTestClass extends AvailableWlanController {
  public isPortalUnauthenticated: boolean = false
  public createApMenu(item: Partial<ApMenuData>, isLast: boolean): WlanItemModel {
    return super.createApMenu(item,isLast);
  }
  public getConnectedApMenu(): WlanItemModel | null {
    return super.getConnectedApMenu();
  }
  public registerDataChange(): void {
    super.registerDataChange();
  }
  public unRegisterDataChange(): void {
    super.unRegisterDataChange();
  }
  public onMenuClick(item: WlanItemModel): boolean {
    return super.onMenuClick(item);
  }
}
function getDefaultLinkedInfo(): wifiManager.WifiLinkedInfo {
  return {
    ssid: "MyHomeNetwork",
    bssid: "00:11:22:33:44:55",
    networkId: 12345,
    rssi: -60,
    band: 1,
    linkSpeed: 54,
    rxLinkSpeed: 54,
    maxSupportedTxLinkSpeed: 150,
    maxSupportedRxLinkSpeed: 150,
    frequency: 2412,
    isHidden: false,
    isRestricted: true,
    chload: 50,
    snr: 20,
    macType: 0,
    macAddress: "00:11:22:33:44:55",
    ipAddress: 1921681100,
    suppState: 0,
    connState: 0,
    channelWidth: 0,
    wifiStandard: 0,
    supportedWifiCategory: 0,
    isHiLinkNetwork: false,
    isHiLinkProNetwork: false
  };
}

function getDefaultWifiConfig(): wifiManager.WifiDeviceConfig {
  return {
    ssid:  '123886-00000',
    bssid: 'apMenu.bssid',
    bssidType: 1,
    preSharedKey: '',
    securityType: WifiSecurityType.WIFI_SEC_TYPE_PSK,
    isHiddenSsid: false,
    ipType: wifiManager.IpType.DHCP,
    randomMacType: 0,
    netId: 1,
    staticIp: {
      ipAddress: 0,
      gateway: 0,
      prefixLength: 0,
      dnsServers: [],
      domains: [],
    },
    proxyConfig: {
      proxyMethod: wifiManager.ProxyMethod.METHOD_NONE,
    },
    wapiConfig: {
      wapiPskType: WapiPskType.WAPI_PSK_ASCII,
      wapiAsCert: '',
      wapiUserCert: '',
    },
    eapConfig: {
      eapMethod: wifiManager.EapMethod.EAP_PEAP,
      phase2Method: wifiManager.Phase2Method.PHASE2_MSCHAPV2,
      identity: '',
      anonymousIdentity: '',
      password: '',
      caCertAlias: '',
      caPath: '',
      clientCertAlias: '',
      certEntry: new Uint8Array(),
      certPassword: '',
      altSubjectMatch: '',
      domainSuffixMatch: '',
      realm: '',
      plmn: '',
      eapSubId: 0,
    }
  };
}
