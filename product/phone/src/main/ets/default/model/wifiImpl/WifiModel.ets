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
import LogUtil from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import ConfigData from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import WifiNativeJs from '@ohos.wifi_native_js';
import wifi from '@ohos.wifi';
import BaseModel from '../../../../../../../../common/utils/src/main/ets/default/model/BaseModel.ets';

const MODULE_TAG = ConfigData.TAG + '.WifiModel -> ';

export class ApScanResult {
  private apInfo = {
    ssid:'',
    bssid: '',
    rssi: -100,
    band: 0,
    frequency: 0,
    timestamp: 0,
    securityType: 1,
  };
  private summary: string = '';
  private connectFlag: boolean = false;

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

  getSSID() {
    return this.apInfo.ssid;
  }

  getSignalLevel(): number {
    return WifiNativeJs.getSignalLevel(this.apInfo.rssi, this.apInfo.band);;
  }

  isConnected() : boolean {
    return (this.connectFlag === true);
  }

  setConnectStatus(status: boolean) {
    this.connectFlag = status;
  }

  updateSummary(summary: string) {
    this.summary = summary;
  }

  getSummary(): string {
    return this.summary;
  }

  isSecurityAp(): boolean {
    // WiFiSecurityType is enum from 0 to 4, 0 is `Invalid`, 1 is `Open`, 2 to 4 is `Encrypted`
    return (this.apInfo.securityType !== 1);
  }

  isValidAp() : boolean {
    // no ssid or signal level 0 is invalid
    return (this.apInfo.ssid !== '' && this.getSignalLevel() != 0);
  }

  renderToListModel(): any {
    function generateArrow(that: ApScanResult): string {
      let signalLevle: string = that.getSignalLevel().toString();
      let lockPrefix: string = 'lock_';
      // connected and not encrypted connection do not add lock on icon
      if (that.isSecurityAp() !== true || that.isConnected() === true) {
        lockPrefix = '';
      }
      let result: string = `/res/image/ic_wifi_${lockPrefix}signal_${signalLevle}_dark.svg`;
      return result;
    }

    let ret = {
      settingIcon: '',
      settingSummary: this.summary,
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
    return JSON.stringify(this.apInfo);
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
      if (!hash[currItem.getSSID()]) {
        hash[currItem.getSSID()] = true;
        total.push(currItem);
      }
      return total;
    }, []);
  }

  static index(arr: ApScanResult[], target: ApScanResult): number {
    return arr.map((item) => {
      return item.getSSID();
    }).indexOf(target.getSSID());
  }
}

export class WifiModel extends BaseModel {
  public wiFiStatusEnum = {
    'Connecting': 1,
    'UnknownState': 3,
    'ApConnected': 4,
    'Disconnecting': 5,
    'Disconnected': 6,
  };
  private userSelectedAp: ApScanResult = new ApScanResult();
  private connectedAp: ApScanResult = new ApScanResult();
  private apScanResults: ApScanResult[] = [];
  private scanIntervalId: number = -1;
  private scanStatus: boolean = false;
  private summary: string = '';

  setUserSelectedAp(apInfo?: any) {
    if (apInfo === null || typeof apInfo === 'undefined') {
      this.userSelectedAp = new ApScanResult();
    }
    LogUtil.info(MODULE_TAG + "set user selected apInfo is : " + JSON.stringify(apInfo));
    this.userSelectedAp = new ApScanResult(apInfo);
  }

  isWiFiActive(): boolean {
    const isActive: boolean = WifiNativeJs.isWifiActive();
    LogUtil.info(MODULE_TAG + 'check WiFi active status is : ' + isActive);
    return isActive;
  }

  enableWiFi(): boolean {
    const ret: boolean = WifiNativeJs.enableWifi();
    LogUtil.info(MODULE_TAG + 'enable WiFi result is : ' + ret);
    return ret;
  }

  disableWifi(): boolean {
    this.setUserSelectedAp(null);
    const ret: boolean = WifiNativeJs.disableWifi();
    LogUtil.info(MODULE_TAG + 'disable WiFi result is : ' + ret);
    return ret;
  }

  scanWiFi(): boolean {
    const ret: boolean = WifiNativeJs.scan();
    LogUtil.info(MODULE_TAG + 'start scan WiFi result is : ' + ret);
    return ret;
  }

