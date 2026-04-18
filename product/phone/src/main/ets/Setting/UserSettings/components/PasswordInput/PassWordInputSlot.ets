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
import { PasswordIconVM } from './PasswordIconVM';

const CARD_CONTENT_WIDTH: number = 516;

@Component
export struct PassWordInputSlot {
  @Link passwordInput: string;
  @Link passwordWarnMsg: ResourceStr;
  @Prop componentId: string;
  @Prop passwordIconVM: PasswordIconVM;
  @Prop placeHolder: ResourceStr;
  @Prop needCheckPassWord: boolean = true;
  @Prop isPasswordWarningShow: boolean = false;
  enterFunc: () => void = () => {
  }
  isShowPasswordEmptyMsg: () => void = () => {
  }
  checkPassword: () => void = () => {
  }
  onPasswordInputChange: () => void = () => {
  }

  build() {
    Column() {
      TextInput({
        placeholder: this.placeHolder,
        text: this.passwordInput,
      })
        .id(this.componentId)
        .fontSize($r('app.float.font_16'))
        .placeholderFont({
          size: $r('sys.float.Body_L'),
          weight: FontWeight.Regular,
          family: 'HarmonyHeiTi'
        })
        .passwordInputStyle()
        .copyOption(CopyOptions.None)
        .type(InputType.Password)
        .showPasswordIcon(false)
        .showPassword(this.passwordIconVM.isPwdVisible)
        .onFocus(() => {
          this.isShowPasswordEmptyMsg();
          this.passwordIconVM.setIsFocused(true);
        })
        .onBlur(() => {
          if (this.needCheckPassWord) {
            this.checkPassword();
          }
          this.passwordIconVM.setIsFocused(false);
        })
        .onChange((value: string) => {
          this.passwordInput = value;
          this.onPasswordInputChange();
        })
        .enterKeyType(EnterKeyType.Done)
        .onSubmit(enterKeyType => {
          if (enterKeyType === EnterKeyType.Done) {
            this.enterFunc();
          }
        })
    }
    .height('100%')
  }
}

/* oobe输入框容器样式 */
@Extend(TextInput)
function passwordInputStyle() {
  .inputStyle(false)
  .backgroundColor(Color.Transparent)
  .border({ width: 0 })
  .flexGrow(1)
  .flexShrink(1)
}

/* oobe输入框样式 */
@Extend(TextInput)
function inputStyle(isShow: boolean) {
  .width(CARD_CONTENT_WIDTH)
  .height(40)
  .backgroundColor($r('app.color.oobe_textinput_bg_color'))
  .caretColor($r('sys.color.ohos_id_color_text_primary_activated'))
  .placeholderColor($r('sys.color.font_secondary'))
  .fontColor($r('sys.color.font_primary'))
  .borderColor(isShow ? $r('app.color.font_color_error') : $r('app.color.oobe_textinput_bg_color'))
  .enabled(true)
  .borderWidth(1)
  .borderRadius(32)
  .padding({
    left: $r('app.float.padding_12'),
    top: 0,
    bottom: 0,
  })
}

/* oobe输入框告警样式 */
@Extend(Text)
function warnTextStyle() {
  .fontColor($r('app.color.font_color_red'))
  .fontFamily('HarmonyHeiTi')
  .fontWeight(FontWeight.Medium)
  .width(CARD_CONTENT_WIDTH)
  .margin({ left: 12, top: 8, bottom: 8 })
}