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
import LogUtil from '../../common/baseUtil/LogUtil.ets';
import WifiNativeJs from '@ohos.wifi_native_js';
import BaseParseConfModel from '../baseParseConfImpl/BaseParseConfModel.ets';
import BaseModel from '../BaseModel.ets';
import BrightnessSettingModel from '../brightnessImpl/BrightnessSettingModel.ets';

export class WifiModel extends BaseModel {
  private mWifiList: any[] = [];
  private remdupWifiList: any[] = [];
  private linkedInfoList: any[] = [];

  getWifiStatus() {
    LogUtil.info('WifiNativeJs isWifiActive');
    return WifiNativeJs.isWifiActive();
  }

  getEnableWifi() {
    LogUtil.info('WifiNativeJs enableWifi');
    return WifiNativeJs.enableWifi();
  }

  disableWifi() {
    this.linkedInfoList = [];
    LogUtil.info('WifiNativeJs disableWifi');
    return WifiNativeJs.disableWifi();
  }

  getScanWifi() {
    LogUtil.info('WifiNativeJs scan');
    return WifiNativeJs.scan();
  }

  getScanInfoCallBack() {
    LogUtil.info('get to wifi info start');
    this.mWifiList = [];
    this.remdupWifiList = [];
    WifiNativeJs.getScanInfos(result => {
      LogUtil.info('[wifi_js_test] wifi received scan info call back results1:' + JSON.stringify(result));
      if (result === null) {
        return;
      }
      LogUtil.info('[wifi_js_test] wifi received scan info call back results2:' + JSON.stringify(result));
      let clen = Object.keys(result)
        .length;
      let image;
      LogUtil.info('[wifi_js_test] wifi received scan info call back length:' + clen);
      for (let j = 0; j < clen; j++) {
        LogUtil.info('result[0].ssid: ' + result[j].ssid);
        LogUtil.info('securityType: ' + result[j].securityType);
        LogUtil.info('rssi: ' + result[j].rssi);
        LogUtil.info('bssid: ' + result[j].bssid);
        LogUtil.info('band: ' + result[j].band);
        LogUtil.info('frequency: ' + result[j].frequency);
        LogUtil.info('timestamp: ' + result[j].timestamp);
        LogUtil.info('SignalLevel: ' + WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band));
        if (result[j].securityType === 1 && WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band) === 4) {
          image = '/res/image/ic_wifi_signal_4_dark.svg';
          LogUtil.info('securityType 1 and signal level 4');
        }
        if (result[j].securityType === 1 && WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band) === 3) {
          image = '/res/image/ic_wifi_signal_3_dark.svg';
          LogUtil.info('securityType 1 and signal level 3');
        }
        if (result[j].securityType === 1 && WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band) === 2) {
          image = '/res/image/ic_wifi_signal_2_dark.svg';
          LogUtil.info('securityType 1 and signal level 2');
        }
        if (result[j].securityType === 1 && WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band) === 1) {
          image = '/res/image/ic_wifi_signal_1_dark.svg';
          LogUtil.info('securityType 1 and signal level 1');
        }
        if (result[j].securityType === 1 && WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band) === 0) {
          image = '/res/image/ic_wifi_signal_1_dark.svg';
          LogUtil.info('securityType 1 and signal level 1');
        }
        if (result[j].securityType !== 1 && WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band) === 4) {
          image = '/res/image/ic_wifi_lock_signal_4_dark.svg';
          LogUtil.info('securityType lock and level 4');
        }
        if (result[j].securityType !== 1 && WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band) === 3) {
          image = '/res/image/ic_wifi_lock_signal_3_dark.svg';
          LogUtil.info('securityType lock and level 3');
        }
        if (result[j].securityType !== 1 && WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band) === 2) {
          image = '/res/image/ic_wifi_lock_signal_2_dark.svg';
          LogUtil.info('securityType lock and level 2');
        }
        if (result[j].securityType !== 1 && WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band) === 1) {
          image = '/res/image/ic_wifi_lock_signal_1_dark.svg';
          LogUtil.info('securityType lock and level 1');
        }
        if (result[j].securityType !== 1 && WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band) === 0) {
          image = '/res/image/ic_wifi_lock_signal_1_dark.svg';
          LogUtil.info('securityType lock and level 1');
        }

        if (result[j].ssid === '' || result[j] === null) {
          LogUtil.info('result ssid empty');
        } else {
          this.mWifiList.push({
            settingSummary: '',
            settingTitle: result[j].ssid,
            settingValue: '',
            settingArrow: image,
            settingRssi: result[j].rssi,
            settingBand: result[j].band,
            bssid: result[j].bssid,
            securityType: result[j].securityType,
            signalLevel: WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band),
          });
        }
      }
      LogUtil.info('original mWifiList :' + JSON.stringify(this.mWifiList));
      for (let i = 0; i < this.mWifiList.length; i++) {
        let position = this.getItemPosition(this.remdupWifiList, this.mWifiList[i].settingTitle);
        if (position !== -1) {
          if (this.remdupWifiList[position].signalLevel < this.mWifiList[i].signalLevel) {
            this.remdupWifiList.splice(position, 1);
            this.remdupWifiList.splice(position, 0, this.mWifiList[i]);
          }
        } else {
          this.remdupWifiList.push(this.mWifiList[i]);
        }
      }
      LogUtil.info('get linkedList info before0 ：' + JSON.stringify(this.linkedInfoList));
      LogUtil.info('get linkedList info before1 ：' + this.linkedInfoList.length);
      if (this.linkedInfoList.length === 0) {
        LogUtil.info('get linkedList info linkedInfoList empty ：');
      } else {
        if (this.linkedInfoList[0].settingTitle !== '' && clen > 0) {
          LogUtil.info('get linkedList info start ：');
          let index = this.getItemPosition(this.remdupWifiList, this.linkedInfoList[0].settingTitle)
          let settingTitle = this.linkedInfoList[0].settingTitle;
          let settingArrow = this.remdupWifiList[index].settingArrow;
          let settingRssi = this.linkedInfoList[0].settingRssi;
          let settingBand = this.linkedInfoList[0].settingBand;
          let bssid = this.linkedInfoList[0].bssid;
          let securityType = this.remdupWifiList[index].securityType;
          this.remdupWifiList.splice(index, 1);
          this.remdupWifiList.unshift({
            settingSummary: $r('app.string.connected'),
            settingTitle: settingTitle,
            settingValue: '',
            settingArrow: settingArrow,
            settingArrowStyle: 'wifi',
            settingRssi: settingRssi,
            settingBand: settingBand,
            bssid: bssid,
            securityType: securityType,
          });
        } else {
          LogUtil.info('get linkedList info linkedInfoList settingTitle is empty ：');
        }
      }
      AppStorage.SetOrCreate('WifiList', this.remdupWifiList);
      LogUtil.info('remove duplicate ssid remdupWifiList: ' + JSON.stringify(this.remdupWifiList));
    });
    LogUtil.info('get to wifi information end ---->');
  }

  getItemPosition(list, ssid) {
    for (let i = 0; i < list.length; i++) {
      if (ssid === list[i].settingTitle) {
        return i;
      }
    }
    return -1;
  }

  connectToDevice(obj) {
    LogUtil.info('[wifi_js_test] connect to wifi');
    return WifiNativeJs.connectToDevice(obj);
  }

  disConnect() {
    LogUtil.info('netWork disconnect');
    return WifiNativeJs.disConnect();
  }

  getLinkedInfo() {
    this.linkedInfoList = [];
    LogUtil.info('[wifi_js] get wifi linked info start');
    WifiNativeJs.getLinkedInfo()
      .then(data => {
      LogUtil.info("[wifi_js] get wifi linked info [promise] -> " + JSON.stringify(data));
      LogUtil.info("[wifi_js] get wifi linked info [promise] -> " + JSON.stringify(data.ssid));
      LogUtil.info('data result[0].ssid: ' + data.ssid);
      LogUtil.info('data rssi: ' + data.rssi);
      LogUtil.info('data bssid: ' + data.bssid);
      LogUtil.info('data band: ' + data.band);
      this.linkedInfoList.push({
        settingSummary: '',
        settingTitle: data.ssid,
        settingValue: '',
        settingArrow: '',
        settingRssi: data.rssi,
        settingBand: data.band,
        bssid: data.bssid,
        securityType: '',
        signalLevel: WifiNativeJs.getSignalLevel(data.rssi, data.band),
      });
      LogUtil.info("[wifi_js] get wifi linked info linkedInfoList 1" + JSON.stringify(this.linkedInfoList))
      AppStorage.SetOrCreate('linkedInfoList', this.linkedInfoList);
      LogUtil.info("[wifi_js] get wifi linked info linkedInfoList 2" + JSON.stringify(this.linkedInfoList))
    })
      .catch(error => {
      LogUtil.info("[wifi_js] linked info promise then error" + error);
    })
    LogUtil.info('[wifi_js] get wifi linked info end');
  }
}

let wifiModel = new WifiModel();
export default wifiModel as WifiModel
;