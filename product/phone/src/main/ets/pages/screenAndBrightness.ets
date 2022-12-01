/**
 * Copyright (c) 2021-2022 Huawei Device Co., Ltd.
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

import { ScreenModeModel } from '../model/displayAndBrightnessImpl/display/ScreenMode';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import { SubHeader } from '../../../../../../common/component/src/main/ets/default/textComponent';
import { BrightnessSettingModel } from '../model/displayAndBrightnessImpl/brightness/BrightnessSettingModel';

const BRIGHTNESS_STEP_VALUE = 1;

/**
 * brightness setting
 */
@Entry
@Component
struct BrightnessSettings {
  @State brightnessSettingModel: BrightnessSettingModel = new BrightnessSettingModel();
  @StorageLink('BrightnessValue') brightnessValue: number = 0;
  private TAG = ConfigData.TAG + 'BrightnessSettings ';

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.brightnessTab'), isActive: true });

          SubHeader({ titleContent: $r('app.string.brightness') });

          Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
            Image($r('app.media.ic_settings_brightness_maximum'))
              .padding("3vp")
              .width($r('app.float.wh_value_24'))
              .height($r('app.float.wh_value_24'))
              .objectFit(ImageFit.Contain)
              .fillColor($r("sys.color.ohos_id_color_primary"))
              .opacity($r("sys.float.ohos_fa_alpha_content_secondary"))

            Slider({
              value: this.brightnessValue,
              min: this.brightnessSettingModel.getMinBrightness(),
              max: this.brightnessSettingModel.getMaxBrightness(),
              step: BRIGHTNESS_STEP_VALUE,
              style: SliderStyle.InSet
            })
              .selectedColor($r('app.color.font_color_007DFF'))
              .blockColor(Color.White)
              .layoutWeight(ConfigData.LAYOUT_WEIGHT_1)
              .padding({ left: $r('app.float.distance_12'), right: $r('app.float.distance_12') })
              .onChange((number, mode: SliderChangeMode) => {
                this.brightnessSettingModel.setValue(number, mode);
              });

            Image($r('app.media.ic_settings_brightness_maximum'))
              .width($r('app.float.wh_value_24'))
              .height($r('app.float.wh_value_24'))
              .objectFit(ImageFit.Contain)
              .fillColor($r("sys.color.ohos_id_color_primary"))
              .opacity($r("sys.float.ohos_fa_alpha_content_secondary"))
          }
          .padding({
            left: $r('sys.float.ohos_id_card_margin_start'),
            right: $r("sys.float.ohos_id_card_margin_end")
          })
          .height($r('app.float.distance_64'))
          .width(ConfigData.WH_100_100)
          .borderRadius($r('app.float.radius_24'))
          .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))

          SubHeader({ titleContent: $r('app.string.screen') })

          ScreenModelComponent()
        }
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 }
        })
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100)
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
  }

  @Log
  aboutToAppear(): void{
    LogUtil.info(this.TAG + 'aboutToAppear in');
    this.brightnessSettingModel.registerObserver();
    LogUtil.info(this.TAG + 'aboutToAppear out');
  }

  @Log
  aboutToDisappear(): void{
    LogUtil.info(this.TAG + 'aboutToDisappear in');
    this.brightnessSettingModel.unregisterObserver();
    LogUtil.info(this.TAG + 'aboutToDisappear out');
  }
}


/**
 * Sub-Page Entry Component with EndText
 */
@Component
export struct ScreenModelComponent {
  @State isTouched: boolean = false;
  @StorageLink('sysScreenModeText') sysScreenModeText: string = '';
  @State screenModeModel: ScreenModeModel = new ScreenModeModel();

  build() {
    Navigator({ target: "pages/screenMode" }) {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text($r("app.string.screenResolution"))
          .fontSize($r('app.float.font_16'))
          .lineHeight($r('app.float.wh_value_22'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r("sys.color.ohos_id_color_text_primary"))
          .margin({ left: $r('app.float.distance_8') })
          .textAlign(TextAlign.Start);

        Row() {
          Text(this.sysScreenModeText)
            .fontSize($r('app.float.font_14'))
            .lineHeight($r('app.float.wh_value_19'))
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .opacity($r("sys.float.ohos_fa_alpha_content_secondary"))
            .margin({ right: $r('app.float.distance_4') })
            .textAlign(TextAlign.End);

          Image('/res/image/ic_settings_arrow.svg')
            .width($r('app.float.wh_value_12'))
            .height($r('app.float.wh_value_24'))
            .margin({ right: $r('app.float.distance_8') })
            .fillColor($r("sys.color.ohos_id_color_primary"))
            .opacity($r("sys.float.ohos_fa_alpha_content_fourth"))
        }
      }
      .height(ConfigData.WH_100_100)
      .width(ConfigData.WH_100_100)
      .borderRadius($r('app.float.radius_20'))
      .linearGradient(this.isTouched ? {
                                         angle: 90,
                                         direction: GradientDirection.Right,
                                         colors: [[$r("app.color.DCEAF9"), 0.0], [$r("app.color.FAFAFA"), 1.0]]
                                       } : {
                                             angle: 90,
                                             direction: GradientDirection.Right,
                                             colors: [[$r("sys.color.ohos_id_color_foreground_contrary"), 1], [$r("sys.color.ohos_id_color_foreground_contrary"), 1]]
                                           })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.isTouched = true;
        }

        if (event.type === TouchType.Up) {
          this.isTouched = false;
        }
      });
    }
    .padding($r('app.float.distance_4'))
    .height($r('app.float.wh_value_56'))
    .borderRadius($r('app.float.radius_24'))
    .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"));
  }
}