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

import Window from '@ohos.window';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PRIVACY_PORTRAIT_PAGES } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { ColumnSystemManager } from '@ohos/settings.common/src/main/ets/window/ColumnSystemManager';
import { PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageConfig, ScreenType } from '@ohos/settings.common/src/main/ets/framework/common/PageConfig';
import { DefaultPageConfig } from '@ohos/settings.common/src/main/ets/framework/common/DefaultPageConfig';
import { settingPageBuilder } from '@ohos/settings.common/src/main/ets/framework/view/SettingPage';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { WifiMenuManager } from '@ohos/settings.wifi/src/main/ets/WifiMenuManager';
import { PageRouteController } from '../../pages/home/controller/PageRouteController';
import { OObeWifiSettings } from './OObeWifiSettings';
// import { HdsNavigation, HdsNavigationAttribute } from '@kit.UIDesignKit';
/* instrument ignore file */
const TAG: string = 'OObeWifiSettingsHome : ';

@Entry
@Component
struct OObeWifiSettingsHome {
  isJumpOobeWifiPage: boolean = false;
  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();

  @Builder pageBuilder(param: PageParams): void {
    if (param && param.pageCtx) {
      param.pageCtx.pageBuilder?.builder(param);
    }
  }

  @Builder
  myRouter(name: string, param?: Object) {
    if (name === 'oobe_wifi_ui_extension_entry') {
      OObeWifiSettings();
    } else {
      this.pageBuilder(param as PageParams);
    }
  }

  build() {
    // HdsNavigation(this.pathInfos) {
    Navigation(this.pathInfos) {
      NavRouter() {
        Column() {}
        .size({ width: '100%', height: '100%' })
      }
    }
    .navBarWidth($r('app.float.nav_value_271'))
    .navDestination(this.myRouter)
    .mode(NavigationMode.Stack)
    .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
      if (from.index !== -1) {
        return undefined;
      }
      // oobe wifi界面由于背景需要设置为透明，此场景下Navigation组件会显示一层灰色蒙层，因此需要自定义动效解决
      return this.createCustomAnimation(from, to, operation);
    })
  }

  onNavPathStackChanged() {
    LogUtil.info(`${TAG} onNavPathStackChanged`);
    const pathNames: string[] = this.pathInfos?.getAllPathName() ?? [];
    if (pathNames.length > 0) {
      const topNavName: string = pathNames[pathNames.length - 1];
      if (PRIVACY_PORTRAIT_PAGES.indexOf(topNavName) >= 0) {
        PasswordUtil.setWindowPrivacyMode((AppStorage.get<Window.WindowStage>('windowStage') as Window.WindowStage), true);
      } else {
        PasswordUtil.setWindowPrivacyMode((AppStorage.get<Window.WindowStage>('windowStage') as Window.WindowStage), false);
      }
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    WifiMenuManager.setOObeStage(true);
    this.pageRouterInit();
    ColumnSystemManager.getInstance().registerMediaQuery();
    this.pathInfos?.pushPath(new NavPathInfo('oobe_wifi_ui_extension_entry', new PushParam(AppStorage.get<Want>('wantParams')?.parameters?.pushParams), undefined, true));
  }

  private createCustomAnimation(from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation):
    NavigationAnimatedTransition {
    let customAnimation: NavigationAnimatedTransition = {
      onTransitionEnd: (isSuccess: boolean) => {
      },
      timeout: 700,
      // 转场开始时系统调用该方法，并传入转场上下文代理对象
      transition: (transitionProxy: NavigationTransitionProxy) => {
        animateTo({
          duration: 300,
          onFinish: () => {
            transitionProxy.finishTransition();
          }
        }, () => {});
      }
    };
    return customAnimation;
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    WifiMenuManager.setOObeStage(false);
    ColumnSystemManager.getInstance().unregisterMediaQuery();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  pageRouterInit(): void {
    PageConfig.getInstance().setPageConfigGlobal({
      defaultPageConfig: DefaultPageConfig.getInstance(),
      defaultPageBuilder: wrapBuilder(settingPageBuilder),
      screenType: ScreenType.SCREEN_TYPE_SMALL,
      navMode: NavigationMode.Auto
    });
    PageRouter.createRouter('Setting', {
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
    PageRouter.push('wifi_entry', undefined, true);
  }
}