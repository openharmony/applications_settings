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

import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageLoader, PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import { ObservedData, UiExtensionViewModel } from '@ohos/settings.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { ExitAbnormallyComponent } from '@ohos/settings.common/src/main/ets/viewmodel/ExitAbnormallyComponent';

const TAG: string = 'SOSEmergencyHelpSettings: ';
const BUNDLE_NAME: string = 'com.ohos.emergencycommunication';
const ABILITY_NAME: string = 'com.ohos.emergencycommunication.SosHelpAbility';

@Builder
export function settingSOSEmergencyHelpBuilder(param: object): void {
  SOSEmergencyHelpSettings({ params: (param as PageParams)?.param as PushParam });
}

function customPage(): SettingPageModel {
  return {
    id: 'sos_emergency_help_entry',
    url: NavEntryKey.SOS_EMERGENCY_HELP_ENTRY,
    type: PageType.PAGE_TYPE_CUSTOM,
    title: 'sos_emergency_help_entry',
  }
}

@Component
export struct SOSEmergencyHelpSettings {
  uiExtensionProxy?: UIExtensionProxy;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;
  @State screenHeight: number = 0;
  private firstNavigationMode: number = 0;
  private statusBarHeight: number = 0;
  @StorageProp('navigationMode')
  @Watch('onNavigationModeChange') navigationMode: NavigationMode = NavigationMode.Stack;
  @State observedData: ObservedData = new ObservedData();
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);

  recoverController: CustomDialogController = new CustomDialogController({
    builder: ExitAbnormallyComponent(),
  });

  build(){
    NavDestination(){
      UIExtensionComponent({
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME,
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'ability.want.params.IsNotifyOccupiedAreaChange': true,
          'navigationMode': this.firstNavigationMode,
          'statusBarHeight': this.statusBarHeight,
          'pushParams': (this.params?.config || this.params?.subUri) as string,
          'startReason': this.params?.startReason ?? PageStartModeManager.getInstance().getStartReason(),
          'reconnect': this.observedData.reconnect,
        }
      })
        .onRemoteReady((proxy) => {
          LogUtil.info(`${TAG} onRemoteReady navigationMode: ${this.navigationMode}`);
          this.uiExtensionProxy = proxy;
          this.uiExtensionProxy?.send({ 'navigationMode': this.navigationMode });
          this.uiExtensionProxy?.on('syncReceiverRegister', () => {
            this.uiExtensionProxy?.send({ 'navigationMode': this.navigationMode });
          });
        })
        .onError((error) => {
          LogUtil.info(`${TAG} UIExtensinoComponent onError: ${error?.code}, ${error.name}, ${error?.message}`);
          this.viewModel.refreshing(error, this.recoverController, BUNDLE_NAME, ABILITY_NAME);
        })
        .onTerminated(() => {})
        .onRelease((number) => {
          LogUtil.info(`${TAG} UIExtensionComponent onRealse ${number}`);
        })
        .onReceive((data) => {
          LogUtil.info(`${TAG} UIExtensionComponent onReceive, pop`);
          // 新增：处理返回逻辑
          if (data && data.action === 'pop' || data?.reason === 'back') {
            LogUtil.info(`${TAG} Received back command from remote UI, triggering pop.`);
            this.handleBackAction();
          }
        })
        .size({ width: '100%', height: '100%' })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onShown(() => {
      LogUtil.info(`${TAG} NavDestination onShwon`);
    })
    .onHidden(() => {
      LogUtil.info(`${TAG} NavDestination onHidden`)
    })
  }

  /**
   * 处理返回操作
   */
  private handleBackAction(): void {
    LogUtil.info(`${TAG} handleBackAction called, pathInfos length: ${this.pathInfos}`);
    // 方法1：使用路由管理器的pop方法
    if (this.pathInfos) {
      // 从导航栈中弹出当前页面
      this.pathInfos.pop();
      LogUtil.info(`${TAG} Successfully popped from navigation stack.`);
      return;
    }
  }

  onNavigationModeChange(): void {
    if (!this.uiExtensionProxy) {
      return;
    }
    LogUtil.info(`${TAG} onNavigationModeChange ${this.navigationMode}` );
    this.uiExtensionProxy.send({ 'navigationMode': this.navigationMode });
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.firstNavigationMode = this.navigationMode;
    this.statusBarHeight = px2vp(AppStorage.get('statusBarHeight'));
    this.viewModel.listening(this.recoverController);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`)
    this.viewModel.destroyListening();
    this.uiExtensionProxy?.off('syncReceiverRegister');
  }
}

PageLoader.load(NavEntryKey.SOS_EMERGENCY_HELP_ENTRY, {
  configGenerator: customPage,
  pageBuilder: wrapBuilder(settingSOSEmergencyHelpBuilder),
});