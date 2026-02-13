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
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { UIExtensionSessionUtils } from '@ohos/settings.common/src/main/ets/utils/UIExtensionSessionUtils';

const TAG: string = 'PrintSettings: ';
const BUNDLE_NAME: string = 'com.ohos.spooler';
const ABILITY_NAME: string = 'PrintersScannersUIExtensionAbility';

@Builder
export function PrintersAndScannersSettingsLoader($$: Params): void {
  if (LogUtil.printBuilderLog(`${TAG} settings loader`)) {
    PrintSettings();
  }
}

@Component
export struct PrintSettings {
  uiExtensionProxy?: UIExtensionProxy;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;
  @State observedData: ObservedData = new ObservedData();
  @StorageProp('navigationMode') @Watch('navigationModeChange') navigationMode: NavigationMode = NavigationMode.Split;
  private firstNavigationMode: number = 0;
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  private isToAddDevicePage: boolean = false;
  private startTime: number = 0;
  recoverController: CustomDialogController = new CustomDialogController({
    builder: ExitAbnormallyComponent(),
  });

  build() {
    NavDestination() {
      UIExtensionComponent({
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME,
        uri: 'PrintersAndScanners_page',
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'reconnect': this.observedData.reconnect,
          'isToAddDevicePage': this.isToAddDevicePage,
          'navigationMode': this.firstNavigationMode
        }
      }, {
        dpiFollowStrategy: DpiFollowStrategy.FOLLOW_HOST_DPI
      })
        .defaultFocus(true)
        .onRemoteReady((proxy) => {
          this.uiExtensionProxy = proxy;
          UIExtensionSessionUtils.sendTitleAnimationDuration(this.uiExtensionProxy, this.startTime);
          this.uiExtensionProxy?.on('asyncReceiverRegister', () => {
            UIExtensionSessionUtils.sendTitleAnimationDuration(this.uiExtensionProxy, this.startTime);
          });
        })
        .onError((error) => {
          LogUtil.info(`${TAG} UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
          this.viewModel.refreshing(error, this.recoverController, BUNDLE_NAME, ABILITY_NAME);
        })
        .onTerminated(() => {
        })
        .onReceive((data) => {
          LogUtil.debug(`${TAG} UIExtensionComponent onReceive`);
          // 分屏场景接受UIExtensionAbility发过来的参数
          if (data && data['action'] === 'getNavigationMode') {
            this.uiExtensionProxy?.send({ 'navigationMode': this.navigationMode });
            LogUtil.showInfo(TAG, `send getNavigationMode ${this.navigationMode}`);
          }
          if (data && data['action'] === 'pop') {
            LogUtil.showInfo(TAG, 'page pop');
            this.pathInfos.pop();
          }
        })
        .size({ width: '100%', height: '100%' })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      LogUtil.debug(`${TAG} NavDestination onShown`);
      if (this.navigationMode === NavigationMode.Stack) {
        this.viewModel.delayTransition();
      }
    })
    .onHidden(() => {
      LogUtil.debug(`${TAG} NavDestination onHidden`);
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.startTime = new Date().getTime();
    this.viewModel.listening(this.recoverController);
    this.firstNavigationMode = this.navigationMode;
    let want: Want | undefined = AppStorage.get<Want>('wantParams');
    if (want?.parameters?.isToAddDevicePage) {
      LogUtil.info(`${TAG} is to pull up add device window`);
      this.isToAddDevicePage = true;
      want.parameters.isToAddDevicePage = false;
      AppStorage.set('wantParams', want);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.viewModel.destroyListening();
  }

  navigationModeChange(): void {
    if (!this.uiExtensionProxy) {
      LogUtil.showInfo(TAG, 'uiExtensionProxy is null');
      return;
    }
    LogUtil.showInfo(TAG, `onNavigationModeChange ${this.navigationMode}`);
    this.uiExtensionProxy.send({ 'navigationMode': this.navigationMode });
  }
}