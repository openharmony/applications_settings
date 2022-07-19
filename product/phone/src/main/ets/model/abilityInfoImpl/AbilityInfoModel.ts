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
import BaseModel from '../../../../../../common/utils/src/main/ets/default/model/BaseModel';
import Bundle from '@ohos.bundle';
//import ResMgr from '@ohos.resourceManager';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import {BaseData} from '../../../../../../common/utils/src/main/ets/default/bean/BaseData';
import {MetaDataModel} from './MetaDataModel';

let icon_arrow = $r('app.media.ic_settings_arrow');
let icon_default = $r('app.media.icon_default');
let metaName = 'meta-app';

/**
 * Obtain meta-data Information
 */
export class AbilityInfoModel extends BaseModel {
  public mAbilityInfoList: BaseData[]= [];
  private metaDatas: string[]= [];
  /**
   * Obtain meta-data Information
   * @param bundleName - bundleName
   * @param abilityName - abilityName
   * @param callback - Return meta-data
   */
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
      LogUtil.info('settings getAbilityInfoListener ability:' + JSON.stringify(ability));
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
          let metaApp = abilityMetaData.customizeDatas[i].name;
          if (metaName === metaApp) {
            extra = abilityMetaData.customizeDatas[i].extra;
          }
        }
        if ('' !== extra && undefined !== extra) {
          let metaDataModel = new MetaDataModel('{' + extra + '}');
          LogUtil.info('settings getAbilityInfoListener ability BaseData:' + JSON.stringify(metaDataModel));
          this.getResource(callback, metaDataModel, bundleName, icon_default);
        }
      }
    });
    LogUtil.info('settings getAbilityInfoListener mAbilityInfoList end: ' + JSON.stringify(this.mAbilityInfoList));
  }

  getResource(callback, metaBase, bundleName, deaultAppIcon) {
    LogUtil.info('settings getAbilityInfoListener getIconItem start');
    let imageValue = '';
    let label = '';
    try {
      LogUtil.info('settings getAbilityInfoListener labelId:' + metaBase.labelId + '|iconId:' + metaBase.iconId);
      if (null !== metaBase.labelName && '' !== metaBase.labelName) {
        LogUtil.info('settings getAbilityInfoListener getResourceManager getString() label:' + label);
        label = metaBase.labelName;
      } else {
        if (metaBase.labelId > 0) {
            globalThis.settingsAbilityContext.resourceManager.getString(parseInt(metaBase.labelId), (error, value) => {
            if (error != null) {
              LogUtil.info('settings getAbilityInfoListener getString error:' + error);
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
      globalThis.settingsAbilityContext.resourceManager.getMediaBase64(parseInt(metaBase.iconId), (error, value) => {
        if (error != null) {
          LogUtil.info('settings getAbilityInfoListener getMediaBase64 error:' + error);
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
      LogUtil.info('settings getAbilityInfoListener mAbilityInfoList out: ' + JSON.stringify(this.mAbilityInfoList));
    } catch (error) {
      LogUtil.info('settings getAbilityInfoListener catch error:' + error);
    }
    LogUtil.info('settings getAbilityInfoListener getIconItem end');
  }
  /**
   * @param label - title
   * @param imageValue - image
   * @param metaBase -
   * @param callback -
   */
  getMetaDataList(label, imageValue, metaBase, callback) {
    this.mAbilityInfoList = [];
    let baseData = new BaseData();
    baseData.settingIcon = imageValue;
    baseData.settingTitle = label;
    baseData.settingAlias = '';
    baseData.settingValue = ''
    baseData.settingArrow = icon_arrow;
    baseData.settingSummary = metaBase.summary,
    baseData.settingUri = metaBase.action;
    baseData.settingPriority = metaBase.priority;
    this.mAbilityInfoList.push(baseData);
    LogUtil.info('settings getAbilityInfoListener mAbilityInfoList in: ' + JSON.stringify(this.mAbilityInfoList));
    callback(this.mAbilityInfoList);
  }
}

let abilityInfoModel = new AbilityInfoModel();

export default abilityInfoModel as AbilityInfoModel
;