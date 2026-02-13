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

import { DefaultPageConfig } from '@ohos/settings.common/src/main/ets/framework/common/DefaultPageConfig';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PageConfig, ScreenType } from '@ohos/settings.common/src/main/ets/framework/common/PageConfig';
import { PageLoader, PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { settingPageBuilder } from '@ohos/settings.common/src/main/ets/framework/view/SettingPage';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { notifyNetWorkSettingsSheetHeightChange } from '@ohos/settings.wifi/src/main/ets/controller/new/NetWorkSettingsController';
import { WifiMenuManager } from '@ohos/settings.wifi/src/main/ets/WifiMenuManager';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import { PageRouteController } from '../../pages/home/controller/PageRouteController';
/* instrument ignore file */
const TAG: string = 'ExternalNetworkPageComponent:';
const ROUTER_NAME: string = 'OpenNetWorkSetting';

@Entry
@Component
export struct ExternalNetworkPageComponent {
  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();
  private isWifiActive: boolean = false;

  @Builder
  pageBuilder(param: PageParams): void {
    if (param && param.pageCtx) {
      param.pageCtx.pageBuilder?.builder(param);
    }
  }

  build() {
    Column() {
      this.pageBuilder({
        router: ROUTER_NAME,
        pageUrl: 'openNetWorkSettingEntry',
        pageCtx: PageLoader.getPageContext('open_network_entry').get()
      })
    }
    .width('100%')
    .height('100%')
    .onAppear(() => {
      LogUtil.info(`${TAG} onAppear isModalShow true`);
      notifyNetWorkSettingsSheetHeightChange(this.isWifiActive, true);
    })
  }

  aboutToAppear() {
    LogUtil.info(`${TAG} aboutToAppear`);
    WifiMenuManager.setExternalNetworkStage(true);
    this.isWifiActive = WifiUtils.isWifiActive();
    PageConfig.getInstance().setPageConfigGlobal({
      defaultPageConfig: DefaultPageConfig.getInstance(),
      defaultPageBuilder: wrapBuilder(settingPageBuilder),
      screenType: ScreenType.SCREEN_TYPE_SMALL,
      navMode: NavigationMode.Auto
    });
    PageRouter.createRouter(ROUTER_NAME, {
      rootDir: '../../',
      loader: async (entryKey: string): Promise<void> => {
        LogUtil.showInfo(TAG, `import file ${entryKey}`);
        await import(PageRouteController.getInstance().getPageUrl(entryKey) as string);
      },
      path: this.pathInfos,
      isHomeEntryPage: (url: string): boolean => {
        return PageRouteController.getInstance().isHomeEntryPage(url);
      }
    });
    PageRouter.pushPage({ router: ROUTER_NAME, url: 'open_network_entry', isHome: true }, false);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    WifiMenuManager.setExternalNetworkStage(false);
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    EventBus.getInstance().emit('ExternalNetworkPagePageShow');
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    EventBus.getInstance().emit('ExternalNetworkPagePageHide');
  }
}
