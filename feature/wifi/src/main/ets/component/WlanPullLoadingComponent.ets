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
import { SettingContentModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { SettingToggleState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { WlanPullLoadingController } from '../controller/WlanPullLoadingController';

/* instrument ignore file */
const TAG = 'WlanPullLoadingComponent: ';
const DEFAULT_VERTICAL_OFFSET: number = -64;
const UX_LOADING_PROGRESS_SIZE: number = 32;
const WLAN_TOGGLE_KEY: string = 'Setting.Wlan.WlanConfig.WlanSwitch.toggle';

/**
 * Wlan下拉加载中组件
 *
 * @since 2024-05-29
 */
@Component
export struct WlanPullLoadingComponent {
  param: object | undefined = undefined;
  compControl?: WlanPullLoadingController;
  @State showLoading: boolean = false;
  @State isToggleOn: boolean = false;
  @State newHeight: number = 0;
  onToggleChangeCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleState is invalid`);
      return;
    }
    LogUtil.info(`${TAG} receive toggle state change: ${toggleState.state}`);
    if (this.isToggleOn !== toggleState.state) {
      this.isToggleOn = toggleState.state;
    }
  };

  build() {
    Column() {
      if (this.isToggleOn && this.showLoading) {
        Row() {
          LoadingProgress()
            .color($r('app.color.loading_color'))
            .align(Alignment.Top)
            .size({
              width: UX_LOADING_PROGRESS_SIZE,
              height: UX_LOADING_PROGRESS_SIZE,
            });
        }
        .width('10%')
        .height(Math.abs(this.newHeight - DEFAULT_VERTICAL_OFFSET));
      }
    }
    .width('100%')
    .align(Alignment.Center)
  }

  aboutToAppear(): void {
    if (this.param) {
      this.compControl = (this.param as SettingContentModel).compControl as WlanPullLoadingController;
      this.isToggleOn = (this.param as SettingContentModel).visible ?? false;
      this.compControl?.registerVisibleChangeListener((show) => {
        this.showLoading = show;
      });
      this.compControl?.registerHeightChangeListener((newHeight) => {
        this.newHeight = newHeight;
      });
    }
    EventBus.getInstance().on(WLAN_TOGGLE_KEY, this.onToggleChangeCallback);
  }

  aboutToDisappear(): void {
    this.compControl?.unRegisterListener();
    EventBus.getInstance().detach(WLAN_TOGGLE_KEY, this.onToggleChangeCallback);
  }
}