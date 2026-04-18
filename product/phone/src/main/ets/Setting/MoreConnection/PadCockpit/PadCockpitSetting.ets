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
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';

interface ErrorObject {
  code: number;
  name: string;
  message: string;
}

@Component
export struct PadCockpitSetting {
  @State message: string = 'UIExtensionAbility';
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;
  private TAG: string = 'PadCockpitSetting: ';
  want: Want = {
    bundleName: 'com.ohos.cardistributedassist',
    abilityName: 'SettingsUIExtAbility',
    parameters: { 'ability.want.params.uiExtensionType': 'sys/commonUI',
      'pushParams': (this.params?.config || this.params?.subUri) as string,
      'startReason': this.params?.startReason ?? PageStartModeManager.getInstance().getStartReason(),
    }
  };

  build() {
    NavDestination() {
      Column() {
        UIExtensionComponent(this.want)
          .defaultFocus(true)
          .size({ width: '100%', height: '100%' })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .onRemoteReady((proxy: UIExtensionProxy) => {
            this.message = 'remote ready' + proxy;
            LogUtil.info(`${this.TAG + this.message} UIExtensionAbilityOnRemoteReady`);
          })
          .onReceive((data) => {
            this.message = JSON.stringify(data);
            LogUtil.info(`${this.TAG} UIExtensionAbilityOnReceive`);
          })
          .onResult((data) => {
            this.message = JSON.stringify(data);
            LogUtil.info(`${this.TAG} UIExtensionAbilityOnResult`);
          })
          .onRelease((code) => {
            this.message = 'release code : ' + code;
            LogUtil.info(`${this.TAG + this.message} UIExtensionAbilityOnRelease`);
            this.pathInfos.pop();
          })
          .onError((error: ErrorObject) => {
            this.message = 'onError: ' + error.code;
            LogUtil.info(`${this.TAG + this.message} UIExtensionAbilityOnError`);
          })
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.TAG} aboutToAppear, config: ${this.params?.config}, subUri: ${this.params?.subUri}`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.TAG} aboutToDisappear`);
  }

  onPageShow(): void {
    LogUtil.info(`${this.TAG} onPageShow`);
    DynamicLoader.getInstance().pageTransitionSuccess(this.TAG);
  }

  onPageHide(): void {
    LogUtil.info(`${this.TAG} onPageHide`);
  }
}