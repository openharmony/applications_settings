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
import SettingListModel from '../../model/settingListImpl/SettingListModel.js';
import LogUtil from '../../common/baseUtil/LogUtil.js';
import WifiModel from '../../model/wifiImpl/WifiModel.js';

let mSettingListModel = null;
let mWifiModel = null;
let mLogUtil = null;

const DATA_PAGE_SOURCE_HOME_PAGE = 'homePage';

export default {
    data: {
        settingsList: [],
        switchChangeValue: false,
        switchDefaultChangeValue: false
    },

    onInit() {
        mLogUtil = new LogUtil();
        mLogUtil.info('settings settingList onInit start:');
        mSettingListModel = new SettingListModel();
        mWifiModel = new WifiModel();
        mSettingListModel.setSettingListener(this.settingsListData);
        mLogUtil.info('settings settingList onInit end:');
    },

    settingsListData(data) {
        mLogUtil.info('settingList settingsListData data:' + JSON.stringify(data));
        this.settingsList = data;
    },

    onShow() {
        mLogUtil.info('settingList onShow start');
        for (let key in this.settingsList) {
            let settingAlias = this.settingsList[key].settingAlias;
            if (settingAlias === 'wifiTab') {
                if (mWifiModel.getWifiStatus()) {
                    this.settingsList[key].settingValue = this.$t('strings.enabled');
                } else {
                    this.settingsList[key].settingValue = this.$t('strings.disabled');
                }
            }
            this.settingsList[key].settingTitle = this.$t('strings.'.concat(settingAlias));
        }
        mLogUtil.info('settingList onShow end');
    },

    onClick() {
        mLogUtil.info('settings settingList onClick start');
        Router.push({
            uri: 'pages/searchInfo/searchInfo',
            params: {
                data: this.settingsList,
                type: DATA_PAGE_SOURCE_HOME_PAGE
            }
        });
        mLogUtil.info('settings settingList onClick end');
    },
};