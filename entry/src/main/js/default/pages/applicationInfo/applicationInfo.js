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
import LogUtil from '../../common/baseUtil/LogUtil.js';
import resmgr from '@ohos.resourceManager';

let logUtil = new LogUtil();

export default {
    data: {
        appInfo: {},
        bundleName: '',
        icon: '',
        label: '',
        settingSummary: ''
    },
    onInit() {
        logUtil.info('setting applicationInfo onInit start：' );
        this.appInfo = this.dataParam;
        logUtil.info('setting applicationInfo onInit appInfo：' + JSON.stringify(this.appInfo))
        this.bundleName=this.appInfo.item.name;
        this.settingSummary=this.appInfo.settingSummary;
        this.getMediaResources(this.bundleName,this.appInfo.item.appInfo.iconId);
        this.getStringResources(this.bundleName,this.appInfo.item.appInfo.labelId);
        logUtil.info('setting applicationInfo onInit end：' );
    },

    /**
     * get app icon media by iconId
     * @param bundleName
     * @param iconId
     * @return
     */
    getMediaResources(bundleName, iconId) {
        logUtil.info('setting applicationInfo getMediaResources start bundleName labelId'+bundleName+"---"+iconId)
        let that = this;
        try {
            resmgr.getResourceManager(bundleName).then(data => {
                logUtil.info('setting applicationInfo getMediaResources getResourceManager start data:'+JSON.stringify(data))
                data.getMediaBase64(iconId,(error, value) => {
                    logUtil.info('setting applicationInfo getMediaResources getResourceManager getMediaBase64 value:'+value)
                    if (value != null) {
                        logUtil.info('setting applicationInfo getMediaResources getResourceManager getMediaBase64 if 1 value :'+value)
                        that.icon = value;
                        logUtil.info('setting applicationInfo getMediaResources getResourceManager getMediaBase64 if 2 that.icon :'+that.icon)
                    } else {
                        logUtil.info('setting applicationInfo getMediaResources getResourceManager getMediaBase64 else error:'+error)
                    }
                });
                logUtil.info('setting applicationInfo getMediaResources getResourceManager end')
            });
        } catch (err) {
            logUtil.info('setting applicationInfo getStringResources getMediaBase64 else error:'+ err)
        }
        logUtil.info('setting applicationInfo getStringResources end')
    },

    /**
     * get app label info by labelId
     * @param bundleName
     * @param labelId
     * @return
     */
    getStringResources(bundleName, labelId) {
        logUtil.info('setting applicationInfo getStringResources start bundleName labelId'+bundleName+"---"+labelId)
        let that = this;
        try {
            resmgr.getResourceManager(bundleName).then(data => {
                logUtil.info('setting applicationInfo getStringResources start data:'+data)
                if(labelId>0){
                    data.getString(labelId,(error, value)=>{
                        logUtil.info('setting applicationInfo getStringResources getString value:'+value)
                        if (value != null) {
                            logUtil.info('setting applicationInfo getStringResources getString if value:'+value)
                            that.label = value;
                            logUtil.info('setting applicationInfo getStringResources getString if that.label:'+ that.label)
                        } else {
                            logUtil.info('setting applicationInfo getStringResources getString else error:'+ error)
                        }
                    });
                }else{
                    logUtil.info('setting applicationInfo getStringResources getString else this.appInfo.item.label:'+ this.appInfo.item.label)
                    that.label =this.appInfo.item.appInfo.label;
                }
            });
        }catch(err) {
            logUtil.info('setting applicationInfo getStringResources catch err:'+err)
        }
        logUtil.info('setting applicationInfo getStringResources end')
    },
    appInfoBack() {
        logUtil.info('setting applicationInfo appInfoBack start')
        router.back();
        logUtil.info('setting applicationInfo appInfoBack end')
    },
    onBackPress() {
        logUtil.info('setting applicationInfo onBackPress start')
        router.back();
        logUtil.info('setting applicationInfo onBackPress end')
    },
    onCreate(){
        logUtil.info('setting applicationInfo onCreate')
    },
    onReady(){
        logUtil.info('setting applicationInfo onReady')
    },
    onShow(){
        logUtil.info('setting applicationInfo onShow')
    },
    onHide(){
        logUtil.info('setting applicationInfo onHide')
    },
    onDestroy(){
        logUtil.info('setting applicationInfo onDestroy')
    }
}
