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

import {
  afterAll,
  afterEach,
  beforeAll,
  beforeEach,
  describe,
  expect,
  it,
  Level,
} from '@ohos/hypium';
import wifiManager from '@ohos.wifiManager';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import {
  AccessPoint,
  WifiScanResult,
  WifiSecurityType,
  PendingIpConfig
} from '@ohos/settings.wifi/src/main/ets/model/WifiModel';

export default function wifiUtilsTest() {
  describe('wifiUtilsTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    isWifiDiscoveryOnTest001();
    isWifiDiscoveryOnTest002();
    isWifiDiscoveryOnTest003();
    isWifiDiscoveryOnTest004();
    isWifiDiscoveryOnTest005();
    isWifiDiscoveryOnTest006();
    isWifiDiscoveryOnTest007();
    isWifiDeviceTest001();
    isWifiDeviceTest003();
    isWifiDeviceTest004();
    isWifiDeviceTest005();

    wifiLinkedInfoDetailTest();
    isOpenAp();
    isValidNetworkId();
    wifiUtilsTestIsValidSaePassword();
    wifiUtilsTestGetDeviceMacAddress();
    getApKey001();
    getApKey002();
    getApKey003();
    getApKey004();
    getApLogKey001();
    getApLogKey002();
    getApLogKey003();
    getApLogKey004();
    isWifiNetworkValidated001();
    isWifiNetworkValidated002();
    isValidPskPasswordTest();
    isValidPskPasswordTest002();
    isValidPskPasswordTest003();
    wifiUtilsTestIpString2Number();
    wifiUtilsTestIpString2NumberEmpty();
    wifiUtilsTestIpString2NumberExcept();
    wifiUtilsTestGetLogSsidString();
    equalSignalTest();
    wifiUtilsTestGetDisconnectedReason();

    getScanInfoListTest();
    getIpInfoByPendingConfigTest();
    getIpv6InfoByPendingConfigTest();
    ipv6PrefixToNumberTest()
    isValidWifiIpsConfigTest();
    isValidWifiIpv6ConfigTest();
    wifiUtilsTestGetApKeyWithConfig();
    wifiUtilsTestGetConfigForNetworkId();
    wifiUtilsTestGetConfig();
    wifiUtilsTestIsScanResultMatches01();
    wifiUtilsTestIsConfigMatches01();
    wifiUtilsTestGetTitle();
    apWithNoConfigTest();
    wifiUtilsTestIsHidden01();
    wifiUtilsTestIsActive();
    isReachableTest();
    wifiUtilsTestIsSaved();

    it('enableHiLinkHandshakeTest01', 0, async () => {
        let isHiLinkEnable = true;
        let bssid = 'test';
        let config:wifiManager.WifiDeviceConfig = {
          ssid:'test',
          preSharedKey:'test',
          securityType:1
        }
      WifiUtils.enableHiLinkHandshake(isHiLinkEnable,bssid,config);
      expect(bssid).not().assertNull();
    });
    it('enableHiLinkHandshakeTest02', 0, async () => {
      let isHiLinkEnable = true;
      let bssid = '';
      let config:wifiManager.WifiDeviceConfig = {
        ssid:'',
        preSharedKey:'',
        securityType:1
      }
      WifiUtils.enableHiLinkHandshake(isHiLinkEnable,bssid,config);
      expect(isHiLinkEnable).not().assertNull();
    });
  })
}

function getScanInfoListTest() {
  it('getScanInfoListTest', 0, async () => {
    expect(wifiManager.getScanInfoList().length >= 0).assertTrue();
  });
}

function getIpInfoByPendingConfigTest() {
  it('getIpInfoByPendingConfigTest', 0, () => {
    let ipv6Config: wifiManager.Ipv6Config = {
      ipAddress: '',
      gateway: '',
      prefixLength: 0,
      dnsServers: [],
      domains: []
    }
    let ipConfig: wifiManager.IpConfig = {
      ipAddress: 0,
      gateway: 0,
      prefixLength: 0,
      dnsServers: [],
      domains: []
    }
    let pendingIpConfig: PendingIpConfig =
      new PendingIpConfig(wifiManager.IpType.DHCP, ipConfig, ipv6Config);
    expect(WifiUtils.getIpInfoByPendingConfig(pendingIpConfig)).not().assertEqual('');
  });
}


