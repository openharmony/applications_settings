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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { EVENT_ID_CONFIGURATION_UPDATE } from '@ohos/settings.common/src/main/ets/event/types';
import settings from '@ohos.settings';
import { DisplayConstant } from '@ohos/settings.common/src/main/ets/constant/DisplayConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysDisplayBrightnessEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { PADDING_16 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
/* instrument ignore file */
import { SliderDrawModifier } from './SliderDrawModifier';

@Component
export struct FontWeightAdjustComponent {
  TAG: string = 'FontWeightAdjustComponent: ';
  private modifier: SliderDrawModifier = new SliderDrawModifier();
  private fontMultiWeightName: Resource = $r('app.string.display_mode_font_weight_multiWeight');
  @State fontWeightName: Resource = this.getDefaultFontWeightScaleName();
  @Link fontWeightStepVal: number;
  @Link fontWeightVal: number;
  @Link maxFontWeightLevel: number;
  @Prop multiWeight: boolean;
  private fontWeightConfigUpdateCallback = () => {
    LogUtil.info(`${this.TAG} received config update event`);
    this.changeFontWeightName();
  };

  aboutToAppear(): void {
    this.registerUpdateConfigEvent();
  }

  aboutToDisappear(): void {
    this.unRegisterUpdateConfigEvent();
  }

  build() {
    this.buildFontWeightItem();
  }

