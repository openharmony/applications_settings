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

import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EVENT_ID_SETTING_SEARCH_BACK } from '@ohos/settings.common/src/main/ets/event/types';
import { PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { HdsNavDestination, HdsNavDestinationAttribute } from '@kit.UIDesignKit';
/* instrument ignore file */
const TAG: string = 'DistributedConnectSettings : ';

interface ErrorObject {
  code: number;
  name: string;
  message: string;
}

@Component
export struct DistributedConnectSettings {
  @State message: string = 'UIExtensionAbility';
  @Consume('pathInfos') pathInfos: NavPathStack;
  private TAG: string = 'DistributedConnectSettings : ';
  @State params: PushParam | null = null;
  @State startReason: string | null = null;
  @StorageProp('navigationMode') navigationMode: NavigationMode = NavigationMode.Stack;

  build() {
    NavDestination() {
      Column() {
        UIExtensionComponent({
          bundleName: 'com.ohos.callsetting',
          abilityName: 'com.ohos.callsetting.DistributedSettingsAbility',
          parameters: {
            'ability.want.params.uiExtensionType': 'sys/commonUI',
            'startReason': this.startReason,
            'navigationMode': this.navigationMode
          }
        })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .defaultFocus(true)
          .size({ width: '100%', height: '100%' })
          .onRemoteReady((proxy: UIExtensionProxy) => {
            this.message = 'remote ready' + proxy;
            LogUtil.info(`${this.TAG + this.message} UIExtensionAbilityOnRemoteReady`);
          })
          .onResult((data) => {
            this.message = JSON.stringify(data);
            LogUtil.info(`${this.TAG + this.message} UIExtensionAbilityOnResult`);
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
          .onReceive((data) => {
            if (data) {
              LogUtil.info(`${TAG} UIExtensionComponent onReceive`);
              if (data['action'] === 'pop') {
                this.doPopAction();
                LogUtil.info(`${TAG} UIExtensionComponent pop`);
              }
            }
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

  private initStartReason() {
    this.startReason = this.params?.startReason as string;
    if (!this.startReason) {
      try {
        let params = this.params as PageParams;
        if (params.param && params.param['startReason']) {
          this.startReason = params.param['startReason'] as string;
        }
        LogUtil.info(`${this.TAG} getStartReason params ${this.startReason}`);
      } catch (error) {
        LogUtil.error(`${this.TAG} get isFromSearch error: ${error?.code}, message: ${error?.message}`);
      }
    }
  }

  private doPopAction(): void {
    if (this.startReason === 'from_search' &&
      this.navigationMode === NavigationMode.Split) {
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

  aboutToAppear(): void {
    LogUtil.info(`${this.TAG} aboutToAppear`);
    this.initStartReason();
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