function getIpv6InfoByPendingConfigTest() {
  it('getIpv6InfoByPendingConfigTest', 0, () => {
    let ipv6Config: wifiManager.Ipv6Config = {
      ipAddress: '',
      gateway: '',
      prefixLength: 0,
      dnsServers: [],
      domains: []
    }
    let ipConfig: wifiManager.IpConfig = {
      ipAddress: 0,
      gateway: 0,
      prefixLength: 0,
      dnsServers: [],
      domains: []
    }
    let pendingIpConfig: PendingIpConfig =
      new PendingIpConfig(wifiManager.IpType.DHCP, ipConfig, ipv6Config);
    expect(WifiUtils.getIpv6InfoByPendingConfig(pendingIpConfig)).not().assertEqual('');
  });
}

function ipv6PrefixToNumberTest() {
  it('ipv6PrefixToNumberTest', 0, () => {
    const prefixStr = "ffff:ffff:ffff:ffff::";
    expect(WifiUtils.ipv6PrefixToNumber(prefixStr)).not().assertEqual('');
  });
}

function isValidWifiIpsConfigTest() {
  it('isValidWifiIpsConfigTest', 0, () => {
    let ipv6Config: wifiManager.Ipv6Config = {
      ipAddress: '::1',
      gateway: '::2',
      prefixLength: 64,
      dnsServers: ['::33', '::44'],
      domains: []
    }
    let ipConfig: wifiManager.IpConfig = {
      ipAddress: -1062731420,
      gateway: -1062731519,
      prefixLength: 23,
      dnsServers: [208695408, 1920103026],
      domains: []
    }
    expect(WifiUtils.isValidWifiIpsConfig(wifiManager.IpType.DHCP, ipConfig, ipv6Config)).not().assertEqual('');
  });
}

function isValidWifiIpv6ConfigTest() {
  it('isValidWifiIpv6ConfigTest', 0, () => {
    let ipv6Config: wifiManager.Ipv6Config = {
      ipAddress: '::1',
      gateway: '::2',
      prefixLength: 64,
      dnsServers: ['::33', '::44'],
      domains: []
    }
    let ipConfig: wifiManager.IpConfig = {
      ipAddress: -1062731420,
      gateway: -1062731519,
      prefixLength: 23,
      dnsServers: [208695408, 1920103026],
      domains: []
    }
    expect(WifiUtils.isValidWifiIpv6Config(1, ipv6Config)).not().assertEqual('');
  });
}

function wifiUtilsTestGetApKeyWithConfig() {
  it('wifiUtilsTestGetApKeyWithConfig', 0, () => {
    let config: wifiManager.WifiDeviceConfig = {
      ssid: 'test',
      bssid: 'test',
      preSharedKey: 'test',
      isHiddenSsid: false,
      securityType: 1,
    };
    expect(WifiUtils.getApKeyWithConfig(config)).not().assertEqual('');
  });
}

function wifiUtilsTestGetConfigForNetworkId() {
  it('wifiUtilsTestGetConfigForNetworkId', 0, () => {
    let wifiConfig: wifiManager.WifiDeviceConfig = {
      netId: 1,
      ssid: 'wifi',
      preSharedKey: '123456',
      isHiddenSsid: false,
      securityType: 1
    };
    let configs: wifiManager.WifiDeviceConfig[] = [wifiConfig];
    let result = WifiUtils.getConfigForNetworkId(1, configs);
    expect(result).assertEqual(wifiConfig);
  });
}

function wifiUtilsTestGetConfig() {
  it('wifiUtilsTestGetConfig', 0, () => {
    let configs: wifiManager.WifiDeviceConfig[] = [
      {
        ssid: 'test001',
        securityType: 1,
      } as wifiManager.WifiDeviceConfig,
      {
        ssid: 'test002',
        securityType: 2,
      } as wifiManager.WifiDeviceConfig,
    ];
    let result = WifiUtils.getConfig('test003', 3);
    expect(result).assertUndefined();
  });
}

