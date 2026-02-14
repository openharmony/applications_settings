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
// import dsmm from '@hms.security.dsmm';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils'
import { PinSubType, ResultCode } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { TIME_INTERVAL, PasswordResolveInfoManager } from '../PasswordResolveInfoManager';

export const NEXT_ACTION: string = 'next';
export const CANCEL_ACTION: string = 'cancel';
export const CHECK_PASSWORD_DIALOG_EVENT: string = 'checkPasswordDialogEvent';
export const OPEN_COUNTDOWN_DIALOG: string = 'open_countdown_dialog';
let pwdResolveInfoManager: PasswordResolveInfoManager | null = PasswordResolveInfoManager.getInstance();

@Component
export struct CheckLockScreenPasswordDialog {
  private tag: string = `CheckLockScreenPasswordDialog`;
  @State passwordState: boolean = false;
  @State showError: boolean = false;
  @State textInput: string = '';
  @State dividerBackgroundColor: Resource = $r('sys.color.ohos_id_color_subheading_separator');
  @State remainTimes: number = -1;
  @State buttonEnable: boolean = true;
  public pinChallenge: string = '';

  build() {
    Column() {
      Column() {
        TextInput({
          text: this.textInput,
          placeholder: $r('app.string.input_lock_screen_password_dialog_title')
        })
          .onSubmit(() => {
            if (this.buttonEnable) {
              this.buttonEnable = false;
              this.checkInputPasswordCorrect();
              setTimeout(() => {
                this.buttonEnable = true;
              }, 500);
            }
          })
          .onChange((value: string) => {
            this.textInput = value;
          })
          .onSecurityStateChange(((isShowPassword: boolean) => {
            this.passwordState = isShowPassword;
          }))
          .enableAutoFill(false)
          .showPasswordIcon(true)
          .showPassword(this.passwordState)
          .backgroundColor(Color.Transparent)
          .width('100%')
          .constraintSize({
            minHeight: $r('app.float.height_48')
          })
          .defaultFocus(true)
          .onEditChange((isEditing: boolean) => {
            this.dividerBackgroundColor = isEditing ? $r('sys.color.ohos_id_color_focused_content_primary') :
            $r('sys.color.ohos_id_color_subheading_separator');
          })
          .margin({
            top: $r('app.float.margin_4')
          })
          .type(InputType.Password)
          .placeholderColor($r('sys.color.ohos_id_color_text_hint'))
          .placeholderFont({
            size: $r('sys.float.ohos_id_text_size_body1'),
            weight: FontWeight.Regular,
            family: 'sans-serif',
            style: FontStyle.Normal,
          })
          .maxLength(64)
          .caretColor(Color.Blue)

        Column() {
          Divider();
        }
        .backgroundColor((this.showError ? $r('app.color.font_color_error') : this.dividerBackgroundColor))
        .size({
          width: '100%',
          height: $r('app.float.length_1')
        })
        .alignItems(HorizontalAlign.Center)
      }
      .id('DialogContentComponent_column')
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .constraintSize({
        minHeight: $r('app.float.height_56')
      })
      .padding({
        top: FontScaleUtils.isExtraLargeFontMode() ? FontScaleUtils.getCurrentTopPadding() : $r('app.float.margin_0'),
        bottom: FontScaleUtils.isExtraLargeFontMode() ? FontScaleUtils.getCurrentTopPadding() : $r('app.float.margin_0'),
      })

      Row(){
        Text($r('app.plural.password_message_incorrect', this.remainTimes, this.remainTimes))
          .constraintSize({ minHeight: '14vp' })
          .visibility(this.remainTimes === -1 ? Visibility.None : Visibility.Visible)
          .margin({ top: '8vp' })
          .font({
            size: $r('sys.float.ohos_id_text_size_body3'),
            weight: FontWeight.Medium,
          })
          .fontColor($r('app.color.font_color_error'))
          .textAlign(TextAlign.Start)
          .align(Alignment.Start)
      }
      .width('100%')

      Column() {
        GridContainer({
          columns: 2,
          sizeType: SizeType.Auto,
          gutter: '16vp',
          margin: '4vp',
        }) {
          Row() {
            Column() {
              Button($r('app.string.cancel'))
                .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
                .type(ButtonType.Normal)
                .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
                .size({ width: '100%', height: '40vp' })
                .constraintSize({ minHeight: '40vp' })
                .borderRadius($r('sys.float.corner_radius_level4'))
                .onClick(() => {
                  if (this.buttonEnable) {
                    this.buttonEnable = false;
                    EventBus.getInstance().emit(CHECK_PASSWORD_DIALOG_EVENT, CANCEL_ACTION);
                    setTimeout(() => {
                      this.buttonEnable = true;
                    }, 500);
                  }
                })
            }
            .gridSpan(1)
            .gridOffset(0)

            Column() {
              Button($r('app.string.dialog_next'))
                .type(ButtonType.Normal)
                .borderRadius($r('sys.float.corner_radius_level4'))
                .backgroundColor($r('sys.color.ohos_id_color_component_activated'))
                .fontColor($r('sys.color.font_on_primary'))
                .size({ width: '100%', height: '40vp' })
                .constraintSize({ minHeight: '40vp' })
                .enabled(this.textInput?.length > 0 )
                .onClick(() => {
                  if (this.buttonEnable) {
                    this.buttonEnable = false;
                    this.checkInputPasswordCorrect();
                    setTimeout(() => {
                      this.buttonEnable = true;
                    }, 500);
                  }
                })
            }
            .gridSpan(1)
            .gridOffset(1)
          }
          .direction(Direction.Auto)
          .width('100%')
        }
      }
      .margin({ top: $r('app.float.padding_16') })
    }
    .padding({
      start: PADDING_8,
      end: PADDING_8,
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    this.subscribe();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    this.unsubscribe();
  }

  subscribe(): void {
    PasswordUtil.closeSession();
    LogUtil.info(`${this.tag} dsmm open session start`);
    let mode:string = 'developer';
    // dsmm.openSession(mode).then((challenge: ESObject) => {
    //   this.pinChallenge = PasswordUtil.challengeToPinChallenge(challenge);
    // }).catch((error: Error) => {
    //   LogUtil.error(`${this.tag} open session failed ${error?.message}`);
    // });
    PasswordUtil.registerInputer(PinSubType.PIN_MIXED);
  };

  unsubscribe(): void {
    PasswordUtil.unregisterInputer();
    PasswordUtil.closeSession();
  };

  private checkInputPasswordCorrect(): void {
    PasswordUtil.authPin(this.pinChallenge, this.textInput, (result, extraInfo) => {
      if (result === ResultCode.SUCCESS) {
        pwdResolveInfoManager?.setGlobalPinToken(extraInfo?.token as string);
        EventBus.getInstance().emit(CHECK_PASSWORD_DIALOG_EVENT, NEXT_ACTION);
        pwdResolveInfoManager?.setCheckedPassword(this.textInput);
      } else {
        pwdResolveInfoManager?.setRemainTimes(extraInfo?.remainTimes as number);
        pwdResolveInfoManager?.setFreezingTime(extraInfo?.freezingTime as number >=
          TIME_INTERVAL ? extraInfo?.freezingTime as number : 0);
        if (pwdResolveInfoManager?.getRemainTimes() as number <= 0) {
          EventBus.getInstance().emit(CHECK_PASSWORD_DIALOG_EVENT, NEXT_ACTION, OPEN_COUNTDOWN_DIALOG);
        } else {
          this.remainTimes = pwdResolveInfoManager?.getRemainTimes() as number;
          this.textInput = '';
          this.showError = true;
        }
      }
    });
  }
}