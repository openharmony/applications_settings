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
import BaseModel from '../BaseModel.js';
import bundle from '@ohos.bundle';
import resmgr from '@ohos.resmgr';

const INDEX = 0;
const IS_INCLUDE_ABILITY_INFO = 0;
/**
 * app management service class
 *
 */
var mBundleInfoList = [];

export default class AppManagementModel extends BaseModel {
    setAppManagementListener(callback) {
        console.info('setting appManagement init AppManagementModel setAppManagementListener start');
        bundle.getBundleInfos(IS_INCLUDE_ABILITY_INFO).then((data) => {
            console.info('AppManagementModel setAppManagementListener getBundleInfos() start ');
            console.info('AppManagementModel data.length: ' + data.length + ' data: ' + JSON.stringify(data));
            this.getIconItem(INDEX, data.length, data, callback);
        });
        console.info('setting appManagement init AppManagementModel setAppManagementListener end');
    }

    getIconItem(index, count, data, callback) {
        console.info('AppManagementModel getIconItem start data.length' + data.length);
        let imageValue = '';
        let label = '';
        let that = this;
        resmgr.getResourceManager(data[index].name, (error, item) => {
            console.info('AppManagementModel getIconItem getResourceManager start item' + JSON.stringify(item));
            var appInfo = data[index].appInfo;
            if (appInfo.labelId > 0) {
                item.getString(appInfo.labelId, (error, value) => {
                    console.info('AppManagementModel getIconItem getResourceManager  value.length:' + value.length);
                    if (value != null) {
                        console.info('AppManagementModel getIconItem getResourceManager getString() value:' + value);
                        label = value;
                        console.info('AppManagementModel getIconItem getResourceManager getString() label:' + label);
                    } else {
                        console.info('AppManagementModel getIconItem getResourceManager getString() error:' + error);
                    }
                });
            } else {
                console.info('AppManagementModel getIconItem getResourceManager getString() label:' + appInfo.label);
                label = appInfo.label;
            }
            console.info('AppManagementModel getIconItem getResourceManager getString() finish label:' + label);
            item.getMediaBase64(appInfo.iconId, (error, value) => {
                console.info('AppManagementModel getIconItem getResourceManager getMediaBase64() :' + value.length);
                if (value.length > 0) {
                    imageValue = value;
                }
                console.info('AppManagementModel getIconItem getResourceManager getMediaBase64() end');
                mBundleInfoList.push({
                    settingIcon: imageValue,
                    settingTitle: label,
                    settingValue: '',
                    settingArrow: '/res/image/ic_settings_arrow.svg',
                    settingDefaultValue: false,
                    settingSummary: data[index].versionName,
                    dividerIsShow: true,
                    settingType: 1,
                    settingBundleName: data[index].name,
                    item: data[index],
                    settingUri: 'pages/applicationInfo/applicationInfo'
                })
                if (count - 1 > index) {
                    setTimeout(function () {
                        console.info('AppManagementModel getMediaBase64() if index:' + index + ' | count:' + count);
                        index = index + 1;
                        that.getIconItem(index, count, data, callback);
                    }, 100);
                } else {
                    console.info('AppManagementModel getMediaBase64() else index:' + index + ' | count:' + count);
                    callback(mBundleInfoList);
                }
            });
        });
        console.info('setting appManagement init AppManagementModel getIconItem end');
    }
}