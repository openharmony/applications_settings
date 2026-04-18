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

import window from '@ohos.window';
import { KeyboardAvoidMode } from '@ohos.arkui.UIContext';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { PushParam, Params } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { MenuPageComponent } from '@ohos/settings.uikit/src/main/ets/component/MenuPageComponent';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { UIExtensionSessionUtils } from '@ohos/settings.common/src/main/ets/utils/UIExtensionSessionUtils';
import { WifiEntryParams } from './controller/WifiEntryController';
import { WifiPasswordPage } from './model/WifiPasswordPage';

/* instrument ignore file */
const TAG: string = 'WifiPasswordSettings : ';

@Builder
export function WifiPasswordSettingsLoader($$: Params): void {
  WifiPasswordSettings({ params: ($$ as object) as PushParam });
}

@Component
export struct WifiPasswordSettings {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @State params?: PushParam = undefined;
  @Consume('pathInfos') pathInfos: NavPathStack;

  build() {
    NavDestination() {
      Column() {
        MenuPageComponent({ menuPage: this.pageRoot.menuPage });
      }
      .size({ width: '100%', height: '100%' })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(false)
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .title((this.params?.config as WifiEntryParams)?.config?.ssid)
    // .titleBar({content: {title: {mainTitle: (this.params?.config as WifiEntryParams)?.config?.ssid}}})
    .padding(({ top: UIExtensionSessionUtils.calculateTopPaddingIfNeeded() }))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    if (!this.params?.config && (this.params as PageParams).param) {
      LogUtil.info(`${TAG} config is empty.`);
      this.params = (this.params as PageParams).param;
    }
    this.pageRoot.aboutToAppear(new WifiPasswordPage(this.params, this.pathInfos));
    PasswordUtil.setWindowPrivacyMode((AppStorage.get<window.WindowStage>('windowStage') as
    window.WindowStage), true);
    PasswordUtil.setSessionPrivacyMode(true);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
    PasswordUtil.setWindowNonPrivacyModeIfNeed((AppStorage.get<window.WindowStage>('windowStage') as
    window.WindowStage), this.pathInfos);
    PasswordUtil.setSessionPrivacyMode(false);
  }

  onPageShow(): void {
    const ssid = WifiUtils.getLogSsidString((this.params?.config as WifiEntryParams)?.config?.ssid);
    LogUtil.info(`${TAG} onPageShow ssid:${ssid}`);
    this.pageRoot.onPageShow();
    DynamicLoader.getInstance().pageTransitionSuccess(TAG);
    this.getUIContext()?.setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.pageRoot.onPageHide();
    this.getUIContext()?.setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);
  }
}