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
import wifi_native_js from '@ohos.wifi_native_js';
import Subscriber from '@ohos.commonevent';

let logUtil = new LogUtil();
let mWifiList = [];
let remdupWifiList = [];
var wifiCode = null;
let mCommonEventSubscriber = null;
let mCommonEventSubscribeInfo = {
    events: ["usual.event.wifi.CONN_STATE"]
};
export default class WifiModel extends BaseModel {
    getWifiStatus() {
        logUtil.info('wifi_native_js isWifiActive');
        return wifi_native_js.isWifiActive();
    };

    getEnableWifi() {
        logUtil.info('wifi_native_js enableWifi');
        return wifi_native_js.enableWifi();
    };
    disableWifi() {
        logUtil.info('wifi_native_js enableWifi');
        return wifi_native_js.disableWifi();
    };
    getScanWifi() {
        logUtil.info('wifi_native_js scan');
        return wifi_native_js.scan();
    };
    getScanInfoCallBack() {
        logUtil.info('get to wifi information start---->');
        mWifiList = [];
        remdupWifiList = [];
        wifi_native_js.getScanInfos(result => {
            logUtil.info('[wifi_js_test] wifi received scan info call back results:' + JSON.stringify(result));
            let clen = Object.keys(result).length;
            let image;
            logUtil.info('[wifi_js_test] wifi received scan info call back length:' + clen);
            for (let j = 0; j < clen; j++) {
                logUtil.info('result[0].ssid: ' + result[j].ssid);
                logUtil.info('securityType: ' + result[j].securityType);
                logUtil.info('rssi: ' + result[j].rssi);
                logUtil.info('bssid: ' + result[j].bssid);
                logUtil.info('band: ' + result[j].band);
                logUtil.info('frequency: ' + result[j].frequency);
                logUtil.info('timestamp: ' + result[j].timestamp);
                logUtil.info('wifi_native_js.getSignalLevel: ' + wifi_native_js.getSignalLevel(result[j].rssi, result[j].band));

                if (result[j].securityType == 1 && wifi_native_js.getSignalLevel(result[j].rssi, result[j].band) == 4) {
                    image = '/res/image/ic_wifi_signal_4_dark.png';
                    logUtil.info('securityType 1 and signal level 4');
                };
                if (result[j].securityType == 1 && wifi_native_js.getSignalLevel(result[j].rssi, result[j].band) == 3) {
                    image = '/res/image/ic_wifi_signal_3_dark.png';
                    logUtil.info('securityType 1 and signal level 3');
                };
                if (result[j].securityType == 1 && wifi_native_js.getSignalLevel(result[j].rssi, result[j].band) == 2) {
                    image = '/res/image/ic_wifi_signal_2_dark.png';
                    logUtil.info('securityType 1 and signal level 2');
                };
                if (result[j].securityType == 1 && wifi_native_js.getSignalLevel(result[j].rssi, result[j].band) == 1) {
                    image = '/res/image/ic_wifi_signal_1_dark.png';
                    logUtil.info('securityType 1 and signal level 1');
                };
                if (result[j].securityType == 1 && wifi_native_js.getSignalLevel(result[j].rssi, result[j].band) == 0) {
                    image = '/res/image/ic_wifi_signal_1_dark.png';
                    logUtil.info('securityType 1 and signal level 1');
                };
                if (result[j].securityType != 1 && wifi_native_js.getSignalLevel(result[j].rssi, result[j].band) == 4) {
                    image = '/res/image/ic_wifi_lock_signal_4_dark.png';
                    logUtil.info('securityType lock and level 4');
                };
                if (result[j].securityType != 1 && wifi_native_js.getSignalLevel(result[j].rssi, result[j].band) == 3) {
                    image = '/res/image/ic_wifi_lock_signal_3_dark.png';
                    logUtil.info('securityType lock and level 3');
                };
                if (result[j].securityType != 1 && wifi_native_js.getSignalLevel(result[j].rssi, result[j].band) == 2) {
                    image = '/res/image/ic_wifi_lock_signal_2_dark.png';
                    logUtil.info('securityType lock and level 2');
                };
                if (result[j].securityType != 1 && wifi_native_js.getSignalLevel(result[j].rssi, result[j].band) == 1) {
                    image = '/res/image/ic_wifi_lock_signal_1_dark.png';
                    logUtil.info('securityType lock and level 1');
                };
                if (result[j].securityType != 1 && wifi_native_js.getSignalLevel(result[j].rssi, result[j].band) == 0) {
                    image = '/res/image/ic_wifi_lock_signal_1_dark.png';
                    logUtil.info('securityType lock and level 1');
                };

                if (result[j].ssid == '' || result[j] == null) {
                    logUtil.info('result ssid empty');
                } else {
                    mWifiList.push({
                        settingIcon: '',
                        settingSummary: '',
                        settingTitle: result[j].ssid,
                        settingValue: '',
                        settingArrow: image,
                        settingDefaultValue: '',
                        dividerIsShow: true,
                        settingType: 1,
                        bssid: result[j].bssid,
                        securityType: result[j].securityType,
                        signalLevel: wifi_native_js.getSignalLevel(result[j].rssi, result[j].band),
                    });
                }
            };
            logUtil.info("original mWifiList :" + JSON.stringify(mWifiList));
            for (let i = 0; i < mWifiList.length; i++) {
                let position = this.getItemPosition(remdupWifiList, mWifiList[i].settingTitle);
                if (position != -1) {
                    // the same SSID，Take the strong signal
                    if (remdupWifiList[position].signalLevel < mWifiList[i].signalLevel) {
                        remdupWifiList.splice(position, 1);
                        remdupWifiList.splice(position, 0, mWifiList[i]);
                    }
                } else {
                    remdupWifiList.push(mWifiList[i])
                }
            };
            logUtil.info('remove duplicate ssid remdupWifiList: ' + JSON.stringify(remdupWifiList));
        });
        logUtil.info('get to wifi information end---->');
        return remdupWifiList;
    };

