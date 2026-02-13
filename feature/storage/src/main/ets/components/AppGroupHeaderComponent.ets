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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil'
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { APP_LOADING_DONE_EVENT } from '@ohos/settings.common/src/main/ets/event/types';

const TAG = 'AppGroupHeaderComponent';

@Builder
export function appGroupHeaderBuilder(param: object): void {
  AppGroupHeaderComponent();
}

@Component
export struct AppGroupHeaderComponent {
  @State private isLoading: boolean = true;
  private dealLoadingCallback = (data: boolean) => {
    this.isLoading = data;
    LogUtil.info(`${TAG} emitter.on success ${this.isLoading}`);
  }

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
      Text($r('app.string.storage_app_data_size'))
        .fontSize($r('sys.float.Subtitle_S'))
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Medium)
        .alignSelf(ItemAlign.End)
        .id('storage_app_data_size')
        .accessibilityRole(AccessibilityRoleType.TITLE_BAR)
      if (this.isLoading) {
        LoadingProgress()
          .width(24)
          .height(24)
          .margin({
            left: $r('sys.float.padding_level4')
          })
          .id('loading_progress_storage_app_list_group')
      }
    }
    .width('100%')
  }

  aboutToAppear(): void {
    EventBus.getInstance().on(APP_LOADING_DONE_EVENT, this.dealLoadingCallback);
  }

  aboutToDisappear(): void {
    EventBus.getInstance().detach(APP_LOADING_DONE_EVENT, this.dealLoadingCallback);
  }
}