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

import { TabIndexConstants } from '@ohos/settings.common/src/main/ets/constant/TabIndexConstants';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { TextInputStyle, TextInputMenuStyle } from '../InputStyle';
/* instrument ignore file */
const TAG = 'InputComponent : ';

@Extend(TextInput)
function textInputStyle(textInputStyle?: TextInputStyle) {
  .type(textInputStyle?.inputType)
  .copyOption(textInputStyle?.inputType === InputType.Password ? CopyOptions.None : CopyOptions.LocalDevice)
  .placeholderColor(textInputStyle?.placeholderColor)
  .placeholderFont(textInputStyle?.placeholderFont)
  .caretColor(textInputStyle?.caretColor)
  .constraintSize({
    minHeight: 32
  })
  .borderRadius(textInputStyle?.borderRadius as Length)
  .padding(textInputStyle?.padding as Padding)
  .margin(textInputStyle?.margin as Padding)
  .maxLength(textInputStyle?.maxLength ?? 1000)
  .backgroundColor(textInputStyle?.backgroundColor)
  .textAlign(textInputStyle?.textAlign)
  .direction(textInputStyle?.direction)
  .fontColor(textInputStyle?.fontColor)
  .fontSize(textInputStyle?.fontSize?.size)
  .fontFamily(textInputStyle?.fontSize?.family)
  .fontWeight(textInputStyle?.fontSize?.weight)
  .showUnderline(textInputStyle?.showUnderline ?? false)
}

@Component
export struct InputComponent {
  hint: ResourceStr = '';
  private onChange?: (value: string) => void;
  onChangeInput?: (value: string) => string;
  private onSubmitClick?: (enterKeyType: EnterKeyType) => void;
  private style?: TextInputMenuStyle;
  private showDivider: boolean = true;
  private showCancelButton: boolean = false;
  private enablePreviewText: boolean = true;
  private showPassword: boolean = false;
  private showPasswordIcon: boolean = true;
  @Prop showComponent: boolean = true;
  @Prop content: ResourceStr = '';
  @State enable: boolean = true;
  @Prop tabInd?: number = TabIndexConstants.TAB_INDEX_LEVEL2_PAGE + 1;
  @State dividerBackgroundColor: Resource = $r('sys.color.comp_background_tertiary');
  private callBack = (state: boolean) => {
    this.enable = state;
  }

  build() {
    Column() {
      TextInput({
        placeholder: this.hint,
        text: $$this.content,
      })
        .enablePreviewText(this.enablePreviewText)
        .enabled(this.enable)
        .defaultFocus(true)
        .showPassword(this.showPassword)
        .showPasswordIcon(this.showPasswordIcon)
        .onSecurityStateChange((isShowPassword: boolean) => {
          this.showPassword = isShowPassword;
        })
        .textInputStyle(this.style?.textInputStyle)
        .inputFilter(this.style?.textInputStyle?.inputFilter ?? '')
        .onChange((input: string) => {
          if (this.onChange) {
            this.onChange(input);
            this.content = input;
          }
          if (this.onChangeInput) {
            this.content = this.onChangeInput(input);
          }
        })
        .onEditChange((isEditing: boolean) => {
          this.dividerBackgroundColor = isEditing ? $r('sys.color.comp_focused_primary') :
          $r('sys.color.comp_background_tertiary');
        })
        .onSubmit((enterKeyType: EnterKeyType) => {
          if (this.onSubmitClick) {
            this.onSubmitClick(enterKeyType);
          }
        })
        .cancelButton(this.showCancelButton ? {
          style: CancelButtonStyle.CONSTANT,
          icon: {
            size: '24vp',
            color: $r('sys.color.icon_primary'),
            src: $r('app.media.ic_public_cancel_bt'),
          },
        } : undefined)
      Column() {
        Divider();
      }
      .visibility(this.showDivider && this.style?.dividerStyle?.backgroundColor ? Visibility.Visible : Visibility.None)
      .backgroundColor(this.dividerBackgroundColor)
      .size(this.style?.dividerStyle?.size)
      .alignItems(HorizontalAlign.Center);
    }
    .visibility(this.showComponent ? Visibility.Visible : Visibility.None)
    .width('100%')
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    EventBus.getInstance().on('ADD_OTHER_WLAN_STATE_CHANGE', this.callBack);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    EventBus.getInstance().detach('ADD_OTHER_WLAN_STATE_CHANGE', this.callBack);
  }
}