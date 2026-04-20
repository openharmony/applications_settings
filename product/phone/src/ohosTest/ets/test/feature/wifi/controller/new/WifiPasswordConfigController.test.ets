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
import { DeviceUtil, SettingSheetPageContext } from '@ohos/settings.common'
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus'
import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel'
import { SettingToggleState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel'
import {
  WifiPasswordConfigController
} from '@ohos/settings.wifi/src/main/ets/controller/new/WifiPasswordConfigController'
import { WifiSecurityType, WLAN_SWITCH_ID } from '@ohos/settings.wifi/src/main/ets/model/WifiModel'
import wifiManager from '@ohos.wifiManager'
import { WlanItemModel } from '@ohos/settings.wifi/src/main/ets/model/WlanItemModel'
import { WapiPskType } from '@ohos/settings.wifi/src/main/ets/WifiMenuManager'

export default function WifiPasswordConfigControllerTest() {
  describe('WifiPasswordConfigControllerTest', () => {
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
      let test = new WifiPasswordConfigController()
      test.addGroupForeground()
      test.init(compParam)
      let context: SettingSheetPageContext = {
        itemComp: {
          id: '2222222'
        }
      };
      compParam.param = context;
      test.init(compParam);
      test.addGroupForeground()
      EventBus.getInstance().emit(WLAN_SWITCH_ID);
      let state: SettingToggleState = {
        state: false
      };
      EventBus.getInstance().emit(WLAN_SWITCH_ID, state);
      test.onPageShow();
      test.onPageHide();
      test.destroy();
      expect(test !== null).assertTrue();
    })
    it('test_initMenus', 0, () => {
      let test = new WifiPasswordConfigController();
      test.initMenus();
      let itemModel: WlanItemModel = {
        type: 0,
        id: '555',
        securityType: wifiManager.WifiSecurityType.WIFI_SEC_TYPE_EAP
      };
      test.itemModel = itemModel;
      test.initMenus();
      itemModel.securityType = wifiManager.WifiSecurityType.WIFI_SEC_TYPE_EAP_SUITE_B;
      test.itemModel = itemModel;
      test.initMenus();
      itemModel.securityType = wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_PSK;
      test.itemModel = itemModel;
      test.initMenus();
      itemModel.securityType = wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_CERT;
      test.itemModel = itemModel;
      test.initMenus();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePc);
      when(mockFunc)(ArgumentMatchers.any).afterReturn(true);
      test.initMenus();
      when(mockFunc)(ArgumentMatchers.any).afterReturn(false);
      test.initMenus();
      (test as object)['createWapiPskPasswordModel']();
      (test as object)['createCipherKeyModel']();
      expect(test !== null).assertTrue();
      mocker.clear(DeviceUtil);
    })
    it('test_private', 0, () => {
      let test = new WifiPasswordConfigController();
      test.wifiConfig = undefined;
      (test as object)['onMacTypeSelectChanged']();
      (test as object)['onEapMethodChanged'](0);
      (test as object)['dealCertificateResult'](true, 'test', 'file');
      test.wifiConfig = getDefaultWifiConfig();
      (test as object)['onMacTypeSelectChanged']();
      (test as object)['onEapMethodChanged'](0);
      (test as object)['onEapMethodChanged'](1);
      (test as object)['dealCertificateResult'](true, 'test', 'file');
      (test as object)['dealCertificateResult'](false, 'test', 'file');
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
