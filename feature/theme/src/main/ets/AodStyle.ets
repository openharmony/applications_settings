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

/* instrument ignore file */
import display from '@ohos.display';
import window from '@ohos.window';
import { ObservedData, UiExtensionViewModel } from '@ohos/settings.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { ExitAbnormallyComponent } from '@ohos/settings.common/src/main/ets/viewmodel/ExitAbnormallyComponent';
import { PageStartReason } from '@ohos/settings.common/src/main/ets/data/types';
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { enterNoNavigationPage } from '@ohos/settings.common/src/main/ets/other/SettingsNoNavigationPage';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ContextUtils } from '@ohos/settings.common/src/main/ets/utils/baseutils/ContextUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';

const TAG: string = 'AodStylePage:';
const BUNDLE_NAME: string = 'com.ohos.sceneboard';
const ABILITY_NAME: string = 'AodStyleAbility';
const AOD_WINDOW_MOD: string = 'aod.windowMode';
const BUNDLE_NAME_THEME_APP: string = 'com.ohos.thememanager';
const THEME_ABILITY_NAME: string = 'ThemeUIExtAbility';
const ABILITY_TYPE: string = 'sys/commonUI';
const CONTENT_TYPE_AOD: string = 'aod';
const SHOW_TYPE_FULLSCREEN: number = 0;
const DETAIL_PAGE: string = 'detail_page';

@Builder
export function AodStyleLoader($$: Params): void {
  AodStyle({ params: $$ as Object as PushParam });
}

@Component
struct AodStyle {
  private proxy?: UIExtensionProxy;
  @State observedData: ObservedData = new ObservedData();
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  @Consume('pathInfos') pathStack: NavPathStack;
  @StorageProp('navigationMode') @Watch('onNavigationModeChange') navigationMode: NavigationMode = NavigationMode.Stack;
  private hideBackButton: boolean = false;
  private isFromThemeApp: boolean = false;
  public params: Nullable<PushParam> = undefined;
  recoverController: CustomDialogController = new CustomDialogController({
    builder: ExitAbnormallyComponent(),
  });

  public onNavigationModeChange(): void {
    if (this.params?.startReason === PageStartReason.FROM_SEARCH) {
      this.hideBackButton = this.navigationMode === NavigationMode.Split;
      this.proxy?.send({ 'hideBackButton': this.hideBackButton });
    }
  }

  private handleReceiveData(data: object): void {
    LogUtil.info(`${TAG} UIExtensionComponent onReceive`);
    if (data['enterImmersion'] === true) {
      window.getLastWindow(getContext(this)).then((window) => {
        window.setWindowLayoutFullScreen(true).then(() => {
          window.setWindowSystemBarEnable([]);
        });
      });
    }
    if (data['enterImmersion'] === false) {
      window.getLastWindow(getContext(this)).then((window) => {
        window.setWindowSystemBarEnable(['status', 'navigation']).then(() => {
          window.setWindowLayoutFullScreen(false);
        });
      });
    }
    if (data['back'] === true) {
      this.pathStack.pop();
    }

    // 跳转AOD预置样式全屏预览页
    if (data['intent'] === 'to_preview_page') {
      LogUtil.info('start to open AODPreviewPage');
      let want: Want = {
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME,
        parameters: {
          'ability.want.params.uiExtensionType': ABILITY_TYPE,
          'sceneType': 'SettingsPreview',
          'reconnect': this.observedData.reconnect,
        }
      };
      enterNoNavigationPage(want, false, true, true);
    }

    // 跳转AOD在线样式详情页
    if (data['intent'] === 'to_online_details') {
      if (data['param'] && data['param']['id']) {
        const contentId: string = data['param']['id'] as string;
        LogUtil.info(`open online details, contentId = ${contentId}`);
        let want: Want = {
          bundleName: BUNDLE_NAME_THEME_APP,
          abilityName: THEME_ABILITY_NAME,
          parameters: {
            'ability.want.params.uiExtensionType': ABILITY_TYPE,
            'page': DETAIL_PAGE,
            'contentType': CONTENT_TYPE_AOD,
            'contentId': contentId,
            'showType': SHOW_TYPE_FULLSCREEN,
          }
        };
        enterNoNavigationPage(want, false, false, false);
      }
    }
  }

  build() {
    NavDestination() {
      UIExtensionComponent({
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME,
        parameters: {
          'ability.want.params.uiExtensionType': ABILITY_TYPE,
          'sceneType': 'SettingEditor',
          'hideBackButton': this.hideBackButton,
          'isFromThemeApp': this.isFromThemeApp,
          'reconnect': this.observedData.reconnect,
        }
      })
        .defaultFocus(true)
        .width('100%')
        .height('100%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .onRemoteReady((proxy) => {
          LogUtil.info(`${TAG} UIExtensionComponent onRemoteReady`);
          this.proxy = proxy;
        })
        .onError((error) => {
          LogUtil.info(`${TAG} UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
          this.viewModel.refreshing(error, this.recoverController, BUNDLE_NAME, ABILITY_NAME);
        })
        .onTerminated(() => {
        })
        .onReceive((data) => {
          this.handleReceiveData(data);
        });
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      LogUtil.info(`${TAG} NavDestination onShown`);
    })
    .onHidden(() => {
      LogUtil.info(`${TAG} NavDestination onHidden`);
    });
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.updateWindowStatus();
    this.viewModel.listening(this.recoverController);
    if (this.params?.startReason === PageStartReason.FROM_SEARCH && this.navigationMode === NavigationMode.Split) {
      // 设置中搜索跳转时，若设置分栏，则隐藏返回按钮
      this.hideBackButton = true;
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.viewModel.destroyListening();
  }

  private updateWindowStatus(): void {
    try {
      let context: Context = ContextUtils.getContext();
      if (CheckEmptyUtils.isEmpty(context)) {
        this.pathStack?.pop();
      }
      window.getLastWindow(context).then((win) => {
        let windowStatus: window.WindowStatusType = window.WindowStatusType.UNDEFINED;
        const windowRect = win.getWindowProperties().windowRect;
        const displayRect = display.getDefaultDisplaySync();
        LogUtil.info(`${TAG} windowWidth: ${windowRect.width}, displayWidth: ${displayRect.width}` +
          `windowHeight: ${windowRect.height}, displayHeight: ${displayRect.height}`);
        if (windowRect.width < displayRect.width || windowRect.height < displayRect.height) {
          windowStatus = window.WindowStatusType.FLOATING;
        }
        SettingsDataUtils.setSettingsDataWithContext(ContextUtils.getContext(), AOD_WINDOW_MOD, String(windowStatus));

        win.on('windowStatusChange', (windowStatusType: window.WindowStatusType) => {
          LogUtil.info(`${TAG} windowStatusChange, window type is ${windowStatusType}`);
          SettingsDataUtils.setSettingsDataWithContext(ContextUtils.getContext(), AOD_WINDOW_MOD,
           String(windowStatusType));
        });
      });
    } catch (err) {
      LogUtil.error(`${TAG} Failed to updateWindowStatus, error: ${err?.code}, message: ${err?.message}`);
    }

    if (this.params?.bundleName === BUNDLE_NAME_THEME_APP) {
      // 主题app跳转时，则隐藏更多在线样式按钮
      this.isFromThemeApp = true;
    }
  }
}
