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
import BrightnessSettingModel from '../../model/brightnessImpl/BrightnessSettingModel.js';
import BaseParseConfModel from '../../model/baseParseConfImpl/BaseParseConfModel.js';
import LogUtil from '../../common/baseUtil/LogUtil.js';

let brightnessSettingModel = new BrightnessSettingModel();
let baseParseConfModel = new BaseParseConfModel();
let logUtil = new LogUtil();

export default {
    data: {
        bright: null,
        settingSwitchValue: false,
        switchModeValue: 0,
        before: '/res/image/ic_settings_brightness_minimum.png',
        after: '/res/image/ic_settings_brightness_maximum.png',
        brightnessSettingOb: {},
        brightnessSettingList: []
    },
    onInit() {
        logUtil.info('setting brightnessSettings onInit start')
        this.bright = brightnessSettingModel.getStorageValue();
        logUtil.info('setting brightnessSettings onInit start this.bright:' + this.bright)
        /**
         * Get the current screen brightness value of the device
         */
        this.brightnessSettingList = baseParseConfModel.getJsonData('/data/accounts/account_0/applications/com.ohos.settings/com.ohos.settings/assets/entry/resources/rawfile/brightness.json');
        for (let key in this.brightnessSettingList) {
            var settingAlias = this.brightnessSettingList[key].settingAlias
            this.brightnessSettingList[key].settingTitle = this.$t('strings.'.concat(settingAlias))
        }
        logUtil.info('setting brightnessSettings onInit end')
    },

    /**
     * Acquisition mode
     * @param data
     * @return
     */
    getMode(data) {
        logUtil.info('setting brightnessSettings getMode start：' + JSON.stringify(data) + JSON.stringify(this.brightnessSettingList));
        for (let key in this.brightnessSettingList) {
            let value = this.brightnessSettingList[key]
            /**
             * The value adjustment of the screen brightness mode is 0 or 1
             *  0: manual  1:automatic
             */
            value.settingSwitchValue = data[value.settingAlias] == 0 ? false : true;
            value.switchModeValue = data[value.settingAlias];
        }
        logUtil.info('setting brightnessSettings getMode end:' + JSON.stringify(this.brightnessSettingList));
    },

    /**
     * Get the current screen brightness value of the device
     * @param data
     * @return
     */
    getBrightnessValue(brightValue) {
        logUtil.info('setting brightnessSettings getBrightnessValue start brightValue:' + brightValue);
        this.bright = brightValue;
        logUtil.info('setting brightnessSettings getBrightnessValue end')
    },

    /**
     * Brightness setting
     */
    getValue: function (name, data) {
        logUtil.info('setting brightnessSettings getValue start');
        this.bright = data.value;
        brightnessSettingModel.setBrightnessListener(this.bright);
        brightnessSettingModel.setStorageValue(this.bright);
        logUtil.info('setting brightnessSettings getValue end this.bright：' + this.bright);
    },
    /**
     * Set the current screen brightness value of the device
     * @param e
     * @return
     */
    clickBrightnessSet(brightnessValue) {
        logUtil.info('setting brightnessSettings clickBrightnessSet start brightnessValue:' + brightnessValue)
        brightnessSettingModel.setBrightnessListener(brightnessValue);
        brightnessSettingModel.setStorageValue(brightnessValue);
        logUtil.info('setting brightnessSettings clickBrightnessSet end')
    },
    /**
     * Brightness mode setting
     */
    switchTouch() {
        logUtil.info('setting brightnessSettings switchTouch start')
        for (let key in this.brightnessSettingList) {
            logUtil.info('setting brightnessSettings switchTouch this.settingSwitchValue：' + this.brightnessSettingList[key].settingSwitchValue);
            if (this.brightnessSettingList[key].settingSwitchValue == false) {
                this.brightnessSettingList[key].settingSwitchValue = true;
                this.brightnessSettingList[key].switchModeValue = 1;
                this.clickSetMode(this.brightnessSettingList[key].switchModeValue)
                logUtil.info('setting brightnessSettings switchTouch settingSwitchValue true：' + this.brightnessSettingList[key].settingSwitchValue + " | switchModeValue | " + this.brightnessSettingList[key].switchModeValue);
            } else {
                this.brightnessSettingList[key].settingSwitchValue = false;
                this.brightnessSettingList[key].switchModeValue = 0;
                this.clickSetMode(this.brightnessSettingList[key].switchModeValue)
                logUtil.info('setting brightnessSettings switchTouch settingSwitchValue false：' + this.brightnessSettingList[key].settingSwitchValue + " | switchModeValue | " + this.brightnessSettingList[key].switchModeValue);
            }
        }
        logUtil.info('setting brightnessSettings onBackPress end')
    },
    /**
     * Set the current screen brightness mode of the device.
     * @param e
     * @return
     */
    clickSetMode(e) {
        logUtil.info('setting brightnessSettings switchTouch start clickSetMode：' + e);
    },
    back() {
        logUtil.info('setting brightnessSettings back start')
        router.back();
        logUtil.info('setting brightnessSettings back end')
    },
    onBackPress() {
        logUtil.info('setting brightnessSettings onBackPress start')
        router.back();
        logUtil.info('setting brightnessSettings onBackPress end')
    },
    onCreate() {
        logUtil.info('setting brightnessSettings onCreate')
    },
    onReady() {
        logUtil.info('setting brightnessSettings onReady')
    },
    onShow() {
        logUtil.info('setting brightnessSettings onShow')
    },
    onHide() {
        logUtil.info('setting brightnessSettings onHide')
    },
    onDestroy() {
        logUtil.info('setting brightnessSettings onDestroy')
    }
}