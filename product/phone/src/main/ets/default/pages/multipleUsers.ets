// @ts-nocheck
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
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import ResourceUtil from '../../../../../../../common/search/src/main/ets/default/common/ResourceUtil.ets';
import {TitleText} from '../../../../../../../common/component/src/main/ets/default/textComponent.ets';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import SystemAccountController from '../model/usersAndAccounts/systemAccountController.ets';
import SystemAccountModel from '../model/usersAndAccounts/systemAccountModel.ets';
import router from '@system.router';

@Entry
@Component
struct MultipleUsers {
  @StorageLink("isShowAddUser") isShowAddUser: boolean = false;
  @StorageLink("isShowAddGuest") isShowAddGuest: boolean = false;
  @StorageLink("systemAccoutList") userList: any[] = [];
  @StorageLink("isShowDelete") isShowDelete: boolean = false;
  private addUserDialogController: CustomDialogController = new CustomDialogController({
    builder: AddUserDialog({ controller: this.addUserDialogController, account: {} })
  });

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: Alignment.Center, justifyContent: FlexAlign.SpaceBetween }) {
      Column() {
        // head
        HeadComponent({ headName: $r('app.string.user'), isActive: true });

        // user list
        List() {
          ForEach(this.userList, userItem => {
            ListItem() {
                UserItem({ user: userItem })
            }
          })
        }
        .divider({ strokeWidth: $r('app.float.wh_value_1'), color: $r('app.color.color_E3E3E3_grey'),
          startMargin: $r('app.float.wh_value_20'), endMargin: $r('app.float.wh_value_20') })
        .borderRadius($r("app.float.radius_24"))
        .backgroundColor($r("app.color.white_bg_color"))
        .padding($r('app.float.distance_4'))
        .margin({top: $r("app.float.distance_16"), bottom: $r("app.float.distance_8")})
        .visibility(this.userList.length > 0 ? Visibility.Visible : Visibility.None)

        // Add user, shown when is administrator
        TitleText({
          title: $r("app.string.addUser"),
          color: Color.Blue,
          visibility: this.isShowAddUser ? Visibility.Visible : Visibility.None,
          clickEvent: (event => {
            LogUtil.info("Add user.");
            this.addUserDialogController.open();
          }).bind(this)
        })

        /**
         * Add guest, shown with conditions:
         * 1. Current user is administrator
         * 2. Guest is not created.
         */
        TitleText({
          title: $r("app.string.addGuest"),
          color: Color.Blue,
          visibility: this.isShowAddGuest ? Visibility.Visible : Visibility.None,
          clickEvent: ((event) => {
            AlertDialog.show({
              message: $r("app.string.askAddGuest"),
              primaryButton: {
                value: $r("app.string.cancel"),
                action: () => {
                  LogUtil.info("Cancel add guest.");
                }
              },
              secondaryButton: {
                value: $r("app.string.confirm"),
                action: () => {
                  LogUtil.info("Confirm add guest user.");
                  SystemAccountController.createQuest();
                }
              },
              cancel: () => {
                LogUtil.info("Cancel dialog.")
              }
            })
          }).bind(this)
        })
      }
      .height(ConfigData.WH_90_100)
      .alignItems(HorizontalAlign.Start)

      if (this.isShowDelete) {
        Column() {
          Image($r("app.media.ic_delete"))
            .height($r("app.float.wh_value_40"))
            .width($r("app.float.wh_value_40"))
            .margin({ top: $r("app.float.wh_value_20"), bottom: $r("app.float.wh_value_10") })
          Text($r("app.string.deleteButton"))
            .fontSize($r("app.float.font_20"))
            .fontColor(Color.Black)
            .margin({ bottom: $r("app.float.wh_value_10") })
        }
        .width(ConfigData.WH_100_100)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          AlertDialog.show({
            message: $r("app.string.deleteUserWarn"),
            primaryButton: {
              value: $r("app.string.cancel"),
              action: () => {
                LogUtil.info("Cancel delete user.");
              }
            },
            secondaryButton: {
              value: $r("app.string.deleteButton"),
              action: () => {
                LogUtil.info("Confirm delete user.");
                SystemAccountController.removeAccount();
              }
            }
          });
        })
      }
    }
    .height(ConfigData.WH_100_100)
    .padding({left:$r('app.float.distance_24'), right:$r('app.float.distance_24')})
    .align(Alignment.Center)
    .height(ConfigData.WH_100_100)
    .width(ConfigData.WH_100_100)
    .backgroundColor($r("app.color.color_E3E3E3_grey"));
  }

  aboutToAppear() {
    LogUtil.info("Multiple user list about to appear.")
    SystemAccountController.refreshSystemAccountList();
    LogUtil.info("after appear.");
  }

  aboutToDisappear() {
    LogUtil.info('multiple user about to disappear.');
    AppStorage.SetOrCreate("systemAccoutList", []);
  }

  onBackPress() {
    LogUtil.info('multiple user on back press.');
    AppStorage.SetOrCreate("systemAccoutList", []);
    router.back();
  }

}

