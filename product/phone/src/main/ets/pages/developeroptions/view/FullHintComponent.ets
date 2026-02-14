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

const TAG: string = 'FullHintComponent: ';

@Component
export struct FullHintComponent {
  build() {
    Scroll() {
      Text() {
        Span($r('app.string.network_navigator_custom_full_tips'))
          .fontSize($r('sys.float.Body_S'))
          .constraintSize({ minHeight: $r('app.float.wh_value_16') })
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))

      }
      .textAlign(TextAlign.Start)
      .width('100%')
      .wordBreak(WordBreak.BREAK_WORD)
    }
    .scrollBar(BarState.Off)
    .constraintSize({ maxHeight: '25%' })
    .visibility(Visibility.Visible)
  }
}