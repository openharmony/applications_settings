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

import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { BrightnessController } from '../controller/BrightnessController';
/* instrument ignore file */
const MAX_REFRESH_ID: number = 1000;
const TAG: string = 'BrightnessComponent';
const AUTO_ADJUST_SWITCH: string = 'settings.display.AutoAdjustSwitch';

@Component
export struct BrightnessComponent {
  item?:SettingBaseModel;
  private controller: BrightnessController = new BrightnessController();
  @State isAutoAdjustSupport: boolean = false;
  @State isStateOn: boolean = false;
  @State sliderValue: number = 0;
  @State refreshId: number = 1;

  private brightnessSliderCallBack = (value: number) => {
    LogUtil.info(`${TAG} brightness_slider_value value ${value}`);
    this.sliderValue = value;
    this.refreshId++;
    if (this.refreshId > MAX_REFRESH_ID) {
      this.refreshId = 1;
    }
  }

  private brightnessAutoCallBack = (isState: boolean) => {
    LogUtil.info(`${TAG} auto_brightness_state value ${isState}`);
    this.isStateOn = isState;
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.controller.init();
    this.sliderValue = this.controller.sliderValue;
    this.isStateOn = this.controller.isStateOn;
    EventBus.getInstance().on('brightness_slider_value', this.brightnessSliderCallBack);
    let isSupport: boolean = PreferencesUtil.getSync(AUTO_ADJUST_SWITCH, false) as boolean;
    LogUtil.info(`${TAG} PreferencesUtil getSupported autoAdjustSwitch : ${isSupport}`);
    this.isAutoAdjustSupport = isSupport;
    EventBus.getInstance().on('auto_brightness_state', this.brightnessAutoCallBack);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    EventBus.getInstance().detach('brightness_slider_value', this.brightnessSliderCallBack);
    EventBus.getInstance().detach('auto_brightness_state', this.brightnessAutoCallBack);
  }

  @Builder
  autoAdjustBuilder(): void {
    Row() {
      Text($r('app.string.automatic_adjust'))
        .id('automatic_adjust_title')
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Start)
        .wordBreak(WordBreak.BREAK_ALL)
        .flexShrink(0)
        .flexGrow(1)
        .width('80%')

      Toggle({ type: ToggleType.Switch, isOn: this.isStateOn })
        .id('automatic_adjust_toggle')
        .onChange((isOn: boolean) => {
          if (this.isStateOn !== isOn) {
            this.isStateOn = isOn;
            this.controller.onToggleChange(isOn);
          }
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .constraintSize({ minHeight: $r('app.float.height_48') })
    .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6'), bottom: $r('sys.float.padding_level6') })
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Image($r('app.media.ic_brightness_reduce'))
          .id('brightness_reduce_image')
          .fillColor($r('sys.color.font_secondary'))
          .width('24vp')
          .height('24vp')
          .objectFit(ImageFit.Contain)
          .draggable(false)
          .accessibilityText($r('app.string.toggle_to_dark'))
          .accessibilityRole(AccessibilityRoleType.BUTTON)
          .onClick(() => {
            this.controller.onEndIconClick();
          });

        Slider({
          value: this.refreshId ? this.sliderValue : this.sliderValue,
          min: this.controller.getSliderMin(),
          max: this.controller.getSliderMax(),
          step: this.controller.getSliderStep(),
          style: SliderStyle.InSet
        })
          .onChange((value: number, mode: SliderChangeMode) => {
            this.controller.onSliderChange(value, mode);
          })
          .id('brightness_slider')
          .sliderInteractionMode(SliderInteraction.SLIDE_AND_CLICK_UP)
          .selectedColor($r('sys.color.brand'))
          .blockColor('#ffffff')
          .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })

        Image($r('app.media.ic_brightness_plus'))
          .id('brightness_plus_image')
          .fillColor($r('sys.color.font_secondary'))
          .width('24vp')
          .height('24vp')
          .objectFit(ImageFit.Contain)
          .accessibilityText($r('app.string.toggle_to_bright'))
          .accessibilityRole(AccessibilityRoleType.BUTTON)
          .draggable(false)
          .onClick(() => {
            this.controller.onStartIconClick();
          })
      }
      .height('56vp')
      .width('100%')
      .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })

      //zy-20251217-这里判断的时候设备是否支持自动调节，由于没有相关传感器，所以返回的是不支持。
      if (this.isAutoAdjustSupport && !SystemParamUtil.isSimulatorMode) {
        this.autoAdjustBuilder()
      }
    }
    .borderRadius($r('sys.float.corner_radius_level10'))
    .width('100%')
    .padding({ top: $r('sys.float.padding_level2'), bottom: $r('sys.float.padding_level2') })
  }
}