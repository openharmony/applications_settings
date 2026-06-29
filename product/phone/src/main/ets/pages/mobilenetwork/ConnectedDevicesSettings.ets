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

import wifiManager from '@ohos.wifiManager';
import window from '@ohos.window';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { MenuPageComponent } from '@ohos/settings.uikit/src/main/ets/component/MenuPageComponent';
import { ConnectedDevicesPage } from './model/ConnectedDevicesPage';

const TAG: string = 'HotspotSettings : ';

@Builder
export function ConnectedDevicesSettingsLoader($$: Params): void {
  ConnectedDevicesSettings({ params: $$ as Object as PushParam});
}

@Component
export struct ConnectedDevicesSettings {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  title: string = ResourceUtil.getStringSync($r('app.string.hotspot_connected_device'));
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;
  @State stations: wifiManager.StationInfo[] = [];
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
      Column() {
        Blank().height($r('app.float.navigation_56'))
        MenuPageComponent({ menuPage: this.pageRoot.menuPage}).margin({bottom: $r('app.float.navigation_56')});
      }
      .size({width: '100%', height: '100%'})
    }
    .hideTitleBar(false)
    .title(this.title)

    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.getStationsFromWifi();
    this.pageRoot.aboutToAppear(new ConnectedDevicesPage());
    PasswordUtil.setWindowPrivacyMode((AppStorage.get<window.WindowStage>('windowStage') as
    window.WindowStage), false);
  }

  getStationsFromWifi(): void {
    try{
      this.stations = wifiManager.getStations();
    }catch (error) {
      LogUtil.info(`${TAG} getStations error: ${error?.message}}`);
      this.isEmpty = true;
    }
    if (this.stations.length === 0) {
      this.isEmpty = true;
    } else {
      this.isEmpty = false;
    }
  }

  aboutToDisappear(): void{
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
    PasswordUtil.reSetWindowPrivacyModeIfNeed((AppStorage.get<window.WindowStage>('windowStage') as
    window.WindowStage), this.pathInfos);
  }

  onPageShow(): void {
    LogUtil.info(LogUtil.info(`${TAG} onPageShow`));
    this.pageRoot.onPageShow();
  }
  onPageHide(): void {
    LogUtil.info(LogUtil.info(`${TAG} onPageHide`));
    this.pageRoot.onPageHide();
  }
}















