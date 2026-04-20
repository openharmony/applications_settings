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

import { SegmentButton, SegmentButtonItemTuple, SegmentButtonOptions } from '@ohos.arkui.advanced.SegmentButton';
import { PADDING_12 } from '../../constant/StyleConstant';
import { SegmentButtonModel } from '../model/SettingItemModel';
import { SettingPageLayout } from '../model/SettingPageModel';

/**
 * 分段按钮的定义，为了实现动态加载分段按钮的so，单独拆开写
 */
@Component
struct CustomSegmentButton {
  @Prop tabContents: ResourceStr[];
  @Link selectedIndexes: number[];
  compId: string = '';
  layout?: SettingPageLayout = undefined;
  @State selectCapsuleOptions: SegmentButtonOptions = SegmentButtonOptions.capsule({
    buttons: [{ text: this.tabContents?.length == 2 ? this.tabContents[0] : '' }, {
      text: this.tabContents?.length == 2 ? this.tabContents[1] : ''
    }] as SegmentButtonItemTuple,
    multiply: false,
    fontSize: $r('sys.float.ohos_id_text_size_body2'),
    selectedFontSize: $r('sys.float.ohos_id_text_size_body2'),
    fontColor: $r('sys.color.ohos_id_color_text_secondary'),
    selectedFontColor: $r('sys.color.ohos_id_color_text_primary'),
    fontWeight: FontWeight.Medium,
    selectedFontWeight: FontWeight.Medium,
    // top(bottom) = (高度(40)- 字体(14)- 固定边距(2*2))/2
    buttonPadding: { top: '11vp', right: '10vp', bottom: '11vp', left: '10vp' },
    backgroundColor: $r('sys.color.ohos_id_color_button_normal'),
    selectedBackgroundColor: $r('sys.color.ohos_id_color_foreground_contrary_disable'),
    backgroundBlurStyle: BlurStyle.NONE
  });

  build() {
    SegmentButton({ options: this.selectCapsuleOptions, selectedIndexes: this.selectedIndexes })
      .id(`${this.compId}.SegmentButton`)
      .focusable(false)
      .defaultFocus(false)
      .margin({
        start: this.layout?.padding?.start,
        end: this.layout?.padding?.end,
        top: this.layout?.padding?.top,
        bottom: PADDING_12,
      })
      .constraintSize({ minHeight: '40vp' })
  }
}

@Builder
export function segmentButtonLoader($$: SegmentButtonModel) {
  CustomSegmentButton({
    selectedIndexes: $$.selectedIndexes,
    tabContents: $$.tabContents,
    compId: $$.compId,
    layout: $$.layout
  });
}