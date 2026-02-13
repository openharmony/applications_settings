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
import { ResourceUtil } from '../../common/utils/ResourceUtil';
import AccessibilityUtil from '../../common/utils/AccessibilityUtil';
import Log from '../../common/utils/Log';
import { PasswordUtils, PinSubType, ResultCode } from '../../common/utils/PasswordUtils';
import { CommonConstants } from '../../common/constants/CommonConstants';
import { SelectPsdTypeDialogComponent } from '../SelectPsdTypeDialogComponent';
import { PasswordTypeModel } from '../../model/PasswordTypeModel';
import { HiSysEventUtil } from '../../common/utils/HiSysEventUtil';
import { HiSysEventConstants } from '../../common/constants/HiSysEventConstants';
import { osAccount } from '@kit.BasicServicesKit';
import SecurityManager from '../../security/SecurityManager';
import { AccountConstants } from '../../common/constants/AccountConstants';
import { DeviceUtils } from '../../common/utils/DeviceUtils';
import { currentPwdType, getCurrentTokenAndCredId } from '../../common/PrivacyPassword';
import { AlertDialog } from '@ohos.arkui.advanced.Dialog';
import { PADDING_16, PADDING_24 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { DeviceUtil } from '@ohos/settings.common';
import { TipMessage } from './TipMsg';
import {
  HdsNavDestinationTitleMode, HdsNavDestination, HdsNavDestinationAttribute, DividerShowType
} from '@kit.UIDesignKit';


const TAG: string = 'UpdatePrivatePwdPinType';
const MAX_PWD_LENGTH: number = 6;

@Component
export struct UpdatePrivatePwdPinType {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @Consume('innerPathInfos') innerPathInfos: NavPathStack;
  @Link passwordType: number;
  @Link isNeedPop: boolean;
  @State password: string = '';
  @State isFirstInput: boolean = true;
  @State title: string = '';
  @State navigationIndicatorHeight: number | undefined =
    LocalStorage.getShared().get<number>(CommonConstants.NAVIGATION_INDICATOR_HEIGHT_KEY);
  @State maxPasswordLength: number = AccountConstants.SIX_PIN_PASSWORD_LENGTH;
  @State tipMsg: string = '';
  @State transitionType: NavigationSystemTransitionType = NavigationSystemTransitionType.DEFAULT;

  dialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: $r('app.string.weak_password_dialog_title'),
      content: $r('app.string.weak_password_dialog_content'),
      primaryButton: {
        value: $r('app.string.weak_password_dialog_negative_button'),
        action: () => {
          HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_UPDATE_WEAK_PIN_CONTINUE,
            HiSysEventConstants.USER_OPERATION_CLICK);
          this.onConfirm();
        },
      },
      secondaryButton: {
        value: $r('app.string.weak_password_dialog_positive_button'),
        role: ButtonRole.NORMAL,
        buttonStyle: ButtonStyleMode.EMPHASIZED,
        action: () => {
          HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_UPDATE_WEAK_PIN_RESET,
            HiSysEventConstants.USER_OPERATION_CLICK);
          this.onCancel();
        }
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    showInSubWindow: true,
    onWillDismiss: () => {
      HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_UPDATE_WEAK_PIN_RESET,
        HiSysEventConstants.USER_OPERATION_CLICK);
      this.onCancel();
    }
  });
  changePsdTypeDialogController: CustomDialogController = new CustomDialogController({
    builder: SelectPsdTypeDialogComponent({
      title: $r('app.string.private_pin_other_password_type'),
      confirmText: $r('app.string.dialog_cancel'),
      data: this.initOtherPsdTypeData(),
      cancel: () => {
        this.onCancelPsdType()
      },
      isNeedPop: this.isNeedPop,
      passwordType: this.passwordType,
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    showInSubWindow: true
  });
  private bgColorPrimary: Resource = $r('sys.color.ohos_id_color_background_transparent');
  @State bgColors: Resource[] = [
    this.bgColorPrimary, this.bgColorPrimary,
    this.bgColorPrimary, this.bgColorPrimary,
    this.bgColorPrimary, this.bgColorPrimary];
  private firstPassword: string = '';
  private bgColorSecondary: Resource = $r('sys.color.ohos_id_color_foreground');
  private oldSubType: osAccount.AuthSubType = osAccount.AuthSubType.PIN_SIX;

  async aboutToAppear(): Promise<void> {
    Log.info(TAG, `aboutToAppear`);
    this.transitionType = NavigationSystemTransitionType.TITLE;
    this.title = ResourceUtil.getNumberFormatString($r('app.string.pin_password_message'),
      AccountConstants.SIX_PIN_PASSWORD_LENGTH);
    this.oldSubType = await currentPwdType();
    HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_UPDATE_PWD_PIN,
      HiSysEventConstants.USER_OPERATION_BEGIN);
  }

  aboutToDisappear(): void {
    Log.info(TAG, `aboutToDisappear`);
    this.changePsdTypeDialogController.close();
    this.dialogController.close();
    this.clearResource();
  }

  @Builder
  builderTitle(): void {
    Column() {
      Text(this.title)
        .width('100%')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('app.float.font_16'))
        .textAlign(TextAlign.Center)
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .constraintSize({ minHeight: $r('app.float.wh_64') })
  }

  @Builder
  builderPasswordCircleComponent(): void {
    Stack() {
      TextInput({ text: this.password })
        .backgroundColor(Color.Transparent)
        .caretColor(Color.Transparent)
        .maxLength(this.maxPasswordLength)
        .type(InputType.NUMBER_PASSWORD)
        .enableAutoFill(false)
        .showPasswordIcon(false)
        .textAlign(TextAlign.Center)
        .enableKeyboardOnFocus(true)
        .defaultFocus(true)
        .onChange(async (val: string) => {
          this.inputChange(val);
        })
        .opacity(0)
        .fontColor(($r('sys.color.ohos_id_color_text_primary')))
        .inputFilter('[0-9]')
        .width('100%')
        .showPasswordIcon(false)
        .id('updatePrivatePwdPinTypePasswordInput')

      List({ space: 24 }) {
        ForEach(this.bgColors, (color: Resource) => {
          ListItem() {
            Stack({ alignContent: Alignment.Center }) {
              Column()
                .width($r('app.float.wh_12'))
                .height($r('app.float.wh_12'))
                .backgroundColor(color)
                .border({ width: 1.5, color: this.bgColorSecondary, radius: $r('app.float.wh_24') });
            }
            .pixelRound({
              end: PixelRoundCalcPolicy.FORCE_FLOOR,
            })
          }
        })
      }
      .pixelRound({
        end: PixelRoundCalcPolicy.FORCE_CEIL,
      })
      .listDirection(Axis.Horizontal)
      .height($r('app.float.wh_12'))
      .hitTestBehavior(HitTestMode.Transparent)
    }
    .accessibilityGroup(true)
    .accessibilityText(this.getPasswordReadText())
    .accessibilityDescription(' ')
    .hitTestBehavior(HitTestMode.Block)
    .onClick(() => {
      focusControl.requestFocus('updatePrivatePwdPinTypePasswordInput');
    })
  }

  @Builder
  builderTipMessage(): void {
    TipMessage({
      tipMsg: this.tipMsg
    })
  }

  @Builder
  builderOtherTypePassword(): void {
    Button($r('app.string.private_pin_other_password_type'), {
      buttonStyle: ButtonStyleMode.TEXTUAL
    })
    .width('100%')
    .fontSize($r('sys.float.Body_L'))
    .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
    .margin({ top: $r('app.float.wh_20') })
    .fontWeight(FontWeight.Medium)
    .padding({
      left: $r('sys.float.padding_level8'),
      top: $r('sys.float.padding_level6'),
      right: $r('sys.float.padding_level8'),
      bottom : $r('sys.float.padding_level6')
    })
    .onClick(() => {
      HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_UPDATE_OTHER_TYPE,
        HiSysEventConstants.USER_OPERATION_CLICK);
      this.changePsdTypeDialogController.open();
    })
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            this.builderTitle();
            this.builderPasswordCircleComponent();
            this.builderTipMessage();
            if (this.isFirstInput) {
              this.builderOtherTypePassword();
            }
          }
          .margin({ top: $r('app.float.wh_24') })
        }
        .height('100%')
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .align(Alignment.TopStart)
      }
      .height('100%')
      .padding({
        left: DeviceUtils.isPhone() ? $r('app.float.wh_16') : $r('app.float.wh_24'),
        right: DeviceUtils.isPhone() ? $r('app.float.wh_16') : $r('app.float.wh_24'),
      })
      .justifyContent(FlexAlign.Start)
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.KEYBOARD], [SafeAreaEdge.BOTTOM])
    }
    .onBackPressed(() => {
      Log.info(TAG, `onBackPressed`);
      this.transitionType = NavigationSystemTransitionType.TITLE;
      HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_UPDATE_PWD_PIN,
        HiSysEventConstants.USER_OPERATION_CANCEL);
      this.pathInfos.pop();
      return true;
    })
    .onShown(() => {
      Log.info(TAG, `onShown`);
      this.transitionType = NavigationSystemTransitionType.DEFAULT;
      this.isNeedPop = true;
    })
    .title($r('app.string.set_privacy_password'))
    // .titleMode(HdsNavDestinationTitleMode.MINI)
    // .titleBar({
    //   enableComponentSafeArea: true,
    //   content: {
    //     title: {
    //       mainTitle: $r('app.string.set_privacy_password'),
    //     },
    //     divider: {
    //       showType: DividerShowType.OFF
    //     }
    //   },
    //   style: {
    //     originalStyle: {
    //       backgroundStyle: {
    //         backgroundColor: $r('sys.color.comp_background_gray'),
    //       },
    //     },
    //     scrollEffectStyle: {
    //       backgroundStyle: {
    //         backgroundColor: $r('sys.color.comp_background_gray'),
    //       },
    //     },
    //   },
    //   padding: {
    //     start: DeviceUtil.isDevicePhone() ? PADDING_16 : PADDING_24,
    //     end: DeviceUtil.isDevicePhone() ? PADDING_16 : PADDING_24,
    //   }
    // })
    .height('100%')
    .width('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }

  private onCancel(): void {
    Log.info(TAG, `dialog cancel`);
    this.dialogController.close();
    this.password = '';
    this.isFirstInput = true;
  }

  private async onConfirm(): Promise<void> {
    Log.info(TAG, `dialog confirm`);
    this.dialogController.close();
    this.inputFinish();
  }

  private inputFinish(): void {
    if (!this.password) {
      return;
    }
    if (this.isFirstInput) {
      this.firstPassword = this.password;
      this.isFirstInput = false;
      this.password = '';
      this.tipMsg = '';
      this.title = ResourceUtil.getStringSync($r('app.string.enter_pin_again_title'));
      return;
    }
    if (this.password !== this.firstPassword) {
      Log.warn(TAG, `password not same`);
      this.password = '';
      this.tipMsg = ResourceUtil.getStringSync($r('app.string.pin_repeat_error_title'));
      AccessibilityUtil.autoReadForAccessibility(this.tipMsg);
      return;
    }
    this.updatePwd();
  }

  private updatePwd(): void {
    PasswordUtils.unregisterInputer();
    PasswordUtils.registerPriPwdInputer(osAccount.AuthSubType.PIN_SIX, this.password);
    let token = SecurityManager.getInstance().getToken();
    if (!token) {
      Log.error(TAG, `get token failed`);
      return;
    }
    PasswordUtils.updatePriPwd(this.oldSubType, token, (result, extraInfo) => {
      if (result === ResultCode.SUCCESS) {
        Log.info(TAG, `update private pwd success`);
        getCurrentTokenAndCredId().then((res) => {
          HiSysEventUtil.setCredentialAndTempIdAfter(res.credentialId, res.templateId);
          HiSysEventUtil.reportUpdateEvent(HiSysEventConstants.UPDATE_PWD);
        })
        HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_UPDATE_PWD_PIN,
          HiSysEventConstants.USER_OPERATION_END);
        this.pathInfos.pop();
        return;
      }
      Log.error(TAG, `update private pwd failed, result: ${result}`);
      this.pathInfos.pop();
      return;
    })
  }

  private inputChange(value: string): void {
    this.password = value;
    if (value.length > this.maxPasswordLength) {
      return;
    }

    for (let i = 0; i < this.maxPasswordLength; i++) {
      if (i < value.length) {
        this.bgColors[i] = this.bgColorSecondary;
      } else {
        this.bgColors[i] = this.bgColorPrimary;
      }
    }

    if (PasswordUtils.isPinNumber6(value)) {
      if (PasswordUtils.isWeakPasswords(this.password) && this.isFirstInput) {
        this.dialogController.open();
      } else {
        this.inputFinish();
      }
    }
  }

  private initOtherPsdTypeData(): PasswordTypeModel[] {
    let passwordData: PasswordTypeModel[] = [];
    passwordData.push(new PasswordTypeModel(PinSubType.PIN_NUMBER,
      ResourceUtil.getStringSync($r('app.string.number_password_type'))));
    passwordData.push(new PasswordTypeModel(PinSubType.PIN_MIXED,
      ResourceUtil.getStringSync($r('app.string.mixed_password_type'))));
    return passwordData;
  }

  private onCancelPsdType(): void {
    Log.info(TAG, `onCancelPsdType cancel`);
    this.changePsdTypeDialogController.close();
  }

  private clearResource(): void {
    this.password = '';
  }

  private getPasswordReadText(): string {
    const length = this.password.length;
    const begin = ResourceUtil.getPluralStringSync($r('app.plural.private_password_edit_read_begin'), MAX_PWD_LENGTH);
    const end = ResourceUtil.getPluralStringSync($r('app.plural.password_edit_read_end'), length);
    return `${begin} ${end}`;
  }
}