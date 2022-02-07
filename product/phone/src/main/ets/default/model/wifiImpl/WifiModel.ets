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
import BaseModel from '../../../../../../../../common/utils/src/main/ets/default/model/BaseModel.ets';
import settings from '@ohos.settings';
import featureAbility from '@ohos.ability.featureAbility'

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
  private apScanResults: ApScanResult[] = [];
  private scanIntervalId: number = -1;
  private scanStatus: boolean = false;

  setUserSelectedAp(apInfo?: any) {
    if (apInfo === null || typeof apInfo === 'undefined') {
      this.userSelectedAp = new ApScanResult();
    }
    LogUtil.info(MODULE_TAG + "set user selected apInfo is : " + JSON.stringify(apInfo));
    this.userSelectedAp = new ApScanResult(apInfo);
  }

  getUserSelectedAp(): ApScanResult {
    return this.userSelectedAp;
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
    let apInfo = this.getPrimaryApInfo().getApInfo();
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

  /**
   * Get connected WiFi information
   */
  getWiFiLinkedInfo() {
    WifiNativeJs.getWiFiLinkedInfo(results => {
      LogUtil.info(MODULE_TAG + ' get linked info is : ' + results);
    });
  }

  refreshApScanResults() {
    WifiNativeJs.getScanInfos((err, results) => {
      if (err) {
        LogUtil.info(MODULE_TAG + "get scan info error : " + JSON.stringify(err));
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
      function unshiftPrimaryApScanResult(newResults: any[], oldResults: any[],
                                         primaryApInfo: ApScanResult): ApScanResult[] {
        let idxInNew = ApScanResult.index(newResults, primaryApInfo);
        let idxInOld = ApScanResult.index(oldResults, primaryApInfo);
        // direct return the scan results
        if (idxInNew === -1 && idxInOld === -1) {
          return newResults;
        }
        // new scan results not contains the primary ap info,
        // but old results had it, using old one
        if (idxInNew === -1 && idxInOld !== -1) {
          newResults.unshift(oldResults[idxInOld]);
          return newResults;
        }
        // new scan results contains the primary ap info,
        // and the old results is not, using new one
        if (idxInNew !== -1 && idxInOld === -1) {
          newResults.splice(idxInNew, 1);
          newResults.unshift(primaryApInfo);
        }
        // new scan results and old results both had primary ap info,
        // update new one's summary and connected status by old one
        if (idxInNew !== -1 && idxInOld !== -1) {
          let temp = newResults[idxInNew];
          temp.setConnectStatus(oldResults[idxInOld].isConnected());
          temp.updateSummary(oldResults[idxInOld].getSummary());
          newResults.splice(idxInNew, 1);
          newResults.unshift(temp);
        }
        return newResults;
      }

      let scanResults: ApScanResult[] = removeDuplicateResults(results);
      scanResults = unshiftPrimaryApScanResult(scanResults, this.apScanResults, this.getPrimaryApInfo());
      this.apScanResults = scanResults;
      let listModelRestuls = this.apScanResults.map((item) => {
        return item.renderToListModel();
      });
      AppStorage.SetOrCreate('slWiFiLists', listModelRestuls);
    });
  }

  private getPrimaryApInfo(): ApScanResult {
    function loadPrimaryApInfo(): ApScanResult {
      let urivar = settings.getUri('settings.wifi.lastConnected');
      let dataAbilityHelper = featureAbility.acquireDataAbilityHelper(urivar);
      let apInfoStr: string = settings.getValue(dataAbilityHelper, 'settings.wifi.lastConnected', '');
      let result = new ApScanResult();
      if (apInfoStr !== '') {
        result = new ApScanResult(JSON.parse(apInfoStr));
      }
      LogUtil.info(MODULE_TAG + 'get stored primary ap info str is : ' + apInfoStr
      + ' and it to string is :' + result.toString());
      return result;
    }

    if (this.userSelectedAp.isValidAp()) {
      return this.userSelectedAp;
    }
    let primary = new ApScanResult();
    let loadedApInfo = loadPrimaryApInfo();
    if (loadedApInfo.isValidAp()) {
      primary = loadedApInfo;
    }
    return primary;
  }

  removePrimaryApInfo() {
    let primaryApInfo = this.getPrimaryApInfo();
    if (primaryApInfo.isValidAp() !== true) {
      return;
    }
    let index = ApScanResult.index(this.apScanResults, primaryApInfo);
    LogUtil.info(MODULE_TAG + 'find primary ap info in scan result is' + index);
    if (index !== -1) {
      this.apScanResults[index].setConnectStatus(false);
      this.apScanResults[index].updateSummary('');
    }
  }

  updatePrimaryApInfo(summary: any) {
    function storePrimaryApInfo(primary: ApScanResult) {
      LogUtil.info(MODULE_TAG + 'start to store primary ap info : ' + primary.toString());
      if (!primary.isValidAp()) {
        LogUtil.info(MODULE_TAG + 'we do not save the invalid ap info');
        return;
      }
      let urivar = settings.getUri('settings.wifi.lastConnected');
      let dataAbilityHelper = featureAbility.acquireDataAbilityHelper(urivar);
      let ret = settings.setValue(dataAbilityHelper, 'settings.wifi.lastConnected', primary.toString());
      LogUtil.info(MODULE_TAG + 'ret of store primary ap info is : ' + ret);
    };

    let primary = this.getPrimaryApInfo();
    if (primary.isValidAp() !== true) {
      LogUtil.info(MODULE_TAG + 'unknown status, disconnect and break');
      this.disconnectWiFi();
      return;
    }
    let index = ApScanResult.index(this.apScanResults, primary);
    if (index !== -1) {
      this.apScanResults[index].updateSummary(summary);
      this.apScanResults[index].setConnectStatus(true);
      let temp = this.apScanResults[index];
      this.apScanResults.splice(index, 1);
      this.apScanResults.unshift(temp);
    }
    // store primary ap info into settings data
    storePrimaryApInfo(primary);
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
