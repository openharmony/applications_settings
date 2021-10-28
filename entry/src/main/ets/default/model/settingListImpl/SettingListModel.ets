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
import ConfigData from '../../common/baseUtil/ConfigData.ets';
import LogUtil from '../../common/baseUtil/LogUtil.ets';
import  BaseParseConfModel from '../baseParseConfImpl/BaseParseConfModel.ets';
import BaseModel from '../BaseModel.ets';
import FeatureAbility from '@ohos.ability.featureAbility';
import WifiModel from '../wifiImpl/WifiModel.ets';
import AbilityInfoModel from '../abilityInfoImpl/AbilityInfoModel.ets';

const BUNDEL_NAME1 = 'com.ohos.settings1';
const ABILITY_NAME1 = 'com.ohos.settings1.MainAbility';
const BUNDEL_NAME2 = 'com.ohos.settings2';
const ABILITY_NAME2 = 'com.ohos.settings2.MainAbility';
const BUNDEL_NAME3 = 'com.ohos.settings3';
const ABILITY_NAME3 = 'com.ohos.settings3.MainAbility';
const BUNDEL_NAME5 = 'com.ohos.settings5';
const ABILITY_NAME5 = 'com.ohos.settings5.MainAbility';
/**
 * app setting homepage service class
 */
export class SettingListModel extends BaseModel {
  private appList: any[]= [];

  async setSettingListener() {
    LogUtil.info('settings SettingListModel getAbilityInfoListener in');
    BaseParseConfModel.getJsonDataBase(ConfigData.FILE_URI.concat('settinglist.json'), baseData => {
      LogUtil.info('settings SettingListModel getAbilityInfoListener getJsonDataBase:' + JSON.stringify(baseData))
      let settingsList = this.setTitleValue(baseData);
      AppStorage.SetOrCreate('settingsList', settingsList);
      for (let index = 0;index < 4; index++) {
        let BUNDEL_NAME;
        let ABILITY_NAME;
        if (index === 0) {
          BUNDEL_NAME = BUNDEL_NAME1;
          ABILITY_NAME = ABILITY_NAME1;
        } else if (index === 1) {
          BUNDEL_NAME = BUNDEL_NAME2;
          ABILITY_NAME = ABILITY_NAME2;
        } else if (index === 2) {
          BUNDEL_NAME = BUNDEL_NAME3;
          ABILITY_NAME = ABILITY_NAME3;
        } else if (index === 3) {
          BUNDEL_NAME = BUNDEL_NAME5;
          ABILITY_NAME = ABILITY_NAME5;
        }
        AbilityInfoModel.getAbilityInfo(BUNDEL_NAME, ABILITY_NAME, metaData => {
          LogUtil.info('settings SettingListModel getAbilityInfoListener getAbilityInfo:' + JSON.stringify(metaData))
          LogUtil.info('settings SettingListModel getAbilityInfoListener getAbilityInfo summary:' + metaData.summary)
          settingsList.push.apply(settingsList, metaData);
          metaData = [];
          LogUtil.info('settings SettingListModel getAbilityInfoListener settingsList:' + settingsList.length)
          AppStorage.SetOrCreate('settingsList', settingsList);
        });
      }
    });
  }

  setTitleValue(settingsList) {
    LogUtil.info('settings setTitleValue getAbilityInfoListener this.settingsList in:' + JSON.stringify(settingsList));
    for (let key in settingsList) {
      let settingAlias = settingsList[key].settingAlias;
      let value;
      let wifiStatus = WifiModel.getWifiStatus();
      if ('wifiTab' === settingAlias) {
        value = $r('app.string.wifiTab');
        if (wifiStatus) {
          settingsList[key].settingValue = $r('app.string.enabled');
        } else {
          settingsList[key].settingValue = $r('app.string.disabled');
        }
      }
      else if ('brightnessTab' === settingAlias) {
        value = $r('app.string.brightnessTab');
      } else if ('applyTab' === settingAlias) {
        value = $r('app.string.applyTab');
      } else if ('dateAndTimeTab' === settingAlias) {
        value = $r('app.string.dateAndTimeTab');
      } else if ('aboutTab' === settingAlias) {
        value = $r('app.string.aboutTab');
      } else if ('volumeControlTab' === settingAlias) {
        value = $r('app.string.volumeControlTab');
      }
      settingsList[key].settingTitle = value;
    }
    LogUtil.info('settings setTitleValue getAbilityInfoListener end this.settingsList:' + JSON.stringify(settingsList));
    return settingsList;
  }

  startPage(callback): void{
    LogUtil.info('settings SettingList startPage start');
    FeatureAbility.getWant().then((Want) => {
      LogUtil.info(`settings SettingList startWifiPage successful. Data: ${ JSON.stringify(Want) }`);
      LogUtil.info(`settings SettingList startWifiPage successful. Want.uri: ${ Want.uri }`);
      callback( Want.uri);
    })
      .catch((error) => {
      LogUtil.error('settings SettingList startWifiPage failed. Cause: ' + JSON.stringify(error));
    })
  }
}

let settingListModel = new SettingListModel();
export default settingListModel as SettingListModel
;