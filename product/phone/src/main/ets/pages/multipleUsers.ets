// @ts-nocheck
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

import router from '@system.router';
import deviceInfo from '@ohos.deviceInfo';
import InputMethod from '@ohos.inputmethod';
import osAccount from '@ohos.account.osAccount';
import { MAX_LENGTH } from '../model/usersAndAccounts/systemAccountModel';
import SystemAccountModel from '../model/usersAndAccounts/systemAccountModel';
import SystemAccountController from '../model/usersAndAccounts/SystemAccountController';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import { TitleText } from '../../../../../../common/component/src/main/ets/default/textComponent';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import ResourceUtil from '../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import { DialogButtonLayout, DialogButtonLayoutWithState } from '../../../../../../common/component/src/main/ets/default/dialogComponent';

const deviceTypeInfo = deviceInfo.deviceType;

@Entry
@Component
struct MultipleUsers {
  @StorageLink("isShowAddUser") isShowAddUser: boolean = false;
  @StorageLink("isShowAddGuest") isShowAddGuest: boolean = false;
  @StorageLink("systemAccountList") userList: osAccount.OsAccountInfo[] = [];
  @StorageLink("isShowDelete") isShowDelete: boolean = false;

  private addUserDialogController: CustomDialogController = new CustomDialogController({
    builder: AddUserDialog({
      controller: this.addUserDialogController,
      account: {},
      confirm: this.onConfirm.bind(this),
    }),
    alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
    offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 }),
    autoCancel: true
  });

  private waitDialogController: CustomDialogController = new CustomDialogController({
    builder: WaitDialog({ controller: this.waitDialogController, content: $r("app.string.isCreatingUser") }),
    autoCancel: false,
    alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
    offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 }),
  });

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          Flex({
            direction: FlexDirection.Column,
            alignItems: Alignment.Center,
            justifyContent: FlexAlign.SpaceBetween
          }) {
            Column() {
              // head
              HeadComponent({ headName: $r('app.string.user'), isActive: true });

              // user list
              List() {
                ForEach(this.userList, userItem => {
                  ListItem() {
                    UserItem({ user: userItem });
                  }
                })
              }
              .margin({ top: $r("app.float.distance_14") })
              .divider({
                strokeWidth: $r('app.float.divider_wh'),
                color: $r('sys.color.ohos_id_color_list_separator'),
                startMargin: $r('app.float.wh_value_20'),
                endMargin: $r('app.float.wh_value_20')
              })
              .borderRadius($r("app.float.radius_24"))
              .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
              .visibility(this.userList.length > 0 ? Visibility.Visible : Visibility.None)

              // Add user, shown when is administrator
              if (this.isShowAddUser) {
                TitleText({
                  title: $r("app.string.addUser"),
                  color: $r("app.color.font_color_007DFF"),
                  visible: this.isShowAddUser ? Visibility.Visible : Visibility.None,
                  clickEvent: (event => {
                    LogUtil.info("Add user.");
                    this.addUserDialogController.open();
                  })
                })
              }

              /**
               * Add guest, shown with conditions:
               * 1. Current user is administrator
               * 2. Guest is not created.
               */
              if (this.isShowAddGuest) {
                TitleText({
                  title: $r("app.string.addGuest"),
                  color: $r("app.color.font_color_007DFF"),
                  visible: this.isShowAddGuest ? Visibility.Visible : Visibility.None,
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
                          this.waitDialogController.open();
                          SystemAccountController.createQuest((() => {
                            this.waitDialogController.close();
                          }).bind(this));
                        }
                      },
                      alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
                      offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 }),
                      cancel: () => {
                        LogUtil.info("Cancel dialog.");
                      }
                    })
                  }).bind(this)
                })
              }
            }
            .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
            .height(ConfigData.WH_90_100)
            .alignItems(HorizontalAlign.Start)

            if (this.isShowDelete) {
              Column() {
                Image($r("app.media.ic_delete"))
                  .height($r("app.float.wh_value_40"))
                  .width($r("app.float.wh_value_40"))
                  .fillColor($r("sys.color.ohos_id_color_primary"))
                  .margin({ top: $r("app.float.wh_value_20"), bottom: $r("app.float.wh_value_10") })

                Text($r("app.string.deleteButton"))
                  .fontSize($r("app.float.font_20"))
                  .fontColor($r("app.color.font_color_182431"))
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
                  },
                  alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
                  offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 })
                });
              })
            }
          }
        }
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

  onConfirm(localName: string) {
    LogUtil.info("Open creating wait dialog");
    this.waitDialogController.open();
    SystemAccountController.createSystemAccount(localName, ((account) => {
      this.waitDialogController.close();
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
        alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
        offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 }),
        cancel: () => {
          LogUtil.info("Cancel dialog.");
        }
      })
    }));
  }

  onPageShow() {
    LogUtil.info("Multiple user list about to appear.")
    SystemAccountController.refreshSystemAccountList();
    LogUtil.info("after appear.");
  }

  aboutToDisappear() {
    LogUtil.info('multiple user about to disappear.');
    AppStorage.SetOrCreate("systemAccountList", []);
  }

  onBackPress() {
    LogUtil.info('settings MultipleUsers onBackPress');
  }
}

