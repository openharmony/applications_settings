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
import { CompCtrlParam, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel'
import {
  WifiSetupProxySheetPageController
} from '@ohos/settings.wifi/src/main/ets/controller/new/WifiSetupProxySheetPageController'
import wifiManager from '@ohos.wifiManager';
import { WifiSecurityType } from '@ohos/settings.wifi';
import { WapiPskType } from '@ohos/settings.wifi/src/main/ets/WifiMenuManager';

export default function WifiSetupProxySheetPageControllerTest() {
  describe('WifiSetupProxySheetPageControllerTest', () => {
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
      let WifiSetupProxySheetPage = new WifiSetupProxySheetPageController();
      let compParam: CompCtrlParam = AppStorage.get<CompCtrlParam>('null') as CompCtrlParam;
      let resA = WifiSetupProxySheetPage.init(compParam);
      expect(resA === null).assertFalse();
      let obj: SettingBaseModel = {
        id: ''
      }
      compParam= {
        compId: '1',
        component: obj,
        param: obj
      }
      let resB = WifiSetupProxySheetPage.init(compParam);
      expect(resB === null).assertFalse();
    })

    it('test_onManualProxyChecked', 0, () => {
      let WifiSetupProxySheetPage = new WifiSetupProxySheetPageController();
      WifiSetupProxySheetPage.wifiConfig = undefined;
      let compParam: CompCtrlParam = AppStorage.get<CompCtrlParam>('null') as CompCtrlParam;
      let resA = WifiSetupProxySheetPage.onManualProxyChecked(true);
      expect(resA === null).assertFalse();
      let obj: SettingBaseModel = {
        id: ''
      }
      compParam= {
        compId: '1',
        component: obj,
        param: obj
      }
      WifiSetupProxySheetPage.wifiConfig = getDefaultWifiConfig();
      let resB = WifiSetupProxySheetPage.onManualProxyChecked(false);
      expect(resB === null).assertFalse();
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