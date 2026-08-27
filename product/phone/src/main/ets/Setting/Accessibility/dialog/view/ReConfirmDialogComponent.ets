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
import Display from '@ohos.display';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { ReConfirmButtonController } from '../controller/ReConfirmButtonController';
import { AccessibilityImageSizeAdjust } from '../../utils/AccessibilityImageSizeAdjust';
import { DIALOG_WIDTH_FOLD_EXPAND } from '../../constant/Constants';

const TAG: string = 'ReConfirmDialogComponent: ';
const SHORTCUT_TIMEOUT: number = 3;

@CustomDialog
export struct ReConfirmDialogComponent {
  public targetsInfo: string = '';
  reConfirmButtonController?: ReConfirmButtonController;
  controller?: CustomDialogController;
  @State dialogWidth: number | string =
    AccessibilityImageSizeAdjust.checkIsDevicesExpanded() ? DIALOG_WIDTH_FOLD_EXPAND : '100%';
  @State paddingValue: ResourceStr | number =
    AccessibilityImageSizeAdjust.checkIsDevicesExpanded() ? 0 : $r('sys.float.padding_level8');

  build() {
    Column() {
      this.reConfirmDialogBuilder();
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({
      left: this.paddingValue,
      right: this.paddingValue,
    })
  }

  @Builder
  reConfirmDialogBuilder() {
    Column() {
      this.titleBuilder()
      Scroll() {
        this.contentBuilder()
      }
      .width('100%')
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
      .constraintSize({
        maxHeight: '40%'
      })

      if (FontScaleUtils.isExtraLargeFontMode()) {
        this.buttonLargeBuilder()
      } else {
        this.buttonBuilder()
      }
    }
    .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
    .saturate(0.9)
    .alignItems(HorizontalAlign.Start)
    .borderRadius($r('sys.float.corner_radius_level16'))
    .width(this.dialogWidth)
  }

  @Builder
  titleBuilder() {
    Row() {
      Text($r('app.string.shortKey_Enable'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Bold)
        .fontSize('20fp')
        .maxFontScale(2)
        .wordBreak(WordBreak.BREAK_WORD)
        .fontColor($r('sys.color.font_primary'))
        .textOverflow({ overflow: TextOverflow.None })
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .constraintSize({
          minHeight: $r('app.float.length_27'),
        })
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .padding({
      top: 15,
      bottom: 15,
      left: 24,
      right: 24
    })
  }

  @Builder
  contentBuilder() {
    Column() {
      Row() {
        Text($r('app.string.shortKey_Enable_Aware', ResourceUtil.getLocalNumberFormat(
          SHORTCUT_TIMEOUT), this.targetsInfo))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .textOverflow({ overflow: TextOverflow.None })
          .textAlign(TextAlign.Center)
          .wordBreak(WordBreak.HYPHENATION)
          .maxLines(20)
          .constraintSize({
            minHeight: 21,
          })
      }
      .width('100%')

      Row() {
        Text($r('app.string.shortKey_Enable_Setting'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .wordBreak(WordBreak.BREAK_WORD)
          .textOverflow({ overflow: TextOverflow.None })
          .maxLines(20)
          .wordBreak(WordBreak.HYPHENATION)
          .textAlign(TextAlign.Center)
          .constraintSize({
            minHeight: 21,
          })
          .width('100%')
      }
      .width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .margin({
      left: $r('sys.float.padding_level12'),
      right: $r('sys.float.padding_level12'),
    })
  }

  @Builder
  buttonBuilder() {
    Row() {
      Button($r('app.string.dialog_cancel'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_emphasize'))
        .constraintSize({ minHeight: '40vp' })
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          LogUtil.info(`${TAG} onClick cancel`);
          this.reConfirmButtonController?.onCancelClick();
        })

      Divider()
        .vertical(true)
        .height(24)
        .strokeWidth(px2vp(2))
        .lineCap(LineCapStyle.Round)
        .color($r('sys.color.comp_divider'))
        .margin({ left: 8, right: 8 })

      Button($r('app.string.accessibility_enable'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_emphasize'))
        .constraintSize({ minHeight: '40vp' })
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          LogUtil.info(`${TAG} onClick open`);
          this.reConfirmButtonController?.onOpenClick();
        })
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .margin({
      top: $r('sys.float.padding_level4'),
    })
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
      bottom: $r('sys.float.padding_level8'),
    })
  }

  @Builder
  buttonLargeBuilder() {
    Column() {
      Button() {
        Text($r('app.string.dialog_cancel'))
          .fontColor($r('sys.color.font_emphasize'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Regular)
          .maxFontScale(2)
      }
      .width('100%')
      .backgroundColor($r('app.color.transparent'))
      .onClick(() => {
        LogUtil.info(`${TAG} onClick cancel`);
        this.reConfirmButtonController?.onCancelClick();
      })
      .hoverEffect(HoverEffect.None)
      .padding({ left: $r('app.float.padding_8'), right: $r('app.float.padding_8') })
      .margin({ bottom: $r('app.float.padding_8') })

      Button() {
        Text($r('app.string.accessibility_enable'))
          .fontColor($r('sys.color.font_emphasize'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Regular)
          .maxFontScale(2)
      }
      .backgroundColor($r('app.color.transparent'))
      .width('100%')
      .onClick(() => {
        LogUtil.info(`${TAG} onClick open`);
        this.reConfirmButtonController?.onOpenClick();
      })
      .hoverEffect(HoverEffect.None)
      .padding({ left: $r('app.float.padding_8'), right: $r('app.float.padding_8') })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({
      top: $r('sys.float.padding_level8'),
      bottom: $r('sys.float.padding_level12'),
    })
    .padding({
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
  }


  private handleFoldStateChange(status: number): void {
    LogUtil.debug(`${TAG} on fold status changed: ${status}`);
    if (AccessibilityImageSizeAdjust.checkIsDevicesExpanded()  || this.dialogWidth === '100%') {
      this.dialogWidth = DIALOG_WIDTH_FOLD_EXPAND;
      this.paddingValue = 0;
      return;
    }
    if (status === Display.FoldStatus.FOLD_STATUS_HALF_FOLDED) {
      return;
    }
    this.dialogWidth = '100%';
    this.paddingValue = $r('sys.float.padding_level8');
  }

  private callback: Callback<number> = () => {
    this.dialogWidth = AccessibilityImageSizeAdjust.checkIsDevicesExpanded() ? DIALOG_WIDTH_FOLD_EXPAND : '100%';
    this.paddingValue = AccessibilityImageSizeAdjust.checkIsDevicesExpanded() ? 0 : $r('sys.float.padding_level8');
  };

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.reConfirmButtonController = new ReConfirmButtonController(this.controller);
    if (DeviceUtil.isFoldable()) {
      try {
        Display.on('foldStatusChange', (status: number) => {
          this.handleFoldStateChange(status);
        });
      } catch (err) {
        LogUtil.error(`${TAG} register foldStatusChange: code: ${err?.code} message: ${err?.message}`);
      }
    }

    try {
      Display.on('change', this.callback);
    } catch (err) {
      LogUtil.error(`${TAG} failed to register display change, code: ${err?.code}, message: ${err?.message}`);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    if (DeviceUtil.isFoldable()) {
      try {
        Display.off('foldStatusChange');
      } catch (e) {
        LogUtil.error(`${TAG} unregister foldStatusChange: ${e?.message}`);
      }
    }

    try {
      Display.off('change', this.callback);
    } catch (e) {
      LogUtil.error(`${TAG} display unregister change error: ${e?.message}`);
    }
  }
}