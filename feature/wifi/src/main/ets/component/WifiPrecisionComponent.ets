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
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { NavEntryKey, TextClickPosition } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { SettingToggleState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { WLAN_SWITCH_ID } from '../model/WifiModel';
import { WifiPrecisionModel } from '../model/WifiPrecisionModel';

/* instrument ignore file */
const TAG = 'WifiPrecisionComponent: ';
const SLICE_INDEX = 2;

/**
 * 提高精确度组件
 *
 * @since 2024-05-29
 */
@Component
export struct WifiPrecisionComponent {
  param: object | undefined = undefined;
  @State start: string | ResourceStr = '';
  @State middle: string | ResourceStr = '';
  @State end: string | ResourceStr = '';
  @State clickTextPosition: string = '';
  @State isVisible: boolean = false;
  @Builder
  contentBuilder(): void {
    Text() {
      Span(this.start)
        .fontSize($r('sys.float.Body_S'))
        .fontColor(this.clickTextPosition === TextClickPosition.START ? $r('sys.color.font_emphasize') :
        $r('sys.color.font_secondary'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(this.clickTextPosition === TextClickPosition.START ? FontWeight.Medium : FontWeight.Regular)
      Span(this.middle)
        .fontSize($r('sys.float.Body_S'))
        .fontColor((this.clickTextPosition === TextClickPosition.MIDDLE) ?
        $r('sys.color.font_emphasize') : $r('sys.color.font_secondary'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(this.clickTextPosition === TextClickPosition.MIDDLE ? FontWeight.Medium : FontWeight.Regular)
        .onClick(() => {
          if (this.clickTextPosition === TextClickPosition.MIDDLE) {
            this.onEntryClick();
          }
        })
      Span(this.end)
        .fontSize($r('sys.float.Body_S'))
        .fontColor((this.clickTextPosition === TextClickPosition.END) ?
        $r('sys.color.font_emphasize') : $r('sys.color.font_secondary'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(this.clickTextPosition === TextClickPosition.END ? FontWeight.Medium : FontWeight.Regular)
    }
  }
  onToggleChangeCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleState is invalid`);
      return;
    }
    LogUtil.info(`${TAG} receive toggle state change: ${toggleState.state}`);
    this.setVisible(!toggleState.state);
  };

  build() {
    Column() {
      Row() {
        Scroll() {
          this.contentBuilder()
        }
        .constraintSize({maxHeight:'75%'})
      }
      .size({ width: '100%' })
    }
    .size({ width: '100%' })
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

  private onEntryClick(): void {
    PageRouter.push(NavEntryKey.WIFI_PRECISION_MENU_ENTRY);
  }

  private transFormResource(resource: Resource): void {
    let result = ResourceUtil.getStringSync(resource);
    for (let i = 0; i < result.length; i++) {
      if (result[i] === '%' && result[i + 1] === 's') {
        if (i === 0) {
          this.clickTextPosition = TextClickPosition.START;
          this.start = $r('app.string.wifi_precision_title');
          this.middle = result.slice(0, i);
          this.end = result.slice(i + SLICE_INDEX, result.length);
        } else if (i === (result.length - 1)) {
          this.clickTextPosition = TextClickPosition.END;
          this.start = result.slice(0, i);
          this.middle = result.slice(i + SLICE_INDEX, result.length);
          this.end = $r('app.string.wifi_precision_title');
        } else {
          this.clickTextPosition = TextClickPosition.MIDDLE;
          this.start = result.slice(0, i);
          this.middle = $r('app.string.wifi_precision_title');
          this.end = result.slice(i + SLICE_INDEX, result.length);
        }
      }
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    if (this.param) {
      this.isVisible = !(this.param as WifiPrecisionModel).isWifiActive ?? false;
    }
    this.transFormResource($r('app.string.wifi_precision_text'));
    EventBus.getInstance().on(WLAN_SWITCH_ID, this.onToggleChangeCallback);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    EventBus.getInstance().detach(WLAN_SWITCH_ID, this.onToggleChangeCallback);
  }

  private setVisible(isVisible: boolean): void {
    if (this.isVisible !== isVisible) {
      this.isVisible = isVisible;
    }
  }
}