    /**
     * Get the next value corresponding to SSID
     */
    getItemPosition(list, ssid) {
        for (let i = 0; i < list.length; i++) {
            if (ssid == list[i].settingTitle) {
                return i;
            }
        }
        return -1;
    };

    connectToDevice(obj) {
        logUtil.info('[wifi_js_test] connect to wifi');
        return wifi_native_js.connectToDevice(obj);
    };
    /**
     * wifi monitoring events
     */
    wifiStatusListener() {
        logUtil.info('wifi status listener')
        Subscriber.createSubscriber(mCommonEventSubscribeInfo,
            this.CreateSubscriberCallBack.bind(this));
    };

    CreateSubscriberCallBack(err, data) {
        logUtil.info('subscriber subscribe');
        mCommonEventSubscriber = data;
        Subscriber.subscribe(mCommonEventSubscriber, this.SubscriberCallBack.bind(this));
    };

    SubscriberCallBack(err, data) {
        logUtil.info('subscriber call back')
        logUtil.info('==========================>SubscriberCallBack  event = ' + data.event);
        logUtil.info('==========================>SubscriberCallBack  data = ' + JSON.stringify(data));
        logUtil.info('==========================>SubscriberCallBack  data code = ' + data.code);
        wifiCode = data.code;
        logUtil.info('wifi data code value' + wifiCode);
    };
    /**
     * get wifi code value
     */
    getWifiCode() {
        logUtil.info('wifi code value' + wifiCode);
        return wifiCode;
    };

    unSubscriberListener() {
        Subscriber.unsubscribe(mCommonEventSubscriber, () => {
            logUtil.info('wifi unsubscribe');
        });
    };

    disConnect() {
        logUtil.info('netWork disconnect');
        return wifi_native_js.disConnect();
    };
}