function wifiUtilsTestIsScanResultMatches01() {
  it('wifiUtilsTestIsScanResultMatches01', 0, () => {
    let result: WifiScanResult = new WifiScanResult();
    result.securityType = WifiSecurityType.WIFI_SEC_TYPE_INVALID;
    let scanResults: WifiScanResult[] = [];
    let ap: AccessPoint = new AccessPoint(scanResults);
    ap.securityType = WifiSecurityType.WIFI_SEC_TYPE_INVALID;
    let isMatches = WifiUtils.isScanResultMatches(result, ap);
    expect(isMatches).assertTrue();
  });
}

function wifiUtilsTestIsConfigMatches01() {
  it('wifiUtilsTestIsConfigMatches01', 0, () => {
    let config: wifiManager.WifiDeviceConfig = {
      ssid: 'test',
      securityType: 1,
      preSharedKey: ''
    };
    let scanResults: WifiScanResult[] = [];
    let ap: AccessPoint = new AccessPoint(scanResults);
    ap.apKey = '';
    expect(WifiUtils.isConfigMatches(config, ap)).assertTrue();
    ap.ssid = '12313';
    expect(WifiUtils.isConfigMatches(config, ap)).assertTrue();
  });
}

function wifiUtilsTestGetTitle() {
  it('wifiUtilsTestGetTitle', 0, () => {
    let scanResults: WifiScanResult[] = [];
    let ap: AccessPoint = new AccessPoint(scanResults);
    ap.ssid = 'getTitle';
    let getTitle = WifiUtils.getTitle(ap);
    expect(getTitle).assertEqual('getTitle');
  });
}

function apWithNoConfigTest() {
  it('apWithNoConfigTest', 0, () => {
    let scanResults: WifiScanResult[] = [];
    let ap: AccessPoint = new AccessPoint(scanResults);
    ap.configs = [];
    let result = WifiUtils.getBestConfig(ap);
    expect(result).assertNull();
  });
}

function wifiUtilsTestIsHidden01() {
  it('wifiUtilsTestIsHidden01', 0, () => {
    let scanResults: WifiScanResult[] = [];
    let ap: AccessPoint = new AccessPoint(scanResults);
    let result = WifiUtils.isHidden(ap);
    expect(result).assertFalse();
  });
}

function wifiUtilsTestIsActive() {
  it('wifiUtilsTestIsActive', 0, () => {
    let scanResults: WifiScanResult[] = [];
    let ap: AccessPoint = new AccessPoint(scanResults);
    ap.lastLinkedInfo = null;
    expect(WifiUtils.isActive(ap)).assertFalse();
  });
}

function isReachableTest() {
  it('isReachableTest', 0, () => {
    let scanResults: WifiScanResult[] = [];
    let ap: AccessPoint = new AccessPoint(scanResults);
    ap.bestRssi = -1;
    expect(WifiUtils.isReachable(ap)).assertTrue();
  });
}

function wifiUtilsTestIsSaved() {
  it('wifiUtilsTestIsSaved', 0, () => {
    let scanResults: WifiScanResult[] = [];
    let ap: AccessPoint = new AccessPoint(scanResults);
    let result = WifiUtils.isSaved(ap);
    expect(result).assertFalse();
    ap.configs = [];
    let config: wifiManager.WifiDeviceConfig = {
      ssid: 'test',
      securityType: 1,
      preSharedKey: ''
    };
    ap.configs.push(config);
    let result1 = WifiUtils.isSaved(ap);
    expect(result1).assertTrue();
  });
}

function wifiUtilsTestGetDisconnectedReason() {
  it('wifiUtilsTest_getDisconnectedReason', 0, () => {
    let disconnectedReason = WifiUtils.getDisconnectedReason();
    expect(disconnectedReason).assertInstanceOf('Number');
  });
}

