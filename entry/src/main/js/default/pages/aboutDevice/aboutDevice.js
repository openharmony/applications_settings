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
import AboutDeviceModel from '../../model/aboutDeviceImpl/AboutDeviceModel.js';
import BaseParseConfModel from '../../model/baseParseConfImpl/BaseParseConfModel.js';
import LogUtil from '../../common/baseUtil/LogUtil.js';

let mAboutDeviceModel = new AboutDeviceModel();
let baseParseConfModel = new BaseParseConfModel();
let logUtil = new LogUtil();

export default {
    data: {
        aboutDeviceList: [],
        text: ''
    },
    onInit() {
        logUtil.info('aboutDevice onInit  start:')
        this.aboutDeviceList = baseParseConfModel.getJsonData('/data/accounts/account_0/applications/com.ohos.settings/com.ohos.settings/assets/entry/resources/rawfile/aboutDevice.json');
        logUtil.info('settings aboutDevice get aboutDeviceList by json:' + JSON.stringify(this.aboutDeviceList))
        for (let key in this.aboutDeviceList) {
            var settingAlias = this.aboutDeviceList[key].settingAlias
            this.aboutDeviceList[key].settingTitle = this.$t('strings.'.concat(settingAlias))
        }
        mAboutDeviceModel.setOnAboutDeviceListener(this.aboutDevice);
        logUtil.info('aboutDevice onInit end:')
    },
    aboutDevice(data) {
        logUtil.info('aboutDeviceList start:' + JSON.stringify(data))
        for (let key in this.aboutDeviceList) {
            let value = this.aboutDeviceList[key]
            if ('model' == value.settingAlias) {
                value.settingValue = data.productModel;
            }
            if ('companyInfo' == value.settingAlias) {
                value.settingValue = data.manufacture;
            }
            if ('deviceId' == value.settingAlias) {
                value.settingValue = data.serial;
            }
            if ('softwareVersion' == value.settingAlias) {
                value.settingValue = data.displayVersion;
            }
        }
    },
    aboutDeviceBack() {
        logUtil.info('settings aboutDevice back start:')
        router.back();
        logUtil.info('settings aboutDevice back end:')
    },
    onBackPress() {
        logUtil.info('settings aboutDevice onBackPress:')
        router.back();
    },
    onCreate() {
        logUtil.info('setting aboutDevice onCreate')
    },
    onReady() {
        logUtil.info('setting aboutDevice onReady')
    },
    onShow() {
        logUtil.info('setting aboutDevice onShow')
    },
    onHide() {
        logUtil.info('setting aboutDevice onHide')
    },
    onDestroy() {
        logUtil.info('setting aboutDevice onDestroy')
    }
}
