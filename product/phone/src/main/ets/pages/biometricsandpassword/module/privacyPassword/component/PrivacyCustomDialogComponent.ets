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

import measure from '@ohos.measure';
import Log from '../common/utils/Log';

const TAG: string = 'PrivacyCustomDialogComponent: ';

@CustomDialog
export struct PrivacyCustomDialogComponent {
  @Prop cancelText: Resource;
  @Prop confirmText: Resource;
  @State useButtonRowLayout: boolean = true;
  controller?: CustomDialogController;
  title: Resource | undefined = undefined;
  message: Resource | undefined = undefined;
  isNeedDealDisappearCallback: boolean = true;

  cancel: () => void = () => {
  }

  confirm: () => void = () => {
  }

  disappearCallback?: () => void = () => {
  };

  build() {
    Scroll() {
      Column() {
        this.builderTitle();
        this.builderMessage();
        this.builderButton();
      }
      .constraintSize({ minWidth: $r('app.float.wh_224') })
      .backgroundColor($r('sys.color.ohos_id_color_panel_bg'))
      .borderRadius({
        topLeft: $r('app.float.wh_16'),
        bottomLeft: $r('app.float.wh_16'),
        topRight: $r('app.float.wh_16'),
        bottomRight: $r('app.float.wh_16')
      })
      .padding({ left: $r('app.float.wh_24'), right: $r('app.float.wh_24'), top: $r('app.float.wh_12') })
      .onAreaChange((oldValue: Area, newValue: Area) => {
        this.useButtonRowLayout = dialogButtonRowLayout(newValue.width as number, this.confirmText, this.cancelText);
      })
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
  }

  aboutToDisappear(): void {
    Log.info(TAG, `aboutToDisappear`);
    if (this.disappearCallback && this.isNeedDealDisappearCallback) {
      this.disappearCallback();
    }
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
    .width('100%')
    .constraintSize({ minHeight: $r('app.float.wh_56') })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  builderMessage(): void {
    Row() {
      Text(this.message)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontSize($r('app.float.font_16'))
        .fontWeight(FontWeight.Regular)
    }
    .width('100%')
  }

  @Builder
  builderButton(): void {
    Column() {
      if (!this.useButtonRowLayout) {
        Column({ space: 4 }) {
          Button(this.confirmText)
            .labelStyle({ maxLines: 1, maxFontSize: $r('sys.float.Body_L'), minFontSize: 9 })
            .confirmButtonStyle()
            .width('100%')
            .onClick(() => {
              this.isNeedDealDisappearCallback = false;
              this.confirm();
            })
          Button(this.cancelText)
            .labelStyle({ maxLines: 1, maxFontSize: $r('sys.float.Body_L'), minFontSize: 9 })
            .cancelButtonStyle()
            .width('100%')
            .onClick(() => {
              this.isNeedDealDisappearCallback = false;
              this.cancel();
            })
        }
        .margin({ top: $r('app.float.wh_8'), bottom: $r('app.float.wh_8') })
        .width('100%')
        .flexShrink(0)
      } else {
        Row({ space: 8 }) {
          Button(this.confirmText)
            .confirmButtonStyle()
            .layoutWeight(1)
            .onClick(() => {
              this.isNeedDealDisappearCallback = false;
              this.confirm();
            })
          Button(this.cancelText)
            .cancelButtonStyle()
            .layoutWeight(1)
            .onClick(() => {
              this.isNeedDealDisappearCallback = false;
              this.cancel();
            })
        }
        .margin({ top: $r('app.float.wh_8'), bottom: $r('app.float.wh_16') })
        .width('100%')
        .flexShrink(0)
      }
    }
    .width('100%')
    .padding({ left: $r('app.float.wh_16'), right: $r('app.float.wh_16') })
  }
}

@Extend(Button)
function confirmButtonStyle() {
  .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
  .backgroundColor($r('app.color.font_color_transparent'))
  .fontSize($r('sys.float.ohos_id_text_size_button1'))
  .fontWeight(FontWeight.Medium)
  .constraintSize({ minHeight: 40 })
  .hoverEffect(HoverEffect.None)
  .type(ButtonType.Normal)
  .borderRadius($r('sys.float.corner_radius_level10'))
}

@Extend(Button)
function cancelButtonStyle() {
  .fontColor($r('sys.color.font_on_primary'))
  .backgroundColor($r('sys.color.comp_background_emphasize'))
  .fontSize($r('sys.float.ohos_id_text_size_button1'))
  .fontWeight(FontWeight.Medium)
  .constraintSize({ minHeight: 40 })
  .hoverEffect(HoverEffect.None)
  .type(ButtonType.Normal)
  .borderRadius($r('sys.float.corner_radius_level10'))
}

function dialogButtonRowLayout(dialogWidth: number, primary: Resource, secondary: Resource): boolean {
  let primaryButtonTextWidth = measure.measureText({
    textContent: primary,
    fontSize: $r('sys.float.ohos_id_text_size_button1'),
    fontWeight: FontWeight.Regular,
    fontFamily: 'HarmonyHeiTi'
  });
  // measureText Unit: px
  let secondaryButtonTextWidth = measure.measureText({
    textContent: secondary,
    fontSize: $r('sys.float.ohos_id_text_size_button1'),
    fontWeight: FontWeight.Regular,
    fontFamily: 'HarmonyHeiTi'
  });
  let maxButtonWidth: number = Math.max(primaryButtonTextWidth, secondaryButtonTextWidth);
  let limit = (dialogWidth - (16 * 2) - 8 - (16 * 2 * 2)) * 0.5;
  return maxButtonWidth <= vp2px(limit);
}