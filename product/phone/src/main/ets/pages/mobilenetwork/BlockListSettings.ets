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

import wifiManager from "@ohos.wifiManager";
import emitter from "@ohos.events.emitter";
import { HotSpotBlackListUtils, LogUtil, PageLifecycleOwner, PageRoot, ResourceUtil } from "@ohos/settings.common";
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { MenuPageComponent } from '@ohos/settings.uikit'
import { EVENT_ID_BLOCK_LIST_EMPTY } from '@ohos/settings.common/src/main/ets/event/types'
import { HiSysEventUtil } from "@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil";
import { HiSysHotspotEventGroup } from "@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts";
import { BlockListPage } from "./model/BlockListPage";

/* instrument ignore file */
const TAG: string = 'BlockListSettings';

@Builder
export function BlockListSettingsLoader($$: Params): void {
  BlockListSettings({ params: $$ as Object as PushParam})
}

@Component
export struct BlockListSettings {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  title: string = ResourceUtil.getStringSync($r('app.string.hot_spot_block_list'));
  @State params: PushParam | null = null;
  @State stations: Array<wifiManager.StationInfo> = [];
  @State isEmpty: boolean = false;

  @Styles
  normalStyles() {
    .backgroundColor(Color.Transparent)
    .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.ohos_id_color_click_effect'))
    .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
  }

  build() {
    NavDestination() {
      if (this.isEmpty) {
        this.emptyPage()
      } else {
        Column() {
          Blank().height($r('app.float.navigation_56'))
          MenuPageComponent({ menuPage: this.pageRoot.menuPage }).margin({bottom: $r('app.float.navigation_56')})
        }
        .size({ width: '100%', height: '100%'})
      }
    }
    .hideTitleBar(false)
    .title(this.title)
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .onShown(() => {
      this.onPageShow()
    })
    .onHidden(() => {
      this.onPageHide()
    })
  }

  @Builder
  emptyPage(): void {
    Scroll() {
      Column() {
        Image($r('app.media.search_no_result')).width(120).height(120).margin({ bottom: '16vp' })
        Text($r('app.string.no_equipment'))
          .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
          .fontSize('sys.color.ohos_id_text_size_body1')
      }
    }
    .size({ width: '100%', height: '100%' })
    .align(Alignment.Center)
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.getHotspotBlockList();
    this.pageRoot.aboutToAppear(new BlockListPage());
    HiSysEventUtil.reportDefaultBehaviorEvent(HiSysHotspotEventGroup.VIEW_BLOCK_LIST, `${this.stations.length}`)
    emitter.on({
      eventId: EVENT_ID_BLOCK_LIST_EMPTY,
    }, (event) => {
      this.isEmpty = true;
    });
  }

  getHotspotBlockList(): void {
    try {
      this.stations = HotSpotBlackListUtils.getBlockList();
    } catch (error) {
      LogUtil.info(`${TAG} getStations error: ${error?.message}`);
      this.isEmpty = true;
    }
    if (this.stations.length === 0) {
      this.isEmpty = true;
    } else {
      this.isEmpty = false;
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
    emitter.off(EVENT_ID_BLOCK_LIST_EMPTY);
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.pageRoot.onPageShow();
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.pageRoot.onPageHide();
  }
}