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
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { DialogButtonType, OPACITY_ONE, OPACITY_OTHER, STROKE_WIDTH } from './types';
/* instrument ignore file */
const TAG: string = 'CommonDialog';
const MAX_LENGTH_52: number = 52;

@Extend(Button)
function dialogButton() {
  .constraintSize({minHeight: $r('app.float.height_40')})
  .fontSize($r('sys.float.ohos_id_text_size_button1'))
  .flexGrow(1)
  .type(DeviceUtil.isDevicePc() ? ButtonType.Normal : ButtonType.Capsule)
  .borderRadius(DeviceUtil.isDevicePc() ? $r('sys.float.corner_radius_level4') : undefined)
}

class BackgroundColorModifier implements AttributeModifier<ColumnAttribute> {
  public backgroundColor?: ResourceColor;

  applyNormalAttribute(instance: ColumnAttribute): void {
    if (this.backgroundColor) {
      instance.backgroundColor(this.backgroundColor);
    } else {
      instance.backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK);
    }
  }
}
/**
 * Common Dialog
 *
 * @since 2023-08-14
 */
@CustomDialog
export struct CommonDialog {
  @State title: string = '';
  @State dialogWidth: string = '100%';
  @BuilderParam content: () => void;
  @State confirmEnable: boolean = true;
  @State textContent: string = '';
  @State cancelBackground: Resource = $r('sys.color.ohos_id_color_button_normal');
  @State confirmBackground: Resource = $r('sys.color.ohos_id_color_button_normal');
  @State customWidth: string = '100%';
  @State modifier: BackgroundColorModifier = new BackgroundColorModifier();
  private controller?: CustomDialogController;
  scroller: Scroller = new Scroller();
  actionType: DialogButtonType = DialogButtonType.TWO_BUTTON_HORIZONTAL;
  fingerEnrollDialog: boolean = false;
  fingerprintIdentifyDialog: boolean = false;
  hasWarning: boolean = false;
  bgColor?: ResourceColor;
  titleColor?: ResourceColor;
  ownDialogWidth: string = '100%';
  needBuildButtons: boolean = true;
  cancelCallback?: () => void;
  confirmCallback?: () => void;
  disappearCallback?: () => void;
  textInputCallback = (value: string): void => void (0);
  confirmText?: Resource | string;
  cancelText?: Resource | string;
  confirmTextColor?: ResourceColor;
  isDarkModeSameWithLightMode?: boolean;
  isFromUnderScreenFingerprint?: boolean;
  isSupportScroll?: boolean;
  isConfirmFocus: boolean = false;

  aboutToAppear(): void {
    this.updateDialogWidth();
    if (DeviceUtil.isDevicePc()) {
      this.cancelBackground = $r('sys.color.ohos_id_color_button_normal');
      this.confirmBackground = $r('sys.color.ohos_id_color_button_normal');
    } else {
      this.cancelBackground = $r('app.color.transparent');
      this.confirmBackground = $r('app.color.transparent');
    }
    this.modifier.backgroundColor = this.bgColor;
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    if (this.disappearCallback) {
      this.disappearCallback();
    }
  }

