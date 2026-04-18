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

import Display from '@ohos.display';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
/* instrument ignore file */
const TAG: string = 'NormalDialogComponent: ';

@CustomDialog
export struct NormalDialogComponent {
  title: ResourceStr = '';
  content: ResourceStr = '';
  hint: ResourceStr = '';
  primaryButton: ResourceStr = $r('app.string.bluetooth_not_allowed');
  secondaryButton: ResourceStr = $r('app.string.wifi_button_tittle_allow');
  disallowed?: Function;
  allowed?: Function;
  controller?: CustomDialogController;
  private isPad: boolean = DeviceUtil.isDevicePad();
  private isFoldExpand: boolean = DeviceUtil.isFoldExpand();
  @State dialogWidth: number | string = this.isPad || this.isFoldExpand ? 400 : '100%'
  @State paddingValue: ResourceStr | number = this.isPad || this.isFoldExpand ? 0 : $r('sys.float.padding_level8');

  build() {
    Column() {
      Column() {
        this.titleBuilder()
        this.contentBuilder()
        this.buttonBuilder()
      }
      .backgroundColor($r('sys.color.ohos_id_color_dialog_bg'))
      .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
      .saturate(0.9)
      .alignItems(HorizontalAlign.Start)
      .borderRadius($r('sys.float.corner_radius_level16'))
      .width(this.dialogWidth)
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
  titleBuilder() {
    Row() {
      Text(this.title)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Bold)
        .fontSize('20fp')
        .maxFontScale(2)
        .minFontSize($r('sys.float.Subtitle_M'))
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({overflow: TextOverflow.Ellipsis})
        .fontColor($r('sys.color.font_primary'))
        .constraintSize({
          minHeight: 27,
        })
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .padding({
      top: 15,
      bottom: 15,
      left: $r('sys.float.padding_level12'),
      right: $r('sys.float.padding_level12'),
    })
  }

  @Builder
  contentBuilder() {
    Scroll() {
      Column() {
        Text(this.content)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .constraintSize({
            minHeight: 21,
          })

        if (this.hint) {
          Text(this.hint)
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .constraintSize({
              minHeight: 21,
            })
            .margin({
              top: $r('sys.float.padding_level8'),
            })
        }
      }
      .margin({
        left: $r('sys.float.padding_level12'),
        right: $r('sys.float.padding_level12'),
      })
      .alignItems(HorizontalAlign.Start)
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Auto)
    .edgeEffect(EdgeEffect.Spring)
    .constraintSize({
      maxHeight:'50%'
    })
  }

  @Builder
  buttonBuilder() {
    Row() {
      Button() {
        Text(this.primaryButton)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_emphasize'))
          .constraintSize({ minHeight: '21vp' })
          .maxFontScale(2)
          .margin({
            top: 10,
            bottom: 9,
          })
      }
      .layoutWeight(1)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        LogUtil.info(`${TAG} onClick disallowed`);
        this.disallowed?.();
      })

      Divider()
        .vertical(true)
        .height(24)
        .strokeWidth(px2vp(2))
        .color($r('sys.color.comp_divider'))
        .margin({ left: 8, right: 8 })

      Button() {
        Text(this.secondaryButton)
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_emphasize'))
          .constraintSize({ minHeight: '21vp' })
          .maxFontScale(2)
          .margin({
            top: 10,
            bottom: 9,
          })
      }
      .layoutWeight(1)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        LogUtil.info(`${TAG} onClick allowed`);
        this.allowed?.();
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

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    if (DeviceUtil.isFoldable()) {
      try {
        Display.on('foldStatusChange', (status: number) => {
          this.handleFoldStateChange(status);
        });
      } catch (err) {
        LogUtil.error(`${TAG} register foldStatusChange: code: ${err?.code} message: ${err?.message}`);
      }
    }
  }

  private handleFoldStateChange(status: number): void {
    LogUtil.info(`${TAG} on fold status changed: ${status}`);
    if (status === Display.FoldStatus.FOLD_STATUS_FOLDED) {
      this.dialogWidth = '100%';
      this.paddingValue = $r('sys.float.padding_level8');
    } else {
      this.dialogWidth = 400;
      this.paddingValue = 0;
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
  }
}