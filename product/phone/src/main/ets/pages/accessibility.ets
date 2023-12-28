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

import bundleMonitor from '@ohos.bundle.bundleMonitor';
import config from '@ohos.accessibility.config';
import accessibility from '@ohos.accessibility';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import { ResourceUtils } from '../model/accessibilityImpl/resourceUtils';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import ComponentConfig from '../../../../../../common/component/src/main/ets/default/ComponentConfig';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import { SubHeader } from '../../../../../../common/component/src/main/ets/default/textComponent';
import { AccessibilitySettingModel } from '../model/accessibilityImpl/AccessibilitySettingModel';

const AUDIO_BALANCE_STEP_VALUE: number = 1;
const AUDIO_BALANCE_MIN_VALUE: number = -100;
const AUDIO_BALANCE_MAX_VALUE: number = 100;
const BASIC_ABILITY_HIGH_CONTRAST_TEXT = 'HIGH_CONTRAST_TEXT';
const BASIC_ABILITY_SINGLE_AUDIO = 'AUDIO_MONO';
const BASIC_ABILITY_INVERT_COLOR = 'INVERT_COLOR';

/**
 * accessibility setting
 */
@Entry
@Component
struct AccessibilitySettings {
  @State shortKeyIsOn: boolean = false;
  @State shortKeyStatusText: string = '';
  @State highContrastTextIsOn: boolean = false;
  @State invertColorIsOn: boolean = false;
  @State audioMonoIsOn: boolean = false;
  @State colorCorrectionStatusText: string = '';
  @State inSetValueAudioBalance: number = 0;
  @State serviceNum: number = 0;
  @State serviceStateText: Resource = $r('app.string.no_service');
  @State isTouched: boolean = false;
  @State serviceNumChanged: boolean = true;
  private TAG = ConfigData.TAG + 'AccessibilitySettings ';

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.accessibility'), isActive: true });

          SubHeader({ titleContent: ResourceUtils.getCapitalStringSync($r('app.string.visual_accessibility')) });

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
            .padding({ left: $r('app.float.wh_value_12'), right: $r('app.float.wh_value_6') })
            .backgroundColor($r("app.color.white_bg_color"))
            .borderRadius($r('app.float.radius_24'));

            Row() {
              Column() {
                Text($r('app.string.invert_color'))
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .fontWeight(FontWeight.Medium)
                  .textAlign(TextAlign.Start);
                Text($r('app.string.performance_may_be_affected'))
                  .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
                  .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                  .fontWeight(FontWeight.Regular)
                  .textAlign(TextAlign.Center);
              }
              .width($r('app.float.wh_value_230'))
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.Start)

              Blank();

