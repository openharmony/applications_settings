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
import AboutDeviceModel from '../../model/aboutDeviceImpl/AboutDeviceModel.js';
import BaseParseConfModel from '../../model/baseParseConfImpl/BaseParseConfModel.js';
import LogUtil from '../../common/baseUtil/LogUtil.js';

let mAboutDeviceModel = null;
let mBaseParseConfModel = null;
let mLogUtil = null;
export default {
    data: {
        aboutDeviceList: [],
        text: ''
    },
    onInit() {
        mLogUtil = new LogUtil();
        mLogUtil.info('aboutDevice onInit  start:');
        mAboutDeviceModel = new AboutDeviceModel();
        mBaseParseConfModel = new BaseParseConfModel();
        this.aboutDeviceList = mBaseParseConfModel.getJsonData('/data/accounts/account_0/applications/'
        + 'com.ohos.settings/com.ohos.settings/assets/entry/resources/rawfile/aboutDevice.json');
        mLogUtil.info('settings aboutDevice get aboutDeviceList by json:' + JSON.stringify(this.aboutDeviceList));
        for (let key in this.aboutDeviceList) {
            let settingAlias = this.aboutDeviceList[key].settingAlias;
            this.aboutDeviceList[key].settingTitle = this.$t('strings.'.concat(settingAlias));
        }
        mAboutDeviceModel.setOnAboutDeviceListener(this.aboutDevice);
        mLogUtil.info('aboutDevice onInit end:');
    },
    aboutDevice(data) {
        mLogUtil.info('aboutDeviceList start:' + JSON.stringify(data));
        for (let key in this.aboutDeviceList) {
            let value = this.aboutDeviceList[key];
            if ('model' === value.settingAlias) {
                value.settingValue = data.productModel;
            }
            if ('companyInfo' === value.settingAlias) {
                value.settingValue = data.manufacture;
            }
            if ('deviceId' === value.settingAlias) {
                value.settingValue = data.serial;
            }
            if ('softwareVersion' === value.settingAlias) {
                value.settingValue = data.displayVersion;
            }
        }
    },
    aboutDeviceBack() {
        mLogUtil.info('settings aboutDevice back start');
        Router.back();
        mLogUtil.info('settings aboutDevice back end');
    },
    onBackPress() {
        mLogUtil.info('settings aboutDevice onBackPress');
        Router.back();
    },
    onCreate() {
        mLogUtil.info('setting aboutDevice onCreate');
    },
    onReady() {
        mLogUtil.info('setting aboutDevice onReady');
    },
    onShow() {
        mLogUtil.info('setting aboutDevice onShow');
    },
    onHide() {
        mLogUtil.info('setting aboutDevice onHide');
    },
    onDestroy() {
        mLogUtil.info('setting aboutDevice onDestroy');
    }
};
