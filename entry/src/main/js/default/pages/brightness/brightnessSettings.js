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
import BrightnessSettingModel from '../../model/brightnessImpl/BrightnessSettingModel.js';
import LogUtil from '../../common/baseUtil/LogUtil.js';

let mBrightnessSettingModel = null;
let mLogUtil = null;

export default {
    data: {
        bright: null,
        settingSwitchValue: false,
        switchModeValue: 0,
        before: '/res/image/ic_settings_brightness_minimum.svg',
        after: '/res/image/ic_settings_brightness_maximum.svg',
        brightnessSettingOb: {},
        brightnessSettingList: []
    },
    onInit() {
        mLogUtil = new LogUtil();
        mLogUtil.info('setting brightnessSettings onInit start');
        mBrightnessSettingModel = new BrightnessSettingModel();
        this.bright = mBrightnessSettingModel.getStorageValue();
        mLogUtil.info('setting brightnessSettings onInit this.bright:' + this.bright);
        mLogUtil.info('setting brightnessSettings onInit end');
    },

    getMode(data) {
        mLogUtil.info('setting brightnessSettings getMode start：' + JSON.stringify(data));
        for (let key in this.brightnessSettingList) {
            let value = this.brightnessSettingList[key];
            /**
             * The value adjustment of the screen brightness mode is 0 or 1
             *  0: manual  1:automatic
             */
            value.settingSwitchValue = data[value.settingAlias] == 0 ? false : true;
            value.switchModeValue = data[value.settingAlias];
        }
        mLogUtil.info('setting brightnessSettings getMode end:' + JSON.stringify(this.brightnessSettingList));
    },

    getBrightnessValue(brightValue) {
        mLogUtil.info('setting brightnessSettings getBrightnessValue start brightValue:' + brightValue);
        this.bright = brightValue;
        mLogUtil.info('setting brightnessSettings getBrightnessValue end');
    },

    getValue: function (name, data) {
        mLogUtil.info('setting brightnessSettings getValue start');
        this.bright = data.value;
        mBrightnessSettingModel.setBrightnessListener(this.bright);
        mBrightnessSettingModel.setStorageValue(this.bright);
        mLogUtil.info('setting brightnessSettings getValue end this.bright：' + this.bright);
    },

    /**
     * Brightness mode setting
     */
    switchTouch() {
        mLogUtil.info('setting brightnessSettings switchTouch start');
        for (let key in this.brightnessSettingList) {
            mLogUtil.info('setting brightnessSettings switchTouch this.settingSwitchValue：'
                + this.brightnessSettingList[key].settingSwitchValue);
            if (this.brightnessSettingList[key].settingSwitchValue === false) {
                this.brightnessSettingList[key].settingSwitchValue = true;
                this.brightnessSettingList[key].switchModeValue = 1;
                this.clickSetMode(this.brightnessSettingList[key].switchModeValue);
                mLogUtil.info('setting brightnessSettings switchTouch settingSwitchValue true：'
                    + this.brightnessSettingList[key].settingSwitchValue + ' | switchModeValue | '
                    + this.brightnessSettingList[key].switchModeValue);
            } else {
                this.brightnessSettingList[key].settingSwitchValue = false;
                this.brightnessSettingList[key].switchModeValue = 0;
                this.clickSetMode(this.brightnessSettingList[key].switchModeValue);
                mLogUtil.info('setting brightnessSettings switchTouch settingSwitchValue false：'
                    + this.brightnessSettingList[key].settingSwitchValue + ' | switchModeValue | '
                    + this.brightnessSettingList[key].switchModeValue);
            }
        }
        mLogUtil.info('setting brightnessSettings onBackPress end');
    },

    clickSetMode(modeValue) {
        mLogUtil.info('setting brightnessSettings switchTouch start clickSetMode');
    },
    back() {
        mLogUtil.info('setting brightnessSettings back start');
        Router.back();
        mLogUtil.info('setting brightnessSettings back end');
    },
    onBackPress() {
        mLogUtil.info('setting brightnessSettings onBackPress start');
        Router.back();
        mLogUtil.info('setting brightnessSettings onBackPress end');
    },
    onCreate() {
        mLogUtil.info('setting brightnessSettings onCreate');
    },
    onReady() {
        mLogUtil.info('setting brightnessSettings onReady');
    },
    onShow() {
        mLogUtil.info('setting brightnessSettings onShow');
    },
    onHide() {
        mLogUtil.info('setting brightnessSettings onHide');
    },
    onDestroy() {
        mLogUtil.info('setting brightnessSettings onDestroy');
    }
};