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

import emitter from '@ohos.events.emitter';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { PushParam, Params } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { EVENT_ID_EXIT_FIND_DEVICE_PAGE } from '@ohos/settings.common/src/main/ets/event/types';
import { ResetExtraParams } from '@ohos/settings.reset/src/main/ets/model/SettingsRestoreModel';
/* instrument ignore file */
const TAG: string = 'StartWalletSettings : ';

export const enum WalletPageStatus {
  // 拉起钱包失败
  START_FAIL = -1,
  // 拉起钱包成功
  START_SUCCESS = 0,
  // 取消网络设置，暂不回退
  NETWORK_SETTING_CANCEL = 10,
  // 取消登录设置，暂不回退
  USE_LOGIN_CANCEL = 11,
  // 部分异常取消，暂不回退
  ABNORMAL_CANCEL = 13,
}

class WalletData {
  public close?: Next2HMOSResult;
}

class Next2HMOSResult {
  public resultCode?: number;
}

@Builder
export function StartWalletSettingsLoader($$: Params): void {
  if (LogUtil.printBuilderLog(`${TAG} start wallet settings loader`)) {
    StartWalletPage({ params: $$ as Object as PushParam });
  }
}

@Component
export struct StartWalletPage {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @State params: PushParam | null = null;
  @State isResetAll: boolean = false;
  @Consume('pathInfos') pathInfos: NavPathStack;

  private goToFindDevicePage(): void {
    let params: ResetExtraParams = { isResetAll: this.isResetAll };
    let pathInfoStack: NavPathStack | undefined = AppStorage.get<NavPathStack>(PackagesConstant.SETTINGS_PATH_STACK);
    DynamicLoader.getInstance().fire(NavEntryKey.START_FIND_DEVICE_ENTRY).then(() => {
      pathInfoStack?.pushPathByName(NavEntryKey.START_FIND_DEVICE_ENTRY, new PushParam(params));
    });
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.BottomStart }) {
        UIExtensionComponent({
          bundleName: 'com.ohos.wallet',
          abilityName: 'ResetFactoryUIExtensionAbility',
          parameters: {
            'ability.want.params.uiExtensionType': 'sys/commonUI',
          }
        })
          .defaultFocus(true)
          .onTerminated(() => {
          })
          .onReceive((data) => {
            LogUtil.info(`${TAG}, onReceive code: ${(data as WalletData).close?.resultCode}`);
            if (!this.pathInfos?.getAllPathName().includes(NavEntryKey.START_FIND_DEVICE_ENTRY)) {
              this.onWalletPageStatus((data as WalletData).close?.resultCode);
            }
          })
          .onError((error) => {
            LogUtil.error(`${TAG}, code: ${error?.code}, name: ${error?.name}, message:${error?.message}`);
            if (!this.pathInfos?.getAllPathName().includes(NavEntryKey.START_FIND_DEVICE_ENTRY)) {
              this.onWalletPageStatus(WalletPageStatus.START_FAIL);
            }
          })
          .onTerminated(()=>{})
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
    emitter.on({ eventId: EVENT_ID_EXIT_FIND_DEVICE_PAGE }, () => {
      this.pathInfos?.pop();
    })
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    emitter.off(EVENT_ID_EXIT_FIND_DEVICE_PAGE)
  }
  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.pageRoot.onPageShow();
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.pageRoot.onPageHide();
  }

  private onWalletPageStatus(resultCode?: WalletPageStatus): void {
    switch (resultCode) {
      case WalletPageStatus.START_FAIL:
      case WalletPageStatus.START_SUCCESS:
        this.goToFindDevicePage();
        break;
      default:
        // 用户中途取消清除钱包操作，销毁Navigation组件，停留当前界面
        this.pathInfos?.pop();
        break;
    }
  }
}