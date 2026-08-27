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
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';

const TAG: string = 'ScreenReaderMoreSettings: ';
const BUNDLE_NAME: string = 'com.ohos.screenreader';
const ABILITY_NAME: string = 'UIExtAbility';

@Builder
export function ScreenReaderMoreSettingsLoader($$: Params): void {
  ScreenReaderMoreSettings({ params: $$ as Object as PushParam });
}

@Component
export struct ScreenReaderMoreSettings {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageProp('navigationMode') @Watch('onNavigationModeChange') navigationMode: NavigationMode = NavigationMode.Stack;
  @State params: PushParam | null = null;
  @State observedData: ObservedData = new ObservedData();
  private uiExtensionProxy?: UIExtensionProxy;
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  isFromExternal: boolean = false;

  recoverController: CustomDialogController = new CustomDialogController({
    builder: ExitAbnormallyComponent(),
  });

  build() {
    NavDestination() {
      UIExtensionComponent({
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME,
        parameters : {
          'ability.want.params.uiExtensionType' :  'sys/commonUI',
          'reconnect': this.observedData.reconnect,
          'pushParams': (this.params?.config || this.params?.subUri) as string,
          'startReason': this.params?.startReason ?? PageStartModeManager.getInstance().getStartReason()
        }
      })
        .defaultFocus(true)
        .width('100%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
        .onRemoteReady((proxy) => {
          LogUtil.info(`${TAG} onRemoteReady start`);
          if (proxy === null || proxy === undefined) {
            LogUtil.error(`${TAG} proxy is null or undefined`);
            return;
          }
          proxy.on('asyncReceiverRegister', () => {
            this.uiExtensionProxy = proxy;
            LogUtil.info(`${TAG} asyncReceiverRegister send navigationMode: start`);
            this.uiExtensionProxy.send({ 'navigationMode': this.navigationMode });
            LogUtil.info(`${TAG} asyncReceiverRegister send navigationMode ${this.navigationMode} finished`)
          })
        })
        .onError((error) => {
          LogUtil.info(`${TAG} UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
          this.viewModel.refreshing(error, this.recoverController, BUNDLE_NAME, ABILITY_NAME);
        })
        .onTerminated(()=>{})
        .onReceive((data) => {
          LogUtil.info(`${TAG} onReceive data`);
          if (data) {
            LogUtil.info(`${TAG} data is not empty`);
            if (data['action'] === 'backpressed') {
              this.pathInfos.pop();
            }
          }
        })
        .height('100%');
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      this.onPageShow();
      // delay start page transition animation
      if (this.navigationMode === NavigationMode.Stack) {
        this.viewModel.delayTransition();
      }
    })
    .onHidden(() => {
      this.onPageHide();
    })
    .onBackPressed(() => {
      if (this.isFromExternal) {
        LogUtil.info(`${TAG} onBackPressed`);
        this.termiteAbility();
      }
      return this.isFromExternal;
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG}  aboutToAppear`);
    this.viewModel.listening(this.recoverController);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG}  aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
    this.uiExtensionProxy?.off('asyncReceiverRegister');
    // 外部页面拉起一步返回
    if (this.isFromExternal) {
      LogUtil.info(`${TAG} from external, teminate ability`);
      this.termiteAbility();
    }
    this.viewModel.destroyListening();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.pageRoot.onPageShow();
    DynamicLoader.getInstance().pageTransitionSuccess(TAG);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.pageRoot.onPageHide();
  }

  onBackPress(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  onNavigationModeChange(): void {
    if (this.uiExtensionProxy === undefined || this.uiExtensionProxy === null) {
      LogUtil.error(`${TAG} uiExtensionProxy is undefined`);
      return;
    }
    LogUtil.info(`${TAG} onNavigationModeChange ${this.navigationMode}`);
    this.uiExtensionProxy.send({ 'navigationMode': this.navigationMode })
  }

  private termiteAbility(): void {
    AbilityContextManager.tryKillBackgroundAbility();
  }
}