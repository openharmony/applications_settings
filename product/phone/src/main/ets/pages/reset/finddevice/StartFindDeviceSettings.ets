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

import common from '@ohos.app.ability.common';
import distributedAccount from '@ohos.account.distributedAccount';
import emitter from '@ohos.events.emitter';
import { BusinessError } from '@ohos.base';
import { ObservedData, UiExtensionViewModel } from '@ohos/settings.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { ExitAbnormallyComponent } from '@ohos/settings.common/src/main/ets/viewmodel/ExitAbnormallyComponent';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { PushParam, Params } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { EVENT_ID_EXIT_FIND_DEVICE_PAGE } from '@ohos/settings.common/src/main/ets/event/types';
import { ResetFactoryManager } from '@ohos/settings.reset/src/main/ets/controller/ResetFactoryManager';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { ResetExtraParams } from '@ohos/settings.reset/src/main/ets/model/SettingsRestoreModel';

/* instrument ignore file */
const TAG: string = 'StartFindDeviceSettings: ';
const BUNDLE_NAME: string = 'com.ohos.findservice';
const ABILITY_NAME: string = 'CheckFindLockAbility';

@Builder
export function StartFindDeviceSettingsLoader($$: Params): void {
  if (LogUtil.printBuilderLog(`${TAG} start find device settings loader`)) {
    StartFindDeviceSettings({ params: $$ as Object as PushParam });
  }
}

@Component
export struct StartFindDeviceSettings {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @State params: PushParam | null = null;
  @State isResetAll: boolean = false;
  @State observedData: ObservedData = new ObservedData();
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  @Consume('pathInfos') pathInfos: NavPathStack;

  recoverController: CustomDialogController = new CustomDialogController({
    builder: ExitAbnormallyComponent(),
  });

  private resetFactory(): void {
    distributedAccount.getDistributedAccountAbility()?.getOsAccountDistributedInfo().then(async (data) => {
      if (data.name !== 'ohosAnonymousName') {
        LogUtil.info(`${TAG} log out`);
        data.event = 'Ohos.account.event.LOGOUT';
        try {
          await distributedAccount.getDistributedAccountAbility().setOsAccountDistributedInfo(data);
        } catch (error) {
          LogUtil.error(`${TAG} log out error: msg:${error.message}`);
        }
      } else {
        LogUtil.info(`${TAG} user no login`);
      }
      ResetFactoryManager.getInstance()
        .LogoutAndReset(AbilityContextManager.getContext() as common.UIAbilityContext, this.isResetAll);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} get osAccount info failed: ${error.message}`);
    })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.BottomStart }) {
        UIExtensionComponent({
          bundleName: BUNDLE_NAME,
          abilityName: ABILITY_NAME,
          parameters: {
            'ability.want.params.uiExtensionType': 'sys/commonUI',
            'ability.want.params.IsNotifyOccupiedAreaChange': true,
            'reconnect': this.observedData.reconnect,
          }
        })
          .defaultFocus(true)
          .onError((error) => {
            LogUtil.info(`${TAG} UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
            this.viewModel.refreshing(error, this.recoverController, BUNDLE_NAME, ABILITY_NAME);
          })
          .onTerminated(()=>{})
          .onRemoteReady((proxy) => {
            LogUtil.info(`${TAG} onRemoteReady`);
          })
          .onReceive((data) => {
            LogUtil.info(`${TAG} onReceive`);
          })
          .onTerminated((data) => {
            LogUtil.info(`${TAG} onTerminated ${String(data?.code)}`)
            if (data?.code === 101) {
              this.pathInfos?.pop();
              emitter.emit({ eventId: EVENT_ID_EXIT_FIND_DEVICE_PAGE });
            } else {
              this.resetFactory();
            }
          })
          .size({ width: '100%', height: '100%' })
          .backgroundColor(Color.Transparent)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          .zIndex(2)
      }
    }
    .backgroundColor('#00000000')
    // 配置此参数后界面为半模态窗口
    .mode(NavDestinationMode.DIALOG)
    .hideTitleBar(true)
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    const isResetAll: boolean = (this.params?.config as ResetExtraParams)?.isResetAll ?? false;
    LogUtil.info(`${TAG} reset mode is ${isResetAll ? 'reset all' : 'reset normal'}.`);
    this.isResetAll = isResetAll;
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