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

import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { MenuPageComponent } from '@ohos/settings.uikit/src/main/ets/component/MenuPageComponent';
import settings from '@ohos.settings';
import bundleManager from '@ohos.bundle.bundleManager';
import emitter from '@ohos.events.emitter';
import { EVENT_ID_ENTERPRISE_MENU_HIDE } from '@ohos/settings.common/src/main/ets/event/types';
import { DeviceAndApplicationPage } from './model/DeviceAndApplicationPage';

const TAG: string = 'DeviceAndApplicationSettings : ';

/**
 * device and application settings
 */
@Builder
export function DeviceAndApplicationLoader($$: Params): void {
  DeviceAndApplicationSettings({ params: $$ as Object as PushParam });
}

@Component
export struct DeviceAndApplicationSettings {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  title: string = ResourceUtil.getStringSync($r('app.string.enterprise_device_and_application_management'));
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;

  build() {
    NavDestination() {
      Column() {
        Blank().height($r('app.float.navigation_56'))
        MenuPageComponent({ menuPage: this.pageRoot.menuPage }).margin({bottom: $r('app.float.navigation_56')});
      }
      .size({ width: '100%', height: '100%' })
    }
    .hideTitleBar(false)
    .title(this.title)
    // .titleBar({content: {title: {mainTitle: this.title}}})
    .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
  }

  private getDeveloperInfoArray(): boolean {
    try {
      return bundleManager.getDeveloperIds(bundleManager.AppDistributionType.ENTERPRISE).length !== 0;
    } catch (err) {
      LogUtil.error(`${TAG} bundleManager.getDeveloperIds fail: ${err.message}`);
      return false;
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.pageRoot.aboutToAppear(new DeviceAndApplicationPage(this.params as PushParam));
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.pageRoot.onPageShow();
    DynamicLoader.getInstance().pageTransitionSuccess(TAG);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.pageRoot.onPageHide();
    const COM_ENTERPRISE_ENTERPRISE_DEVICE_MANAGER_DISPLAY: string = 'com.enterprise.enterprise_device_manager_display';
    let context: Context = AppStorage.get<Context>('pageContext') as Context;
    let deviceManagerDisplay: string = 'false';
    try {
      deviceManagerDisplay = settings.getValueSync(context,
        COM_ENTERPRISE_ENTERPRISE_DEVICE_MANAGER_DISPLAY, 'false');
    } catch (e) {
      LogUtil.error(`${TAG} settings getValueSync err`);
    }
    if (deviceManagerDisplay === 'false' && !this.getDeveloperInfoArray()) {
      emitter.emit({ eventId: EVENT_ID_ENTERPRISE_MENU_HIDE });
    }
  }
}

