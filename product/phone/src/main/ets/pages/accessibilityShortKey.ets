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

import accessibility from '@ohos.accessibility';
import config from '@ohos.accessibility.config';
import bundleMonitor from '@ohos.bundle.bundleMonitor';
import { BusinessError } from '@ohos.base';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import { AccessibilitySettingModel } from '../model/accessibilityImpl/AccessibilitySettingModel';

const TAG = ConfigData.TAG + 'Accessibility ShortKey: ';
const BASIC_ABILITY_HIGH_CONTRAST_TEXT = 'HIGH_CONTRAST_TEXT';
const BASIC_ABILITY_SINGLE_AUDIO = 'AUDIO_MONO';

@Entry
@Component
struct AccessibilityShortKey {
  @State shortKeyIsOn: boolean = false;
  @State shortKeyStatusText: string = '';
  @State checked: string = '';
  @State extAbilityNameList: string[] = [];
  @State AllAbilityNameList: string[] = [];
  private SelectAbilityScalingDialog: CustomDialogController = new CustomDialogController({
    builder: SelectAbilityScalingInformation({
      AllAbilityNameList: $AllAbilityNameList,
      shortKeyStatusText: $shortKeyStatusText,
      checked: $checked,
      extAbilityNameList: $extAbilityNameList,
    }),
    alignment: DialogAlignment.Center,
    offset: ({ dx: 0, dy: '-12dp' }),
    autoCancel: true,
    customStyle: true,
  });

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.accessibility_shortcuts'), isActive: true });
          Text($r('app.string.accessibility_shortcuts_tips'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .fontSize($r('app.float.font_14'))
            .lineHeight($r('app.float.lineHeight_19'))
            .fontColor($r('app.color.font_color_182431'))
            .margin({
              bottom: $r('app.float.distance_36'),
              top: $r('app.float.distance_24'),
              left: $r('app.float.distance_12'),
              right: $r("app.float.distance_12"),
            })
            .opacity($r("app.float.opacity_100_60"))
            .textAlign(TextAlign.Center);

          Column() {
            List() {
              ListItem() {
                Column() {
                  Row() {
                    Text($r('app.string.accessibility_shortcuts'))
                      .fontSize($r('sys.float.ohos_id_text_size_body1'))
                      .fontColor($r('sys.color.ohos_id_color_text_primary'))
                      .fontWeight(FontWeight.Medium)
                      .textAlign(TextAlign.Start);
                    Blank();
                    Toggle({ type: ToggleType.Switch, isOn: this.shortKeyIsOn })
                      .width('36vp')
                      .height('20vp')
                      .selectedColor('#007DFF')
                      .onChange((isOn: boolean) => {
                        this.setShortcutsFunctionState(isOn);
                      });
                  }
                  .height($r('app.float.wh_value_56'))
                  .width(ConfigData.WH_100_100)
                  .alignItems(VerticalAlign.Center)
                  .padding({ left: $r('app.float.wh_value_12'), right: $r('app.float.wh_value_6') })
                  .backgroundColor($r("app.color.white_bg_color"))
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
                    Text($r("app.string.accessibility_select_ability"))
                      .fontColor($r('sys.color.ohos_fa_text_primary'))
                      .fontFamily('HarmonyHeiTi')
                      .fontWeight(FontWeight.Medium)
                      .fontSize($r('sys.float.ohos_id_text_size_body1'));
                  }
                  .alignItems(HorizontalAlign.Start);

                  Blank();

                  Row() {
                    Text(this.shortKeyStatusText)
                      .margin({ right: $r("app.float.distance_4") })
                      .fontSize($r('sys.float.ohos_id_text_size_body2'))
                      .fontColor($r('sys.color.ohos_fa_text_secondary'));

                    Image('/res/image/ic_settings_arrow.svg')
                      .width($r('app.float.wh_value_12'))
                      .height($r('app.float.wh_value_24'))
                      .fillColor($r('sys.color.ohos_id_color_primary'))
                      .opacity($r("app.float.opacity_0_2"));
                  }
                }
                .padding({ left: $r('sys.float.ohos_id_card_margin_start'), right: $r('app.float.distance_8') })
                .alignItems(VerticalAlign.Center)
                .width(ConfigData.WH_100_100)
                .height($r("app.float.wh_value_48"))
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
          .borderRadius($r("app.float.wh_value_24"))
          .backgroundColor($r("app.color.white_bg_color"))
          .width(ConfigData.WH_100_100)
          .margin({ top: $r("app.float.distance_12") })
          .padding({
            top: $r("app.float.distance_4"),
            bottom: $r("app.float.distance_4"),
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

  setShortcutsFunctionState(isOn: boolean): void {
    LogUtil.info(`${TAG} setShortcutsFunctionState ${isOn}`);
    if (isOn) {
      this.shortKeyIsOn = true;
      AccessibilitySettingModel.accessibilityConfigSetting('shortKey', true);
    } else {
      this.shortKeyIsOn = false;
      AccessibilitySettingModel.accessibilityConfigSetting('shortKey', false);
    }
  }

  async getShortKeyStateAndTarget(): Promise<void> {
    await config.shortkey.get().then((data) => {
      this.shortKeyIsOn = data;
      LogUtil.info(`${TAG} get shortKeyIsOn success : ${data}`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} failed to get shortKeyIsOn, because ${JSON.stringify(err)}`);
    });

    await config.shortkeyTarget.get().then((data) => {
      LogUtil.info(`${TAG} get shortkeyTarget success: ${data}`);
      if (data === 'none') {
        this.shortKeyStatusText = (Object)($r('app.string.disabled'));
        return;
      }
      if (data === BASIC_ABILITY_HIGH_CONTRAST_TEXT) {
        this.checked = BASIC_ABILITY_HIGH_CONTRAST_TEXT;
        this.shortKeyStatusText = (Object)($r('app.string.highContrast_text'));
      } else if (data === BASIC_ABILITY_SINGLE_AUDIO) {
        this.checked = BASIC_ABILITY_SINGLE_AUDIO;
        this.shortKeyStatusText = (Object)($r('app.string.single_audio'));
      } else {
        this.checked = data;
        this.shortKeyStatusText = data.split('/')[1];
      }
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} failed to get shortKeyTarget, because ${JSON.stringify(err)}`);
    });
  }

  generateAllAbilityNameList(): Array<string> {
    let basicAbilities = [BASIC_ABILITY_HIGH_CONTRAST_TEXT, BASIC_ABILITY_SINGLE_AUDIO];
    return basicAbilities.concat(this.extAbilityNameList);
  }

  updateAccessibilityExtensionList() {
    accessibility.getAccessibilityExtensionList('all', 'install').then((data) => {
      LogUtil.info(`${TAG} get accessibilityAbilityList success, service length: ${JSON.stringify(data.length)}`);
      if (data.length > 0) {
        data.forEach(item => this.extAbilityNameList.push(item.id));
      }
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} failed to get accessibilityAbilityList, because ${JSON.stringify(err)}`);
    })
  }

  aboutToAppear(): void {
    this.openAbilitySelectListener();
    LogUtil.info(`${TAG} aboutToAppear in`);
    this.getShortKeyStateAndTarget();
    this.updateAccessibilityExtensionList();
    LogUtil.info(`${TAG} aboutToAppear out`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  onPageHide(): void {
    this.closeAbilitySelectListener();
  }

  openAbilitySelectListener(): void {
    try {
      bundleMonitor.on('add', (bundleChangeInfo) => {
        this.extAbilityNameList = [];
        this.AllAbilityNameList = [];
        this.updateAccessibilityExtensionList();
        this.AllAbilityNameList = this.generateAllAbilityNameList();
        LogUtil.info(`bundleName:${bundleChangeInfo.bundleName} userId:${bundleChangeInfo.userId}`);
      })
    } catch (errData) {
      let message = (errData as BusinessError).message;
      let errCode = (errData as BusinessError).code;
      LogUtil.error(`errData is errCode :${errCode} message:${message}`);
    }
    try {
      bundleMonitor.on('remove', (bundleChangeInfo) => {
        this.extAbilityNameList = [];
        this.AllAbilityNameList = [];
        this.updateAccessibilityExtensionList();
        this.AllAbilityNameList = this.generateAllAbilityNameList();
        if (this.AllAbilityNameList.indexOf(this.shortKeyStatusText) === -1) {
          this.shortKeyStatusText = (Object)($r('app.string.disabled'));
          this.setShortcutsFunctionState(false);
          this.SelectAbilityScalingDialog.close();
          this.getShortKeyStateAndTarget();
        }
        LogUtil.info(`bundleName:${bundleChangeInfo.bundleName} userId:${bundleChangeInfo.userId}`);
      })
    } catch (errData) {
      let message = (errData as BusinessError).message;
      let errCode = (errData as BusinessError).code;
      LogUtil.error(`errData is errCode :${errCode} message:${message}`);
    }
  }

  closeAbilitySelectListener(): void {
    try {
      bundleMonitor.off('add');
    } catch (errData) {
      let message = (errData as BusinessError).message;
      let errCode = (errData as BusinessError).code;
      LogUtil.error(`errData is errCode :${errCode} message:${message}`);
    }
    try {
      bundleMonitor.off('remove');
    } catch (errData) {
      let message = (errData as BusinessError).message;
      let errCode = (errData as BusinessError).code;
      LogUtil.error(`errData is errCode :${errCode} message:${message}`);
    }
  }
}

@CustomDialog
struct SelectAbilityScalingInformation {
  controller?: CustomDialogController;
  @Link shortKeyStatusText: string;
  @Link checked: string;
  @Link extAbilityNameList: Array<string>;
  @Link AllAbilityNameList: Array<string>;

  updateAccessibilityExtensionList() {
    accessibility.getAccessibilityExtensionList('all', 'install').then((data) => {
      LogUtil.info(`${TAG} get accessibilityAbilityList success, service length: ${JSON.stringify(data.length)}`);
      if (data.length > 0) {
        data.forEach(item => this.extAbilityNameList.push(item.id));
      }
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} failed to get accessibilityAbilityList, because ${JSON.stringify(err)}`);
    })
  }

  aboutToAppear() {
    LogUtil.info(`${TAG} aboutToAppear Accessibility Functions list`);
    this.AllAbilityNameList = this.generateAllAbilityNameList();
    LogUtil.info(JSON.stringify(this.AllAbilityNameList));
    try {
      bundleMonitor.on('add', (bundleChangeInfo) => {
        this.extAbilityNameList = [];
        this.AllAbilityNameList = [];
        this.updateAccessibilityExtensionList();
        this.AllAbilityNameList = this.generateAllAbilityNameList();
        this.controller?.close();
        LogUtil.info(`bundleName:${bundleChangeInfo.bundleName} userId:${bundleChangeInfo.userId}`);
      })
    } catch (errData) {
      let message = (errData as BusinessError).message;
      let errCode = (errData as BusinessError).code;
      LogUtil.error(`errData is errCode :${errCode} message:${message}`);
    }
    try {
      bundleMonitor.on('remove', (bundleChangeInfo) => {
        this.extAbilityNameList = [];
        this.AllAbilityNameList = [];
        this.updateAccessibilityExtensionList();
        this.AllAbilityNameList = this.generateAllAbilityNameList();
        if (this.AllAbilityNameList.indexOf(this.shortKeyStatusText) === -1) {
          this.shortKeyStatusText = (Object)($r('app.string.disabled'));
        }
        this.controller?.close();
        LogUtil.info(`bundleName:${bundleChangeInfo.bundleName} userId:${bundleChangeInfo.userId}`);
      })
    } catch (errData) {
      let message = (errData as BusinessError).message;
      let errCode = (errData as BusinessError).code;
      LogUtil.error(`errData is errCode :${errCode} message:${message}`);
    }
  }

  build() {
    Column() {
      Column() {
        Text($r('app.string.accessibility_select_ability'))
          .fontFamily('HarmonyHeiTi')
          .fontSize($r('sys.float.ohos_id_text_size_headline8'))
          .fontWeight(FontWeight.Medium)
          .height($r("app.float.wh_value_56"))
          .alignSelf(ItemAlign.Start);

        List() {
          ForEach(Array.from(new Set(this.AllAbilityNameList)), (item: string, index) => {
            ListItem() {
              Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                Text((item === BASIC_ABILITY_HIGH_CONTRAST_TEXT) ? $r('app.string.highContrast_text') :
                  ((item === BASIC_ABILITY_SINGLE_AUDIO) ? $r('app.string.single_audio') : item.split('/')[1]))
                  .fontFamily('HarmonyHeiTi')
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontWeight(FontWeight.Medium);

                Radio({ value: '', group: 'radioGroup' })
                  .checked(this.checked === item ? true : false)
                  .height($r("app.float.wh_value_24"))
                  .width($r("app.float.wh_value_24"))
                  .onChange((value: boolean) => {
                    if (value) {
                      this.controller?.close();
                      this.setAbilityText(item);
                      this.setShortKeyStatusText(item);
                      this.checked = item;
                    }
                  })
              }
              .height($r("app.float.wh_value_48"))
            }
            .height($r("app.float.wh_value_48"))
          })
        }

        Text($r('app.string.Cancel_Animation'))
          .fontSize($r('sys.float.ohos_id_text_size_button1'))
          .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
          .alignSelf(ItemAlign.Center)
          .width($r("app.float.wh_value_40"))
          .height($r("app.float.wh_value_40"))
          .margin({ top: $r("app.float.distance_8") })
          .onClick(() => {
            this.controller?.close();
          })
      }
      .padding({
        left: $r("app.float.padding_24"),
        right: $r("app.float.padding_24"),
      })
      .width(ConfigData.WH_100_100)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor($r("app.color.white_bg_color"))
      .borderRadius($r("app.float.radius_24"));
    }
    .width(ConfigData.WH_100_100)
    .padding({ left: $r("app.float.distance_12"), right: $r("app.float.distance_12") });
  }

  setAbilityText(ability: string): void {
    LogUtil.info(`${TAG} set ability text ${ability}`);
    AccessibilitySettingModel.accessibilityShortKeyStateSet(ability);
  }

  generateAllAbilityNameList(): Array<string> {
    let basicAbilities = [BASIC_ABILITY_HIGH_CONTRAST_TEXT, BASIC_ABILITY_SINGLE_AUDIO];
    return basicAbilities.concat(this.extAbilityNameList);
  }

  setShortKeyStatusText(text: string): void {
    if (text === BASIC_ABILITY_HIGH_CONTRAST_TEXT) {
      this.shortKeyStatusText = (Object)($r('app.string.highContrast_text'));
    } else if (text === BASIC_ABILITY_SINGLE_AUDIO) {
      this.shortKeyStatusText = (Object)($r('app.string.single_audio'));
    } else {
      this.shortKeyStatusText = text.split('/')[1];
    }
  }
}