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
import lazy promptAction from '@ohos.promptAction';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { AccessibilitySettingModel } from '@ohos/settings.accessibility/src/main/ets/model/AccessibilitySettingModel';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { SliderConstants } from '../constant/Constants';
import { a11yInitData } from '../sendable/A11yInitData';
/* instrument ignore file */
const TAG: string = 'AudioBalanceController : ';
const TOAST_DURATION: number = 2000;

/**
 * 音量平衡控制器
 *
 * @since 2024-08-07
 */
export class AudioBalanceController {
  public audioBalanceState: number = 0;
  private configObserver = (data: number): void => {
    if (this.audioBalanceState !== data) {
      this.audioBalanceState = data;
      a11yInitData.audioBalanceState = data;
      LogUtil.info(`${TAG} audioBalance state change:${data}`);
      this.refreshUi();
    }
  };

  async init(): Promise<void> {
    LogUtil.info(`${TAG} init, state:${a11yInitData.audioBalanceState}`);
    await this.getAccessibilityConfig();
    this.refreshUi();
    this.registerDataChange();
  }

  public destroy(): void {
    this.unRegisterDataChange();
    LogUtil.info(`${TAG} on destroy`);
  }

  async getAccessibilityConfig(): Promise<void> {
    let result: number = 0;
    try {
      result = await config.audioBalance.get();
      LogUtil.info(`${TAG} reload audioBalanceState success:${result}`);
    } catch (err) {
      LogUtil.error(`${TAG} reload audioBalanceState error: ${err?.message}`);
      return;
    }
    if (this.audioBalanceState !== result) {
      LogUtil.info(`${TAG} audioBalanceState refresh`);
      this.audioBalanceState = result;
      a11yInitData.audioBalanceState = result;
    }
  }

  getSliderMin(): number {
    return SliderConstants.MIN;
  }

  getSliderMax(): number {
    return SliderConstants.MAX;
  }

  getSliderStep(): number {
    return SliderConstants.STEP;
  }

  isShowSteps(): boolean {
    return true;
  }

  /**
   * 保存值
   */
  getSliderValue(): number {
    return this.audioBalanceState * SliderConstants.MULTIPLES;
  }

  public onSliderChange(sliderValue: number, sliderChangeMode: number): void {
    this.setSliderValue(sliderValue);
    LogUtil.info(`${TAG} value: ${sliderValue} SliderChangeMode: ${sliderChangeMode}`);
    if (sliderChangeMode === SliderConstants.MOVING || sliderChangeMode === SliderConstants.END ||
      sliderChangeMode === SliderConstants.CLICK) {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAccessibilityEventGroup.AUDIO_BALANCE_SLIDER_CHANGE,
        (sliderValue / SliderConstants.MULTIPLES).toFixed(2).toString());
      AccessibilitySettingModel.accessibilityAudioBalanceSetting(sliderValue / SliderConstants.MULTIPLES);
    }
    if (sliderChangeMode === SliderConstants.END && sliderValue === SliderConstants.MAX) {
      LogUtil.info(`${TAG} right_mute_toast value: ${sliderValue} SliderChangeMode: ${sliderChangeMode}`);
      promptAction.showToast({
        message: $r('app.string.audio_balance_left_mute_toast'),
        duration: TOAST_DURATION
      });
      return;
    }
    if (sliderChangeMode === SliderConstants.END && sliderValue === SliderConstants.MIN) {
      LogUtil.info(`${TAG} left_mute_toast value: ${sliderValue} SliderChangeMode: ${sliderChangeMode}`);
      promptAction.showToast({
        message: $r('app.string.audio_balance_right_mute_toast'),
        duration: TOAST_DURATION
      });
    }
  }

  setSliderValue(sliderValue: number): void {
    if (this.audioBalanceState * SliderConstants.MULTIPLES !== sliderValue) {
      this.audioBalanceState = sliderValue / SliderConstants.MULTIPLES;
      a11yInitData.audioBalanceState = this.audioBalanceState;
      this.refreshUi();
    }
  }

  protected refreshUi(): void {
    LogUtil.info(`${TAG} refreshUi`);
    EventBus.getInstance().emit('accessiblility_audio_balance_slider_value',
      this.audioBalanceState * SliderConstants.MULTIPLES);
  }

  /**
   * 监听开关的实时状态
   */
  protected registerDataChange(): void {
    try {
      config.audioBalance.on(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed subscribe audioBalance, because ${err?.message}`);
    }
  }

  /**
   * 取消监听开关的实时状态
   */
  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    try {
      config.audioBalance.off(this.configObserver);
    } catch (err) {
      LogUtil.error(`${TAG} failed unsubscribe audioBalance, because ${err?.message}`);
    }
  }
}