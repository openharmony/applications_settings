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

import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import {
  WifiSetupIpButtonController
} from '@ohos/settings.wifi/src/main/ets/controller/new/WifiSetupIpButtonController'
import wifiManager from '@ohos.wifiManager'
import { WifiSecurityType } from '@ohos/settings.wifi'
import { WapiPskType } from '@ohos/settings.wifi/src/main/ets/WifiMenuManager'
import { AddOtherWlanConfigManager } from '@ohos/settings.wifi/src/main/ets/AddOtherWlanConfigManager'
import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel'

export default function WifiSetupIpButtonControllerTest() {
  describe('WifiSetupIpButtonControllerTest', () => {
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
    it('test_appear', 0, () => {
      let test = new WifiSetupIpButtonController();
      let compParam: CompCtrlParam = {
        compId: '001',
        component: {
          id: '000000-5555'
        },
      };
      test.init(compParam);
      AddOtherWlanConfigManager.getInstance().wifiConfig = undefined;
      test.aboutToAppear();
      let config = getDefaultWifiConfig();
      AddOtherWlanConfigManager.getInstance().wifiConfig = config;
      test.aboutToAppear();
      config.staticIp = undefined;
      AddOtherWlanConfigManager.getInstance().wifiConfig = config;
      test.aboutToAppear();
      test.destroy();
      expect(test !== null).assertTrue();
    })
    it('test_disappear', 0, () => {
      let test = new WifiSetupIpButtonController();
      test.aboutToDisappear();
      let config = getDefaultWifiConfig();
      test.wifiConfig = config;
      AddOtherWlanConfigManager.getInstance().wifiConfig = undefined;
      test.aboutToDisappear();
      AddOtherWlanConfigManager.getInstance().wifiConfig = config;
      test.aboutToDisappear();
      test.onSaveButtonClicked();
      test.aboutToDisappear();
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
      ipAddress: 1,
      gateway: 1,
      prefixLength: 1,
      dnsServers: [1],
      domains: ['1'],
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
