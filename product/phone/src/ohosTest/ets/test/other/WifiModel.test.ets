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

import { afterAll, afterEach,
  ArgumentMatchers,
  beforeAll, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { AccessPoint, ApMenu, ApMenuData, WifiScanResult,
  WifiSecurityType } from '@ohos/settings.wifi/src/main/ets/model/WifiModel';
import wifiManager from '@ohos.wifiManager';
import { WapiPskType } from '@ohos/settings.wifi/src/main/ets/WifiMenuManager';


export default function wifiModelTest() {
  describe('wifiModelTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    wifiScanResultConstructor();
    apMenuConstructor();
    apMenuUpdateNull();
    apMenuUpdateSameData();
    apMenuUpdateDifferentData();
    apMenuGetLogKey();
    accessPointTestIsSameAp();
    accessPointTestIsSameAp01();
    accessPointTestIsSameAp02();
    accessPointTestIsSameAp03();
    AccessPointTestSetScanResults001();
    AccessPointTests();
  })
}
function AccessPointTests() {
  it('test_isSameAp', 0, () => {
    let mocker: MockKit = new MockKit()
    let ap1: AccessPoint = new AccessPoint(null)
    ap1.ssid = 'ssid1'
    ap1.securityType = 1
    let getSummary1: Function = mocker.mockFunc(ap1, ap1.getSummary)
    let getStateIcon1: Function = mocker.mockFunc(ap1, ap1.getStateIcon)
    let getFrequency1: Function = mocker.mockFunc(ap1, ap1.getFrequency)
    let getIpAddress1: Function = mocker.mockFunc(ap1, ap1.getIpAddress)
    let getSpeed1: Function = mocker.mockFunc(ap1, ap1.getSpeed)
    when(getSummary1)(ArgumentMatchers.any).afterReturn('Summary1')
    when(getStateIcon1)(ArgumentMatchers.any).afterReturn('StateIcon1')
    when(getFrequency1)(ArgumentMatchers.any).afterReturn(1)
    when(getIpAddress1)(ArgumentMatchers.any).afterReturn(1)
    when(getSpeed1)(ArgumentMatchers.any).afterReturn(1)

    let ap2: AccessPoint = new AccessPoint(null)
    ap2.ssid = 'ssid2'
    ap2.securityType = 2
    let getTitle2: Function = mocker.mockFunc(ap2, ap2.getTitle)
    let getSummary2: Function = mocker.mockFunc(ap2, ap2.getSummary)
    let getStateIcon2: Function = mocker.mockFunc(ap2, ap2.getStateIcon)
    let getFrequency2: Function = mocker.mockFunc(ap2, ap2.getFrequency)
    let getIpAddress2: Function = mocker.mockFunc(ap2, ap2.getIpAddress)
    let getSpeed2: Function = mocker.mockFunc(ap2, ap2.getSpeed)
    when(getTitle2)(ArgumentMatchers.any).afterReturn('ssid2')
    when(getSummary2)(ArgumentMatchers.any).afterReturn('Summary2')
    when(getStateIcon2)(ArgumentMatchers.any).afterReturn('StateIcon2')
    when(getFrequency2)(ArgumentMatchers.any).afterReturn(2)
    when(getIpAddress2)(ArgumentMatchers.any).afterReturn(2)
    when(getSpeed2)(ArgumentMatchers.any).afterReturn(2)

    expect(ap1.isSameAp(ap2)).assertFalse()
    ap2.ssid = ap1.ssid
    expect(ap1.isSameAp(ap2)).assertFalse()
    ap2.securityType = ap1.securityType
    expect(ap1.isSameAp(ap2)).assertFalse()
    when(getTitle2)(ArgumentMatchers.any).afterReturn(ap1.ssid)
    expect(ap1.isSameAp(ap2)).assertFalse()
    when(getSummary2)(ArgumentMatchers.any).afterReturn('Summary1')
    expect(ap1.isSameAp(ap2)).assertFalse()
    when(getStateIcon2)(ArgumentMatchers.any).afterReturn('StateIcon1')
    expect(ap1.isSameAp(ap2)).assertFalse()
    when(getFrequency2)(ArgumentMatchers.any).afterReturn(1)
    expect(ap1.isSameAp(ap2)).assertFalse()
    when(getIpAddress2)(ArgumentMatchers.any).afterReturn(1)
    expect(ap1.isSameAp(ap2)).assertFalse()
    when(getSpeed2)(ArgumentMatchers.any).afterReturn(1)
    expect(ap1.isSameAp(ap2)).assertTrue()
    mocker.clear(ap1)
    mocker.clear(ap2)
  })
  it('test_setScanResults_01', 0, () => {
    let ap = new AccessPoint(null)
    ap.ssid = 'ssid1'
    ap.securityType = WifiSecurityType.WIFI_SEC_TYPE_WEP
    ap.bestRssi = 2
    ap.setScanResults(null)
    ap.setScanResults([])
    let res1 = new WifiScanResult()
    res1.ssid = ap.ssid
    res1.securityType = ap.securityType
    res1.rssi = 1
    let res2 = new WifiScanResult()
    res2.ssid = 'ssid1'
    res2.securityType = WifiSecurityType.WIFI_SEC_TYPE_PSK
    res2.rssi = 2
    ap.setScanResults([res2])
    ap.setScanResults([res2])
    ap.setScanResults([res1])
    expect(ap.scanResults !== null).assertTrue()
  })
  it('test_setScanResults_02', 0, () => {
    let ap = new AccessPoint(null)
    ap.ssid = 'ssid1'
    ap.securityType = WifiSecurityType.WIFI_SEC_TYPE_WEP
    let res1 = new WifiScanResult()
    res1.ssid = ap.ssid
    res1.securityType = ap.securityType
    res1.rssi = -300
    let res3 = new WifiScanResult()
    res3.ssid = ap.ssid
    res3.securityType = ap.securityType
    res3.rssi = -100
    ap.bestRssi = -200
    ap.setScanResults([res1,res3])
    ap.bestRssi = -Number.MIN_VALUE
    ap.setScanResults([res1,res3])
    res3.band = 1
    ap.setScanResults([res3])
    res3.rssi = -85
    ap.setScanResults([res3])
    res3.rssi = -78
    ap.setScanResults([res3])
    res3.rssi = -70
    ap.setScanResults([res3])
    res3.rssi = -50
    ap.setScanResults([res3])
    res3.band = 2
    res3.rssi = -100
    ap.setScanResults([res3])
    res3.rssi = -80
    ap.setScanResults([res3])
    res3.rssi = -75
    ap.setScanResults([res3])
    res3.rssi = -70
    ap.setScanResults([res3])
    res3.rssi = -50
    ap.setScanResults([res3])
    expect(ap.scanResults !== null).assertTrue()
  })
  it('test_setConfigs_01', 0, () => {
    let ap = new AccessPoint(null)
    ap.ssid = '1235-000'
    ap.securityType = WifiSecurityType.WIFI_SEC_TYPE_SAE
    ap.setConfigs(null)
    ap.setConfigs([])
    let config = getDefaultWifiConfig()
    ap.setConfigs([config])
    ap.setConfigs([config])
    ap.ssid = config.ssid
    ap.setConfigs([config])
    ap.capabilities = 'WPA2-PSK'
    ap.setConfigs([config])
    ap.securityType = WifiSecurityType.WIFI_SEC_TYPE_PSK
    ap.setConfigs([config])
    expect(ap.configs !== null).assertTrue()
  })
  it('test_setConfigs_02', 0, () => {
    let ap = new AccessPoint(null)
    let config = getDefaultWifiConfig()
    ap.bssidType = config.bssidType ?? 0
    ap.setConfigs([config])
    expect(ap.configs !== null).assertTrue()
  })
  it('test_updateLastLinkedInfo', 0, () => {
    let ap = new AccessPoint(null)
    let mocker: MockKit = new MockKit()
    let isLinkedInfoForMeFunc: Function = mocker.mockFunc(ap, ap.isLinkedInfoForMe)
    when(isLinkedInfoForMeFunc)(ArgumentMatchers.any).afterReturn(false)
    let linkInfo = getDefaultLinkedInfo()
    ap.updateLastLinkedInfo(linkInfo)
    when(isLinkedInfoForMeFunc)(ArgumentMatchers.any).afterReturn(true)
    ap.updateLastLinkedInfo(linkInfo)
    let res = new WifiScanResult()
    ap.scanResults = [res]
    ap.updateLastLinkedInfo(linkInfo)
    ap.scanResults = undefined
    ap.updateLastLinkedInfo(linkInfo)
    ap.updateLastLinkedInfo(linkInfo)
    expect(ap.lastLinkedInfo !== null).assertTrue()
    mocker.clear(ap)
  })
  it('test_isLinkedInfoForMe', 0, () => {
    let ap = new AccessPoint(null)
    let linkedInfo = getDefaultLinkedInfo()
    let scanRes = new WifiScanResult()
    let config = getDefaultWifiConfig()
    expect(ap.isLinkedInfoForMe(linkedInfo)).assertTrue()
    ap.getTitle()
    ap.ssid = 'ssidAP'
    ap.getTitle()
    expect(ap.isLinkedInfoForMe(linkedInfo)).assertFalse()
    ap.configs = [config]
    expect(ap.isLinkedInfoForMe(linkedInfo)).assertFalse()
    config.netId = linkedInfo.networkId
    expect(ap.isLinkedInfoForMe(linkedInfo)).assertTrue()
    ap.configs = null
    ap.scanResults = [scanRes]
    expect(ap.isLinkedInfoForMe(linkedInfo)).assertFalse()
    scanRes.bssid = linkedInfo.bssid
    expect(ap.isLinkedInfoForMe(linkedInfo)).assertFalse()
    scanRes.ssid = linkedInfo.ssid
    expect(ap.isLinkedInfoForMe(linkedInfo)).assertTrue()
  })
  it('test_isHidden', 0, () => {
    let ap = new AccessPoint(null)
    let linkedInfo = getDefaultLinkedInfo()
    let config = getDefaultWifiConfig()
    expect(ap.isHidden()).assertFalse()
    expect(ap.isSaved()).assertFalse()
    ap.configs = [config]
    expect(ap.isHidden()).assertFalse()
    expect(ap.isSaved()).assertTrue()
    config.isHiddenSsid = true
    expect(ap.isHidden()).assertTrue()
    ap.lastLinkedInfo = linkedInfo
    expect(ap.isHidden()).assertFalse()
    linkedInfo.isHidden = true
    expect(ap.isHidden()).assertTrue()
  })
  it('test_getBestConfig', 0, () => {
    let ap = new AccessPoint(null)
    let config = getDefaultWifiConfig()
    expect(ap.getBestConfig()).assertEqual(undefined)
    ap.configs = [config]
    expect(ap.getBestConfig()).assertEqual(config)
    ap.bestBssid = config.bssid!
    expect(ap.getBestConfig()).assertEqual(config)
  })
  it('test_getOthers', 0, () => {
    let ap = new AccessPoint(null)
    let linkedInfo = getDefaultLinkedInfo()
    expect(ap.getFrequency()).assertEqual(0)
    expect(ap.getIpAddress()).assertEqual(0)
    expect(ap.getSpeed()).assertEqual(0)
    expect(ap.getMacAddress()).assertEqual('')
    ap.lastLinkedInfo = linkedInfo
    expect(ap.getFrequency()).assertEqual(linkedInfo.frequency)
    expect(ap.getIpAddress()).assertEqual(linkedInfo.ipAddress)
    expect(ap.getSpeed()).assertEqual(linkedInfo.linkSpeed)
    expect(ap.getMacAddress()).assertEqual(linkedInfo.macAddress)
  })
  it('test_compare', 0, () => {
    let mocker: MockKit = new MockKit()
    let ap1: AccessPoint = new AccessPoint(null)
    ap1.ssid = 'ssid1'
    ap1.securityType = 1
    let isActive1: Function = mocker.mockFunc(ap1, ap1.isActive)
    let isReachable1: Function = mocker.mockFunc(ap1, ap1.isReachable)
    let isSaved1: Function = mocker.mockFunc(ap1, ap1.isSaved)

    let ap2: AccessPoint = new AccessPoint(null)
    ap2.ssid = 'ssid2'
    ap2.securityType = 2
    let isActive2: Function = mocker.mockFunc(ap2, ap2.isActive)
    let isReachable2: Function = mocker.mockFunc(ap2, ap2.isReachable)
    let isSaved2: Function = mocker.mockFunc(ap2,ap2.isSaved);
    {
      when(isActive1)(ArgumentMatchers.any).afterReturn(true)
      when(isActive2)(ArgumentMatchers.any).afterReturn(false)
      expect(AccessPoint.compare(ap1,ap2)).assertEqual(-1)
      when(isActive1)(ArgumentMatchers.any).afterReturn(false)
      when(isActive2)(ArgumentMatchers.any).afterReturn(true)
      expect(AccessPoint.compare(ap1,ap2)).assertEqual(1)
      when(isActive1)(ArgumentMatchers.any).afterReturn(true)
      when(isActive2)(ArgumentMatchers.any).afterReturn(true)
    }
    {
      when(isReachable1)(ArgumentMatchers.any).afterReturn(true)
      when(isReachable2)(ArgumentMatchers.any).afterReturn(false)
      expect(AccessPoint.compare(ap1,ap2)).assertEqual(-1)
      when(isReachable1)(ArgumentMatchers.any).afterReturn(false)
      when(isReachable2)(ArgumentMatchers.any).afterReturn(true)
      expect(AccessPoint.compare(ap1,ap2)).assertEqual(1)
      when(isReachable1)(ArgumentMatchers.any).afterReturn(true)
      when(isReachable2)(ArgumentMatchers.any).afterReturn(true)
    }
    {
      when(isSaved1)(ArgumentMatchers.any).afterReturn(true)
      when(isSaved2)(ArgumentMatchers.any).afterReturn(false)
      expect(AccessPoint.compare(ap1,ap2)).assertEqual(-1)
      when(isSaved1)(ArgumentMatchers.any).afterReturn(false)
      when(isSaved2)(ArgumentMatchers.any).afterReturn(true)
      expect(AccessPoint.compare(ap1,ap2)).assertEqual(1)
      when(isSaved1)(ArgumentMatchers.any).afterReturn(true)
      when(isSaved2)(ArgumentMatchers.any).afterReturn(true)
    }
    {
      ap1.bestLevel = 5
      ap2.bestLevel = 10
      expect(AccessPoint.compare(ap1,ap2)).assertEqual(5)
      ap2.bestLevel = 5
    }
    {
      ap1.bestRssi = 5
      ap2.bestRssi = 10
      expect(AccessPoint.compare(ap1,ap2)).assertEqual(5)
      ap2.bestRssi = 5
    }
    {
      ap1.securityType = 5
      ap2.securityType = 10
      expect(AccessPoint.compare(ap1,ap2)).assertEqual(5)
      ap2.securityType = 5
    }
    AccessPoint.compare(ap1,ap2)
    mocker.clear(ap1)
    mocker.clear(ap2)
  })
}

