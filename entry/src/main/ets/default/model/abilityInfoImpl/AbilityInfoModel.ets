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
import BaseModel from '../BaseModel';
import Bundle from '@ohos.bundle';
import ResMgr from '@ohos.resourceManager';
import LogUtil from '../../common/baseUtil/LogUtil.ets';
import {BaseData} from '../BaseData.ets';

export class AbilityInfoModel extends BaseModel {
  public mAbilityInfoList: any[]= [];
  private metaDatas: string[]= [];

  getAbilityInfo(bundleName, abilityName, callback) {
    LogUtil.info('settings getAbilityInfoListener in');
    Bundle.queryAbilityByWant(
      {
        want: {
          action: 'action.system.home',
          entities: ['entity.system.home'],
          elementName: {
            deviceId: '0',
            bundleName: bundleName,
            abilityName: abilityName,
          },
        }
      }, 1, 0, (err, ability) => {
      LogUtil.info('setting getAbilityInfoListener ability:' + JSON.stringify(ability));
      let abilityMetaData;
      for (let i = 0, len = ability.length; i < len; i++) {
        abilityMetaData = ability[i].metaData;
      }
      LogUtil.info('settings getAbilityInfoListener ability MetaData :' + JSON.stringify(abilityMetaData));
      if ('' !== abilityMetaData && undefined !== abilityMetaData
      && [] !== abilityMetaData.customizeDatas && abilityMetaData.customizeDatas.length > 0) {
        LogUtil.info('settings getAbilityInfoListener ability Custom:' + JSON.stringify(abilityMetaData.customizeDatas));
        let extra;
        for (let i = 0, len = abilityMetaData.customizeDatas.length; i < len; i++) {
          LogUtil.info('settings getAbilityInfoListener ability Extra:' +
          JSON.stringify(abilityMetaData.customizeDatas[i].extra));
          extra = abilityMetaData.customizeDatas[i].extra;
        }
        LogUtil.info('settings getAbilityInfoListener ability { + extra + }:' + '{' + extra + '}');
        let extraJson = JSON.parse('{' + extra + '}');
        LogUtil.info('settings getAbilityInfoListener ability BaseData:' + JSON.stringify(extraJson));
        this.getIconItem(callback, extraJson, bundleName, $r('app.media.icon_default'));
      }
    });
    LogUtil.info('settings getAbilityInfoListener mAbilityInfoList end: ' + JSON.stringify(this.mAbilityInfoList));
  }

  getIconItem(callback, metaBase, bundleName, deaultAppIcon) {
    LogUtil.info('settings getAbilityInfoListener getIconItem start');
    let imageValue = '';
    let label = '';
    try {
      ResMgr.getResourceManager(bundleName, (error, item) => {
        LogUtil.info('settings getAbilityInfoListener getResourceManager item' + JSON.stringify(item) + "|error:" + error);
        LogUtil.info('settings getAbilityInfoListener labelId:' + metaBase.labelId + "|iconId:" + metaBase.iconId);
        if (null !== metaBase.labelName && '' !== metaBase.labelName) {
          LogUtil.info('settings getAbilityInfoListener getResourceManager getString() label:' + label);
          label = metaBase.labelName;
        } else {
          if (metaBase.labelId > 0) {
            item.getString(parseInt(metaBase.labelId), (error, value) => {
              if (error != null) {
                console.info('settings getAbilityInfoListener getString error:' + error);
                label = '';
              }
              LogUtil.info('settings getAbilityInfoListener getResourceManager  value.length:' + value.length);
              if (value !== null) {
                LogUtil.info('settings getAbilityInfoListener getResourceManager getString() value:' + value);
                label = value;
                LogUtil.info('settings getAbilityInfoListener getResourceManager getString() label:' + label);
              } else {
                LogUtil.info('settings getAbilityInfoListener getResourceManager getString() error:' + error);
              }
            });
          } else {
            label = '';
          }
        }
        LogUtil.info('settings getAbilityInfoListener getResourceManager getString() finish label:' + label);
        item.getMediaBase64(parseInt(metaBase.iconId), (error, value) => {
          if (error != null) {
            console.info('settings getAbilityInfoListener getMediaBase64 error:' + error);
            imageValue = deaultAppIcon;
            this.getMetaDataList(label, imageValue, metaBase, callback)
          }
          LogUtil.info('settings getAbilityInfoListener getMediaBase64 value:' + value.length);
          if (value.length > 0) {
            imageValue = value;
            LogUtil.info('settings getAbilityInfoListener getResourceManager getMediaBase64 imageValue:' + imageValue);
          } else {
            imageValue = deaultAppIcon;
          }
          LogUtil.info('settings getAbilityInfoListener getResourceManager getMediaBase64 end');
          this.getMetaDataList(label, imageValue, metaBase, callback)
        })
      });
      LogUtil.info('settings getAbilityInfoListener mAbilityInfoList out: ' + JSON.stringify(this.mAbilityInfoList));
    } catch (error) {
      LogUtil.info('settings getAbilityInfoListener catch error:' + error);
    }
    LogUtil.info('settings getAbilityInfoListener getIconItem end');
  }

