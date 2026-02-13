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
import { PADDING_12, PADDING_28, PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';

/**
 * Subheader layout.
 * It's suggested to use it when subheader is needed.
 */
@Component
export struct SubHeaderComponent {
  private titleContent: string | Resource | undefined = undefined;

  build() {
    Row() {
      Text(this.titleContent)
        .fontSize($r('app.float.font_14'))
        .constraintSize({ minHeight: $r('app.float.distance_20') })
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .accessibilityRole(AccessibilityRoleType.TITLE_BAR)
    }
    .constraintSize({ minHeight: $r('app.float.wh_value_56') })
    .alignItems(VerticalAlign.Bottom)
    .padding({
      bottom: PADDING_8,
      top: PADDING_28,
      start: PADDING_12,
      end: PADDING_12
    })
    .id('zone_title')
  }
}
