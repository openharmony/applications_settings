/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import wifi from '@ohos.wifi';
import BaseModel from '../../../../../../../common/utils/src/main/ets/default/model/BaseModel';

const MODULE_TAG = ConfigData.TAG + 'WifiModel -> ';
const Undefined_TaskId = -1;
export interface WifiScanInfo {
  ssid: string,
  bssid: string,
  rssi: number,
  band: number,
  frequency: number,
  timestamp: number,
  securityType: number,
};

export enum ConnState {
  /** The device is searching for an available AP. */
  SCANNING,

  /** The Wi-Fi connection is being set up. */
  CONNECTING,

  /** The Wi-Fi connection is being authenticated. */
  AUTHENTICATING,

  /** The IP address of the Wi-Fi connection is being obtained. */
  OBTAINING_IPADDR,

  /** The Wi-Fi connection has been set up. */
  CONNECTED,

  /** The Wi-Fi connection is being torn down. */
  DISCONNECTING,

  /** The Wi-Fi connection has been torn down. */
  DISCONNECTED,

  /** Failed to set up the Wi-Fi connection. */
  UNKNOWN
}

export enum WiFiSummaryMap {
  CONNECTED,
  CONNECTING,
  SAVE_ENCRYPTED,
  SAVE_OPEN,
  ENCRYPTED,
  OPEN,
  OBTAINING_IP,
}

export enum WiFiIntensityMap {
  GOOD,
  WELL,
  NORMAL,
  BAD,
}

export enum WiFiEncryptMethodMap {
  OPEN,
  WEP,
  WPA,
  WPA2,
}

export class ApScanResult {
  // interface WifiScanInfo
  private apInfo = {
    ssid:'',
    bssid: '',
    rssi: -100,
    band: 0,
    frequency: 0,
    timestamp: 0,
    securityType: 1,
  };
  private connectStatus: number = ConnState.UNKNOWN;
  private isSaved: boolean = false;

  constructor(apInfo?: any);

  constructor(apInfo: any) {
    if (apInfo === null || apInfo === undefined) {
      return;
    }
    this.apInfo = apInfo;
  };

  getApInfo() {
    return this.apInfo;
  }

  getSignalLevel(): number {
    return wifi.getSignalLevel(this.apInfo.rssi, this.apInfo.band);;
  }

  isConnected(): boolean {
    return (this.connectStatus === ConnState.CONNECTED);
  }

  isSavedConfig(): boolean {
    return (this.isSaved === true);
  }

  isSecurityAp(): boolean {
    // WiFiSecurityType is enum from 0 to 4, 0 is `Invalid`, 1 is `Open`, 2 to 4 is `Encrypted`
    return (this.apInfo.securityType !== 1);
  }

  isValidAp(): boolean {
    // no ssid or signal level 0 is invalid
    return (this.apInfo.ssid !== '' && this.getSignalLevel() != 0);
  }

  updateConnectStatus(status: number) {
    this.connectStatus = status;
  }

  updateSavedStatus(status: boolean) {
    this.isSaved = status;
  }

  renderToListModel(): any {
    function generateArrow(that: ApScanResult): string {
      let signalLevel: string = that.getSignalLevel().toString();
      let lockPrefix: string = 'lock_';
      if (that.isSecurityAp() !== true) {
        lockPrefix = '';
      }
      let result: string = `/res/image/ic_wifi_${lockPrefix}signal_${signalLevel}_dark.svg`;
      return result;
    }

    function generateSummary(that: ApScanResult): number {
      if (that.isConnected()) {
        return WiFiSummaryMap.CONNECTED;
      }
      if (that.connectStatus === ConnState.CONNECTING) {
        return WiFiSummaryMap.CONNECTING;
      }
      if (that.connectStatus === ConnState.OBTAINING_IPADDR) {
        return WiFiSummaryMap.OBTAINING_IP;
      }
      if (that.isSavedConfig()) {
        if (that.isSecurityAp()) {
          return WiFiSummaryMap.SAVE_ENCRYPTED;
        } else {
          return WiFiSummaryMap.SAVE_OPEN;
        }
      } else {
        if (that.isSecurityAp()) {
          return WiFiSummaryMap.ENCRYPTED;
        } else {
          return WiFiSummaryMap.OPEN;
        }
      }
    }

    let ret = {
      settingIcon: '',
      settingSummary: generateSummary(this),
      settingTitle: this.apInfo.ssid,
      settingValue: '',
      settingArrow: generateArrow(this),
      settingArrowStyle: 'wifi',
      settingUri: '',
      apInfo: this.apInfo,
    };
    return ret;
  }

