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
import { osAccount } from '@kit.BasicServicesKit';
import { CommonConstants } from '../../common/constants/CommonConstants';
import { HiSysEventConstants } from '../../common/constants/HiSysEventConstants';
import AccessibilityUtil from '../../common/utils/AccessibilityUtil';
import { DeviceUtils } from '../../common/utils/DeviceUtils';
import FormatUtil from '../../common/utils/FormatUtil';
import { HiSysEventUtil } from '../../common/utils/HiSysEventUtil';
import Log from '../../common/utils/Log';
import { PasswordUtils, ResultCode } from '../../common/utils/PasswordUtils';
import { ResourceUtil } from '../../common/utils/ResourceUtil';
import MixAndNumberPasswordPageButton from '../MixAndNumberPasswordPageButton';
import SecurityManager from '../../security/SecurityManager';
import { AccountConstants } from '../../common/constants/AccountConstants';
import { getCurrentTokenAndCredId } from '../../common/PrivacyPassword';
import { PasswordConstants } from '../../common/constants/PasswordConstants';

const TAG: string = 'CheckMixedAndNumberPwd';

@Component
export struct CheckMixedAndNumberPwd {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @Link authPinType: osAccount.AuthSubType;
  @Link isNeedPop: boolean;
  @Link isChecked: boolean;
  @Link forgetPwd: boolean;
  @Link credentialId?: Uint8Array;
  @State password: string = '';
  @State isEditing: boolean = false;
  @State buttonAreaHeight: number = 0;
  @State buttonAreaWidth: number = 0;
  @Provide containerHeight: number = 0;
  @State title: ResourceStr = $r('app.string.verify_privacy_password');
  @State hasFreezingTime: boolean = false;
  @State freezeTimeMessage: ResourceStr = '';
  @State enableClick: boolean = true;
  @State canClick: boolean = true;
  @State tipMsg: string = '';
  private timer: number | undefined = undefined;
  private freezingTime: number | undefined = undefined;

