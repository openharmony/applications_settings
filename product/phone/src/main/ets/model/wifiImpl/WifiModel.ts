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
import wifi from '@ohos.wifiManager';
import BaseModel from '../../../../../../../common/utils/src/main/ets/default/model/BaseModel';
import { BusinessError } from '@ohos.base';

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
    return wifi.getSignalLevel(this.apInfo.rssi, this.apInfo.band);
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

  renderToListModel(): { settingIcon: string, settingSummary: number, settingTitle: string, settingValue: string,
    settingArrow: string, settingArrowStyle: string, settingUri: string, apInfo: WifiScanInfo } {
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
  private linkedApInfo: wifi.WifiLinkedInfo = null
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

  unregisterWiFiStatusObserver(callback) {
    LogUtil.info(MODULE_TAG + 'start unregister wifi status observer');
    wifi.off('wifiStateChange', callback);
  }

  registerWiFiConnectionObserver(callback) {
    LogUtil.info(MODULE_TAG + 'start register wifi connection observer');
    wifi.on('wifiConnectionChange', callback);
  }

  unregisterWiFiConnectionObserver() {
    LogUtil.info(MODULE_TAG + 'start unregister wifi connection observer');
    try {
      if (wifi.isWifiActive()) {
        wifi.off('wifiConnectionChange');
      }
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      LogUtil.error(MODULE_TAG + `off failed errorCode: ${e.code},  Message: ${e.message}`);
    }
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
    try {
      wifi.enableWifi();
    }catch(error){
      LogUtil.info(MODULE_TAG + "enable failed:" + JSON.stringify(error));
    }
  }

  disableWifi() {
    this.setUserSelectedAp(null);

    if (wifi.isWifiActive() !== true) {
      LogUtil.info(MODULE_TAG + 'wifi is already inactive');
      return;
    }
    try {
      wifi.disableWifi();
    }catch(error){
      LogUtil.info(MODULE_TAG + "disAble failed:" + JSON.stringify(error));
    }
  }

  scanWiFi() {
    try {
      wifi.startScan()
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      LogUtil.error(MODULE_TAG + `startScan failed errorCode: ${e.code},  Message: ${e.message}`);
    }
  }

  connectWiFi(password: string) {
    let apInfo = this.userSelectedAp.getApInfo();
    let ret = false;
    let connectParam: wifi.WifiDeviceConfig = {
      "ssid": apInfo.ssid,
      "bssid": apInfo.bssid,
      "preSharedKey": password,
      "isHiddenSsid": false, // we don't support connect to hidden ap yet
      "securityType": apInfo.securityType
    };
    LogUtil.info(MODULE_TAG + 'disconnect WiFi isConnected is ' + wifi.isConnected());
    if (wifi.isConnected() === true) {
      wifi.disconnect();
      LogUtil.info(MODULE_TAG + 'disconnect WiFi ret is ' + ret);
      this.registerWiFiConnectionObserver((code: Number) => {
        if (code === 0) {
          try {
            wifi.connectToDevice(connectParam);
            this.unregisterWiFiConnectionObserver();
          } catch (error) {
            let e: BusinessError = error as BusinessError;
            LogUtil.error(MODULE_TAG + `connectToDevice failed errorCode: ${e.code},  Message: ${e.message}`);
          }
        }
      })
    } else {
      try {
        wifi.connectToDevice(connectParam);
        LogUtil.info(MODULE_TAG + 'connect WiFi ret is ' + ret);
      } catch (error) {
        let e: BusinessError = error as BusinessError;
        LogUtil.error(MODULE_TAG + `connectToDevice failed errorCode: ${e.code},  Message: ${e.message}`);
      }
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
    wifi.removeDevice(networkId);
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
    wifi.getLinkedInfo((err: BusinessError, result: wifi.WifiLinkedInfo) => {
      if (err) {
        LogUtil.info(MODULE_TAG + 'get linked info failed');
        return;
      }
      LogUtil.info(MODULE_TAG + 'scan get linked info succeed');
      this.linkedApInfo = result;
    });

    let results: wifi.WifiScanInfo[] = wifi.getScanInfoList()
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
    if (this.linkedApInfo) {
      let linkInfoResult: ApScanResult = addConnectStatusFlag(scanResults, this.linkedApInfo);
      if (linkInfoResult.isConnected()) {
        AppStorage.SetOrCreate('slnetId', this.linkedApInfo.networkId + '');
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
  }

  startScanTask() {
    LogUtil.info(MODULE_TAG + 'start the wifi scan task');

    if (this.scanTaskId !== Undefined_TaskId) {
      clearInterval(this.scanTaskId);
      this.scanTaskId = Undefined_TaskId;
    }

    this.scanTaskId = setInterval(() => {
      if (this.isWiFiActive() && this.isScanning) {
        this.refreshApScanResults();
        return;
      }
      if (this.isWiFiActive() === true) {
        LogUtil.info(MODULE_TAG + 'scan wifi started');
        this.scanWiFi();
        this.isScanning = true;
        this.refreshApScanResults();
      }
    }, 5000);
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
