/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import {BrightnessSettingModel} from '../model/displayAndBrightnessImpl/brightness/BrightnessSettingModel';
import {ScreenModeModel} from '../model/displayAndBrightnessImpl/display/ScreenMode';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import {SubEntryComponentWithEndText} from '../../../../../../../common/component/src/main/ets/default/subEntryComponent.ets';
import {SubHeader} from '../../../../../../../common/component/src/main/ets/default/textComponent.ets';


const BRIGHTNESS_MIN_VALUE = 4;
const BRIGHTNESS_MAX_VALUE = 100;
const BRIGHTNESS_STEP_VALUE = 1;

/**
 * brightness setting
 */
@Entry
@Component
struct BrightnessSettings {
  @State brightnessSettingModel:BrightnessSettingModel = new BrightnessSettingModel();
  @State screenModeModel:ScreenModeModel = new ScreenModeModel();
  private TAG = ConfigData.TAG + 'BrightnessSettings ';

  build() {
    Column(){
      GridContainer({columns:12, sizeType: SizeType.Auto, gutter: vp2px(1) === 2 ? '12vp' : '0vp', margin: vp2px(1) === 2 ? '24vp' : '0vp'}) {
        Row({}) {
          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 0 }, sm: { span: 0, offset: 0 },
            md: { span: 0, offset: 0 }, lg: { span: 2, offset: 0 }
          });

          Column() {
            HeadComponent({headName: $r('app.string.brightnessTab'), isActive: true});

            SubHeader({ titleContent: $r('app.string.brightness') })

            Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
              Image($r('app.media.ic_settings_brightness_maximum'))
                .width($r('app.float.wh_value_18'))
                .height($r('app.float.wh_value_18'))
                .objectFit(ImageFit.Contain);
              Slider({
                value: this.brightnessSettingModel.getValue(),
                min: BRIGHTNESS_MIN_VALUE,
                max: BRIGHTNESS_MAX_VALUE,
                step: BRIGHTNESS_STEP_VALUE,
                style: SliderStyle.InSet
              })
                .selectedColor($r('app.color.font_color_007DFF'))
                .blockColor(Color.White)
                .layoutWeight(1)
                .padding({left: $r('app.float.distance_12'), right: $r('app.float.distance_12')})
                .onChange((number, mode:SliderChangeMode) => {
                  this.brightnessSettingModel.setValue(number, mode);
                });
              Image($r('app.media.ic_settings_brightness_maximum'))
                .width($r('app.float.wh_value_24'))
                .height($r('app.float.wh_value_24'))
                .objectFit(ImageFit.Contain);
            }
            .padding({left: $r('sys.float.ohos_id_card_margin_start'), right: $r('sys.float.ohos_id_card_margin_end')})
            .height($r('app.float.distance_64'))
            .width(ConfigData.WH_100_100)
            .borderRadius($r('app.float.radius_24'))
            .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))

            SubHeader({ titleContent: $r('app.string.screen') })

            SubEntryComponentWithEndText({targetPage: "pages/screenMode", title: $r("app.string.screenResolution"), endText: this.screenModeModel.sysScreenModeText})
          }
          .padding({left: $r('app.float.distance_24'), right: $r('app.float.distance_24')})
          .align(Alignment.Center)
          .height(ConfigData.WH_100_100)
          .width(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 12, offset: 0 }, sm: { span: 12, offset: 0 },
            md: { span: 12, offset: 0 }, lg: { span: 8, offset: 2 }
          });

          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 12 }, sm: { span: 0, offset: 12 },
            md: { span: 0, offset: 12 }, lg: { span: 2, offset: 10 }
          })
        }
        .width(ConfigData.WH_100_100)
        .height(ConfigData.WH_100_100);
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100);
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }

  @Log
  private aboutToAppear(): void{
    LogUtil.info(this.TAG + 'aboutToAppear in');
    this.brightnessSettingModel.registerObserver();
    LogUtil.info(this.TAG + 'aboutToAppear out');
  }

  @Log
  private aboutToDisappear(): void{
    LogUtil.info(this.TAG + 'aboutToDisappear in');
    this.brightnessSettingModel.unregisterObserver();
    LogUtil.info(this.TAG + 'aboutToDisappear out');
  }
}