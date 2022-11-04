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
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import deviceInfo from '@ohos.deviceInfo';
import settings from '@ohos.settings';
import CatchError from '../../../../../../../common/utils/src/main/ets/default/baseUtil/CatchError';

/**
 * about device service class
 */
export class AboutDeviceModel extends BaseModel {
  private deviceInfo: BaseModel[] = [
    {
      settingAlias: "model",
      settingTitle: "",
      settingValue: ""
    },
    {
      settingAlias: "companyInfo",
      settingTitle: "",
      settingValue: ""
    },
    {
      settingAlias: "deviceId",
      settingTitle: "",
      settingValue: "00000000000000"
    },
    {
      settingAlias: "softwareVersion",
      settingTitle: "",
      settingValue: ""
    }
  ]

  constructor(){
    super();
  }

  /**
   * Get Uri
   */
  @Log
  @CatchError(`dataability:///com.ohos.settingsdata.DataAbility/${ConfigData.SETTINGSDATA_DEVICE_NAME}`)
  public getUri(){
    return settings.getUriSync(ConfigData.SETTINGSDATA_BRIGHTNESS);
  }

  /**
   * Get phone information
   */
  @Log
  setOnAboutDeviceListener(): any {
    LogUtil.info('settings setOnAboutDeviceListener in');
    LogUtil.info('settings setOnAboutDeviceListener deviceInfo ' + JSON.stringify(deviceInfo));
    return deviceInfo;
  }

  /**
  * Read local file
  */
  @Log
  public getAboutDeviceInfoListener(): any[] {
    LogUtil.info('settings getAboutDeviceInfoListener come in');
    return this.deviceInfo;
  }

  /**
  * Get system name from SettingsData
  */
  @Log
  @CatchError(ConfigData.DEVICE_NAME)
  getSystemName(){
    let deviceName = settings.getValueSync(globalThis.settingsAbilityContext, ConfigData.SETTINGSDATA_DEVICE_NAME, ConfigData.DEVICE_NAME);
    return deviceName;
  }

  /**
  * Set system name to SettingsData
  */
  @Log
  @CatchError(undefined)
  setSystemName(name: string){
    settings.setValueSync(globalThis.settingsAbilityContext, ConfigData.SETTINGSDATA_DEVICE_NAME, name);
    return;
  }
}

let aboutDeviceModel = new AboutDeviceModel();
export default aboutDeviceModel as AboutDeviceModel
;