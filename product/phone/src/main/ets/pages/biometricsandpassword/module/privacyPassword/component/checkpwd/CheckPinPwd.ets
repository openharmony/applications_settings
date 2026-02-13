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
import { CommonConstants } from '../../common/constants/CommonConstants';
import { HiSysEventConstants } from '../../common/constants/HiSysEventConstants';
import AccessibilityUtil from '../../common/utils/AccessibilityUtil';
import { HiSysEventUtil } from '../../common/utils/HiSysEventUtil';
import Log from '../../common/utils/Log';
import { PasswordUtils, PinSubType, ResultCode } from '../../common/utils/PasswordUtils';
import { AccountConstants } from '../../common/constants/AccountConstants';
import FormatUtil from '../../common/utils/FormatUtil';
import SecurityManager from '../../security/SecurityManager';
import { getCurrentTokenAndCredId } from '../../common/PrivacyPassword';

const TAG: string = 'CheckPinPwd';
const MAX_PWD_LENGTH: number = 6;

@Component
export struct CheckPinPwd {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @Link isNeedPop: boolean;
  @Link isChecked: boolean;
  @Link credentialId?: Uint8Array;
  @Link forgetPwd: boolean;
  @State password: string = '';
  @State navigationIndicatorHeight: number | undefined =
    LocalStorage.getShared().get<number>(CommonConstants.NAVIGATION_INDICATOR_HEIGHT_KEY);
  @State hasFreezingTime: boolean = false;
  @State freezeTimeMessage: ResourceStr = '';
  @State tipMsg: string = '';
  innerPathInfos: NavPathStack = new NavPathStack();
  private timer: number | undefined = undefined;
  private freezingTime: number | undefined = undefined;
  private bgColorPrimary: Resource = $r('sys.color.ohos_id_color_background_transparent');
  private bgColorSecondary: Resource = $r('sys.color.ohos_id_color_foreground');

  @State bgColors: Resource[] = [
    this.bgColorPrimary, this.bgColorPrimary,
    this.bgColorPrimary, this.bgColorPrimary,
    this.bgColorPrimary, this.bgColorPrimary];

  aboutToAppear(): void {
    Log.info(TAG, `aboutToAppear`);
    HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_CHECK_PIN,
      HiSysEventConstants.USER_OPERATION_BEGIN);
    this.initStatus();
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

