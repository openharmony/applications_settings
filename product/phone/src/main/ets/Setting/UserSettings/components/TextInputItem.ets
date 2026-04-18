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
/**
 * 将子标题、输入框、错误信息包裹在一起的容器
 *  ___________________
 * |   subtitle |  *  |
 * |‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|
 * |   inputContext   |
 * | ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|
 * |   warningMsg     |
 *  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
 */

import { UserConstraints } from '../common/constants/UserConstraints';

const CARD_CONTENT_WIDTH: number = 560;

@Component
export struct TextInputItem {
  @Link inputText: string;
  @Prop subTitle: ResourceStr;
  @Prop subTitleId: string;
  @Prop placeHolder: ResourceStr;
  @Prop inputContentId: string;
  @Prop warningMsg: ResourceStr;
  @Prop warningMsgId: string;
  @Prop isWarningMsgShow: boolean;
  isDefaultFocus: boolean = false;
  isFocusInput: boolean = false;
  isPromptShow: boolean = false;
  enterFunc: () => void = () => {
  }
  onTextInputFocus: () => void = () => {
  }

  build() {
    Column() {
      Row() {
        Text(this.subTitle)
          .id(this.subTitleId)
          .fontSize($r('app.float.font_14'))
          .lineHeight($r('app.float.line_height_19_fp'))
          .subTitleStyle()
        if (this.isFocusInput) {
          Text('*')
            .fontColor($r('sys.color.ohos_id_color_warning'))
            .margin({ left: $r('app.float.margin_8') })
            .padding({ top: $r('app.float.padding_10') })
        }
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center);

      TextInput({
        placeholder: this.placeHolder,
        text: this.inputText,
      })
        .id(this.inputContentId)
        .fontSize($r('app.float.font_16'))
        .placeholderFont({
          size: $r('sys.float.Body_L'),
          weight: FontWeight.Regular,
          family: 'HarmonyHeiTi'
        })
        .inputStyle(this.isWarningMsgShow)
        .copyOption(CopyOptions.LocalDevice)
        .type(InputType.Normal)
        .maxLength(UserConstraints.USER_NAME_MAX_LEN)
        .onAppear(() => {
          if (this.isDefaultFocus) {
            this.getUIContext().getFocusController().requestFocus(this.inputContentId);
          }
        })
        .onFocus(() => {
          this.onTextInputFocus();
        })
        .onChange((value: string) => {
          this.inputText = value;
        })
        .enterKeyType(EnterKeyType.Done)
        .onSubmit(enterKeyType => {
          if (enterKeyType === EnterKeyType.Done) {
            this.enterFunc();
          }
        });
      Text(this.warningMsg ? this.warningMsg : '')
        .id(this.warningMsgId)
        .fontSize($r('app.float.font_12'))
        .lineHeight($r('app.float.line_height_16_fp'))
        .warnTextStyle()
        .visibility(this.isWarningMsgShow ? Visibility.Visible : Visibility.None);
      if (this.isPromptShow) {
        Text($r('app.string.user_account_name_input_desc'))
          .id('accountNamePrompt')
          .fontSize($r('app.float.font_12'))
          .lineHeight($r('app.float.line_height_16_fp'))
          .fontColor($r('sys.color.font_secondary'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .width(CARD_CONTENT_WIDTH)
          .margin({
            left: $r('app.float.margin_12'),
            top: this.isWarningMsgShow ? $r('app.float.margin_prompt_f4') : $r('app.float.margin_8'),
            bottom: $r('app.float.margin_8'),
          })
      }
    }
    .alignItems(HorizontalAlign.Start)
  }
}

/* oobe界面添加本地用户副标题样式 */
@Extend(Text)
function subTitleStyle() {
  .fontFamily('HarmonyHeiTi')
  .fontWeight(FontWeight.Medium)
  .fontColor($r('sys.color.font_secondary'))
  .margin({
    left: 14
  })
  .padding({ top: 12, bottom: 8 })
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