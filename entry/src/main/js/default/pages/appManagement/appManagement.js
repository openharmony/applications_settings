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
import AppManagementModel from '../../model/appManagementImpl/AppManagementModel.js';
import LogUtil from '../../common/baseUtil/LogUtil.js';
import router from '@system.router';

const DATA_PAGE_SOURCE_APP_PAGE = 'appPage';
let appManagementModel = new AppManagementModel();
let logUtil = new LogUtil();

export default {
    data: {
        appList: [],
    },
    onInit() {
        logUtil.info('setting appManagement init start:')
        appManagementModel.setAppManagementListener(this.appListData)
        logUtil.info('setting appManagement init end:')
    },
    appListData(appListData) {
        if (null == appListData) {
            logUtil.info('setting appManagement appListData is null')
            return;
        }
        logUtil.info('setting appManagement appListData start:' + JSON.stringify(appListData.length))
        for(var i=0;i<appListData.length;i++){
            var settingSummary=appListData[i].settingSummary;
            appListData[i].settingSummary=this.$t('strings.version').concat(settingSummary);
        }
        this.appList = appListData;
        logUtil.info('setting appManagement appListData end')
    },
    /**
     * Jump to search page
     */
    onClick() {
        logUtil.info('setting appManagement onClick start pages/searchInfo/searchInfo ')
        router.push({
            uri: 'pages/searchInfo/searchInfo',
            params: {
                appData: this.appList,
                type: DATA_PAGE_SOURCE_APP_PAGE
            }
        });
        logUtil.info('setting appManagement onClick end')
    },
    appInfoBack() {
        logUtil.info('setting appManagement appInfoBack start')
        router.back();
        logUtil.info('setting appManagement appInfoBack end')
    },
    onBackPress() {
        logUtil.info('setting appManagement onBackPress start')
        router.back();
        logUtil.info('setting appManagement onBackPress end')
    },
    onCreate() {
        logUtil.info('setting appManagement onCreate')
    },
    onReady() {
        logUtil.info('setting appManagement onReady')
    },
    onShow() {
        logUtil.info('setting appManagement onShow')
    },
    onHide() {
        logUtil.info('setting appManagement onHide')
    },
    onDestroy() {
        logUtil.info('setting appManagement onDestroy')
    }
}

