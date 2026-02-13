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

/* instrument ignore file */
import { contact } from '@kit.ContactsKit';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import { AlertDialog } from '@ohos.arkui.advanced.Dialog';
import { BusinessError } from '@ohos.base';
import { LengthMetrics } from '@kit.ArkUI';
import settings from '@ohos.settings';
import { LogUtil, SettingsDataUtils, ContextUtils } from '@ohos/settings.common/index'
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { SettingCompState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { NOT_DISTURB_NUMBER_MINUS } from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbUtils';
import {
  FOCUS_MODE_CALL_MESSAGE_POLICY,
  INCOMING_CALL_SELECT_CONTACTS
} from '../controller/ContactPolicyRadioController';
import { IncomingCallSettingController, } from '../controller/IncomingCallSettingController';
import { SelectContactsController } from '../controller/SelectContactsController';
import { ContactPolicy } from '../model/IncomingCallParam';

const TAG: string = 'SelectContactsComponent: ';

@Component
export struct SelectMenuComponent {
  comId: string = '';
  title?: ResourceStr;
  controller?: IncomingCallSettingController;
  private arrowMarginEnd: LengthMetrics | undefined =
    LengthMetrics.resource($r('app.float.distance_8'));

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.interactive_click'))
    .borderRadius($r('sys.float.corner_radius_level10'))
  }

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius($r('sys.float.corner_radius_level10'))
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row() {
          Text(this.title)
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .constraintSize({ minHeight: $r('app.float.wh_value_48') })
            .textAlign(TextAlign.Start)
            .margin({ left: $r('app.float.distance_8')})
            .flexShrink(1);
        }

        Image($r('app.media.ic_settings_arrow'))
          .fillColor($r('sys.color.icon_secondary'))
          .width($r('app.float.wh_value_12'))
          .height($r('app.float.wh_value_24'))
          .margin({ end: this.arrowMarginEnd })
          .matchTextDirection(true)
          .draggable(false);
      }
      .backgroundColor($r('app.color.color_default_white'))
      .stateStyles({
        normal: this.normalStyles,
        pressed: this.pressedStyles,
      })
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .padding($r('app.float.distance_4'))
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .constraintSize({ minHeight: $r('app.float.wh_value_56') })
    .borderRadius($r('sys.float.corner_radius_level10'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }
}

@Component
export struct SelectContactsComponent {
  @State isShowSelect: boolean = false;
  @State controller?: IncomingCallSettingController = undefined;
  @State mSelectContactController: SelectContactsController = SelectContactsController.getInstance();
  private dialogControllerConfirm?: CustomDialogController;

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.mSelectContactController.onInit();
    let contactPolicy = SettingsDataUtils.getSettingsData(FOCUS_MODE_CALL_MESSAGE_POLICY,
      ContactPolicy.FORBID_EVERYONE, settings.domainName.USER_PROPERTY);
    this.isShowSelect = contactPolicy === ContactPolicy.ALLOW_SPECIFIED_CONTACTS;
    EventBus.getInstance().on(INCOMING_CALL_SELECT_CONTACTS, (data: object) => {
      let visible = (data as SettingCompState).state;
      this.isShowSelect = visible;
    });

    this.showContactSetPermission();
  }

  showContactSetPermission(): void {
    LogUtil.info(`${TAG} showContactSetPermission`);
    this.dialogControllerConfirm = new CustomDialogController({
      autoCancel: false,
      builder: AlertDialog({
        primaryTitle: $r('app.string.permission_dialog_title'),
        content: $r('app.string.permission_reason_read_write_contacts'),
        primaryButton: {
          value: $r('app.string.timer_cancel'),
          action: () => {
          },
        },
        secondaryButton: {
          value: $r('app.string.go_to_set'),
          action: () => {
            this.startAbilitySettings();
          }
        },
      }),
    });
  }

  startAbilitySettings(): void {
    let bundleName = PackagesConstant.SETTINGS_BUNDLE_NAME;
    let abilityName = PackagesConstant.SETTINGS_MAIN_ABILITY_NAME;
    let navEntryKey = NavEntryKey.APPLICATION_INFO_ENTRY;
    AbilityUtils.startAbilityForResult({
      bundleName: bundleName,
      abilityName: abilityName,
      uri: navEntryKey,
      parameters: {
        pushParams: PackagesConstant.SETTINGS_BUNDLE_NAME
      }
    }, () => {
      LogUtil.info(`${TAG} start about applition info page success`);
    });
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.mSelectContactController.onDestroy();
    EventBus.getInstance().off(INCOMING_CALL_SELECT_CONTACTS);
    this.dialogControllerConfirm?.close();
  }

  refreshUi(): void {
    LogUtil.info(`${TAG} refreshUi`);
    this.aboutToAppear();
  }

  build() {
    Column() {
      SelectMenuComponent({
        comId: 'select_contacts',
        title: $r('app.string.select_contacts'),
      })
    }
    .margin({
      top: $r('app.float.distance_12')
    })
    .onClick(() => {
      this.requestPermissions();
    })
    .visibility(this.isShowSelect ? Visibility.Visible : Visibility.None)
  }

  requestPermissions() {
    let requestPermissions: Permissions[] = [
      'ohos.permission.READ_CONTACTS',
      'ohos.permission.WRITE_CONTACTS',
    ];
    let atManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(ContextUtils.getContext(), requestPermissions)
      .then((data) => {
        let authFlag = true;
        for (let i = 0; i < data.authResults.length; i++) {
          if (data.authResults[i] == NOT_DISTURB_NUMBER_MINUS) {
            authFlag = false;
          }
        }
        LogUtil.info(`${TAG}, authFlag: ${authFlag}`);
        if (authFlag) {
          contact.selectContacts({
            isMultiSelect: true
          }, (err: BusinessError, data) => {
            if (err) {
              LogUtil.error(`${TAG}, selectContact callback: err->${err?.message}`);
              return;
            }
            LogUtil.info(`${TAG}, selectContact callback: success`);
            this.mSelectContactController.batchSelectContactForResult(data, () => {})
          });
        } else {
          LogUtil.info(`${TAG} dialogControllerConfirm open`);
          this.dialogControllerConfirm?.open();
        }
      })
      .catch((err: BusinessError) => {
        LogUtil.error(`${TAG}, requestPermissionsFromUser err. code: ${err.code}, message: ${err.message}`);
      });
    LogUtil.info(`${TAG}, Application requestPermissionsFromUser end`);
  }
}