  connectWiFi(password: string) {
    let apInfo = this.userSelectedAp.getApInfo();
    let obj: any = {
      "ssid": apInfo.ssid,
      "bssid": apInfo.bssid,
      "preSharedKey": password,
      "isHiddenSsid": false,
      "securityType": apInfo.securityType
    };
    LogUtil.info(MODULE_TAG + 'start to connect WiFi, the parameter is : ' + JSON.stringify(obj));
    // avoid connect the same AP multi times
    WifiNativeJs.disconnect();
    let ret = WifiNativeJs.connectToDevice(obj);
    LogUtil.info(MODULE_TAG + 'connect WiFi ret is ' + ret);
    return ret;
  }

  /**
   * Disconnect wifi
   */
  disconnectWiFi() {
    this.setUserSelectedAp(null);
    let ret = WifiNativeJs.disconnect();
    LogUtil.info(MODULE_TAG + 'disconnect WiFi result is : ' + ret);
    return ret;
  }

  getConnectedAp() {
    return this.connectedAp;
  }

  /**
   * update connected WiFi information
   */
  updateConnectedAp() {
    wifi.getLinkedInfo((err, result) => {
      this.connectedAp = new ApScanResult();
      if (err) {
        LogUtil.info(MODULE_TAG + 'get linked info failed');
        return;
      }
      LogUtil.info(MODULE_TAG + 'get linked info err is : ' + JSON.stringify(err));
      LogUtil.info(MODULE_TAG + 'get linked info result is : ' + JSON.stringify(result));
      // result.connState need as CONNECTED
      if (result.connState !== 4) {
        LogUtil.info(MODULE_TAG + 'result connState is not CONNECTED');
        return;
      }
      this.connectedAp = new ApScanResult({
        ssid: result.ssid,
        bssid: result.bssid,
        rssi: result.rssi,
        band: result.band,
        frequency: result.frequency,
        timestamp: 0,
        securityType: 1,
      });
      this.connectedAp.updateSummary(this.summary);
      this.connectedAp.setConnectStatus(true);
    });
  }

  refreshApScanResults() {
    this.updateConnectedAp();

    WifiNativeJs.getScanInfos((err, results) => {
      if (err) {
        LogUtil.info(MODULE_TAG + "get scan info failed");
        return;
      }

      function removeDuplicateResults(arr: any[]): ApScanResult[] {
        let len: number = Object.keys(arr).length;
        let results: ApScanResult[] = [];
        for (let i = 0; i < len; i++) {
          let item = new ApScanResult(arr[i]);
          if (item.isValidAp() === true) {
            results.push(item);
          }
        }
        results.sort(ApScanResult.compare);
        return ApScanResult.filter(results);
      };

      // make the connected wifi item at the head of the array as
      // the connected wifi need to be shown at top of list-view
      function unshiftConnectedAp(newResults: any[], primaryApInfo: ApScanResult): ApScanResult[] {
        LogUtil.info(MODULE_TAG + 'primaryApInfo is : ' + primaryApInfo.toString());
        if (primaryApInfo.isValidAp() !== true) {
          return newResults;
        }
        let idxInNew = ApScanResult.index(newResults, primaryApInfo);
        if (idxInNew !== -1) {
          newResults.splice(idxInNew, 1);
        }
        newResults.unshift(primaryApInfo);
        return newResults;
      }

      let scanResults: ApScanResult[] = removeDuplicateResults(results);
      this.apScanResults = unshiftConnectedAp(scanResults, this.connectedAp);
      let listModelResults = this.apScanResults.map((item) => {
        return item.renderToListModel();
      });
      AppStorage.SetOrCreate('slWiFiLists', listModelResults);
    });
  }

  setConnectedSummary(summary: string) {
    this.summary = summary;
  }

  setIntervalScanTask() {
    LogUtil.info(MODULE_TAG + 'start set scan interval task');
    this.scanIntervalId = setInterval(() => {
      if (this.scanStatus === true) {
        LogUtil.info(MODULE_TAG + 'direct get scan result');
        this.refreshApScanResults();
        return;
      }
      if (this.isWiFiActive() === true && this.scanWiFi() === true) {
        LogUtil.info(MODULE_TAG + 'call scan wifi to get scan result');
        this.scanStatus = true;
        this.refreshApScanResults();
      }
    }, 3000);
  }

  clearIntervalScanTask() {
    this.scanStatus = false;
    clearInterval(this.scanIntervalId);
    LogUtil.info(MODULE_TAG + 'clear the scan interval id');
  }
}

let wifiModel = new WifiModel();
export default wifiModel as WifiModel;
