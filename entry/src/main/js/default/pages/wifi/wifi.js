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
import router from '@system.router';
import BaseParseConfModel from '../../model/baseParseConfImpl/BaseParseConfModel.js';
import LogUtil from '../../common/baseUtil/LogUtil.js';
import WifiModel from '../../model/wifiImpl/WifiModel.js';

let baseParseConfModel = new BaseParseConfModel();
let logUtil = new LogUtil();
let wifiModel = new WifiModel();

globalThis.$globalT = null;

export default {
    data: {
        switch_on: false,
        animator_on: false,
        wifiListInfoData: 'wifiListInfo',
        wifiListData: 'wifiList',
        wifiList: [],
        wifiListInfo: [],
        timeoutFlag: '',
        timeoutMark: '',
        listenerMark: '',
        frames: [
            {
                src: "/res/image/ic_loading01.png",
            },
            {
                src: "/res/image/ic_loading02.png",
            },
            {
                src: "/res/image/ic_loading03.png",
            },
            {
                src: "/res/image/ic_loading04.png",
            },
            {
                src: "/res/image/ic_loading05.png",
            },
            {
                src: "/res/image/ic_loading06.png",
            }
        ],
    },
    handleStart() {
        this.$refs.animator.start();
    },
    handlePause() {
        this.$refs.animator.pause();
    },
    handleResume() {
        this.$refs.animator.resume();
    },
    handleStop() {
        this.$refs.animator.stop();
    },

    onInit() {
        logUtil.info('wifiListInfo onInit start--->');
        wifiModel.wifiStatusListener();
        globalThis.$globalT = this.$t.bind(this);
        this.wifiListInfo = baseParseConfModel.getJsonData('/data/accounts/account_0/applications/com.ohos.settings/com.ohos.settings/assets/entry/resources/rawfile/wifi.json');
        for (let key in this.wifiListInfo) {
            let settingAlias = this.wifiListInfo[key].settingAlias;
            this.wifiListInfo[key].settingTitle = this.$t('strings.'.concat(settingAlias));
            logUtil.info("init wifiListInfo[key].switchOnChangeValue enter");
            if (wifiModel.getWifiStatus()) {
                this.wifiListInfo[key].switchOnChangeValue = true;
                this.wifiListInfo[key].settingDefaultValue = true;
                this.switch_on = true;
                this.animator_on = true;
                logUtil.info('init enableWifi enter ---->');
                let that = this;
                this.timeoutMark = setTimeout(function () {
                    logUtil.info('delay 3s');
                    if (wifiModel.getScanWifi()) {
                        logUtil.info('init enter scan ---->');
                        this.timeoutFlag = setTimeout(function () {
                            logUtil.info('delay 3s');
                            that.wifiList = wifiModel.getScanInfoCallBack();
                            that.animator_on = false;
                            clearTimeout(that.timeoutFlag);
                            clearTimeout(this.timeoutMark);
                        }, 3000);
                    }
                    else {
                        logUtil.info("init wifi scan failed: ");
                    };
                }, 3000);
            } else {
                this.wifiListInfo[key].switchOnChangeValue = false;
                this.wifiListInfo[key].settingDefaultValue = false;
                logUtil.info("init get wifi status" + wifiModel.getWifiStatus());
                this.switch_on = false;
            };
        };
        logUtil.info('wifiListInfo onInit end--->');
    },
    /**
     * back
     */
    back() {
        router.back();
    },
    /**
     * wifi switch button
     */
    switchClick() {
        logUtil.info('switchClick start ---->');
        for (let key in this.wifiListInfo) {
            logUtil.info('wifiListInfo switchOnChangeValue this.switchOnChangeValue：' + this.wifiListInfo[key].switchOnChangeValue);
            if (this.wifiListInfo[key].switchOnChangeValue === false) {
                logUtil.info('switchClick Wifi enter ');
                this.switch_on = true;
                this.animator_on = true;
                this.wifiListInfo[key].switchOnChangeValue = true;
                this.wifiListInfo[key].settingDefaultValue = true;
                if (wifiModel.getEnableWifi()) {
                    logUtil.info('switchClick enableWifi enter ---->');
                    let that = this;
                    this.timeoutMark = setTimeout(function () {
                        logUtil.info('delay 3s');
                        try {
                            if (wifiModel.getScanWifi()) {
                                logUtil.info('switchClick enter scan ---->');
                                this.timeoutFlag = setTimeout(function () {
                                    logUtil.info('delay 3s');
                                    that.wifiList = wifiModel.getScanInfoCallBack();
                                    that.animator_on = false;
                                    clearTimeout(that.timeoutFlag);
                                    clearTimeout(this.timeoutMark);
                                }, 3000);
                            } else {
                                logUtil.info('switchClick fail to scan ---->');
                            }
                        } catch {
                            logUtil.info('switchClick wifi_native_js.scan() error ---->');
                        }
                    }, 3000);
                    logUtil.info('switchClick enableWifi sleep end ---->');
                } else {
                    logUtil.info('switchClick fail to enableWifi ---->');
                }
            } else {
                this.switch_on = false;
                if (wifiModel.disableWifi()) {
                    logUtil.info('switchClick enter to disableWifi ---->');
                    this.clearScanInfo();
                    logUtil.info('switchClick  this.wifiList---->' + this.wifiList);
                } else {
                    logUtil.info('switchClick fail to disableWifi ---->');
                }
                this.wifiListInfo[key].switchOnChangeValue = false;
                this.wifiListInfo[key].settingDefaultValue = false;
            };
        };
        logUtil.info('switchClick end ---->');
    },
    /**
     * clear scan wifi list
     */
    clearScanInfo() {
        logUtil.info('clear scan wifiList start---->');
        this.wifiList = [];
        logUtil.info('clear scan wifiList end---->');
    },
    /**
     * Select WiFi to enter the details page
     * @param idx
     * @return
     */
    clickToSecret(idx) {
        logUtil.info('wifi clickToSecret start index:' + idx + ' settingTitle:' + this.wifiList[idx].settingTitle);
        let title = this.wifiList[idx].settingTitle;
        let image = this.wifiList[idx].settingArrow;
        let bssid = this.wifiList[idx].bssid;
        let securityType = this.wifiList[idx].securityType;
        logUtil.info("click to get title ：" + title + ' bssid' + bssid + ' securityType' + securityType);
        if (globalThis.$globalT) {
            this.connected = globalThis.$globalT('strings.connected');
            logUtil.info('wifi constructor this.connected:' + this.connected);
        };
        if (this.wifiList[0].settingSummary == this.connected) {
            if (wifiModel.disConnect() == true) {
                logUtil.info("click disconnect success get wifi code" + wifiModel.getWifiCode());
            } else {
                logUtil.info("disconnect failed : " + wifiModel.disConnect())
            }
        };
        let obj = {
            "ssid": title,
            "bssid": bssid,
            "preSharedKey": '',
            "isHiddenSsid": false,
            "securityType": securityType,
        };
        if (!wifiModel.connectToDevice(obj)) {
            logUtil.info("[wifi_js_test] connect to wifi failed");
            return;
        };
        logUtil.info('before wifi connectToDevice status code---->' + wifiModel.getWifiCode());
        if (wifiModel.connectToDevice(obj)) {
            logUtil.info("[wifi_js_test] connect to wifi " + JSON.stringify(obj));
            let that = this
            this.listenerMark = setTimeout(function () {
                if (wifiModel.getWifiCode() == 3) {
                    that.wifiList.unshift({
                        settingIcon: '',
                        settingSummary: that.connected,
                        settingTitle: title,
                        settingValue: '',
                        settingArrow: image,
                        settingDefaultValue: '',
                        dividerIsShow: true,
                        settingType: 1,
                        bssid: bssid,
                        securityType: securityType,
                    });
                    for (let key in that.wifiList) {
                        if (key == (idx + 1)) {
                            that.wifiList.splice(key,1)
                        };
                        if (key != 0) {
                            that.wifiList[key].settingSummary = '';
                        };
                    };
                };
                clearTimeout(this.listenerMark);
            }, 1000);
        };
        logUtil.info('clickToSecret end:');
    },
     onCreate() {
        logUtil.info('setting wifi onCreate')
    },
    onReady() {
        logUtil.info('setting wifi onReady')
    },
    onShow() {
        logUtil.info('setting wifi onShow')
    },
    onHide() {
        logUtil.info('setting wifi onHide')
    },
    onDestroy() {
        logUtil.info("setting wifi onDestroy start");
        wifiModel.unSubscriberListener();
        logUtil.info('setting wifi onDestroy end')
    },
}