@Component
struct UserItem {
  private user: osAccount.OsAccountInfo;
  @State isTouched: boolean = false;

  private dialogController: CustomDialogController = new CustomDialogController({
    builder: UserItemDialog({ dialogController: this.dialogController, user: this.user }),
    autoCancel: false,
    alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
    offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 })
  });

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      Row() {
        Image("/res/image/ic_user_portrait.svg")
          .width($r("app.float.wh_value_40"))
          .height($r("app.float.wh_value_40"))
          .margin({ left: $r("app.float.wh_value_12"), right: $r("app.float.wh_value_12") })

        Column() {
          Text(this.user.localName)
            .fontSize($r("app.float.font_16"))
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .margin({ bottom: $r('sys.float.ohos_id_text_margin_vertical') })

          if (SystemAccountController.isShowIdentity(this.user)) {
            Text(SystemAccountModel.getIdentityFromMap(this.user.type))
              .fontSize($r('sys.float.ohos_id_text_size_body2'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          }
        }
        .alignItems(HorizontalAlign.Start)
      }

      Image($r("app.media.ic_settings_arrow"))
        .width($r("app.float.wh_value_12"))
        .height($r("app.float.wh_value_24"))
        .margin({ right: $r("app.float.distance_11") })
        .fillColor($r("sys.color.ohos_id_color_primary"))
        .opacity($r("app.float.opacity_0_2"))
    }
    .height($r("app.float.wh_value_80"))
    .onClick((event) => {
      LogUtil.info("Click the multiple user item.");
      if (SystemAccountController.isCurrentAdministrator() ||
      SystemAccountController.isCurrentUser(this.user) && !SystemAccountController.isGuestAccount(this.user)) {
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
          },
          alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
          offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 })
        });
      }
    })
    .borderRadius($r('app.float.radius_20'))
    .linearGradient(this.isTouched ? {
                                       angle: 90,
                                       direction: GradientDirection.Right,
                                       colors: [[$r("app.color.DCEAF9"), 0.0], [$r("app.color.FAFAFA"), 1.0]]
                                     } : {
                                           angle: 90,
                                           direction: GradientDirection.Right,
                                           colors: [[$r("sys.color.ohos_id_color_foreground_contrary"), 1], [$r("sys.color.ohos_id_color_foreground_contrary"), 1]]
                                         })
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
  private user: osAccount.OsAccountInfo;
  private dialogController: CustomDialogController;

  build() {
    if (SystemAccountController.isCurrentUser(this.user)) {
      CurrentDialogBuilder({
        controller: this.dialogController,
        user: this.user
      });
    } else {
      UserDialogBuilder({
        controller: this.dialogController,
        user: this.user
      });
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
        .width($r("app.float.wh_value_40"))
        .height($r("app.float.wh_value_40"))
        .margin({ top: $r("app.float.wh_value_24"), bottom: $r("app.float.wh_value_13") })
        .onClick((event) => {
          LogUtil.info("Click to modify user image.")
          let chooseImageDialog = new CustomDialogController({
            builder: ChooseImageDialog(),
            alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
            offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 })
          });
          chooseImageDialog.open();
        })

      Text($r("app.string.addUserImage"))
        .fontFamily('HarmonyHeiTi')
        .fontSize($r("app.float.font_16"))
        .height($r("app.float.wh_value_22"))
        .fontColor($r("sys.color.ohos_id_color_primary"))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: $r("app.float.wh_value_8") })

      TextInput({ text: this.user.localName })
        .placeholderColor($r("app.color.font_color_182431"))
        .placeholderFont({
          size: $r("app.float.font_16"),
          weight: FontWeight.Regular,
          style: FontStyle.Normal
        })
        .width(ConfigData.WH_100_100)
        .height($r("app.float.wh_value_48"))
        .borderRadius($r("app.float.search_input_border_radius"))
        .maxLength(MAX_LENGTH)
        .padding({ left: $r("app.float.wh_value_12"), right: $r("app.float.wh_value_12") })
        .backgroundColor($r('app.color.color_00000000_transparent'))
        .onChange((value: string) => {
          LogUtil.info("Set current account name, name: " + value);
          this.tempName = value;
        })
        .onSubmit((enterKey) => {
          InputMethod.getInputMethodController().stopInput()
            .then((ret) => {
              LogUtil.debug(`${ConfigData.TAG}, enterType: ${enterKey}, stopInput: ${ret}`);
            });
        })

      Divider()
        .margin({
          left: $r("app.float.wh_value_12"),
          right: $r("app.float.wh_value_12"),
          bottom: $r("app.float.distance_9")
        })
        .color($r("sys.color.ohos_id_color_list_separator"))

      DialogButtonLayout({
        firstClickEvent: () => {
          LogUtil.info("Cancel current user modify dialog.");
          this.controller.close();
        },
        secondClickEvent: () => {
          LogUtil.info("Confirm current user modify dialog.");
          this.controller.close();
          SystemAccountController.setAccountName(this.user.localId, this.tempName);
        }
      })
    }
    .padding({ left: $r("app.float.wh_value_12"), right: $r("app.float.wh_value_12") })
    .borderRadius('24vp')
    .height('220vp')
  }
}

