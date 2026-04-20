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
import { SettingSheetPageContext } from '@ohos/settings.common'
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus'
import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel'
import { ItemType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel'
import { SettingToggleState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel'
import { AddOtherWlanController } from '@ohos/settings.wifi/src/main/ets/controller/new/AddOtherWlanController'
import { WlanItemModel } from '@ohos/settings.wifi/src/main/ets/model/WlanItemModel'
import { WifiPasswordConfigManager } from '@ohos/settings.wifi/src/main/ets/WifiPasswordConfigManager'
import wifiManager from '@ohos.wifiManager';
import { WapiPskType } from '@ohos/settings.wifi/src/main/ets/WifiMenuManager'
import { WifiSecurityType } from '@ohos/settings.wifi'
import { AddOtherWlanConfigManager } from '@ohos/settings.wifi/src/main/ets/AddOtherWlanConfigManager'


export default function AddOtherWlanControllerTest() {
  describe('AddOtherWlanControllerTest', () => {
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
      let test = new AddOtherWlanController()
      test.addGroupForeground()
      let mocker: MockKit = new MockKit()
      let mockFunc: Function = mocker.mockFunc(WifiPasswordConfigManager.getInstance(),
        WifiPasswordConfigManager.getInstance().getConfig)
      when(mockFunc)(ArgumentMatchers.any).afterReturn(true)
      test.init(compParam)
      let param: WlanItemModel = {
        type: 0,
        id: ''
      }
      compParam.param = param
      test.init(compParam)
      let context: SettingSheetPageContext = {
        itemComp: {
          id: '2222222'
        }
      }
      compParam.param = context
      test.init(compParam)
      when(mockFunc)(ArgumentMatchers.any).afterReturn(false)
      test.init(compParam)
      EventBus.getInstance().emit('Setting.Wlan.WlanConfig.WlanSwitch.toggle')
      let state: SettingToggleState = {
        state: false
      }
      EventBus.getInstance().emit('Setting.Wlan.WlanConfig.WlanSwitch.toggle', state)
      test.itemModel = {
        type: 0,
        id: '555'
      }
      EventBus.getInstance().emit('Setting.Wlan.WlanConfig.WlanSwitch.toggle', state)
      test.destroy()
      expect(test !== null).assertTrue()
      mocker.clear(WifiPasswordConfigManager.getInstance());
    })
    it('test_onSafetySelected', 0, () => {
      let test = new AddOtherWlanController();
      (test as object)['onSafetySelected'](0);
      let obj = AddOtherWlanConfigManager.getInstance().wifiConfig;
      AddOtherWlanConfigManager.getInstance().wifiConfig = getDefaultWifiConfig();
      (test as object)['onSafetySelected'](0);
      (test as object)['onSafetySelected'](1);
      (test as object)['onSafetySelected'](2);
      (test as object)['onSafetySelected'](3);
      (test as object)['onSafetySelected'](4);
      (test as object)['onSafetySelected'](5);
      (test as object)['onSafetySelected'](6);
      (test as object)['onSafetySelected'](7);
      (test as object)['onSafetySelected'](8);
      (test as object)['onSafetySelected'](9);
      (test as object)['onSafetySelected'](110);
      (test as object)['onMacTypeSelectChanged'](1);
      AddOtherWlanConfigManager.getInstance().wifiConfig = obj;
      (test as object)['onMacTypeSelectChanged'](1);
      expect(test !== null).assertTrue()
    })
    it('test_onEapMethodChanged_dealCertificateResult', 0, () => {
      let test = new AddOtherWlanController();
      let config1 = getDefaultWifiConfig();
      config1.eapConfig = undefined;
      config1.wapiConfig = undefined;
      test.wifiConfig = config1;
      (test as object)['onEapMethodChanged'](1);
      (test as object)['onEapMethodChanged'](110);
      let config2 = getDefaultWifiConfig();
      (test as object)['dealCertificateResult'](true,'text','fileName');
      test.wifiConfig = config2;
      (test as object)['onEapMethodChanged'](1);
      (test as object)['dealCertificateResult'](true,'text','fileName');
      (test as object)['dealCertificateResult'](false,'text','fileName');
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
