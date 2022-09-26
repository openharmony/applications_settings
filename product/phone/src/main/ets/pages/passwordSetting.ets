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

import prompt from '@system.prompt';
import Router from '@system.router';
import deviceInfo from '@ohos.deviceInfo';
import PasswordListController from '../controller/password/PasswordSettingController';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import EntryComponent from '../../../../../../common/component/src/main/ets/default/entryComponent';
import ResourceUtil from '../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import { PasswordSettingItem } from '../../../../../../common/utils/src/main/ets/default/bean/PasswordSettingItem';

const deviceTypeInfo = deviceInfo.deviceType;

@Entry
@Component
struct PasswordSetting {
  private TAG_PAGE = ConfigData.TAG + 'PasswordSetting page ';
  private mController: PasswordListController = new PasswordListController();

  // bind Properties
  @State private passwordList: PasswordSettingItem[][] = [];
  private pinChallenge: string = '';

  // private Properties
  private lockUi: boolean = false; // prevent continuous and multiple clicks
  @State isPhoneOrRK: boolean = false;
  @State isTouched: boolean = false;
  @State touchedItem: boolean = false;
  @State listSpace: string = '10vp';
  @State faceAuthFailedMessage: string = '';

  @Log
  aboutToAppear(): void {
    if (deviceTypeInfo === 'phone' || deviceTypeInfo === 'default') {
      this.isPhoneOrRK = true;
    } else {
      this.isPhoneOrRK = false;
    }

    // bind component and initialize
    this.mController.bindComponent(this)
      .bindProperties(["passwordList", "pinChallenge"])
      .initData()
      .subscribe();

    ResourceUtil.getString($r('app.float.distance_10')).then(value => this.listSpace = value);
    ResourceUtil.getString($r("app.string.face_auth_failed")).then(value => this.faceAuthFailedMessage = value);
  }

  @Log
  aboutToDisappear(): void {
    this.mController.unsubscribe();
  }

  @Log
  onPageShow(): void {
    this.lockUi = false;
    this.mController.loadData();
  }

  @Builder FaceAuthItem() {
    Stack() {
      EntryComponent({
        settingIcon: '',
        settingTitle: $r('app.string.face_recognition'),
        settingSummary: '',
        settingValue: '',
        settingArrow: '/res/image/ic_settings_arrow.svg',
        settingArrowStyle: '',
        settingUri: '',
        heights: $r('app.float.password_list_item_height'),
        fontSize: $r('app.float.password_list_item_title_font_size')
      })
    }
    .width(ConfigData.WH_100_100)
    .onClick(() => {
      if (this.lockUi) {
        return;
      }
      this.lockUi = true;
      globalThis.settingsAbilityContext.startAbility({
        bundleName: ConfigData.FACEAUTH_BUNDLE_NAME,
        abilityName: ConfigData.FACEAUTH_ABILITY_NAME
      })
        .then((data) => {
          LogUtil.info(`${this.TAG_PAGE}, ${ConfigData.FACEAUTH_BUNDLE_NAME} start successful. Data: ${JSON.stringify(data)}`);
        })
        .catch((error) => {
          prompt.showToast({
            message: this.faceAuthFailedMessage,
            duration: 2000
          })
          LogUtil.error(`${this.TAG_PAGE}, ${ConfigData.FACEAUTH_BUNDLE_NAME} start failed. Cause: ${JSON.stringify(error)}`);
        })
      this.lockUi = false;
    })
  }

  @Builder DisablePasswordItem(item: PasswordSettingItem) {
    Stack() {
      EntryComponent({
        settingIcon: '',
        settingTitle: item.settingTitle,
        settingSummary: '',
        settingValue: item.settingValue,
        settingArrow: item.settingArrow,
        settingUri: item.settingUri,
        settingArrowStyle: '',
        titleFontColor: $r("app.color.font_color_007DFF"),
        heights: $r('app.float.password_list_item_height'),
        fontSize: $r('app.float.font_16')
      })
    }
    .width(ConfigData.WH_100_100)
    .onClick(() => {
      if (this.lockUi) {
        return;
      }
      this.lockUi = true;
      LogUtil.info(this.TAG_PAGE + ' disable password onclick : item = ' + JSON.stringify(item));
      this.showClosePasswordDialog(item);
      this.lockUi = false;
    });
  }

