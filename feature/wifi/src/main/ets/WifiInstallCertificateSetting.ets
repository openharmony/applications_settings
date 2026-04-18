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
import { ObservedData, UiExtensionViewModel } from '@ohos/settings.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { ExitAbnormallyComponent } from '@ohos/settings.common/src/main/ets/viewmodel/ExitAbnormallyComponent';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { Params } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';

const TAG: string = 'WifiInstallCertificateSetting : ';
const BUNDLE_NAME: string = 'com.ohos.certmanager';
const ABILITY_NAME: string = 'MainExtensionAbility';

@Builder
export function WifiInstallCertificateSettingLoader($$: Params): void {
  WifiInstallCertificateSetting({ params: $$ as object as PushParam });
}

@Component
export struct WifiInstallCertificateSetting {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @State observedData: ObservedData = new ObservedData();
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  @Consume('pathInfos') pathInfos: NavPathStack;
  uiExtensionProxy?: UIExtensionProxy;
  @State params: PushParam | null = null;
  @State startReason: string | null = null;
  @StorageProp('navigationMode')
  @Watch('onNavigationModeChange') navigationMode: NavigationMode = NavigationMode.Split;

  onNavigationModeChange(): void {
    LogUtil.info(`${TAG} onNavigationModeChange navigationMode: ${this.navigationMode}`);
    this.uiExtensionProxy?.send({ 'navigationMode': this.navigationMode });
  }

  recoverController: CustomDialogController = new CustomDialogController({
    builder: ExitAbnormallyComponent(),
  });

  build() {
    NavDestination() {
      UIExtensionComponent({
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME,
        type: 'wlanCertInstall',
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'reconnect': this.observedData.reconnect,
          'startReason': this.startReason,
          'navigationMode': this.navigationMode,
        }
      })
        .defaultFocus(true)
        .onRemoteReady((proxy) => {
          this.uiExtensionProxy = proxy;
        })
        .onError((error) => {
          LogUtil.info(`${TAG} UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
          this.viewModel.refreshing(error, this.recoverController, BUNDLE_NAME, ABILITY_NAME);
        })
        .onTerminated(()=>{})
        .onReceive((data) => {
          LogUtil.info(`${TAG} UIExtensionComponent onReceive.`);
          if (data) {
            if (data['action'] === 'exit') {
              this.pathInfos.pop();
            }
          }
        })
        .size({ width: '100%', height: '100%' })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .padding({
      left: this.observedData.left, right: this.observedData.right,
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.viewModel.listening(this.recoverController);
    if (this.params && this.params.startReason) {
      this.startReason = this.params.startReason;
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.viewModel.destroyListening();
  }
}