function getDefaultLinkedInfo(): wifiManager.WifiLinkedInfo {
  return {
    ssid: "MyHomeNetwork",
    bssid: "00:11:22:33:44:55",
    networkId: 12345,
    rssi: -60,
    band: 1,
    linkSpeed: 54,
    rxLinkSpeed: 54,
    maxSupportedTxLinkSpeed: 150,
    maxSupportedRxLinkSpeed: 150,
    frequency: 2412,
    isHidden: false,
    isRestricted: true,
    chload: 50,
    snr: 20,
    macType: 0,
    macAddress: "00:11:22:33:44:55",
    ipAddress: 1921681100,
    suppState: 0,
    connState: 0,
    channelWidth: 0,
    wifiStandard: 0,
    supportedWifiCategory: 0,
    isHiLinkNetwork: false,
    isHiLinkProNetwork:false,
  };
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


function AccessPointTestSetScanResults001() {
  it('AccessPointTest_setScanResults_001', 0, () => {
    let ap: AccessPoint = new AccessPoint(null);
    ap.setScanResults(null);
    expect(undefined).assertEqual(ap.scanResults);
  });
}

function accessPointTestIsSameAp03() {
  it('AccessPointTest_isSameAp_03', 0, () => {
    let ap: AccessPoint = new AccessPoint([]);
    let ap1: AccessPoint = new AccessPoint([]);
    ap.ssid = 'test';
    ap1.ssid = 'test';
    ap1.securityType = 1;
    expect(ap.isSameAp(ap1)).assertFalse();
  });
}

function accessPointTestIsSameAp02() {
  it('AccessPointTest_isSameAp_02', 0, () => {
    let ap: AccessPoint = new AccessPoint([]);
    let ap1: AccessPoint = new AccessPoint([]);
    ap1.securityType = 1;
    expect(ap.isSameAp(ap1)).assertFalse();
  });
}

function accessPointTestIsSameAp01() {
  it('AccessPointTest_isSameAp_01', 0, () => {
    let ap: AccessPoint = new AccessPoint([]);
    let ap1: AccessPoint = new AccessPoint([]);
    ap1.ssid = 'test';
    expect(ap.isSameAp(ap1)).assertFalse();
  });
}

function accessPointTestIsSameAp() {
  it('AccessPointTest_isSameAp', 0, () => {
    let ap: AccessPoint = new AccessPoint([]);
    let ap1: AccessPoint = new AccessPoint([]);
    expect(ap.isSameAp(ap1)).assertFalse();
  });
}

function apMenuGetLogKey() {
  it('ApMenu_getLogKey', 0, () => {
    let apMenu = new ApMenu({
      ssid: 'ssid',
      securityType: 1
    });
    let logKey = 'WifiComponent ssid, Wifi Security Type:1';
    expect(apMenu.getLogKey()).not().assertUndefined();
  });
}

function apMenuUpdateDifferentData() {
  it('ApMenu_update_different_data', 0, () => {
    let apMenu: ApMenu = new ApMenu({
      ssid: 'ssid',
      bssid: 'bssid',
      bssidType: 1,
      level: 1,
      securityType: 1,
      supportedWifiCategory: 1,
      isHiLinkNetwork: true,
      scanResults: [new WifiScanResult({
        ssid: '1',
        bssid: '1',
        bssidType: 1,
        capabilities: '1',
        securityType: 1,
        rssi: 1,
        band: 1,
        frequency: 1,
        channelWidth: 1,
        timestamp: 1,
        supportedWifiCategory: 1,
        isHiLinkNetwork: true,
        isHiLinkProNetwork: false,
        centerFrequency0: 1,
        centerFrequency1: 1,
        infoElems: []
      })]
    });
    let newData: Partial<ApMenuData> = {
      title: 'WIFI可用',
      summary: $r('app.string.wifi_status_connected'),
      stateIcon: 'public/images/wifi/wifi_signal_4.svg',
      level: 4
    };
    let isChange = apMenu.update(newData);
    expect(isChange).assertTrue();
  });
}

function apMenuUpdateSameData() {
  it('ApMenu_update_same_data', 0, () => {
    let apMenu: ApMenu = new ApMenu({
      ssid: 'ssid',
      bssid: 'bssid',
      bssidType: 1,
      level: 1,
      securityType: 1,
      supportedWifiCategory: 1,
      isHiLinkNetwork: true,
      scanResults: [new WifiScanResult({
        ssid: '1',
        bssid: '1',
        bssidType: 1,
        capabilities: '1',
        securityType: 1,
        rssi: 1,
        band: 1,
        frequency: 1,
        channelWidth: 1,
        timestamp: 1,
        supportedWifiCategory: 1,
        isHiLinkNetwork: true,
        isHiLinkProNetwork: false,
        centerFrequency0: 1,
        centerFrequency1: 1,
        infoElems: []
      })]
    });
    let isChange = apMenu.update({});
    expect(isChange).assertTrue();
  });
}

function apMenuUpdateNull() {
  it('ApMenu_update_null', 0, () => {
    let apMenu = new ApMenu({});
    let isChange = apMenu.update({});
    expect(isChange).assertFalse();
  });
}

function apMenuConstructor() {
  it('ApMenuConstructor', 0, () => {
    let apMenu: ApMenu = new ApMenu({
      ssid: 'ssid',
      bssid: 'bssid',
      bssidType: 1,
      level: 1,
      securityType: 1,
      supportedWifiCategory: 1,
      isHiLinkNetwork: true,
      scanResults: [new WifiScanResult({
        ssid: '1',
        bssid: '1',
        bssidType: 1,
        capabilities: '1',
        securityType: 1,
        rssi: 1,
        band: 1,
        frequency: 1,
        channelWidth: 1,
        timestamp: 1,
        supportedWifiCategory: 1,
        isHiLinkNetwork: true,
        isHiLinkProNetwork: false,
        centerFrequency0: 1,
        centerFrequency1: 1,
        infoElems: []
      })]
    });
    expect(apMenu.ssid).assertEqual('ssid');
  });
}

function wifiScanResultConstructor() {
  it('WifiScanResultConstructor', 0, () => {
    let wifiScanInfo: wifiManager.WifiScanInfo = {
      ssid: 'test',
      bssid: 'test',
      bssidType: 1,
      capabilities: 'test',
      securityType: 1,
      rssi: 1,
      band: 1,
      frequency: 1,
      channelWidth: 1,
      timestamp: 1,
      centerFrequency0: 1,
      centerFrequency1: 1,
      infoElems: [],
      supportedWifiCategory: 1,
      isHiLinkNetwork: true,
      isHiLinkProNetwork: false
    };
    let wr = new WifiScanResult(wifiScanInfo);
    expect(wr.ssid).assertEqual('test');
  });
}
