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
// import { HdsNavigation, HdsNavigationAttribute } from '@kit.UIDesignKit';
import Want from '@ohos.application.Want';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { MenuPageComponent } from '@ohos/settings.uikit/src/main/ets/component/MenuPageComponent';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { PageStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { NavEntryKey, PRIVACY_PORTRAIT_PAGES } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { ColumnSystemManager } from '@ohos/settings.common/src/main/ets/window/ColumnSystemManager';
import { ExternalHomePage } from './model/ExternalHomePage';
import { PageUrl } from '../PageUrl';
import { WifiSettings } from '../wifi/WifiSettings';
import { WifiPrecisionSetting } from '../wifi/WifiPrecisionSetting';
import { OobeWifiExtensionSettings } from '../wifi/OobeWifiExtensionSettings';
import { WifiPasswordSettings } from '../wifi/WifiPasswordSettings';
import { CreateSixPinSettings } from '../password/CreateSixPinSettings';
import { CreateNumberPsdSettings } from '../password/CreateNumberPsdSettings';
import { CreateMixedPsdSettings } from '../password/CreateMixedPsdSettings';
import { CheckPasswordSettings } from '../password/CheckPasswordSettings';
import { AddOtherWifiPage } from '../wifi/AddOtherWifiPage';
import { WifiSetupProxyPage } from '../wifi/WifiSetupProxyPage';
import { WifiSetupIpPage } from '../wifi/WifiSetupIpPage';
import { WifiConfigSetting } from '../wifi/WifiConfigSetting';
import { CreateFourPinSettings } from '../password/CreateFourPinSettings';
import PageOperation from '../../Setting/Biometrics/utils/PageOperation';
/* instrument ignore file */
const TAG: string = 'ExternalSettingsHome : ';

/**
 * 增加外部拉起设置应用内页面路由，保留至外部应用适配完，后续需要裁剪
 */
@Entry
@Component
struct ExternalSettingsHome {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  isJumpOobeWifiPage: boolean = false;
  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();
  @StorageProp('externalNavigationUrl') externalNavigationUrl: string = '';
  private changeMainContent: boolean = false;
  private mainContentNavigationUrl: string = '';

  @Builder
  myRouter(name: string, param?: Object) { // any涉及原代码适配，后续需求SR000IAJ8T中会统一整改
    // 当前Navigation只支持if-else的写法，暂无其他方式可以替代，待有新的方式替换则修改该实现
    if (name === NavEntryKey.WIFI_PRECISION_MENU_ENTRY) {
      WifiPrecisionSetting({ params: param });
    } else if (name === NavEntryKey.OOBE_UI_EXTENSION_WIFI_ENTRY) {
      OobeWifiExtensionSettings();
    } else if (name === NavEntryKey.EXTERNAL_WIFI_ENTRY) {
      WifiSettings({ isFromExternal: true });
    } else if (name === NavEntryKey.WIFI_MENU_ENTRY) {
      WifiPasswordSettings({ params: param });
    } else if (name === NavEntryKey.LOCK_SCREEN_PASSWORD_ENTRY) {
      CreateSixPinSettings({ params: param });
    } else if (name === NavEntryKey.CREATE_NUMBER_PSD_ENTRY) {
      CreateNumberPsdSettings({ params: param });
    } else if (name === NavEntryKey.CREATE_MIX_PSD_ENTRY) {
      CreateMixedPsdSettings({ params: param });
    } else if (name === NavEntryKey.CREATE_FOUR_PSD_ENTRY) {
      CreateFourPinSettings({ params: param });
    } else if (name === NavEntryKey.CHECK_PSD_ENTRY) {
      CheckPasswordSettings({ params: param });
    } else if (name === NavEntryKey.ADD_OTHER_WIFI_ENTRY) {
      AddOtherWifiPage();
    } else if (name === NavEntryKey.WIFI_SETUP_PROXY_ENTRY) {
      WifiSetupProxyPage({ pushParam: param });
    } else if (name === NavEntryKey.WIFI_SETUP_IP_ENTRY) {
      WifiSetupIpPage({ pushParam: param });
    } else if (name === NavEntryKey.WIFI_MENU_CONFIG_ENTRY) {
      WifiConfigSetting({ pushParam: param });
    }
  }

  build() {
    Navigation(this.pathInfos) {
    // HdsNavigation(this.pathInfos) {
      if (!this.changeMainContent) {
        NavRouter() {
          Column() {
            MenuPageComponent({ menuPage: this.pageRoot.menuPage });
          }
          .size({ width: '100%', height: '100%' })
        }
      }
    }
    .hideTitleBar(true)
    .navBarWidth($r('app.float.nav_value_271'))
    .navDestination(this.myRouter)
    .mode(NavigationMode.Stack)
    .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
      if (!this.isJumpOobeWifiPage || from.index !== -1) {
        return undefined;
      }
      // oobe wifi界面由于背景需要设置为透明，此场景下Navigation组件会显示一层灰色蒙层，因此需要自定义动效解决
      return this.createCustomAnimation(from, to, operation);
    })
    .onAppear(() => {
      if (this.changeMainContent) {
        this.pathInfos?.pushPath(new NavPathInfo(this.mainContentNavigationUrl,
          new PushParam(AppStorage.get<Want>('wantParams')?.parameters?.pushParams), undefined, true));
      }
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

  initMainContent(): void {
    this.changeMainContent = this.externalNavigationUrl === NavEntryKey.LOCK_SCREEN_PASSWORD_ENTRY;
    this.mainContentNavigationUrl = this.externalNavigationUrl;
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear external Url: ${this.externalNavigationUrl}`);
    PageOperation.firstEntryPage = true;
    let settingHomePage = new ExternalHomePage(PageUrl.EXTERNAL_SETTINGS_HOME_PAGE_URL);
    settingHomePage.menuType = '';
    this.pageRoot.aboutToAppear(settingHomePage);
    this.initForOobeWifiPage();
    this.initMainContent();
    if (this.externalNavigationUrl !== '') {
      if (!this.changeMainContent) {
        this.pathInfos?.pushPath(new NavPathInfo(this.externalNavigationUrl,
          new PushParam(AppStorage.get<Want>('wantParams')?.parameters?.pushParams), undefined, true));
      }
      AppStorage.SetOrCreate('externalNavigationUrl', '');
    }
  }

  private initForOobeWifiPage(): void {
    if (this.externalNavigationUrl === NavEntryKey.OOBE_UI_EXTENSION_WIFI_ENTRY) {
      this.isJumpOobeWifiPage = true;
      ColumnSystemManager.getInstance().registerMediaQuery();
      if (this.pageRoot.menuPage?.style instanceof PageStyle) {
        this.pageRoot.menuPage.style.backgroundColor = Color.Transparent;
      }
    }
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
    ColumnSystemManager.getInstance().unregisterMediaQuery();
    this.pageRoot.aboutToDisappear();
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