  toString(): string {
    return `apInfo is: ssid=${this.getApInfo().ssid} signal=${this.getSignalLevel()} isConnected=${this.isConnected()}`;
  }

  static compare(x: ApScanResult, y: ApScanResult): number {
    let xApInfo = x.getApInfo();
    let yApInfo = y.getApInfo();
    // rssi value is negative number
    return ((-xApInfo.rssi) - (-yApInfo.rssi));
  }

  static filter(arr: ApScanResult[]): ApScanResult[] {
    let hash = {};
    return arr.reduce((total, currItem) => {
      if (!hash[currItem.getApInfo().ssid]) {
        hash[currItem.getApInfo().ssid] = true;
        total.push(currItem);
      }
      return total;
    }, []);
  }

  static index(arr: ApScanResult[], target: ApScanResult): number {
    return arr.map((item) => {
      return item.getApInfo().ssid;
    }).indexOf(target.getApInfo().ssid);
  }
}

export class WifiModel extends BaseModel {
  private userSelectedAp: ApScanResult = new ApScanResult();
  private linkedApInfo: any = undefined;

  private scanTaskId: number = Undefined_TaskId;
  private isScanning: boolean = false;

  destroyWiFiModelData() {
    this.linkedApInfo = undefined;
    this.setUserSelectedAp(null);
    AppStorage.SetOrCreate('slConnectedWifi', (new ApScanResult()).renderToListModel());
  }

  registerWiFiStatusObserver(callback) {
    LogUtil.info(MODULE_TAG + 'start register wifi status observer');
    wifi.on('wifiStateChange', callback);
  }

  unregisterWiFiStatusObserver() {
    LogUtil.info(MODULE_TAG + 'start unregister wifi status observer');
    wifi.off('wifiStateChange');
  }

  registerWiFiConnectionObserver(callback) {
    LogUtil.info(MODULE_TAG + 'start register wifi connection observer');
    wifi.on('wifiConnectionChange', callback);
  }

  unregisterWiFiConnectionObserver() {
    LogUtil.info(MODULE_TAG + 'start unregister wifi connection observer');
    wifi.off('wifiConnectionChange');
  }

  setUserSelectedAp(apInfo?: any) {
    if (apInfo === null || typeof apInfo === 'undefined') {
      this.userSelectedAp = new ApScanResult();
    }
    this.userSelectedAp = new ApScanResult(apInfo);
  }

  isSavedAp(ssid: string): boolean {
    let deviceConfigs: any[] = wifi.getDeviceConfigs();
    for (let i = 0; i < deviceConfigs.length; i++) {
      if (ssid === deviceConfigs[i].ssid) {
        return true;
      }
    }
    return false;
  }

  isWiFiActive(): boolean {
    const isActive: boolean = wifi.isWifiActive();
    LogUtil.info(MODULE_TAG + 'check WiFi active status is : ' + isActive);
    return isActive;
  }

  isWiFiConnected(): boolean {
    let ret = wifi.isConnected();
    LogUtil.info(MODULE_TAG + 'check WiFi connected status is : ' + ret);
    return ret;
  }

  enableWiFi() {
    if (wifi.isWifiActive() === true) {
      LogUtil.info(MODULE_TAG + 'wifi is already active');
      return;
    }
    let ret: boolean = wifi.enableWifi();
    LogUtil.info(MODULE_TAG + 'enable WiFi result is : ' + ret);
    return ret;
  }

  disableWifi() {
    this.setUserSelectedAp(null);

    if (wifi.isWifiActive() !== true) {
      LogUtil.info(MODULE_TAG + 'wifi is already inactive');
      return;
    }
    const ret: boolean = wifi.disableWifi();
    LogUtil.info(MODULE_TAG + 'disable WiFi result is : ' + ret);
  }

