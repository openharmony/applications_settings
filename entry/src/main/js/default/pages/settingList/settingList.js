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
import SettingListModel from '../../model/settingListImpl/SettingListModel.js';
import LogUtil from '../../common/baseUtil/LogUtil.js';

const DATA_PAGE_SOURCE_HOME_PAGE = 'homePage';
let mSettingListModel = new SettingListModel();
let logUtil = new LogUtil();

export default {
    data: {
        settingsList: [],
        switchChangeValue: false,
        switchDefaultChangeValue: false
    },
    onInit() {
        logUtil.info('settings settingList onInit start:');
        mSettingListModel.setSettingListener(this.settingsListData);
        for (let key in this.settingsList) {
            var settingAlias = this.settingsList[key].settingAlias
            if (settingAlias == 'wifiTab') {
                this.settingsList[key].settingValue = this.$t('strings.enabled')
            }
            this.settingsList[key].settingTitle = this.$t('strings.'.concat(settingAlias))
        }
        logUtil.info('settings settingList onInit end:');
    },
    settingsListData(data) {
        logUtil.info('settingList settingsListData data:' + JSON.stringify(data));
        this.settingsList = data
    },

    /**
     * Click the search box to jump to the search page
     */
    onClick() {
        logUtil.info('settings settingList onClick start:');
        router.push({
            uri: 'pages/searchInfo/searchInfo',
            params: {
                data: this.settingsList,
                type: DATA_PAGE_SOURCE_HOME_PAGE
            }
        });
        logUtil.info('settings settingList onClick end:');
    },
}