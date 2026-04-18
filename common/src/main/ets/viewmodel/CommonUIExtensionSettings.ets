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

import { window } from '@kit.ArkUI';
import { ComponentContent, LengthMetrics } from '@ohos.arkui.node';
import { LogUtil } from '../utils/LogUtil';
import { Params, PushParam } from '../core/controller/Controller';
import { CommonUtils } from '../utils/CommonUtils';
import { DeviceUtil } from '../utils/BaseUtils';
import { WindowManager } from '../window/WindowManager';
import {
  DEFAULT_WINDOW_WIDTH,
  INIT_AVOID_WIDTH,
  INIT_DEFAULT_WIDTH,
  UIExtensionFinishType
} from '../utils/Consts';
import { ObservedData, UiExtensionViewModel } from '../viewmodel/UiExtensionViewModel';
import { PageRouter } from '../framework/common/PageRouter';
import { PageStartModeManager } from '../window/PageStartModeManager';

const TAG: string = 'CommonUIExtensionSettings: ';

@Builder
export function CommonUIExtensionSettingsLoader($$: Params): void {
  CommonUIExtensionSettings({ params: $$ as object as PushParam });
}

@Builder
function loadingBuilder(params: Params) {
  Column({ space: 16 }) {
    LoadingProgress()
      .width(72)
      .height(72)

    Text($r('app.string.app_list_loading'))
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('sys.color.font_secondary'))
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
}

@Component
export struct CommonUIExtensionSettings {
  @Consume('pathInfos') pathInfos: NavPathStack;
  uiExtensionProxy?: UIExtensionProxy;
  @State params: PushParam | null = null;
  hasPlaceholder: boolean = false;
  @StorageProp('navigationMode')
  @Watch('onNavigationModeChange') navigationMode: NavigationMode = NavigationMode.Auto;
  @StorageProp('navDesDynamicPadding')
  @Watch('onNavDesDynamicPaddingChange') navDesDynamicPadding: number =
    AppStorage.get<number>('navDesDynamicPadding') as number;
  @State defaultAvoidWidth: number | undefined = INIT_DEFAULT_WIDTH;
  @StorageProp('windowMode')
  @Watch('onWindowModeChange') windowModeType: number = window.WindowStatusType.UNDEFINED as number;
  @State observedData: ObservedData = new ObservedData();
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  private titleButtonRectWidth: number = INIT_AVOID_WIDTH;
  private firstNavigationMode: number = NavigationMode.Stack;
  private loadingProgress = new ComponentContent(this.getUIContext(), wrapBuilder(loadingBuilder), new Params);

