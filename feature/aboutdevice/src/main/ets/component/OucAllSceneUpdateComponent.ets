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

import { LengthMetrics } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SystemUpdateConstants } from '@ohos/settings.common/src/main/ets/constant/SystemUpdateConstants';
import { ObservedData, UiExtensionViewModel } from '@ohos/settings.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { ExitAbnormallyComponent } from '@ohos/settings.common/src/main/ets/viewmodel/ExitAbnormallyComponent';
import { EVENT_ID_SETTING_SEARCH_BACK } from '@ohos/settings.common/src/main/ets/event/types';
import { HiSysSystemAndUpdatesEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import {
  INIT_AVOID_WIDTH,
  INIT_DEFAULT_WIDTH,
  INVALID_AVOID_WIDTH,
} from '@ohos/settings.common/src/main/ets/utils/Consts';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
/* instrument ignore file */
const TAG: string = 'OucAllSceneUpdateComponent: ';
const TITLE_BAR_MARGIN_CHANGE_EVENT: string = 'eventTitleBarMarginChange';

@Component
export struct OucAllSceneUpdateComponent {
  uiExtensionProxy?: UIExtensionProxy;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageProp('com_hmos_ouc_all_scene_update_target_sub_router')
  @Watch('onTargetSubRouterChange') targetSubRouter: string = '';
  @State observedData: ObservedData = new ObservedData();
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  @State params: PushParam | null = null;
  @StorageProp('navDesDynamicPadding')
  @Watch('onNavDesDynamicPaddingChange') navDesDynamicPadding: number =
    AppStorage.get<number>('navDesDynamicPadding') ?? 0;
  @State defaultAvoidWidth: number | undefined = INIT_DEFAULT_WIDTH;
  private titleButtonRectWidth: number = INIT_AVOID_WIDTH;
  @StorageProp('navigationMode') @Watch('onNavigationModeChange')
  navigationMode: NavigationMode = NavigationMode.Stack;
  private navigationModeParameter: NavigationMode = this.navigationMode;
  
  recoverController: CustomDialogController = new CustomDialogController({
    builder: ExitAbnormallyComponent(),
  });

  build() {
    NavDestination() {
      UIExtensionComponent({
        bundleName: SystemUpdateConstants.OUC_BUNDLE_NAME,
        abilityName: SystemUpdateConstants.OUC_ALL_SCENE_ABILITY_NAME,
        uri: SystemUpdateConstants.OUC_ALL_SCENE_PAGE_URI,
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'startReason': this.params?.startReason ?? PageStartModeManager.getInstance().getStartReason(),
          'navigationMode': this.navigationModeParameter,
          'reconnect': this.observedData.reconnect,
        },
      })
        .defaultFocus(true)
        .onRemoteReady((proxy) => {
          this.uiExtensionProxy = proxy;
          this.uiExtensionProxy.on('asyncReceiverRegister', (proxy1) => {
            LogUtil.info(`OucAllSceneUpdateComponent asyncReceiverRegister`);
            this.setDefaultAvoidWidth();
            this.sendAvoidWidth();
          });
        })
        .onReceive((data) => {
          LogUtil.showInfo(TAG, `UIExtensionComponent onReceive ${data?.['action']}`);
          this.processReceiveData(data);
        })
        .onError((error) => {
          LogUtil.showInfo(TAG, `UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
          this.viewModel.refreshing(error, this.recoverController, SystemUpdateConstants.OUC_BUNDLE_NAME,
            SystemUpdateConstants.OUC_ALL_SCENE_ABILITY_NAME);
        })
        .onTerminated(() => {
          this.pathInfos.pop();
          LogUtil.showInfo(TAG, `onRelease pathInfos.size ${this.pathInfos.size()}`);
        })
        .size({ width: '100%', height: '100%' })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      LogUtil.showInfo(TAG, `NavDestination onShown`);
    })
    .onHidden(() => {
      LogUtil.showInfo(TAG, `NavDestination onHidden`);
    })
    .padding({
      start: LengthMetrics.vp(this.navDesDynamicPadding),
      end: LengthMetrics.vp(this.navDesDynamicPadding)
    })
  }

  onNavDesDynamicPaddingChange(): void {
    this.setDefaultAvoidWidth();
    this.sendAvoidWidth();
  }

  private setDefaultAvoidWidth() {
    this.titleButtonRectWidth = AppStorage.get<number>('titleButtonRectWidth') ?? 0;
    let avoidWidth: number = CommonUtils.calculateAvoidWidth(this.titleButtonRectWidth, this.navDesDynamicPadding);
    if (avoidWidth !== INVALID_AVOID_WIDTH) {
      this.defaultAvoidWidth = avoidWidth;
    }
  }

  private sendAvoidWidth(): void {
    if (this.uiExtensionProxy && DeviceUtil.isDevicePc()) {
      this.uiExtensionProxy.send({'eventType' : TITLE_BAR_MARGIN_CHANGE_EVENT,
        'value': {end : LengthMetrics.vp(this.defaultAvoidWidth)}});
    }
  }

  private processReceiveData(data: object): void {
    switch (data?.['action']) {
      case 'settingSearchBack':
        this.settingSearchBack();
        break;
      case 'pop':
        this.pathInfos.pop();
        break;
      default:
        break;
    }
  }

  private settingSearchBack(): void {
    if (AppStorage.get<NavigationMode>('navigationMode') === NavigationMode.Split) {
      emitter.emit({
        eventId: EVENT_ID_SETTING_SEARCH_BACK,
        priority: emitter.EventPriority.IMMEDIATE,
      });
    } else {
      this.pathInfos.pop();
    }
  }

  onNavigationModeChange(): void {
    this.navigationModeParameter = this.navigationMode;
    this.uiExtensionProxy?.send({ 'navigationMode': this.navigationMode });
  }

  onTargetSubRouterChange(): void {
    LogUtil.showInfo(TAG, `onTargetSubRouterChange in ${this.targetSubRouter}`);
    if (!this.targetSubRouter) {
      return;
    }
    if (!this.uiExtensionProxy) {
      LogUtil.showError(TAG, `uiExtensionProxyEmpty`);
      this.consumeTargetSubRouter();
      return;
    }
    this.uiExtensionProxy.send({ 'targetSubRouter': this.targetSubRouter });
    LogUtil.showInfo(TAG, `onTargetSubRouterChange send ${this.targetSubRouter}`);
    this.consumeTargetSubRouter();
  }

  consumeTargetSubRouter(): string {
    let temp = this.targetSubRouter;
    LogUtil.showInfo(TAG, `consumeTargetSubRouter ${temp}`);
    AppStorage.setOrCreate<string>('com_hmos_ouc_all_scene_update_target_sub_router', '');
    return temp;
  }

  aboutToAppear(): void {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.ENTER_SOFTWARE_UPDATES, 'all_scene');
    LogUtil.showInfo(TAG, `aboutToAppear: subUri: ${this.params?.subUri}, config: ${this.params?.config}`);
    this.viewModel.listening(this.recoverController);
    this.consumeTargetSubRouter();
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, `aboutToDisappear`);
    this.viewModel.destroyListening();
  }
}