  aboutToAppear(): void {
    this.passwordInputRequestFocus();
    this.initStatus();
    HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_CHECK_MIX_AND_NUM,
      HiSysEventConstants.USER_OPERATION_BEGIN);
  }

  aboutToDisappear(): void {
    PasswordUtils.unregisterInputer();
    PasswordUtils.closeSession(TAG);
    this.clearResource();
  }

  private clearResource(): void {
    this.password = '';
    this.credentialId = undefined;
  }

  private inputFinish(): void {
    if (!this.password) {
      this.enableClick = true;
      this.canClick = true;
      return;
    }
    this.checkPassword();
  }

  private initStatus(): void {
    PasswordUtils.getAuthProperty((data) => {
      if (data?.result === ResultCode.SUCCESS) {
        this.hasFreezingTime =
          (data?.freezingTime && data?.freezingTime >= AccountConstants.MIN_COUNT_DOWN_TIME) as boolean;
        if (this.hasFreezingTime) {
          this.freezingTime = data.freezingTime;
          this.startTimer();
        }
      } else {
        Log.info(TAG, `initStatus getAuthProperty failed`);
      }
    });
  }

  private checkPassword(): void {
    Log.info(TAG, `checkPassword start`);
    PasswordUtils.unregisterInputer();
    PasswordUtils.registerInputer(this.authPinType);
    PasswordUtils.openSession(TAG).then(() => {
      let challenge = SecurityManager.getInstance().getChallenge();
      PasswordUtils.authPin(challenge, this.password, (result, extraInfo) => {
        this.canClick = true;
        if (result === ResultCode.SUCCESS) {
          Log.info(TAG, `auth password success`);
          this.tipMsg = '';
          this.isChecked = true;
          this.credentialId = extraInfo.credentialId
          this.enableClick = true;
          getCurrentTokenAndCredId().then((res) => {
            HiSysEventUtil.setCredentialAndTempIdBefore(res.credentialId, res.templateId);
            HiSysEventUtil.updateByPwd();
          })
          HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_CHECK_MIX_AND_NUM,
            HiSysEventConstants.USER_OPERATION_END);
          return;
        }
        Log.warn(TAG, `auth password fail, ${result}`);
        this.isChecked = false;
        const freezeTime = extraInfo.freezingTime;
        if (freezeTime && freezeTime > 0) {
          this.hasFreezingTime = true;
          this.freezingTime = extraInfo.freezingTime;
          this.startTimer();
        }

        const remainTime = extraInfo.remainTimes;
        if (remainTime && remainTime > 0) {
          Log.warn(TAG, `check warn ${remainTime}`);
          this.tipMsg = this.authPinType === osAccount.AuthSubType.PIN_MIXED ?
            ResourceUtil.getPluralStringSync($r('app.plural.password_message_incorrect'), remainTime) :
            ResourceUtil.getPluralStringSync($r('app.plural.pin_message_incorrect'), remainTime)
          AccessibilityUtil.autoReadForAccessibility(this.tipMsg);
          this.password = '';
          this.enableClick = true;
          return;
        }
      })
    })
  }

  private startTimer(): void {
    Log.info(TAG, `startTimer ${this.timer}`);
    this.getFreezingMessage();
    if (this.freezingTime) {
      this.timer = setInterval(() => {
        this.getFreezingMessage();
      }, CommonConstants.MILE_SECOND_TO_SECOND)
    }
  }

  private getFreezingMessage(): void {
    if (this.freezingTime) {
      if (this.freezingTime <= CommonConstants.MILE_SECOND_TO_SECOND) {
        this.hasFreezingTime = false;
        const id = setTimeout(() => {
          focusControl.requestFocus('checkMixedAndNumberPwdPasswordInput');
          clearTimeout(id);
        }, CommonConstants.INPUT_FOCUS_DELAY);
        this.password = '';
        this.tipMsg = '';
        Log.info(TAG, 'Show input psd and reset');
      }
      this.enableClick = true;
      this.canClick = true;
      this.freezingTime -= CommonConstants.MILE_SECOND_TO_SECOND;
      this.freezeTimeMessage = FormatUtil.getCountDownMessage(this.freezingTime);
    } else if (this.freezingTime === 0) {
      Log.info(TAG, 'freezingTime is 0, clear');
      this.releaseResource();
    } else {
      Log.error(TAG, 'freezingTime is invalid');
    }
  }

  private releaseResource(): void {
    if (this.timer === undefined) {
      Log.warn(TAG, 'timer is undefined');
      return;
    }
    Log.info(TAG, `release timer ${this.timer}`);
    clearInterval(this.timer);
    this.timer = undefined;
  }

  private passwordInputRequestFocus(): void {
    const id = setTimeout(() => {
      focusControl.requestFocus('checkMixedAndNumberPwdPasswordInput');
      clearTimeout(id);
    }, CommonConstants.INPUT_FOCUS_DELAY);
  }

  @Builder
  builderPasswordComponent(): void {
    Column() {
      TextInput({ text: this.password, placeholder: $r('app.string.hotspot_password') })
        .backgroundColor(Color.Transparent)
        .type(this.authPinType === osAccount.AuthSubType.PIN_MIXED ? InputType.Password : InputType.NUMBER_PASSWORD)
        .enableAutoFill(false)
        .showPasswordIcon(true)
        .textAlign(TextAlign.Start)
        .enableKeyboardOnFocus(true)
        .defaultFocus(true)
        .onChange(async (val: string) => {
          this.password = val;
        })
        .fontColor(($r('sys.color.ohos_id_color_text_primary')))
        .inputFilter(this.authPinType !== osAccount.AuthSubType.PIN_MIXED ? '[0-9]' : '')
        .width('100%')
        .maxLength(PasswordConstants.NUMBER_PSD_MAX_LENGTH)
        .onEditChange((isEditing: boolean) => {
          this.isEditing = isEditing;
        })
        .onSubmit(() => {
          Log.info(TAG, `input submit`);
          this.enableClick = false;
          this.inputFinish();
        })
        .id('checkMixedAndNumberPwdPasswordInput')

      Divider()
        .strokeWidth('1px')
        .color(this.isEditing ? $r('sys.color.ohos_id_color_text_primary') :
        $r('sys.color.ohos_id_color_list_separator'))
        .opacity(this.isEditing ? 0.6 : 1)
        .margin({ left: $r('app.float.wh_16'), right: $r('app.float.wh_16') })
    }
  }

  @Builder
  builderTipMessage(): void {
    Row() {
      Text(this.tipMsg)
        .width('100%')
        .fontColor($r('sys.color.ohos_id_color_warning'))
        .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
    }
    .margin({ top: $r('app.float.wh_32') })
  }

  @Builder
  builderCheckPasswordContent(): void {
    Column() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start }) {
        Scroll() {
          Column() {
            this.builderPasswordComponent();
            this.builderTipMessage();
            this.builderForgetPwdTips();
            Blank();
          }
        }
        .height(this.containerHeight - this.buttonAreaHeight - 24)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .align(Alignment.TopStart)
        .flexGrow(1)
        Row() {
          this.builderBottomBtn();
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  builderForgetPwdTips(): void {
    Button(this.authPinType === osAccount.AuthSubType.PIN_MIXED ?
    $r('app.string.forgot_password') : $r('app.string.forgot_pin'), {
      buttonStyle: ButtonStyleMode.TEXTUAL
    })
    .width('100%')
    .fontWeight(FontWeight.Medium)
    .fontSize($r('sys.float.Body_L'))
    .fontColor($r('sys.color.font_emphasize'))
    .margin({ top: $r('app.float.wh_20') })
    .padding({
      left: $r('sys.float.padding_level8'),
      top: $r('sys.float.padding_level6'),
      right: $r('sys.float.padding_level8'),
      bottom : $r('sys.float.padding_level6')
    })
    .onClick(() => {
      this.forgetPwd = true;
    })
  }

  @Builder
  builderBottomBtn(): void {
    MixAndNumberPasswordPageButton({
      resourceLeft: $r('app.string.dialog_cancel'),
      resourceRight: $r('app.string.dialog_next'),
      buttonAreaWidth: this.buttonAreaWidth,
      enableClick: this.enableClick,
      cancelClicked: () => {
        this.pathInfos.pop();
        HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_CHECK_MIX_AND_NUM_CANCEL,
          HiSysEventConstants.USER_OPERATION_CLICK);
      },
      continueClicked: () => {
        if (this.canClick) {
          this.canClick = false;
          this.inputFinish();
          HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_CHECK_MIX_AND_NUM_NEXT,
            HiSysEventConstants.USER_OPERATION_CLICK);
        }
      }
    })
  }

  @Builder
  builderContent(): void {
    if (this.hasFreezingTime) {
      this.builderTimerCount();
    } else {
      this.builderCheckPasswordContent();
    }
  }

  build() {
    Column() {
      this.builderContent();
    }
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.containerHeight = newValue.height as number;
      this.buttonAreaWidth = Math.min(CommonConstants.MAX_BUTTON_WIDTH,
        newValue.width as number - 2 * (DeviceUtils.isPhone() ? 16 : 24))
    })
    .margin({ top: $r('app.float.wh_24') })
    .padding({
      left: DeviceUtils.isPhone() ? $r('app.float.wh_16') : $r('app.float.wh_24'),
      right: DeviceUtils.isPhone() ? $r('app.float.wh_16') : $r('app.float.wh_24'),
    })
    .justifyContent(FlexAlign.Start)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  builderTimerCount(): void {
    Text(this.freezeTimeMessage)
      .width('100%')
      .fontWeight(FontWeight.Medium)
      .fontSize($r('sys.float.ohos_id_text_size_body1'))
      .constraintSize({ minHeight: $r('app.float.wh_48') })
      .backgroundColor($r('sys.color.ohos_id_color_list_card_bg'))
      .textAlign(TextAlign.Center)
      .borderRadius($r('app.float.wh_10'))
      .fontColor($r('sys.color.font_emphasize'))
      .margin({ top: $r('app.float.wh_66') })
      .id('checkMixedAndNumberPwdTimerCountId')
      .onAppear(() => {
        AccessibilityUtil.autoFocusForAccessibility('checkMixedAndNumberPwdTimerCountId');
      })
  }
}