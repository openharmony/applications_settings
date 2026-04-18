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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
/* instrument ignore file */
import { OPACITY_ONE, OPACITY_OTHER, STROKE_WIDTH } from './types';

// 输入框最小长度
const INPUT_MIN_LENGTH: number = 0;

// 输入框最大长度
const INPUT_MAX_LENGTH: number = 100;

const TAG: string = 'CommonDialog';

@Extend(Button)
function dialogButton() {
  .constraintSize({ minHeight: $r('app.float.height_40') })
  .fontSize($r('sys.float.ohos_id_text_size_button1'))
  .flexGrow(1)
  .type(DeviceUtil.isDevicePc() ? ButtonType.Normal : ButtonType.Capsule)
  .borderRadius(DeviceUtil.isDevicePc() ? $r('sys.float.corner_radius_level4') : undefined)
}

/**
 * CommonTextInputDialog
 *
 * @since 2023-08-14
 */
@CustomDialog
export struct CommonTextInputDialog {
  @State confirmEnable: boolean = true;
  @State textContent: string = '';
  @State cancelBackground: Resource = $r('sys.color.ohos_id_color_button_normal');
  @State confirmBackground: Resource = $r('sys.color.ohos_id_color_button_normal');
  @State dialogWidth: string = '100%';
  controller?: CustomDialogController;
  title: Resource | string = '';
  content: Function = (): void => void (0);
  cancelCallback?: () => void;
  confirmCallback?: (value: string) => void;
  confirmText?: Resource | string;
  cancelText?: Resource | string;
  confirmTextColor?: ResourceColor;
  filter?: string[];
  isTextSelect: boolean = false;
  private inputController: TextInputController = new TextInputController();

