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
import { ResourceUtil} from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { LogUtil} from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { UIExtensionSessionUtils } from '@ohos/settings.common/src/main/ets/utils/UIExtensionSessionUtils';
import { MenuPageComponent } from '@ohos/settings.uikit/src/main/ets/component/MenuPageComponent';
import { WifiPrecisionPage } from './model/WifiPrecisionPage';

const TAG: string = 'phoneWifiPrecisionSetting : ';

@Builder
export function WifiPrecisionSettingLoader($$: Params): void {
  WifiPrecisionSetting({ params: ($$ as object) as PushParam });
}

@Component
export struct WifiPrecisionSetting {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @State params?: PushParam | null = null;
  title: string = ResourceUtil.getStringSync($r('app.string.wifi_precision_title'));
  build() {
    NavDestination() {
      Column() {
        MenuPageComponent({ menuPage: this.pageRoot.menuPage })
      }
      .size({ width: '100%', height: '100%' })
    }
    .hideTitleBar(false)
    .title(this.title)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .padding(({ top: UIExtensionSessionUtils.calculateTopPaddingIfNeeded() }))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() =>{
      this.onPageHide();
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.pageRoot.aboutToAppear(new WifiPrecisionPage());
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
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

