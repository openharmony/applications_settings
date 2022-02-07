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
import BaseModel from '../../../../../../../../common/utils/src/main/ets/default/model/BaseModel.ets';
import LogUtil from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import Bundle from '@ohos.bundle';
import ResMgr from '@ohos.resourceManager';
import AbilityManager from '@ohos.app.abilityManager'
import BaseParseConfModel from '../../../../../../../../common/utils/src/main/ets/default/model/BaseParseConfModel.ets';
import ConfigData from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import {LogAll} from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator.ets';

const INDEX = 0;
const IS_INCLUDE_ABILITY_INFO = 0;
const URI_PAGE = 'pages/applicationInfo';
let icon_arrow = $r('app.media.ic_settings_arrow');
let icon_default = $r('app.media.icon_default');

/**
 * app management service class
 */
@LogAll
export class AppManagementModel extends BaseModel {
  private mBundleInfoList: any[]= [];
 /**
  * get application data
  */
  setAppManagementListener() {
    LogUtil.info('settings AppManagementModel getIconItem ResMgr:' + JSON.stringify(ResMgr));
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
  getResourceItem(index, count, data) {
    LogUtil.info('settings AppManagementModel getIconItem start data.length' + data.length);
    let imageValue = '';
    let label = '';
    let that = this;
    LogUtil.info('settings AppManagementModel data[index].name :' + data[index].name);
    try {
      ResMgr.getResourceManager(data[index].name, (error, item) => {
        LogUtil.info('settings AppManagementModel getResourceManager item' + JSON.stringify(item) + "|error:" + error);
        let appInfo = data[index].appInfo;
        LogUtil.info('settings AppManagementModel getResourceManager appInfo.labelId:' + JSON.stringify(appInfo));
        LogUtil.info('settings AppManagementModel labelId:' + appInfo.labelId + "|iconId:" + appInfo.iconId);
        if (appInfo.labelId > 0) {
          item.getString(appInfo.labelId, (error, value) => {
            LogUtil.info('settings AppManagementModel getResourceManager  value.length:' + value.length);
            if (value != null) {
              LogUtil.info('settings AppManagementModel getResourceManager getString() value:' + value);
              label = value;
              LogUtil.info('settings AppManagementModel getResourceManager getString() label:' + label);
            } else {
              LogUtil.info('settings AppManagementModel getResourceManager getString() error:' + error);
            }
          });
        } else {
          LogUtil.info('settings AppManagementModel getResourceManager getString() label:' + appInfo.label);
          label = appInfo.label;
        }
        LogUtil.info('settings AppManagementModel getResourceManager getString() finish label:' + label);
        if (appInfo.iconId > 0) {
          item.getMediaBase64(appInfo.iconId, (error, value) => {
            console.info('settings AppManagementModel getMediaBase64 error:' + error);
            if (error != null) {
              console.info('settings AppManagementModel getMediaBase64 error!=null:' + error);
              this.mBundleInfoList.push({
                settingIcon: icon_default,
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
            }
            LogUtil.info('settings AppManagementModel getResourceManager getMediaBase64() :' + value.length);
            if (value.length > 0) {
              imageValue = value;
              LogUtil.info('settings AppManagementModel getResourceManager getMediaBase64() imageValue:' + imageValue);
            }
            LogUtil.info('settings AppManagementModel getResourceManager getMediaBase64() end');
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
              LogUtil.info('settings AppManagementModel getMediaBase64() if index:' + index + ' | count:' + count);
              index = index + 1;
              that.getResourceItem(index, count, data);
            } else {
              LogUtil.info('settings AppManagementModel getMediaBase64() else index:' + index + ' | count:' + count);
              LogUtil.info('settings AppManagementModel mBundleInfoList[i]: ' + JSON.stringify(this.mBundleInfoList));
              AppStorage.SetOrCreate('appManagementList', this.mBundleInfoList);
            }
          });
        } else {
          if (count - 1 > index) {
            LogUtil.info('settings AppManagementModel getMediaBase64() id=0:' + index + ' | count:' + count);
            index = index + 1;
            that.getResourceItem(index, count, data);
          } else {
            LogUtil.info('settings AppManagementModel getMediaBase64() id=0:' + index + ' | count:' + count);
            LogUtil.info('settings AppManagementModel mBundleInfoList[i]: ' + JSON.stringify(this.mBundleInfoList));
            AppStorage.SetOrCreate('appManagementList', this.mBundleInfoList);
          }
        }
      });
    } catch (error) {
      LogUtil.info('settings AppManagementModel catch error:' + error);
    }
    LogUtil.info('settings appManagement AppManagementModel getIconItem end');
  }

  /**
  * Get storageList
  */
  getStorageList() {
    BaseParseConfModel.getJsonDataBase(ConfigData.FILE_URI.concat('applicationStorage.json'), baseData => {
      let applicationStorageList = this.setTitleValue(baseData);
      AppStorage.SetOrCreate('applicationStorageList', applicationStorageList);
    })
  }

  /**
  * Set titleValue
  */
  setTitleValue(baseData) {
    let titleValue;
    for (let key in baseData) {
      let settingAlias = baseData[key].settingAlias;
      if ('storageTab' === settingAlias) {
        baseData[key].settingSummary = $r('app.string.storageTab')
      } else if ('totalTab' === settingAlias) {
        titleValue = $r('app.string.totalTab')
      } else if ('applyTab' === settingAlias) {
        titleValue = $r('app.string.applyTab')
      } else if ('dataTab' === settingAlias) {
        titleValue = $r('app.string.dataTab')
      } else if ('deleteDataTab' === settingAlias) {
        titleValue = $r('app.string.deleteDataTab')
      } else if ('cacheTab' === settingAlias) {
        titleValue = $r('app.string.cacheTab')
      } else if ('clearCacheTab' === settingAlias) {
        titleValue = $r('app.string.clearCacheTab')
      }
      baseData[key].settingTitle = titleValue
    }
    return baseData;
  }


  /**
   * Clear up application data by bundle name
   * @param bundleName bundle name
   */
  clearUpApplicationData(bundleName: string, callback) {
    AbilityManager.clearUpApplicationData(bundleName, callback);
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
  uninstall(bundleName: string, callback) {
    Bundle.getBundleInstaller((err: Error, bundleInstaller) => {
      if (err) {
        LogUtil.info(ConfigData.TAG + 'getBundleInstaller err : ' + JSON.stringify(err));
      }
      let installParam = { userId: 0, installFlag: 0, isKeepData: false };
      bundleInstaller.uninstall(bundleName, installParam, callback);
    });
  }

  /**
   * Kill processes by bundle name
   * @param bundleName bundle name
   */
  killProcessesByBundleName(bundleName: string, callback) {
    AbilityManager.killProcessesByBundleName(bundleName, callback);
  }

}

let appManagementModel = new AppManagementModel();

export default appManagementModel as AppManagementModel
;