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
export const TIP_PLACE_HOLDER = ' ';

@Component
export struct TipMessage {
  @Link tipMsg: string;
  build() {
    Row() {
      if (!this.tipMsg) {
        Text(TIP_PLACE_HOLDER)
          .width('100%')
          .fontColor($r('sys.color.ohos_id_color_warning'))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .accessibilityLevel('no-hide-descendants')
      } else {
        Text(this.tipMsg)
          .width('100%')
          .fontColor($r('sys.color.ohos_id_color_warning'))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
      }
    }
    .margin({ top: $r('app.float.wh_32') })
  }
}