  build() {
    NavDestination() {
      UIExtensionComponent({
        bundleName: this.params?.bundleName,
        abilityName: this.params?.abilityName,
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'navigationMode': this.firstNavigationMode,
          'pushParams': (this.params?.config || this.params?.subUri) as string,
          'finishType': this.params?.finishType ?? UIExtensionFinishType.FINISH_TYPE_SEND_POP,
          'targetPage': this.params?.targetPage ?? '',
          'startReason': this.params?.startReason ?? PageStartModeManager.getInstance().getStartReason(),
          'originalCallerInfo': this.params?.originalCallerInfo
        }
      },
        {
          placeholder: this.hasPlaceholder ? this.loadingProgress : undefined
        })
        .defaultFocus(true)
        .onRemoteReady((proxy) => {
          this.uiExtensionProxy = proxy;
          this.uiExtensionProxy.on('asyncReceiverRegister', (proxy) => {
            this.setDefaultAvoidWidth();
            this.sendAvoidWidth();
            this.sendWindowStatus();
          });
          LogUtil.info(`${TAG} onRemoteReady start`);
        })
        .onRelease(() => {
          this.pathInfos.pop();
        })
        .onError((error) => {
          LogUtil.error(`${TAG} UIExtensionComponent onError: ${error?.code} ${error?.message}`);
        })
        .onReceive((data) => {
          LogUtil.info(`${TAG} UIExtensionComponent onReceive ${data['action']}`);
          if (data && data['action'] === 'getNavigationMode') {
            this.uiExtensionProxy?.send({ 'navigationMode': this.navigationMode });
            LogUtil.info(`${TAG} send getNavigationMode ${this.navigationMode}`);
            return;
          }
          if (data && data['action'] === 'pop') {
            this.pathInfos.pop();
            LogUtil.info(`${TAG} pop`);
          }
          if (data['action'] === 'jump' && data['uri']) {
            LogUtil.info(`${TAG} jump uri: ${data['uri']}`);
            PageRouter.push(String(data['uri']), new PushParam(data['pushParams']), false, undefined, true);
          }
        })
        .size({ width: '100%', height: '100%' })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
    .backgroundColor(DeviceUtil.isDevicePc() ? Color.Transparent : $r('sys.color.comp_background_gray'))
    .padding({
      left: CommonUtils.getSettingsPagePadding(this.navDesDynamicPadding),
      right: CommonUtils.getSettingsPagePadding(this.navDesDynamicPadding)
    })
    .onShown(() => {
      LogUtil.info(`${TAG} NavDestination onShown`);
      WindowManager.getInstance().onKeyboardHeightChange((data: number) => {
        if (!this.uiExtensionProxy) {
          return;
        }
        LogUtil.info(`${TAG} keyboardHeight ${data} `);
        this.uiExtensionProxy.send({ 'keyboardHeight': data, 'requestType': 8 });
      });
    })
    .onHidden(() => {
      LogUtil.info(`${TAG} NavDestination onHidden`);
      WindowManager.getInstance().offKeyboardHeightChange();
    })
  }

  onNavigationModeChange(): void {
    if (!this.uiExtensionProxy) {
      return;
    }
    LogUtil.info(`${TAG} onNavigationModeChange ${this.navigationMode}`);
    this.uiExtensionProxy.send({ 'navigationMode': this.navigationMode });
  }

  private sendAvoidWidth(): void {
    if (this.uiExtensionProxy) {
      this.uiExtensionProxy.send({
        'eventType': 'eventTitleBarMarginChange',
        'value': { end: LengthMetrics.vp(this.defaultAvoidWidth) }
      });
      LogUtil.info(`${TAG} send width : ${this.defaultAvoidWidth}`);
    }
  }

  private sendWindowStatus(): void {
    if (this.uiExtensionProxy) {
      this.uiExtensionProxy.send({ 'navigationMode': this.navigationMode });
      LogUtil.info(`${TAG} onRemoteReady navigationMode: ${this.navigationMode}`);
      this.uiExtensionProxy.send({ 'windowMode': this.windowModeType });
      LogUtil.info(`${TAG} onRemoteReady send windowMode: ${this.windowModeType}`);
    }
  }

  onNavDesDynamicPaddingChange(): void {
    this.setDefaultAvoidWidth();
    this.sendAvoidWidth();
  }

  onWindowModeChange(): void {
    if (this.uiExtensionProxy) {
      this.uiExtensionProxy.send({
        'windowMode': this.windowModeType,
      });
      LogUtil.info(`${TAG} send windowMode : ${this.windowModeType}`);
    }
  }

  private setDefaultAvoidWidth(): void {
    this.titleButtonRectWidth = AppStorage.get<number>('titleButtonRectWidth') as number;
    if (this.navDesDynamicPadding !== undefined) {
      this.defaultAvoidWidth = this.titleButtonRectWidth - DEFAULT_WINDOW_WIDTH - this.navDesDynamicPadding;
    }
    LogUtil.info(`${TAG} default avoidWidth: ${this.defaultAvoidWidth}`);
  }

  aboutToAppear(): void {
    this.setDefaultAvoidWidth();
    LogUtil.info(`${TAG} aboutToAppear, navigationMode: ${this.navigationMode}`);
    this.firstNavigationMode = this.navigationMode;
  }
}