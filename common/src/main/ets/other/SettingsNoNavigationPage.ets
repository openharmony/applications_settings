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

import Want from '@ohos.app.ability.Want';
import router from '@ohos.router';
import window from '@ohos.window';
import EnvironmentCallback from '@ohos.app.ability.EnvironmentCallback';
import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant';
import { BusinessError } from '@ohos.base';
import { Configuration } from '@ohos.app.ability.Configuration';
import emitter from '@ohos.events.emitter';
import { LogUtil } from '../utils/LogUtil';
import { EVENT_ID_CLOSE_THEME_FULL_SCREEN_PAGE } from '../event/types'

/* instrument ignore file */
const TAG: string = 'SettingsNoNavigationPage : ';
const PAGE_NAME: string = 'SettingsNoNavigationPage';
const COLOR_WHITE: string = '#ffffffff';
const COLOR_BLACK: string = '#ff000000';

/**
 * 路由携带参数
 */
interface NoNavigationPageParams {
  want: Want;
  isFull: boolean;
  isBlackBG: boolean;
  isDarkMode: boolean;
}

@Entry({ routeName: PAGE_NAME })
@Component
struct SettingsNoNavigationPage {
  @State want: Want = {};
  private isFull: boolean = false;
  @State isBlackBG: boolean = false;
  private isDarkMode: boolean = false;
  private environmentCallbackId: number = -1;

  /**
   * 设置系统栏(状态栏、导航栏)的颜色模式。浅色模式：内容黑色，深色模式：内容白色
   * @param colorMode 颜色模式：浅色模式、深色模式
   */
  private async setSystemBarColorMode(colorMode: ConfigurationConstant.ColorMode): Promise<void> {
    try {
      const isDarkMode: boolean = colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
      const lastWindow: window.Window = await window.getLastWindow(getContext(this));
      const properties: window.SystemBarProperties = {
        statusBarContentColor: isDarkMode ? COLOR_WHITE : COLOR_BLACK,
        navigationBarContentColor: isDarkMode ? COLOR_WHITE : COLOR_BLACK,
      };
      await lastWindow.setWindowSystemBarProperties(properties);
    } catch (error) {
      const e = error as BusinessError;
      LogUtil.error(`${TAG}Failed to set system bar color mode. Error = ${e?.name}, ${e?.code}, ${e?.message}`);
    }
  }

  /**
   * 重置系统栏颜色模式，保持和设置应用一致的颜色模式
   */
  private async resetSystemBarColorMode(): Promise<void> {
    try {
      const configuration = AppStorage.get<Configuration>('envConfig');
      if (configuration && configuration.colorMode !== undefined) {
        this.setSystemBarColorMode(configuration.colorMode);
      }
    } catch (error) {
      const e = error as BusinessError;
      LogUtil.error(`${TAG}Failed to reset system bar color mode. Error = ${e?.name}, ${e?.code}, ${e?.message}`);
    }
  }

  /**
   * 是否启用系统栏(状态栏、导航栏、导航条)，启用会显示系统栏，不启用会隐藏系统栏
   * @param enable 是否启用
   * @param enableAnimation 显示和隐藏系统栏，是否使用动效
   */
  private async setSystemBarEnabled(enable: boolean, enableAnimation: boolean): Promise<void> {
    try {
      const lastWindow: window.Window = await window.getLastWindow(getContext(this));
      await lastWindow.setSpecificSystemBarEnabled('status', enable, enableAnimation);
      await lastWindow.setSpecificSystemBarEnabled('navigation', enable, enableAnimation);
      await lastWindow.setSpecificSystemBarEnabled('navigationIndicator', enable, enableAnimation);
    } catch (error) {
      const e = error as BusinessError;
      LogUtil.error(`${TAG}Failed to set system bar enabled. Error = ${e?.name}, ${e?.code}, ${e?.message}`);
    }
  }

  /**
   * 退出该页面时，恢复系统栏，确保不会影响到设置的其他页面
   */
  private recoverSystemBar(): void {
    this.resetSystemBarColorMode();
    this.setSystemBarEnabled(true, false);
  }

  private initParams(): void {
    const params: NoNavigationPageParams = router.getParams() as NoNavigationPageParams;
    if (!params || !params.want) {
      LogUtil.warn(`${TAG} params is error`);
      return;
    }
    this.want = params.want;
    this.isFull = params.isFull;
    this.isBlackBG = params.isBlackBG;
    this.isDarkMode = params.isDarkMode;
  }

  private handleFullScreen(): void {
    if (!this.isFull) {
      return;
    }
    // 全屏页面，不启用系统栏(状态栏、导航栏、导航条)
    this.setSystemBarEnabled(false, false);
  }

  private handleDarkMode(): void {
    if (!this.isDarkMode) {
      return;
    }
    // 深色模式页面，修改系统栏(状态栏、导航栏)颜色
    this.setSystemBarColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);

