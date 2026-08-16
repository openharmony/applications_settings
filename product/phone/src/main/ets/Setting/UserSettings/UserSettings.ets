/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
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

import osAccount from '@ohos.account.osAccount';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { usersAccountController } from './controller/UsersAccountController';
import { usersAccountModel, MAX_USER_NAME_LENGTH } from './model/UsersAccountModel';

const TAG: string = 'UserSettings:';

@Component
export struct UserSettings {
  @StorageLink('isShowAddUser') isShowAddUser: boolean = false;
  @StorageLink('isShowAddGuest') isShowAddGuest: boolean = false;
  @StorageLink('systemAccountList') userList: osAccount.OsAccountInfo[] = [];
  @StorageLink('isShowDelete') isShowDelete: boolean = false;
  @StorageLink('isCurrentGuestUser') isCurrentGuestUser: boolean = false;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageProp('navigationMode') navigationMode: NavigationMode = NavigationMode.Stack;
  params: PushParam | null = null;
  private title: string = ResourceUtil.getStringSync($r('app.string.user_settings_title'));
  private addUserDialogController?: CustomDialogController;
  private waitDialogController?: CustomDialogController;
  private renameDialogController?: CustomDialogController;
  private userActionDialogController?: CustomDialogController;

  aboutToAppear(): void {
    this.initDialogs();
    usersAccountController.refreshSystemAccountList();
  }

  aboutToDisappear(): void {
    this.addUserDialogController = undefined;
    this.waitDialogController = undefined;
    AppStorage.setOrCreate('systemAccountList', []);
  }

  private initDialogs(): void {
    this.addUserDialogController = new CustomDialogController({
      builder: AddUserDialog({
        controller: this.addUserDialogController,
        confirm: (localName: string): void => {
          this.onCreateUserConfirm(localName);
        },
      }),
      alignment: DialogAlignment.Bottom,
      autoCancel: true,
    });
    this.waitDialogController = new CustomDialogController({
      builder: WaitDialog({
        controller: this.waitDialogController,
        content: $r('app.string.user_add_loading'),
      }),
      autoCancel: false,
      alignment: DialogAlignment.Bottom,
    });
  }

  private onCreateUserConfirm(localName: string): void {
    if (usersAccountController.isAlreadyCreated(localName)) {
      AlertDialog.show({
        message: $r('app.string.fp_duplicated_name_toast'),
        primaryButton: {
          value: $r('app.string.dlg_ok_gt'),
          action: () => {
          }
        },
      });
      return;
    }
    this.waitDialogController?.open();
    usersAccountController.createSystemAccount(localName, () => {
      this.waitDialogController?.close();
      AlertDialog.show({
        message: $r('app.string.user_add_user_dialog_title'),
        primaryButton: {
          value: $r('app.string.cancel'),
          action: () => {
          }
        },
        secondaryButton: {
          value: $r('app.string.user_add_dialog_switch_btn_text'),
          action: () => {
            usersAccountController.switchToCreatedAccount();
          }
        },
      });
    });
  }

