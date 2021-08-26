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
import LogUtil from '../../common/baseUtil/LogUtil.js';
import Resmgr from '@ohos.resourceManager';

let mLogUtil = null;

export default {
    data: {
        appInfo: {},
        bundleName: '',
        icon: '',
        label: '',
        settingSummary: ''
    },
    onInit() {
        mLogUtil = new LogUtil();
        mLogUtil.info('setting applicationInfo onInit start');
        this.appInfo = this.dataParam;
        mLogUtil.info('setting applicationInfo onInit appInfo:' + JSON.stringify(this.appInfo));
        this.bundleName = this.appInfo.item.name;
        this.settingSummary = this.appInfo.settingSummary;
        this.getMediaResources(this.bundleName, this.appInfo.item.appInfo.iconId);
        this.getStringResources(this.bundleName, this.appInfo.item.appInfo.labelId);
        mLogUtil.info('setting applicationInfo onInit end');
    },

    /**
     * get app icon media by iconId
     * @param bundleName
     * @param iconId
     * @return
     */
    getMediaResources(bundleName, iconId) {
        mLogUtil.info('applicationInfo getMediaResources start bundleName labelId' + bundleName + '|' + iconId);
        let that = this;
        try {
            Resmgr.getResourceManager(bundleName).then(data => {
                mLogUtil.info('getMediaResources getResourceManager start data:' + JSON.stringify(data));
                data.getMediaBase64(iconId, (error, value) => {
                    mLogUtil.info('getMediaResources getResourceManager getMediaBase64 value:' + value);
                    if (value !== null) {
                        mLogUtil.info('getMediaResources getResourceManager getMediaBase64 if 1 value :' + value);
                        that.icon = value;
                        mLogUtil.info('getMediaResources getResourceManager getMediaBase64 if 2 icon :' + that.icon);
                    } else {
                        mLogUtil.info('getMediaResources getResourceManager getMediaBase64 else error:' + error);
                    }
                });
                mLogUtil.info('setting applicationInfo getMediaResources getResourceManager end');
            });
        } catch (err) {
            mLogUtil.info('setting applicationInfo getStringResources getMediaBase64 else error:' + err);
        }
        mLogUtil.info('setting applicationInfo getStringResources end');
    },

    /**
     * get app label info by labelId
     * @param bundleName
     * @param labelId
     * @return
     */
    getStringResources(bundleName, labelId) {
        mLogUtil.info('getStringResources start bundleName labelId' + bundleName + '|' + labelId);
        let that = this;
        try {
            Resmgr.getResourceManager(bundleName).then(data => {
                mLogUtil.info('setting applicationInfo getStringResources start data:' + data);
                if (labelId > 0) {
                    data.getString(labelId, (error, value) => {
                        mLogUtil.info('setting applicationInfo getStringResources getString value:' + value);
                        if (value !== null) {
                            mLogUtil.info('applicationInfo getStringResources getString if value:' + value);
                            that.label = value;
                            mLogUtil.info('applicationInfo getStringResources getString if that.label:' + that.label);
                        } else {
                            mLogUtil.info('setting applicationInfo getStringResources getString else error:' + error);
                        }
                    });
                } else {
                    mLogUtil.info('getStringResources getString else appInfo.item.label:' + this.appInfo.item.label);
                    that.label = this.appInfo.item.appInfo.label;
                }
            });
        } catch (err) {
            mLogUtil.info('setting applicationInfo getStringResources catch err:' + err);
        }
        mLogUtil.info('setting applicationInfo getStringResources end');
    },
    appInfoBack() {
        mLogUtil.info('setting applicationInfo appInfoBack start');
        Router.back();
        mLogUtil.info('setting applicationInfo appInfoBack end');
    },
    onBackPress() {
        mLogUtil.info('setting applicationInfo onBackPress start');
        Router.back();
        mLogUtil.info('setting applicationInfo onBackPress end');
    },
    onCreate() {
        mLogUtil.info('setting applicationInfo onCreate');
    },
    onReady() {
        mLogUtil.info('setting applicationInfo onReady');
    },
    onShow() {
        mLogUtil.info('setting applicationInfo onShow');
    },
    onHide() {
        mLogUtil.info('setting applicationInfo onHide');
    },
    onDestroy() {
        mLogUtil.info('setting applicationInfo onDestroy');
    }
};
