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

/* instrument ignore file */
import taskpool from '@ohos.taskpool';
import Settings from '@ohos.settings';
import Brightness from '@ohos.brightness';
import systemParameter from '@ohos.systemparameter';
import dataShare from '@ohos.data.dataShare';
import { SliderMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysDisplayEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { DisplayUtils } from '../DisplayUtils';

const TAG: string = 'BrightnessController : ';
const SETTINGS_DATA_BRIGHTNESS: string = Settings.display.SCREEN_BRIGHTNESS_STATUS;
const SLIDER_STEP: number = 5;

/**
 * 亮度设置的通用逻辑
 *
 * @since 2022-03-21
 */
export class BrightnessController extends SliderMenuController {
  static CreateBrightnessController(menu: SettingsBaseMenu): Controller {
    return new BrightnessController(menu);
  }

  public static readonly DEFAULT_BRIGHTNESS: string = systemParameter.getSync('const.display.brightness.default');
  public static readonly MAX_BRIGHTNESS: number = Number(systemParameter.getSync('const.display.brightness.max'));
  public static readonly MIN_BRIGHTNESS: number = Number(systemParameter.getSync('const.display.brightness.min'));
  private SLIDER_STEP_VALUE: number = this.getSliderMax() / SLIDER_STEP;
  private dataHelper: dataShare.DataShareHelper | null = null;
  /**
   * 数据库监听回调
   */
  public onDataChange = () => {
    let brightnessVal: number = this.getBrightness();
    LogUtil.info(`${TAG} onDataChange brightnessVal: ${brightnessVal}`);
    let sliderValue = DisplayUtils.countUIValue(brightnessVal);
    this.setSliderValue(sliderValue);
  }

  /**
   * 获取实时亮度
   */
  private getBrightness(): number {
    let brightness: string = SettingsDataUtils.getSettingsData(SETTINGS_DATA_BRIGHTNESS,
      BrightnessController.DEFAULT_BRIGHTNESS);
    return Math.min(Number(brightness), DisplayUtils.countPhysicsValue(this.getSliderMax()));
  }

  getSliderMin(): number {
    return BrightnessController.MIN_BRIGHTNESS;
  }

  getSliderMax(): number {
    return BrightnessController.MAX_BRIGHTNESS;
  }

  getSliderStep(): number {
    return 1;
  }

  public getBrightnessRange(): number {
    return BrightnessController.MAX_BRIGHTNESS - BrightnessController.MIN_BRIGHTNESS;
  }

  public getSliderRange(): number {
    return this.getSliderMax() - this.getSliderMin();
  }

  protected updateSliderValue(): number {
    let brightnessVal: number = this.getBrightness();
    LogUtil.info(`${TAG} updateSliderValue brightnessVal: ${brightnessVal}`);
    return DisplayUtils.countUIValue(brightnessVal);
  }

  onSliderChange(sliderValue: number, sliderChangeMode: number): boolean {
    if (sliderChangeMode !== SliderChangeMode.End) {
      this.unRegisterDataChange();
    }
    let brightnessValue = DisplayUtils.countPhysicsValue(sliderValue);
    let task: taskpool.Task = new taskpool.Task(taskBrightnessSetValue, brightnessValue);
    taskpool.execute(task, taskpool.Priority.MEDIUM);
    if (sliderChangeMode === SliderChangeMode.End) {
      this.registerDataChange();
      this.setSliderValue(sliderValue);
      LogUtil.info(`${TAG} onSliderChange ${sliderValue.toString()}`);
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayEventGroup.MANUALLY_ADJUST_BRIGHTNESS,
        sliderValue.toString());
    }
    return true;
  }

  protected registerDataChange(): void {
    if (this.dataHelper) {
      SettingsDataUtils.registerDataChange(this.dataHelper, SETTINGS_DATA_BRIGHTNESS, this.onDataChange);
    } else {
      (SettingsDataUtils.createDataHelper(SETTINGS_DATA_BRIGHTNESS) as
      Promise<dataShare.DataShareHelper>).then((dataShareHelper?: dataShare.DataShareHelper) => {
        if (dataShareHelper) {
          this.dataHelper = dataShareHelper;
          SettingsDataUtils.registerDataChange(this.dataHelper, SETTINGS_DATA_BRIGHTNESS, this.onDataChange);
        }
      })
    }
    LogUtil.info(`${TAG} listen on`);
  }

  protected unRegisterDataChange(): void {
    SettingsDataUtils.unRegisterDataChange(this.dataHelper as dataShare.DataShareHelper, SETTINGS_DATA_BRIGHTNESS);
    LogUtil.info(`${TAG} listen off`);
  }

  onStartIconClick(): void {
    this.sliderValue = Math.max(this.sliderValue - this.SLIDER_STEP_VALUE, this.getSliderMin());
    LogUtil.info(`${TAG} onStartIconClick: ${this.sliderValue}`);
    let brightnessValue = DisplayUtils.countPhysicsValue(this.sliderValue);
    Brightness.setValue(brightnessValue);
    this.setSliderValue(this.sliderValue);
  }

  onEndIconClick(): void {
    this.sliderValue = Math.min(this.sliderValue + this.SLIDER_STEP_VALUE, this.getSliderMax());
    LogUtil.info(`${TAG} onEndIconClick: ${this.sliderValue}`);
    let brightnessValue = DisplayUtils.countPhysicsValue(this.sliderValue);
    Brightness.setValue(brightnessValue);
    this.setSliderValue(this.sliderValue);
  }
}

@Concurrent
async function taskBrightnessSetValue(sliderValue: number): Promise<void> {
  const TAG: string = 'BrightnessController :';
  Brightness.setValue(sliderValue);
  LogUtil.info(`${TAG} taskBrightnessSetValue :${sliderValue}`)
}