@Component
struct UserItem {
  private user: any;
  @State isTouched:boolean = false;
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: UserItemDialog({ dialogController: this.dialogController, user: this.user }),
    autoCancel: false
  });

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      Row() {
        Image("/res/image/ic_user_portrait.svg")
          .width($r("app.float.wh_value_50"))
          .height($r("app.float.wh_value_50"))
          .margin({ left: $r("app.float.wh_value_12"), right: $r("app.float.wh_value_12") })
        Column() {
            Text(this.user.localName)
              .fontSize($r("app.float.font_24"))
              .fontColor(Color.Black)
          if (SystemAccountController.isShowIdentity(this.user)) {
            Text(SystemAccountModel.getIdentityFromMap(this.user.type))
              .fontSize($r("app.float.font_22"))
              .fontColor(Color.Black)
          }
        }
      }

      Image($r("app.media.ic_settings_arrow"))
        .width($r("app.float.wh_value_40"))
        .height($r("app.float.wh_value_40"))
        .margin({ right: $r("app.float.distance_16") })
    }
    .height($r("app.float.wh_value_100"))
    .onClick(event => {
      LogUtil.info("Click the multiple user item.");
      if (SystemAccountController.isCurrentAdministrator() || SystemAccountController.isCurrentUser(this.user)
        && !SystemAccountController.isGuestAccount(this.user)) {
        this.dialogController.open();
        return;
      }
      if (!SystemAccountController.isCurrentQuest() || !SystemAccountController.isGuestAccount(this.user)) {
        AlertDialog.show({
          message: $r("app.string.switchUser"),
          primaryButton: {
            value: $r("app.string.cancel"),
            action: () => {
              LogUtil.info("Cancel switch to user.");
            }
          },
          secondaryButton: {
            value: $r("app.string.confirm"),
            action: () => {
              SystemAccountController.switchUser(this.user.localId);
            }
          }
        });
      }
    })
    .borderRadius($r('app.float.radius_24'))
    .backgroundColor(this.isTouched ? $r("app.color.color_D8D8D8_grey") : $r("app.color.white_bg_color"))
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isTouched = true;
      }
      if (event.type === TouchType.Up) {
        this.isTouched = false;
      }
    });
  }
}

// Current user item dialog, allow user to set user name and profile image.
@CustomDialog
struct UserItemDialog {
  private user: UserData;
  private dialogController: CustomDialogController;

  build() {
    if (SystemAccountController.isCurrentUser(this.user)) {
      CurrentDialogBuilder({ controller: this.dialogController, user: this.user });
    } else {
      UserDialogBuilder({ controller: this.dialogController, user: this.user });
    }
  }
}

@Component
struct CurrentDialogBuilder {
  private controller: CustomDialogController;
  private user: UserData;
  private tempName: string = "";

