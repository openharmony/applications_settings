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
import prompt from '@system.prompt';
import FeatureAbility from '@ohos.ability.featureAbility';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import Log from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator.ets';
import PasswordListController from '../controller/password/PasswordSettingController.ets';
import EntryComponent from '../../../../../../../common/component/src/main/ets/default/EntryComponent.ets';
import Router from '@system.router';

@Entry
@Component
struct PasswordSetting {
  private TAG_PAGE = ConfigData.TAG + 'PasswordSetting page ';
  private mController: PasswordListController = new PasswordListController();

// bind Properties
  @State private passwordList: any[] = [];
  private pinChallenge: string = '';

// private Properties
  private lockUi: boolean = false // prevent continuous and multiple clicks
  private delItem: any;

// dialog
  private unlockDialog : CustomDialogController = new CustomDialogController({
    builder: UnlockDialog({
      confirmAction: (item) => {
        LogUtil.info(this.TAG_PAGE + ' dialog disable button onclick.')
        this.gotoNextPage(this.delItem);
      }
    }),
    autoCancel: true
  });

  @Log
  aboutToAppear(): void {

    // bind component and initialize
    this.mController.bindComponent(this)
      .bindProperties(["passwordList", "pinChallenge"])
      .initData()
      .subscribe();
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

  build() {
    Column() {
      HeadComponent({ headName: $r('app.string.biometricsAndPassword'), isActive: true })

      List() {
        ForEach(this.passwordList, (item) => {

          if (item.settingShouldDisplay) {

            if (item.settingIsSectionTitle) {
              ListItem() {
                Text(item.settingTitle).sectionTitle()
              }

            } else if (item.settingAlias == 'password_disable_password')  {
              ListItem() {
                EntryComponent({
                  settingIcon: '',
                  settingTitle: item.settingTitle,
                  settingSummary: '',
                  settingValue: item.settingValue,
                  settingArrow: item.settingArrow,
                  settingArrowStyle: '',
                  settingUri: item.settingUri,
                  titleFontColor: Color.Blue
                });
              }
              .height($r('app.float.wh_value_70'))
              .onClick(() => {
                if (this.lockUi) {
                  return;
                }
                this.lockUi = true
                LogUtil.info(this.TAG_PAGE + ' disable password onclick : item = ' + JSON.stringify(item))
                this.delItem = item
                this.unlockDialog.open();
                this.lockUi = false
              });

            } else if (item.settingAlias == "face_recognition") {
              ListItem() {
                EntryComponent({
                  settingIcon: '',
                  settingTitle: item.settingTitle,
                  settingSummary: '',
                  settingValue: item.settingValue,
                  settingArrow: item.settingArrow,
                  settingArrowStyle: '',
                  settingUri: item.settingUri,
                  titleFontColor: Color.Blue
                });
              }
              .height($r('app.float.wh_value_70'))
              .onClick(()=>{
                FeatureAbility.startAbility({
                  want: {
                    bundleName: ConfigData.FACEAUTH_BUNDLE_NAME,
                    abilityName: ConfigData.FACEAUTH_ABILITY_NAME
                  }
                })
                  .then((data) => {
                    LogUtil.info(`${this.TAG_PAGE}, ${ConfigData.FACEAUTH_BUNDLE_NAME} start successful. Data: ${JSON.stringify(data)}`);
                  })
                  .catch((error) => {
                    prompt.showToast({
                      message: $r("app.string.faceauthFailed"),
                      duration: 2000
                    })
                    LogUtil.error(`${this.TAG_PAGE}, ${ConfigData.FACEAUTH_BUNDLE_NAME} start failed. Cause: ${JSON.stringify(error)}`);
                  })
              })
            } else {
              ListItem() {
                EntryComponent({
                  settingIcon: '',
                  settingTitle: item.settingTitle,
                  settingSummary: '',
                  settingValue: item.settingValue,
                  settingArrow: item.settingArrow,
                  settingArrowStyle: '',
                  settingUri: item.settingUri,
                });
              }
              .height($r('app.float.wh_value_70'))
              .onClick(() => {
                if (this.lockUi) {
                  return;
                }
                this.lockUi = true
                LogUtil.info(this.TAG_PAGE + ' item onclick : item = ' + JSON.stringify(item))
                this.gotoNextPage(item)
              });
            }
          }
        });
      }
      .divider({
        strokeWidth: 1,
        color: $r('app.color.color_E3E3E3_grey'),
        startMargin: $r('app.float.wh_value_65'),
        endMargin: $r('app.float.wh_value_15')
      })
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100)
      .alignSelf(ItemAlign.Start);

    }
  }

//------------------------------ Router ---------------------------
/**
   * Go to password page
   *
   * @param uri : page uri
   * @param pageRequestCode : page request code
   */
  @Log
  gotoNextPage(item: any) {
    if (!item.settingUri) {
      return
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
}

@CustomDialog
struct UnlockDialog {
  controller: CustomDialogController;
  item: any;
  confirmAction: (item: any) => void;

  @Log
  closeDialog() {
    this.controller.close();
  }

  build() {
    Column() {
      // title
      Row() {
        Text($r("app.string.password_select_unlock_method"))
          .height($r('app.float.wh_value_60'))
          .margin({ left: $r('app.float.wh_value_30') })
          .width(ConfigData.WH_100_100)
          .fontSize($r('app.float.font_28'));
      }

      // message
      Row() {
        Text($r("app.string.password_disable_prompt"))
          .margin({
            top: $r('app.float.item_common_vertical_margin'),
            bottom: $r('app.float.item_common_vertical_margin'),
            left: $r('app.float.wh_value_30') })
          .fontSize($r('app.float.font_22'));
      }

      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button() {
          Text($r('app.string.cancel'))
            .dialogBtnName()
        }
        .dialogBtn()
        .align(Alignment.Bottom)
        .onClick(() => {
          this.closeDialog();
        });
        Button() {
          Text($r('app.string.disable_'))
            .dialogBtnName()
        }
        .dialogBtn()
        .align(Alignment.Bottom)
        .onClick(() => {
          this.confirmAction(this.item)
          this.closeDialog();
        });
      }
      .width(ConfigData.WH_100_100)
      .margin({
        top: $r('app.float.item_common_vertical_margin'),
        bottom: $r('app.float.item_common_vertical_margin') })
    }
  }
}

@Extend(Text) function sectionTitle () {
  .width(ConfigData.WH_100_100)
  .height($r('app.float.wh_value_60'))
  .fontSize($r('app.float.font_20'))
  .fontWeight(FontWeight.Normal)
  .fontColor(Color.Grey)
  .maxLines(ConfigData.MAX_LINES_1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .margin({ left: $r('app.float.wh_value_15'), right: $r('app.float.wh_value_15') })
}

@Extend(Text) function dialogBtnName () {
  .fontSize($r('app.float.application_button_subtitle_size'))
  .fontColor(Color.Blue)
  .textCase(TextCase.UpperCase)
}

@Extend(Button) function dialogBtn () {
  .backgroundColor($r('app.color.color_E3E3E3_grey'))
  .width($r("app.float.wh_value_210"))
  .height($r("app.float.wh_value_60"))
}
