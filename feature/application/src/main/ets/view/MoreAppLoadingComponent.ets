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

import emitter from '@ohos.events.emitter';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EVENT_ID_MORE_APP_LIST_LOADER } from '@ohos/settings.common/src/main/ets/event/types';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { MoreAppListLoader } from '../MoreAppListLoader';
/* instrument ignore file */
const TAG: string = 'MoreAppLoadingComponent : ';

@Component
export struct MoreAppLoadingComponent {
  @State isLoading: boolean = true;

  build() {
    Column() {
      LoadingProgress()
        .width(72)
        .height(72)
        .alignSelf(ItemAlign.Center)
      Text($r('app.string.app_list_loading_message'))
        .margin({ top: $r('sys.float.padding_level8') })
    }
    .width('100%')
    .height(this.isLoading ? '60%' : 0)
    .justifyContent(FlexAlign.Center)
    .visibility(this.isLoading ? Visibility.Visible : Visibility.None)
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    let appList = MoreAppListLoader.getInstance().getAppListCache();
    if (appList.length) {
      this.isLoading = false;
    }

    emitter.on({
      eventId: EVENT_ID_MORE_APP_LIST_LOADER,
    }, (eventData: emitter.EventData) => {
      this.isLoading = MoreAppListLoader.getInstance().isRefreshAppList();
    });
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    if (CommonUtils.isPageExist(NavEntryKey.MORE_APPLICATION_ENTRY)) {
      LogUtil.info(`${TAG} the page exist, stop emmitter off`);
      return;
    }
    emitter.off(EVENT_ID_MORE_APP_LIST_LOADER);
  }
}