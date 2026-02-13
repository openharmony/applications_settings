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
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';

@CustomDialog
export default struct UnSaveDialogConfirmComponent {
  controller?: CustomDialogController;
  cancel: () => void = () => {
  };
  confirm: () => void = () => {
  };

  build() {
    Column() {
      SymbolGlyph($r('sys.symbol.security_shield'))
        .fontSize(32)
        .fontColor([$r('sys.color.icon_primary'), $r('sys.color.icon_emphasize')])
        .draggable(false)
        .accessibilityText('')
        .accessibilityLevel('')
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)

      Text($r('app.string.join_unsave_net'))
        .width('100%')
        .fontFamily('HarmonyHeiTi')
        .fontSize($r('sys.float.Title_S'))
        .constraintSize({
          minHeight: DeviceUtil.isDevicePc() ? 26 : 56,
        })
        .padding({
          left: 24,
          right: 24,
        })
        .margin({
          top: DeviceUtil.isDevicePc() ? 8 : 0,
          bottom: DeviceUtil.isDevicePc() ? 16 : 0,
        })
        .maxFontScale(2)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .wordBreak(WordBreak.BREAK_WORD)

      Scroll() {
        Text($r('app.string.join_unsave_net_tips'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(21)
          .width('100%')
          .textAlign(TextAlign.Start)
          .wordBreak(WordBreak.BREAK_WORD)
      }
      .scrollBar(BarState.Auto)
      .align(Alignment.TopStart)
      .edgeEffect(EdgeEffect.Spring)
      .constraintSize({
        maxHeight: '30%'
      })
      .padding({
        left: 24,
        right: 24,
      })

      Row() {
        Button() {
          Text($r('app.string.cancel'))
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .maxFontScale(2)
            .fontColor($r('sys.color.font_emphasize'))
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Center)
            .wordBreak(WordBreak.BREAK_WORD)
        }
        .constraintSize({
          minHeight: 40,
        })
        .layoutWeight(1)
        .type(DeviceUtil.isDevicePc() ? ButtonType.Normal : ButtonType.Capsule)
        .backgroundColor((DeviceUtil.isDevicePc() ? $r('sys.color.comp_background_tertiary') : Color.Transparent))
        .borderRadius(DeviceUtil.isDevicePc() ? $r('sys.float.corner_radius_level4') : undefined)
        .onClick(() => {
          this.controller?.close();
          this.cancel();
        })

        Divider()
          .vertical(true)
          .strokeWidth(0.5)
          .margin({
            left: 7.5,
            right: 7.5,
          })
          .color($r('sys.color.comp_divider'))
          .height(24);

        Button() {
          Text($r('app.string.continue_join'))
            .fontFamily('HarmonyHeiTi')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .maxFontScale(2)
            .fontColor($r('sys.color.font_emphasize'))
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Center)
            .wordBreak(WordBreak.BREAK_WORD)
        }
        .constraintSize({
          minHeight: 40,
        })
        .layoutWeight(1)
        .type(DeviceUtil.isDevicePc() ? ButtonType.Normal : ButtonType.Capsule)
        .backgroundColor((DeviceUtil.isDevicePc() ? $r('sys.color.comp_background_tertiary') : Color.Transparent))
        .borderRadius(DeviceUtil.isDevicePc() ? $r('sys.float.corner_radius_level4') : undefined)
        .onClick(() => {
          this.controller?.close();
          this.confirm();
        })
      }
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .constraintSize({
        minHeight: 40,
      })
      .margin({
        top: DeviceUtil.isDevicePc() ? 16 : 8,
      })
      .padding({
        left: 16,
        right: 16,
      })
    }.alignItems(HorizontalAlign.Center)
    .padding({
      bottom: 16,
      top: 24,
    })
    .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
  }
}