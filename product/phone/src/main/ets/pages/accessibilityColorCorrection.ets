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
import { BusinessError } from '@ohos.base';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import { AccessibilitySettingModel } from '../model/accessibilityImpl/AccessibilitySettingModel';

const TAG = ConfigData.TAG + 'Accessibility ColorCorrection: ';
const BASIC_MODE_GREEN_AMBLYOPIA = 'Deuteranomaly';
const BASIC_MODE_RED_AMBLYOPIA = 'Protanomaly';
const BASIC_MODE_BLUE_AMBLYOPIA = 'Tritanomaly';

@Entry
@Component
struct AccessibilityColorCorrection {
  @State colorCorrectionIsOn: boolean = false;
  @State colorModeStatusText: string = '';
  @State checked: config.DaltonizationColorFilter = 'Normal';
  @State allModeNameList: config.DaltonizationColorFilter[] = [BASIC_MODE_GREEN_AMBLYOPIA, BASIC_MODE_RED_AMBLYOPIA, BASIC_MODE_BLUE_AMBLYOPIA];
  private SelectAbilityScalingDialog: CustomDialogController = new CustomDialogController({
    builder: SelectAbilityScalingInformation({
      allModeNameList: $allModeNameList,
      colorModeStatusText: $colorModeStatusText,
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
          HeadComponent({ headName: $r('app.string.color_correction'), isActive: true });

          Column() {
            List() {
              ListItem() {
                Column() {
                  Row() {
                    Text($r('app.string.color_correction'))
                      .fontSize($r('sys.float.ohos_id_text_size_body1'))
                      .fontColor($r('sys.color.ohos_id_color_text_primary'))
                      .fontWeight(FontWeight.Medium)
                      .textAlign(TextAlign.Start);
                    Blank();
                    Toggle({ type: ToggleType.Switch, isOn: this.colorCorrectionIsOn })
                      .width('36vp')
                      .height('20vp')
                      .selectedColor('#007DFF')
                      .onChange((isOn: boolean) => {
                        this.setColorCorrectionState(isOn);
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
                .borderRadius($r('app.float.radius_24'))
                .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'));
              }

              ListItem() {
                Row() {
                  Column() {
                    Text($r('app.string.mode_of_correction'))
                      .fontColor($r('sys.color.ohos_fa_text_primary'))
                      .fontFamily('HarmonyHeiTi')
                      .fontWeight(FontWeight.Medium)
                      .fontSize($r("sys.float.ohos_id_text_size_body1"));
                  }
                  .alignItems(HorizontalAlign.Start);

                  Blank();

                  Row() {
                    Text(this.colorModeStatusText)
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
                .padding({ left: $r('sys.float.ohos_id_card_margin_start'), right: $r('app.float.distance_8') })
                .alignItems(VerticalAlign.Center)
                .enabled(this.colorCorrectionIsOn)
                .opacity(this.colorCorrectionIsOn ? 1 : 0.4)
                .width(ConfigData.WH_100_100)
                .height($r('app.float.wh_value_48'))
                .onClick(() => {
                  this.SelectAbilityScalingDialog.open();
                });
              }
            }
            .width(ConfigData.WH_100_100)
            .divider({
              strokeWidth: $r('app.float.divider_wh'),
              color: $r('sys.color.ohos_id_color_list_separator'),
              startMargin: $r('app.float.wh_value_15'),
              endMargin: $r('app.float.wh_value_15'),
            })
          }
          .borderRadius($r('app.float.wh_value_24'))
          .backgroundColor($r('app.color.white_bg_color'))
          .width(ConfigData.WH_100_100)
          .margin({ top: $r('app.float.distance_12') })
          .padding({
            top: $r('app.float.distance_4'),
            bottom: $r('app.float.distance_4'),
          });
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

  setColorCorrectionState(isOn: boolean): void {
    LogUtil.info(`${TAG} setColorCorrectionState ${isOn}`);
    if (isOn) {
      this.colorCorrectionIsOn = true;
      AccessibilitySettingModel.accessibilityConfigSetting('daltonizationState', true);
    } else {
      this.colorCorrectionIsOn = false;
      AccessibilitySettingModel.accessibilityConfigSetting('daltonizationState', false);
    }
  }

  async getColorCorrectionStateAndTarget(): Promise<void> {
    await config.daltonizationState.get().then((data) => {
      LogUtil.info(`${TAG} get daltonizationState success: ${data}`);
      this.colorCorrectionIsOn = data;
    }).catch((err: object) => {
      LogUtil.error(`${TAG} failed to get daltonizationState, because ${JSON.stringify(err)}`);
    });

    await config.daltonizationColorFilter.get().then((data) => {
      LogUtil.info(`${TAG} get daltonizationColorFilter success: ${data}`);
      if (data === 'Normal') {
        this.colorModeStatusText = (Object)($r('app.string.none'));
        return;
      }
      if (data === 'Deuteranomaly') {
        this.checked = BASIC_MODE_GREEN_AMBLYOPIA;
        this.colorModeStatusText = (Object)($r('app.string.green_amblyopia'));
      } else if (data === 'Tritanomaly') {
        this.checked = BASIC_MODE_BLUE_AMBLYOPIA;
        this.colorModeStatusText = (Object)($r('app.string.blue_amblyopia'));
      } else {
        this.checked = BASIC_MODE_RED_AMBLYOPIA;
        this.colorModeStatusText = (Object)($r('app.string.red_amblyopia'));
      }
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} failed to get daltonizationColorFilter, because ${JSON.stringify(err)}`);
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
  @Link colorModeStatusText: string;
  @Link checked: config.DaltonizationColorFilter;
  @Link allModeNameList: Array<config.DaltonizationColorFilter>;

  build() {
    Column() {
      Column() {
        Text($r('app.string.mode_of_correction'))
          .fontFamily('HarmonyHeiTi')
          .fontSize($r('sys.float.ohos_id_text_size_headline8'))
          .fontWeight(FontWeight.Medium)
          .height($r('app.float.wh_value_56'))
          .alignSelf(ItemAlign.Start);

        List() {
          ForEach(this.allModeNameList, (item: config.DaltonizationColorFilter, index) => {
            ListItem() {
              Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                Text((item === BASIC_MODE_GREEN_AMBLYOPIA) ? $r('app.string.green_amblyopia') :
                  ((item === BASIC_MODE_RED_AMBLYOPIA) ? $r('app.string.red_amblyopia') : $r('app.string.blue_amblyopia')))
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
          .width($r('app.float.wh_value_60'))
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

  setAbilityText(ability: config.DaltonizationColorFilter): void {
    LogUtil.info(`${TAG} set ability text ${ability}`);
    AccessibilitySettingModel.accessibilityColorCorrectionSet(ability);
  }

  setColorCorrectionStatusText(text: string): void {
    if (text === BASIC_MODE_GREEN_AMBLYOPIA) {
      this.colorModeStatusText = (Object)($r('app.string.green_amblyopia'));
    } else if (text === BASIC_MODE_RED_AMBLYOPIA) {
      this.colorModeStatusText = (Object)($r('app.string.red_amblyopia'));
    } else {
      this.colorModeStatusText = (Object)($r('app.string.blue_amblyopia'));
    }
  }
}