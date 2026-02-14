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

import { BusinessError } from '@ohos.base';
import emitter from '@ohos.events.emitter';
import Settings from '@ohos.settings';
import uiAppearance from '@ohos.uiAppearance';
import { SliderMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { DisplayConstant } from '@ohos/settings.common/src/main/ets/constant/DisplayConstant';
import { EVENT_ID_CONFIGURATION_UPDATE } from '@ohos/settings.common/src/main/ets/event/types';
import { DisplayUtils } from '../DisplayUtils';

const TAG: string = 'FontSizeAdjustController : ';

/**
 * 字体大小设置的通用逻辑
 *
 * @since 2024-04-17
 */
export class FontSizeAdjustController extends SliderMenuController {
  static CreateFontSizeAdjustController(menu: SettingsBaseMenu): Controller {
    return new FontSizeAdjustController(menu);
  }

  private inSetValue: number = DisplayConstant.DEFAULT_FONT_SIZE_STEP;
  private fontSizeScale: number = Number(SettingsDataUtils
    .getSettingsDataDomain(Settings.display.FONT_SCALE, DisplayConstant.DEFAULT_FONT_SIZE_SCALE,
      Settings.domainName.USER_PROPERTY));
  private maxVal: number = DisplayConstant.MAX_FONT_SIZE_LEVEL;
  private minVal: number = DisplayConstant.MIN_FONT_SIZE;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.initialPage();
  }

  getSliderMin(): number {
    return this.minVal;
  }

  getSliderMax(): number {
    return this.maxVal;
  }

  getSliderStep(): number {
    return DisplayConstant.FONT_SIZE_STEP_NUM;
  }

  /**
   * 保存值
   */
  getSliderValue(): number {
    return this.inSetValue;
  }

  protected updateSliderValue(): number {
    return this.inSetValue;
  }

  onSliderChange(sliderValue: number): boolean {
    LogUtil.info(`${TAG} font size slider val ${sliderValue}`);
    let valInteger: number = Number.parseInt(sliderValue.toString());
    if (this.inSetValue === valInteger) {
      LogUtil.info(`${TAG} font size slider val not change`);
      return true;
    }
    this.inSetValue = valInteger;
    this.updateFontSizeConfig();
    return true;
  }

  onStartIconClick() : void {
    LogUtil.info(`${TAG} onReduceClick`);
    if (this.inSetValue <= DisplayConstant.MIN_FONT_SIZE) {
      LogUtil.info(`${TAG} inSetValue is already min`);
      return;
    }
    this.inSetValue -= DisplayConstant.FONT_SIZE_STEP_NUM;
    LogUtil.info(`${TAG} this.inSetValue: ${this.inSetValue}`);
    this.updateFontSizeConfig();
  }

  onEndIconClick() : void {
    LogUtil.info(`${TAG} onIncreaseClick`);
    if (this.inSetValue >= this.maxVal) {
      LogUtil.info(`${TAG} inSetValue is already max`);
      return;
    }
    this.inSetValue += DisplayConstant.FONT_SIZE_STEP_NUM;
    LogUtil.info(`${TAG} this.inSetValue: ${this.inSetValue}`);
    this.updateFontSizeConfig();
  }

  private updateFontSizeConfig(): void {
    this.changeFontSizeScale();
    try {
      uiAppearance.setFontScale(this.fontSizeScale);
      LogUtil.info(`${TAG} updateConfiguration success, ${this.fontSizeScale}`);
      SettingsDataUtils.setSettingsDataDomain(Settings.display.FONT_SCALE,
        this.fontSizeScale.toString(), Settings.domainName.USER_PROPERTY);
    } catch (paramError) {
      LogUtil.error(`${TAG} error.message: ${(paramError as BusinessError).message}`);
    }
  }

  private changeFontSizeScale(): void {
    switch (this.inSetValue) {
      case DisplayConstant.TEXT_FONT_SIZE_SMALL_STEP:
        this.fontSizeScale = DisplayConstant.TEXT_FONT_SIZE_SMALL;
        break;
      case DisplayConstant.TEXT_FONT_SIZE_NORMAL_STEP:
        this.fontSizeScale = DisplayConstant.TEXT_FONT_SIZE_NORMAL;
        break;
      case DisplayConstant.TEXT_FONT_SIZE_LARGE_STEP:
        this.fontSizeScale = DisplayConstant.TEXT_FONT_SIZE_LARGE;
        break;
      case DisplayConstant.TEXT_FONT_SIZE_EXTRA_LARGE_STEP:
        this.fontSizeScale = DisplayConstant.TEXT_FONT_SIZE_EXTRA_LARGE;
        break;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE_STEP:
        this.fontSizeScale = DisplayConstant.TEXT_FONT_SIZE_HUGE;
        break;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE2_STEP:
        this.fontSizeScale = DisplayConstant.TEXT_FONT_SIZE_HUGE2;
        break;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE3_STEP:
        this.fontSizeScale = DisplayConstant.TEXT_FONT_SIZE_HUGE3;
        break;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE4_STEP:
        this.fontSizeScale = DisplayConstant.TEXT_FONT_SIZE_HUGE4;
        break;
      default:
        this.fontSizeScale = DisplayConstant.TEXT_FONT_SIZE_NORMAL;
        break;
    }
  }

  private initialPage(): void {
    this.inSetValue = DisplayUtils.getDefaultFontSizeStep(this.fontSizeScale);
    LogUtil.info(`${TAG} this.inSetValue: ${this.inSetValue}`);
  }

  aboutToAppear(): void {
    this.registerUpdateConfigEvent();
  }

  aboutToDisappear(): void {
    this.unRegisterUpdateConfigEvent();
  }

  private registerUpdateConfigEvent(): void {
    emitter.on({ eventId: EVENT_ID_CONFIGURATION_UPDATE }, () => {
      LogUtil.info(`${TAG} received config update event`);
    })
    LogUtil.info(`${TAG} registerUpdateConfigEvent`);
  }

  private unRegisterUpdateConfigEvent(): void {
    emitter.off(EVENT_ID_CONFIGURATION_UPDATE);
    LogUtil.info(`${TAG} unRegisterUpdateConfigEvent`);
  }
}