  scanWiFi(): boolean {
    const ret: boolean = wifi.scan();
    LogUtil.info(MODULE_TAG + 'start scan WiFi result is : ' + ret);
    return ret;
  }

  connectWiFi(password: string) {
    let apInfo = this.userSelectedAp.getApInfo();
    let ret = false;
    let connectParam: any = {
      "ssid": apInfo.ssid,
      "bssid": apInfo.bssid,
      "preSharedKey": password,
      "isHiddenSsid": false, // we don't support connect to hidden ap yet
      "securityType": apInfo.securityType
    };
    LogUtil.info(MODULE_TAG + 'disconnect WiFi isConnected is ' + wifi.isConnected());
    if (wifi.isConnected() === true) {
      ret = wifi.disconnect();
      LogUtil.info(MODULE_TAG + 'disconnect WiFi ret is ' + ret);
      this.registerWiFiConnectionObserver((code: Number) => {
        if (code === 0) {
          ret = wifi.connectToDevice(connectParam);
          this.unregisterWiFiConnectionObserver();
        }
      })
    }else{
      ret = wifi.connectToDevice(connectParam);
      LogUtil.info(MODULE_TAG + 'connect WiFi ret is ' + ret);
    }
    return ret;
  }

  /**
   * Disconnect wifi
   */
  disconnectWiFi() {
    this.setUserSelectedAp(null);

    let ret = wifi.disconnect();
    LogUtil.info(MODULE_TAG + 'disconnect WiFi result is : ' + ret);
    return ret;
  }

  getSignalIntensity(apInfo: WifiScanInfo) {
    let result = wifi.getSignalLevel(apInfo.rssi, apInfo.band);
    if (result <= 1) {
      return WiFiIntensityMap.BAD;
    }
    if (result <= 2) {
      return WiFiIntensityMap.NORMAL;
    }
    if (result <= 3) {
      return WiFiIntensityMap.WELL;
    }
    return WiFiIntensityMap.GOOD;
  }

  getEncryptMethod(apInfo: WifiScanInfo) {
    if (apInfo.securityType === 1) {
      return WiFiEncryptMethodMap.OPEN;
    }
    if (apInfo.securityType === 2) {
      return WiFiEncryptMethodMap.WEP;
    }
    return WiFiEncryptMethodMap.WPA2;
  }

  getLinkInfo() {
    return this.linkedApInfo;
  }

  removeDeviceConfig(apInfo: WifiScanInfo) {
    LogUtil.info(MODULE_TAG + 'start to removeDeviceConfig');
    let deviceConfigs: any[] = wifi.getDeviceConfigs();
    let networkId: number = -1;
    for (let i = 0; i < deviceConfigs.length; i++) {
      if (deviceConfigs[i].ssid === apInfo.ssid) {
        networkId = deviceConfigs[i].netId;
        break;
      }
    }
    if (networkId === -1) {
      return;
    }
    LogUtil.info(MODULE_TAG + 'start to removeDevice');
    let ret = wifi.removeDevice(networkId);
    LogUtil.info(MODULE_TAG + 'remove device config : ' + ret);
  }

  connectByDeviceConfig(apInfo: WifiScanInfo) {
    let deviceConfigs: any[] = wifi.getDeviceConfigs();
    // find the wifi device config
    for (let i = 0; i < deviceConfigs.length; i++) {
      if (deviceConfigs[i].ssid === apInfo.ssid) {
        let ret = wifi.connectToDevice(deviceConfigs[i]);
        LogUtil.info(MODULE_TAG + 'connect ret for : ' + i + ' = ' + ret);
      }
    }
    LogUtil.info(MODULE_TAG + 'end connect by device config');
  }

