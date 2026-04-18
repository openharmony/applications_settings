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
import { AddOtherWlanConfigManager } from '@ohos/settings.wifi/src/main/ets/AddOtherWlanConfigManager'
import wifiManager from '@ohos.wifiManager'
import { WapiPskType } from '@ohos/settings.wifi/src/main/ets/WifiMenuManager'

export default function AddOtherWlanConfigManagerTest() {
  describe('AddOtherWlanConfigManagerTest', () => {
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
    it('test_AddOtherWlanConfigManager', 0, () => {
      let manager1 = AddOtherWlanConfigManager.getInstance()
      let manager2 = AddOtherWlanConfigManager.getInstance()
      expect(manager1 === manager2).assertTrue()
      let res = true
      try {
        manager2.connectToWifiDevice()
        manager2.initConfig()
        manager2.connectToWifiDevice()
        manager2.initConfig()
        if (manager2.getConfig()) {
          manager2.clearAndGetFormattedConfig(manager2.getConfig()!)
        }
        manager2.wifiConfig = testConfig()
        manager2.connectToWifiDevice()
        if (manager2.getConfig()) {
          manager2.clearAndGetFormattedConfig(manager2.getConfig()!)
        }
        manager2.clearConfig()
      } catch (e) {
        res = false
      } finally {
        expect(res).assertTrue()
      }
    })
  })
}

function testConfig(): wifiManager.WifiDeviceConfig {
   return {
    isHiddenSsid: true,
    ssid: '',
    preSharedKey: '',
    securityType: wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_CERT,
    ipType: wifiManager.IpType.STATIC,
    randomMacType: 0,
    staticIp: {
      ipAddress: 0,
      gateway: 0,
      prefixLength: 0,
      dnsServers: [],
      domains: [],
    },
    proxyConfig: {
      proxyMethod: wifiManager.ProxyMethod.METHOD_AUTO,
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
  }
}