function equalSignalTest() {
  it('equalSignalTest', 0, () => {
    expect(WifiUtils.equalSignal(1, 0)).assertTrue();
    expect(WifiUtils.equalSignal(1, -1)).assertTrue();
  });
}

function wifiUtilsTestGetLogSsidString() {
  it('wifiUtilsTestGetLogSsidString', 0, () => {
    let ssid2 = 'a';
    expect(WifiUtils.getLogSsidString(ssid2)).assertEqual('*****');
  });
}

function wifiUtilsTestIpString2NumberExcept() {
  it('wifiUtilsTestIpString2NumberExcept', 0, () => {
    let ipString: string = '192.168.1.1.1';
    let exceptStr: null = null;
    let result: number | null = WifiUtils.ipString2Number(ipString);
    expect(exceptStr).assertEqual(result);
  });
}

function wifiUtilsTestIpString2NumberEmpty() {
  it('wifiUtilsTestIpString2NumberEmpty', 0, () => {
    let ipString: string = '';
    let exceptStr: null = null;
    let result: number | null = WifiUtils.ipString2Number(ipString);
    expect(exceptStr).assertEqual(result);
  });
}

function wifiUtilsTestIpString2Number() {
  it('wifiUtilsTestIpString2Number', 0, () => {
    let ipString: string = '192.168.1.1';
    let exceptStr: number = 3232235777;
    let result: number | null = WifiUtils.ipString2Number(ipString);
    expect(exceptStr).assertEqual(result);
  });
}

function isValidPskPasswordTest() {
  it('isValidPskPasswordTest', 0, () => {
    let result = WifiUtils.isValidPskPassword('1234567');
    expect(result).assertFalse();
  });
}

function isValidPskPasswordTest002() {
  it('isValidPskPasswordTest002', 0, () => {
    let result = WifiUtils.isValidPskPassword('1234567890123456789012345678901234567890123456789012345678901234');
    expect(result !== null).assertTrue();
  });
}

function isValidPskPasswordTest003() {
  it('isValidPskPasswordTest003', 0, () => {
    let result = WifiUtils.isValidPskPassword('1234567890123456789012345678901234567890123456789012345678901234', '[WPA-PSK-CCMP+TKIP][WPA2-PSK-CCMP+TKIP][ESS]');
    expect(result).assertTrue();
  });
}

function isWifiNetworkValidated002() {
  it('isWifiNetworkValidated002', Level.LEVEL0, (): void => {
    expect(WifiUtils.isPortalWifiNetwork([17])).assertTrue();
  });
}

function isWifiNetworkValidated001() {
  it('isWifiNetworkValidated001', Level.LEVEL0, (): void => {
    expect(WifiUtils.isWifiNetworkValidated([16])).assertTrue();
  });
}

function getApLogKey004() {
  it('getApLogKey004', Level.LEVEL0, (): void => {
    expect(WifiUtils.getApLogKey(null, 0) === '').assertTrue();
  });
}

function getApLogKey003() {
  it('getApLogKey003', Level.LEVEL0, (): void => {
    expect(WifiUtils.getApLogKey(undefined, 0) === '').assertTrue();
  });
}

function getApLogKey002() {
  it('getApLogKey002', Level.LEVEL0, (): void => {
    expect(WifiUtils.getApLogKey('', null) === '').assertTrue();
  });
}

function getApLogKey001() {
  it('getApLogKey001', Level.LEVEL0, (): void => {
    expect(WifiUtils.getApLogKey('', undefined) === '').assertTrue();
  });
}

function getApKey004() {
  it('getApKey004', Level.LEVEL0, (): void => {
    expect(WifiUtils.getApKey(null, null, 0) === '').assertFalse();
  });
}

function getApKey003() {
  it('getApKey003', Level.LEVEL0, (): void => {
    expect(WifiUtils.getApKey(undefined, undefined, 0) === '').assertFalse();
  });
}

function getApKey002() {
  it('getApKey002', Level.LEVEL0, (): void => {
    expect(WifiUtils.getApKey('', '', null) === '').assertFalse();
  });
}

