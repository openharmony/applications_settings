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

import Window from '@ohos.window';
import { KeyboardAvoidMode } from '@ohos.arkui.UIContext';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Params } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { UIExtensionSessionUtils } from '@ohos/settings.common/src/main/ets/utils/UIExtensionSessionUtils';
import { MenuPageComponent } from '@ohos/settings.uikit/src/main/ets/component/MenuPageComponent';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { AddOtherWifiModel } from './model/AddOtherWifiModel';

const TAG: string = 'AddOtherWifiPage : ';

@Builder
export function AddOtherWifiPageLoader($$: Params): void {
  AddOtherWifiPage();
}

/**
 * 添加其他网络界面Page
 *
 * @since 2023-11-09
 */
@Component
export struct AddOtherWifiPage {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @Consume('pathInfos') pathInfos: NavPathStack;
  title: string = ResourceUtil.getStringSync($r('app.string.wifi_add_wifi'));

  build() {
    NavDestination() {
      Column() {
        MenuPageComponent({ menuPage: this.pageRoot.menuPage });
      }
      .size({ width: '100%', height: '100%' })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(false)
    .title(this.title)
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
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
    this.pageRoot.aboutToAppear(new AddOtherWifiModel(this.pathInfos));
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
    // 退出这个页面的时候，取消掉截屏禁用
    PasswordUtil.setWindowPrivacyMode((AppStorage.get<Window.WindowStage>('windowStage') as
    Window.WindowStage), false);
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.pageRoot.onPageShow();
    this.getUIContext()?.setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.pageRoot.onPageHide();
    this.getUIContext()?.setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);
  }
}