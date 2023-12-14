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
 * limitations under the License.   clickResponseTime   ignoreRepeatClick
 */

import config from '@ohos.accessibility.config';
import { BusinessError } from '@ohos.base';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import { AccessibilitySettingModel } from '../model/accessibilityImpl/AccessibilitySettingModel';

const TAG = ConfigData.TAG + 'AccessibilityScreenTouch: ';
const BASIC_SUSTAIN_DURATION_SHORT = 'Short';
const BASIC_SUSTAIN_DURATION_CENTRE = 'Medium';
const BASIC_SUSTAIN_DURATION_LONG = 'Long';

@Entry
@Component
struct AccessibilityScreenTouch {
  @State clickResponseTimeText: string = '';
  @State checked: config.ClickResponseTime = 'Short';
  @State ignoreRepeatClickIsOn: boolean = false;
  @State ignoreRepeatClickTimeText: string = '';
  @State setIgnoreRepeatClickTime: number = 0;
  @State ignoreRepeatFlag: boolean = false;
  @State allClickResponseTimeList: config.ClickResponseTime[] = [BASIC_SUSTAIN_DURATION_SHORT, BASIC_SUSTAIN_DURATION_CENTRE, BASIC_SUSTAIN_DURATION_LONG];
  private SelectAbilityScalingDialog: CustomDialogController = new CustomDialogController({
    builder: SelectAbilityScalingInformation({
      allClickResponseTimeList: $allClickResponseTimeList,
      clickResponseTimeText: $clickResponseTimeText,
      checked: $checked,
    }),
    alignment: DialogAlignment.Bottom,
    offset: ({ dx: 0, dy: '-12dp' }),
    autoCancel: true,
    customStyle: true,
  });

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.screen_touch'), isActive: true });

