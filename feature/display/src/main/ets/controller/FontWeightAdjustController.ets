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
import { BusinessError } from '@ohos.base';
import emitter from '@ohos.events.emitter';
import Settings from '@ohos.settings';
import uiAppearance from '@ohos.uiAppearance';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { DisplayConstant } from '@ohos/settings.common/src/main/ets/constant/DisplayConstant';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SliderMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { EVENT_ID_CONFIGURATION_UPDATE } from '@ohos/settings.common/src/main/ets/event/types';

const TAG: string = 'FontWeightAdjustController : ';

/**
 * 字体粗细设置的通用逻辑
 *
 * @since 2024-04-17
 */
export class FontWeightAdjustController extends SliderMenuController {
  static CreateFontSizeAdjustController(menu: SettingsBaseMenu): Controller {
    return new FontWeightAdjustController(menu);
  }

  private inSetValue: number = DisplayConstant.DEFAULT_FONT_WEIGHT;
  private fontWeightScale: number = Number(SettingsDataUtils
    .getSettingsDataDomain(DisplayConstant.SETTINGS_DATA_FONT_WEIGHT_SCALE, DisplayConstant.DEFAULT_FONT_WEIGHT_SCALE,
      Settings.domainName.USER_PROPERTY));
  private maxVal: number = DisplayConstant.TEXT_FONT_WEIGHT_BOLDEST;
  private minVal: number = DisplayConstant.TEXT_FONT_WEIGHT_LIGHTEST;

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
    return DisplayConstant.FONT_WEIGHT_STEP_NUM;
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
    LogUtil.info(`${TAG} font weight slider val ${sliderValue}`);
    let valInteger: number = Number(sliderValue.toFixed(2));
    if (this.inSetValue === valInteger) {
      LogUtil.info(`${TAG} font weight slider val not change`);
      return true;
    }
    this.inSetValue = valInteger;
    LogUtil.info(`${TAG} font weight slider inSetValue ${this.inSetValue}`);
    this.updateFontWeightConfig();
    return true;
  }

  onStartIconClick() : void {
    this.zoomOutFontWeight();
  }

  onEndIconClick() : void {
    this.zoomInFontWeight();
  }

  private zoomOutFontWeight(): void {
    LogUtil.info(`${TAG} onReduceClick`);
    if (this.inSetValue <= this.minVal) {
      LogUtil.info(`${TAG} font weight is already min`);
      return;
    }
    LogUtil.info(`${TAG} zoom out font weight ${this.inSetValue}`);
    if (this.inSetValue > DisplayConstant.TEXT_FONT_WEIGHT_LIGHTEST &&
      this.inSetValue <= DisplayConstant.TEXT_FONT_WEIGHT_NORMAL) {
      this.inSetValue = DisplayConstant.TEXT_FONT_WEIGHT_LIGHTEST;
      this.updateFontWeightConfig();
      return;
    }
    if (this.inSetValue > DisplayConstant.TEXT_FONT_WEIGHT_NORMAL &&
      this.inSetValue <= DisplayConstant.TEXT_FONT_WEIGHT_BOLDEST) {
      this.inSetValue = DisplayConstant.TEXT_FONT_WEIGHT_NORMAL;
      this.updateFontWeightConfig();
      return;
    }
  }

  private zoomInFontWeight(): void {
    if (this.inSetValue >= this.maxVal) {
      LogUtil.info(`${TAG} font weight is already max`);
      return;
    }
    LogUtil.info(`${TAG} zoom in font weight ${this.inSetValue}`);
    if (this.inSetValue >= DisplayConstant.TEXT_FONT_WEIGHT_LIGHTEST &&
      this.inSetValue < DisplayConstant.TEXT_FONT_WEIGHT_NORMAL) {
      this.inSetValue = DisplayConstant.TEXT_FONT_WEIGHT_NORMAL;
      this.updateFontWeightConfig();
      return;
    }
    if (this.inSetValue >= DisplayConstant.TEXT_FONT_WEIGHT_NORMAL &&
      this.inSetValue < DisplayConstant.TEXT_FONT_WEIGHT_BOLDEST) {
      this.inSetValue = DisplayConstant.TEXT_FONT_WEIGHT_BOLDEST;
      this.updateFontWeightConfig();
      return;
    }
  }

  private updateFontWeightConfig(): void {
    this.changeFontWeightScale();
    try {
      uiAppearance.setFontWeightScale(this.fontWeightScale);
      LogUtil.info(`${TAG} updateConfiguration success, ${this.fontWeightScale}`);
      SettingsDataUtils.setSettingsDataDomain(DisplayConstant.SETTINGS_DATA_FONT_WEIGHT_SCALE,
        this.fontWeightScale.toString(), Settings.domainName.USER_PROPERTY);
    } catch (paramError) {
      let code: number = (paramError as BusinessError).code;
      let message: string = (paramError as BusinessError).message;
      LogUtil.error(`${TAG} error.code: ${code}, error.message: ${message}`);
    }
  }

  private changeFontWeightScale(): void {
    this.fontWeightScale = this.inSetValue;
  }

  private initialPage(): void {
    this.inSetValue = this.fontWeightScale;
    LogUtil.info(`${TAG} initialPage inSetValue: ${this.inSetValue}`);
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
