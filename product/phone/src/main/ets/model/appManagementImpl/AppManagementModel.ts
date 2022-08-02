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
import BaseModel from '../../../../../../../common/utils/src/main/ets/default/model/BaseModel';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Bundle from '@ohos.bundle';
import appManager from '@ohos.application.appManager'
import osAccount from '@ohos.account.osAccount';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import { LogAll } from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';

const INDEX = 0;
const IS_INCLUDE_ABILITY_INFO = 0;
const URI_PAGE = 'pages/applicationInfo';
let icon_arrow = $r('app.media.ic_settings_arrow');
let icon_default = "ohos_app_icon";
let icon_default_str = "";

const MODULE_TAG = ConfigData.TAG + 'application-> ';

/**
 * app management service class
 */
export class AppManagementModel extends BaseModel {
    private mBundleInfoList: any[] = [];

    constructor() {
        super();
        try {
            globalThis.settingsAbilityContext.resourceManager.getMediaBase64ByName(icon_default)
                .then((res) => {
                    icon_default_str = res;
                    LogUtil.info('settings AppManagementModel getResourceManager init defaultIcon res:' + icon_default_str);
                })
                .catch((err) => {
                    icon_default_str = "";
                    LogUtil.info('settings AppManagementModel getResourceManager init defaultIcon error:' + err);
                });
        } catch (err) {
            icon_default_str = "";
            LogUtil.info('settings AppManagementModel getResourceManager init defaultIcon error:' + err);
        }

    }
    /**
     * get application data
     */
    setAppManagementListener() {
        this.mBundleInfoList = [];
        Bundle.getAllBundleInfo(IS_INCLUDE_ABILITY_INFO)
            .then((data) => {
                LogUtil.info('settings AppManagementModel setAppManagementListener getBundleInfos() start ');
                LogUtil.info('settings AppManagementModel data.length: ' + data.length + ' data: ' + JSON.stringify(data));
                this.getResourceItem(INDEX, data.length, data);
            });
        LogUtil.info('settings appManagement init AppManagementModel setAppManagementListener end');
    }

    /**
     * get resource information according to resource id
     *
     * @param index - array position
     * @param count - array length
     * @param data - data
     */
    async getResourceItem(index, count, data) {
        LogUtil.info('settings AppManagementModel getIconItem start data.length' + data.length);
        let imageValue = '';
        let label = '';
        let that = this;
        LogUtil.info('settings AppManagementModel data[index].name :' + data[index].name);
        try {
            let context = globalThis.settingsAbilityContext;
            let appInfo = data[index].appInfo;
            LogUtil.info('settings AppManagementModel getResourceManager appInfo.labelId:' + JSON.stringify(appInfo.labelResource));
            if (appInfo.labelResource.id > 0) {
                await context.resourceManager.getString(appInfo.labelResource)
                    .then((res) => {
                        label = res;
                        LogUtil.info('settings AppManagementModel getResourceManager getString() res:' + label);
                    })
                    .catch((err) => {
                        LogUtil.info('settings AppManagementModel getResourceManager getString() error:' + err);
                    });
            } else {
                label = appInfo.label;
                if (label.length == 0) {
                    label = appInfo.labelResource.bundleName;
                }
                LogUtil.info('settings AppManagementModel getResourceManager getString() id=0:' + appInfo.label);
            }
            LogUtil.info('settings AppManagementModel getResourceManager getString() value:' + label);
            LogUtil.info('settings AppManagementModel getResourceManager appInfo.iconResource:' + JSON.stringify(appInfo.iconResource));
            if (appInfo.iconResource.id > 0) {
                await context.resourceManager.getMediaBase64(appInfo.iconResource)
                    .then((res) => {
                        imageValue = res;
                        LogUtil.info('settings AppManagementModel getResourceManager getMediaBase64() res:' + imageValue);
                    })
                    .catch((err) => {
                        LogUtil.info('settings AppManagementModel getResourceManager getString() error:' + err);
                        imageValue = icon_default_str;
                    });
            } else {
                imageValue = icon_default_str;
                LogUtil.info('settings AppManagementModel getResourceManager getMediaBase64() id=0:' + icon_default_str);
            }
            LogUtil.info('settings AppManagementModel getResourceManager getMediaBase64() value:' + imageValue);
            this.mBundleInfoList.push({
                settingIcon: imageValue,
                settingTitle: label,
                settingValue: '',
                settingArrow: icon_arrow,
                settingSummary: data[index].versionName,
                settingBundleName: data[index].name,
                settingIconId: appInfo.iconId,
                settingUri: URI_PAGE
            });


            if (count - 1 > index) {
                LogUtil.info('settings AppManagementModel getMediaBase64() id=0:' + index + ' | count:' + count);
                index = index + 1;
                that.getResourceItem(index, count, data);
            } else {
                LogUtil.info('settings AppManagementModel getMediaBase64() id=0:' + index + ' | count:' + count);
                LogUtil.info('settings AppManagementModel mBundleInfoList[i]: ' + JSON.stringify(this.mBundleInfoList));
                AppStorage.SetOrCreate('appManagementList', this.mBundleInfoList);
            }
        } catch (error) {
            LogUtil.error('settings AppManagementModel catch error:' + error);
        }
        LogUtil.info('settings appManagement AppManagementModel getIconItem end');
    }

    /**
     * Remove duplicate item
     */
    public distinct(arr) {
        for (let i = 0; i < arr.length; i++) {
            for (let j = i + 1; j < arr.length; j++) {
                if (arr[i].settingBundleName === arr[j].settingBundleName) {
                    arr.splice(j, 1);
                    j--;
                }
            }
        }
        return arr;
    }

    /**
     * Clear up application data by bundle name
     * @param bundleName bundle name
     */
    clearUpApplicationData(bundleName: string, callback) {
        appManager.clearUpApplicationData(bundleName, callback);
    }

    /**
     * Clears cache data of a specified application.
     * @param bundleName bundle name
     */
    cleanBundleCacheFiles(bundleName: string, callback) {
        Bundle.cleanBundleCacheFiles(bundleName, callback);
    }

    /**
     * Uninstall an application.
     * @param bundleName bundle name
     */
    async uninstall(bundleName: string, callback) {
        LogUtil.info(ConfigData.TAG + "start uninstall in model");
        const bundlerInstaller = await Bundle.getBundleInstaller();
        const accountManager = await osAccount.getAccountManager();
        const mUserID = await accountManager.getOsAccountLocalIdFromProcess();
        LogUtil.info(ConfigData.TAG + "get bundlerInstaller : " + typeof bundlerInstaller);
        bundlerInstaller.uninstall(bundleName,
            {
                userId: mUserID,
                installFlag: 0,
                isKeepData: false
            }, (err, result) => {
                AppStorage.SetOrCreate('appManagementList', []);
                this.setAppManagementListener();
                callback(err, result);
            });
        LogUtil.info(ConfigData.TAG + "end uninstall in model");
    }

    getBundleInfo(bundleName, callback) {
        LogUtil.info(MODULE_TAG + 'start get bundle info');
        Bundle.getBundleInfo(bundleName, Bundle.BundleFlag.GET_APPLICATION_INFO_WITH_PERMISSION, callback);
        LogUtil.info(MODULE_TAG + 'end get bundle info');
    }

    /**
     * Kill processes by bundle name
     * @param bundleName bundle name
     */
    killProcessesByBundleName(bundleName: string, callback) {
        appManager.killProcessesByBundleName(bundleName, callback);
    }
}

let appManagementModel = new AppManagementModel();

export default appManagementModel as AppManagementModel
;