          Column() {
            Row() {
              Column() {
                Text($r('app.string.click_duration'))
                  .fontColor($r('sys.color.ohos_fa_text_primary'))
                  .fontFamily('HarmonyHeiTi')
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r("sys.float.ohos_id_text_size_body1"));
              }
              .alignItems(HorizontalAlign.Start);

              Blank();

              Row() {
                Text(this.clickResponseTimeText)
                  .margin({ right: $r('app.float.distance_4') })
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .fontColor($r('sys.color.ohos_fa_text_secondary'));

                Image('/res/image/ic_settings_arrow.svg')
                  .width($r('app.float.wh_value_12'))
                  .height($r('app.float.wh_value_24'))
                  .fillColor($r('sys.color.ohos_id_color_primary'))
                  .opacity($r('app.float.opacity_0_2'));
              }
            }
            .padding({ left: $r('app.float.wh_value_12'), right: $r('app.float.distance_6') })
            .alignItems(VerticalAlign.Center)
            .width(ConfigData.WH_100_100)
            .height($r('app.float.wh_value_56'))
            .onClick(() => {
              this.SelectAbilityScalingDialog.open();
            });
          }
          .height($r('app.float.wh_value_56'))
          .width(ConfigData.WH_100_100)
          .margin({ top: $r('app.float.distance_20') })
          .borderRadius($r('app.float.radius_24'))
          .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'));

          Column() {
            Row() {
              Text($r('app.string.Ignore_duplicate_clicks'))
                .fontSize($r('sys.float.ohos_id_text_size_body1'))
                .fontColor($r('sys.color.ohos_id_color_text_primary'))
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start);
              Blank();
              Toggle({ type: ToggleType.Switch, isOn: this.ignoreRepeatClickIsOn })
                .width('36vp')
                .height('20vp')
                .selectedColor('#007DFF')
                .onChange((isOn: boolean) => {
                  this.setIgnoreRepeatClickState(isOn);
                });
            }
            .height($r('app.float.wh_value_56'))
            .width(ConfigData.WH_100_100)
            .alignItems(VerticalAlign.Center)
            .padding({ left: $r('app.float.wh_value_12'), right: $r('app.float.wh_value_6') })
            .backgroundColor($r('app.color.white_bg_color'))
            .borderRadius($r('app.float.radius_24'));
          }
          .height($r('app.float.wh_value_56'))
          .width(ConfigData.WH_100_100)
          .margin({ top: $r('app.float.distance_20') })
          .borderRadius($r('app.float.radius_24'))
          .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'));

          Text($r('app.string.Ignore_duplicate_clicks_illustrate'))
            .width(ConfigData.WH_100_100)
            .fontSize($r('app.float.font_14'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .height($r('app.float.wh_value_52'))
            .lineHeight($r('app.float.wh_value_20'))
            .padding({
              left: $r('app.float.wh_value_12'),
              top: $r('app.float.distance_4'),
              bottom: $r('app.float.distance_24'),
            });

          Column() {
            Text($r('app.string.time_interval'))
              .width(ConfigData.WH_100_100)
              .fontSize($r('app.float.font_14'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .height($r('app.float.wh_value_52'))
              .lineHeight($r('app.float.wh_value_20'))
              .padding({
                left: $r('app.float.wh_value_12'),
                top: $r('app.float.distance_4'),
              });

            Row() {
              Column() {
                Row() {
                  Text(this.ignoreRepeatClickTimeText)
                    .fontSize($r('sys.float.ohos_id_text_size_body1'))
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .fontWeight(FontWeight.Medium)
                    .textAlign(TextAlign.Center);
                }
                .height($r('app.float.wh_value_19'))
                .width(ConfigData.WH_100_100)
                .alignItems(VerticalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .margin({top:$r('app.float.wh_value_16')})
                .backgroundColor($r('app.color.white_bg_color'))
                .borderRadius($r('app.float.radius_24'));

                Row() {
                  Image('/res/image/ic_public_remove.svg')
                    .height($r('app.float.wh_value_24'))
                    .width($r('app.float.wh_value_24'))
                    .fillColor($r('sys.color.ohos_id_color_primary'))
                    .margin({bottom:$r('app.float.wh_value_18')})
                    .onClick(() => {
                      this.onIgnoreRepeatClickTimeChange('minus')
                    });

                  Slider({
                    value: this.setIgnoreRepeatClickTime,
                    min: 0,
                    max: 100,
                    step: 25,
                    style: SliderStyle.InSet,
                  })
                    .selectedColor($r('app.color.font_color_007DFF'))
                    .blockColor(Color.Blue)
                    .showSteps(true)
                    .height($r('app.float.wh_value_20'))
                    .width(ConfigData.WH_83_100)
                    .margin({top:$r('app.float.wh_value_10'),bottom:$r('app.float.wh_value_22'),left:$r('app.float.wh_value_12'),right:$r('app.float.wh_value_12')})
                    .borderRadius($r('app.float.radius_24'))
                    .onChange((value: number, mode: SliderChangeMode) => {
                      this.setIgnoreRepeatClickTimeValue(value, mode);
                    });

                  Image('/res/image/ic_public_add_norm.svg')
                    .height($r('app.float.wh_value_24'))
                    .width($r('app.float.wh_value_24'))
                    .fillColor($r('sys.color.ohos_id_color_primary'))
                    .margin({bottom:$r('app.float.wh_value_18')})
                    .onClick(() => {
                      this.onIgnoreRepeatClickTimeChange('add')
                    });
                }
                .width(ConfigData.WH_100_100)
                .height($r('app.float.wh_value_52'))
                .justifyContent(FlexAlign.SpaceBetween)
                .padding({ left: $r('app.float.wh_value_6'), right: $r('app.float.wh_value_6') })
                .backgroundColor($r("app.color.white_bg_color"))
                .borderRadius($r('app.float.radius_24'));
              }
              .width(ConfigData.WH_100_100);
            }
            .width(ConfigData.WH_100_100)
            .alignItems(VerticalAlign.Center)
            .padding({ left: $r('app.float.wh_value_6'), right: $r('app.float.wh_value_6') })
            .backgroundColor($r("app.color.white_bg_color"))
            .borderRadius($r('app.float.radius_24'));
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .visibility(this.ignoreRepeatClickIsOn ? Visibility.Visible : Visibility.Hidden)
          .margin({ top: $r('app.float.wh_value_30') });
        }
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 },
        });
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100);
    }
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }

  setIgnoreRepeatClickState(isOn: boolean): void {
    LogUtil.info(`${TAG} setIgnoreRepeatClickState ${isOn}`);
    if (isOn) {
      this.ignoreRepeatClickIsOn = true;
      AccessibilitySettingModel.accessibilityConfigSetting('ignoreRepeatClick', true);
    } else {
      this.ignoreRepeatClickIsOn = false;
      AccessibilitySettingModel.accessibilityConfigSetting('ignoreRepeatClick', false);
    }
  }

  setIgnoreRepeatClickTimeValue(value: number, mode: SliderChangeMode): void {
    LogUtil.info(`${TAG} setIgnoreRepeatClickTimeValue ${value}${mode}`);
    this.setIgnoreRepeatClickTime = value;
    if (mode == SliderChangeMode.End || mode == SliderChangeMode.Click) {
      this.setNumberBecomeValue(value);
    }
  }

  onIgnoreRepeatClickTimeChange(value: string): void {
    LogUtil.info(`${TAG} onIgnoreRepeatClickTimeChange ${this.setIgnoreRepeatClickTime}`);
    if (value === 'minus') {
      if (this.setIgnoreRepeatClickTime > 0) {
        this.setIgnoreRepeatClickTime = this.setIgnoreRepeatClickTime - 25;
        this.setNumberBecomeValue(this.setIgnoreRepeatClickTime)
      }
      return;
    } else {
      if (this.setIgnoreRepeatClickTime < 100) {
        this.setIgnoreRepeatClickTime = this.setIgnoreRepeatClickTime + 25;
        this.setNumberBecomeValue(this.setIgnoreRepeatClickTime)
      }
      return;
    }
  }

  setNumberBecomeValue(value: number): void {
    LogUtil.info(`${TAG} setNumberBecomeValue ${value}`);
    let repeatClickValue: config.RepeatClickInterval = 'Shortest';
    switch (value) {
      case 0:
        repeatClickValue = 'Shortest';
        this.ignoreRepeatClickTimeText = (Object)($r('app.string.shortest'));
        break;
      case 25:
        repeatClickValue = 'Short';
        this.ignoreRepeatClickTimeText = (Object)($r('app.string.short'));
        break;
      case 50:
        repeatClickValue = 'Medium';
        this.ignoreRepeatClickTimeText = (Object)($r('app.string.centre'));
        break;
      case 75:
        repeatClickValue = 'Long';
        this.ignoreRepeatClickTimeText = (Object)($r('app.string.long'));
        break;
      case 100:
        repeatClickValue = 'Longest';
        this.ignoreRepeatClickTimeText = (Object)($r('app.string.longest'));
        break;
      default:
        repeatClickValue = 'Shortest';
        this.ignoreRepeatClickTimeText = (Object)($r('app.string.shortest'));
        LogUtil.error(`${TAG} setNumberBecomeValue fail reason: ${value}`);
        break;

    }
    AccessibilitySettingModel.accessibilityIgnoreRepeatClickTimeSet(repeatClickValue);
  }

  async getColorCorrectionStateAndTarget(): Promise<void> {
    await config.clickResponseTime.get().then((data) => {
      LogUtil.info(`${TAG} get clickResponseTime success: ${data}`);
      if (data === 'Short') {
        this.checked = BASIC_SUSTAIN_DURATION_SHORT;
        this.clickResponseTimeText = (Object)($r('app.string.default_short'));
      } else if (data === 'Medium') {
        this.checked = BASIC_SUSTAIN_DURATION_CENTRE;
        this.clickResponseTimeText = (Object)($r('app.string.centre'));
      } else {
        this.checked = BASIC_SUSTAIN_DURATION_LONG;
        this.clickResponseTimeText = (Object)($r('app.string.long'));
      }
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} failed to get clickResponseTime, because ${JSON.stringify(err)}`);
    });

    await config.ignoreRepeatClick.get().then((data) => {
      LogUtil.info(`${TAG} get ignoreRepeatClick success: ${data}`);
      this.ignoreRepeatClickIsOn = data;
    }).catch((err: object) => {
      LogUtil.error(`${TAG} failed to get ignoreRepeatClick, because ${JSON.stringify(err)}`);
    });

    await config.repeatClickInterval.get().then((data) => {
      LogUtil.info(`${TAG} get daltonizationColorFilter success: ${data}`);
      if (data === 'Shortest') {
        this.setIgnoreRepeatClickTime = 0;
        this.ignoreRepeatClickTimeText = (Object)($r('app.string.shortest'));
      } else if (data === 'Short') {
        this.setIgnoreRepeatClickTime = 25;
        this.ignoreRepeatClickTimeText = (Object)($r('app.string.short'));
      } else if (data === 'Medium') {
        this.setIgnoreRepeatClickTime = 50;
        this.ignoreRepeatClickTimeText = (Object)($r('app.string.centre'));
      } else if (data === 'Long') {
        this.setIgnoreRepeatClickTime = 75;
        this.ignoreRepeatClickTimeText = (Object)($r('app.string.long'));
      } else {
        this.setIgnoreRepeatClickTime = 100;
        this.ignoreRepeatClickTimeText = (Object)($r('app.string.longest'));
      }
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} failed to get ignoreRepeatClickTime, because ${JSON.stringify(err)}`);
    });
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear in`);
    this.getColorCorrectionStateAndTarget();

    LogUtil.info(`${TAG} aboutToAppear out`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }
}

@CustomDialog
struct SelectAbilityScalingInformation {
  controller?: CustomDialogController;
  @Link clickResponseTimeText: string;
  @Link checked: config.ClickResponseTime;
  @Link allClickResponseTimeList: Array<config.ClickResponseTime>;

  build() {
    Column() {
      Column() {
        Text($r('app.string.click_duration'))
          .fontFamily('HarmonyHeiTi')
          .fontSize($r('sys.float.ohos_id_text_size_headline8'))
          .fontWeight(FontWeight.Medium)
          .height($r('app.float.wh_value_56'))
          .alignSelf(ItemAlign.Start);

        List() {
          ForEach(this.allClickResponseTimeList, (item: config.ClickResponseTime, index) => {
            ListItem() {
              Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                Text((item === BASIC_SUSTAIN_DURATION_SHORT) ? $r('app.string.default_short') :
                  ((item === BASIC_SUSTAIN_DURATION_CENTRE) ? $r('app.string.centre') : $r('app.string.long')))
                  .fontFamily('HarmonyHeiTi')
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontWeight(FontWeight.Medium);

                Radio({ value: '', group: 'radioGroup' })
                  .checked(this.checked === item ? true : false)
                  .height($r('app.float.wh_value_24'))
                  .width($r('app.float.wh_value_24'))
                  .onChange((value: boolean) => {
                    if (value) {
                      this.controller?.close();
                      this.setAbilityText(item);
                      this.setColorCorrectionStatusText(item);
                      this.checked = item;
                    }
                  })
              }
              .height($r('app.float.wh_value_48'))
            }
            .height($r('app.float.wh_value_48'))
          })
        }

        Text($r('app.string.Cancel_Animation'))
          .fontSize($r('sys.float.ohos_id_text_size_button1'))
          .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
          .alignSelf(ItemAlign.Center)
          .width($r('app.float.wh_value_40'))
          .height($r('app.float.wh_value_40'))
          .margin({ top: $r('app.float.distance_8') })
          .onClick(() => {
            this.controller?.close();
          })
      }
      .padding({
        left: $r('app.float.padding_24'),
        right: $r('app.float.padding_24'),
      })
      .width(ConfigData.WH_100_100)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor($r('app.color.white_bg_color'))
      .borderRadius($r('app.float.radius_24'));
    }
    .width(ConfigData.WH_100_100)
    .padding({ left: $r('app.float.distance_12'), right: $r('app.float.distance_12') });
  }

  setAbilityText(ability: config.ClickResponseTime): void {
    LogUtil.info(`${TAG} set ability text ${ability}`);
    AccessibilitySettingModel.accessibilityClickResponseTimeSet(ability);
  }

  setColorCorrectionStatusText(text: string): void {
    if (text === BASIC_SUSTAIN_DURATION_SHORT) {
      this.clickResponseTimeText = (Object)($r('app.string.default_short'));
    } else if (text === BASIC_SUSTAIN_DURATION_CENTRE) {
      this.clickResponseTimeText = (Object)($r('app.string.centre'));
    } else {
      this.clickResponseTimeText = (Object)($r('app.string.long'));
    }
  }
}