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

import {
  SegmentButton,
  SegmentButtonItemTuple,
  SegmentButtonOptions,
} from '@kit.ArkUI';

/* instrument ignore file */
@Component
export struct SegmentButtonGroup {
  @Link selectedIndexes: number[];
  @State selectCapsuleOptions: SegmentButtonOptions = SegmentButtonOptions.capsule({
    buttons: [{ text: $r('app.string.storage_apps') },
      { text: $r('app.string.meta_service_settings_title') }] as SegmentButtonItemTuple,
    multiply: false,
    fontSize: $r('sys.float.Body_M'),
    selectedFontSize: $r('sys.float.Body_M'),
    fontColor: $r('sys.color.font_secondary'),
    selectedFontColor: $r('sys.color.font_primary'),
    fontWeight: FontWeight.Medium,
    selectedFontWeight: FontWeight.Medium,
    // top(bottom) = (高度(40)- 字体(14)- 固定边距(2*2))/2
    buttonPadding: {
      top: '11vp',
      right: '10vp',
      bottom: '11vp',
      left: '10vp'
    },
    backgroundColor: $r('sys.color.comp_background_tertiary'),
    selectedBackgroundColor: $r('sys.color.ohos_id_color_foreground_contrary_disable'),
    backgroundBlurStyle: BlurStyle.NONE
  });

  build() {
    SegmentButton({
      options: this.selectCapsuleOptions,
      selectedIndexes: $selectedIndexes
    })
      .focusable(false)
      .defaultFocus(false)
      .constraintSize({ minHeight: '40vp' })
      .width('calc(100% - 32vp)')
  }
}