  @Builder
  buildTextTitle(): void {
    Text($r('app.string.screen_zoom_text_weight'))
      .fontSize($r('app.float.length_16'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.ohos_id_color_text_primary'))
      .textAlign(TextAlign.Start)
      .margin({ end: PADDING_16 })
    Text(this.multiWeight ? this.fontWeightName : this.fontMultiWeightName)
      .fontSize($r('app.float.length_14'))
      .fontColor($r('sys.color.ohos_id_color_text_secondary'))
      .fontWeight(FontWeight.Regular)
      .flexShrink(1)
  }

  @Builder
  buildFontWeightItem(): void {
    Column() {
      Row() {
        this.buildTextTitle();
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .constraintSize({ minHeight: $r('app.float.length_48')})

      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Image($r('app.media.ic_font_weight_tiny'))
          .width($r('app.float.length_24'))
          .height($r('app.float.length_24'))
          .draggable(false)
          .fillColor($r('app.color.black'))
          .accessibilityText($r('app.string.toggle_to_thinner'))
          .accessibilityRole(AccessibilityRoleType.BUTTON)
          .onClick(() => {
            this.zoomOutFontWeight();
            AccessibilityUtils.announceText(ResourceUtil.getStringSync(this.fontWeightName));
          })
          .responseRegion({ x: -8, y: -8, width: 40, height: 40 })
          .enabled(this.multiWeight)
          .opacity(this.multiWeight ? 1 : $r('sys.float.ohos_id_alpha_disabled'))
        Slider({
          style: SliderStyle.InSet,
          value: this.fontWeightStepVal,
          step: DisplayConstant.FONT_WEIGHT_STEP_NUM,
          max: DisplayConstant.TEXT_FONT_WEIGHT_BOLDEST,
          min: DisplayConstant.TEXT_FONT_WEIGHT_LIGHTEST
        })
          .responseRegion({ x: 0, y: -6, width: '100%', height: 32 })
          .enabled(this.multiWeight)
          .opacity(this.multiWeight ? 1 : 0.4)
          .drawModifier(this.modifier)
          .onAppear(() => {
            this.modifier.min = DisplayConstant.TEXT_FONT_WEIGHT_LIGHTEST;
            this.modifier.max = DisplayConstant.TEXT_FONT_WEIGHT_BOLDEST;
            this.modifier.default = DisplayConstant.TEXT_FONT_WEIGHT_NORMAL;
            this.modifier.invalidate();
          })
          .blockColor('#ffffff')
          .height($r('app.float.length_20'))
          .showSteps(false)
          .margin({ left: $r('app.float.length_5'), right: $r('app.float.length_5') })
          .sliderInteractionMode(SliderInteraction.SLIDE_AND_CLICK_UP)
          .onChange((value: number) => {
            let weightValue: number = Number(value.toFixed(2));
            LogUtil.info(`${this.TAG} font weight slider val ${weightValue}`);
            if (this.fontWeightStepVal === weightValue) {
              LogUtil.info(`${this.TAG} font weight slider val not change`);
              return;
            }
            this.fontWeightStepVal = weightValue;
            this.updateFontWeightConfig();
          })
          .onClick(() => {
            if (this.fontWeightStepVal > DisplayConstant.TEXT_FONT_WEIGHT_NORMAL_LEFT &&
              this.fontWeightStepVal < DisplayConstant.TEXT_FONT_WEIGHT_NORMAL_RIGHT) {
              LogUtil.info(`${this.TAG} onClick to normal`);
              this.fontWeightStepVal = DisplayConstant.TEXT_FONT_WEIGHT_NORMAL;
              this.updateFontWeightConfig();
            }
          })
        Image($r('app.media.ic_font_weight_thickness'))
          .width($r('app.float.length_24'))
          .height($r('app.float.length_24'))
          .fillColor($r('app.color.black'))
          .draggable(false)
          .accessibilityText($r('app.string.toggle_to_fatter'))
          .accessibilityRole(AccessibilityRoleType.BUTTON)
          .onClick(() => {
            this.zoomInFontWeight();
            AccessibilityUtils.announceText(ResourceUtil.getStringSync(this.fontWeightName));
          })
          .responseRegion({ x: -8, y: -8, width: 40, height: 40 })
          .enabled(this.multiWeight)
          .opacity(this.multiWeight ? 1 : $r('sys.float.ohos_id_alpha_disabled'))
      }
      .constraintSize({ minHeight: $r('app.float.height_40') })
    }
  }

  private registerUpdateConfigEvent(): void {
    EventBus.getInstance().on(EVENT_ID_CONFIGURATION_UPDATE.toString(), this.fontWeightConfigUpdateCallback);
    LogUtil.info(`${this.TAG} registerUpdateConfigEvent`);
  }

  private unRegisterUpdateConfigEvent(): void {
    EventBus.getInstance().detach(EVENT_ID_CONFIGURATION_UPDATE.toString(), this.fontWeightConfigUpdateCallback);
    LogUtil.info(`${this.TAG} unRegisterUpdateConfigEvent`);
  }

  private zoomInFontWeight(): void {
    if (this.fontWeightStepVal >= this.maxFontWeightLevel) {
      LogUtil.info(`${this.TAG} font weight is already max`);
      return;
    }
    LogUtil.info(`${this.TAG} zoom in font weight ${this.fontWeightStepVal}`);
    if (this.fontWeightStepVal >= DisplayConstant.TEXT_FONT_WEIGHT_LIGHTEST &&
      this.fontWeightStepVal < DisplayConstant.TEXT_FONT_WEIGHT_NORMAL) {
      this.fontWeightStepVal = DisplayConstant.TEXT_FONT_WEIGHT_NORMAL;
      this.updateFontWeightConfig();
      return;
    }
    if (this.fontWeightStepVal >= DisplayConstant.TEXT_FONT_WEIGHT_NORMAL &&
      this.fontWeightStepVal < DisplayConstant.TEXT_FONT_WEIGHT_BOLDEST) {
      this.fontWeightStepVal = DisplayConstant.TEXT_FONT_WEIGHT_BOLDEST;
      this.updateFontWeightConfig();
      return;
    }
  }

  private updateFontWeightConfig(): void {
    this.changeFontWeightScale();
    this.changeFontWeightName();
  }

  private changeFontWeightName(): Resource {
    LogUtil.info(`${this.TAG} change font weight name ${this.fontWeightStepVal}`);

    if (this.fontWeightStepVal === DisplayConstant.TEXT_FONT_WEIGHT_LIGHTEST) {
      this.fontWeightName = $r('app.string.display_mode_font_weight_lightest');
      return this.fontWeightName;
    }

    if (this.fontWeightStepVal > DisplayConstant.TEXT_FONT_WEIGHT_LIGHTEST &&
      this.fontWeightStepVal < DisplayConstant.TEXT_FONT_WEIGHT_NORMAL) {
      this.fontWeightName = $r('app.string.display_mode_font_weight_light');
      return this.fontWeightName;
    }

    if (this.fontWeightStepVal === DisplayConstant.TEXT_FONT_WEIGHT_NORMAL) {
      this.fontWeightName = $r('app.string.display_mode_font_weight_normal');
      return this.fontWeightName;
    }

    if (this.fontWeightStepVal > DisplayConstant.TEXT_FONT_WEIGHT_NORMAL &&
      this.fontWeightStepVal < DisplayConstant.TEXT_FONT_WEIGHT_BOLDEST) {
      this.fontWeightName = $r('app.string.display_mode_font_weight_bold');
      return this.fontWeightName;
    }

    if (this.fontWeightStepVal === DisplayConstant.TEXT_FONT_WEIGHT_BOLDEST) {
      this.fontWeightName = $r('app.string.display_mode_font_weight_boldest');
      return this.fontWeightName;
    }
    return $r('app.string.display_mode_font_weight_normal');
  }

  private changeFontWeightScale(): void {
    LogUtil.info(`${this.TAG} change font weight scale ${this.fontWeightStepVal}`);
    this.fontWeightVal = this.fontWeightStepVal;
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayBrightnessEventGroup.UPDATE_FONT_WEIGHT,
      this.fontWeightStepVal.toString());
  }

  private zoomOutFontWeight(): void {
    if (this.fontWeightStepVal <= DisplayConstant.TEXT_FONT_WEIGHT_LIGHTEST) {
      LogUtil.info(`${this.TAG} font weight is already min`);
      return;
    }
    LogUtil.info(`${this.TAG} zoom out font weight ${this.fontWeightStepVal}`);
    if (this.fontWeightStepVal > DisplayConstant.TEXT_FONT_WEIGHT_LIGHTEST &&
      this.fontWeightStepVal <= DisplayConstant.TEXT_FONT_WEIGHT_NORMAL) {
      this.fontWeightStepVal = DisplayConstant.TEXT_FONT_WEIGHT_LIGHTEST;
      this.updateFontWeightConfig();
      return;
    }
    if (this.fontWeightStepVal > DisplayConstant.TEXT_FONT_WEIGHT_NORMAL &&
      this.fontWeightStepVal <= DisplayConstant.TEXT_FONT_WEIGHT_BOLDEST) {
      this.fontWeightStepVal = DisplayConstant.TEXT_FONT_WEIGHT_NORMAL;
      this.updateFontWeightConfig();
      return;
    }
  }

  private getDefaultFontWeightScaleName(): Resource {
    let defaultFontWeightScale: number = Number(SettingsDataUtils
      .getSettingsDataDomain(DisplayConstant.SETTINGS_DATA_FONT_WEIGHT_SCALE, DisplayConstant.DEFAULT_FONT_WEIGHT_SCALE,
      settings.domainName.USER_PROPERTY));
    LogUtil.info(`${this.TAG} getDefaultFontWeightScale ${defaultFontWeightScale}`);

    let fontWeightName: Resource = $r('app.string.display_mode_font_weight_normal');
    if (defaultFontWeightScale === DisplayConstant.TEXT_FONT_WEIGHT_LIGHTEST) {
      fontWeightName = $r('app.string.display_mode_font_weight_lightest');
    }

    if (defaultFontWeightScale > DisplayConstant.TEXT_FONT_WEIGHT_LIGHTEST &&
      defaultFontWeightScale < DisplayConstant.TEXT_FONT_WEIGHT_NORMAL) {
      fontWeightName = $r('app.string.display_mode_font_weight_light');
    }

    if (defaultFontWeightScale === DisplayConstant.TEXT_FONT_WEIGHT_NORMAL) {
      fontWeightName = $r('app.string.display_mode_font_weight_normal');
    }

    if (defaultFontWeightScale > DisplayConstant.TEXT_FONT_WEIGHT_NORMAL &&
      defaultFontWeightScale < DisplayConstant.TEXT_FONT_WEIGHT_BOLDEST) {
      fontWeightName = $r('app.string.display_mode_font_weight_bold');
    }

    if (defaultFontWeightScale === DisplayConstant.TEXT_FONT_WEIGHT_BOLDEST) {
      fontWeightName = $r('app.string.display_mode_font_weight_boldest');
    }
    return fontWeightName;
  }
}