// Current user item dialog, allow user to set user name and profile image.
@Component
struct UserDialogBuilder {
  private controller: CustomDialogController;
  private user: osAccount.OsAccountInfo;
  private waitController: CustomDialogController = new CustomDialogController({
    builder: WaitDialog({
      controller: this.waitController,
      content: $r("app.string.isRemoving")
    }),
    alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
    offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 }),
    autoCancel: false
  });

  build() {
    Column() {
      Text(this.user.localName)
        .fontSize($r("app.float.font_20"))
        .fontWeight(FontWeight.Medium)
        .fontColor($r("app.color.font_color_182431"))
        .height($r("app.float.wh_value_56"))

      Text($r("app.string.switchUser"))
        .fontSize($r("app.float.font_16"))
        .fontColor($r("app.color.font_color_182431"))
        .height($r("app.float.wh_value_48"))
        .width(ConfigData.WH_100_100)
        .textAlign(TextAlign.Start)
        .onClick((event) => {
          this.controller.close();
          SystemAccountController.switchUser(this.user.localId);
        })

      Divider()
        .color($r("sys.color.ohos_id_color_list_separator"))

      Text($r("app.string.removeUser"))
        .fontSize($r("app.float.font_16"))
        .fontColor($r("app.color.font_color_182431"))
        .height($r("app.float.wh_value_48"))
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
                this.waitController.open();
                SystemAccountController.removeAccount(this.user.localId, () => {
                  this.waitController.close();
                });
              }
            },
            alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
            offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 })
          });
          this.controller.close();
        })

      Button($r("app.string.cancel"))
        .fontSize($r("app.float.font_16"))
        .fontColor($r("app.color.font_color_182431"))
        .backgroundColor(Color.White)
        .margin({ top: $r("app.float.wh_value_16"), bottom: $r("app.float.wh_value_16") })
        .width(ConfigData.WH_100_100)
        .onClick(() => {
          LogUtil.info("Cancel user operation dialog.");
          this.controller.close();
        })
    }
    .alignItems(HorizontalAlign.Start)
    .margin({ left: $r("app.float.wh_value_24"), right: $r("app.float.wh_value_24") })
  }
}

@CustomDialog
struct AddUserDialog {
  @State buttonState: boolean = false;
  @State hintText: string = '';
  @State isWarn: boolean = false;
  private controller: CustomDialogController;
  private confirm: (localName: string) => void;
  private account;

