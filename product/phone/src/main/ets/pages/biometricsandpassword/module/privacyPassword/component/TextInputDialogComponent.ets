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

import { PasswordProtectConstants } from '../common/constants/PasswordProtectionConstants';
import AccessibilityUtil from '../common/utils/AccessibilityUtil';
import FontScaleUtils from '../common/utils/FontScaleUtils';
/* instrument ignore file */
import { ResourceUtil } from '../common/utils/ResourceUtil';

@CustomDialog
export struct TextInputDialogComponent {
  @Link inputText: ResourceStr;
  @State intputLimitMessage: string = '';
  @State enabledConfirm: boolean = false;
  @State inputLength: number = 0;
  @State useButtonRowLayout: boolean = true;
  controller?: CustomDialogController;
  title?: ResourceStr;

  cancel: () => void = () => {
  }

  confirm: () => void = () => {
  }

  build() {
    Scroll() {
      Column() {
        this.builderTitle();
        this.builderTextInput();
        this.builderButton();
      }
      .constraintSize({ minWidth: $r('app.float.wh_224') })
      .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
      .borderRadius({
        topLeft: $r('sys.float.ohos_id_corner_radius_dialog'),
        bottomLeft: $r('sys.float.ohos_id_corner_radius_dialog'),
        topRight: $r('sys.float.ohos_id_corner_radius_dialog'),
        bottomRight: $r('sys.float.ohos_id_corner_radius_dialog')
      })
      .onAreaChange((oldValue: Area, newValue: Area) => {
        this.useButtonRowLayout = FontScaleUtils.dialogButtonRowLayout(newValue.width as number,
          $r('app.string.dialog_cancel'), $r('app.string.confirm'));
      })
    }
    .onAppear(() => {
      this.intputLimitMessage =
        ResourceUtil.getAnyNumFormatStringSync($r('app.string.intput_character_length_from_to'),
          PasswordProtectConstants.TEXT_MIN_LENGTH, PasswordProtectConstants.TEXT_MAX_LENGTH)
    })
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .align(Alignment.TopStart)
  }

  @Builder
  builderTitle(): void {
    Row() {
      Text(this.title)
        .maxFontScale(2)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .padding({
      left: $r('app.float.wh_24'),
      right: $r('app.float.wh_24'),
      top: $r('app.float.wh_12'),
      bottom: $r('app.float.wh_12')
    })
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .constraintSize({ minHeight: $r('app.float.wh_56') })
  }

  @Builder
  builderTextInput(): void {
    Row() {
      TextInput({ placeholder: this.intputLimitMessage })
        .placeholderColor($r('sys.color.ohos_id_color_text_hint'))
        .placeholderFont({ size: $r('sys.float.ohos_id_text_size_body1') })
        .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
        .fontSize($r('sys.float.ohos_id_text_size_body1'))
        .caretColor($r('sys.color.ohos_id_color_text_primary_activated'))
        .showUnderline(true)
        .defaultFocus(true)
        .constraintSize({ minHeight: 48 })
        .onChange((value: string) => {
          if (value.length >= 2 && value.length <= 16) {
            this.inputText = value;
            this.enabledConfirm = true;
          } else {
            this.enabledConfirm = false;
          }
          this.inputLength = value.length;
        })
        .showError(this.inputLength > 16 ? ResourceUtil.getStringSync($r('app.string.private_pin_textInput_maxLength')) :
          undefined);
    }
    .padding({ left: $r('app.float.wh_24'), right: $r('app.float.wh_24') })
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .onAreaChange(() => {
      if (this.inputLength > 16) {
        AccessibilityUtil.autoReadForAccessibility(ResourceUtil.getStringSync($r('app.string.private_pin_textInput_maxLength')));
      }
    })
  }

  @Builder
  builderButton(): void {
    Column() {
      if (!this.useButtonRowLayout) {
        Column({ space: 4 }) {
          Button($r('app.string.dialog_cancel'))
            .buttonExtendStyle(() => this.cancel())
            .width('100%')
          Button($r('app.string.confirm'))
            .buttonExtendStyle(() => this.confirm())
            .width('100%')
            .enabled(this.enabledConfirm)
        }
        .margin({ top: $r('app.float.wh_8'), bottom: $r('app.float.wh_8') })
        .width('100%')
      } else {
        Row({ space: 16 }) {
          Button($r('app.string.dialog_cancel'))
            .buttonExtendStyle(() => this.cancel())
            .layoutWeight(1)
          Button($r('app.string.confirm'))
            .buttonExtendStyle(() => this.confirm())
            .layoutWeight(1)
            .enabled(this.enabledConfirm)
        }
        .margin({ top: $r('app.float.wh_8'), bottom: $r('app.float.wh_16') })
        .width('100%')
      }
    }
    .width('100%')
    .padding({ left: $r('app.float.wh_16'), right: $r('app.float.wh_16') })
  }
}

@Extend(Button)
function buttonExtendStyle(callback: () => void) {
  .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
  .fontSize($r('sys.float.ohos_id_text_size_button1'))
  .backgroundColor('#00000000')
  .constraintSize({ minHeight: 40 })
  .onClick(callback)
  .hoverEffect(HoverEffect.None)
  .fontWeight(FontWeight.Medium)
}
