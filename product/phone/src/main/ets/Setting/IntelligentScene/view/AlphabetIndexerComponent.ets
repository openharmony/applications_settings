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

import { PADDING_4 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { EVENT_ID_INTELLIGENCE_PINYIN_LIST_SCROLL_START } from '../event/types';
import { alphabets, AppInfoDataSource } from '../model/bean/AppInfoDataSource';

/* instrument ignore file */
@Component
export struct AlphabetIndexerComponent {
  private appInfoGroups: AppInfoDataSource = new AppInfoDataSource();
  scroller: Scroller = new Scroller();
  @Prop isAutoCollapse: boolean = true;
  @Prop selectedIndex: number = 0;
  @State isPop: boolean = false;
  private scrollCallBack = () => {
    this.isPop = false;
  }

  aboutToAppear(): void {
    EventBus.getInstance().on(EVENT_ID_INTELLIGENCE_PINYIN_LIST_SCROLL_START, this.scrollCallBack);
  }

  aboutToDisappear() {
    EventBus.getInstance().detach(EVENT_ID_INTELLIGENCE_PINYIN_LIST_SCROLL_START, this.scrollCallBack);
  }

  build() {
    Column() {
      AlphabetIndexer({
        arrayValue: alphabets,
        selected: this.selectedIndex,
      })
        .autoCollapse(true)
        .selectedColor($r('sys.color.font_emphasize'))
        .popupColor($r('sys.color.font_emphasize'))
        .selectedBackgroundColor($r('sys.color.comp_emphasize_tertiary'))
        .popupBackground($r('sys.color.comp_emphasize_tertiary'))
        .usingPopup(this.isPop)
        .selectedFont({ size: '10vp', weight: FontWeight.Medium })
        .popupFont({ size: $r('sys.float.Title_M') })
        .popupPosition({ x: '60vp' })
        .alignStyle(IndexerAlign.END, 48)
        .onSelect((index: number) => {
          let scrollIndex: number = this.appInfoGroups.getListScrollIndex(index);
          if (scrollIndex >= 0) {
            this.scroller.scrollToIndex(scrollIndex);
          }
        })
        .onRequestPopupData((index: number) => {
          return this.appInfoGroups.getPrefixList(index);
        })
        .onPopupSelect((index: number) => {
        })
    }
    .height('100%')
    .width('24vp')
    .onTouch((event) => {
      if (event?.type === TouchType.Down) {
        this.isPop = true;
      }
    })
  }
}