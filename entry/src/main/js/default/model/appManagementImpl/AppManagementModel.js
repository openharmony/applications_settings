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
import bundle from '@ohos.bundle_mgr';
import resmgr from '@ohos.resmgr';

const index = 0;
/**
 * app management service class
 *
 */
var mBundleInfoList = [];

export default class AppManagementModel extends BaseModel {
    setAppManagementListener(callback) {
        console.info('setting appManagement init AppManagementModel setAppManagementListener start')
        bundle.getApplicationInfos().then((data) => {
            console.log('setting appManagement init AppManagementModel setAppManagementListener getApplicationInfos() data.length: ' + data.length);
            for (var i = 0;i < data.length; i++) {
                console.log('setting appManagement init AppManagementModel setAppManagementListener getApplicationInfos() data[i].iconId:' + data[i].bundleName + '|data[i].iconId:' + data[i].iconId + '|data[i].labelId:' + data[i].labelId);
            }
            var dataArray = data;
            console.log('setting appManagement init AppManagementModel setAppManagementListener getApplicationInfos() dataArray' + JSON.stringify(dataArray));
            this.getIcon(dataArray, callback);
        });
        console.info('setting appManagement init AppManagementModel setAppManagementListener end')
    }

    getIcon(data, callback) {
        console.info('setting appManagement init AppManagementModel getIcon start')
        this.getIconItem(index, data.length, data, callback);
        console.info('setting appManagement init AppManagementModel getIcon end')
    }

    /**
     * get app icon and item
     * @param index
     * @param count
     * @param data
     * @param callback
     * @return
     */
    getIconItem(index, count, data, callback) {
        console.info('setting appManagement init AppManagementModel getIconItem start data.length' + data.length)
        let imageValue = '';
        let label = '';
        let that = this;
        resmgr.getResourceManager(data[index].bundleName, (error, item) => {
            console.info('setting appManagement init AppManagementModel getIconItem getResourceManager start item' + JSON.stringify(item))
            if (data[index].labelId > 0) {
                item.getString(data[index].labelId, (error, value) => {
                    console.info('setting appManagement init AppManagementModel getIconItem getResourceManager getString() value.length:' + value.length)
                    if (value != null) {
                        console.info('setting appManagement init AppManagementModel getIconItem getResourceManager getString() value:' + value)
                        label = value;
                        console.info('setting appManagement init AppManagementModel getIconItem getResourceManager getString() label:' + label)
                    } else {
                        console.info('setting appManagement init AppManagementModel getIconItem getResourceManager getString() error:' + error)
                    }
                });
            } else {
                console.info('setting appManagement init AppManagementModel getIconItem getResourceManager getString() data[index].label:' + data[index].label)
                label = data[index].label;
            }
            console.info('setting appManagement init AppManagementModel getIconItem getResourceManager getString() finish label:' + label)
            item.getMediaBase64(data[index].iconId, (error, value) => {
                console.info('setting appManagement init AppManagementModel getIconItem getResourceManager getMediaBase64() value.length:' + value.length)
                if (value.length > 0) {
                    imageValue = value;
                } else {
                }
                console.info('setting appManagement init AppManagementModel getIconItem getResourceManager getMediaBase64() end')
                mBundleInfoList.push({
                    settingIcon: imageValue,
                    settingTitle: label,
                    settingValue: '',
                    settingArrow: '/res/image/ic_settings_arrow.png',
                    settingDefaultValue: false,
                    settingSummary: '',
                    dividerIsShow: true,
                    settingType: 1,
                    settingBundleName: data[index].bundleName,
                    item: data[index],
                    settingUri: 'pages/applicationInfo/applicationInfo'
                })
                if (count - 1 > index) {
                    setTimeout(function () {
                        console.info('setting appManagement init AppManagementModel getIconItem getResourceManager getMediaBase64() if index:' + index + '|count:' + count)
                        index = index + 1;
                        that.getIconItem(index, count, data, callback);
                    }, 100);
                } else {
                    console.info('setting appManagement init AppManagementModel getIconItem getResourceManager getMediaBase64() else index:' + index + '|count:' + count)
                    that.getBundleInfo(0, mBundleInfoList.length, mBundleInfoList, callback);
                }
            });
        });
        console.info('setting appManagement init AppManagementModel getIconItem end')
    }
    /**
     * getBundleInfo
     * @param index
     * @param count
     * @param mBundleInfoList
     * @param callback
     * @return
     */
    getBundleInfo(index, count, mBundleInfoList, callback) {
        let that = this
        console.info('setting appManagement init AppManagementModel getBundleInfo start mBundleInfoList :' + mBundleInfoList.length+mBundleInfoList[index].settingBundleName)
        bundle.getBundleInfo(mBundleInfoList[index].settingBundleName).then(data => {
            console.info("setting appManagement init AppManagementModel getBundleInfo versionCode:" + data.versionCode + "|versionName:" + data.versionName);
            mBundleInfoList[index].settingSummary = data.versionName;
            console.info("setting appManagement init AppManagementModel getBundleInfo  mBundleInfoList[index].settingSummary:" + mBundleInfoList[index].settingSummary);
            if (count - 1 > index) {
                setTimeout(function () {
                    console.info('setting appManagement init AppManagementModel getIconItem getBundleInfo if index:' + index + '|count:' + count)
                    index = index + 1;
                    that.getBundleInfo(index, count, mBundleInfoList, callback);
                }, 100);
            } else {
                console.info('setting appManagement init AppManagementModel getIconItem getBundleInfo callback else index:' + index + '|count:' + count)
                callback(mBundleInfoList);
            }
        });
        console.info('setting appManagement init AppManagementModel getBundleInfo end' )
    }
}