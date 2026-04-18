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
import { AppListLoader } from '../AppListLoader';

const TAG: string = 'BaseAppLoadingComponent : ';

@Component
export struct BaseAppLoadingComponent {
  @State isLoading: boolean = true;
  private appListLoadEventCb = (data: boolean) => {
    LogUtil.info(`${TAG} app list load ${data}`);
    this.isLoading = data;
  };

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
    let appList = AppListLoader.getInstance().getAppListCache();
    if (appList.length) {
      this.isLoading = false;
    }

    EventBus.getInstance().on('EVENT_ID_LOADING', this.appListLoadEventCb);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    EventBus.getInstance().detach('EVENT_ID_LOADING', this.appListLoadEventCb);
  }
}