  private onAddGuestClick(): void {
    AlertDialog.show({
      message: $r('app.string.user_add_new_guest_title'),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
        }
      },
      secondaryButton: {
        value: $r('app.string.dlg_ok_gt'),
        action: () => {
          this.waitDialogController?.open();
          usersAccountController.createGuest(() => {
            this.waitDialogController?.close();
          });
        }
      },
    });
  }

  private showDeleteUserConfirmDialog(localId?: number): void {
    AlertDialog.show({
      message: $r('app.string.delete_user_message'),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
        }
      },
      secondaryButton: {
        value: $r('app.string.user_delete_button'),
        action: () => {
          usersAccountController.removeAccount(localId);
        }
      },
    });
  }

  private onDeleteCurrentUser(): void {
    this.showDeleteUserConfirmDialog();
  }

  private onUserItemClick(user: osAccount.OsAccountInfo): void {
    if (usersAccountController.isCurrentAdministrator() ||
      (usersAccountController.isCurrentUser(user) && !usersAccountController.isGuestAccount(user))) {
      this.showUserActionDialog(user);
      return;
    }
    if (!usersAccountController.isCurrentGuest() || !usersAccountController.isGuestAccount(user)) {
      AlertDialog.show({
        message: $r('app.string.accout_switch'),
        primaryButton: {
          value: $r('app.string.cancel'),
          action: () => {
          }
        },
        secondaryButton: {
          value: $r('app.string.dlg_ok_gt'),
          action: () => {
            usersAccountController.switchUser(user.localId);
          }
        },
      });
    }
  }

  private showUserActionDialog(user: osAccount.OsAccountInfo): void {
    if (usersAccountController.isCurrentUser(user)) {
      this.renameDialogController = new CustomDialogController({
        builder: RenameUserDialog({
          controller: this.renameDialogController,
          userName: user.localName,
          confirm: (name: string): void => {
            if (name && name !== user.localName) {
              usersAccountController.setAccountName(user.localId, name);
            }
          },
        }),
        alignment: DialogAlignment.Bottom,
        autoCancel: true,
      });
      this.renameDialogController.open();
      return;
    }
    if (usersAccountController.canAdminDeleteUser(user)) {
      this.userActionDialogController = new CustomDialogController({
        builder: UserManageDialog({
          controller: this.userActionDialogController,
          userName: user.localName,
          onSwitch: (): void => {
            usersAccountController.switchUser(user.localId);
          },
          onDelete: (): void => {
            this.showDeleteUserConfirmDialog(user.localId);
          },
        }),
        alignment: DialogAlignment.Bottom,
        autoCancel: true,
      });
      this.userActionDialogController.open();
      return;
    }
    AlertDialog.show({
      message: $r('app.string.accout_switch'),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
        }
      },
      secondaryButton: {
        value: $r('app.string.dlg_ok_gt'),
        action: () => {
          usersAccountController.switchUser(user.localId);
        }
      },
    });
  }

  build() {
    NavDestination() {
      List() {
        if (this.userList.length > 0) {
          ListItemGroup() {
            ForEach(this.userList, (userItem: osAccount.OsAccountInfo) => {
              ListItem() {
                Row() {
                  Column() {
                    Text(userItem.localName)
                      .fontSize($r('sys.float.ohos_id_text_size_body1'))
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('sys.color.ohos_id_color_text_primary'))
                      .width('100%')
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .wordBreak(WordBreak.BREAK_WORD)
                    if (usersAccountController.isShowIdentity(userItem)) {
                      Text(usersAccountModel.getIdentityFromMap(userItem.type) as Resource)
                        .fontSize($r('sys.float.ohos_id_text_size_body2'))
                        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                        .width('100%')
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .margin({ top: $r('app.float.distance_2') })
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  .padding({
                    top: $r('sys.float.padding_level4'),
                    bottom: $r('sys.float.padding_level4')
                  })

                  if (usersAccountController.isCurrentUser(userItem)) {
                    SymbolGlyph($r('sys.symbol.checkmark'))
                      .fontSize($r('app.float.wh_value_24'))
                      .fontWeight(FontWeight.Regular)
                      .fontColor([$r('sys.color.ohos_id_color_activated')])
                      .margin({ right: $r('sys.float.padding_level4') })
                      .flexShrink(0)
                  }

                  Image($r('sys.symbol.chevron_right'))
                    .width($r('app.float.wh_value_12'))
                    .height($r('app.float.wh_value_24'))
                    .fillColor($r('sys.color.ohos_id_color_fourth'))
                    .flexShrink(0)
                }
                .width('100%')
                .constraintSize({ minHeight: $r('app.float.wh_value_56') })
                .padding({
                  left: $r('sys.float.padding_level8'),
                  right: $r('sys.float.padding_level8')
                })
                .alignItems(VerticalAlign.Center)
                .onClick(() => {
                  this.onUserItemClick(userItem);
                })
              }
            }, (userItem: osAccount.OsAccountInfo) => `${userItem.localId}_${userItem.localName}`)
          }
          .divider({
            strokeWidth: $r('app.float.wh_value_0_5'),
            color: $r('sys.color.ohos_id_color_list_separator'),
            startMargin: $r('sys.float.padding_level8'),
            endMargin: $r('sys.float.padding_level8'),
          })
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .borderRadius($r('sys.float.corner_radius_level8'))
          .margin({
            top: $r('app.float.distance_12'),
            left: $r('sys.float.padding_level8'),
            right: $r('sys.float.padding_level8')
          })
        }

        if (this.isShowAddUser) {
          ListItem() {
            Row() {
              Text($r('app.string.user_add_user_title'))
                .fontSize($r('sys.float.ohos_id_text_size_body1'))
                .fontColor($r('sys.color.ohos_id_color_emphasize'))
                .width('100%')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .wordBreak(WordBreak.BREAK_WORD)
            }
            .width('100%')
            .constraintSize({ minHeight: $r('app.float.wh_value_56') })
            .padding({
              left: $r('sys.float.padding_level8'),
              right: $r('sys.float.padding_level8'),
              top: $r('sys.float.padding_level4'),
              bottom: $r('sys.float.padding_level4')
            })
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .borderRadius($r('sys.float.corner_radius_level8'))
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              this.addUserDialogController?.open();
            })
          }
          .padding($r('app.float.wh_value_0'))
          .margin({
            top: $r('app.float.distance_12'),
            left: $r('sys.float.padding_level8'),
            right: $r('sys.float.padding_level8')
          })
        }

        if (this.isShowAddGuest) {
          ListItem() {
            Row() {
              Text($r('app.string.user_add_guest_menu_title'))
                .fontSize($r('sys.float.ohos_id_text_size_body1'))
                .fontColor($r('sys.color.ohos_id_color_emphasize'))
                .width('100%')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .wordBreak(WordBreak.BREAK_WORD)
            }
            .width('100%')
            .constraintSize({ minHeight: $r('app.float.wh_value_56') })
            .padding({
              left: $r('sys.float.padding_level8'),
              right: $r('sys.float.padding_level8'),
              top: $r('sys.float.padding_level4'),
              bottom: $r('sys.float.padding_level4')
            })
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .borderRadius($r('sys.float.corner_radius_level8'))
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              this.onAddGuestClick();
            })
          }
          .padding($r('app.float.wh_value_0'))
          .margin({
            top: $r('app.float.distance_12'),
            left: $r('sys.float.padding_level8'),
            right: $r('sys.float.padding_level8')
          })
        }

        if (this.isShowDelete) {
          ListItem() {
            Row() {
              Text(this.isCurrentGuestUser ? $r('app.string.user_delete_guest') :
                $r('app.string.user_delete_user_description'))
                .fontSize($r('sys.float.ohos_id_text_size_body1'))
                .fontColor($r('sys.color.ohos_id_color_warning'))
                .width('100%')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .wordBreak(WordBreak.BREAK_WORD)
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .constraintSize({ minHeight: $r('app.float.wh_value_56') })
            .padding({
              left: $r('sys.float.padding_level8'),
              right: $r('sys.float.padding_level8'),
              top: $r('sys.float.padding_level4'),
              bottom: $r('sys.float.padding_level4')
            })
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .borderRadius($r('sys.float.corner_radius_level8'))
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              this.onDeleteCurrentUser();
            })
          }
          .padding($r('app.float.wh_value_0'))
          .margin({
            top: $r('app.float.distance_12'),
            left: $r('sys.float.padding_level8'),
            right: $r('sys.float.padding_level8')
          })
        }
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .scrollBar(BarState.Off)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .title(this.title)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .hideBackButton(this.navigationMode === NavigationMode.Split && this.pathInfos.size() === 1)
    .onShown(() => {
      usersAccountController.refreshSystemAccountList();
    })
  }
}

