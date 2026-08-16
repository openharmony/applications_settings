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
import { ObservedData, UiExtensionViewModel } from '@ohos/settings.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { ExitAbnormallyComponent } from '@ohos/settings.common/src/main/ets/viewmodel/ExitAbnormallyComponent';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import common from '@ohos.app.ability.common';
import { SIMCardManagementPage } from './model/SIMCardManagementPage';

/* instrument ignore file */
const TAG: string = 'SIMCardManagement : ';
const BUNDLE_NAME: string = 'com.ohos.simcardmanagement';
const ABILITY_NAME: string = 'com.ohos.simcardmanagement.MainAbility';

@Builder
export function SIMCardManagementLoader($$: Params): void {
  SIMCardManagement({ params: $$ as object as PushParam });
}

@Component
export struct SIMCardManagement {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @State observedData: ObservedData = new ObservedData();
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;
  uiExtensionProxy?: UIExtensionProxy;
  title: string = ResourceUtil.getStringSync($r('app.string.sim_card_management_title'));
  private context = getContext(this) as common.UIAbilityContext;
  isFromExternal: boolean = false;
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
          'ability.want.params.IsNotifyOccupiedAreaChange': true,
          'reconnect': this.observedData.reconnect,
          'pushParams': (this.params?.config || this.params?.subUri) as string,
          'startReason': this.params?.startReason ?? PageStartModeManager.getInstance().getStartReason(),
        },
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
          if (data) {
            LogUtil.info(`${TAG} UIExtensionComponent onReceive`);
            if (data['action'] === 'pop') {
              this.pathInfos.pop();
              LogUtil.info(`${TAG} UIExtensionComponent pop`);
            }
          }
        })
        .width('100%')
        .height('100%')
        .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.KEYBOARD], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
    .title(this.title)
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .onShown(() => {
      this.onPageShow();
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
    LogUtil.info(`${TAG} aboutToAppear, config: ${this.params?.config}, subUri: ${this.params?.subUri}`);
    this.viewModel.listening(this.recoverController);
    this.pageRoot.aboutToAppear(new SIMCardManagementPage());
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
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
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.pageRoot.onPageHide();
  }

  private termiteAbility(): void {
    this.context.terminateSelf();
  }
}