  build() {
    Column() {
      Text($r("app.string.addNewUser"))
        .fontSize($r("app.float.font_20"))
        .fontWeight(FontWeight.Medium)
        .fontColor($r("sys.color.ohos_id_color_primary"))
        .height($r("app.float.wh_value_56"))
        .width(ConfigData.WH_100_100)
        .textAlign(TextAlign.Start)
        .padding({ right: $r("app.float.wh_value_12"), left: $r("app.float.wh_value_12") })

      Image("/res/image/ic_user_camera.svg")
        .width($r("app.float.wh_value_40"))
        .height($r("app.float.wh_value_40"))
        .margin({ bottom: $r("app.float.wh_value_32") })

      TextInput({ placeholder: this.hintText })
        .placeholderFont({ size: $r("app.float.font_16") })
        .placeholderColor($r("app.color.font_color_182431"))
        .borderRadius($r("app.float.search_input_border_radius"))
        .maxLength(MAX_LENGTH)
        .width(ConfigData.WH_100_100)
        .padding({ left: $r("app.float.wh_value_12"), right: $r("app.float.wh_value_12") })
        .borderRadius(0)
        .backgroundColor($r('app.color.color_00000000_transparent'))
        .onChange((value: string) => {
          LogUtil.info("Set the user name: " + value);
          this.account.localName = value;
          this.isWarn = SystemAccountController.isAlreadyCreated(value);
          this.buttonState = value != "" && !this.isWarn;
          LogUtil.info("Set the user name, name: " + this.account.localName);
        })
        .onSubmit((enterKey) => {
          InputMethod.getInputMethodController().stopInput()
            .then((ret) => {
              LogUtil.debug(`${ConfigData.TAG}, enterType: ${enterKey}, stopInput: ${ret}`);
            });
        })

      Divider()
        .margin({ right: $r("app.float.wh_value_12"), left: $r("app.float.wh_value_12") })
        .color($r("sys.color.ohos_id_color_list_separator"))

      if (this.isWarn) {
        Text($r("app.string.userCreatedWarn"))
          .fontSize($r("app.float.font_14"))
          .fontColor($r("sys.color.ohos_id_color_primary"))
          .width(ConfigData.WH_100_100)
          .textAlign(TextAlign.Start)
          .margin({
            top: $r("app.float.wh_value_8"),
            bottom: $r("app.float.wh_value_18"),
            left: $r("app.float.wh_value_12")
          })
      } else {
        Text($r("app.string.addUserDescription"))
          .fontSize($r("app.float.font_16"))
          .fontColor($r("app.color.font_color_182431"))
          .fontWeight(500)
          .width(ConfigData.WH_100_100)
          .textAlign(TextAlign.Start)
          .padding({
            top: $r("app.float.wh_value_8"),
            bottom: $r("app.float.distance_9"),
            left: $r("app.float.wh_value_12")
          })
      }

      DialogButtonLayoutWithState({
        firstClickEvent: () => {
          LogUtil.info("Cancel add new user.");
          this.controller.close();
        },
        secondClickEvent: () => {
          LogUtil.info("Confirm Add new user.");
          this.controller.close();
          this.confirm(this.account.localName);
        },
        secondButtonState: this.buttonState
      })
    }
    .borderRadius($r("app.float.wh_value_24") )
    .height($r("app.float.wh_value_260"))
    .margin({ left: $r("app.float.wh_value_12"), right: $r("app.float.wh_value_12") })
  }

  aboutToAppear() {
    ResourceUtil.getString($r("app.string.nickname"))
      .then(value => this.hintText = value);
  }
}

@CustomDialog
struct ChooseImageDialog {
  private controller: CustomDialogController;

  build() {
    Column() {
      Text($r("app.string.takePhoto"))
        .fontSize($r("app.float.font_24"))
        .fontColor($r("app.color.font_color_182431"))
        .onClick(() => {
          router.push({ uri: "" });
        })

      Text($r("app.string.chooseFromShop"))
        .fontSize($r("app.float.font_16"))
        .fontColor($r("app.color.font_color_182431"))
        .onClick(() => {
          router.push({ uri: "" })
        })
    }
  }
}

@CustomDialog
struct WaitDialog {
  private controller: CustomDialogController;
  private content: string | Resource;

  build() {
    Row() {
      Text(this.content)
        .fontSize($r("app.float.font_16"))
        .fontColor($r("app.color.font_color_182431"))
        .height($r("app.float.wh_value_48"))
        .width(ConfigData.WH_100_100)
        .textAlign(TextAlign.Start)
        .fontWeight(FontWeight.Medium)
        .padding({
          top: $r("app.float.distance_8"),
          bottom: $r("app.float.distance_8")
        })
    }
    .alignItems(VerticalAlign.Center)
    .height($r("app.float.wh_value_80"))
    .padding({
      left: $r("app.float.distance_24"),
      right: $r("app.float.distance_24")
    })
  }
}
