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
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageStartReason } from '@ohos/settings.common/src/main/ets/data/types';
import { WirelessProjectionComponent } from './WirelessProjectionComponent';

const TAG: string = 'WirelessProjectionSettings : ';

@Component
export struct WirelessProjectionSettings {
  @State isFromSearch: boolean = false;
  @State params?: PushParam = undefined;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageLink('isWirelessBackPress') isWirelessBackPress: boolean = false;
  @StorageProp('navigationMode') navigationMode: NavigationMode = NavigationMode.Stack;

  build() {
    NavDestination() {
      WirelessProjectionComponent();
    }
    .title($r('app.string.projection_toggle_title'))
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .hideBackButton(this.navigationMode === NavigationMode.Split && this.isFromSearch)
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
    .onBackPressed(() => {
      LogUtil.info(`${TAG} onBackPress`);
      this.isWirelessBackPress = true;
      return false;
    });
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.isFromSearch = this.params?.startReason === PageStartReason.FROM_SEARCH;
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }
}