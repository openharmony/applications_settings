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
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { MenuPageComponent } from '@ohos/settings.uikit';
import { OtherInputDetail } from './model/OtherInputDetail';
import { InputPushParam } from './controller/inputSettingController';

const TAG: string = 'OtherInputDetailSettings : ';

@Builder
export function OtherInputDetailSettingsLoader($$: Params): void {
  OtherInputDetailSettings({ params: $$ as Object as PushParam });
}


@Component
export struct OtherInputDetailSettings {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @State params: PushParam | null = null;
  @Consume('pathInfos') pathInfos: NavPathStack;
  userId: string = ''

  build() {
    NavDestination() {
      Column() {
        Blank().height($r('app.float.navigation_56'))
        MenuPageComponent({ menuPage: this.pageRoot.menuPage }).margin({bottom: $r('app.float.navigation_56')});
      }
      .size({ width: '100%', height: '100%' })
    }
    .hideTitleBar(false)
    .title((this.params?.config as InputPushParam).title ?? '')
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .onShown(() => {
      LogUtil.info(`${TAG} onPageShow`);
      this.onPageShow();
    })
    .onHidden(() => {
      LogUtil.info(`${TAG} onPageHide`);
      this.onPageHide();
    })
  }

  aboutToAppear(): void {
    this.pageRoot.aboutToAppear(new OtherInputDetail((this.params?.config as InputPushParam).extra,
      (this.params?.config as InputPushParam).title));
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

