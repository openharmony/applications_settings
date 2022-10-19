/**
 * Copyright (c) 2021-2022 Huawei Device Co., Ltd.
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

import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import BaseModel from '../../../../../../../common/utils/src/main/ets/default/model/BaseModel';
import ResourceUtil from '../../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import wifi from '@ohos.wifi';
import prompt from '@system.prompt';
import Router from '@system.router';
import FeatureAbility from '@ohos.ability.featureAbility';

/**
 * app setting homepage service class
 */
export class SettingListModel extends BaseModel {
  private TAG = `${ConfigData.TAG} SettingListModel`;

  /**
   * Get settingsList
   */
  @Log
  getSettingList() {
//    return this.settingsList;
  }

  /**
   * Item on click
   */
  @Log
  onSettingItemClick(targetPage): void{
    if(targetPage === ''){
      globalThis.settingsAbilityContext.startAbility({
        bundleName: ConfigData.MOBILE_DATA_BUNDLE_NAME,
        abilityName: ConfigData.MOBILE_DATA_ABILITY_NAME,
      })
        .then((data) => {
          LogUtil.info(`${this.TAG}, ${ConfigData.MOBILE_DATA_BUNDLE_NAME} start successful. Data: ${JSON.stringify(data)}`);
        })
        .catch((error) => {
          ResourceUtil.getString($r("app.string.mobileDataFailed")).then(value => {
            prompt.showToast({
              message: value,
              duration: 2000,
            });
            LogUtil.error(`${this.TAG}, ${ConfigData.MOBILE_DATA_BUNDLE_NAME} start failed. Cause: ${JSON.stringify(error)}`);
          })
        })
    }else if(targetPage === 'security'){
      globalThis.settingsAbilityContext.startAbility({
        bundleName: ConfigData.SECURITY_BUNDLE_NAME,
        abilityName: ConfigData.SECURITY_ABILITY_NAME,
      })
        .then((data) => {
          LogUtil.info(`${this.TAG}, ${ConfigData.SECURITY_BUNDLE_NAME} start successful. Data: ${JSON.stringify(data)}`);
        })
        .catch((error) => {
          ResourceUtil.getString($r("app.string.securityFailed")).then(value => {
            prompt.showToast({
              message: value,
              duration: 2000,
            });
            LogUtil.error(`${this.TAG}, ${ConfigData.SECURITY_BUNDLE_NAME} start failed. Cause: ${JSON.stringify(error)}`);
          })
        })
    } else {
      Router.push({
        uri: targetPage,
      });
    }
  }

  /**
   * Register Observer
   */
  @Log
  registerObserver(){
    wifi.on('wifiStateChange', (code) => {
      AppStorage.SetOrCreate('wifiStatus', wifi.isWifiActive());
    })
  }
}

let settingListModel = new SettingListModel();
export default settingListModel as SettingListModel;
