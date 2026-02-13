/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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

import taskpool from '@ohos.taskpool';
import settings from '@ohos.settings';
import lazy { default as Brightness } from '@ohos.brightness';
import dataShare from '@ohos.data.dataShare';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysDisplayEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
/* instrument ignore file */
const SETTINGS_DATA_BRIGHTNESS: string = settings.display.SCREEN_BRIGHTNESS_STATUS;
const AUTO_SCREEN_BRIGHTNESS: string = settings.display.AUTO_SCREEN_BRIGHTNESS;
const AUTO_SCREEN_BRIGHTNESS_ON: string = '1';
const SLIDER_STEP: number = 5;
const TAG: string = 'BrightnessController';
const CHANGE_BRIGHTNESS_SWITCH: string = 'change_brightness_switch';

export class BrightnessController {
  public isStateOn: boolean = false;
  public sliderValue: number = 0;
  private readonly DEFAULT_BRIGHTNESS: string = SystemParamUtil.getParam('const.display.brightness.default', '');
  private readonly MAX_BRIGHTNESS: number = Number(SystemParamUtil.getParam('const.display.brightness.max', ''));
  private readonly MIN_BRIGHTNESS: number = Number(SystemParamUtil.getParam('const.display.brightness.min', ''));
  private readonly SLIDER_STEP_VALUE: number = this.getSliderMax() / SLIDER_STEP;
  private dataHelper: dataShare.DataShareHelper | null = null;
  private isDbDataChange: boolean = true;
  private onDataChange = () => {
    if (this.isDbDataChange) {
      let brightnessVal: number = this.getBrightness();
      LogUtil.info(`${TAG} onDataChange brightnessVal: ${brightnessVal}`);
      let sliderValue = this.countUIValue(brightnessVal);
      this.setSliderValue(sliderValue);
      this.isStateOn = SettingsDataUtils.getSettingsData(settings.display.AUTO_SCREEN_BRIGHTNESS, 
        AUTO_SCREEN_BRIGHTNESS_ON) === AUTO_SCREEN_BRIGHTNESS_ON;
      EventBus.getInstance().emit('auto_brightness_state', this.isStateOn);
    }
  }

  public init(): void {
    LogUtil.info(`${TAG} MAX_BRIGHTNESS ${this.MAX_BRIGHTNESS} min ${this.MIN_BRIGHTNESS}`);
    let sliderValue = this.countUIValue(this.getBrightness());
    this.setSliderValue(sliderValue);
    this.isStateOn = SettingsDataUtils.getSettingsData(settings.display.AUTO_SCREEN_BRIGHTNESS, '1') == '1';
  }

  public getSliderMin(): number {
    return this.MIN_BRIGHTNESS;
  }

  public getSliderMax(): number {
    return this.MAX_BRIGHTNESS;
  }

  public getSliderStep(): number {
    //当前为无障碍模式下，需要调整亮度的步长为5%，非无障碍模式下亮度步长为1
    return AccessibilityUtils.isAccessibilityMode() ? ((this.MAX_BRIGHTNESS - this.MIN_BRIGHTNESS) * 0.05) : 1;
  }

  public getBrightnessRange(): number {
    return this.MAX_BRIGHTNESS - this.MIN_BRIGHTNESS;
  }

  public getSliderRange(): number {
    return this.getSliderMax() - this.getSliderMin();
  }

