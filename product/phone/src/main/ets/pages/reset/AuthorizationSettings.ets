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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ObservedData, UiExtensionViewModel } from '@ohos/settings.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { ExitAbnormallyComponent } from '@ohos/settings.common/src/main/ets/viewmodel/ExitAbnormallyComponent';
/* instrument ignore file */
const TAG: string = 'AuthorizationPage';
const BUNDLE_NAME: string = 'com.ohos.parentcontrol';
const ABILITY_NAME: string = 'AuthorizationAbility';

@Builder
export function AuthorizationSettingsLoader($$: Params): void {
  AuthorizationSettings();
}

@Component
export struct AuthorizationSettings {
  @State context: Context = getContext(this);
  @State params: PushParam | null = null;
  @State observedData: ObservedData = new ObservedData();
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  @Consume('pathInfos') pageInfoList: NavPathStack;
  private callerIntent: string = '';

  recoverController: CustomDialogController = new CustomDialogController({
    builder: ExitAbnormallyComponent(),
  });

  build() {
    NavDestination() {
      UIExtensionComponent({
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME,
        parameters: {
          // 必须配置，能够解决弹出的输入窗口覆盖密码输入框的问题
          'ability.want.params.IsNotifyOccupiedAreaChange': true,
          // 业务需要携带相应标识或者来源，用于告知家长授权场景
          'callerIntent': this.callerIntent,
          'reconnect': this.observedData.reconnect,
        }
      })
        .defaultFocus(true)
        .onError((error) => {
          LogUtil.info(`${TAG} UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
          this.viewModel.refreshing(error, this.recoverController, BUNDLE_NAME, ABILITY_NAME);
        })
        .onTerminated(()=>{})
        .onReceive((callback) => {
          // 健康使用手机会使用session.sendData将参数返回给业务，业务根据这个结果进行下一步操作
          let result: string = callback['authorizationResult'] as string;
          LogUtil.info(`${TAG}, onReceive: result = ${result}`);
          if (!this.pageInfoList || this.pageInfoList.size() <= 0) {
            LogUtil.error(`${TAG}, onReceive: this.pageInfoList is undefined`);
            return;
          }
          this.pageInfoList.pop(result);
        })
        .backgroundColor('#00000000')
        .width('100%')
        .height('100%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    }
    .id('AuthorizationSettings')
    .backgroundColor('#00000000')
    // 配置此参数后界面为半模态窗口
    .mode(NavDestinationMode.DIALOG)
    .hideTitleBar(true)
    .onShown(() => {
      LogUtil.info(`${TAG} NavDestination onShown`);
    })
    .onHidden(() => {
      LogUtil.info(`${TAG} NavDestination onHidden`);
    });
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.viewModel.listening(this.recoverController);
    this.callerIntent =
      (this.pageInfoList.getParamByName(NavEntryKey.AUTHORIZATION_ENTRY)[0] as Record<string, string>)['callerIntent'];
    this.parseCallerIntent();
  }

  private parseCallerIntent(): void {
    LogUtil.info(`${TAG} parseCallerIntent`);
    if (!this.pageInfoList) {
      LogUtil.error(`${TAG} parseCallerIntent: this.pageInfoList is undefined`);
      return;
    }
    let paramList: Record<string, string>[] =
      this.pageInfoList.getParamByName(NavEntryKey.AUTHORIZATION_ENTRY) as Record<string, string>[];
    if (!paramList || paramList.length <= 0) {
      LogUtil.error(`${TAG} parseCallerIntent: paramList is undefined or length is less than zero`);
      return;
    }
    let record: Record<string, string> | undefined = paramList.pop();
    if (!record) {
      LogUtil.error(`${TAG} parseCallerIntent: record is undefined`);
      return;
    }
    this.callerIntent = record['callerIntent'];
    LogUtil.info(`${TAG} parseCallerIntent: callerIntent = ${this.callerIntent}`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.viewModel.destroyListening();
  }
}