  build() {
    Column() {
      Image("/res/image/ic_user_portrait.svg")
        .width($r("app.float.wh_value_60"))
        .height($r("app.float.wh_value_60"))
        .margin({ top: $r("app.float.wh_value_20"), bottom: $r("app.float.wh_value_20") })
        .onClick((event) => {
          LogUtil.info("Click to modify user image.")
          new CustomDialogController({
            builder: ChooseImageDialog({ controller: this.controller })
          }).open();
        })
      Text($r("app.string.addUserImage"))
        .fontSize($r("app.float.font_22"))
        .fontColor(Color.Black)
        .margin({ bottom: $r("app.float.wh_value_20") })
      TextInput({ text: this.user.localName })
        .placeholderColor(Color.Black)
        .placeholderFont({ size: $r("app.float.font_24"), weight: FontWeight.Normal, style: FontStyle.Normal })
        .width(ConfigData.WH_100_100)
        .borderRadius($r("app.float.search_input_border_radius"))
        .margin({ bottom: $r("app.float.wh_value_20") })
        .onChange((value: string) => {
          LogUtil.info("Set current account name, name: " + value);
          this.tempName = value;
        })
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button($r("app.string.cancel"))
          .backgroundColor(Color.White)
          .fontSize($r("app.float.font_24"))
          .fontColor(Color.Blue)
          .fontWeight(FontWeight.Medium)
          .width(ConfigData.WH_50_100)
          .onClick(() => {
            LogUtil.info("Cancel current user modify dialog.");
            this.controller.close();
          })
        Button($r("app.string.confirm"))
          .backgroundColor(Color.White)
          .fontSize($r("app.float.font_24"))
          .fontColor(Color.Blue)
          .fontWeight(FontWeight.Medium)
          .width(ConfigData.WH_50_100)
          .onClick(() => {
            LogUtil.info("Confirm current user modify dialog.");
            this.controller.close();
            SystemAccountController.setAccountName(this.user.localId, this.tempName);
          })
      }.margin({ bottom: $r("app.float.wh_value_40") })
    }
    .margin({ left: $r("app.float.wh_value_20"), right: $r("app.float.wh_value_20") })
  }
}

// Current user item dialog, allow user to set user name and profile image.
@Component
struct UserDialogBuilder {
  private controller: CustomDialogController;
  private user: any;

  build() {
    Column() {
      Text(this.user.localName)
        .fontSize($r("app.float.font_35"))
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.Black)
        .margin({ bottom: $r("app.float.wh_value_20"), top: $r("app.float.wh_value_20") })

      Text($r("app.string.switchUser"))
        .fontSize($r("app.float.font_24"))
        .fontColor(Color.Black)
        .margin({ bottom: $r("app.float.wh_value_10") })
        .height($r("app.float.wh_value_50"))
        .width(ConfigData.WH_100_100)
        .textAlign(TextAlign.Start)
        .onClick((event) => {
          this.controller.close();
          SystemAccountController.switchUser(this.user.localId);
        })

      Divider()

      Text($r("app.string.removeUser"))
        .fontSize($r("app.float.font_24"))
        .fontColor(Color.Black)
        .height($r("app.float.wh_value_50"))
        .margin({ top: $r("app.float.wh_value_10") })
        .width(ConfigData.WH_100_100)
        .textAlign(TextAlign.Start)
        .onClick(() => {
          AlertDialog.show({
            message: $r("app.string.deleteUserWarn"),
            primaryButton: {
              value: $r("app.string.cancel"),
              action: () => {
                LogUtil.info("Cancel delete user.");
              }
            },
            secondaryButton: {
              value: $r("app.string.deleteButton"),
              action: () => {
                LogUtil.info("Confirm delete user.");
                SystemAccountController.removeAccount(this.user.localId);
              }
            },
          });
          this.controller.close();
        })

      Button($r("app.string.cancel"))
        .fontSize($r("app.float.font_24"))
        .fontColor(Color.Blue)
        .backgroundColor(Color.White)
        .margin({ top: $r("app.float.wh_value_20"), bottom: $r("app.float.wh_value_20") })
        .width(ConfigData.WH_100_100)
        .onClick(() => {
          LogUtil.info("Cancel user operation dialog.");
          this.controller.close();
        })
    }
    .alignItems(HorizontalAlign.Start)
    .margin({ left: $r("app.float.wh_value_40"), right: $r("app.float.wh_value_40") })
  }
}

