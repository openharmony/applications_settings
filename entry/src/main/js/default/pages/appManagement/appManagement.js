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
import Router from '@system.router';

const DATA_PAGE_SOURCE_APP_PAGE = 'appPage';

let mAppManagementModel = null;
let mLogUtil = null;
globalThis.$globalR = null;

export default {
    data: {
        animatorOn: true,
        contentViewIsShow: false,
        appList: [],
        frames: null,
    },
    onInit() {
        mLogUtil = new LogUtil();
        mLogUtil.info('setting appManagement init start');
        this.initFrames();
        mAppManagementModel = new AppManagementModel();
        globalThis.$globalR = this.$r.bind(this);
        mAppManagementModel.setAppManagementListener(this.appListData);
        mLogUtil.info('setting appManagement init end');
    },
    appListData(appListData) {
        if (null === appListData) {
            mLogUtil.info('setting appManagement appListData is null');
            return;
        }
        this.handleStop();
        this.animatorOn = false;
        this.contentViewIsShow = true;
        mLogUtil.info('setting appManagement appListData start:' + JSON.stringify(appListData.length));
        for (let i = 0; i < appListData.length; i++) {
            let settingSummary = appListData[i].settingSummary;
            appListData[i].settingSummary = this.$t('strings.version').concat(settingSummary);
        }
        this.appList = appListData;
        mLogUtil.info('setting appManagement appListData end');
    },

    /**
     * Jump to search page
     */
    onClick() {
        mLogUtil.info('setting appManagement onClick start pages/searchInfo/searchInfo ');
        Router.push({
            uri: 'pages/searchInfo/searchInfo',
            params: {
                appData: this.appList,
                type: DATA_PAGE_SOURCE_APP_PAGE
            }
        });
        mLogUtil.info('setting appManagement onClick end');
    },
    appInfoBack() {
        mLogUtil.info('setting appManagement appInfoBack start');
        Router.back();
        mLogUtil.info('setting appManagement appInfoBack end');
    },
    onBackPress() {
        mLogUtil.info('setting appManagement onBackPress start');
        Router.back();
        mLogUtil.info('setting appManagement onBackPress end');
    },
    onCreate() {
        mLogUtil.info('setting appManagement onCreate');
    },
    onReady() {
        mLogUtil.info('setting appManagement onReady');
    },
    onShow() {
        mLogUtil.info('setting appManagement onShow');
    },
    onHide() {
        mLogUtil.info('setting appManagement onHide');
    },
    onDestroy() {
        mLogUtil.info('setting appManagement onDestroy');
    },
    initFrames() {
        mLogUtil.info('setting appManagement initFrames Start');
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
    handleStart() {
        mLogUtil.info('setting appManagement handleStart');
        this.$refs.animator.start();
    },
    handlePause() {
        mLogUtil.info('setting appManagement handlePause');
        this.$refs.animator.pause();
    },
    handleResume() {
        mLogUtil.info('setting appManagement handleResume');
        this.$refs.animator.resume();
    },
    handleStop() {
        mLogUtil.info('setting appManagement handleStop');
        this.$refs.animator.stop();
    },
    handleClose() {
        mLogUtil.info('setting appManagement handleClose');
        this.$refs.animator.close();
    },
    handleFinish() {
        mLogUtil.info('setting appManagement handleFinish');
        this.$refs.animator.finish();
    },
};

