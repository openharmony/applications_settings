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

import window from '@ohos.window';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { AvoidAreaDirect, WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';

const TAG: string = 'EmptySearchComponent: ';
const windowStage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
const PC_TITLE_BAR_TOP_SPACE: number = 4;
const TITLE_BAR_HEIGHT_AND_PADDING: number = 64;
const BOTTOM_SPACE: number = 100;

@Component
export struct EmptySearchComponent {
  private isPC: boolean = DeviceUtil.isDevicePc();
  @State isEmpty: boolean = false;
  @State componentHeight: number = 0;

  build() {
    Column() {
      Blank()
        .height(this.isPC ? BOTTOM_SPACE : 0)
      Column() {
        Image($r('app.media.search_no_result'))
          .width('120vp')
          .height('120vp')
          .draggable(false)
        Text($r('app.string.no_matching_results'))
          .fontColor($r('sys.color.font_secondary'))
          .fontSize('14fp')
          .fontWeight(FontWeight.Regular)
          .fontFamily('HarmonyHeiTi')
      }
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height(this.componentHeight)
    .justifyContent(FlexAlign.Center)
    .visibility(this.isEmpty ? Visibility.Visible : Visibility.None)
  }

  async aboutToAppear(): Promise<void> {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    if (this.isPC) {
      windowStage?.getMainWindow((err, data) => {
        // 根据windowSizeChange 类型来获取当前窗口宽度
        data?.on('windowSizeChange', (size: window.Size) => {
          let currentHeight: number = size?.height;
          this.componentHeight =
            px2vp(currentHeight) - TITLE_BAR_HEIGHT_AND_PADDING - PC_TITLE_BAR_TOP_SPACE - BOTTOM_SPACE * 2;
        });
        let currentWindowHeight: number = data?.getWindowProperties().windowRect.height;
        this.componentHeight =
          px2vp(currentWindowHeight) - TITLE_BAR_HEIGHT_AND_PADDING - PC_TITLE_BAR_TOP_SPACE - BOTTOM_SPACE * 2;
      })
    } else {
      let topHeight = WindowManager.getAvoidAreaHeight(
        AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage, AvoidAreaDirect.TOP,
        window.AvoidAreaType.TYPE_SYSTEM);
      let bottomHeight = WindowManager.getAvoidAreaHeight(
        AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage, AvoidAreaDirect.BOTTOM,
        window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      this.componentHeight =
        DisplayUtils.getScreenHeight() - TITLE_BAR_HEIGHT_AND_PADDING - px2vp(topHeight) - px2vp(bottomHeight);
    }
    EventBus.getInstance().on('EVENT_ID_SEARCH_EMPTY', this.serviceEmptyEventCb);
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    EventBus.getInstance().detach('EVENT_ID_SEARCH_EMPTY', this.serviceEmptyEventCb);
  }

  private serviceEmptyEventCb = (isEmpty: boolean) => {
    LogUtil.showInfo(TAG, `serviceEmpty : ${this.isEmpty} `);
    this.isEmpty = isEmpty;
  };
}