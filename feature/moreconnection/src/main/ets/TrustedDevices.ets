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

import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ObservedData, UiExtensionViewModel } from '@ohos/settings.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { ExitAbnormallyComponent } from '@ohos/settings.common/src/main/ets/viewmodel/ExitAbnormallyComponent';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageStartReason } from '@ohos/settings.common/src/main/ets/data/types';
import { PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { EVENT_ID_SETTING_SEARCH_BACK } from '@ohos/settings.common/src/main/ets/event/types';
import { WirelessProjectionController } from './controller/new/WirelessProjectionController';

/* instrument ignore file */
const TAG: string = 'TrustedDevicesSettings : ';
const BUNDLE_NAME: string = 'com.ohos.cast';
const ABILITY_NAME: string = 'TrustedDevicesExtAbility';

@Component
export struct TrustedDevices {
  uiExtensionProxy?: UIExtensionProxy;
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @State observedData: ObservedData = new ObservedData();
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;
  @State startReason: string | null = null;
  @State controller: WirelessProjectionController = WirelessProjectionController.getInstance();
  @StorageProp('navigationMode') @Watch('onNavigationModeChange') navigationMode: NavigationMode = NavigationMode.Stack;
  @StorageLink('isTrustedDevicesBackPress') isTrustedDevicesBackPress: boolean = false;
  recoverController: CustomDialogController = new CustomDialogController({
    builder: ExitAbnormallyComponent(),
  });
  @StorageProp('navDesDynamicPadding') navDesDynamicPadding: number =
    AppStorage.get<number>('navDesDynamicPadding') ?? 0;

  build() {
    NavDestination() {
      UIExtensionComponent({
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME,
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'reconnect': this.observedData.reconnect,
          'pushParams': (this.params?.config || this.params?.subUri) as string,
          'startReason': this.startReason,
          'navigationMode': this.navigationMode
        }
      })
        .onRemoteReady((proxy) => {
          this.uiExtensionProxy = proxy;
        })
        .onError((error) => {
          LogUtil.info(`${TAG} UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
          this.viewModel.refreshing(error, this.recoverController, BUNDLE_NAME, ABILITY_NAME);
          // 界面失败刷新，需要重新拉起服务
          this.controller.connectCastService(getContext());
        })
        .onTerminated(() => {
        })
        .onReceive((data) => {
          LogUtil.info(`${TAG} UIExtensionComponent onReceive.`);
          if (data) {
            if (data['action'] === 'pop') {
              this.doPopAction();
              LogUtil.info(`${TAG} UIExtensionComponent pop`);
            }
          }
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .size({ width: '100%', height: '100%' })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .onShown(() => {
      this.onPageShow();
    })
    .padding({
      left: CommonUtils.getSettingsPagePadding(this.navDesDynamicPadding),
      right: CommonUtils.getSettingsPagePadding(this.navDesDynamicPadding)
    })
    .onHidden(() => {
      this.onPageHide();
    })
    .onBackPressed(() => {
      LogUtil.info(`${TAG} onBackPress`);
      this.isTrustedDevicesBackPress = true;
      return false;
    });
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.isTrustedDevicesBackPress = false;
    this.initStartReason();
    this.viewModel.listening(this.recoverController);
    this.controller.connectCastService(getContext());
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.viewModel.destroyListening();
    if (this.isTrustedDevicesBackPress) {
      this.controller.disconnectCastService(getContext());
    }
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.pageRoot.onPageShow();
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.pageRoot.onPageHide();
  }

  onNavigationModeChange(): void {
    if (!this.uiExtensionProxy) {
      return;
    }
    LogUtil.info(`${TAG} onNavigationModeChange ${this.navigationMode}`);
    this.uiExtensionProxy.send({ 'navigationMode': this.navigationMode });
  }

  private initStartReason() {
    this.startReason = this.params?.startReason as string;
    if (!this.startReason) {
      try {
        let params = this.params as PageParams;
        if (params && params.param && params.param['startReason']) {
          this.startReason = params.param['startReason'] as string;
        }
        LogUtil.info(`${TAG} getStartReason params ${this.startReason}`);
      } catch (error) {
        LogUtil.error(`${TAG} get isFromSearch error: ${error?.code}, message: ${error?.message}`);
      }
    }
  }

  private doPopAction(): void {
    if (this.startReason === PageStartReason.FROM_SEARCH && this.navigationMode === NavigationMode.Split) {
      try {
        import('@ohos.events.emitter').then(emitter => {
          emitter.default.emit({
            eventId: EVENT_ID_SETTING_SEARCH_BACK,
            priority: emitter.default.EventPriority.IMMEDIATE
          });
        });
      } catch (error) {
        LogUtil.error(`emitter doPopAction failed, error:${error?.message}`);
        this.pathInfos.pop();
      }
    } else {
      this.pathInfos.pop();
    }
  }
}