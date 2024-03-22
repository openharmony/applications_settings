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
import { ResourceUtils } from '../model/accessibilityImpl/resourceUtils';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import { AccessibilitySettingModel } from '../model/accessibilityImpl/AccessibilitySettingModel';

const TAG = ConfigData.TAG + 'AccessibilityShortKey: ';
const BASIC_ABILITY_HIGH_CONTRAST_TEXT = 'HIGH_CONTRAST_TEXT';
const BASIC_ABILITY_SINGLE_AUDIO = 'AUDIO_MONO';
const BASIC_ABILITY_INVERT_COLOR = 'INVERT_COLOR';

@Entry
@Component
struct AccessibilityShortKey {
  @State shortKeyIsOn: boolean = false;
  @State shortKeyStatusText: string = '';
  @State extAbilityNameList: string[] = [];
  @State AllAbilityNameList: string[] = [];
  @State selectAbilityList: Array<string> = [];
  private SelectAbilityScalingDialog: CustomDialogController | null = new CustomDialogController({
    builder: SelectAbilityScalingInformation({
      AllAbilityNameList: $AllAbilityNameList,
      shortKeyStatusText: $shortKeyStatusText,
      selectAbilityList: $selectAbilityList,
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
              right: $r('app.float.distance_12'),
            })
            .opacity($r('app.float.opacity_100_60'))
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
                    Text($r('app.string.accessibility_select_ability'))
                      .fontColor($r('sys.color.ohos_fa_text_primary'))
                      .fontFamily('HarmonyHeiTi')
                      .fontWeight(FontWeight.Medium)
                      .fontSize($r('sys.float.ohos_id_text_size_body1'));
                  }
                  .alignItems(HorizontalAlign.Start);

                  Blank();

                  Row() {
                    Text(this.shortKeyStatusText)
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
                .width(ConfigData.WH_100_100)
                .height($r('app.float.wh_value_48'))
                .onClick(() => {
                  this.SelectAbilityScalingDialog?.open();
                });
              }
            }
            .width(ConfigData.WH_100_100)
            .divider({
              strokeWidth: $r('app.float.divider_wh'),
              color: $r('sys.color.ohos_id_color_list_separator'),
              startMargin: $r('app.float.wh_value_15'),
              endMargin: $r('app.float.wh_value_15'),
            });
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

