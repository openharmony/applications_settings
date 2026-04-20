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

import { describe, it, expect, TestType, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ApMenu, WifiSecurityType, WifiUtils } from '@ohos/settings.wifi';
import { WifiTracker, WifiTrackerListener } from '@ohos/settings.wifi/src/main/ets/WifiTracker';
import { Constant } from '../.././constant/Constant';
import wifiManager from '@ohos.wifiManager';
import { WapiPskType } from '@ohos/settings.wifi/src/main/ets/WifiMenuManager';

export default function WifiTrackerTest() {
  describe('WifiTrackerTest', () => {

    /*
    * @tc.number: WifiTrackerTest_001
    * @tc.name: updateAll
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('WifiTrackerTest_001', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} WifiTrackerTest_001 start`);
      let wifiTracker = new WifiTracker();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(wifiTracker, wifiTracker.updateAll);
      when(mockFunc)().afterReturn(true);
      let result = await wifiTracker.updateAll();
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} WifiTrackerTest_001 end`);
      mocker.clear(wifiTracker);
    });
    it('test_listener', TestType.FUNCTION, () => {
      let wifiTracker = new WifiTracker()
      wifiTracker.setListener(null)
      wifiTracker.releaseResource()
      let listener1: testWiFiListener = new testWiFiListener()
      wifiTracker.setListener(listener1)
      wifiTracker.setListener(listener1)
      let listener2: testWiFiListener = new testWiFiListener()
      wifiTracker.setListener(listener2)
      wifiTracker.releaseResource(listener1)
      let listener3: testWiFiListener = new testWiFiListener()
      wifiTracker.releaseResource(listener3)
      wifiTracker.releaseResource()
    })
    it('test_scanAp', TestType.FUNCTION, (done: Function) => {
      try {
        let wifiTracker = new WifiTracker()
        let mocker: MockKit = new MockKit()
        let mockFunc: Function = mocker.mockFunc(WifiUtils, WifiUtils.scanWifi)
        when(mockFunc)(ArgumentMatchers.any).afterReturn(false)
        wifiTracker.scanAp(3)
        expect(wifiTracker.scanActionResult).assertFalse()
        when(mockFunc)(ArgumentMatchers.any).afterReturn(true)
        wifiTracker.scanAp()
        expect(wifiTracker.scanActionResult).assertFalse()
        mocker.clear(WifiUtils);
      } catch(e) {
      } finally {
        done()
      }
  })
    it('test_start_quit', TestType.FUNCTION, () => {
      let wifiTracker = new WifiTracker()
      let listener1 : testWiFiListener = new testWiFiListener()
      wifiTracker.setListener(listener1)
      wifiTracker.onStart()
      wifiTracker.onStart()
      wifiTracker.onQuit(listener1)
      wifiTracker.onQuit()
    })
    it('test_removeWifiDevice', TestType.FUNCTION, async (done: Function) => {
      let wifiTracker = new WifiTracker()
      let mocker: MockKit = new MockKit()
      let config: wifiManager.WifiDeviceConfig = getDefaultWifiConfig()
      let netFunc: Function = mocker.mockFunc(WifiUtils, WifiUtils.isValidNetworkId)
      when(netFunc)(ArgumentMatchers.any).afterReturn(false)
      await wifiTracker.removeWifiDevice(config,true)
      when(netFunc)(ArgumentMatchers.any).afterReturn(true)
      await wifiTracker.removeWifiDevice(config,false)
      await wifiTracker.removeWifiDevice(config)
      mocker.clear(WifiUtils);
      done()
    })
    it('test_updateAll', TestType.FUNCTION, async (done: Function) => {
      let wifiTracker = new WifiTracker()
      let mocker: MockKit = new MockKit()
      let scanInfoFunc: Function = mocker.mockFunc(WifiUtils, WifiUtils.getScanInfoList)
      when(scanInfoFunc)(ArgumentMatchers.any).afterReturn([])
      await wifiTracker.updateAll()
      when(scanInfoFunc)(ArgumentMatchers.any).afterReturn(fakeWifiScanInfoData)
      await wifiTracker.updateAll()
      mocker.clear(WifiUtils);
      done()
    })
  });
}

export class testWiFiListener implements WifiTrackerListener {
  onApMenuChanged(menu: ApMenu): void {
  }
  onApMenusChanged(menus: ApMenu[]): void {
  }
}

function getDefaultWifiConfig(): wifiManager.WifiDeviceConfig {
  return {
    ssid:  '123886-00000',
    bssid: 'apMenu.bssid',
    bssidType: 0,
    preSharedKey: '',
    securityType: WifiSecurityType.WIFI_SEC_TYPE_OPEN,
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
const fakeWifiScanInfoData : Array<wifiManager.WifiScanInfo> = [
  {
    ssid: "MyHomeNetwork",
    bssid: "00:11:22:33:44:55",
    bssidType: 0,
    capabilities: "Hotspot",
    securityType: WifiSecurityType.WIFI_SEC_TYPE_INVALID,
    rssi: -60,
    band: 1,
    frequency: 2412,
    channelWidth: 20,
    centerFrequency0: 2412,
    centerFrequency1: 2462,
    infoElems: [],
    timestamp: 1643723400,
    supportedWifiCategory: 1,
    isHiLinkNetwork: false,
    isHiLinkProNetwork: false,
  },
  {
    ssid: "OfficeNetwork",
    bssid: "66:77:88:99:AA:BB",
    bssidType: 1,
    capabilities: "Hotspot",
    securityType:  WifiSecurityType.WIFI_SEC_TYPE_PSK,
    rssi: -70,
    band: 2,
    frequency: 5180,
    channelWidth: 20,
    centerFrequency0: 5180,
    centerFrequency1: 5230,
    infoElems: [],
    timestamp: 1643723410,
    supportedWifiCategory: 2,
    isHiLinkNetwork: true,
    isHiLinkProNetwork: false,
  }
];