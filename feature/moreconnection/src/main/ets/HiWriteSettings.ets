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

import Want from '@ohos.app.ability.Want';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PushParam, Params } from '@ohos/settings.common/src/main/ets/core/controller/Controller';

const TAG: string = 'HiWriteSettings : ';

@Builder
export function HiWriteSettingsLoader($$: Params): void {
  HiWriteSettings({ params: $$ as Object as PushParam });
}

@Component
export struct HiWriteSettings {
  uiExtensionProxy?: UIExtensionProxy;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;
  @State wantParameter: Record<string, Object> = {
    'ability.want.params.uiExtensionType': 'sys/commonUI',
  };
  @StorageProp('com_hmos_ouc_accessory_settings_target_sub_router')
  @Watch('onAccessoryUrlChange') targetSubRouter: string = '';

  build() {
    NavDestination() {
      UIExtensionComponent({
        bundleName: 'com.ohos.hiwrite',
        abilityName: 'com.ohos.hiwrite.MainAbility',
        parameters: this.wantParameter,
      })
        .defaultFocus(true)
        .id('com.ohos.settings.hiwrite')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .onError((error) => {
          LogUtil.info(`${TAG} onError name: ${error.name}; code: ${error.code}; messsage: ${error.message}`);
        })
        .onRemoteReady((proxy) => {
          LogUtil.info(`${TAG} onRemoteReady`);
          this.uiExtensionProxy = proxy;
        })
        .onReceive((data) => {
          LogUtil.info(`${TAG} UIExtensionComponent onReceive action ${data['action']}`);
          if (data) {
            if (data['action'] === 'pop') {
              this.pathInfos.pop();
              LogUtil.info(`${TAG} pop`);
            }
          }
        })
        .size({ width: '100%', height: '100%' })
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

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.setWantParameter(this.params?.config as Record<string, Object>);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  private setWantParameter(params: Record<string, Object> | null): boolean {
    this.wantParameter.macId = params?.macId as number;
    let accessoryUrl: string = params?.accessoryUrl as string;
    if (accessoryUrl) {
      this.wantParameter.accessoryUrl = accessoryUrl;
      this.wantParameter.fromNotify = params?.fromNotify as boolean;
      this.wantParameter.penName = params?.penName as string;
    }
    this.consumeTargetSubRouter();
    return true;
  }

  private onAccessoryUrlChange(): void {
    LogUtil.info(`${TAG} onTargetSubRouterChange in ${this.targetSubRouter}`);
    if (!this.targetSubRouter) {
      return;
    }
    if (!this.uiExtensionProxy) {
      LogUtil.error(`${TAG} uiExtensionProxyEmpty`);
      this.consumeTargetSubRouter();
      return;
    }
    let param: Record<string, Object> = AppStorage.get<Want>('wantParams')?.parameters?.pushParams as Record<string, Object>;
    LogUtil.info(`${TAG} onTargetSubRouterChange send toAccessoryUrl`);
    this.uiExtensionProxy.send({ 'action': 'toAccessoryUrl', 'data': param });
    this.consumeTargetSubRouter();
  }

  private consumeTargetSubRouter(): void {
    LogUtil.info(`${TAG} consumeTargetSubRouter ${this.targetSubRouter}`);
    AppStorage.setOrCreate<string>('com_hmos_ouc_accessory_settings_target_sub_router', '');
  }
}