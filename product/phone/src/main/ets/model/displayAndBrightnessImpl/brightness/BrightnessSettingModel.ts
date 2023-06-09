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

import BaseModel from '../../../../../../../../common/utils/src/main/ets/default/model/BaseModel';
import ConfigData from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import LogUtil from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import settings from '@ohos.settings';
import Brightness from '@ohos.brightness';
import data_dataShare from '@ohos.data.dataShare';
import CatchError from '../../../../../../../../common/utils/src/main/ets/default/baseUtil/CatchError';
import systemParameter from '@ohos.systemparameter';

var mBrightnessValue = AppStorage.SetAndLink('BrightnessValue', 100);
/**
 * Brightness setting
 *
 * @param brightnessValue - Brightness value
 */
export class BrightnessSettingModel extends BaseModel{
  private dataShareHelper;
  private brightness:number = 5;
  private defaultBrightnessStr = this.getDefaultBrightness().toString();
  private TAG = `${ConfigData.TAG} BrightnessSettingModel `;
  private readonly listenUri = 'datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=' + ConfigData.SETTINGSDATA_BRIGHTNESS;

  constructor() {
    super();
    if(!globalThis.settingsAbilityContext){
      LogUtil.info("globalThis.settingsAbilityContext is null");
      return;
    }
    data_dataShare.createDataShareHelper(globalThis.settingsAbilityContext, this.listenUri)
      .then((dataHelper) => {
        this.dataShareHelper = dataHelper;
        LogUtil.info("createDataShareHelper success");
        this.dataShareHelper.on("dataChange", this.listenUri, (error) => {
          LogUtil.info("dataChange success");
          this.updateValue();
        })
      })
    this.updateValue();
  }

  /**
   * Get Uri
   */
  @Log
  public getUri(){
    return this.listenUri;
  }

  /**
   * Get brightness value in the BrightnessSettingModel
   */
  @Log
  public getValue(){
    return this.brightness;
  }

  /**
   * Get min brightness value in the BrightnessSettingModel
   */
  public getMinBrightness(){
    return parseInt(systemParameter.getSync('const.display.brightness.min'))
  }

  /**
   * Get max brightness value in the BrightnessSettingModel
   */
  public getMaxBrightness(){
    return parseInt(systemParameter.getSync('const.display.brightness.max'))
  }

  /**
   * Get default brightness value in the BrightnessSettingModel
   */
  public getDefaultBrightness(){
    return parseInt(systemParameter.getSync('const.display.brightness.default'))
  }

  /**
   * Set value
   */
  @Log
  @CatchError(undefined)
  public setValue(brightness: number, sliderChangeMode: number) {
    this.setSystemBrightness(brightness);
    return;
  }

  /**
   * Set brightness value in the SettingsData
   */
  @Log
  @CatchError(undefined)
  private setSettingsData(brightness:number){
    LogUtil.info(`${this.TAG} setSettingsData [brightness:${brightness}]`);
    this.brightness = brightness;
    settings.setValueSync(globalThis.settingsAbilityContext, ConfigData.SETTINGSDATA_BRIGHTNESS, brightness.toString());
    LogUtil.info(`${this.TAG} setSettingsData success`);
  }

  /**
   * Set system brightness value
   */
  @Log
  private setSystemBrightness(brightness:number){
    this.brightness = brightness;
    mBrightnessValue.set(brightness);
    Brightness.setValue(brightness);
    this.setSettingsData(brightness);
    return;
  }

  /**
   * Update brightness value in the BrightnessSettingModel
   */
  @Log
  @CatchError(undefined)
  private updateValue(){
    LogUtil.info(`${this.TAG} updateValue`);
    this.brightness = parseInt(settings.getValueSync(globalThis.settingsAbilityContext, ConfigData.SETTINGSDATA_BRIGHTNESS, this.defaultBrightnessStr));
    mBrightnessValue.set(this.brightness);
    LogUtil.info(`${this.TAG} updateValue success, [brightness:${this.brightness}]`);
    return;
  }

  /**
   * Register observer
   */
  @Log
  public registerObserver(){
  }

  /**
   * Unregister observer
   */
  @Log
  public unregisterObserver() {
    LogUtil.info(`${this.TAG} unregisterObserver`);
    this.dataShareHelper.off("dataChange", this.listenUri, (err)=>{
      LogUtil.info(`${this.TAG} unregisterObserver success`);
    })
    return;
  }
}