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
import { DisplayConstant } from '@ohos/settings.common/src/main/ets/constant/DisplayConstant';
import { EVENT_ID_CONFIGURATION_UPDATE } from '@ohos/settings.common/src/main/ets/event/types';
import settings from '@ohos.settings';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysDisplayBrightnessEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
/* instrument ignore file */
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';

@Component
export struct FontSizeAdjustComponent {
  TAG: string = 'FontSizeAdjustComponent: ';
  @State fontSizeName: Resource = this.getDefaultFontSizeScaleName();
  @Link fontSizeStepVal: number;
  @Link fontSizeScale: number;
  @Link maxFontSizeLevel: number;
  private fontSizeConfigUpdateCallback = () => {
    LogUtil.info(`${this.TAG} received config update event`);
    this.changeFontName();
  };

  aboutToAppear(): void {
    this.registerUpdateConfigEvent();
  }

  aboutToDisappear(): void {
    this.unRegisterUpdateConfigEvent();
  }

  build() {
    this.buildFontSizeItem();
  }

  @Builder
  buildTextTitle(): void {
    Text($r('app.string.screen_zoom_text_size'))
      .fontSize($r('app.float.length_16'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.ohos_id_color_text_primary'))
      .textAlign(TextAlign.Start)
    Text(this.fontSizeName)
      .fontSize($r('app.float.length_14'))
      .fontColor($r('sys.color.ohos_id_color_text_secondary'))
      .fontWeight(FontWeight.Regular)
  }

  @Builder
  buildFontSizeItem(): void {
    Column() {
      Row() {
        this.buildTextTitle();
      }.justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .constraintSize({ minHeight: $r('app.float.length_48')})
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Image($r('app.media.ic_font_size_minuses'))
          .width($r('app.float.length_24'))
          .height($r('app.float.length_24'))
          .draggable(false)
          .fillColor($r('app.color.black'))
          .accessibilityText($r('app.string.toggle_to_smaller'))
          .accessibilityRole(AccessibilityRoleType.BUTTON)
          .onClick(() => {
            this.zoomOutFontSize();
            AccessibilityUtils.announceText(ResourceUtil.getStringSync(this.fontSizeName));
          })
          .responseRegion({ x: -8, y: -8, width: 40, height: 40 })
        Slider({
          style: SliderStyle.InSet,
          value: this.fontSizeStepVal,
          step: DisplayConstant.FONT_SIZE_STEP_NUM,
          max: this.maxFontSizeLevel,
          min: DisplayConstant.MIN_FONT_SIZE
        }).responseRegion({x: 0, y: -6, width: '100%', height: 32})
          .blockColor('#ffffff')
          .height($r('app.float.length_20'))
          .showSteps(true)
          .margin({ left: $r('app.float.length_5'), right: $r('app.float.length_5') })
          .sliderInteractionMode(SliderInteraction.SLIDE_AND_CLICK_UP)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.inputChange(value, mode);
          });
        Image($r('app.media.ic_font_size_add'))
          .width($r('app.float.length_24'))
          .height($r('app.float.length_24'))
          .fillColor($r('app.color.black'))
          .accessibilityText($r('app.string.toggle_to_bigger'))
          .accessibilityRole(AccessibilityRoleType.BUTTON)
          .draggable(false)
          .onClick(() => {
            this.zoomInFontSize();
            AccessibilityUtils.announceText(ResourceUtil.getStringSync(this.fontSizeName));
          })
          .responseRegion({ x: -8, y: -8, width: 40, height: 40 })
      }.constraintSize({ minHeight: $r('app.float.height_40') })
    }
  }

  private registerUpdateConfigEvent(): void {
    EventBus.getInstance().on(EVENT_ID_CONFIGURATION_UPDATE.toString(), this.fontSizeConfigUpdateCallback);
    LogUtil.info(`${this.TAG} registerUpdateConfigEvent`);
  }

  private unRegisterUpdateConfigEvent(): void {
    EventBus.getInstance().detach(EVENT_ID_CONFIGURATION_UPDATE.toString(), this.fontSizeConfigUpdateCallback);
    LogUtil.info(`${this.TAG} unRegisterUpdateConfigEvent`);
  }

  private zoomInFontSize(): void {
    LogUtil.info(`${this.TAG} zoomInFontSize ${this.fontSizeStepVal}, ${this.maxFontSizeLevel}`);
    if (this.fontSizeStepVal >= this.maxFontSizeLevel) {
      LogUtil.info(`${this.TAG} font size is already max`);
      return;
    }
    this.fontSizeStepVal = this.fontSizeStepVal + DisplayConstant.FONT_SIZE_STEP_NUM;
    this.updateFontSizeConfig();
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayBrightnessEventGroup.UPDATE_FONT_SIZE,
      this.fontSizeStepVal.toString());
  }

  private updateFontSizeConfig(): void {
    LogUtil.info(`${this.TAG} updateFontSizeConfig ${this.fontSizeStepVal}`);
    this.changeFontSizeScale();
    this.changeFontName();
  }

  private changeFontName(): Resource {
    switch (this.fontSizeStepVal) {
      case DisplayConstant.TEXT_FONT_SIZE_SMALL_STEP:
        this.fontSizeName = $r('app.string.display_mode_font_size_small');
        break;
      case DisplayConstant.TEXT_FONT_SIZE_NORMAL_STEP:
        this.fontSizeName = $r('app.string.display_mode_font_size_normal');
        break;
      case DisplayConstant.TEXT_FONT_SIZE_LARGE_STEP:
        this.fontSizeName = $r('app.string.display_mode_font_size_large');
        break;
      case DisplayConstant.TEXT_FONT_SIZE_EXTRA_LARGE_STEP:
        this.fontSizeName = $r('app.string.display_mode_font_size_extra_large');
        break;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE_STEP:
        this.fontSizeName = $r('app.string.display_mode_font_size_huge');
        break;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE2_STEP:
        this.fontSizeName = $r('app.string.display_mode_font_size_huge2');
        break;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE3_STEP:
        this.fontSizeName = $r('app.string.display_mode_font_size_huge3');
        break;
      case DisplayConstant.TEXT_FONT_SIZE_HUGE4_STEP:
        this.fontSizeName = $r('app.string.display_mode_font_size_huge4');
        break;
      default:
        this.fontSizeName = $r('app.string.display_mode_font_size_normal');
        break;
    }
    LogUtil.info(`${this.TAG} changeFontName ${this.fontSizeScale}`);
    return this.fontSizeName;
  }

  private changeFontSizeScale(): void {
    switch (this.fontSizeStepVal) {
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

  private zoomOutFontSize(): void {
    LogUtil.info(`${this.TAG} zoomOutFontSize ${this.fontSizeStepVal}`);
    if (this.fontSizeStepVal <= DisplayConstant.MIN_FONT_SIZE) {
      LogUtil.info(`${this.TAG} font size is already min`);
      return;
    }
    this.fontSizeStepVal = this.fontSizeStepVal - DisplayConstant.FONT_SIZE_STEP_NUM;
    this.updateFontSizeConfig();
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayBrightnessEventGroup.UPDATE_FONT_SIZE,
      this.fontSizeStepVal.toString());
  }

  private getDefaultFontSizeScaleName(): Resource {
    let defaultFontSizeScale: number = Number(SettingsDataUtils
      .getSettingsDataDomain(settings.display.FONT_SCALE, DisplayConstant.DEFAULT_FONT_SIZE_SCALE,
      settings.domainName.USER_PROPERTY));
    LogUtil.info(`${this.TAG} getDefaultFontSizeStep ${defaultFontSizeScale}`);
    switch (defaultFontSizeScale) {
      case DisplayConstant.TEXT_FONT_SIZE_SMALL:
        return $r('app.string.display_mode_font_size_small');
      case DisplayConstant.TEXT_FONT_SIZE_NORMAL:
        return $r('app.string.display_mode_font_size_normal');
      case DisplayConstant.TEXT_FONT_SIZE_LARGE:
        return $r('app.string.display_mode_font_size_large');
      case DisplayConstant.TEXT_FONT_SIZE_EXTRA_LARGE:
        return $r('app.string.display_mode_font_size_extra_large');
      case DisplayConstant.TEXT_FONT_SIZE_HUGE:
        return $r('app.string.display_mode_font_size_huge');
      case DisplayConstant.TEXT_FONT_SIZE_HUGE2:
        return $r('app.string.display_mode_font_size_huge2');
      case DisplayConstant.TEXT_FONT_SIZE_HUGE3:
        return $r('app.string.display_mode_font_size_huge3');
      case DisplayConstant.TEXT_FONT_SIZE_HUGE4:
        return $r('app.string.display_mode_font_size_huge4');
      default:
        return $r('app.string.display_mode_font_size_normal');
    }
  }

  private inputChange(value: number, mode: SliderChangeMode): void {
    if (mode === SliderChangeMode.End) {
      LogUtil.info(`${this.TAG} font size slider val ${value}`);
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayBrightnessEventGroup.UPDATE_FONT_SIZE, String(value));
      let valInteger: number = Number.parseInt(value.toString());
      if (this.fontSizeStepVal === valInteger) {
        LogUtil.info(`${this.TAG} font size slider val not change`);
        return;
      }
      this.fontSizeStepVal = valInteger;
      this.updateFontSizeConfig();
    }
  }
}

