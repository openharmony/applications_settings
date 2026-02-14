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

import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageLoader, PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
/* instrument ignore file */
const TAG: string = 'phoneApplicationPermissionSettings : ';

@Builder
export function ApplicationPermissionSettingsLoader($$: Params): void {
  ApplicationPermissionSettings({ params: ($$ as PageParams)?.param as PushParam });
}

@Component
export struct ApplicationPermissionSettings {
  @Consume('pathInfos') pathInfos: NavPathStack;
  uiExtensionProxy?: UIExtensionProxy;
  params: PushParam | null = null;

  build() {
    NavDestination() {
      Column() {
        UIExtensionComponent({
          bundleName: 'com.ohos.security.privacycenter',
          abilityName: 'SettingsPermissionAbility',
          parameters: {
            'ability.want.params.uiExtensionType': 'sys/commonUI',
            'uri': this.params?.config as string,
            'pushParams': (this.params?.config || this.params?.subUri) as string,
            'startReason': this.params?.startReason ?? PageStartModeManager.getInstance().getStartReason(),
            'bundleName': this.params?.bundleName as string,
          }
        })
          .defaultFocus(true)
          .onRemoteReady((proxy) => {
            this.uiExtensionProxy = proxy;
          })
          .onError((error) => {
            LogUtil.info(`${TAG} UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
           this.pathInfos.pop();
          })
          .onTerminated(()=>{})
          .onReceive((data) => {
            LogUtil.info(`${TAG} UIExtensionComponent onReceive`);
            if (data) {
              if (data['action'] === 'exit') {
                this.pathInfos.pop()
              }
            }
          })
          .size({ width: '100%', height: '100%' })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
      }
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
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }
}

function customPage(): SettingPageModel {
  return {
    id: 'ApplicationPermission',
    url: NavEntryKey.APPLICATION_PERMISSION_SETTINGS_ENTRY,
    type: PageType.PAGE_TYPE_CUSTOM,
    title: 'ApplicationPermission',
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.APPLICATION_PERMISSION_SETTINGS_ENTRY, {
  configGenerator: customPage,
  pageBuilder: wrapBuilder(ApplicationPermissionSettingsLoader),
});