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

import { ObservedData, UiExtensionViewModel } from '@ohos/settings.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { ExitAbnormallyComponent } from '@ohos/settings.common/src/main/ets/viewmodel/ExitAbnormallyComponent';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { Params } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { EnterpriseDeviceManagementPage } from './model/EnterpriseDeviceManagementPage';

const TAG: string = 'EnterpriseDeviceManagementSettings : ';
const BUNDLE_NAME: string = 'com.ohos.adminprovisioning';
const ABILITY_NAME: string = 'AdminUIExtensionAbility';

@Builder
export function EnterpriseDeviceManagementSettingsLoader($$: Params): void {
  EnterpriseDeviceManagementSettings();
}

@Component
export struct EnterpriseDeviceManagementSettings {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @State observedData: ObservedData = new ObservedData();
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  @Consume('pathInfos') pathInfos: NavPathStack;
  uiExtensionProxy?: UIExtensionProxy;

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
          'reconnect': this.observedData.reconnect,
        }
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
            if (data['action'] === 'pop') {
              this.pathInfos.pop();
              LogUtil.info(`${TAG} pop`);
            }
          }
        })
        .size({ width: '100%', height: '100%' });
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    });
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.viewModel.listening(this.recoverController);
    this.pageRoot.aboutToAppear(new EnterpriseDeviceManagementPage());
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
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

