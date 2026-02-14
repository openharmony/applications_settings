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
import { PADDING_32, PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';

/* instrument ignore file */
const TAG: string = 'SheetTittleComponent : ';

@Extend(Image)
function iconStyle(width: Length, height: Length, margin?: Padding) {
  .width(width)
  .height(height)
  .draggable(false)
  .syncLoad(true)
  .matchTextDirection(true)
  .margin(margin)
}

@Component
export struct SheetTittleComponent {
  @Link isSearching: boolean;
  closeSheetPage?: (isFinishEdit?: boolean) => void;
  clickBackImage?: () => void;
  title: string | Resource = '';

  build() {
    Row() {
      if (this.isSearching) {
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.chevron_backward'))
            .width($r('app.float.height_24'))
            .height($r('app.float.height_24'))
            .draggable(false)
            .fontSize($r('app.float.height_24'))
            .fontColor([$r('sys.color.ohos_id_color_primary')])
        }
        .margin({ end: PADDING_8 })
        .width(40)
        .height(40)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius($r('sys.float.corner_radius_level10'))
        .onClick(() => {
          if (this.clickBackImage) {
            this.clickBackImage();
          }
        })
      }

      Text(this.title)
        .fontSize($r('app.float.font_size_20'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)

      Button({ type: ButtonType.Circle }) {
        Image($r('app.media.ic_close'))
          .iconStyle(24, 24)
          .fillColor($r('sys.color.icon_primary'))
          .draggable(false)
      }
      .accessibilityText($r('app.string.dialog_disable'))
      .width(40)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius($r('sys.float.corner_radius_level10'))
      .margin({ start: PADDING_32 })
      .onClick(() => {
        if (this.closeSheetPage) {
          this.closeSheetPage(false);
        }
      })
    }
    .width('100%')
    .height('56vp')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: $r('sys.float.padding_level8'), right: $r('sys.float.padding_level8') })
    .margin({ top: $r('sys.float.padding_level4') })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }
}