@CustomDialog
struct AddUserDialog {
  @State buttonState: boolean = false;
  @State hintText: string = '';
  private controller: CustomDialogController;
  private account;

  build() {
    Column() {
      Text($r("app.string.addNewUser"))
        .fontSize($r("app.float.font_35"))
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.Black)
        .margin({ top: $r("app.float.wh_value_40"), bottom: $r("app.float.wh_value_20") })
      Image("/res/image/ic_user_portrait.svg")
        .width($r("app.float.wh_value_60"))
        .height($r("app.float.wh_value_60"))
        .margin({ top: $r("app.float.wh_value_20"), bottom: $r("app.float.wh_value_40") })
      TextInput({
        placeholder: this.hintText
      })
        .placeholderFont({ size: $r("app.float.font_24") })
        .placeholderColor(Color.Brown)
        .margin({ bottom: $r("app.float.wh_value_20") })
        .borderRadius($r("app.float.search_input_border_radius"))
        .onChange((value: string) => {
          LogUtil.info("Set the user name: " + value);
          this.account.localName = value;
          this.buttonState = value != "";
          LogUtil.info("Set the user name, name: " + this.account.localName);
        })
      Text($r("app.string.addUserDescription"))
      Flex({ direction: FlexDirection.Row, alignItems: Alignment.Center }) {
        Button($r("app.string.cancel"))
          .backgroundColor(Color.White)
          .fontSize($r("app.float.font_24"))
          .fontColor(Color.Blue)
          .fontWeight(FontWeight.Medium)
          .width(ConfigData.WH_50_100)
          .onClick(() => {
            LogUtil.info("Cancel add new user.");
            this.controller.close();
          })

        Button($r("app.string.confirm"))
          .backgroundColor(Color.White)
          .fontSize($r("app.float.font_24"))
          .fontColor(Color.Blue)
          .fontWeight(FontWeight.Medium)
          .width(ConfigData.WH_50_100)
          .enabled(this.buttonState)
          .opacity(this.buttonState ? 1 : 0.5)
          .onClick(() => {
            LogUtil.info("Confirm Add new user.");
            this.controller.close();
            SystemAccountController.createSystemAccount(this.account.localName);
            AlertDialog.show({
              message: $r("app.string.askSwitchUser"),
              primaryButton: {
                value: $r("app.string.cancel"),
                action: () => {
                  LogUtil.info("Cancel switch to new user.");
                }
              },
              secondaryButton: {
                value: $r("app.string.switchButton"),
                action: () => {
                  LogUtil.info("Confirm switch to new user.");
                  SystemAccountController.switchToCreatedAccount();
                }
              },
              cancel: () => {
                LogUtil.info("Cancel dialog.")
              }
            })
          })
      }
      .margin({
        bottom: $r("app.float.wh_value_40"),
        top: $r("app.float.wh_value_20")
      })
    }
    .margin({
      left: $r("app.float.wh_value_20"),
      right: $r("app.float.wh_value_20")
    })
  }

  aboutToAppear() {
    ResourceUtil.getString($r("app.string.nickname")).then(value => this.hintText = value);
  }
}

@CustomDialog
struct ChooseImageDialog {
  private controller: CustomDialogController;

  build() {
    Column() {
      Text($r("app.string.takePhoto"))
        .fontSize($r("app.float.font_24"))
        .fontColor(Color.Black)
        .onClick(() => {
          router.push({ uri: "" });
        })
      Text($r("app.string.chooseFromShop"))
        .fontSize($r("app.float.font_24"))
        .fontColor(Color.Black)
        .onClick(() => {
          router.push({ uri: "" })
        })
    }
  }
}