  aboutToAppear(): void {
    this.updateDialogWidth();
    if (DeviceUtil.isDevicePc()) {
      this.cancelBackground = $r('sys.color.ohos_id_color_button_normal');
      this.confirmBackground = $r('sys.color.ohos_id_color_button_normal');
    } else {
      this.cancelBackground = $r('app.color.transparent');
      this.confirmBackground = $r('app.color.transparent');
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  /**
   * handleButtonTouchEvent
   *
   * @param event TouchEvent
   *
   */
  private handleButtonTouchEvent(event: TouchEvent): Resource {
    if (event.type === TouchType.Down || event.type === TouchType.Move) {
      if (DeviceUtil.isDevicePc()) {
        return $r('sys.color.ohos_id_color_hover');
      } else {
        return $r('sys.color.ohos_id_color_click_effect');
      }
    } else {
      if (DeviceUtil.isDevicePc()) {
        return $r('sys.color.ohos_id_color_button_normal');
      } else {
        return $r('app.color.transparent');
      }
    }
  }

  /**
   * handleButtonHoverEvent
   *
   * @param isHover
   */
  private handleButtonHoverEvent(isHover?: boolean): Resource {
    if (isHover) {
      if (DeviceUtil.isDevicePc()) {
        return $r('sys.color.ohos_id_color_hover');
      } else {
        return $r('sys.color.ohos_id_color_click_effect');
      }
    } else {
      if (DeviceUtil.isDevicePc()) {
        return $r('sys.color.ohos_id_color_button_normal');
      } else {
        return $r('app.color.transparent');
      }
    }
  }

  private handleInputTextChanged(value: string): void {
    this.textContent = value;
    if (value?.length === INPUT_MIN_LENGTH) {
      this.confirmEnable = false;
      this.textContent = '';
      return;
    }
    if (value?.length >= INPUT_MAX_LENGTH) {
      this.textContent = value.slice(0, INPUT_MAX_LENGTH);
      ResourceUtil.getString($r('app.string.input_max_length_message')).then(value => {
        ToastUtil.showToast(value, ToastUtil.SHORT_DURATION);
      })
    } else {
      this.textContent = value;
    }
    this.confirmEnable = true;
    if (this.filter) {
      let data = Array.from(this.filter.values());
      for (let str of data) {
        if (value === str) {
          this.confirmEnable = false;
          ResourceUtil.getString($r('app.string.fp_duplicated_name_toast')).then(value => {
            ToastUtil.showToast(value, 2000);
          })
          break;
        }
      }
    }

  }

  @Builder
  buildTitle(): void {
    Flex({ justifyContent: FlexAlign.Center }) {
      Row() {
        Text(this.title)
          .margin({
            left: $r('app.float.margin_12')
          })
          .fontSize($r('app.float.font_20'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Bold)
          .margin({ left: 0 })
          .maxFontScale(2)
      }
      .alignItems(VerticalAlign.Center)
      .constraintSize({ maxWidth: '100%', minHeight: $r('app.float.height_56') })
      .align(Alignment.Start)
      .padding({
        left: $r('app.float.padding_8'),
        right: $r('app.float.padding_8'),
        top: '16vp'
      })
    }
    .width('100%')
  }

  @Builder
  buildContent(): void {
    Column() {
      TextInput({ text: this.textContent, controller: this.inputController })
        .defaultFocus(true)
        .backgroundColor($r('app.color.transparent'))
        .constraintSize({ minHeight: $r('app.float.height_48') })
        .onChange(async (value: string) => {
          this.handleInputTextChanged(value);
        })
        .onSubmit(() => {
          if (!this.textContent.length || !this.confirmEnable) {
            return;
          }
          this.controller?.close();
          if (this.confirmCallback) {
            this.confirmCallback(this.textContent);
          }
        })
        .padding({
          left: $r('app.float.padding_0'),
          right: $r('app.float.padding_0'),
        })
        .onFocus(() => {
          if (this.isTextSelect) {
            this.inputController.setTextSelection(0, this.textContent.length);
          }
        })
        .borderRadius(0)
        .maxLength(INPUT_MAX_LENGTH)

      Divider().color($r('sys.color.ohos_id_color_list_separator'))
    }
    .padding({
      left: $r('app.float.padding_8'),
      right: $r('app.float.padding_8')
    })
    .margin({
      bottom: $r('app.float.margin_8')
    })
  }

  @Builder
  buildButtons(): void {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
      if (this.cancelCallback) {
        Button(this.cancelText ? this.cancelText : $r('app.string.cancel'))
          .onClick(() => {
            this.controller ? this.controller.close() : void (0);
            this.cancelCallback ? this.cancelCallback() : void (0);
          })
          .dialogButton()
          .fontColor(DeviceUtil.isDevicePc() ?
            $r('sys.color.font_emphasize') : $r('sys.color.ohos_id_color_text_primary_activated'))
          .backgroundColor(this.cancelBackground)
          .onHover((isHover?: boolean) => {
            this.cancelBackground = this.handleButtonHoverEvent(isHover);
          })
          .onTouch((event: TouchEvent) => {
            this.cancelBackground = this.handleButtonTouchEvent(event);
          })
      }
      if (this.cancelCallback && this.confirmCallback) {
        Divider()
          .vertical(true)
          .strokeWidth(STROKE_WIDTH)
          .color($r('sys.color.ohos_id_color_list_separator'))
          .lineCap(LineCapStyle.Round)
          .height($r('app.float.height_24'))
          .padding({ left: $r('app.float.padding_7'), right: $r('app.float.padding_7') })
          .visibility(DeviceUtil.isDevicePc() ? Visibility.Hidden : Visibility.Visible)
      }
      if (this.confirmCallback) {
        Button(this.confirmText ? this.confirmText : $r('app.string.ok'))
          .onClick(() => {
            this.controller?.close();
            if (this.confirmCallback) {
              this.confirmCallback(this.textContent);
            }
          })
          .enabled(this.confirmEnable)
          .opacity(this.confirmEnable ? OPACITY_ONE : OPACITY_OTHER)
          .dialogButton()
          .fontColor(DeviceUtil.isDevicePc() ?
            $r('sys.color.font_on_primary') : $r('sys.color.ohos_id_color_text_primary_activated'))
          .backgroundColor(DeviceUtil.isDevicePc() ?
            $r('sys.color.comp_background_emphasize') : this.confirmBackground)
          .onHover((isHover?: boolean) => {
            this.confirmBackground = this.handleButtonHoverEvent(isHover);
          })
          .onTouch((event: TouchEvent) => {
            this.confirmBackground = this.handleButtonTouchEvent(event);
          })
      }
    }
    .constraintSize({ minHeight: $r('app.float.height_40') })
    .margin(DeviceUtil.isDevicePc() ?
      { top: $r('app.float.margin_16'), bottom: $r('app.float.margin_24') } : { bottom: $r('app.float.margin_16') })
  }
  @Builder
  buildLagerButtons(): void {
      if (this.cancelCallback) {
        Button(this.cancelText ? this.cancelText : $r('app.string.cancel'))
          .onClick(() => {
            this.controller ? this.controller.close() : void (0);
            this.cancelCallback ? this.cancelCallback() : void (0);
          })
          .dialogButton()
          .fontColor(DeviceUtil.isDevicePc() ? '#0A59F7' : $r('sys.color.ohos_id_color_text_primary_activated'))
          .backgroundColor(this.cancelBackground)
          .width('100%')
          .margin({bottom:10})
          .onHover((isHover?: boolean) => {
            this.cancelBackground = this.handleButtonHoverEvent(isHover);
          })
          .onTouch((event: TouchEvent) => {
            this.cancelBackground = this.handleButtonTouchEvent(event);
          })
      }

      if (this.confirmCallback) {
        Button(this.confirmText ? this.confirmText : $r('app.string.ok'))
          .onClick(() => {
            this.controller?.close();
            if (this.confirmCallback) {
              this.confirmCallback(this.textContent);
            }
          })
          .enabled(this.confirmEnable)
          .opacity(this.confirmEnable ? OPACITY_ONE : OPACITY_OTHER)
          .dialogButton()
          .fontColor(DeviceUtil.isDevicePc() ? '0xFFFFFF' : $r('sys.color.ohos_id_color_text_primary_activated'))
          .backgroundColor(DeviceUtil.isDevicePc() ? '#0A59F7' : this.confirmBackground)
          .width('100%')
          .margin({bottom:10})
          .onHover((isHover?: boolean) => {
            this.confirmBackground = this.handleButtonHoverEvent(isHover);
          })
          .onTouch((event: TouchEvent) => {
            this.confirmBackground = this.handleButtonTouchEvent(event);
          })
      }
    }

  @Builder
  buildDialog(): void {
    Column() {
      this.buildTitle();
      this.buildContent();
      if (FontScaleUtils.isExtraLargeFontMode()) {
        this.buildLagerButtons();
      } else {
        this.buildButtons();
      }
    }
    .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
    .borderRadius(DeviceUtil.isDevicePc() ? $r('sys.float.corner_radius_level8') : '32vp')
    .padding({
      left: $r('app.float.padding_16'),
      right: $r('app.float.padding_16'),
    })
  }

  @Builder
  buildDialogForPhone(): void {
    Column() {
      this.buildDialog();
    }
  }

  build() {
    Column() {
      if (DeviceUtil.isDevicePc()) {
        this.buildDialog();
      } else {
        this.buildDialogForPhone();
      }
    }
    .width(this.dialogWidth)
  }

  private updateDialogWidth(): void {
    if (DeviceUtil.isDevicePc()) {
      this.dialogWidth = '394vp'
    } else {
      this.dialogWidth = '100%';
    }
  }
}