  private initStatus(): void {
    PasswordUtils.getAuthProperty((data) => {
      if (data?.result === ResultCode.SUCCESS) {
        this.hasFreezingTime =
          (data?.freezingTime && data?.freezingTime >= AccountConstants.MIN_COUNT_DOWN_TIME) as boolean;
        Log.info(TAG, `other freezing startCountDonwTimer ${this.hasFreezingTime}`);
        if (this.hasFreezingTime) {
          this.freezingTime = data.freezingTime;
          this.startTimer();
        }
      } else {
        Log.error(TAG, `initStatus getAuthProperty failed`);
      }
    });
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
          focusControl.requestFocus('checkPinPwdPasswordInput');
          clearTimeout(id);
        }, CommonConstants.INPUT_FOCUS_DELAY);
        this.password = '';
        this.tipMsg = '';
        this.inputChange(this.password);
        Log.info(TAG, 'Show input psd and reset');
      }
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

  private inputChange(value: string): void {
    this.password = value;
    if (value.length > MAX_PWD_LENGTH) {
      return;
    }

    for (let i = 0; i < MAX_PWD_LENGTH; i++) {
      if (i < value.length) {
        this.bgColors[i] = this.bgColorSecondary;
      } else {
        this.bgColors[i] = this.bgColorPrimary;
      }
    }

    if (PasswordUtils.isPinNumber6(value)) {
      this.inputFinish();
    }
  }

  private inputFinish(): void {
    if (!this.password) {
      return;
    }
    this.checkPassword();
  }

  private checkPassword(): void {
    Log.info(TAG, `checkPassword start`);
    PasswordUtils.unregisterInputer();
    PasswordUtils.registerInputer(PinSubType.PIN_SIX);
    PasswordUtils.openSession(TAG).then(() => {
      let challenge = SecurityManager.getInstance().getChallenge();
      PasswordUtils.authPin(challenge, this.password, (result, extraInfo) => {
        if (result === ResultCode.SUCCESS) {
          Log.info(TAG, `auth password success`);
          this.tipMsg = '';
          this.isChecked = true;
          SecurityManager.getInstance().setOldPassword(this.password);
          this.isNeedPop = false;
          this.credentialId = extraInfo.credentialId;
          getCurrentTokenAndCredId().then((res) => {
            HiSysEventUtil.setCredentialAndTempIdBefore(res.credentialId, res.templateId);
            HiSysEventUtil.updateByPwd();
          });
          HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_CHECK_PIN,
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
        const remainTime: number | undefined = extraInfo.remainTimes;
        if (remainTime && remainTime > 0) {
          Log.error(TAG, `check warn ${remainTime}`);
          this.tipMsg = ResourceUtil.getPluralStringSync($r('app.plural.pin_message_incorrect'), remainTime);
          AccessibilityUtil.autoReadForAccessibility(this.tipMsg);
          this.password = '';
          return;
        }
      })
    })
  }

  @Builder
  builderPasswordCircleComponent(): void {
    Stack() {
      TextInput({ text: this.password })
        .backgroundColor(Color.Transparent)
        .caretColor(Color.Transparent)
        .maxLength(MAX_PWD_LENGTH)
        .type(InputType.NUMBER_PASSWORD)
        .enableAutoFill(false)
        .showPasswordIcon(false)
        .textAlign(TextAlign.Center)
        .enableKeyboardOnFocus(true)
        .defaultFocus(true)
        .onChange((val: string) => {
          this.inputChange(val);
        })
        .opacity(0)
        .fontColor(($r('sys.color.ohos_id_color_text_primary')))
        .inputFilter('[0-9]')
        .width('100%')
        .showPasswordIcon(false)
        .id('checkPinPwdPasswordInput')

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
    .accessibilityLevel(this.enableAccessibility())
    .accessibilityGroup(true)
    .accessibilityText(this.getPasswordReadText())
    .accessibilityDescription(' ')
    .id('passwordInputContainer')
    .margin({ top: '88vp' })
    .hitTestBehavior(HitTestMode.Block)
    .onClick(() => {
      focusControl.requestFocus('checkPinPwdPasswordInput');
    })
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
        .fontFamily('HarmonyHeiTi')
    }
    .margin({ top: $r('app.float.wh_32') })
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
      .id('checkPinPwdTimerCountId')
      .onAppear(() => {
        AccessibilityUtil.autoFocusForAccessibility('checkPinPwdTimerCountId');
      })
  }

  @Builder
  builderForgetPwdTips(): void {
    Button($r('app.string.forgot_pin'), {
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
  builderCheckPasswordContent(): void {
    Scroll() {
      Column() {
        this.builderPasswordCircleComponent();
        this.builderTipMessage();
        this.builderForgetPwdTips();
      }
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .align(Alignment.TopStart)
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
      Column() {
        this.builderContent();
      }
      .padding({
        left: $r('app.float.wh_24'), right: $r('app.float.wh_24')
      })
      .justifyContent(FlexAlign.Start)
    }
    .height('100%')
    .padding({ bottom: this.navigationIndicatorHeight })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  private enableAccessibility(): string {
    return this.isChecked ? 'no' : 'yes'
  }

  private getPasswordReadText(): string {
    const length = this.password.length;
    const begin = ResourceUtil.getPluralStringSync($r('app.plural.private_password_edit_read_begin'), MAX_PWD_LENGTH);
    const end = ResourceUtil.getPluralStringSync($r('app.plural.password_edit_read_end'), length);
    return `${begin} ${end}`;
  }
}