    let systemColorMode: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
    const configuration = AppStorage.get<Configuration>('envConfig');
    if (configuration && configuration.colorMode !== undefined) {
      systemColorMode = configuration.colorMode;
    }
    const callback: EnvironmentCallback = {
      onConfigurationUpdated(config: Configuration): void {
        if (systemColorMode === config.colorMode) {
          return;
        }
        systemColorMode = config.colorMode ?? ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
        // 深色模式页面，无论系统是什么颜色模式，状态栏都是白色内容
        try {
          window.getLastWindow(getContext(this), (error: BusinessError, lastWindow: window.Window) => {
            if (error.code) {
              LogUtil.error(`${TAG}Failed to get last Window. Error = ${error.name}, ${error.code}, ${error.message}`);
              return;
            }
            const properties: window.SystemBarProperties = {
              statusBarContentColor: COLOR_WHITE,
              navigationBarContentColor: COLOR_WHITE,
            };
            lastWindow.setWindowSystemBarProperties(properties).catch((error: BusinessError) => {
              LogUtil.error(`${TAG}Failed to set white system bar = ${error?.name}, ${error?.code}, ${error?.message}`);
            });
          });
        } catch (error) {
          const e = error as BusinessError;
          LogUtil.error(`${TAG}Failed to set white system bar. Error = ${e?.name}, ${e?.code}, ${e?.message}`);
        }
      },
      onMemoryLevel(): void {
      },
    };
    try {
      this.environmentCallbackId = getContext(this).getApplicationContext().on('environment', callback);
    } catch (error) {
      const e = error as BusinessError;
      LogUtil.error(`${TAG}Failed to subscribe environment change. Error = ${e?.name}, ${e?.code}, ${e?.message}`);
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    try {
      this.initParams();
      this.handleFullScreen();
      this.handleDarkMode();
    } catch (error) {
      const e = error as BusinessError;
      LogUtil.error(`${TAG}Failed to appear page. Error = ${e?.name}, ${e?.code}, ${e?.message}`);
    }
    // 监听关闭全屏页面的事件
    emitter.on({
      eventId: EVENT_ID_CLOSE_THEME_FULL_SCREEN_PAGE,
      priority: emitter.EventPriority.IMMEDIATE,
    }, () => {
      router.back();
      this.recoverSystemBar();
    });
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    try {
      getContext(this).getApplicationContext().off('environment', this.environmentCallbackId);
      this.environmentCallbackId = -1;
      this.recoverSystemBar();
    } catch (error) {
      const e = error as BusinessError;
      LogUtil.error(`${TAG}Failed to disappear page. Error = ${e?.name}, ${e?.code}, ${e?.message}`);
    }
    emitter.off(EVENT_ID_CLOSE_THEME_FULL_SCREEN_PAGE);
  }

  build() {
    Stack() {
      UIExtensionComponent(this.want)
        .defaultFocus(true)
        .width('100%')
        .height('100%')
        .onError((error) => {
          LogUtil.error(`${TAG} UIExtensionComponent onError ${error?.message}`);
        })
        .onReceive(this.onReceiveData)
        .id('settings_full_extension')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .backgroundColor(this.isBlackBG ? Color.Black : $r('sys.color.background_secondary'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.isBlackBG ? Color.Black : $r('sys.color.background_secondary'))
  }

  private onReceiveData: (data: object) => void = (data: object) => {
    LogUtil.info(`${TAG} onReceiveData`);
    if (data === undefined) {
      LogUtil.error(`${TAG} onReceiveData is undefined`);
      return;
    }

    if (data['enterImmersion'] !== undefined) {
      const isSystemBarEnabled: boolean = data['enterImmersion'] ? false : true;
      this.setSystemBarEnabled(isSystemBarEnabled, true);
      return;
    }

    if (data['hideStatusBar'] !== undefined) {
      const isSystemBarEnabled: boolean = data['hideStatusBar'] ? false : true;
      this.setSystemBarEnabled(isSystemBarEnabled, false);
    }

    if (data['back'] !== undefined) {
      router.back();
      this.recoverSystemBar();
    }

    if (data && data['systemBarColorChange'] !== undefined) {
      LogUtil.showInfo(TAG, 'SCB UIExtension onReceive: systemBarColorChange');
      if (data['systemBarColorChange'] == 'white') {
        this.isBlackBG = true;
        this.setSystemBarColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
      }
      if (data['systemBarColorChange'] == 'reset') {
        this.isBlackBG = false;
        this.resetSystemBarColorMode();
      }
    }
  };
}

/**
 * 进入新的非Navigation页面，不分栏
 * @param want 需要加载的外部UIExtensionComponent的want参数
 * @param isFull 是否需要全屏，默认全屏，全屏会隐藏系统栏(状态栏、导航栏、导航条)
 * @param isBlackBG 是否为黑色背景，默认不是
 * @param isDarkMode 页面是否为深色模式，默认不是，深色模式会改变系统栏(状态栏、导航栏)颜色
 */
export function enterNoNavigationPage(want: Want, isFull: boolean = true, isBlackBG: boolean = false,
  isDarkMode: boolean = false): void {
  const pageParams: NoNavigationPageParams = {
    want: want,
    isFull: isFull,
    isBlackBG: isBlackBG,
    isDarkMode: isDarkMode,
  };
  router.pushNamedRoute({ name: PAGE_NAME, params: pageParams }, router.RouterMode.Standard, (err) => {
    if (err) {
      LogUtil.error(`${TAG} enterFullPage error:${err.message}`);
      return;
    }
  });
}