  refreshApScanResults() {
    wifi.getLinkedInfo((err, result) => {
      if (err) {
        LogUtil.info(MODULE_TAG + 'get linked info failed');
        return;
      }
      LogUtil.info(MODULE_TAG + 'scan get linked info succeed');
      this.linkedApInfo = result;
    });

    wifi.getScanInfos((err, results) => {
      if (err) {
        LogUtil.info(MODULE_TAG + "get scan info failed");
        return;
      }
      LogUtil.info(MODULE_TAG + 'get scan info succeed');
      function removeDuplicateResults(arr: any[]): ApScanResult[] {
        let results: ApScanResult[] = [];
        for (let i = 0; i < arr.length; i++) {
          let apResult = new ApScanResult(arr[i]);
          if (apResult.isValidAp()) {
            results.push(apResult);
          }
        }
        return ApScanResult.filter(results);
      };

      function removeConnectedAp(arr: ApScanResult[], needRemove: ApScanResult) {
        let index = ApScanResult.index(arr, needRemove);
        if (index !== -1) {
          arr.splice(index, 1);
        }
        return arr;
      }

      function addSavedConfigFlag(aps: ApScanResult[]): ApScanResult[] {
        let configs: ApScanResult[] = [];
        let deviceConfigs: any[] = wifi.getDeviceConfigs();
        for (let i = 0; i < deviceConfigs.length; i++) {
          let temp = new ApScanResult(deviceConfigs[i]);
          configs.push(temp);
        }
        for (let i = 0; i < configs.length; i++) {
          let index = ApScanResult.index(aps, configs[i]);
          if (index !== -1) {
            let item = aps[index];
            item.updateSavedStatus(true);
            aps.splice(index, 1);
            aps.unshift(item);
          }
        }
        return aps;
      }

      function addConnectStatusFlag(arr: ApScanResult[], linked: any): ApScanResult {
        let ap: ApScanResult = new ApScanResult();
        for (let i = 0; i < arr.length; i++) {
          if (arr[i].getApInfo().ssid === linked.ssid) {
            ap = arr[i];
            break;
          }
        }
        ap.updateConnectStatus(linked.connState);
        return ap;
      }

      function unshiftConnectingAp(arr: ApScanResult[], ap: ApScanResult): ApScanResult[] {
        let index = ApScanResult.index(arr, ap);
        if (index !== -1) {
          arr.splice(index, 1);
          arr.unshift(ap);
        }
        return arr;
      }

      // step 1 : remove duplicate ap info
      let scanResults: ApScanResult[] = removeDuplicateResults(results);
      LogUtil.info(MODULE_TAG + 'scan results items length is : ' + scanResults.length);

      // step 2 : add saved config flags
      scanResults = addSavedConfigFlag(scanResults);
      scanResults.sort(ApScanResult.compare);

      // step 3 : add wifi summary
      if (this.linkedApInfo !== null && typeof this.linkedApInfo !== 'undefined') {
        let linkInfoResult: ApScanResult = addConnectStatusFlag(scanResults, this.linkedApInfo);
        if (linkInfoResult.isConnected()) {
          LogUtil.info(MODULE_TAG + 'scan connected');
          scanResults = removeConnectedAp(scanResults, linkInfoResult);
          AppStorage.SetOrCreate('slConnectedWifi', linkInfoResult.renderToListModel());
        } else {
          LogUtil.info(MODULE_TAG + 'scan not connected');
          scanResults = unshiftConnectingAp(scanResults, linkInfoResult);
          AppStorage.SetOrCreate('slConnectedWifi', (new ApScanResult()).renderToListModel());
        }
      }
      LogUtil.info(MODULE_TAG + 'scan list results');
      AppStorage.SetOrCreate('slWiFiLists', scanResults.map((item) => {
        return item.renderToListModel();
      }));
    });
  }

  startScanTask() {
    LogUtil.info(MODULE_TAG + 'start the wifi scan task');

    if (this.scanTaskId !== Undefined_TaskId) {
      clearInterval(this.scanTaskId);
      this.scanTaskId = Undefined_TaskId;
    }

    this.scanTaskId = setInterval(() => {
      if (this.isWiFiActive() === true && this.isScanning === true) {
        this.refreshApScanResults();
        return;
      }
      if (this.isWiFiActive() === true && this.scanWiFi() === true) {
        LogUtil.info(MODULE_TAG + 'scan wifi started');
        this.isScanning = true;
        this.refreshApScanResults();
      }
    }, 3000);
  }

  stopScanTask() {
    LogUtil.info(MODULE_TAG + 'stop the wifi scan task');
    if (this.scanTaskId !== Undefined_TaskId) {
      clearInterval(this.scanTaskId);
      this.scanTaskId = Undefined_TaskId;
    }
    this.isScanning = false;
  }
}

let wifiModel = new WifiModel();
export default wifiModel as WifiModel;