  @Builder NormalItem(item: PasswordSettingItem) {
    Stack() {
      EntryComponent({
        settingIcon: '',
        settingTitle: item.settingTitle,
        settingSummary: '',
        settingValue: item.settingValue,
        settingArrow: item.settingArrow,
        settingArrowStyle: '',
        settingUri: item.settingUri,
        heights: $r('app.float.password_list_item_height'),
        fontSize: $r('app.float.font_16')
      })
    }
    .width(ConfigData.WH_100_100)
    .onClick(() => {
      if (this.lockUi) {
        return;
      }
      this.lockUi = true;
      LogUtil.info(this.TAG_PAGE + ' item onclick : item = ' + JSON.stringify(item));
      this.gotoNextPage(item);
      this.lockUi = false;
    });
  }

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.biometricsAndPassword'), isActive: true });

          List({ space: this.listSpace }) {
            ForEach(this.passwordList, (group: PasswordSettingItem[]) => {

              // section title
              if (group[0].settingIsSectionTitle && group[0].settingShouldDisplay) {
                ListItem() {
                  Text(group[0].settingTitle)
                    .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                    .fontSize($r("app.float.font_14"))
                    .lineHeight($r("app.float.lineHeight_19"))
                    .textAlign(TextAlign.Start)
                    .margin({ top: $r("app.float.distance_9_5") })
                    .padding({ left: $r('app.float.distance_12'), right: $r('app.float.distance_12') })
                    .width(ConfigData.WH_100_100);
                }
              }

              ListItem() {
                List() {
                  // item 0 is section title
                  ForEach(group, (item: PasswordSettingItem, index: number) => {
                    if (index > 0 && item.settingShouldDisplay) {
                      ListItem() {
                        if (item.settingAlias == "face_recognition") {
                          // face recognition item
                          this.FaceAuthItem();
                        } else if (item.settingAlias == 'password_disable_password') {
                          // disable password item
                          this.DisablePasswordItem(item);
                        } else {
                          // normal item
                          this.NormalItem(item);
                        }
                      }
                    }
                  });
                }
                .padding($r('app.float.distance_4'))
                .width(ConfigData.WH_100_100)
                .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
                .borderRadius($r('app.float.radius_24'))
                .divider({
                  strokeWidth: $r('app.float.divider_wh'),
                  color: $r('app.color.color_E3E3E3_grey'),
                  startMargin: $r('app.float.wh_value_15'),
                  endMargin: $r('app.float.wh_value_15')
                })
              }
            });
          }
          .margin({ top: $r('app.float.wh_value_8') })
        }
        .padding({
          left: $r('sys.float.ohos_id_card_margin_start'),
          right: $r('sys.float.ohos_id_card_margin_end')
        })
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

  //------------------------------ Router ---------------------------
  /**
   * Go to password page
   *
   * @param uri : page uri
   * @param pageRequestCode : page request code
   */
  @Log
  gotoNextPage(item: PasswordSettingItem) {
    if (!item.settingUri) {
      return;
    }
    Router.push({
      uri: item.settingUri,
      params: {
        'pageRequestCode': item.settingRequestCode,
        'prevPageUri': 'pages/passwordSetting',
        'pinChallenge': this.pinChallenge
      },
    });
  }

  //------------------------------ Dialog ---------------------------
  /**
   * Close password dialog
   * @param item password setting item
   */
  @Log
  showClosePasswordDialog(delItem: PasswordSettingItem) {
    AlertDialog.show({
      title: $r("app.string.password_disable_password"),
      message: $r("app.string.password_disable_prompt"),

      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          LogUtil.info(this.TAG_PAGE + 'ClosePasswordDialog cancel click callback.');
        }
      },
      secondaryButton: {
        value: $r('app.string.disable_'),
        action: () => {
          LogUtil.info(this.TAG_PAGE + 'ClosePasswordDialog disable click callback.');
          this.gotoNextPage(delItem);
        }
      },
      cancel: () => {
        LogUtil.info(this.TAG_PAGE + 'ClosePasswordDialog Closed callbacks');
      },
      autoCancel: true,
      alignment: this.isPhoneOrRK ? DialogAlignment.Bottom : DialogAlignment.Center,
      offset: ({ dx: 0, dy: this.isPhoneOrRK ? '-24dp' : 0 })
    })
  }
}