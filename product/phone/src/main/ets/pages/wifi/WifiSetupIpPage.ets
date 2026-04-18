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

import { KeyboardAvoidMode } from '@ohos.arkui.UIContext';
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { ResourceUtil} from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { UIExtensionSessionUtils } from '@ohos/settings.common/src/main/ets/utils/UIExtensionSessionUtils';
import { WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import { PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { MenuPageComponent } from '@ohos/settings.uikit/src/main/ets/component/MenuPageComponent';
import { PendingIpConfig } from '@ohos/settings.wifi/src/main/ets/model/WifiModel';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { WifiSetupIpModel } from './model/WifiSetupIpModel';

/* instrument ignore file */
@Builder
export function WifiSetupIpPageLoader($$: Params): void {
  WifiSetupIpPage({ pushParam: $$ as Object as PushParam });
}

/**
 * WiFi连接-设置IP界面
 *
 * @since 2023-12-11
 */
@Component
export struct WifiSetupIpPage {
  pushParam?: PushParam;
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @Consume('pathInfos') pathInfos: NavPathStack;
  title: string = ResourceUtil.getStringSync($r('app.string.wifi_ip_settings_title'));

  build() {
    NavDestination() {
      Column() {
        Blank().height($r('app.float.navigation_56'))
        MenuPageComponent({ menuPage: this.pageRoot.menuPage })
          .margin({
          bottom: $r('app.float.navigation_56')
        });
      }
      .size({ width: '100%', height: '100%' })
      .expandSafeArea([SafeAreaType.KEYBOARD]);
    }
    .hideTitleBar(false)
    .title(this.title)
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .padding(({
      top: UIExtensionSessionUtils.calculateTopPaddingIfNeeded(),
      bottom: FontScaleUtils.isExtraLargeFontMode() ? $r('app.float.padding_16') : 0
    }))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
  }

  aboutToAppear(): void {
    if (!this.pushParam?.config && (this.pushParam as PageParams).param) {
      this.pushParam = (this.pushParam as PageParams).param;
    }
    this.pageRoot.aboutToAppear(new WifiSetupIpModel(this.pathInfos, this.pushParam?.config as PendingIpConfig));
  }

  aboutToDisappear(): void {
    this.pageRoot.aboutToDisappear();
  }

  onPageShow(): void {
    this.pageRoot.onPageShow();
    WindowManager.getInstance().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
  }

  onPageHide(): void {
    this.pageRoot.onPageHide();
    WindowManager.getInstance().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);
  }
}