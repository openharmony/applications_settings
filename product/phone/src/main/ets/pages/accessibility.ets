/**
 * Copyright (c) 2023-2023 Huawei Device Co., Ltd.
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
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import { SubHeader } from '../../../../../../common/component/src/main/ets/default/textComponent';
import { AccessibilitySettingModel } from '../model/accessibilityImpl/AccessibilitySettingModel';

const AUDIO_BALANCE_STEP_VALUE: number = 1;
const AUDIO_BALANCE_MIN_VALUE: number = -100;
const AUDIO_BALANCE_MAX_VALUE: number = 100;

/**
 * accessibility setting
 */
@Entry
@Component
struct AccessibilitySettings {
  @State highContrastTextIsOn: boolean = false;
  @State audioMonoIsOn: boolean = false;
  @State inSetValueAudioBalance: number = 0;
  private TAG = ConfigData.TAG + 'AccessibilitySettings ';

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.accessibility'), isActive: true });

          SubHeader({ titleContent: $r('app.string.visual_accessibility') });

          Column() {
            Row() {
              Text($r('app.string.highContrast_text'))
                .fontSize($r('sys.float.ohos_id_text_size_body1'))
                .fontColor($r('sys.color.ohos_id_color_text_primary'))
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start);

              Blank();

              Toggle({ type: ToggleType.Switch, isOn: this.highContrastTextIsOn })
                .width('36vp')
                .height('20vp')
                .selectedColor('#007DFF')
                .onChange((isOn: boolean) => {
                  this.setHighContrastTextState(isOn);
                });
            }
            .height($r('app.float.wh_value_56'))
            .width(ConfigData.WH_100_100)
            .alignItems(VerticalAlign.Center)
            .padding({ left: $r("app.float.wh_value_12"), right: $r('app.float.wh_value_6') })
            .backgroundColor($r("app.color.white_bg_color"))
            .borderRadius($r('app.float.radius_24'));
          }
          .height($r('app.float.wh_value_56'))
          .width(ConfigData.WH_100_100)
          .borderRadius($r('app.float.radius_24'))
          .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))

          SubHeader({ titleContent: $r('app.string.audio_accessibility') });

          Column() {
            Row() {
              Text($r('app.string.single_audio'))
                .fontSize($r('sys.float.ohos_id_text_size_body1'))
                .fontColor($r('sys.color.ohos_id_color_text_primary'))
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start);

              Blank();

              Toggle({ type: ToggleType.Switch, isOn: this.audioMonoIsOn })
                .width('36vp')
                .height('20vp')
                .selectedColor('#007DFF')
                .onChange((isOn: boolean) => {
                  this.setAudioMonoState(isOn);
                });
            }
            .height($r('app.float.wh_value_56'))
            .width(ConfigData.WH_100_100)
            .alignItems(VerticalAlign.Center)
            .padding({ left: $r("app.float.wh_value_12"), right: $r('app.float.wh_value_6') })
            .backgroundColor($r("app.color.white_bg_color"))
            .borderRadius($r('app.float.radius_24'));

            Row() {
              Text($r('app.string.audio_balance'))
                .fontSize($r('sys.float.ohos_id_text_size_body1'))
                .fontColor($r('sys.color.ohos_id_color_text_primary'))
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start);
            }
            .height($r('app.float.wh_value_20'))
            .width(ConfigData.WH_100_100)
            .alignItems(VerticalAlign.Center)
            .padding({ left: $r("app.float.wh_value_12"), right: $r('app.float.wh_value_6') })
            .backgroundColor($r("app.color.white_bg_color"));

            Row() {
              Column() {
                Slider({
                  value: this.inSetValueAudioBalance,
                  min: AUDIO_BALANCE_MIN_VALUE,
                  max: AUDIO_BALANCE_MAX_VALUE,
                  step: AUDIO_BALANCE_STEP_VALUE,
                  style: SliderStyle.OutSet,
                })
                  .selectedColor($r('app.color.font_color_007DFF'))
                  .blockColor(Color.Blue)
                  .height($r('app.float.wh_value_20'))
                  .borderRadius($r('app.float.radius_24'))
                  .onChange((value: number, mode: SliderChangeMode) => {
                    this.setAudioBalanceValue(value, mode);
                  });

                Row() {
                  Text($r('app.string.left'))
                    .fontSize($r('app.float.font_14'))
                    .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                    .lineHeight($r("app.float.wh_value_20"))
                    .textAlign(TextAlign.Start);

                  Blank();

                  Text($r('app.string.right'))
                    .fontSize($r('app.float.font_14'))
                    .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                    .lineHeight($r("app.float.wh_value_20"))
                    .textAlign(TextAlign.End);
                }
                .width(ConfigData.WH_100_100)
                .alignItems(VerticalAlign.Center)
                .padding({ left: $r('app.float.wh_value_6'), right: $r('app.float.wh_value_6') })
                .backgroundColor($r("app.color.white_bg_color"));
              }
              .width(ConfigData.WH_100_100);
            }
            .height($r('app.float.wh_value_56'))
            .width(ConfigData.WH_100_100)
            .alignItems(VerticalAlign.Center)
            .padding({ left: $r('app.float.wh_value_6'), right: $r('app.float.wh_value_6') })
            .backgroundColor($r("app.color.white_bg_color"))
            .borderRadius($r('app.float.radius_24'));
          }
          .width(ConfigData.WH_100_100)
          .borderRadius($r('app.float.radius_24'))
          .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"));

          Text($r('app.string.audio_balance_suggestion'))
            .width(ConfigData.WH_100_100)
            .fontSize($r('app.float.font_14'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .height($r("app.float.wh_value_52"))
            .lineHeight($r("app.float.wh_value_20"))
            .padding({
              left: $r('app.float.wh_value_12'),
              top: $r('app.float.distance_4'),
              bottom: $r('app.float.distance_24'),
            });
        }
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 }
        });
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100);
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  };

  setHighContrastTextState(isOn: boolean): void {
    LogUtil.info(this.TAG + 'setHighContrastTextState ' + isOn);
    if (isOn) {
      this.highContrastTextIsOn = true;
      AccessibilitySettingModel.accessibilityConfigSetting('highContrastText', true);
    } else {
      this.highContrastTextIsOn = false;
      AccessibilitySettingModel.accessibilityConfigSetting('highContrastText', false);
    }
  }

  setAudioMonoState(isOn: boolean): void {
    LogUtil.info(this.TAG + 'setAudioMonoState ' + isOn);
    if (isOn) {
      this.audioMonoIsOn = true;
      AccessibilitySettingModel.accessibilityConfigSetting('audioMono', true);
    } else {
      this.audioMonoIsOn = false;
      AccessibilitySettingModel.accessibilityConfigSetting('audioMono', false);
    }
  }

  setAudioBalanceValue(audioBalance: number, mode: SliderChangeMode): void {
    LogUtil.info(this.TAG + 'setAudioBalanceValue ' + audioBalance + mode);
    if (mode == SliderChangeMode.End || mode == SliderChangeMode.Click) {
      AccessibilitySettingModel.accessibilityAudioBalanceSetting(audioBalance / 100);
    }
  }

  @Log
  aboutToAppear(): void{
    LogUtil.info(this.TAG + 'aboutToAppear in');
    config.highContrastText.get().then((data) => {
      LogUtil.info(this.TAG + 'get highContrastText switch success');
      this.highContrastTextIsOn = data;
    }).catch((err) => {
      LogUtil.error(this.TAG +  'failed to get highContrastText switch, because' + JSON.stringify(err));
    });

    config.audioMono.get().then((data) => {
      this.audioMonoIsOn = data;
      LogUtil.info(this.TAG + 'get audioMono success');
    }).catch((err) => {
      LogUtil.error(this.TAG + 'failed to get audioMono, because ' + JSON.stringify(err));
    });

    config.audioBalance.get().then((data) => {
      this.inSetValueAudioBalance = data * 100;
      LogUtil.info(this.TAG + 'get audioBalance success');
    }).catch((err) => {
      LogUtil.error(this.TAG + 'failed to get audioBalance, because ' + JSON.stringify(err));
    });

    LogUtil.info(this.TAG + 'aboutToAppear out');
  }

  @Log
  aboutToDisappear(): void{
    LogUtil.info(this.TAG + 'aboutToDisappear');
  }
}