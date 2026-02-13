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

import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import common from '@ohos.app.ability.common';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { BackMode, PrivacyPushParams } from '@ohos/settings.privacy/src/main/ets/PrivacyUtil';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { ObservedData, UiExtensionViewModel } from '@ohos/settings.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { ExitAbnormallyComponent } from '@ohos/settings.common/src/main/ets/viewmodel/ExitAbnormallyComponent';
import window from '@ohos.window';
import { WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant';
import { PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { UIExtensionSessionUtils } from '@ohos/settings.common/src/main/ets/utils/UIExtensionSessionUtils';
import { HiSysPrivacyAndSecurityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';

const TAG: string = 'PrivacySettings : ';
const BUNDLE_NAME: string = 'com.ohos.security.privacycenter';
const ABILITY_NAME: string = 'EntryUIExtensionAbility';
const ENTER_INTERNAL_ENTRY: string = 'enter_internal_entry';
const LOCK_SCREEN_PASSWORD_KEY: string = 'lock_screen_password_title';

interface CheckPsdParams {
  source: string;
  nextUrl: string;
  dynamic?: boolean;
  isDialogShowInSubWindow?: boolean;
}

const WINDOW_BG_WHITE: string = '#FFFFFF';
const WINDOW_BG_BLACK: string = '#000000';
const WINDOW_BG_APP: string = '#F1F3F5';


@Builder
export function PrivacySettingsLoader($$: Params): void {
  if (LogUtil.printBuilderLog(`${TAG} privacy settings loader`)) {
    PrivacySettings({ params: $$ as object as PushParam });
  }
}

@Component
export struct PrivacySettings {
  uiExtensionProxy?: UIExtensionProxy;
  @Consume('pathInfos') pathInfos: NavPathStack;
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner())
  @State params: PushParam | null = null;
  @State observedData: ObservedData = new ObservedData();
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  @StorageProp('navigationMode')
  @Watch('onNavigationModeChange') navigationMode: NavigationMode = NavigationMode.Stack;
  firstNavigationMode: NavigationMode = NavigationMode.Stack;
  @StorageProp('privacySettingsTargetSubRouter')
  @Watch('onPrivacySettingsTargetSubRouterChange') privacySettingsTargetSubRouter: string = '';
  private context = getContext(this) as common.UIAbilityContext;
  private startTime: number = 0;
  isFromExternal: boolean = false;
  isHide: boolean = false;

  recoverController: CustomDialogController = new CustomDialogController({
    builder: ExitAbnormallyComponent(),
  });

  build() {
    NavDestination() {
      UIExtensionComponent({
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME,
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'navigationMode': this.firstNavigationMode,
          'targetSubRouter': (this.params as PrivacyPushParams)?.targetSubRouter ?? '',
          'backMode': (this.params as PrivacyPushParams)?.backMode ?? BackMode.Inner,
          'pushParams': (this.params?.config || this.params?.subUri) as string,
          'startReason': this.params?.startReason ?? PageStartModeManager.getInstance().getStartReason(),
          'reconnect': this.observedData.reconnect
        }
      }, {
        dpiFollowStrategy: DpiFollowStrategy.FOLLOW_HOST_DPI
      })
        .defaultFocus(true)
        .onRemoteReady((proxy) => {
          this.onRemoteReadyHandler(proxy);
        })
        .onError((error) => {
          LogUtil.info(`${TAG} UIExtensionComponent onError code: ${error?.code} message: ${error.message}`);
          this.viewModel.refreshing(error, this.recoverController, BUNDLE_NAME, ABILITY_NAME);
          this.dealWindowScreenOn(false);
        })
        .onTerminated(() => {})
        .onReceive((data) => {
          LogUtil.info(`${TAG} UIExtensionComponent onReceive`);
          this.onReceiveData(data);
        })
        .size({ width: '100%', height: '100%' })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      this.viewModel.observedData.reconnect = 0;
      this.onPageShow();
      if (this.navigationMode === NavigationMode.Stack) {
        this.viewModel.delayTransition();
      }
    })
    .onHidden(() => {
      this.onPageShow();
    })
    .onBackPressed(() => {
      if (this.isFromExternal) {
        LogUtil.info(`${TAG} onBackPressed`);
        this.terminateAbility();
      }
      return this.isFromExternal;
    })
  }

  private onRemoteReadyHandler(proxy: UIExtensionProxy): void {
    LogUtil.info(`${TAG} onRemoteReady navigationMode: ${this.navigationMode}`);
    this.uiExtensionProxy = proxy;
    this.uiExtensionProxy?.send({ 'navigationMode': this.navigationMode });
    this.uiExtensionProxy?.on('syncReceiverRegister', () => {
      this.uiExtensionProxy?.send({ 'navigationMode': this.navigationMode });
    });
    UIExtensionSessionUtils.sendTitleAnimationDuration(this.uiExtensionProxy, this.startTime);
    this.uiExtensionProxy?.on('asyncReceiverRegister', () => {
      UIExtensionSessionUtils.sendTitleAnimationDuration(this.uiExtensionProxy, this.startTime);
    });
  }

  private onReceiveData(data: object): void {
    if (data) {
      if (data['action'] === 'pop') {
        this.pathInfos.pop(!this.isHide);
        LogUtil.info(`${TAG} pop`);
      } else if (data['action'] === 'getNavigationMode') {
        this.uiExtensionProxy?.send({ 'navigationMode': this.navigationMode });
        LogUtil.info(`${TAG} send navigation mode ${this.navigationMode}`);
      } else if (data['uri']) {
        let params: CheckPsdParams = {
          source: 'privacy_center_create_password_entry',
          nextUrl: NavEntryKey.PRIVACY_ENTRY,
          dynamic: true,
          isDialogShowInSubWindow: data['uri'] === LOCK_SCREEN_PASSWORD_KEY ? false : undefined,
        };
        let pathInfoStack: NavPathStack | undefined =
          AppStorage.get<NavPathStack>(PackagesConstant.SETTINGS_PATH_STACK);
        DynamicLoader.getInstance().fire(String(data['uri'])).then(() => {
          pathInfoStack?.pushPathByName(String(data['uri']), new PushParam(params));
        });
      } else if (data['action'] === 'keepScreenOn') {
        this.dealWindowScreenOn(true);
      } else if (data['action'] === 'closeScreenOn') {
        this.dealWindowScreenOn(false);
      } else if (data['action'] === 'jump' && data['uri']) {
        LogUtil.info(`${TAG} jump uri: ${data['uri']}`);
        PageRouter.push(data['uri'], new PushParam(), Boolean(data['isHome']), data['isEntry'], Boolean(data['isBack']));
      } else if (data['action'] === 'back') {
        this.pathInfos.pop();
        LogUtil.info(`${TAG} pop`);
      }
    }
  }

  private dealWindowScreenOn(status: boolean): void {
    LogUtil.info(`${TAG} dealWindowScreenOn ${status}`);
    WindowManager.setKeepScreenOn((AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage),
    status);
  }

  private setDarkStatusBar(): void {
    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    let colorModeConfig = context.config.colorMode;
    if (colorModeConfig === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
      LogUtil.info(`${TAG} dark mode no need set status bar`);
      return;
    }
    const properties: window.SystemBarProperties = {
      statusBarContentColor: WINDOW_BG_WHITE,
      navigationBarContentColor: WINDOW_BG_WHITE,
      statusBarColor: WINDOW_BG_BLACK
    }
    const windowBgColor: string = WINDOW_BG_BLACK;
    let windowStage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
    LogUtil.info(`${TAG} setDarStatusBar ${!windowStage} ${!properties}`);
    WindowManager.setSystemBarProperties(windowStage, properties,windowBgColor);
  }

  private setNormalStatusBar(): void {
    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    let colorModeConfig = context.config?.colorMode;
    if (colorModeConfig === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
      LogUtil.info(`${TAG} dark mode no need set normal status bar`);
      return;
    }
    const properties: window.SystemBarProperties = {
      statusBarContentColor: WINDOW_BG_WHITE,
      navigationBarContentColor: WINDOW_BG_WHITE,
      statusBarColor: WINDOW_BG_APP
    }
    const windowBgColor: string = WINDOW_BG_APP;
    WindowManager.setSystemBarProperties((AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage), properties,windowBgColor);
  }

  onNavigationModeChange(): void {
    LogUtil.info(`${TAG} onNavigationModeChange navigationMode: ${this.navigationMode}`);
    this.uiExtensionProxy?.send({ 'navigationMode': this.navigationMode });
  }

  onPrivacySettingsTargetSubRouterChange(): void {
    if (!this.privacySettingsTargetSubRouter) {
      return;
    }
    LogUtil.info(`${TAG} onPrivacySettingsTargetSubRouterChange ${this.privacySettingsTargetSubRouter}`);
    this.uiExtensionProxy?.send({
      'targetSubRouter': this.privacySettingsTargetSubRouter,
      'backMode': BackMode.Inner,
    });
  }

  aboutToAppear(): void {
    let param: PrivacyPushParams = (this.params as PageParams)?.param as PrivacyPushParams;
    if (!(this.params as PrivacyPushParams)?.targetSubRouter && param) {
      this.params = param;
    }
    LogUtil.info(`${TAG} aboutToAppear`);
    this.startTime = new Date().getTime();
    this.viewModel.listening(this.recoverController);
    this.firstNavigationMode = this.navigationMode;
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysPrivacyAndSecurityEventGroup.ENTRY_PRIVACY_SECURITY);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
    if (this.isFromExternal) {
      LogUtil.info(`${TAG} from external, terminate ability`);
      this.terminateAbility();
    }
    this.viewModel.destroyListening();
  }

  onPageShow(): void {
    this.isHide = false;
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    this.isHide = true;
    LogUtil.info(`${TAG} onPageHide`);
  }

  private terminateAbility(): void {
    this.context.terminateSelf();
  }
}