              Toggle({ type: ToggleType.Switch, isOn: this.invertColorIsOn })
                .width('36vp')
                .height('20vp')
                .selectedColor('#007DFF')
                .onChange((isOn: boolean) => {
                  this.setInvertColorState(isOn);
                });
            }
            .height($r('app.float.wh_value_56'))
            .width(ConfigData.WH_100_100)
            .alignItems(VerticalAlign.Center)
            .padding({ left: $r("app.float.wh_value_12"), right: $r('app.float.wh_value_6') })
            .backgroundColor($r("app.color.white_bg_color"))
            .borderRadius($r('app.float.radius_24'));

            Navigator({ target: 'pages/accessibilityColorCorrection' }) {
              Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                Row() {
                  Text($r('app.string.color_correction'))
                    .fontSize($r('app.float.font_16'))
                    .lineHeight($r('app.float.wh_value_22'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.font_color_182431'))
                    .margin({ left: $r('app.float.distance_8') })
                    .textAlign(TextAlign.Start);
                }

                Row() {
                  Text(this.colorCorrectionStatusText)
                    .fontSize($r('app.float.font_14'))
                    .lineHeight($r('app.float.wh_value_19'))
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                    .margin({ right: $r('app.float.distance_4') })
                    .textAlign(TextAlign.End);
                  Image('/res/image/ic_settings_arrow.svg')
                    .width($r('app.float.wh_value_12'))
                    .height($r('app.float.wh_value_24'))
                    .margin({ right: $r('app.float.distance_8') })
                    .fillColor($r('sys.color.ohos_id_color_primary'))
                    .opacity($r('app.float.opacity_0_2'))
                }
              }
              .height(ComponentConfig.WH_100_100)
              .width(ComponentConfig.WH_100_100)
              .borderRadius($r('app.float.radius_20'))
              .onTouch((event?: TouchEvent) => {
                if (event && event.type === TouchType.Down) {
                  this.isTouched = true;
                }
                if (event && event.type === TouchType.Up) {
                  this.isTouched = false;
                }
              });
            }
            .padding($r('app.float.distance_4'))
            .height($r('app.float.wh_value_56'))
            .borderRadius($r('app.float.radius_24'))
            .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'));

          }
          .height($r('app.float.wh_value_160'))
          .width(ConfigData.WH_100_100)
          .borderRadius($r('app.float.radius_24'))
          .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'));

          SubHeader({ titleContent: ResourceUtils.getCapitalStringSync($r('app.string.audio_accessibility')) });

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
          .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'));

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

          SubHeader({ titleContent: ResourceUtils.getCapitalStringSync($r('app.string.operate_accessibility')) });

          Column() {
            Navigator({ target: 'pages/accessibilityScreenTouch' }) {
              Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                Row() {
                  Text($r('app.string.screen_touch'))
                    .fontSize($r('app.float.font_16'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.font_color_182431'))
                    .lineHeight($r('app.float.wh_value_22'))
                    .margin({ left: $r('app.float.distance_8') })
                    .textAlign(TextAlign.Start);
                }

                Row() {
                  Image('/res/image/ic_settings_arrow.svg')
                    .height($r('app.float.wh_value_24'))
                    .width($r('app.float.wh_value_12'))
                    .fillColor($r('sys.color.ohos_id_color_primary'))
                    .margin({ right: $r('app.float.distance_8') })
                    .opacity($r('app.float.opacity_0_2'));
                }
              }
              .onTouch((event?: TouchEvent) => {
                if (event && event.type === TouchType.Down) {
                  this.isTouched = true;
                }
                if (event && event.type === TouchType.Up) {
                  this.isTouched = false;
                }
              })
              .height(ComponentConfig.WH_100_100)
              .width(ComponentConfig.WH_100_100)
              .borderRadius($r('app.float.radius_20'));
            }
            .padding($r('app.float.distance_4'))
            .height($r('app.float.wh_value_56'))
            .borderRadius($r('app.float.radius_24'))
            .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'));

            Navigator({ target: 'pages/accessibilityShortKey' }) {
              Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                Row() {
                  Text($r('app.string.accessibility_shortcuts'))
                    .fontSize($r('app.float.font_16'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.font_color_182431'))
                    .lineHeight($r('app.float.wh_value_22'))
                    .margin({ left: $r('app.float.distance_8') })
                    .textAlign(TextAlign.Start);
                }

                Row() {
                  Text(this.shortKeyStatusText)
                    .fontSize($r('app.float.font_14'))
                    .lineHeight($r('app.float.wh_value_19'))
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                    .textAlign(TextAlign.End)
                    .margin({ right: $r('app.float.distance_4') });
                  Image('/res/image/ic_settings_arrow.svg')
                    .height($r('app.float.wh_value_24'))
                    .width($r('app.float.wh_value_12'))
                    .fillColor($r('sys.color.ohos_id_color_primary'))
                    .margin({ right: $r('app.float.distance_8') })
                    .opacity($r('app.float.opacity_0_2'));
                }
              }
              .onTouch((event?: TouchEvent) => {
                if (event && event.type === TouchType.Down) {
                  this.isTouched = true;
                }
                if (event && event.type === TouchType.Up) {
                  this.isTouched = false;
                }
              })
              .height(ComponentConfig.WH_100_100)
              .width(ComponentConfig.WH_100_100)
              .borderRadius($r('app.float.radius_20'));
            }
            .padding($r('app.float.distance_4'))
            .height($r('app.float.wh_value_56'))
            .borderRadius($r('app.float.radius_24'))
            .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'));
          }
          .height($r('app.float.wh_padding_112'))
          .width(ConfigData.WH_100_100)
          .borderRadius($r('app.float.radius_24'))
          .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'));

          SubHeader({ titleContent: ResourceUtils.getCapitalStringSync($r('app.string.extension_service')) });
          if (this.serviceNumChanged || !this.serviceNumChanged) {
            Navigator({ target: 'pages/serviceManagement' }) {
              Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                Row() {
                  Text($r('app.string.installed_service'))
                    .fontSize($r('app.float.font_16'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.font_color_182431'))
                    .lineHeight($r('app.float.wh_value_22'))
                    .margin({ left: $r('app.float.distance_8') })
                    .textAlign(TextAlign.Start);
                }

                Row() {
                  Text(this.serviceStateText)
                    .fontSize($r('app.float.font_14'))
                    .lineHeight($r('app.float.wh_value_19'))
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                    .textAlign(TextAlign.End)
                    .margin({ right: $r('app.float.distance_4') });
                  Image('/res/image/ic_settings_arrow.svg')
                    .height($r('app.float.wh_value_24'))
                    .width($r('app.float.wh_value_12'))
                    .fillColor($r('sys.color.ohos_id_color_primary'))
                    .margin({ right: $r('app.float.distance_8') })
                    .opacity($r('app.float.opacity_0_2'));
                }
              }
              .onTouch((event?: TouchEvent) => {
                if (event && event.type === TouchType.Down) {
                  this.isTouched = true;
                }
                if (event && event.type === TouchType.Up) {
                  this.isTouched = false;
                }
              })
              .height(ComponentConfig.WH_100_100)
              .width(ComponentConfig.WH_100_100)
              .borderRadius($r('app.float.radius_20'));
            }
            .padding($r('app.float.distance_4'))
            .height($r('app.float.wh_value_56'))
            .borderRadius($r('app.float.radius_24'))
            .enabled(this.serviceNum > 0 ? true : false)
            .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'));
          }
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
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  };

  setShortKeyText(status: boolean, allList: Array<string>): void {
    LogUtil.info(`${this.TAG} shortKeyState: status:${JSON.stringify(status)},text:${JSON.stringify(allList)}`);
    if (allList.length < 1) {
      this.shortKeyStatusText = ResourceUtils.getStringSync($r('app.string.disabled'));
      return;
    }
    if (status) {
      let text: string = '';
      if (allList[0] === BASIC_ABILITY_HIGH_CONTRAST_TEXT) {
        text = ResourceUtils.getStringSync($r('app.string.highContrast_text'));
      } else if (allList[0] === BASIC_ABILITY_SINGLE_AUDIO) {
        text = ResourceUtils.getStringSync($r('app.string.single_audio'));
      } else if (allList[0] === BASIC_ABILITY_INVERT_COLOR) {
        text = ResourceUtils.getStringSync($r('app.string.invert_color'));
      } else {
        text = allList[0].split('/')[1];
      }
      if (allList.length > 1) {
        this.shortKeyStatusText = text + ResourceUtils.getStringSync($r('app.string.wait'));
      } else {
        this.shortKeyStatusText = text;
      }
    } else {
      this.shortKeyStatusText = ResourceUtils.getStringSync($r('app.string.disabled'));
    }
    LogUtil.info(`${this.TAG} set shortKeyStateText: ${JSON.stringify(this.shortKeyStatusText)}`);
  }

  setHighContrastTextState(isOn: boolean): void {
    LogUtil.info(`${this.TAG} setHighContrastTextState ${isOn}`);
    if (isOn) {
      this.highContrastTextIsOn = true;
      AccessibilitySettingModel.accessibilityConfigSetting('highContrastText', true);
    } else {
      this.highContrastTextIsOn = false;
      AccessibilitySettingModel.accessibilityConfigSetting('highContrastText', false);
    }
  }

  setInvertColorState(isOn: boolean): void {
    LogUtil.info(`${this.TAG} setInvertColorState ${isOn}`);
    if (isOn) {
      this.invertColorIsOn = true;
      AccessibilitySettingModel.accessibilityConfigSetting('invertColor', true);
    } else {
      this.invertColorIsOn = false;
      AccessibilitySettingModel.accessibilityConfigSetting('invertColor', false);
    }
  }

  setAudioMonoState(isOn: boolean): void {
    LogUtil.info(`${this.TAG}setAudioMonoState ${isOn}`);
    if (isOn) {
      this.audioMonoIsOn = true;
      AccessibilitySettingModel.accessibilityConfigSetting('audioMono', true);
    } else {
      this.audioMonoIsOn = false;
      AccessibilitySettingModel.accessibilityConfigSetting('audioMono', false);
    }
  }

  setAudioBalanceValue(audioBalance: number, mode: SliderChangeMode): void {
    LogUtil.info(`${this.TAG} setAudioBalanceValue ${audioBalance}${mode}`);
    if (mode == SliderChangeMode.End || mode == SliderChangeMode.Click) {
      AccessibilitySettingModel.accessibilityAudioBalanceSetting(audioBalance / 100);
    }
  }

  async getAbilityList(): Promise<void> {
    await accessibility.getAccessibilityExtensionList('all', 'install').then((data) => {
      LogUtil.info(`${this.TAG} get accessibilityAbilityList success, service length: ${JSON.stringify(data.length)}`);
      if (data.length > 0) {
        this.serviceNum = data.length;
        this.serviceStateText = $r('app.plural.service_number', this.serviceNum, this.serviceNum);
        LogUtil.info(`${this.TAG} serviceNumber: ${JSON.stringify(this.serviceNum)}`);
      } else {
        this.serviceStateText = $r('app.string.no_service');
        this.serviceNum = 0;
      }
      this.serviceNumChanged = !this.serviceNumChanged;
    }).catch((err: object) => {
      LogUtil.error(`${this.TAG} failed to get accessibilityAbilityList, because ${JSON.stringify(err)}`);
      this.serviceStateText = $r('app.string.no_service');
      this.serviceNum = 0;
      this.serviceNumChanged = !this.serviceNumChanged;
    })
    LogUtil.info(`${this.TAG} aboutToAppear out`);
  }

  async getColorCorrectionState(): Promise<void> {
    await config.daltonizationState.get().then((data) => {
      LogUtil.info(`${this.TAG} get daltonizationState success: ${data}`);
      if (data) {
        this.colorCorrectionStatusText = (Object)($r('app.string.enabled'));
      } else {
        this.colorCorrectionStatusText = (Object)($r('app.string.disabled'));
      }
    }).catch((err: object) => {
      LogUtil.error(`${this.TAG} failed to get daltonizationState, because ${JSON.stringify(err)}`);
    });
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.TAG} aboutToAppear in`);
    config.highContrastText.get().then((data) => {
      LogUtil.info(`${this.TAG} get highContrastText switch success`);
      this.highContrastTextIsOn = data;
    }).catch((err: object) => {
      LogUtil.error(`${this.TAG} failed to get highContrastText switch, because ${JSON.stringify(err)}`);
    });

    config.invertColor.get().then((data) => {
      LogUtil.info(`${this.TAG} get invertColor switch success`);
      this.invertColorIsOn = data;
    }).catch((err: object) => {
      LogUtil.error(`${this.TAG} failed to get invertColor switch, because ${JSON.stringify(err)}`);
    });

    config.audioMono.get().then((data) => {
      this.audioMonoIsOn = data;
      LogUtil.info(`${this.TAG} get audioMono success`);
    }).catch((err: object) => {
      LogUtil.error(`${this.TAG} failed to get audioMono, because ${JSON.stringify(err)}`);
    });

    config.audioBalance.get().then((data) => {
      this.inSetValueAudioBalance = data * 100;
      LogUtil.info(`${this.TAG} get audioBalance success`);
    }).catch((err: object) => {
      LogUtil.error(`${this.TAG} failed to get audioBalance, because ${JSON.stringify(err)}`);
    });
    this.openStatusListener();
    this.getColorCorrectionState();
    this.getShortKeyStateAndTargetByStatus();
    this.getAbilityList();
    LogUtil.info(`${this.TAG} aboutToAppear out`);
  }

  async getShortKeyStateAndTargetByStatus(): Promise<void> {
    let allList: Array<string> = [];
    await config.shortkey.get().then((data) => {
      this.shortKeyIsOn = data;
      LogUtil.info(`${this.TAG} get shortKeyIsOn success : ${data}`);
    }).catch((err: object) => {
      LogUtil.error(`${this.TAG} failed to get shortKeyIsOn, because ${JSON.stringify(err)}`);
    });

    await config.shortkeyMultiTargets.get().then((data) => {
      allList = JSON.parse(JSON.stringify(data));
      LogUtil.info(`${this.TAG} get shortkeyMultiTargets success: ${data}`);
    }).catch((err: object) => {
      LogUtil.error(`${this.TAG} failed to get shortkeyMultiTargets, because ${JSON.stringify(err)}`);
    });
    this.setShortKeyText(this.shortKeyIsOn, allList);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.TAG} aboutToDisappear`);
    this.closeExtendedServicesListener();
    this.closeStatusListener();
  }

  onPageShow(): void {
    LogUtil.info(`${this.TAG} onPageShow in`);
    this.getShortKeyStateAndTargetByStatus();
    this.openExtendedServicesListener();
    this.getColorCorrectionState();
    this.getAbilityList();
    LogUtil.info(`${this.TAG} onPageShow out`);
  }

  openStatusListener(): void {
    try {
      config.highContrastText.on((data: boolean) => {
        LogUtil.info(`${this.TAG} subscribe highContrastText success, result: ${JSON.stringify(data)}`);
        this.highContrastTextIsOn = data;
      });
    } catch (exception) {
      LogUtil.info(`${this.TAG} failed subscribe highContrastText, result: ${JSON.stringify(exception)}`);
    }
    try {
      config.invertColor.on((data: boolean) => {
        LogUtil.info(`${this.TAG} subscribe invertColor success, result: ${JSON.stringify(data)}`);
        this.invertColorIsOn = data;
      });
    } catch (exception) {
      LogUtil.info(`${this.TAG} failed subscribe invertColor, result: ${JSON.stringify(exception)}`);
    }
    try {
      config.audioMono.on((data: boolean) => {
        LogUtil.info(`${this.TAG} subscribe audioMono success, result: ${JSON.stringify(data)}`);
        this.audioMonoIsOn = data;
      });
    } catch (exception) {
      LogUtil.info(`${this.TAG} failed subscribe audioMono, result: ${JSON.stringify(exception)}`);
    }
  }

  closeStatusListener(): void {
    try {
      config.highContrastText.off((data: boolean) => {
        LogUtil.info(`${this.TAG} Unsubscribe highContrastText success, result: ${JSON.stringify(data)}`);
      });
    } catch (exception) {
      LogUtil.info(`${this.TAG} failed subscribe highContrastText , result: ${JSON.stringify(exception)}`);
    }
    try {
      config.invertColor.off((data: boolean) => {
        LogUtil.info(`${this.TAG} Unsubscribe invertColor success, result: ${JSON.stringify(data)}`);
      });
    } catch (exception) {
      LogUtil.info(`${this.TAG} failed subscribe invertColor , result: ${JSON.stringify(exception)}`);
    }
    try {
      config.audioMono.off((data: boolean) => {
        LogUtil.info(`${this.TAG} Unsubscribe audioMono success, result: ${JSON.stringify(data)}`);
      });
    } catch (exception) {
      LogUtil.info(`${this.TAG} failed subscribe audioMono, result: ${JSON.stringify(exception)}`);
    }
  }

  openExtendedServicesListener(): void {
    try {
      bundleMonitor.on('add', (bundleChangeInfo) => {
        LogUtil.info(`${this.TAG} Add bundleName: ${bundleChangeInfo.bundleName} userId: ${bundleChangeInfo.userId}`);
        this.getAbilityList();
      });
    } catch (exception) {
      LogUtil.info(`${this.TAG} failed subscribe bundleMonitor add, result: ${JSON.stringify(exception)}`);
    }
    try {
      bundleMonitor.on('update', (bundleChangeInfo) => {
        LogUtil.info(`${this.TAG} Update bundleName: ${bundleChangeInfo.bundleName} userId: ${bundleChangeInfo.userId}`);
        this.getAbilityList();
      });
    } catch (exception) {
      LogUtil.info(`${this.TAG} failed subscribe bundleMonitor, result: ${JSON.stringify(exception)}`);
    }
    try {
      bundleMonitor.on('remove', (bundleChangeInfo) => {
        LogUtil.info(`${this.TAG} Remove bundleName: ${bundleChangeInfo.bundleName} userId: ${bundleChangeInfo.userId}`);
        this.getAbilityList();
        this.getShortKeyStateAndTargetByStatus();
      });
    } catch (exception) {
      LogUtil.info(`${this.TAG} failed subscribe bundleMonitor, result: ${JSON.stringify(exception)}`);
    }
  }

  closeExtendedServicesListener(): void {
    try {
      bundleMonitor.off('add');
      bundleMonitor.off('update');
      bundleMonitor.off('remove');
    } catch (exception) {
      LogUtil.info(`${this.TAG} failed subscribe bundleMonitor, result: ${JSON.stringify(exception)}`);
    }
  }
}