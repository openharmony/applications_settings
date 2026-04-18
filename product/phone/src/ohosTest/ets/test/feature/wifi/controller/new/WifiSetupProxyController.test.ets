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
import { WifiSetupProxyController } from '@ohos/settings.wifi/src/main/ets/controller/new/WifiSetupProxyController'
import { PendingProxyConfig } from '@ohos/settings.wifi/src/main/ets/controller/WifiSetupProxyControllers'
import wifiManager from '@ohos.wifiManager';
import { WifiSecurityType } from '@ohos/settings.wifi';
import { WapiPskType } from '@ohos/settings.wifi/src/main/ets/WifiMenuManager';
import { CompCtrlParam, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel'

export default function WifiSetupProxyControllerTest() {
  describe('WifiSetupProxyControllerTest', () => {
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
    it('test_onProxyChanged', 0, () => {
      let wifiSetupProxy = new WifiSetupProxyController(getDefaultWifiConfig());
      wifiSetupProxy.pendingProxyConfig = null;
      wifiSetupProxy.wifiConfig = undefined;
      let resA: Object = (wifiSetupProxy as object)['onProxyChanged'](2);
      expect(resA === null).assertFalse();
      let pendingProxyConfig: PendingProxyConfig = new PendingProxyConfig();
      pendingProxyConfig.modified = true;
      wifiSetupProxy.pendingProxyConfig = pendingProxyConfig;
      wifiSetupProxy.wifiConfig = getDefaultWifiConfig();
      let resB: Object = (wifiSetupProxy as object)['onProxyChanged'](2);
      expect(resB === null).assertFalse();
      let resC: Object = (wifiSetupProxy as object)['onProxyChanged'](1);
      expect(resC === null).assertFalse();
      let resD: Object = (wifiSetupProxy as object)['onProxyChanged'](0);
      expect(resD === null).assertFalse();
    })

    it('test_init', 0, () => {
      let wifiSetupProxy = new WifiSetupProxyController(getDefaultWifiConfig());
      let resA = wifiSetupProxy.init(undefined);
      expect(resA === null).assertFalse();
      let obj: SettingBaseModel = {
        id: ''
      }
      let compParam: CompCtrlParam= {
        compId: '1',
        component: obj,
        param: obj
      }
      let resB = wifiSetupProxy.init(compParam);
      expect(resB === null).assertFalse();
    })

    it('test_onClick', 0, () => {
      let wifiSetupProxy = new WifiSetupProxyController(getDefaultWifiConfig());
      wifiSetupProxy.pendingProxyConfig = null;
      let resA = wifiSetupProxy.onClick();
      expect(resA === null).assertFalse();
      wifiSetupProxy.pendingProxyConfig = new PendingProxyConfig();
      let resB = wifiSetupProxy.onClick();
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