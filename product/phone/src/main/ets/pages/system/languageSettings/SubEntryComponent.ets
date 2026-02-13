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

/**
 * Sub-Page Entry Component
 */
@Component
export struct SubEntryComponent {
  private targetPage: string | undefined = undefined;
  private title: string | Resource | undefined = undefined;
  @State isTouched: boolean = false;

  build() {
    Navigator({ target: this.targetPage as string }) {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row() {
          Text(this.title ?? '')
            .fontSize($r('app.float.font_16'))
            .lineHeight($r('app.float.wh_value_22'))
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .fontWeight(FontWeight.Medium)
            .margin({ left: $r('app.float.distance_8') })
            .textAlign(TextAlign.Start);
        }

        Image($r('app.media.ic_settings_arrow'))
          .width($r('app.float.wh_value_12'))
          .height($r('app.float.wh_value_24'))
          .margin({ right: $r('app.float.distance_8') })
          .fillColor($r('sys.color.ohos_id_color_secondary'))
          .opacity($r('app.float.opacity_0_2'))
          .draggable(false);
      }
      .height('100%')
      .width('100%')
      .borderRadius('14vp')
      .linearGradient(this.isTouched ? {
        angle: 90,
        direction: GradientDirection.Right,
        colors: [[$r('app.color.DCEAF9'), 0.0], [$r('app.color.FAFAFA'), 1.0]]
      } : {
        angle: 90,
        direction: GradientDirection.Right,
        colors: [[$r('sys.color.ohos_id_color_foreground_contrary'), 1], [$r('sys.color.ohos_id_color_foreground_contrary'), 1]]
      })
      .onTouch((event?: TouchEvent) => {
        if (event?.type === TouchType.Down) {
          this.isTouched = true;
        }
        if (event?.type === TouchType.Up) {
          this.isTouched = false;
        }
      })
    }
    .padding($r('app.float.distance_4'))
    .height($r('app.float.wh_value_56'))
    .borderRadius('16vp')
    .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'));
  }
}