@CustomDialog
struct AddUserDialog {
  controller?: CustomDialogController;
  confirm: (localName: string) => void = () => {
  };
  @State userName: string = '';

  build() {
    Column() {
      Text($r('app.string.user_add_user_title'))
        // .fontSize($r('sys.float.ohos_id_text_size_headline'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: $r('app.float.distance_12') })

      TextInput({ text: this.userName, placeholder: $r('app.string.user_name_input_hint') })
        .maxLength(MAX_USER_NAME_LENGTH)
        .onChange((value: string) => {
          this.userName = value;
        })

      Row() {
        Button($r('app.string.cancel'))
          .layoutWeight(1)
          .onClick(() => {
            this.controller?.close();
          })
        Button($r('app.string.dlg_ok_gt'))
          .layoutWeight(1)
          .margin({ left: $r('app.float.distance_12') })
          .onClick(() => {
            this.controller?.close();
            if (this.userName.trim().length > 0) {
              this.confirm(this.userName.trim());
            }
          })
      }
      .margin({ top: $r('sys.float.padding_level8') })
    }
    .padding($r('sys.float.padding_level8'))
    .borderRadius($r('app.float.wh_value_24'))
  }
}

@CustomDialog
struct RenameUserDialog {
  controller?: CustomDialogController;
  userName: string = '';
  confirm: (localName: string) => void = () => {
  };
  @State editName: string = '';

