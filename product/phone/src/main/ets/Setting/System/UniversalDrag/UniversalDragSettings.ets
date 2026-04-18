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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import { ObservedData, UiExtensionViewModel } from '@ohos/settings.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { ExitAbnormallyComponent } from '@ohos/settings.common/src/main/ets/viewmodel/ExitAbnormallyComponent';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
/* instrument ignore file */
const TAG: string = 'UniversalDragSettings : ';
const BUNDLE_NAME: string = 'com.ohos.hmringgenerator';
const ABILITY_NAME: string = 'DragSwitchExtAbility';

@Builder
export function UniversalDragSettingsLoader($$: Params): void {
  if (LogUtil.printBuilderLog(`${TAG} universal drag settings loader`)) {
    UniversalDragSettings({ params: $$ as Object as PushParam });
  }
}

@Component
export struct UniversalDragSettings {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  uiExtensionProxy?: UIExtensionProxy;
  observedData: ObservedData = new ObservedData();
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;
  
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
          'pushParams': (this.params?.config || this.params?.subUri) as string,
          'startReason': this.params?.startReason ?? PageStartModeManager.getInstance().getStartReason(),
          'reconnect': this.observedData.reconnect,
        },
      })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .defaultFocus(true)
        .onRemoteReady((proxy) => {
          LogUtil.info(`${TAG} onRemoteReady`);
          this.uiExtensionProxy = proxy;
        })
        .onError((error) => {
          LogUtil.info(`${TAG} UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
          if (!this.recoverController) {
            LogUtil.error(`${TAG} recoverController is null.`);
            return;
          }
          this.viewModel.refreshing(error, this.recoverController, BUNDLE_NAME, ABILITY_NAME);
        })
        .onTerminated(() => {})
        .onReceive((data) => {
          LogUtil.info(`${TAG} UIExtensionComponent onReceive`);
          if (data && data['action'] === 'pop') {
            if (this.pathInfos.size() <= 0) {
              LogUtil.error(`${TAG} pathInfos is empty`);
              return;
            }
            this.pathInfos.pop();
            LogUtil.info(`${TAG} pop`);
          }
        })
        .size({ width: '100%', height: '100%' })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      LogUtil.info(`${TAG} NavDestination onShown`);
      this.onPageShow();
    })
    .onHidden(() => {
      LogUtil.info(`${TAG} NavDestination onHidden`);
      this.onPageHide();
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.viewModel.listening(this.recoverController);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.viewModel.destroyListening();
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
