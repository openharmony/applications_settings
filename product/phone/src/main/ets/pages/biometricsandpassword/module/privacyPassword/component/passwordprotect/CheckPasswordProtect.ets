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
import { BusinessError, osAccount } from '@kit.BasicServicesKit';
import { DeviceUtil, NavEntryKey, PasswordUtil } from '@ohos/settings.common';
import { ResourceUtil } from '../../common/utils/ResourceUtil';
import { PasswordProtectConstants } from '../../common/constants/PasswordProtectionConstants';
import AccessibilityUtil from '../../common/utils/AccessibilityUtil';
import { DeviceUtils } from '../../common/utils/DeviceUtils';
import FontScaleUtils, { LARGE_LIMIT_HEIGHT } from '../../common/utils/FontScaleUtils';
import Log from '../../common/utils/Log';
import SecurityManager from '../../security/SecurityManager';
import { CommonConstants } from '../../common/constants/CommonConstants';
import { HiSysEventUtil } from '../../common/utils/HiSysEventUtil';
import { HiSysEventConstants } from '../../common/constants/HiSysEventConstants';
import { PasswordUtils, ResultCode } from '../../common/utils/PasswordUtils';
import SetPasswordModel from '../../model/SetPasswordModel';
import { PADDING_16, PADDING_24 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { common } from '@kit.AbilityKit';
import {
  HdsNavDestinationTitleMode, HdsNavDestination, HdsNavDestinationAttribute, DividerShowType
} from '@kit.UIDesignKit';

const TAG: string = 'CheckPasswordProtect';
const TIP_MESSAGE: string = 'tipMessage';
const TIMER_COUNT: string = 'timerCount';

@Component
export struct CheckPasswordProtect {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State question: string = '';
  @State bottomMargin: number = 16;
  @State containerWidth: number = 0;
  @State buttonAreaWidth: number = 0;
  @State bottomHeight: number = 0;
  @State avoidKeyboardMargin: number = 0;
  innerPathInfos: NavPathStack = new NavPathStack();
  @Link isChecked: boolean;
  @State keyboardHeight: number = 0;
  @State @Watch('statusChange') remainTimes: number = 0;
  @State @Watch('statusChange') freezeTimes: number = 0;
  @State @Watch('PwdChange') secureIssuePwd: string = '';
  @State @Watch('statusChange') showAuthError: boolean = false;
  @State enableClick: boolean = true;
  @State authEnable: boolean = true;
  @State isInputEnable: boolean = false;
  @State questionStatusMsg: string | Resource = ``;
  private tokenTimer: number | undefined;
  private timer: number | undefined = undefined;
  private exceedLength: boolean = false;

  @State showInputError: boolean = false;
  @State isHeightTooSmall: boolean = false;
  @State @Watch('onContainerChange') containerHeight: number = 0;
  @State transitionType: NavigationSystemTransitionType = NavigationSystemTransitionType.DEFAULT;
  onContainerChange() {
    this.isHeightTooSmall = this.containerHeight < LARGE_LIMIT_HEIGHT;
  }
  statusChange(): void {
    if (this.remainTimes === 0 || this.freezeTimes > 0) {
      this.authEnable = false;
    } else {
      this.authEnable = true;
    }

    if (this.showAuthError || !this.authEnable) {
      if (this.remainTimes === 0 && this.freezeTimes === 0) {
        this.questionStatusMsg = '';
      } else {
        this.questionStatusMsg = this.freezeTimes === 0
          ? ResourceUtil.getPluralStringSync($r('app.plural.attempts_n', this.remainTimes), this.remainTimes)
          : PasswordUtil.getCountDownDialogMessage(this.freezeTimes);
      }
    } else {
      this.questionStatusMsg = '';
    }

    if (this.timer === undefined && this.freezeTimes > 0) {
      this.timer = setInterval(() => {
        this.freezeTimes -= 1000;
      }, 1000);
    }

    if (this.timer !== undefined && this.freezeTimes <= 0) {
      this.showAuthError = false;
      this.initQuestionStatus();
      clearInterval(this.timer);
      this.timer = undefined;
    }
  }

  PwdChange(): void {
    if (this.secureIssuePwd.length >= PasswordProtectConstants.TEXT_MIN_LENGTH &&
      this.secureIssuePwd.length <= PasswordProtectConstants.TEXT_MAX_LENGTH) {
      this.isInputEnable = true;
    } else {
      this.isInputEnable = false;
    }
    this.showAuthError = false;

    if (this.secureIssuePwd.length > PasswordProtectConstants.TEXT_MAX_LENGTH) {
      this.showInputError = true;
    } else {
      this.showInputError = false;
    }
  }

  async aboutToAppear(): Promise<void> {
    Log.info(TAG, 'aboutToAppear')
    this.transitionType = NavigationSystemTransitionType.TITLE;
    let ctx: Context = getContext(this);
    this.question = await this.getQuestion(ctx);
    this.initQuestionStatus();
    const id = setTimeout(() => {
      focusControl.requestFocus('answerInput');
      clearTimeout(id);
    }, CommonConstants.INPUT_FOCUS_DELAY);
    HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_CHECK_PWD_PROTECT,
      HiSysEventConstants.USER_OPERATION_BEGIN);
  }

  aboutToDisappear(): void {
    if (this.timer !== undefined) {
      clearInterval(this.timer);
    }
    this.clearResource();
    PasswordUtils.unregisterInputer();
    PasswordUtils.closeSession(TAG);
  }

  cancel: () => void = () => {
    Log.info(TAG, 'cancel button is clicked');
    this.enableClick = true;
    this.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
  }

  clearTimer(): void {
    if (this.tokenTimer !== undefined) {
      clearTimeout(this.tokenTimer);
      this.tokenTimer = undefined;
      Log.info(TAG, 'clear token timer success');
    }
  }

  @Builder
  builderTipMessage(): void {
    Row() {
      if (this.showAuthError) {
        Text($r('app.string.answer_wrong'))
          .width('100%')
          .fontColor($r('sys.color.ohos_id_color_warning'))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .id(TIP_MESSAGE)
          .textAlign(TextAlign.Start)
          .align(Alignment.TopStart)
          .margin({ top: $r('sys.float.padding_level4') })
      }
    }
    .align(Alignment.TopStart)
  }

  @Builder
  builderTimerCount(): void {
    if (this.questionStatusMsg) {
      Text(this.questionStatusMsg)
        .width('100%')
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_M'))
        .textAlign(TextAlign.Center)
        .padding({ left: 12, right: 12 })
        .fontColor($r('app.color.font_color_error'))
        .margin({ top: $r('app.float.wh_66') })
        .id(TIMER_COUNT)
    }
  }

  build() {
    NavDestination() {
      Column() {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
          Scroll() {
            List() {
              ListItem() {
                Row() {
                  Text(this.question)
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .fontSize($r('sys.float.ohos_id_text_size_body1'))
                    .fontFamily('HarmonyHeiTi')
                    .fontWeight(FontWeight.Medium)
                    .textAlign(TextAlign.Start)
                }
                .justifyContent(FlexAlign.Start)
                .width('100%')
                .margin({ top: 24})
              }

              ListItem() {
                Column() {
                  TextInput({
                    placeholder: $r('app.string.intput_character_length_from_to',
                      PasswordProtectConstants.TEXT_MIN_LENGTH, PasswordProtectConstants.TEXT_MAX_LENGTH)
                  })
                    .textInputStyle()
                    .enabled(this.authEnable)
                    .id('answerInput')
                    .onChange((value: string) => {
                      this.secureIssuePwd = value;
                      this.exceedLength = value.length > PasswordProtectConstants.TEXT_MAX_LENGTH;
                    })
                    .onEditChange((isEditing: boolean) => {
                      this.calcOffset(isEditing);
                    })
                    .showError(this.showAuthError ?
                    ResourceUtil.getStringSync($r('app.string.answer_wrong')) :
                      (this.showInputError ? $r('app.string.input_max_length_message') : undefined))
                }
                .onAreaChange(() => {
                  if (this.exceedLength) {
                    AccessibilityUtil.autoReadForAccessibility(ResourceUtil.getStringSync($r('app.string.input_max_length_message')));
                  }
                })
              }

              ListItem() {
                this.builderTimerCount();
              }
            }
            .divider({ strokeWidth: 20, color: $r('sys.color.ohos_id_color_sub_background') })
            .scrollBar(BarState.Off)
            .width('100%')
            .padding({ left: 12, right: 12 })
            .margin({ bottom: this.avoidKeyboardMargin })
            .onAreaChange(() => {
              if (this.remainTimes && this.remainTimes > 0 && this.questionStatusMsg !== '') {
                AccessibilityUtil.autoFocusForAccessibility(this.questionStatusMsg as string);
              }
              if (this.freezeTimes) {
                AccessibilityUtil.autoFocusForAccessibility(TIMER_COUNT);
              }
            })
          }
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Auto)
          .edgeEffect(EdgeEffect.Spring)
          .align(Alignment.TopStart)
          .flexGrow(1)

          if (FontScaleUtils.buttonColumnLayout(this.buttonAreaWidth, $r('app.string.button_tittle_cancel'),
            $r('app.string.button_title_ok'))) {
            if (this.isHeightTooSmall && FontScaleUtils.isExtraLargeFontMode(getContext() as common.UIAbilityContext)) {
              Column({ space: 12 }) {
                Button($r('app.string.dialog_cancel'))
                  .width('100%')
                  .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                  .fontFamily('HarmonyHeiTi')
                  .fontWeight(FontWeight.Medium)
                  .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
                  .type(ButtonType.Normal)
                  .borderRadius($r('sys.float.corner_radius_level10'))
                  .constraintSize({ minHeight: 40 })
                  .fontSize(FontScaleUtils.getRealPX(getContext(), $r('sys.float.ohos_id_text_size_button1')))
                  .onClick(() => {
                    this.cancel();
                    HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_CHECK_PWD_PROTECT_CANCEL,
                      HiSysEventConstants.OPERATION_CHECK_PWD_PROTECT_CANCEL);
                  })
                Button($r('app.string.button_title_ok'))
                  .width('100%')
                  .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                  .fontFamily('HarmonyHeiTi')
                  .fontWeight(FontWeight.Medium)
                  .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
                  .type(ButtonType.Normal)
                  .borderRadius($r('sys.float.corner_radius_level10'))
                  .constraintSize({ minHeight: 40 })
                  .fontSize(FontScaleUtils.getRealPX(getContext(), $r('sys.float.ohos_id_text_size_button1')))
                  .onClick(() => {
                    this.enableClick = false;
                    HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_CHECK_PWD_PROTECT_NEXT,
                      HiSysEventConstants.USER_OPERATION_CLICK);
                    this.authAnswer();
                  })
              }
              .onAreaChange((_oldValue: Area, newValue: Area) => {
                this.bottomHeight = newValue.height as number;
              })
              .margin({
                top: $r('sys.float.padding_level8'),
                bottom: $r('sys.float.padding_level8')
              })
              .width(this.buttonAreaWidth)
              .flexShrink(0)
              .margin({ top: 16 })
            } else {
              Column({ space: 12 }) {
                Button($r('app.string.cancel'))
                  .width('100%')
                  .buttonExtendStyle()
                  .onClick(() => {
                    this.cancel();
                    HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_CHECK_PWD_PROTECT_CANCEL,
                      HiSysEventConstants.OPERATION_CHECK_PWD_PROTECT_CANCEL);
                  })
                Button($r('app.string.button_title_ok'))
                  .width('100%')
                  .buttonExtendStyle()
                  .enabled(this.isInputEnable && this.authEnable && this.enableClick)
                  .onClick(() => {
                    this.enableClick = false;
                    HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_CHECK_PWD_PROTECT_NEXT,
                      HiSysEventConstants.USER_OPERATION_CLICK);
                    this.authAnswer();
                  })
              }
              .onAreaChange((_oldValue: Area, newValue: Area) => {
                this.bottomHeight = newValue.height as number;
              })
              .flexShrink(0)
              .margin({
                top: $r('sys.float.padding_level8'),
                bottom: $r('sys.float.padding_level8')
              })
            }
          } else {
            Row({ space: 12 }) {
              Button($r('app.string.cancel'))
                .layoutWeight(1)
                .buttonExtendStyle()
                .onClick(() => {
                  this.cancel();
                  HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_CHECK_PWD_PROTECT_CANCEL,
                    HiSysEventConstants.OPERATION_CHECK_PWD_PROTECT_CANCEL);
                })
              Button($r('app.string.button_title_ok'))
                .layoutWeight(1)
                .buttonExtendStyle()
                .enabled(this.isInputEnable && this.authEnable && this.enableClick)
                .onClick(() => {
                  this.enableClick = false;
                  HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_CHECK_PWD_PROTECT_NEXT,
                    HiSysEventConstants.USER_OPERATION_CLICK);
                  this.authAnswer();
                })
            }
            .onAreaChange((_oldValue: Area, newValue: Area) => {
              this.bottomHeight = newValue.height as number;
            })
            .flexShrink(0)
            .width('100%')
            .margin({
              top: $r('sys.float.padding_level8'),
              bottom: $r('sys.float.padding_level8')
            })
            .alignItems(VerticalAlign.Center)
            .constraintSize({
              minHeight: $r('app.float.wh_40'),
              maxWidth: CommonConstants.MAX_BUTTON_WIDTH,
            })
            .justifyContent(FlexAlign.Center)
          }
        }
        .padding({
          left: DeviceUtil.isDevicePad() ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8'),
          right: DeviceUtil.isDevicePad() ? $r('sys.float.padding_level12') : $r('sys.float.padding_level8'),
        })
        .onAreaChange((_oldValue: Area, newValue: Area) => {
          this.containerHeight = newValue.height as number;
        })
      }
      .width('100%')
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.KEYBOARD], [SafeAreaEdge.BOTTOM])
    }
    .height('100%')
    .width('100%')
    .title($r('app.string.verify_security_questions'))
    // .titleMode(HdsNavDestinationTitleMode.MINI)
    // .titleBar({
    //   enableComponentSafeArea: true,
    //   content: {
    //     title: {
    //       mainTitle: $r('app.string.verify_security_questions'),
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
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onAreaChange((_oldValue: Area, newValue: Area) => {
      this.containerWidth = newValue.width as number;
      this.buttonAreaWidth = Math.min(CommonConstants.MAX_BUTTON_WIDTH,
        this.containerWidth - 2 * (DeviceUtils.isPhone() ? 16 : 24))
    })
    .onReady((ctx: NavDestinationContext) => {
      this.innerPathInfos = ctx.pathStack;
    })
    .onShown(()=> {
      Log.info(TAG, `onShown`);
      this.transitionType = NavigationSystemTransitionType.DEFAULT;
    })
    .onBackPressed(() => {
      Log.info(TAG, `onBackPressed`);
      this.transitionType = NavigationSystemTransitionType.TITLE;
      this.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
      return true;
    })
  }

  private async getQuestion(ctx: Context): Promise<string> {
    try {
      let question = SetPasswordModel.getPasswordProtectQuestion(ctx)
      return question;
    } catch (error) {
      let e = error as BusinessError;
      Log.error(TAG, 'service init protect error:' + e.code + e.message);
      return '';
    }
  }

  private async initQuestionStatus(): Promise<void> {
    let res = await PasswordUtils.queryQuestionStatus();
    if (!res || res.result !== ResultCode.SUCCESS) {
      Log.error(TAG, `get question status failed, init remainTimes and freezeTimes failed`);
      this.enableClick = true;
      return;
    }
    this.remainTimes = res.remainTimes ? res.remainTimes : 0;
    this.freezeTimes = res.freezingTime ? res.freezingTime : 0;
    this.enableClick = true;
  }

  private authAnswer(): void {
    PasswordUtils.unregisterInputer();
    PasswordUtils.registerPriPwdInputer(osAccount.AuthSubType.PIN_QUESTION, this.secureIssuePwd);
    PasswordUtils.openSession(TAG).then(() => {
      let challenge = SecurityManager.getInstance().getChallenge();
      PasswordUtils.authQuestion(challenge, (result, extraInfo) => {
        if (result === ResultCode.SUCCESS) {
          this.isChecked = true;
          this.enableClick = true;
          HiSysEventUtil.updateByPwdProtect();
          HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_CHECK_PWD_PROTECT,
            HiSysEventConstants.USER_OPERATION_END);
          return;
        }
        this.showAuthError = true;
        this.initQuestionStatus();
      })
    })
  }

  private calcOffset(isEditing: boolean): void {
    if (isEditing) {
      if (this.keyboardHeight && this.keyboardHeight !== undefined) {
        this.avoidKeyboardMargin = Math.max((this.keyboardHeight - this.bottomHeight - this.bottomMargin - 16), 0);
      } else {
        this.avoidKeyboardMargin = 0;
      }
    } else {
      this.avoidKeyboardMargin = 0;
    }
  }

  private clearResource(): void {
    this.secureIssuePwd = '';
  }
}

@Extend(Button)
function buttonExtendStyle() {
  .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
  .fontSize($r('sys.float.ohos_id_text_size_button1'))
  .fontFamily('HarmonyHeiTi')
  .fontWeight(FontWeight.Medium)
  .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
  .type(ButtonType.Capsule)
  .constraintSize({ minHeight: 40 })
  .borderRadius($r('sys.float.corner_radius_level10'))
  .type(ButtonType.Normal)
}

@Extend(TextInput)
function textInputStyle() {
  .placeholderColor($r('sys.color.ohos_id_color_text_hint'))
  .placeholderFont({ size: $r('sys.float.ohos_id_text_size_body1') })
  .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
  .fontSize($r('sys.float.ohos_id_text_size_body1'))
  .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  .caretColor($r('sys.color.ohos_id_color_text_primary_activated'))
  .showUnderline(true)
  .constraintSize({ minHeight: 48 })
}