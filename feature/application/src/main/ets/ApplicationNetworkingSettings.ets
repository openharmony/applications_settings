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

import { ObservedData, UiExtensionViewModel } from '@ohos/settings.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { ExitAbnormallyComponent } from '@ohos/settings.common/src/main/ets/viewmodel/ExitAbnormallyComponent';
import common from '@ohos.app.ability.common';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
/* instrument ignore file */
const TAG: string = 'ApplicationNetworkingSettings : ';
const BUNDLE_NAME: string = 'com.ohos.communicationsetting';
const ABILITY_NAME: string = 'ConnectionExtAbility';

@Builder
export function ApplicationNetworkingSettingsLoader($$: Params): void {
  if (LogUtil.printBuilderLog(`${TAG} Application Networking Settings loader`)) {
    ApplicationNetworkingSettings({ params: $$ as Object as PushParam });
  }
}

@Component
export struct ApplicationNetworkingSettings {
  uiExtensionProxy?: UIExtensionProxy;
  isFromExternal: boolean = false;
  private context = getContext(this) as common.UIAbilityContext;
  private firstNavigationMode: number = 0;
  @State params: PushParam | null = null;
  @State observedData: ObservedData = new ObservedData();
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageProp('navigationMode')
  @Watch('onNavigationModeChange') navigationMode: NavigationMode = NavigationMode.Stack;

  recoverController: CustomDialogController = new CustomDialogController({
    builder: ExitAbnormallyComponent(),
  });

  private onRemoteReadyHandler(proxy: UIExtensionProxy): void {
    LogUtil.info(`${TAG} onRemoteReady navigationMode: ${this.navigationMode}`);
    this.uiExtensionProxy = proxy;
    this.uiExtensionProxy?.send({ 'navigationMode': this.navigationMode });
    this.uiExtensionProxy?.on('syncReceiverRegister', () => {
      this.uiExtensionProxy?.send({ 'navigationMode': this.navigationMode });
    });
  }

  private termiteAbility(): void {
    this.context.terminateSelf();
  }

  onNavigationModeChange(): void {
    if (!this.uiExtensionProxy) {
      return;
    }
    LogUtil.info(`${TAG} onNavigationModeChange ${this.navigationMode}`);
    this.uiExtensionProxy.send({ 'navigationMode': this.navigationMode });
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.viewModel.listening(this.recoverController);
    this.firstNavigationMode = this.navigationMode;
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.viewModel.destroyListening();
  }

  private onBackPressedBool() {
    if (this.isFromExternal) {
      LogUtil.info(`${TAG} onBackPressed`);
      this.termiteAbility();
      return true;
    }
    return false;
  }

  build() {
    NavDestination() {
      Column() {
        UIExtensionComponent({
          bundleName: BUNDLE_NAME,
          abilityName: ABILITY_NAME,
          parameters: {
            'ability.want.params.uiExtensionType': 'sys/commonUI',
            'ability.want.params.IsNotifyOccupiedAreaChange': true,
            'navigationMode': this.firstNavigationMode,
            'pushParams': (this.params?.config || this.params?.subUri) as string,
            'startReason': this.params?.startReason ?? PageStartModeManager.getInstance().getStartReason(),
            'bundleName': this.params?.bundleName as string,
            'reconnect': this.observedData.reconnect,
          }
        })
          .defaultFocus(true)
          .onRemoteReady((proxy) => {
            this.onRemoteReadyHandler(proxy);
          })
          .onError((error) => {
            LogUtil.info(`${TAG} UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
            this.viewModel.refreshing(error, this.recoverController, BUNDLE_NAME, ABILITY_NAME);
          })
          .onTerminated(()=>{})
          .onReceive((data) => {
            LogUtil.info(`${TAG} UIExtensionComponent onReceive data, pop`);
            this.pathInfos.pop();
          })
          .size({ width: '100%', height: '100%' })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
      }
      .size({ width: '100%', height: '100%' })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      LogUtil.info(`${TAG} NavDestination onShown`);
    })
    .onHidden(() => {
      LogUtil.info(`${TAG} NavDestination onHidden`);
    })
    .onBackPressed(() => this.onBackPressedBool());
  }
}