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
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { STORAGE_APP_LOAD_MORE_EVENT } from '@ohos/settings.common/src/main/ets/event/types';

const TAG = 'StorageTextComponent: ';

@Builder
export function storageTextBuilder(param: object): void {
  StorageTextComponent();
}

@Component
export struct StorageTextComponent {
  aboutToAppear(): void {
    LogUtil.showInfo(TAG, `aboutToAppear`);
  }

  build() {
    Row() {
      Text($r('app.string.load_more_data'))
        .constraintSize({
          minHeight: 40,
        })
        .fontColor($r('sys.color.font_emphasize'))
    }.width('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.dealClick();
    })
  }

  dealClick(): void {
    LogUtil.showInfo(TAG, `dealClick`);
    EventBus.getInstance().emit(STORAGE_APP_LOAD_MORE_EVENT);
  }
}