  getMetaDataList(label, imageValue, metaBase, callback) {
    this.mAbilityInfoList = [];
    let baseData = new BaseData();
    baseData.settingIcon = imageValue;
    baseData.settingTitle = label;
    baseData.settingAlias = '';
    baseData.settingValue = ''
    baseData.settingArrow = 'res/image/ic_settings_arrow.svg';
    baseData.settingSummary = metaBase.summary,
    baseData.settingUri = metaBase.action;
    this.mAbilityInfoList.push(baseData);
    LogUtil.info('settings getAbilityInfoListener mAbilityInfoList in: ' + JSON.stringify(this.mAbilityInfoList));
    callback(this.mAbilityInfoList);
  }

  getIconListItem(index, count, data, deaultAppIcon) {
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
              let baseData = new BaseData();
              baseData.settingIcon = deaultAppIcon;
              baseData.settingTitle = label;
              baseData.settingAlias = '';
              baseData.settingValue = '';
              baseData.settingArrow = 'res/image/ic_settings_arrow.svg';
              baseData.settingSummary = data.summary,
              baseData.settingUri = data.action;
              this.mAbilityInfoList.push(baseData);
              if (count - 1 > index) {
                LogUtil.info('settings AppManagementModel getMediaBase64() id=0:' + index + ' | count:' + count);
                index = index + 1;
                that.getIconListItem(index, count, data, deaultAppIcon);
              } else {
                LogUtil.info('settings AppManagementModel getMediaBase64() id=0:' + index + ' | count:' + count);
                LogUtil.info('settings AppManagementModel mBundleInfoList[i]: ' + JSON.stringify(this.mAbilityInfoList));
                AppStorage.SetOrCreate('appManagementList', this.mAbilityInfoList);
              }
            }
            LogUtil.info('settings AppManagementModel getResourceManager getMediaBase64() :' + value.length);
            if (value.length > 0) {
              imageValue = value;
              LogUtil.info('settings AppManagementModel getResourceManager getMediaBase64() imageValue:' + imageValue);
            }
            LogUtil.info('settings AppManagementModel getResourceManager getMediaBase64() end');
            let baseData = new BaseData();
            baseData.settingIcon = imageValue;
            baseData.settingTitle = label;
            baseData.settingAlias = '';
            baseData.settingValue = '';
            baseData.settingArrow = 'res/image/ic_settings_arrow.svg';
            baseData.settingSummary = data.summary,
            baseData.settingUri = data.action;
            this.mAbilityInfoList.push(baseData);
            if (count - 1 > index) {
              LogUtil.info('settings AppManagementModel getMediaBase64() if index:' + index + ' | count:' + count);
              index = index + 1;
              that.getIconListItem(index, count, data, deaultAppIcon);
            } else {
              LogUtil.info('settings AppManagementModel getMediaBase64() else index:' + index + ' | count:' + count);
              LogUtil.info('settings AppManagementModel mBundleInfoList[i]: ' + JSON.stringify(this.mAbilityInfoList));
              AppStorage.SetOrCreate('appManagementList', this.mAbilityInfoList);
            }
          });
        } else {
          if (count - 1 > index) {
            LogUtil.info('settings AppManagementModel getMediaBase64() id=0:' + index + ' | count:' + count);
            index = index + 1;
            that.getIconListItem(index, count, data, deaultAppIcon);
          } else {
            LogUtil.info('settings AppManagementModel getMediaBase64() id=0:' + index + ' | count:' + count);
            LogUtil.info('settings AppManagementModel mBundleInfoList[i]: ' + JSON.stringify(this.mAbilityInfoList));
            AppStorage.SetOrCreate('appManagementList', this.mAbilityInfoList);
          }
        }
      });
    } catch (error) {
      LogUtil.info('settings AppManagementModel catch error:' + error);
    }
    LogUtil.info('settings appManagement AppManagementModel getIconItem end');
  }
}

let abilityInfoModel = new AbilityInfoModel();
export default abilityInfoModel as AbilityInfoModel
;