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
import wifiManager from '@ohos.wifiManager'
import { WifiSecurityType, WifiUtils } from '@ohos/settings.wifi'
import { WapiPskType } from '@ohos/settings.wifi/src/main/ets/WifiMenuManager'
import { WifiHilinkController } from '@ohos/settings.wifi/src/main/ets/controller/new/WifiHilinkController'
import { RANDOM_MAC_TYPE_CHANGED_EVENT,
  WifiConnectionState,
  WlanDisconnectedReason } from '@ohos/settings.wifi/src/main/ets/model/WifiModel'
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus'

export default function WifiHilinkControllerTest() {
  describe('WifiHilinkControllerTest', () => {
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
    it('test_onConnectResult', 0, () => {
      let obj = AppStorage.get<Boolean>('isConnectCancel');
      let test = new WifiHilinkController(undefined, false);
      AppStorage.setOrCreate<Boolean>('isConnectCancel', true);
      test.onConnectResult(0);
      AppStorage.setOrCreate<Boolean>('isConnectCancel', false);
      test.onConnectResult(1);
      test.onConnectResult(0);
      test = new WifiHilinkController(getDefaultWifiConfig(), true);
      test.onConnectResult(0);
      let mocker: MockKit = new MockKit();
      let showDialogFunc: Function = mocker.mockFunc(WifiUtils, WifiUtils.needShowConnectFailedDialog);
      when(showDialogFunc)(ArgumentMatchers.any).afterReturn(false);
      test.onConnectResult(0);
      when(showDialogFunc)(ArgumentMatchers.any).afterReturn(true);
      test.onConnectResult(0);
      let reasonFunc: Function = mocker.mockFunc(WifiUtils, WifiUtils.getDisconnectedReason);
      when(reasonFunc)(ArgumentMatchers.any).afterReturn(WlanDisconnectedReason.DISC_REASON_IGNORE);
      test.onConnectResult(0);
      when(reasonFunc)(ArgumentMatchers.any).afterReturn(WlanDisconnectedReason.WRONG_PWD);
      test.onConnectResult(0);
      when(reasonFunc)(ArgumentMatchers.any).afterReturn(WlanDisconnectedReason.DISC_REASON_CONNECTION_REJECTED);
      test.onConnectResult(0);
      AppStorage.setOrCreate<Boolean>('isConnectCancel', obj);
      expect(test !== null).assertTrue();
      mocker.clear(WifiUtils);
    })
    it('test_aboutToAppear', 0, () => {
      let test = new WifiHilinkController(undefined, false);
      test.init();
      test.destroy();
      test.aboutToAppear();
      test.aboutToDisappear();
      test = new WifiHilinkController(getDefaultWifiConfig(), true);
      test.aboutToAppear();
      test.aboutToDisappear();
      expect(test !== null).assertTrue();
    })
    it('test_event', 0, () => {
      let test = new WifiHilinkController(undefined);
      test.aboutToAppear();
      (test as object)['onWifiConnectionChange'](WifiConnectionState.HILINK);
      (test as object)['onWifiConnectionChange'](WifiConnectionState.DISCONNECTED);
      EventBus.getInstance().emit(RANDOM_MAC_TYPE_CHANGED_EVENT);
      test = new WifiHilinkController(getDefaultWifiConfig(), true);
      test.aboutToAppear();
      EventBus.getInstance().emit(RANDOM_MAC_TYPE_CHANGED_EVENT);
      (test as object)['showOrHideLoadingDialog'](true, 'content');
      (test as object)['onWifiConnectionChange'](WifiConnectionState.DISCONNECTED);
      (test as object)['onWifiConnectionChange'](WifiConnectionState.HILINK);
      (test as object)['onWifiConnectionChange'](WifiConnectionState.DISCONNECTED);
      (test as object)['onWifiConnectionChange'](WifiConnectionState.CONNECTED);
      expect(test !== null).assertTrue();
    })
  })
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