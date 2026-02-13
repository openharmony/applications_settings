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
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { BottomMenuPageComponent } from '@ohos/settings.uikit/src/main/ets/component/MenuPageComponent';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { ResetNetPage } from './model/ResetNetPage';
import { HiSysRelocateEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

const TAG: string = 'ResetNetSettings : ';

/**
 * Reset network settings
 *
 * @author yudenggao
 * @since 2023-08-29
 */
@Component
export struct ResetNetSettings {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  title: string = ResourceUtil.getStringSync($r('app.string.reset_net_title'));
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;
  @StorageProp('navigationMode') navigationMode: NavigationMode | undefined = NavigationMode.Stack;

  build() {
    NavDestination() {
      Column() {
        Blank().height($r('app.float.navigation_56'))
        BottomMenuPageComponent({ menuPage: this.pageRoot.menuPage }).margin({bottom: $r('app.float.navigation_56')});
      }
      .size({ width: '100%', height: '100%' })
    }
    .hideTitleBar(false)
    .title(this.title)
    .hideBackButton(this.navigationMode === NavigationMode.Split && this.pathInfos.size() === 1)
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.pageRoot.aboutToAppear(new ResetNetPage(this.pathInfos, this.params as PushParam));
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
  }

  onPageShow(): void {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysRelocateEventGroup.ENTER_RESTORE_NETWORK_ENTRY);
    LogUtil.info(`${TAG} onPageShow`);
    this.pageRoot.onPageShow();
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.pageRoot.onPageHide();
  }
}

