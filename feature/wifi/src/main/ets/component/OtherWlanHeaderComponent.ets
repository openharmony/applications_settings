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
import { SettingToggleState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { WifiUtils } from '../WifiUtils';
import { WifiMenuManager } from '../WifiMenuManager';

/* instrument ignore file */
export const AVAILABLE_LIST_DATA_CHANGE: string = 'AVAILABLE_LIST_EMPTY';
const WLAN_TOGGLE_KEY: string = 'Setting.Wlan.WlanConfig.WlanSwitch.toggle';
const UX_PROGRESS_SIZE: number = 24;

/**
 * 其他WLAN头组件
 *
 * @since 2024-05-29
 */
@Component
export struct OtherWlanHeaderComponent {
  public tag: string = 'OtherWlanHeaderComponent : ';
  private title: ResourceStr = $r('app.string.wifi_other_wlan');
  private headerHeight: number = 48;
  @State isSwitchOn: boolean = WifiUtils.isWifiActive();
  @State isAvailableWlanEmpty: boolean = false;
  @StorageLink('WlanListLoadingVisible') loadingVisible: boolean = false;
  private onToggleChangeCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${this.tag} toggleState is invalid`);
      return;
    }
    LogUtil.info(`${this.tag} receive toggle state change: ${toggleState.state}`);
    this.isSwitchOn = toggleState.state;
  }

  private onAvailableWlanChangeCallback = (isEmpty: boolean) => {
    if (this.isAvailableWlanEmpty !== isEmpty) {
      this.isAvailableWlanEmpty = isEmpty;
    }
  }

  build() {
    Column() {
      Row() {
        Text(this.title)
          .accessibilityDescription($r('app.string.title'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.Subtitle_S'))
          .lineHeight(19)
          .width('85%')
          .margin({
            top: 4
          })

        Column() {
          LoadingProgress()
            .margin({
              top: 2
            })
            .color($r('sys.color.icon_secondary'))
            .size({ height: '24vp', width: '24vp' })
            .visibility(this.loadingVisible ? Visibility.Visible : Visibility.Hidden)
            .id('loading_progress_')
        }
        .alignItems(HorizontalAlign.End)
        .layoutWeight(1)
      }
    }
  }

  aboutToAppear(): void {
    if (WifiMenuManager.isInOObeStage() && DeviceUtil.isDevicePc()) {
      this.headerHeight = 32;
    }
    EventBus.getInstance().on(WLAN_TOGGLE_KEY, this.onToggleChangeCallback);
    EventBus.getInstance().on(AVAILABLE_LIST_DATA_CHANGE, this.onAvailableWlanChangeCallback);
  }

  aboutToDisappear(): void {
    EventBus.getInstance().detach(WLAN_TOGGLE_KEY, this.onToggleChangeCallback);
    EventBus.getInstance().detach(AVAILABLE_LIST_DATA_CHANGE, this.onAvailableWlanChangeCallback);
  }
}