  /**
   * handleButtonTouchEvent
   *
   * @param event TouchEvent
   * @returns touch背景色资源
   */
  private handleButtonTouchEvent(event: TouchEvent): Resource {
    if (event.type === TouchType.Down || event.type === TouchType.Move) {
      if (DeviceUtil.isDevicePc()) {
        return $r('sys.color.ohos_id_color_hover');
      } else {
        return this.isDarkModeSameWithLightMode ? $r('app.color.add_fingerprint_btn_bg') :
        $r('sys.color.ohos_id_color_click_effect');
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
   * @returns hover背景色资源
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

  @Builder
  buildTitle(): void {
    Flex({ justifyContent: FlexAlign.Center }) {
      Row() {
        Text(this.title)
          .margin({
            left: $r('app.float.margin_12')
          })
          .constraintSize({minHeight:(this.title?.length > MAX_LENGTH_52) ? ($r('app.float.height_18')) : ($r('app.float.height_22'))})
          .fontSize((this.title?.length > MAX_LENGTH_52) ? ($r('app.float.font_16')) : ($r('app.float.font_20')))
          .fontColor(this.titleColor ? this.titleColor : $r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Bold)
          .margin(DeviceUtil.isDevicePc() ? { left: 0, top: $r('app.float.margin_16') } : {
            left: 0,
          })
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
		      .maxFontScale(2)
      }
      .alignItems(VerticalAlign.Center)
      .constraintSize({
        maxWidth: '100%',
        minHeight: $r('app.float.height_56'),
      })
      .align(Alignment.Start)
      .padding({
        left: $r('app.float.padding_8'),
        right: $r('app.float.padding_8')
      })
    }
    .width('100%')
  }

  @Builder
  buildTitlePc(): void {
    Flex({ justifyContent: FlexAlign.Start }) {
      Row() {
        Text(this.title)
          .lineHeight($r('app.float.height_23'))
          .fontSize((this.title?.length > MAX_LENGTH_52) ? ($r('app.float.font_15')) : ($r('app.float.font_20')))
          .fontColor(this.titleColor ? this.titleColor : $r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Bold)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
        if (this.fingerEnrollDialog) {
          Button() {
            Image($r('app.media.ic_public_cancel'))
              .fillColor($r('sys.color.font_primary'))
          }
          .rotate({
            x: 0,
            y: 0,
            z: 1,
            centerX: '50%',
            centerY: '50%',
            angle: 0,
          })
          .onClick(() => {
            this.controller ? this.controller.close() : void (0);
          })
          .height('40vp') // 添加按钮高度
          .width('40vp') // 添加按钮宽度
          .backgroundColor(this.fingerprintIdentifyDialog ? $r('app.color.color_default_white') :
            (this.fingerEnrollDialog ? $r('app.color.color_default_white') : $r('sys.color.ohos_id_color_button_normal'))) // 添加按钮背景颜色
          .borderRadius($r('sys.float.corner_radius_level4'))
          .hoverEffect(HoverEffect.Auto)
        }
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .constraintSize({
        maxWidth: '100%'
      })
      .width('100%')
      .padding({
        left: $r('app.float.padding_8'),
        right: $r('app.float.padding_8'),
      })
      .margin((this.title?.length > MAX_LENGTH_52) ? {
        top: $r('app.float.margin_12'),
        bottom: $r('app.float.margin_12')
      } : {})
      .height($r('app.float.height_56'))
      .align(Alignment.Start)
    }
    .width('100%')
    .padding(this.fingerEnrollDialog ? { top: $r('app.float.margin_16') } : {})
  }

  @Builder
  buildContent(): void {
    Column() {
      this.content();
    }
    .margin({
      bottom: $r('app.float.margin_8')
    })
  }

  getColor( isFromUnderScreenFingerprint: boolean): ResourceStr {
    let res: ResourceStr = '#5291FF';
    if (!isFromUnderScreenFingerprint) {
      res = $r('sys.color.font_emphasize');
    }
    return res;
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
          .layoutWeight(1)
          .dialogButton()
          .fontColor(DeviceUtil.isDevicePc() ? $r('sys.color.ohos_id_color_text_primary_activated') : this.getColor(this.isFromUnderScreenFingerprint))
          .backgroundColor(this.cancelBackground)
          .margin(this.actionType === DialogButtonType.TWO_BUTTON_HORIZONTAL ? {} : { left: '0vp', right: '0vp' })
          .onHover(((isHover: boolean) => {
            this.cancelBackground = this.handleButtonHoverEvent(isHover);
          }) as (isHover?: boolean, event?: HoverEvent) => void)
          .onTouch((event: TouchEvent) => {
            this.cancelBackground = this.handleButtonTouchEvent(event);
          })
      }
      if (this.actionType === DialogButtonType.TWO_BUTTON_HORIZONTAL) {
        if (this.cancelCallback && this.confirmCallback) {
          Divider()
            .vertical(true)
            .strokeWidth(STROKE_WIDTH)
            .color($r('sys.color.ohos_id_color_list_separator'))
            .lineCap(LineCapStyle.Round)
            .height($r('app.float.height_24'))
            .padding({
              left: $r('app.float.padding_7'),
              right: $r('app.float.padding_7')
            })
            .visibility(DeviceUtil.isDevicePc() ? Visibility.Hidden : Visibility.Visible)
        }
        if (this.confirmCallback) {
          Button(this.confirmText ? this.confirmText : $r('app.string.delete'))
            .onClick(() => {
              this.confirmCallback ? this.confirmCallback() : void (0);
              this.controller ? this.controller.close() : void (0);
            })
            .borderRadius(DeviceUtil.isDevicePc() ? $r('sys.float.corner_radius_level4') : undefined)
            .defaultFocus(this.isConfirmFocus)
            .layoutWeight(1)
            .fontColor(this.hasWarning ? $r('sys.color.ohos_id_color_warning') : $r('sys.color.ohos_id_color_text_primary_activated'))
            .enabled(this.confirmEnable)
            .opacity(this.confirmEnable ? OPACITY_ONE : OPACITY_OTHER)
            .dialogButton()
            .backgroundColor(this.confirmBackground)
            .onHover((isHover?: boolean) => {
              this.confirmBackground = this.handleButtonHoverEvent(isHover);
            })
            .onTouch((event: TouchEvent) => {
              this.confirmBackground = this.handleButtonTouchEvent(event);
            })
        }
      }
    }
    .width(DeviceUtil.isDevicePc() ? this.dialogWidth : '100%')
    .constraintSize({ minHeight: $r('app.float.height_40') })
    .margin(DeviceUtil.isDevicePc() ? { top: $r('app.float.margin_8'), bottom: $r('app.float.width_24') } : {
      bottom: $r('app.float.margin_16')
    })
    .padding(DeviceUtil.isDevicePc() ? { left: $r('app.float.margin_16'), right: $r('app.float.margin_16') } : {})
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
          .fontColor(DeviceUtil.isDevicePc() ? '#0A59F7' : this.getColor(this.isFromUnderScreenFingerprint))
          .backgroundColor(this.cancelBackground)
          .width('100%')
          .margin({bottom:10})
          .onHover(((isHover: boolean) => {
            this.cancelBackground = this.handleButtonHoverEvent(isHover);
          }) as (isHover?: boolean, event?: HoverEvent) => void)
          .onTouch((event: TouchEvent) => {
            this.cancelBackground = this.handleButtonTouchEvent(event);
          })
      }
        if (this.confirmCallback) {
          Button(this.confirmText ? this.confirmText : $r('app.string.delete'))
            .onClick(() => {
              this.confirmCallback ? this.confirmCallback() : void (0);
              this.controller ? this.controller.close() : void (0);
            })
            .fontColor(this.hasWarning ? $r('sys.color.ohos_id_color_warning') : $r('sys.color.ohos_id_color_text_primary_activated'))
            .enabled(this.confirmEnable)
            .opacity(this.confirmEnable ? OPACITY_ONE : OPACITY_OTHER)
            .dialogButton()
            .backgroundColor(this.confirmBackground)
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
      if (this.title !== '') {
        if (DeviceUtil.isDevicePc()) {
          this.buildTitlePc();
        } else {
          this.buildTitle();
        }
      }
      this.buildContent();
      if (this.needBuildButtons) {
        if (FontScaleUtils.isExtraLargeFontMode()) {
          this.buildLagerButtons()
        } else {
          this.buildButtons();
        }
      }
    }
    .attributeModifier(this.modifier)
    .borderRadius('16vp')
    .padding({
      left: $r('app.float.padding_16'),
      right: $r('app.float.padding_16'),
    })
  }

  @Builder
  buildDialogForPhone(): void {
    if (this.isSupportScroll) {
      Scroll() {
        Column() {
          this.buildDialog();
        }
      }
      .scrollBar(BarState.Off)
    } else {
      Column() {
        this.buildDialog();
      }
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
    .width(this.updateCustomDialogWidth())
  }

  private updateCustomDialogWidth(): string {
    if (this.isFromUnderScreenFingerprint) {
      this.customWidth = 'calc(100% - 32vp)';
      return this.customWidth;
    }
    return this.dialogWidth;
  }

  private updateDialogWidth(): void {
    if (DeviceUtil.isDevicePc()) {
      this.dialogWidth = this.ownDialogWidth;
    } else {
      this.dialogWidth = '100%';
    }
  }
}