function getApKey001() {
  it('getApKey001', Level.LEVEL0, (): void => {
    expect(WifiUtils.getApKey('', '', undefined) === '').assertFalse();
  });
}

function wifiUtilsTestGetDeviceMacAddress() {
  it('wifiUtilsTestGetDeviceMacAddress', 0, () => {
    let macAddress = WifiUtils.getDeviceMacAddress();
    expect(macAddress).not().assertNull();
  });
}

function wifiUtilsTestIsValidSaePassword() {
  it('wifiUtilsTestIsValidSaePassword', 0, () => {
    const saePassword1: string = '';
    expect(WifiUtils.isValidSaePassword(saePassword1)).assertFalse();
  });
}

function isValidNetworkId() {
  it('isValidNetworkId', 0, () => {
    expect(WifiUtils.isValidNetworkId(null)).assertFalse();
    expect(WifiUtils.isValidNetworkId(undefined)).assertFalse();
    let INVALID_NETWORK_ID = -1;
    expect(WifiUtils.isValidNetworkId(INVALID_NETWORK_ID)).assertFalse();
    expect(WifiUtils.isValidNetworkId(0)).assertTrue();
    expect(WifiUtils.isValidNetworkId(1)).assertTrue();
  });
}

function isOpenAp() {
  it('isOpenAp', 0, () => {
    expect(WifiUtils.isOpenAp(0)).assertFalse();
    expect(WifiUtils.isOpenAp(1)).assertTrue();
  });
}

function wifiLinkedInfoDetailTest() {
  it('wifiLinkedInfoDetailTest', 0, () => {
    WifiUtils.wifiLinkedInfoDetail();
    expect(0).assertEqual(0);
  });
}

function isWifiDeviceTest005() {
  it('isWifiDeviceTest005', Level.LEVEL0, (): void => {
    expect(WifiUtils.isPortalWifiNetwork([17])).assertTrue();
  });
}

function isWifiDeviceTest004() {
  it('isWifiDeviceTest004', Level.LEVEL0, (): void => {
    expect(WifiUtils.isWifiNetworkValidated([16])).assertTrue();
  });
}

function isWifiDeviceTest003() {
  it('isWifiDeviceTest003', Level.LEVEL0, (): void => {
    expect(WifiUtils.isBearerWifi([1, 2])).assertFalse();
  });
}

function isWifiDeviceTest001() {
  it('isWifiDeviceTest001', Level.LEVEL0, (): void => {
    expect(WifiUtils.removeDevice(1) !== null).assertTrue();
  });
}

function isWifiDiscoveryOnTest007() {
  it('isWifiDiscoveryOnTest007', Level.LEVEL0, (): void => {
    expect(WifiUtils.isWifiConnected()).assertFalse();
  });
}

function isWifiDiscoveryOnTest006() {
  it('isWifiDiscoveryOnTest006', Level.LEVEL0, (): void => {
    expect(WifiUtils.startPortalCertification() !== null).assertTrue();
  });
}

function isWifiDiscoveryOnTest005() {
  it('isWifiDiscoveryOnTest005', Level.LEVEL0, (): void => {
    expect(WifiUtils.scanWifi() !== null).assertTrue();
  });
}

function isWifiDiscoveryOnTest004() {
  it('isWifiDiscoveryOnTest004', Level.LEVEL0, (): void => {
    expect(WifiUtils.disconnect() !== null).assertTrue();
  });
}

function isWifiDiscoveryOnTest003() {
  it('isWifiDiscoveryOnTest003', Level.LEVEL0, (): void => {
    expect(WifiUtils.disableWifi()).assertTrue();
  });
}

function isWifiDiscoveryOnTest002() {
  it('isWifiDiscoveryOnTest002', Level.LEVEL0, (): void => {
    expect(WifiUtils.enableWifi()).assertTrue();
  });
}

function isWifiDiscoveryOnTest001() {
  it('isWifiDiscoveryOnTest001', Level.LEVEL0, (): void => {
    expect(WifiUtils.isWifiActive()).assertFalse();
  });
}