    await config.shortkeyMultiTargets.get().then((data) => {
      LogUtil.info(`${TAG} get shortkeyTarget success: ${JSON.stringify(data)}`);
      if (!data || data.length < 1) {
        this.shortKeyStatusText = ResourceUtils.getStringSync($r('app.string.disabled'));
        return;
      }
      this.selectAbilityList = JSON.parse(JSON.stringify(data));
      this.getShortKeyStatus(data);
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} failed to get shortKeyTarget, because ${JSON.stringify(err)}`);
    });
  }

  getShortKeyStatus(list: string[]): void {
    LogUtil.info(`${TAG} get getShortKeyStatus success: ${JSON.stringify(list)}`);
    let targetName: string = '';
    if (list[0] === BASIC_ABILITY_HIGH_CONTRAST_TEXT) {
      targetName = ResourceUtils.getStringSync($r('app.string.highContrast_text'));
    } else if (list[0] === BASIC_ABILITY_SINGLE_AUDIO) {
      targetName = ResourceUtils.getStringSync($r('app.string.single_audio'));
    } else if (list[0] === BASIC_ABILITY_INVERT_COLOR) {
      targetName = ResourceUtils.getStringSync($r('app.string.invert_color'));
    } else {
      targetName = list[0].split('/')[1];
    }
    if (list.length > 1) {
      this.shortKeyStatusText = targetName + ResourceUtils.getStringSync($r('app.string.wait'));
    } else {
      this.shortKeyStatusText = targetName;
    }
    LogUtil.info(`${TAG} get getShortKeyStatus success: ${this.shortKeyStatusText}`);
  }

  generateAllAbilityNameList(): Array<string> {
    LogUtil.info(`${TAG} generateAllAbilityNameList in`);
    let basicAbilities = [BASIC_ABILITY_HIGH_CONTRAST_TEXT, BASIC_ABILITY_SINGLE_AUDIO, BASIC_ABILITY_INVERT_COLOR];
    if (this.extAbilityNameList && this.extAbilityNameList.length > 0) {
      return basicAbilities.concat(this.extAbilityNameList);
    }
    return basicAbilities;
  }

  async updateAccessibilityExtensionList(): Promise<void> {
    await accessibility.getAccessibilityExtensionList('all', 'install').then((data) => {
      LogUtil.info(`${TAG} get accessibilityAbilityList success, service length: ${JSON.stringify(data.length)}`);
      if (data.length > 0) {
        data.forEach(item => this.extAbilityNameList.push(item.id));
      }
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} failed to get accessibilityAbilityList, because ${JSON.stringify(err)}`);
    });
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear in`);
    this.updateAccessibilityExtensionList();
    this.openAbilitySelectListener();
    LogUtil.info(`${TAG} aboutToAppear out`);
  }

  async onPageShow(): Promise<void> {
    LogUtil.info(`${TAG} onPageShow in`);
    await this.getShortKeyStateAndTarget();
    this.openAbilitySelectListener();
    this.abilitySelectListenerAdd();
    this.abilitySelectListenerRemove();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.SelectAbilityScalingDialog = null;
  }

  onPageHide(): void {
    this.closeAbilitySelectListener();
  }

  async abilitySelectListenerAdd(): Promise<void> {
    this.extAbilityNameList = [];
    this.AllAbilityNameList = [];
    await this.updateAccessibilityExtensionList();
    this.AllAbilityNameList = this.generateAllAbilityNameList();
    this.SelectAbilityScalingDialog?.close();
  }

  async abilitySelectListenerRemove(): Promise<void> {
    let check: string[] = [];
    this.extAbilityNameList = [];
    this.AllAbilityNameList = [];
    await this.updateAccessibilityExtensionList();
    this.AllAbilityNameList = this.generateAllAbilityNameList();
    if (this.selectAbilityList && this.selectAbilityList.length > 0) {
      for (let value of this.selectAbilityList) {
        if (this.AllAbilityNameList.indexOf(value) !== -1) {
          check.push(value);
        }
      }
      if (check.length !== this.selectAbilityList.length) {
        if (check.length > 0) {
          this.getShortKeyStatus(check);
        } else {
          this.shortKeyStatusText = ResourceUtils.getStringSync($r('app.string.disabled'));
          this.setShortcutsFunctionState(false);
        }
        this.selectAbilityList = JSON.parse(JSON.stringify(check));
        AccessibilitySettingModel.accessibilityShortKeyMultiTargetsSet(check);
      }
    }
    this.SelectAbilityScalingDialog?.close();
  }

  openAbilitySelectListener(): void {
    try {
      bundleMonitor.on('add', (bundleChangeInfo) => {
        this.abilitySelectListenerAdd();
        LogUtil.info(`${TAG} bundleName:${bundleChangeInfo.bundleName} userId:${bundleChangeInfo.userId}`);
      });
    } catch (errData) {
      let message = (errData as BusinessError).message;
      let errCode = (errData as BusinessError).code;
      LogUtil.error(`${TAG} errData is errCode :${errCode} message:${message}`);
    }
    try {
      bundleMonitor.on('update', (bundleChangeInfo) => {
        this.abilitySelectListenerAdd();
        LogUtil.info(`${TAG} bundleName:${bundleChangeInfo.bundleName} userId:${bundleChangeInfo.userId}`);
      });
    } catch (errData) {
      let message = (errData as BusinessError).message;
      let errCode = (errData as BusinessError).code;
      LogUtil.error(`${TAG} errData is errCode :${errCode} message:${message}`);
    }
    try {
      bundleMonitor.on('remove', (bundleChangeInfo) => {
        this.abilitySelectListenerRemove();
        LogUtil.info(`${TAG} bundleName:${bundleChangeInfo.bundleName} userId:${bundleChangeInfo.userId}`);
      });
    } catch (errData) {
      let message = (errData as BusinessError).message;
      let errCode = (errData as BusinessError).code;
      LogUtil.error(`${TAG} errData is errCode :${errCode} message:${message}`);
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
      bundleMonitor.off('update');
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
  @Link extAbilityNameList: Array<string>;
  @Link AllAbilityNameList: Array<string>;
  @Link selectAbilityList: Array<string>;
  @State stagList: Array<string> = JSON.parse(JSON.stringify(this.selectAbilityList));

  build() {
    Column() {
      Column() {
        Text($r('app.string.accessibility_select_ability'))
          .fontFamily('HarmonyHeiTi')
          .fontSize($r('sys.float.ohos_id_text_size_headline8'))
          .fontWeight(FontWeight.Medium)
          .height($r('app.float.wh_value_56'))
          .alignSelf(ItemAlign.Start);

        List() {
          ForEach(Array.from(new Set(this.AllAbilityNameList)), (item: string, index) => {
            ListItem() {
              Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                Text((item === BASIC_ABILITY_HIGH_CONTRAST_TEXT) ? $r('app.string.highContrast_text') :
                  ((item === BASIC_ABILITY_SINGLE_AUDIO) ? $r('app.string.single_audio') :
                    ((item === BASIC_ABILITY_INVERT_COLOR) ? $r('app.string.invert_color') : item.split('/')[1])))
                  .fontFamily('HarmonyHeiTi')
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontWeight(FontWeight.Medium);

                Checkbox({ name: '', group: 'checkboxGroup' })
                  .select(this.selectAbilityList.includes(item) ? true : false)
                  .height($r('app.float.wh_value_24'))
                  .width($r('app.float.wh_value_24'))
                  .onChange((value: boolean) => {
                    if (value) {
                      this.stagList.push(item);
                      LogUtil.info(`${TAG} push item succeed: ${JSON.stringify(item)}`)
                      LogUtil.info(`${TAG} push selectAbilityList succeed: ${JSON.stringify(this.stagList)}`);
                    } else {
                      LogUtil.info(`${TAG} pop item succeed: ${item}`);
                      this.stagList.splice(this.stagList.indexOf(item), 1);
                      LogUtil.info(`${TAG} pop selectAbilityList succeed: ${JSON.stringify(this.stagList)}`);

                    }
                  });
              }
              .height($r('app.float.wh_value_48'));
            }
            .height($r('app.float.wh_value_48'));
          })
        }

        Row() {
          Text($r('app.string.Cancel_Animation'))
            .fontSize($r('sys.float.ohos_id_text_size_button1'))
            .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
            .alignSelf(ItemAlign.Center)
            .width($r('app.float.wh_value_60'))
            .height($r('app.float.wh_value_40'))
            .margin({ top: $r('app.float.distance_8') })
            .onClick(() => {
              this.stagList = [];
              this.controller?.close();
            });
          Text($r('app.string.ok'))
            .fontSize($r('sys.float.ohos_id_text_size_button1'))
            .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
            .alignSelf(ItemAlign.Center)
            .width($r('app.float.wh_value_60'))
            .height($r('app.float.wh_value_40'))
            .margin({ top: $r('app.float.distance_8') })
            .onClick(() => {
              this.setAbilityList();
            });
        }
        .width(ConfigData.WH_100_100)
        .justifyContent(FlexAlign.SpaceAround);

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

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear Accessibility Functions list`);
    this.AllAbilityNameList = this.generateAllAbilityNameList();
    LogUtil.info(JSON.stringify(this.AllAbilityNameList));
    try {
      bundleMonitor.on('add', (bundleChangeInfo) => {
        LogUtil.info(`${TAG} Add bundleName:${bundleChangeInfo.bundleName} userId:${bundleChangeInfo.userId}`);
        this.interceptionDataChanges();
      });
    } catch (errData) {
      let message = (errData as BusinessError).message;
      let errCode = (errData as BusinessError).code;
      LogUtil.error(`${TAG} errData is errCode :${errCode} message:${message}`);
    }
    try {
      bundleMonitor.on('update', (bundleChangeInfo) => {
        LogUtil.info(`${TAG} Update bundleName:${bundleChangeInfo.bundleName} userId:${bundleChangeInfo.userId}`);
        this.interceptionDataChanges();
      })
    } catch (errData) {
      let message = (errData as BusinessError).message;
      let errCode = (errData as BusinessError).code;
      LogUtil.error(`${TAG} errData is errCode :${errCode} message:${message}`);
    }
    try {
      bundleMonitor.on('remove', (bundleChangeInfo) => {
        LogUtil.info(`${TAG} Remove bundleName:${bundleChangeInfo.bundleName} userId:${bundleChangeInfo.userId}`);
        this.interceptionDataChanges();
      })
    } catch (errData) {
      let message = (errData as BusinessError).message;
      let errCode = (errData as BusinessError).code;
      LogUtil.error(`${TAG} errData is errCode :${errCode} message:${message}`);
    }
  }

  interceptionDataChanges(): void {
    this.extAbilityNameList = [];
    this.AllAbilityNameList = [];
    this.updateAccessibilityExtensionList();
    this.AllAbilityNameList = this.generateAllAbilityNameList();
    this.controller?.close();
    LogUtil.info(`${TAG} interceptionDataChanges end`);
  }

  updateAccessibilityExtensionList(): void {
    accessibility.getAccessibilityExtensionList('all', 'install').then((data) => {
      LogUtil.info(`${TAG} get accessibilityAbilityList success, service length: ${JSON.stringify(data.length)}`);
      if (data.length > 0) {
        data.forEach(item => this.extAbilityNameList.push(item.id));
      }
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} failed to get accessibilityAbilityList, because ${JSON.stringify(err)}`);
    });
  }

  setAbilityList(): void {
    LogUtil.info(`${TAG} set ability List ${JSON.stringify(this.selectAbilityList)}`);
    let endAbilityList: Array<string> = JSON.parse(JSON.stringify(this.stagList));
    this.selectAbilityList = JSON.parse(JSON.stringify(this.stagList));
    AccessibilitySettingModel.accessibilityShortKeyMultiTargetsSet(endAbilityList);
    this.getShortKeyStatus();
    this.controller?.close();
  }

  generateAllAbilityNameList(): Array<string> {
    let basicAbilities = [BASIC_ABILITY_HIGH_CONTRAST_TEXT, BASIC_ABILITY_SINGLE_AUDIO, BASIC_ABILITY_INVERT_COLOR];
    return basicAbilities.concat(this.extAbilityNameList);
  }

  getShortKeyStatus(): void {
    LogUtil.info(`${TAG} getShortKeyStatus in ${JSON.stringify(this.selectAbilityList)}`);
    if (this.selectAbilityList && this.selectAbilityList.length > 1) {
      let targetName: string = this.setShortKeyStatusText(this.selectAbilityList[0]);
      this.shortKeyStatusText = targetName + ResourceUtils.getStringSync($r('app.string.wait'));
    } else if (this.selectAbilityList && this.selectAbilityList.length === 1) {
      this.shortKeyStatusText = this.setShortKeyStatusText(this.selectAbilityList[0]);
    } else {
      this.shortKeyStatusText = ResourceUtils.getStringSync($r('app.string.disabled'));
    }
  }

  setShortKeyStatusText(text: string): string {
    LogUtil.info(`${TAG} set setShortKeyStatusText text ${text}`);
    let targetValue: string = '';
    if (text === BASIC_ABILITY_HIGH_CONTRAST_TEXT) {
      targetValue = ResourceUtils.getStringSync($r('app.string.highContrast_text'));
    } else if (text === BASIC_ABILITY_SINGLE_AUDIO) {
      targetValue = ResourceUtils.getStringSync($r('app.string.single_audio'));
    } else if (text === BASIC_ABILITY_INVERT_COLOR) {
      targetValue = ResourceUtils.getStringSync($r('app.string.invert_color'));
    } else {
      targetValue = text.split('/')[1];
    }
    return targetValue
  }
}