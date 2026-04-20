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
import { LengthMetrics, LengthUnit } from '@kit.ArkUI';
import { osAccount, settings } from '@kit.BasicServicesKit';
import { DeviceUtil, NavEntryKey } from '@ohos/settings.common';
import { CommonConstants } from '../../common/constants/CommonConstants';
import { PasswordProtectConstants } from '../../common/constants/PasswordProtectionConstants';
import AccessibilityUtil from '../../common/utils/AccessibilityUtil';
import { DeviceUtils } from '../../common/utils/DeviceUtils';
import FontScaleUtils, { LARGE_LIMIT_HEIGHT } from '../../common/utils/FontScaleUtils';
import Log from '../../common/utils/Log';
import { PasswordUtils, PinSubType, ResultCode } from '../../common/utils/PasswordUtils';
import { ResourceUtil } from '../../common/utils/ResourceUtil';
import { TextInputDialogComponent } from '../TextInputDialogComponent';
import SecurityManager from '../../security/SecurityManager';
import { HiSysEventUtil } from '../../common/utils/HiSysEventUtil';
import { HiSysEventConstants } from '../../common/constants/HiSysEventConstants';
import { PADDING_16, PADDING_24 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { common } from '@kit.AbilityKit';
import {
  HdsNavDestinationTitleMode, HdsNavDestination, HdsNavDestinationAttribute, DividerShowType
} from '@kit.UIDesignKit';

const TAG = 'SetPasswordProtectView';
const firstTextInputId: string = 'firstTextInput';
const PRIVATE_PASSWORD_PROTECT = 'private_password_protect';

@Component
export struct SetPasswordProtectView {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State intputLimitMessage: string = '';
  @State firstCustomQuestion: ResourceStr = '';
  @State isUserExit: boolean = false;
  @State firstQuestionIndex: number = 0;
  @State tmpAnswer: string = '';
  @State containerWidth: number = 0;
  @State buttonAreaWidth: number = 0;
  @State bottomHeight: number = 0;
  @State isAllowedSubmit: boolean = false;
  @State firstQuestion: ResourceStr = $r('app.string.security_questions_father_name');
  @State shouldBackPress: boolean = false;
  @State menuWidth: number = 224;
  @State isHeightTooSmall: boolean = false;
  @State @Watch('onContainerChange') containerHeight: number = 0;
  @State transitionType: NavigationSystemTransitionType = NavigationSystemTransitionType.DEFAULT;

  onContainerChange() {
    this.isHeightTooSmall = this.containerHeight < LARGE_LIMIT_HEIGHT;
  }
  private isFirstAnswerMaxLength: boolean = false;
  private canClick: boolean = true;
  menuText: string[] = [
    ResourceUtil.getStringSync($r('app.string.security_questions_father_name')),
    ResourceUtil.getStringSync($r('app.string.security_questions_partner_name')),
    ResourceUtil.getStringSync($r('app.string.security_questions_school_name')),
    ResourceUtil.getStringSync($r('app.string.security_questions_street_name')),
    ResourceUtil.getStringSync($r('app.string.security_questions_band_name')),
    ResourceUtil.getStringSync($r('app.string.custom_security_questions'))
  ]
  firstQuestionDialogController: CustomDialogController = new CustomDialogController({
    builder: TextInputDialogComponent({
      title: $r('app.string.custom_security_questions'),
      inputText: this.firstCustomQuestion,
      cancel: () => {
        this.onFirstCancel()
      },
      confirm: () => {
        this.onFirstConfirm()
      }
    }),
    backgroundColor: $r('sys.color.mask_fourth'),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    showInSubWindow: true
  })
  confirm: () => void = async () => {
    HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_UPDATE_PWD_PROTECT_NEXT,
      HiSysEventConstants.USER_OPERATION_CLICK);
    if (!this.canClick) {
      return;
    }
    this.canClick = false
    try {
      Log.info(TAG, 'confirm button is clicked');
      let createRes = await this.updateProtectPwd();
      if (createRes) {
        this.isUserExit = true;
        this.shouldBackPress = true;
        Log.info(TAG, 'set password success');
        HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_UPDATE_PWD_PROTECT,
          HiSysEventConstants.USER_OPERATION_END);
        this.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
      } else {
        Log.error(TAG, 'set password fail');
        this.shouldBackPress = true;
        HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_UPDATE_PWD_PROTECT,
          HiSysEventConstants.USER_OPERATION_END);
        this.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY);
      }
    } catch (e) {
      Log.error(TAG, 'updateProtectPwd fail');
    } finally {
      this.canClick = true;
    }
  }
  cancel: () => void = () => {
    HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_UPDATE_PWD_PROTECT_NEXT,
      HiSysEventConstants.USER_OPERATION_CLICK);
    Log.info(TAG, 'cancel button is clicked');
    this.shouldBackPress = true;
    this.isUserExit = true;
    this.pathInfos.pop();
  }

  setQuestionToDb(question: string) {
    let res: boolean = false;
    try {
      for (let index = 0; index < PasswordProtectConstants.RETRY_TIMES; index++) {
        const result =
          settings.setValueSync(getContext(this), PRIVATE_PASSWORD_PROTECT, question,
            settings.domainName.USER_SECURITY);
        if (result) {
          Log.info(TAG, `set password protect question success`);
          res = result;
          break;
        }
        Log.error(TAG, 'set password protect question fail');
      }
      return res;
    } catch (error) {
      Log.error(TAG, `set password protect question fail, errorCode: ${error?.code}, error message: ${error?.message}`);
    }
    return false;
  }

  async setAnswerToIam(answer: string): Promise<boolean> {
    PasswordUtils.unregisterInputer();
    PasswordUtils.registerPriPwdInputer(osAccount.AuthSubType.PIN_QUESTION, answer);
    let token = SecurityManager.getInstance().getToken();
    if (!token) {
      Log.error(TAG, `get token from secMgr failed`);
      return false;
    }
    return new Promise<boolean>((resolve, reject) => {
      PasswordUtils.updatePriPwd(osAccount.AuthSubType.PIN_QUESTION, token, (result, extraInfo) => {
        if (result === ResultCode.SUCCESS) {
          Log.info(TAG, `update answer success`);
          HiSysEventUtil.reportUpdateEvent(HiSysEventConstants.UPDATE_PROTECT);
          resolve(true);
        } else {
          Log.error(TAG, `update answer failed, result is ${result}}`);
          reject(false);
        }
      });
    });
  }

  aboutToAppear(): void {
    Log.info(TAG, 'aboutToAppear')
    this.transitionType = NavigationSystemTransitionType.TITLE;
    HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_UPDATE_PWD_PROTECT,
      HiSysEventConstants.USER_OPERATION_BEGIN);
    const id = setTimeout(() => {
      focusControl.requestFocus(firstTextInputId);
      clearTimeout(id);
    }, CommonConstants.INPUT_FOCUS_DELAY);
  }

  aboutToDisappear(): void {
    Log.info(TAG, `aboutToDisappear`);
    this.clearResource();
  }

  build() {
    NavDestination() {
      Column() {
        Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
          Scroll() {
            Column() {
              List() {
                ListItem() {
                  Text($r('app.string.remember_security_questions'))
                    .fontColor($r('sys.color.ohos_id_color_text_hint'))
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                    .fontFamily('HarmonyHeiTi')
                    .fontWeight(FontWeight.Regular)
                    .textAlign(TextAlign.Start)
                    .alignSelf(ItemAlign.Start)
                }

                ListItem() {
                  Select([])
                    .selected(0)
                    .value(this.firstQuestion)
                    .space('8vp')// 文本与箭头之间的间距
                    .font({ size: $r('sys.float.ohos_id_text_size_button1'), weight: FontWeight.Medium })
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .alignSelf(ItemAlign.Start)
                    .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
                    .optionFont({ size: $r('sys.float.ohos_id_text_size_body1'), weight: FontWeight.Medium })
                    .optionFontColor($r('sys.color.ohos_id_color_text_primary'))
                    .borderRadius($r('sys.float.corner_radius_level10'))
                    .margin({ top: 24, bottom: 12 })
                    .bindMenu(this.PrivacyMenu(), { placement: Placement.BottomLeft })
                    .onAreaChange((_o, newValue) => {
                      const rowWidth = newValue.width as number
                      if (rowWidth > 224) {
                        this.menuWidth = rowWidth;
                      } else {
                        this.menuWidth = 224;
                      }
                    })
                }

                ListItem() {
                  TextInput({ placeholder: this.intputLimitMessage, text: this.tmpAnswer })
                    .id(firstTextInputId)
                    .textInputStyle()
                    .defaultFocus(true)
                    .onChange((value: string) => {
                      this.tmpAnswer = value;
                      this.onChangeFirstAnswer(value);
                    })
                    .showError(this.isFirstAnswerMaxLength ?
                    ResourceUtil.getStringSync($r( 'app.string.private_pin_textInput_maxLength')) : undefined)
                }
                .onAreaChange(() => {
                  if (this.isFirstAnswerMaxLength) {
                    AccessibilityUtil.autoReadForAccessibility(ResourceUtil.getStringSync($r('app.string.private_pin_textInput_maxLength')));
                  }
                })
              }
              .scrollBar(BarState.Off)
              .width('100%')
              .padding({ left: 12, right: 12 })

              Blank()
            }
            .margin({ top: $r('app.float.wh_24') })
          }
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .align(Alignment.TopStart)
          .flexGrow(1)

         if (FontScaleUtils.buttonColumnLayout(this.buttonAreaWidth, $r('app.string.dialog_cancel'),
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
                 .onClick(this.cancel)
               Button($r('app.string.button_title_ok'))
                 .width('100%')
                 .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                 .fontFamily('HarmonyHeiTi')
                 .fontWeight(FontWeight.Medium)
                 .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
                 .type(ButtonType.Normal)
                 .borderRadius($r('sys.float.corner_radius_level10'))
                 .constraintSize({ minHeight: 40 })
                 .enabled(this.isAllowedSubmit)
                 .fontSize(FontScaleUtils.getRealPX(getContext(), $r('sys.float.ohos_id_text_size_button1')))
                 .onClick(this.confirm)
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
               Button($r('app.string.dialog_cancel'))
                 .width('100%')
                 .buttonExtendStyle()
                 .onClick(this.cancel)
               Button($r('app.string.button_title_ok'))
                 .width('100%')
                 .buttonExtendStyle()
                 .enabled(this.isAllowedSubmit)
                 .onClick(this.confirm)
             }
             .onAreaChange((_oldValue: Area, newValue: Area) => {
               this.bottomHeight = newValue.height as number;
             })
             .padding({ bottom: $r('sys.float.padding_level8') })
             .width(this.buttonAreaWidth)
             .flexShrink(0)
             .margin({ top: 16 })
           }
          } else {
            Row({ space: 12 }) {
              Button($r('app.string.dialog_cancel'))
                .layoutWeight(1)
                .buttonExtendStyle()
                .onClick(this.cancel)
              Button($r('app.string.button_title_ok'))
                .enabled(this.isAllowedSubmit)
                .layoutWeight(1)
                .buttonExtendStyle()
                .onClick(this.confirm)
            }
            .onAreaChange((_oldValue: Area, newValue: Area) => {
              this.bottomHeight = newValue.height as number;
            })
            .margin({ top: 16 })
            .padding({ bottom: $r('sys.float.padding_level8') })
            .flexShrink(0)
            .constraintSize({
              minHeight: $r('app.float.wh_40'),
              maxWidth: CommonConstants.MAX_BUTTON_WIDTH,
            })
            .justifyContent(FlexAlign.Center)
          }

        }

        .padding({
          left: DeviceUtils.isPhone() ? $r('app.float.wh_16') : $r('app.float.wh_24'),
          right: DeviceUtils.isPhone() ? $r('app.float.wh_16') : $r('app.float.wh_24'),
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .onAreaChange((_oldValue: Area, newValue: Area) => {
          this.containerWidth = newValue.width as number;
          this.containerHeight = newValue.height as number;
          this.bottomHeight = newValue.height as number;
          this.buttonAreaWidth = Math.min(CommonConstants.MAX_BUTTON_WIDTH,
            this.containerWidth - 2 * (DeviceUtils.isPhone() ? 16 : 24))
        })
      }
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.KEYBOARD], [SafeAreaEdge.BOTTOM])
    }
    .onAppear(() => {
      this.isUserExit = false;
    })
    .onShown(() => {
      Log.info(TAG, 'onShown');
      this.transitionType = NavigationSystemTransitionType.DEFAULT;
      this.intputLimitMessage =
        ResourceUtil.getAnyNumFormatStringSync($r('app.string.intput_character_length_from_to'),
          PasswordProtectConstants.TEXT_MIN_LENGTH, PasswordProtectConstants.TEXT_MAX_LENGTH)
    })
    .onHidden(() => {
      Log.info(TAG, 'onHidden');
      if (!this.shouldBackPress) {
        Log.info(TAG, 'set protect page on hidden, clear data');
        if (this.isUserExit) {
          Log.info(TAG, 'user exit');
          this.pathInfos.pop();
        } else {
          Log.info(TAG, 'not user exit');
          this.refreshWhenHidden();
        }
      }
    })
    .onBackPressed(() => {
      Log.info(TAG, 'onBackPress');
      this.transitionType = NavigationSystemTransitionType.TITLE;
      this.shouldBackPress = true;
      this.isUserExit = true;
      this.pathInfos.pop();
      HiSysEventUtil.reportUserOperationEvent(HiSysEventConstants.OPERATION_UPDATE_PWD_PROTECT,
        HiSysEventConstants.USER_OPERATION_CANCEL);
      return true;
    })
    .height('100%')
    .width('100%')
    .title($r('app.string.setting_security_questions'))
    // .titleMode(HdsNavDestinationTitleMode.MINI)
    // .titleBar({
    //   enableComponentSafeArea: true,
    //   content: {
    //     title: {
    //       mainTitle: $r('app.string.setting_security_questions'),
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
  }

  @Builder
  PrivacyMenu() {
    Menu() {
      ForEach(this.menuText, (text: string, index) => {
        MenuItem() {
          Flex({
            justifyContent: FlexAlign.SpaceBetween,
            alignItems: ItemAlign.Center
          }) {
            Text(text)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontSize($r('app.float.font_16'))
              .fontWeight(FontWeight.Medium)
            if (this.firstQuestionIndex === index) {
              SymbolGlyph($r('sys.symbol.checkmark'))
                .fontSize('24vp')
                .fontColor([$r('sys.color.ohos_id_color_text_primary')])
                .fontWeight(FontWeight.Regular)
            } else {
              Row().width('24vp')
            }
          }
          .constraintSize({ minHeight: $r('app.float.wh_48') })
          .padding(12)
        }
        .onClick(() => {
          this.firstQuestionIndex = index;
          this.firstQuestion = text;
          1
          if (index === this.menuText.length - 1) {
            Log.info(TAG, 'first custom select is clicked');
            this.firstQuestionDialogController.open();
          }
          if (this.firstQuestionIndex != this.menuText.length - 1) {
            AccessibilityUtil.autoFocusForAccessibility(firstTextInputId);
          }
        })
      })
    }
    .menuItemDivider({
      strokeWidth: new LengthMetrics(1, LengthUnit.PX),
      color: $r('sys.color.comp_divider'),
      startMargin: new LengthMetrics(12),
      endMargin: new LengthMetrics(12),
    })
    .width(this.menuWidth || 224)
  }

  private refreshWhenHidden(): void {
    this.firstQuestionDialogController.close();
    this.firstQuestionIndex = 0;
    this.tmpAnswer = '';
    this.firstQuestion = $r('app.string.security_questions_father_name');
  }

  private onFirstCancel(): void {
    Log.info(TAG, `dialog cancel`);
    this.firstQuestionDialogController.close();
    this.firstQuestion = this.menuText[0];
    this.firstQuestionIndex = 0;
  }

  private onFirstConfirm(): void {
    Log.info(TAG, `dialog confirm`);
    this.firstQuestionDialogController.close();
    this.firstQuestion = this.firstCustomQuestion;
  }

  private onChangeFirstAnswer(value: string): void {
    if (value.length >= PasswordProtectConstants.TEXT_MIN_LENGTH &&
      value.length <= PasswordProtectConstants.TEXT_MAX_LENGTH) {
      this.isAllowedSubmit = true;
    } else {
      this.isAllowedSubmit = false;
    }
    this.isFirstAnswerMaxLength = value.length > PasswordProtectConstants.TEXT_MAX_LENGTH;
  }

  private async updateProtectPwd(): Promise<boolean> {
    Log.info(TAG, `create pin start`);
    let createProtectAnswerRes = await this.setAnswerToIam(this.tmpAnswer);
    let createProtectQuestionRes = this.setQuestionToDb(ResourceUtil.getStringSync(this.firstQuestion));
    if (createProtectQuestionRes && createProtectAnswerRes) {
      Log.info(TAG, `update protect password success`);
      return true;
    }
    Log.error(TAG, `update protect password failed`);
    return false;
  }

  private clearResource(): void {
    this.tmpAnswer = '';
  }
}

@Extend(Button)
function buttonExtendStyle() {
  .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
  .fontSize($r('sys.float.ohos_id_text_size_button1'))
  .fontFamily('HarmonyHeiTi')
  .fontWeight(FontWeight.Medium)
  .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
  .type(ButtonType.Normal)
  .borderRadius($r('sys.float.corner_radius_level10'))
  .constraintSize({ minHeight: 40 })
  .labelStyle({
    maxLines: 1,
    minFontSize: 9,
    maxFontSize: $r('app.float.font_16')
  })
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