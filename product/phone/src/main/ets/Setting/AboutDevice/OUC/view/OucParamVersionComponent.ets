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
import { emitter } from '@kit.BasicServicesKit';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { EVENT_ID_SETTING_SEARCH_BACK } from '@ohos/settings.common/src/main/ets/event/types';
import { HiSysAboutDeviceEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

const TAG: string = 'OucParamVersionComponent: ';

@Component
export struct OucParamVersionComponent {
  uiExtensionProxy?: UIExtensionProxy;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageProp('com_hmos_ouc_param_version_settings_target_sub_router')
  @Watch('onTargetSubRouterChange') targetSubRouter: string = '';
  @State params: PushParam | null = null;
  @StorageProp('navigationMode') @Watch('onNavigationModeChange')
  navigationMode: NavigationMode = NavigationMode.Stack;
  private navigationModeParameter: NavigationMode = this.navigationMode;

  build() {
    NavDestination() {
      UIExtensionComponent({
        bundleName: 'com.ohos.ouc',
        abilityName: 'com.ohos.ouc.ParamAbility',
        uri: 'com_hmos_ouc_param_version_settings',
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'isShowBack': (this.params?.config as string)?.includes('isShowBack:false') ? false : true,
          'targetSubRouter': this.params?.config as string ?? this.params?.subUri,
          'startReason': this.params?.startReason ?? PageStartModeManager.getInstance().getStartReason(),
          'navigationMode': this.navigationModeParameter,
        },
      })
        .defaultFocus(true)
        .onRemoteReady((proxy) => {
          this.uiExtensionProxy = proxy;
        })
        .onReceive((data) => {
          LogUtil.info(`${TAG} UIExtensionComponent onReceive ${data?.['action']}`);
          this.processReceiveData(data);
        })
        .onRelease(() => {
          this.pathInfos.pop();
          LogUtil.info(`${TAG} onRelease pathInfos.size ${this.pathInfos.size()}`);
        })
        .size({ width: '100%', height: '100%' })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      LogUtil.info(`${TAG} NavDestination onShown`);
    })
    .onHidden(() => {
      LogUtil.info(`${TAG} NavDestination onHidden`);
    })
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
    LogUtil.info(`${TAG} onTargetSubRouterChange in ${this.targetSubRouter}`);
    if (!this.targetSubRouter) {
      return;
    }
    if (!this.uiExtensionProxy) {
      LogUtil.error(`${TAG} uiExtensionProxyEmpty`);
      this.consumeTargetSubRouter();
      return;
    }
    this.uiExtensionProxy.send({ 'targetSubRouter': this.targetSubRouter });
    LogUtil.info(`${TAG} onTargetSubRouterChange send ${this.targetSubRouter}`);
    this.consumeTargetSubRouter();
  }

  consumeTargetSubRouter(): string {
    let temp = this.targetSubRouter;
    LogUtil.info(`${TAG} consumeTargetSubRouter ${temp}`);
    AppStorage.setOrCreate<string>('com_hmos_ouc_param_version_settings_target_sub_router', '');
    return temp;
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutDeviceEventGroup.ENTER_PARAMETER_VERSION_ENTRY);
    LogUtil.info(`${TAG} aboutToAppear: subUri: ${this.params?.subUri}, config: ${this.params?.config}`);
    this.consumeTargetSubRouter();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }
}