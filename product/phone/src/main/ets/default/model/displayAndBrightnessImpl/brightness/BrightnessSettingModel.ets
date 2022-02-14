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

import BaseModel from '../../../../../../../../../common/utils/src/main/ets/default/model/BaseModel.ets';
import ConfigData from '../../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import LogUtil from '../../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import Log from '../../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator.ets';
import settings from '@ohos.settings';
import Brightness from '@ohos.brightness';
import featureAbility from '@ohos.ability.featureAbility';

/**
 * Brightness setting
 *
 * @param brightnessValue - Brightness value
 */
export class BrightnessSettingModel extends BaseModel{
  private dataAbilityHelper;
  private urivar:string;
  private settingsDataKey:string = ConfigData.SETTINGSDATA_BRIGHTNESS;
  private brightness:number = 5;
  private defaultBrightnessStr = '5';
  private TAG = ConfigData.TAG + 'BrightnessSettingModel ';

  constructor() {
    super();
    this.urivar = settings.getUri(this.settingsDataKey);
    this.dataAbilityHelper = featureAbility.acquireDataAbilityHelper(this.urivar);
    this.updateValue();
  }

  /**
   * Get brightness value in the BrightnessSettingModel
   */
  @Log
  public getValue(){
    return this.brightness;
  }

  /**
   * Set value
   */
  @Log
  public setValue(brightness:number, sliderChangeMode:number){
    if(sliderChangeMode === ConfigData.SLIDER_CHANG_MODE_END){
      LogUtil.info(this.TAG + `setValue [brightness:${brightness}, sliderChangeMode:${sliderChangeMode}]`);
      this.setSettingsData(brightness);
    }else{
      this.setSystemBrightness(brightness);
    }
    return;
  }

  /**
   * Set brightness value in the SettingsData
   */
  @Log
  private setSettingsData(brightness:number){
    LogUtil.info(this.TAG + `setSettingsData [brightness:${brightness}]`);
    this.brightness = brightness;
    settings.setValue(this.dataAbilityHelper, this.settingsDataKey, brightness.toString());
    LogUtil.info(this.TAG + `setSettingsData success`);
  }

  /**
   * Set system brightness value
   */
  @Log
  private setSystemBrightness(brightness:number){
    this.brightness = brightness;
    Brightness.setValue(brightness);
    return;
  }

  /**
   * Update brightness value in the BrightnessSettingModel
   */
  @Log
  private updateValue(){
    LogUtil.info(this.TAG + 'updateValue');
    this.brightness = parseInt(settings.getValue(this.dataAbilityHelper, this.settingsDataKey, this.defaultBrightnessStr));
    LogUtil.info(this.TAG + `updateValue success, [brightness:${this.brightness}]`);
    return;
  }

  /**
   * Register observer
   */
  @Log
  public registerObserver(){
    LogUtil.info(this.TAG + 'registerObserver');
    this.dataAbilityHelper.on("dataChange", this.urivar, (err)=>{
      this.updateValue();
    })
    LogUtil.info(this.TAG + 'registerObserver success');
    return;
  }

  /**
   * Unregister observer
   */
  @Log
  public unregisterObserver() {
    LogUtil.info(this.TAG + 'unregisterObserver');
    this.dataAbilityHelper.off("dataChange", this.urivar, (err)=>{
      LogUtil.info(this.TAG + 'unregisterObserver success');
    })
    return;
  }
}