  public onSliderChange(sliderValue: number, sliderChangeMode: number): void {
    if (sliderChangeMode === SliderChangeMode.Click) {
      return;
    }
    this.isDbDataChange = false;
    let brightnessValue = this.countPhysicsValue(sliderValue);
    let task: taskpool.Task = new taskpool.Task(taskBrightnessSetValue,
      brightnessValue, sliderChangeMode !== SliderChangeMode.End);
    taskpool.execute(task, taskpool.Priority.MEDIUM);
    if (sliderChangeMode === SliderChangeMode.End) {
      this.setSliderValue(sliderValue);
      LogUtil.info(`${TAG} onSliderChange ${sliderValue}`);
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayEventGroup.MANUALLY_ADJUST_BRIGHTNESS,
        sliderValue.toString());
      this.isDbDataChange = true;
    }
  }

  public onStartIconClick(): void {
    let sliderValue = Math.min(this.sliderValue + this.SLIDER_STEP_VALUE, this.getSliderMax());
    LogUtil.info(`${TAG} onStartIconClick: ${this.sliderValue}`);
    let brightnessValue = this.countPhysicsValue(sliderValue);
    Brightness.setValue(brightnessValue);
    this.setSliderValue(sliderValue);
    this.announceText(sliderValue);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayEventGroup.MANUALLY_ADJUST_BRIGHTNESS,
      sliderValue.toString());
  }

  /**
   * 播报进度条百分比
   * @param sliderValue 进度值
   */
  private announceText(sliderValue: number): void {
    if (this.getSliderMax() !== 0) {
      AccessibilityUtils.announceText(Math.round(sliderValue * 100 / this.getSliderMax()) + '%');
    }
  }

  public onEndIconClick(): void {
    let sliderValue = Math.max(this.sliderValue - this.SLIDER_STEP_VALUE, this.getSliderMin());
    LogUtil.info(`${TAG} onEndIconClick: ${this.sliderValue}`);
    let brightnessValue = this.countPhysicsValue(sliderValue);
    Brightness.setValue(brightnessValue);
    this.setSliderValue(sliderValue);
    this.announceText(sliderValue);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayEventGroup.MANUALLY_ADJUST_BRIGHTNESS,
      sliderValue.toString());
  }

  public onToggleChange(isChecked: boolean): boolean {
    this.isStateOn = isChecked;
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayEventGroup.CLICK_BRIGHTNESS_ADJUST_BUTTON,
      isChecked ? 'true' : 'false');
    LogUtil.info(`${TAG} handleCheckedChange isChecked:  ${isChecked}`);
    SettingsDataUtils.setSettingsData(settings.display.AUTO_SCREEN_BRIGHTNESS, isChecked ? '1' : '0');
    if (isChecked) {
      HiSysEventUtil.reportSwitchEvent(CHANGE_BRIGHTNESS_SWITCH, 'on');
    } else {
      HiSysEventUtil.reportSwitchEvent(CHANGE_BRIGHTNESS_SWITCH, 'off');
    }
    return true;
  }

  public onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.registerDataChange();
    let sliderValue = this.countUIValue(this.getBrightness());
    this.setSliderValue(sliderValue);
    this.isStateOn = SettingsDataUtils.getSettingsData(settings.display.AUTO_SCREEN_BRIGHTNESS, '1') == '1';
    EventBus.getInstance().emit('auto_brightness_state', this.isStateOn);
  }

  public onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.unRegisterDataChange();
  }

  private registerDataChange(): void {
    if (this.dataHelper) {
      SettingsDataUtils.registerDataChange(this.dataHelper, SETTINGS_DATA_BRIGHTNESS, this.onDataChange);
      SettingsDataUtils.registerDataChange(this.dataHelper, AUTO_SCREEN_BRIGHTNESS, this.onDataChange);
    } else {
      (SettingsDataUtils.createDataHelper(SETTINGS_DATA_BRIGHTNESS) as
      Promise<dataShare.DataShareHelper>).then((dataShareHelper?: dataShare.DataShareHelper) => {
        if (dataShareHelper) {
          this.dataHelper = dataShareHelper;
          SettingsDataUtils.registerDataChange(this.dataHelper, SETTINGS_DATA_BRIGHTNESS, this.onDataChange);
          SettingsDataUtils.registerDataChange(this.dataHelper, AUTO_SCREEN_BRIGHTNESS, this.onDataChange);
        }
      })
    }
    LogUtil.info(`${TAG} registerDataChange`);
  }

  private unRegisterDataChange(): void {
    SettingsDataUtils.unRegisterDataChange(this.dataHelper as dataShare.DataShareHelper, SETTINGS_DATA_BRIGHTNESS);
    SettingsDataUtils.unRegisterDataChange(this.dataHelper as dataShare.DataShareHelper, AUTO_SCREEN_BRIGHTNESS);
    LogUtil.info(`${TAG} unRegisterDataChange`);
  }

  private setSliderValue(sliderValue: number): void {
    if (this.sliderValue !== sliderValue) {
      this.sliderValue = sliderValue;
      EventBus.getInstance().emit('brightness_slider_value', sliderValue);
    }
  }

  private getBrightness(): number {
    let brightness: string = this.DEFAULT_BRIGHTNESS;
    try {
      brightness = settings.getValueSync((AppStorage.get<Context>('pageContext') as Context),
        SETTINGS_DATA_BRIGHTNESS, this.DEFAULT_BRIGHTNESS);
    } catch (e) {
      LogUtil.error(`${TAG} settings getValueSync err`);
    }
    return Math.min(Number(brightness), this.countPhysicsValue(this.getSliderMax()));
  }

  private countPhysicsValue(uiVar: number): number {
    let brightnessRange = this.getBrightnessRange();
    let sliderRange = this.getSliderRange();
    sliderRange = sliderRange > 0 ? sliderRange : 254;
    let brightness = Math.pow((uiVar - this.getSliderMin()) / sliderRange, 1.8) * brightnessRange + this.MIN_BRIGHTNESS;
    LogUtil.info(`${TAG} uiVar: ${uiVar} countPhysicsValue: ${brightness} brightnessRange: ${brightnessRange}`);
    return Math.round(brightness);
  }

  private countUIValue(britVar: number): number {
    let brightnessRange = this.getBrightnessRange();
    brightnessRange = brightnessRange > 0 ? brightnessRange : 254;
    let sliderRange = this.getSliderRange();
    let percentage = Math.pow(((britVar - this.MIN_BRIGHTNESS) / brightnessRange), 1 / 1.8);
    let brightnessUI = percentage * sliderRange + this.getSliderMin();
    LogUtil.info(`${TAG} britnessVar: ${britVar} countUIValue percentage: ${percentage} ui value: ${brightnessUI}`);
    return brightnessUI;
  }
}

@Concurrent
async function taskBrightnessSetValue(sliderValue: number, continuous: boolean): Promise<void> {
  const TAG: string = 'BrightnessController :';
  try {
    LogUtil.info(`${TAG} taskBrightnessSetValue :${sliderValue} continuous:${continuous}`);
    Brightness.setValue(sliderValue, continuous);
  } catch (e) {
    LogUtil.error(`${TAG} taskBrightnessSetValue error : ${e?.code} - ${e?.message}`);
  }
}