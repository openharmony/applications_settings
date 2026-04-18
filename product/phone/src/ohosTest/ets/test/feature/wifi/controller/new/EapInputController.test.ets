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
import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel'
import { AddOtherWlanConfigManager } from '@ohos/settings.wifi/src/main/ets/AddOtherWlanConfigManager'
import { EapInputController } from '@ohos/settings.wifi/src/main/ets/controller/new/EapInputController'
import wifiManager from '@ohos.wifiManager'
import { WifiSecurityType } from '@ohos/settings.wifi'
import { CaCertificateType, WapiPskType } from '@ohos/settings.wifi/src/main/ets/WifiMenuManager'
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource'
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus'
import {
  EAP_CA_CERTIFICATE_CHANGED_EVENT,
  EAP_METHOD_CHANGED_EVENT } from '@ohos/settings.wifi/src/main/ets/model/WifiModel'

export default function EapInputControllerTest() {
  describe('EapInputControllerTest', () => {
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
      }
      let test = new EapInputController()
      test.init(compParam)
      AddOtherWlanConfigManager.getInstance().wifiConfig = getDefaultWifiConfig()
      compParam.dataSource = new OrderedDataSource()
      test.init(compParam)
      AddOtherWlanConfigManager.getInstance().wifiConfig = undefined
      test.init(compParam)
      test.destroy()
      expect(test !== null).assertTrue()
    })
    it('test_eventBus', 0, () => {
      let compParam: CompCtrlParam = {
        compId: '001',
        component: {
          id: '000000-5555'
        },
      }
      let test = new EapInputController()
      test.init(compParam)
      test.eapConfig = undefined
      EventBus.getInstance().emit(EAP_METHOD_CHANGED_EVENT)
      EventBus.getInstance().emit(EAP_CA_CERTIFICATE_CHANGED_EVENT)
      compParam.dataSource = new OrderedDataSource()
      test.init(compParam)
      EventBus.getInstance().emit(EAP_METHOD_CHANGED_EVENT)
      EventBus.getInstance().emit(EAP_CA_CERTIFICATE_CHANGED_EVENT)
      let config = getDefaultWifiConfig()
      test.eapConfig = config.eapConfig
      EventBus.getInstance().emit(EAP_METHOD_CHANGED_EVENT)
      EventBus.getInstance().emit(EAP_CA_CERTIFICATE_CHANGED_EVENT)
      if (test.eapConfig) {
        test.eapConfig!.eapMethod = wifiManager.EapMethod.EAP_PEAP
        EventBus.getInstance().emit(EAP_METHOD_CHANGED_EVENT)
        EventBus.getInstance().emit(EAP_CA_CERTIFICATE_CHANGED_EVENT)
        test.eapConfig!.eapMethod = wifiManager.EapMethod.EAP_TLS
        EventBus.getInstance().emit(EAP_METHOD_CHANGED_EVENT)
        EventBus.getInstance().emit(EAP_CA_CERTIFICATE_CHANGED_EVENT)
        test.eapConfig!.eapMethod = wifiManager.EapMethod.EAP_TTLS
        EventBus.getInstance().emit(EAP_METHOD_CHANGED_EVENT)
        EventBus.getInstance().emit(EAP_CA_CERTIFICATE_CHANGED_EVENT)
        test.eapConfig!.eapMethod = wifiManager.EapMethod.EAP_PWD
        EventBus.getInstance().emit(EAP_METHOD_CHANGED_EVENT)
        EventBus.getInstance().emit(EAP_CA_CERTIFICATE_CHANGED_EVENT)
      }
      expect(test !== null).assertTrue()
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
