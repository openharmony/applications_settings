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

import { EVENT_ID_SEARCH_BAR_VISIBLE } from '@ohos/settings.common/src/main/ets/event/types';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'CoverComponent: ';

@Component
export struct CoverComponent {
  private searchBarEventCb = (isSearching: boolean, coverVisible: boolean, searchWord: string) => {
    this.visible = coverVisible;
    LogUtil.info(`${TAG} aboutToAppear this.visible : ${this.visible}`);
  }
  @State visible: boolean = false;

  build() {
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.mask_fourth'))
      .visibility(this.visible ? Visibility.Visible : Visibility.None)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .onClick(() => {
        let isSearching = false;
        let coverVisible = false;
        EventBus.getInstance().emit(EVENT_ID_SEARCH_BAR_VISIBLE, isSearching, coverVisible, '');
      })
  }

  aboutToAppear(): void {
    EventBus.getInstance().on(EVENT_ID_SEARCH_BAR_VISIBLE, this.searchBarEventCb);
  }

  aboutToDisappear(): void {
    EventBus.getInstance().detach(EVENT_ID_SEARCH_BAR_VISIBLE, this.searchBarEventCb);
  }
}