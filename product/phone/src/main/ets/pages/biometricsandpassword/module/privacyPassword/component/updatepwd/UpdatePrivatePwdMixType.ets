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
import { AccountConstants } from '../../common/constants/AccountConstants';
import { CommonConstants } from '../../common/constants/CommonConstants';
import { PasswordConstants } from '../../common/constants/PasswordConstants';
import AccessibilityUtil from '../../common/utils/AccessibilityUtil';
import { DeviceUtils } from '../../common/utils/DeviceUtils';
import Log from '../../common/utils/Log';
import { PasswordUtils, PinSubType, ResultCode } from '../../common/utils/PasswordUtils';
import { ResourceUtil } from '../../common/utils/ResourceUtil';
import { PasswordTypeModel } from '../../model/PasswordTypeModel';
import MixAndNumberPasswordPageButton from '../MixAndNumberPasswordPageButton';
import { SelectPsdTypeDialogComponent } from '../SelectPsdTypeDialogComponent';
import { osAccount } from '@kit.BasicServicesKit';
import SecurityManager from '../../security/SecurityManager';
import { HiSysEventUtil } from '../../common/utils/HiSysEventUtil';
import { HiSysEventConstants } from '../../common/constants/HiSysEventConstants';
import { currentPwdType, getCurrentTokenAndCredId } from '../../common/PrivacyPassword';
import { AlertDialog } from '@ohos.arkui.advanced.Dialog';
import { DeviceUtil } from '@ohos/settings.common';
import { PADDING_16, PADDING_24 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { TipMessage } from './TipMsg';
import {
  HdsNavDestinationTitleMode, HdsNavDestination, HdsNavDestinationAttribute, DividerShowType
} from '@kit.UIDesignKit';

const TAG: string = 'UpdatePrivatePwdMixType';

@Component
export struct UpdatePrivatePwdMixType {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @Consume('innerPathInfos') innerPathInfos: NavPathStack;
  @Link passwordType: number;
  @Link isNeedPop: boolean;
  @State maxPasswordLength: number = AccountConstants.MIXED_PASSWORD_LENGTH;
  @State password: string = '';
  @State isFirstInput: boolean = true;
  @State buttonAreaWidth: number = 0;
  @State isEditing: boolean = true;
  @State title: Resource | string = this.initTitle();
  @State enableClick: boolean = true;
  @State canClick: boolean = true;
  @State tipMsg: string = '';
  @Provide containerHeight: number = 0;
  @State transitionType: NavigationSystemTransitionType = NavigationSystemTransitionType.DEFAULT;
  private oldSubType: osAccount.AuthSubType = osAccount.AuthSubType.PIN_SIX;

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
      passwordType: this.passwordType
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    showInSubWindow: true
  });
  private firstPassword: string = '';
  private textInputController: TextInputController = new TextInputController();

  async aboutToAppear(): Promise<void> {
    Log.info(TAG, 'aboutToAppear')
    this.transitionType = NavigationSystemTransitionType.TITLE;
    this.oldSubType = await currentPwdType();
    HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_UPDATE_PWD_MIX,
      HiSysEventConstants.USER_OPERATION_BEGIN);
  }

  aboutToDisappear(): void {
    Log.info(TAG, `aboutToDisappear`);
    this.changePsdTypeDialogController.close();
    this.dialogController.close();
    this.clearResource();
  }

  onPageShow(): void {
  }

  onPageHide(): void {
  }

  @Builder
  builderTitle(): void {
    Column() {
      Text(this.title)
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('app.float.font_16'))
        .padding({ right: 12, left: 12 })
        .accessibilityText(this.isFirstInput ?
        ResourceUtil.getAnyStrFormatStringSync($r('app.string.mixed_password_message_accessibility'),
          PasswordConstants.NUMBER_PSD_MIN_LENGTH_STRING, PasswordConstants.NUMBER_PSD_MAX_LENGTH_STRING,
          PasswordConstants.MIXED_PSD_MIN_LATTER_STRING) :
        ResourceUtil.getStringSync($r('app.string.enter_password_again_title')))
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .constraintSize({ minHeight: $r('app.float.wh_64') })
  }

  @Builder
  builderPasswordInput(): void {
    Column() {
      TextInput({
        text: this.password, placeholder: $r('app.string.hotspot_password'),
        controller: this.textInputController
      })
        .backgroundColor(Color.Transparent)
        .maxLength(this.maxPasswordLength)
        .type(InputType.Password)
        .enableAutoFill(false)
        .showPasswordIcon(true)
        .textAlign(TextAlign.Start)
        .enableKeyboardOnFocus(true)
        .defaultFocus(true)
        .onChange(async (val: string) => {
          this.inputChange(val);
        })
        .fontColor(($r('sys.color.ohos_id_color_text_primary')))
        .width('100%')
        .onEditChange((isEditing: boolean) => {
          this.isEditing = isEditing;
        })
        .onSubmit(() => {
          Log.info(TAG, `input submit`);
          this.inputFinish();
        })
        .id('updatePrivatePwdMixTypePasswordInput')

      Divider()
        .strokeWidth('1px')
        .color(this.isEditing ? $r('sys.color.ohos_id_color_text_primary') :
        $r('sys.color.ohos_id_color_list_separator'))
        .opacity(this.isEditing ? 0.6 : 1)
        .margin({ left: $r('app.float.wh_16'), right: $r('app.float.wh_16') })
    }
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

  @Builder
  builderTipMessage(): void {
    TipMessage({
      tipMsg: this.tipMsg
    })
  }

  @Builder
  buildBlank(): void {
    if (this.isEditing) {
      Column().height($r('app.float.wh_32'))
    } else {
      Blank();
    }
  }

  @Builder
  builderBottomBtn(): void {
    MixAndNumberPasswordPageButton({
      resourceLeft: $r('app.string.dialog_cancel'),
      resourceRight: this.isFirstInput ? $r('app.string.dialog_continue') : $r('app.string.dialog_sure'),
      buttonAreaWidth: this.buttonAreaWidth,
      enableClick: this.enableClick,
      cancelClicked: () => {
        HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_UPDATE_MIX_CANCEL,
          HiSysEventConstants.USER_OPERATION_CLICK);
        this.pathInfos.pop();
      },
      continueClicked: () => {
        if (this.canClick) {
          this.canClick = false;
          HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_UPDATE_MIX_CONFIRM,
            HiSysEventConstants.USER_OPERATION_CLICK);
          this.inputFinish();
        }
      }
    })
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column() {
            this.builderTitle();
            this.builderPasswordInput();
            this.builderTipMessage();
            if (this.isFirstInput) {
              this.builderOtherTypePassword();
            }
          }
          .margin({ top: $r('app.float.wh_24') })
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .align(Alignment.TopStart)
        .flexGrow(1)
        .flexShrink(1)

        this.builderBottomBtn();
      }
      .onAreaChange((oldValue: Area, newValue: Area) => {
        this.containerHeight = newValue.height as number;
        this.buttonAreaWidth = Math.min(CommonConstants.MAX_BUTTON_WIDTH,
          newValue.width as number - 2 * (DeviceUtils.isPhone() ? 16 : 24))
      })
      .height('100%')
      .padding({
        left: DeviceUtils.isPhone() ? $r('app.float.wh_16') : $r('app.float.wh_24'),
        right: DeviceUtils.isPhone() ? $r('app.float.wh_16') : $r('app.float.wh_24'),
      })
      .justifyContent(FlexAlign.Start)
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.KEYBOARD], [SafeAreaEdge.BOTTOM])
    }
    .onHidden(() => {
      Log.info(TAG, `onHidden`);
      this.onPageHide();
    })
    .onBackPressed(() => {
      Log.info(TAG, `onBackPressed`);
      this.transitionType = NavigationSystemTransitionType.TITLE;
      this.pathInfos.pop();
      HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_UPDATE_PWD_MIX,
        HiSysEventConstants.USER_OPERATION_CANCEL);
      return true;
    })
    .onShown(() => {
      Log.info(TAG, `onShown`);
      this.transitionType = NavigationSystemTransitionType.DEFAULT;
      this.onPageShow();
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

  private onCancelPsdType(): void {
    Log.info(TAG, `onCancelPsdType cancel`);
    this.changePsdTypeDialogController.close();
  }

  private initTitle(): string {
    return ResourceUtil.getAnyStrFormatStringSync($r('app.string.mixed_password_message'),
      PasswordConstants.NUMBER_PSD_MIN_LENGTH_STRING, PasswordConstants.NUMBER_PSD_MAX_LENGTH_STRING,
      PasswordConstants.MIXED_PSD_MIN_LATTER_STRING)
  }

  private onCancel(): void {
    Log.info(TAG, `dialog cancel`);
    this.dialogController.close();
    this.password = '';
    this.isFirstInput = true;
  }

  private onConfirm(): void {
    Log.info(TAG, `dialog confirm`);
    this.dialogController.close();
    this.firstPassword = this.password;
    this.isFirstInput = false;
    this.password = '';
    this.tipMsg = '';
    this.title = ResourceUtil.getStringSync($r('app.string.enter_password_again_title'));
  }

  private initOtherPsdTypeData(): PasswordTypeModel[] {
    let passwordData: PasswordTypeModel[] = [];
    let pinSixType: string = ResourceUtil.getNumberFormatString($r('app.string.pin_type'),
      AccountConstants.SIX_PIN_PASSWORD_LENGTH);
    passwordData.push(new PasswordTypeModel(PinSubType.PIN_SIX, pinSixType));
    passwordData.push(new PasswordTypeModel(PinSubType.PIN_NUMBER,
      ResourceUtil.getStringSync($r('app.string.number_password_type'))));
    return passwordData;
  }

  private inputChange(value: string): void {
    if (value === null || value === undefined || value === '') {
      return;
    }
    this.password = value;
    if (value.length > this.maxPasswordLength) {
      Log.warn(TAG, `length is over max length`);
      return;
    }
    if (value.length < PasswordConstants.MIXED_PSD_MIN_LENGTH) {
      this.tipMsg = ResourceUtil.getNumberFormatString($r('app.string.mixed_password_too_short'),
        PasswordConstants.MIXED_PSD_MIN_LENGTH);
      AccessibilityUtil.autoReadForAccessibility(this.tipMsg);
      return;
    }
    if (PasswordUtils.isContainIllegalCharacter(this.password)) {
      Log.warn(TAG, `password isContainIllegalCharacter`);
      this.tipMsg = ResourceUtil.getAnyNumFormatStringSync($r('app.string.mixed_password_contains_illegal_character'));
      AccessibilityUtil.autoReadForAccessibility(this.tipMsg);
      return;
    }
    if (!PasswordUtils.isIncludeAtLeastOneLetter(this.password)) {
      Log.warn(TAG, `password include no letter`);
      this.tipMsg = ResourceUtil.getNumberFormatString($r('app.string.mixed_password_include_letter'),
        PasswordConstants.MIXED_PSD_MIN_LATTER);
      AccessibilityUtil.autoReadForAccessibility(this.tipMsg);
      return
    }
    this.tipMsg = '';
  }

  private passwordInputRequestFocus(endIndex: number): void {
    const id1 = setTimeout(() => {
      focusControl.requestFocus('updatePrivatePwdMixTypePasswordInput');
      const id2 = setTimeout(() => {
        this.textInputController.setTextSelection(0, endIndex);
        clearTimeout(id1);
        clearTimeout(id2);
      }, 0);
    }, 0);
  }

  private inputFinish(): void {
    if (!this.password) {
      Log.error(TAG, `password is empty`);
      this.enableClick = true;
      this.canClick = true;
      return;
    }

    if (this.password !== this.firstPassword && !this.isFirstInput) {
      Log.warn(TAG, `password not same`);
      this.textInputController.setTextSelection(0, this.password.length);
      this.tipMsg = ResourceUtil.getStringSync($r('app.string.password_repeat_error_title'));
      AccessibilityUtil.autoReadForAccessibility(this.tipMsg);
      this.passwordInputRequestFocus(this.password.length);
      this.enableClick = true;
      this.canClick = true;
      return;
    }

    if (this.password.length < PasswordConstants.NUMBER_PSD_MIN_LENGTH) {
      this.tipMsg =
        ResourceUtil.getNumberFormatString($r('app.string.mixed_password_too_short'),
          PasswordConstants.NUMBER_PSD_MIN_LENGTH);
      AccessibilityUtil.autoReadForAccessibility(this.tipMsg);
      this.enableClick = true;
      this.canClick = true;
      return;
    }
    if (PasswordUtils.isContainIllegalCharacter(this.password)) {
      Log.warn(TAG, `password isContainIllegalCharacter`);
      this.tipMsg = ResourceUtil.getStringSync($r('app.string.mixed_password_contains_illegal_character'));
      AccessibilityUtil.autoReadForAccessibility(this.tipMsg);
      this.enableClick = true;
      this.canClick = true;
      return;
    }
    if (!PasswordUtils.isIncludeAtLeastOneLetter(this.password)) {
      Log.warn(TAG, `password isIncludeAtLeastOneLetter`);
      this.tipMsg = ResourceUtil.getNumberFormatString($r('app.string.mixed_password_include_letter'),
        PasswordConstants.MIXED_PSD_MIN_LATTER);
      AccessibilityUtil.autoReadForAccessibility(this.tipMsg);
      this.enableClick = true;
      this.canClick = true;
      return;
    }

    if (this.isFirstInput) {
      if (PasswordUtils.isWeakPasswords(this.password)) {
        Log.info(TAG, `weak password`);
        this.dialogController.open();
        this.enableClick = true;
        this.canClick = true;
        return;
      }

      this.firstPassword = this.password;
      this.isFirstInput = false;
      this.password = '';
      this.tipMsg = '';
      this.title = ResourceUtil.getStringSync($r('app.string.enter_pin_again_title'));
      this.enableClick = true;
      this.canClick = true;
      return;
    }

    this.updatePwd();
  }

  private updatePwd(): void {
    PasswordUtils.unregisterInputer();
    PasswordUtils.registerPriPwdInputer(osAccount.AuthSubType.PIN_MIXED, this.password);
    let token = SecurityManager.getInstance().getToken();
    if (!token) {
      Log.error(TAG, `get token failed`);
      return;
    }
    PasswordUtils.updatePriPwd(this.oldSubType, token, (result, extraInfo) => {
      if (result === ResultCode.SUCCESS) {
        Log.info(TAG, `update private pwd success`);
        this.enableClick = true;
        getCurrentTokenAndCredId().then((res) => {
          HiSysEventUtil.setCredentialAndTempIdAfter(res.credentialId, res.templateId);
          HiSysEventUtil.reportUpdateEvent(HiSysEventConstants.UPDATE_PWD);
        })
        HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_UPDATE_PWD_MIX,
          HiSysEventConstants.USER_OPERATION_END);
        this.pathInfos.pop();
        return;
      }
      Log.error(TAG, `update private pwd failed, result: ${result}`);
      this.enableClick = true;
      this.canClick = true;
      this.pathInfos.pop();
      return;
    })
  }

  private clearResource(): void {
    this.password = '';
  }
}