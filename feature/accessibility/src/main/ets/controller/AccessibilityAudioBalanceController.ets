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

import config from '@ohos.accessibility.config';
import { SliderMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { BusinessError } from '@ohos.base';
import { AccessibilitySettingModel } from '../model/AccessibilitySettingModel';
/* instrument ignore file */
const TAG: string = 'AccessibilityAudioBalanceController : ';
const MAX: number = 100;
const MIN: number = -100;
const STEP: number = 20;
const MULTIPLES: number = 100;
const MOVING: number = 1;
const END: number = 2;
const CLICK: number = 3;

/**
 * 音量平衡控制器
 *
 * @since 2023-06-02
 */
export class AccessibilityAudioBalanceController extends SliderMenuController {
  static CreateAccessibilityAudioBalanceController(menu: SettingsBaseMenu): Controller {
    return new AccessibilityAudioBalanceController(menu);
  }

  public audioBalanceState: number;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.audioBalanceState = menu?.extra as number;
  }

  getSliderMin(): number {
    return MIN;
  }

  getSliderMax(): number {
    return MAX;
  }

  getSliderStep(): number {
    return STEP;
  }

  updateStatus(): void {
    this.setSliderValue(this.audioBalanceState * MULTIPLES);
    super.updateStatus();
  }

  public getObserverKey = (): string => {
    return this.menu?.key as string;
  }

  public onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    config.audioBalance.get().then((value)=>{
      this.setSliderValue(value * MULTIPLES);
      LogUtil.info(`${TAG} value: ${value}`);
    })
  }

  public onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  onSliderChange(sliderValue: number, sliderChangeMode: number): boolean {
    this.setSliderValue(sliderValue);
    LogUtil.info(`${TAG} value: ${sliderValue} SliderChangeMode: ${sliderChangeMode}`);
    if (sliderChangeMode === MOVING || sliderChangeMode === END || sliderChangeMode === CLICK) {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(
        HiSysAccessibilityEventGroup.AUDIO_BALANCE_SLIDER_CHANGE, (sliderValue / MULTIPLES).toFixed(2).toString());
      AccessibilitySettingModel.accessibilityAudioBalanceSetting(sliderValue / MULTIPLES);
    }
    return true;
  }

  protected accessibilityAudioBalanceSetting(audioBalance: number): void {
    LogUtil.info(`${TAG} accessibilityConfigSetting config begin: ${audioBalance}`);
    config.audioBalance.set(audioBalance).then(() => {
      LogUtil.info(`${TAG} accessibilityConfigSetting config success: ${audioBalance}`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} accessibilityConfigSetting config fail: ${audioBalance} err: ${err?.message}`);
    });
  }
}
