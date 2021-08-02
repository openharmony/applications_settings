// @ts-nocheck
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
import Router from '@system.router';
import BaseParseConfModel from '../../model/baseParseConfImpl/BaseParseConfModel.js';
import LogUtil from '../../common/baseUtil/LogUtil.js';
import WifiModel from '../../model/wifiImpl/WifiModel.js';
import Subscriber from '@ohos.commonevent';

let mBaseParseConfModel = null;
let mLogUtil = null;
let mWifiModel = null;
let mBeginTime;
let mEndTime;
let mIndex;
let mConnectImage;
let mConnectName;
let mConnectBssid;
let mConnectSecurityType;
let mCommonEventSubscriber = null;
let mCommonEventSubscribeInfo = {
    events: ["usual.event.wifi.CONN_STATE"]
};

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
        frames: null,

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
        mLogUtil = new LogUtil();
        mLogUtil.info('wifiListInfo onInit start--->');
        mBeginTime = new Date();
        this.initFrames();
        this.wifiStatusListener();
        globalThis.$globalT = this.$t.bind(this);
        mBaseParseConfModel = new BaseParseConfModel();
        mWifiModel = new WifiModel();
        this.wifiListInfo = mBaseParseConfModel.getJsonData('/data/accounts/account_0/applications'
            + '/com.ohos.settings/com.ohos.settings/assets/entry/resources/rawfile/wifi.json');
        for (let key in this.wifiListInfo) {
            let settingAlias = this.wifiListInfo[key].settingAlias;
            this.wifiListInfo[key].settingTitle = this.$t('strings.'.concat(settingAlias));
            mLogUtil.info("init wifiListInfo[key].switchOnChangeValue enter");
            if (mWifiModel.getWifiStatus()) {
                this.wifiListInfo[key].switchOnChangeValue = true;
                this.wifiListInfo[key].settingDefaultValue = true;
                this.switch_on = true;
                this.animator_on = true;
                mLogUtil.info('init enableWifi enter ---->');
                let that = this;
                this.timeoutMark = setTimeout(function () {
                    mLogUtil.info('delay 3s');
                    if (mWifiModel.getScanWifi()) {
                        mLogUtil.info('init enter scan ---->');
                        this.timeoutFlag = setTimeout(function () {
                            mLogUtil.info('delay 3s');
                            that.wifiList = mWifiModel.getScanInfoCallBack();
                            that.animator_on = false;
                            clearTimeout(that.timeoutFlag);
                            clearTimeout(this.timeoutMark);
                        }, 3000);
                    }
                    else {
                        mLogUtil.info("init wifi scan failed: ");
                    }
                }, 3000);
            } else {
                this.wifiListInfo[key].switchOnChangeValue = false;
                this.wifiListInfo[key].settingDefaultValue = false;
                mLogUtil.info("init get wifi status" + mWifiModel.getWifiStatus());
                this.switch_on = false;
            }
        }
        mEndTime = new Date();
        mLogUtil.info("setting wifi onInit:"+(mEndTime-mBeginTime)+"ms");
        mLogUtil.info('wifiListInfo onInit end--->');
    },

    back() {
        Router.back();
    },

    switchClick() {
        mLogUtil.info('switchClick start ---->');
        for (let key in this.wifiListInfo) {
            mLogUtil.info('wifiListInfo switchOnChangeValue this.switchOnChangeValue：'
                + this.wifiListInfo[key].switchOnChangeValue);
            if (this.wifiListInfo[key].switchOnChangeValue === false) {
                mLogUtil.info('switchClick Wifi enter ');
                this.switch_on = true;
                this.animator_on = true;
                this.wifiListInfo[key].switchOnChangeValue = true;
                this.wifiListInfo[key].settingDefaultValue = true;
                if (mWifiModel.getEnableWifi()) {
                    mLogUtil.info('switchClick enableWifi enter ---->');
                    let that = this;
                    this.timeoutMark = setTimeout(function () {
                        mLogUtil.info('delay 3s');
                        try {
                            if (mWifiModel.getScanWifi()) {
                                mLogUtil.info('switchClick enter scan ---->');
                                this.timeoutFlag = setTimeout(function () {
                                    mLogUtil.info('delay 3s');
                                    that.wifiList = mWifiModel.getScanInfoCallBack();
                                    that.animator_on = false;
                                    clearTimeout(that.timeoutFlag);
                                    clearTimeout(this.timeoutMark);
                                }, 3000);
                            } else {
                                mLogUtil.info('switchClick fail to scan ---->');
                            }
                        } catch {
                            mLogUtil.info('switchClick wifi_native_js.scan() error ---->');
                        }
                    }, 3000);
                    mLogUtil.info('switchClick enableWifi sleep end ---->');
                } else {
                    mLogUtil.info('switchClick fail to enableWifi ---->');
                }
            } else {
                this.switch_on = false;
                if (mWifiModel.disableWifi()) {
                    mLogUtil.info('switchClick enter to disableWifi ---->');
                    this.clearScanInfo();
                    mLogUtil.info('switchClick  this.wifiList---->' + this.wifiList);
                } else {
                    mLogUtil.info('switchClick fail to disableWifi ---->');
                }
                this.wifiListInfo[key].switchOnChangeValue = false;
                this.wifiListInfo[key].settingDefaultValue = false;
            }
        }
        mLogUtil.info('switchClick end ---->');
    },

    clearScanInfo() {
        mLogUtil.info('clear scan wifiList start---->');
        this.wifiList = [];
        mLogUtil.info('clear scan wifiList end---->');
    },

    clickToSecret(idx) {
        this.sleep(2000);
        mLogUtil.info('wifi clickToSecret start index:' + idx + ' settingTitle:' + this.wifiList[idx].settingTitle);
        let title = this.wifiList[idx].settingTitle;
        let image = this.wifiList[idx].settingArrow;
        let bssid = this.wifiList[idx].bssid;
        let securityType = this.wifiList[idx].securityType;
        mLogUtil.info("click to get title ：" + title + ' bssid' + bssid + ' securityType' + securityType);
        if (globalThis.$globalT) {
            this.connected = globalThis.$globalT('strings.connected');
            mLogUtil.info('wifi constructor this.connected:' + this.connected);
        }
        if (this.wifiList[idx].settingSummary == this.connected) {
            return;
        }
        if (securityType !== 1) {
            return;
        }

        let obj = {
            "ssid": title,
            "bssid": bssid,
            "preSharedKey": '',
            "isHiddenSsid": false,
            "securityType": securityType,
        }
        if (!mWifiModel.connectToDevice(obj)) {
            mLogUtil.info("[wifi_js_test] connect to wifi failed");
            return;
        }

        this.sleep(2000);

        if (mWifiModel.connectToDevice(obj)) {
            this.wifiList[0].settingSummary = '';
            mLogUtil.info("[wifi_js_test] connect to wifi " + JSON.stringify(obj));
            mConnectBssid = bssid;
            mConnectImage = image;
            mConnectName = title;
            mIndex = idx;
            mConnectSecurityType = securityType
        }
        mLogUtil.info('clickToSecret end:');
    },

    wifiStatusListener() {
        mLogUtil.info('wifi status listener')
        Subscriber.createSubscriber(mCommonEventSubscribeInfo,
            this.CreateSubscriberCallBack.bind(this));
    },

    CreateSubscriberCallBack(err, data) {
        mLogUtil.info('subscriber subscribe');
        mCommonEventSubscriber = data;
        Subscriber.subscribe(mCommonEventSubscriber, this.SubscriberCallBack.bind(this));
    },

    SubscriberCallBack(err, data) {
        mLogUtil.info('subscriber call back')
        mLogUtil.info('==========================>SubscriberCallBack  event = ' + data.event);
        mLogUtil.info('==========================>SubscriberCallBack  data = ' + JSON.stringify(data));
        mLogUtil.info('==========================>SubscriberCallBack  data code = ' + data.code);
        if (globalThis.$globalT) {
            this.connected = globalThis.$globalT('strings.connected');
            mLogUtil.info('wifi constructor this.connected:' + this.connected);
        }
        if (data.code === 3) {
            mLogUtil.info('wifi code into');
            this.wifiList.unshift({
                settingIcon: '',
                settingSummary: this.connected,
                settingTitle: mConnectName,
                settingValue: '',
                settingArrow: mConnectImage,
                settingArrowStyle: 'commonHeadImage',
                settingDefaultValue: '',
                dividerIsShow: true,
                settingType: 1,
                bssid: mConnectBssid,
                securityType: mConnectSecurityType,
            });
            for (let key in this.wifiList) {
                if (key == (mIndex + 1)) {
                    this.wifiList.splice(key,1)
                }
                if (key != 0) {
                    this.wifiList[key].settingSummary = '';
                }
            }
        }
    },

    unSubscriberListener() {
        Subscriber.unsubscribe(mCommonEventSubscriber, () => {
            mLogUtil.info('wifi unsubscribe');
        });
    },

    sleep(delay) {
        let  start = (new Date()).getTime();
        while ((new Date()).getTime() - start < delay) {
            continue;
        }
    },

    onCreate() {
        mLogUtil.info('setting wifi onCreate')
    },
    onReady() {
        mLogUtil.info('setting wifi onReady')
    },
    onShow() {
        mLogUtil.info('setting wifi onShow')
    },
    onHide() {
        mLogUtil.info('setting wifi onHide')
    },
    onDestroy() {
        mLogUtil.info("setting wifi onDestroy start");
        this.unSubscriberListener();
        mLogUtil.info('setting wifi onDestroy end')
    },
    initFrames() {
        mLogUtil.info('setting appManagement initFrames Start')
        this.frames = [
            {
                src: this.$r('image.icLoading01'),
            },
            {
                src: this.$r('image.icLoading02'),
            },
            {
                src: this.$r('image.icLoading03'),
            },
            {
                src: this.$r('image.icLoading04'),
            },
            {
                src: this.$r('image.icLoading05'),
            },
            {
                src: this.$r('image.icLoading06'),
            }
        ];
    },
}
