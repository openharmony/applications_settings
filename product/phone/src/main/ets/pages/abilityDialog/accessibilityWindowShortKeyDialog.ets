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

import accessibility from '@ohos.accessibility';
import config from '@ohos.accessibility.config';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import bundleMonitor from '@ohos.bundle.bundleMonitor';
import { BusinessError } from '@ohos.base';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import { AccessibilitySettingModel } from '../../model/accessibilityImpl/AccessibilitySettingModel';

const TAG = 'AccessibilityWindowShortKeyDialog :';
const BASIC_ABILITY_HIGH_CONTRAST_TEXT = 'HIGH_CONTRAST_TEXT';
const BASIC_ABILITY_SINGLE_AUDIO = 'AUDIO_MONO';
const BASIC_ABILITY_INVERT_COLOR = 'INVERT_COLOR';

@Entry
@Component
struct AccessibilityShortKeyWindow {
  private AccessibilityWindowShortKeyDialog: CustomDialogController = new CustomDialogController({
    builder: AccessibilityWindowShortKeyDialog({}),
    alignment: DialogAlignment.Bottom,
    offset: ({ dx: 0, dy: '-40dp' }),
    autoCancel: true,
    customStyle: true,
    cancel: () => {
      (AppStorage.get<UIExtensionContentSession>('accessibilityDialogSession') as UIExtensionContentSession).terminateSelf();
    }
  });

  build() {
  }

  aboutToAppear(): void {
    this.AccessibilityWindowShortKeyDialog.open();
  }
}


@CustomDialog
struct AccessibilityWindowShortKeyDialog {
  controller?: CustomDialogController;
  capabilities: Array<accessibility.Capability> = ['retrieve', 'keyEventObserver', 'gesture', 'zoom', 'touchGuide'];
  @State allAbilityList: string[] = [];
  @State enabledAbilityList: string[] = [];

