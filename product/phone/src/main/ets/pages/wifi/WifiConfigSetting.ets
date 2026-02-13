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

import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { UIExtensionSessionUtils } from '@ohos/settings.common/src/main/ets/utils/UIExtensionSessionUtils';
import { AccessPoint } from '@ohos/settings.wifi/src/main/ets/model/WifiModel';
import { MenuPageComponent } from '@ohos/settings.uikit/src/main/ets/component/MenuPageComponent';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import { PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { WifiConfigModel } from './model/WifiConfigModel';

/* instrument ignore file */
const TAG: string = 'WifiConfigSetting:';

@Builder
export function WifiConfigSettingLoader($$: Params): void {
  WifiConfigSetting({ pushParam: $$ as Object as PushParam });
}

/**
 * WiFi 配置修改
 *
 * @since 2024-02-04
 */
@Component
export struct WifiConfigSetting {
  pushParam?: PushParam;
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @Consume('pathInfos') pathInfos: NavPathStack;
  title: string = ResourceUtil.getStringSync($r('app.string.wifi_proxy_settings_title'));

  build() {
    NavDestination() {
      Column() {
        MenuPageComponent({ menuPage: this.pageRoot.menuPage });
      }
      .size({ width: '100%', height: '100%' })
    }
    .hideTitleBar(false)
    .title((this.pushParam?.config as AccessPoint)?.ssid)
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
    if (this.pushParam && !this.pushParam?.config && (this.pushParam as PageParams).param) {
      LogUtil.info(`${TAG} config is empty.`);
      this.pushParam.config = (this.pushParam as PageParams).param as AccessPoint;
    }
    LogUtil.info(`${TAG} title: ${WifiUtils.getLogSsidString((this.pushParam?.config as AccessPoint)?.ssid)}`);
    this.pageRoot.aboutToAppear(new WifiConfigModel((this.pushParam?.config as AccessPoint), this.pathInfos));
  }

  aboutToDisappear(): void {
    this.pageRoot.aboutToDisappear();
  }

  onPageShow(): void {
    this.pageRoot.onPageShow();
  }

  onPageHide(): void {
    this.pageRoot.onPageHide();
  }
}