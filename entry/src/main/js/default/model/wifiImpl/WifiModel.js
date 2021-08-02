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
import BaseModel from '../BaseModel.js';
import LogUtil from '../../common/baseUtil/LogUtil.js';
import WifiNativeJs from '@ohos.wifi_native_js';

let mLogUtil = null;
let mWifiList = [];
let remdupWifiList = [];

export default class WifiModel extends BaseModel {
    constructor() {
        super();
        mLogUtil = new LogUtil();
    }

    getWifiStatus() {
        mLogUtil.info('WifiNativeJs isWifiActive');
        return WifiNativeJs.isWifiActive();
    }

    getEnableWifi() {
        mLogUtil.info('WifiNativeJs enableWifi');
        return WifiNativeJs.enableWifi();
    }
    disableWifi() {
        mLogUtil.info('WifiNativeJs enableWifi');
        return WifiNativeJs.disableWifi();
    }
    getScanWifi() {
        mLogUtil.info('WifiNativeJs scan');
        return WifiNativeJs.scan();
    }
    getScanInfoCallBack() {
        mLogUtil.info('get to wifi info start');
        mWifiList = [];
        remdupWifiList = [];
        WifiNativeJs.getScanInfos(result => {
            if (result == null) {
                return;
            }
            mLogUtil.info('[wifi_js_test] wifi received scan info call back results:' + JSON.stringify(result));
            let clen = Object.keys(result).length;
            let image;
            mLogUtil.info('[wifi_js_test] wifi received scan info call back length:' + clen);
            for (let j = 0; j < clen; j++) {
                mLogUtil.info('result[0].ssid: ' + result[j].ssid);
                mLogUtil.info('securityType: ' + result[j].securityType);
                mLogUtil.info('rssi: ' + result[j].rssi);
                mLogUtil.info('bssid: ' + result[j].bssid);
                mLogUtil.info('band: ' + result[j].band);
                mLogUtil.info('frequency: ' + result[j].frequency);
                mLogUtil.info('timestamp: ' + result[j].timestamp);
                mLogUtil.info('SignalLevel: ' + WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band));
                if (result[j].securityType === 1 && WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band) === 4) {
                    image = '/res/image/ic_wifi_signal_4_dark.svg';
                    mLogUtil.info('securityType 1 and signal level 4');
                }
                if (result[j].securityType === 1 && WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band) === 3) {
                    image = '/res/image/ic_wifi_signal_3_dark.svg';
                    mLogUtil.info('securityType 1 and signal level 3');
                }
                if (result[j].securityType === 1 && WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band) === 2) {
                    image = '/res/image/ic_wifi_signal_2_dark.svg';
                    mLogUtil.info('securityType 1 and signal level 2');
                }
                if (result[j].securityType === 1 && WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band) === 1) {
                    image = '/res/image/ic_wifi_signal_1_dark.svg';
                    mLogUtil.info('securityType 1 and signal level 1');
                }
                if (result[j].securityType === 1 && WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band) === 0) {
                    image = '/res/image/ic_wifi_signal_1_dark.svg';
                    mLogUtil.info('securityType 1 and signal level 1');
                }
                if (result[j].securityType !== 1 && WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band) === 4) {
                    image = '/res/image/ic_wifi_lock_signal_4_dark.svg';
                    mLogUtil.info('securityType lock and level 4');
                }
                if (result[j].securityType !== 1 && WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band) === 3) {
                    image = '/res/image/ic_wifi_lock_signal_3_dark.svg';
                    mLogUtil.info('securityType lock and level 3');
                }
                if (result[j].securityType !== 1 && WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band) === 2) {
                    image = '/res/image/ic_wifi_lock_signal_2_dark.svg';
                    mLogUtil.info('securityType lock and level 2');
                }
                if (result[j].securityType !== 1 && WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band) === 1) {
                    image = '/res/image/ic_wifi_lock_signal_1_dark.svg';
                    mLogUtil.info('securityType lock and level 1');
                }
                if (result[j].securityType !== 1 && WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band) === 0) {
                    image = '/res/image/ic_wifi_lock_signal_1_dark.svg';
                    mLogUtil.info('securityType lock and level 1');
                }

                if (result[j].ssid === '' || result[j] === null) {
                    mLogUtil.info('result ssid empty');
                } else {
                    mWifiList.push({
                        settingIcon: '',
                        settingSummary: '',
                        settingTitle: result[j].ssid,
                        settingValue: '',
                        settingArrow: image,
                        settingDefaultValue: '',
                        settingArrowStyle: 'commonHeadImage',
                        dividerIsShow: true,
                        settingType: 1,
                        bssid: result[j].bssid,
                        securityType: result[j].securityType,
                        signalLevel: WifiNativeJs.getSignalLevel(result[j].rssi, result[j].band),
                    });
                }
            }
            mLogUtil.info('original mWifiList :' + JSON.stringify(mWifiList));
            for (let i = 0; i < mWifiList.length; i++) {
                let position = this.getItemPosition(remdupWifiList, mWifiList[i].settingTitle);
                if (position !== -1) {
                    // the same SSID，Take the strong signal
                    if (remdupWifiList[position].signalLevel < mWifiList[i].signalLevel) {
                        remdupWifiList.splice(position, 1);
                        remdupWifiList.splice(position, 0, mWifiList[i]);
                    }
                } else {
                    remdupWifiList.push(mWifiList[i]);
                }
            }
            mLogUtil.info('remove duplicate ssid remdupWifiList: ' + JSON.stringify(remdupWifiList));
        });
        mLogUtil.info('get to wifi information end ---->');
        return remdupWifiList;
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
        mLogUtil.info('[wifi_js_test] connect to wifi');
        return WifiNativeJs.connectToDevice(obj);
    }

    disConnect() {
        mLogUtil.info('netWork disconnect');
        return WifiNativeJs.disConnect();
    }
}