  build() {
    Column() {
      Column() {
        Text($r('app.string.accessibility_shortcuts'))
          .fontFamily('HarmonyHeiTi')
          .fontSize($r('sys.float.ohos_id_text_size_headline8'))
          .fontWeight(FontWeight.Medium)
          .height($r('app.float.wh_value_56'))
          .alignSelf(ItemAlign.Start);

        List() {
          ForEach(this.allAbilityList, (item: string, index) => {
            ListItem() {
              Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                Text((item === BASIC_ABILITY_HIGH_CONTRAST_TEXT) ? $r('app.string.highContrast_text') :
                  ((item === BASIC_ABILITY_SINGLE_AUDIO) ? $r('app.string.single_audio') :
                    ((item === BASIC_ABILITY_INVERT_COLOR) ? $r('app.string.invert_color') : item.split('/')[1])))
                  .fontFamily('HarmonyHeiTi')
                  .fontSize($r('sys.float.ohos_id_text_size_body1'))
                  .fontWeight(FontWeight.Medium);

                Image($r("app.media.ic_ok"))
                  .width($r('app.float.wh_value_24'))
                  .height($r('app.float.wh_value_24'))
                  .fillColor('#47CC47')
                  .objectFit(ImageFit.Contain)
                  .visibility(this.enabledAbilityList.includes(item) ? Visibility.Visible : Visibility.None);

              }
              .height($r('app.float.wh_value_48'));
            }
            .height($r('app.float.wh_value_48'))
            .onClick(() => {
              if (this.enabledAbilityList.indexOf(item) === -1) {
                this.enabledAbilityList.push(item);
                this.setShortKeyAbility(item, true);
              } else {
                this.enabledAbilityList.splice(this.enabledAbilityList.indexOf(item), 1);
                this.setShortKeyAbility(item, false);
              }
            });
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
              this.onDialogClose();
            });
        }
        .width(ConfigData.WH_100_100)
        .justifyContent(FlexAlign.Center);

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

  async aboutToAppear(): Promise<void> {
    LogUtil.info(`${TAG} dialog aboutToAppear in`);
    await config.shortkeyMultiTargets.get().then((data) => {
      LogUtil.info(`${TAG} get shortkeyTarget success: ${JSON.stringify(data)}`);
      this.allAbilityList = JSON.parse(JSON.stringify(data));
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} failed to get shortKeyTarget, because ${JSON.stringify(err)}`);
    });
    this.getAbilityListStatus();
    this.openExtendedServicesListener();
  }

  async getAbilityListStatus(): Promise<void> {
    LogUtil.info(`${TAG} dialog getAbilityListStatus in: ${JSON.stringify(this.allAbilityList)}`);
    for (let value of this.allAbilityList) {
      if (value === BASIC_ABILITY_HIGH_CONTRAST_TEXT) {
        config.highContrastText.get().then((data: boolean) => {
          LogUtil.info(`${TAG} get highContrastText success`);
          if (data) {
            this.enabledAbilityList.push(value);
          }
        }).catch((err: object) => {
          LogUtil.error(`${TAG} failed to get highContrastText, because: JSON.stringify(err)`);
        });
      } else if (value === BASIC_ABILITY_SINGLE_AUDIO) {
        config.audioMono.get().then((data: boolean) => {
          LogUtil.info(`${TAG} get audioMno success`);
          if (data) {
            this.enabledAbilityList.push(value);
          }
        }).catch((err: object) => {
          LogUtil.error(`${TAG} failed to get highContrastText, because: JSON.stringify(err)`);
        });
      } else if (value === BASIC_ABILITY_INVERT_COLOR) {
        config.invertColor.get().then((data: boolean) => {
          LogUtil.info(`${TAG} get invertColor success`);
          if (data) {
            this.enabledAbilityList.push(value);
          }
        }).catch((err: object) => {
          LogUtil.error(`${TAG} failed to get invertColor, because: JSON.stringify(err)`);
        });
      } else {
        let enabledServiceList: Array<accessibility.AccessibilityAbilityInfo> = await accessibility.getAccessibilityExtensionList('all', 'enable');
        if (!enabledServiceList || enabledServiceList.length === 0) {
          continue;
        }
        for (let enabledService of enabledServiceList) {
          if (enabledService.id && enabledService.id === value) {
            this.enabledAbilityList.push(value);
            break;
          }
        }
      }
    }
  }

  onDialogClose(): void {
    LogUtil.info(`${TAG} onDialogClose in`);
    this.controller?.close();
    (AppStorage.get<UIExtensionContentSession>('accessibilityDialogSession') as UIExtensionContentSession).terminateSelf();
  }

  openExtendedServicesListener(): void {
    LogUtil.info(`${TAG} openExtendedServicesListener in`);
    try {
      bundleMonitor.on('add', (bundleChangeInfo) => {
        this.onDialogClose();
        LogUtil.info(`${TAG} add bundleName:${bundleChangeInfo.bundleName} userId:${bundleChangeInfo.userId}`);
      });
    } catch (errData) {
      let message = (errData as BusinessError).message;
      let errCode = (errData as BusinessError).code;
      LogUtil.error(`${TAG} add errData is errCode :${errCode} message:${message}`);
    }
    try {
      bundleMonitor.on('update', (bundleChangeInfo) => {
        this.onDialogClose();
        LogUtil.info(`${TAG} update bundleName:${bundleChangeInfo.bundleName} userId:${bundleChangeInfo.userId}`);
      });
    } catch (errData) {
      let message = (errData as BusinessError).message;
      let errCode = (errData as BusinessError).code;
      LogUtil.error(`${TAG} update errData is errCode :${errCode} message:${message}`);
    }
    try {
      bundleMonitor.on('remove', (bundleChangeInfo) => {
        this.onDialogClose();
        LogUtil.info(`${TAG} remove bundleName:${bundleChangeInfo.bundleName} userId:${bundleChangeInfo.userId}`);
      })
    } catch (errData) {
      let message = (errData as BusinessError).message;
      let errCode = (errData as BusinessError).code;
      LogUtil.error(`${TAG} remove errData is errCode :${errCode} message:${message}`);
    }
  }

  setShortKeyAbility(text: string, isOn: boolean): void {
    LogUtil.info(`${TAG} setShortKeyAbility get:${JSON.stringify(text)}},${JSON.stringify(isOn)}}`);
    if (text === BASIC_ABILITY_HIGH_CONTRAST_TEXT) {
      AccessibilitySettingModel.accessibilityConfigSetting('highContrastText', isOn);
    } else if (text === BASIC_ABILITY_SINGLE_AUDIO) {
      AccessibilitySettingModel.accessibilityConfigSetting('audioMono', isOn);
    } else if (text === BASIC_ABILITY_INVERT_COLOR) {
      AccessibilitySettingModel.accessibilityConfigSetting('invertColor', isOn);
    } else {
      if (isOn) {
        config.enableAbility(text, this.capabilities).then(() => {
          LogUtil.info(`${TAG} enable accessibilityService success`);
        }).catch((err: object) => {
          LogUtil.error(`${TAG} failed to enable accessibilityService, because ${JSON.stringify(err)}`);
        })
      } else {
        config.disableAbility(text).then(() => {
          LogUtil.info(`${TAG} disable accessibilityService success`);
        }).catch((err: object) => {
          LogUtil.error(`${TAG} disable accessibilityService failed, error: ${JSON.stringify(err)}`);
        });
      }
    }
    this.onDialogClose();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} dialog aboutToDisappear in`);
    try {
      bundleMonitor.off('add');
      bundleMonitor.off('update');
      bundleMonitor.off('remove');
    } catch (exception) {
      LogUtil.info(`${TAG} failed subscribe bundleMonitor, result: ${JSON.stringify(exception)}`);
    }
  }
}