  aboutToAppear(): void {
    this.editName = this.userName;
  }

  build() {
    Column() {
      Text($r('app.string.user_nickname'))
        // .fontSize($r('sys.float.ohos_id_text_size_headline'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: $r('app.float.distance_12') })

      TextInput({ text: this.editName, placeholder: $r('app.string.user_name_input_hint') })
        .maxLength(MAX_USER_NAME_LENGTH)
        .onChange((value: string) => {
          this.editName = value;
        })

      Row() {
        Button($r('app.string.cancel'))
          .layoutWeight(1)
          .onClick(() => {
            this.controller?.close();
          })
        Button($r('app.string.dlg_ok_gt'))
          .layoutWeight(1)
          .margin({ left: $r('app.float.distance_12') })
          .onClick(() => {
            this.controller?.close();
            if (this.editName.trim().length > 0) {
              this.confirm(this.editName.trim());
            }
          })
      }
      .margin({ top: $r('sys.float.padding_level8') })
    }
    .padding($r('sys.float.padding_level8'))
    .borderRadius($r('app.float.wh_value_24'))
  }
}

@CustomDialog
struct UserManageDialog {
  controller?: CustomDialogController;
  userName: string = '';
  onSwitch: () => void = () => {
  };
  onDelete: () => void = () => {
  };

  build() {
    Column() {
      Text(this.userName)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: $r('sys.float.padding_level8') })

      Button($r('app.string.user_add_dialog_switch_btn_text'))
        .width('100%')
        .onClick(() => {
          this.controller?.close();
          this.onSwitch();
        })

      Button($r('app.string.user_delete_button'))
        .width('100%')
        .margin({ top: $r('app.float.distance_12') })
        .fontColor($r('sys.color.ohos_id_color_warning'))
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .onClick(() => {
          this.controller?.close();
          this.onDelete();
        })

      Button($r('app.string.cancel'))
        .width('100%')
        .margin({ top: $r('app.float.distance_12') })
        .onClick(() => {
          this.controller?.close();
        })
    }
    .padding($r('sys.float.padding_level8'))
    .borderRadius($r('app.float.wh_value_24'))
  }
}

@CustomDialog
struct WaitDialog {
  controller?: CustomDialogController;
  content: ResourceStr = '';

  build() {
    Column() {
      LoadingProgress()
        .width($r('app.float.wh_value_48'))
        .height($r('app.float.wh_value_48'))
      Text(this.content)
        .margin({ top: $r('app.float.distance_12') })
    }
    .padding($r('app.float.wh_value_24'))
    .borderRadius($r('app.float.wh_value_24'))
  }
}
