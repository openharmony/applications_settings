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

/* instrument ignore file */
import emitter from '@ohos.events.emitter';
import systemParameterEnhance from '@ohos.systemParameterEnhance';
import { EVENT_ID_APP_TAB_CHANGE_EVENT } from '@ohos/settings.common/src/main/ets/event/types';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageConfig } from '@ohos/settings.common/src/main/ets/framework/common/PageConfig';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import {
  HiSysApplicationsAndServicesEventGroup
} from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { AppUtils } from '@ohos/settings.application/src/main/ets/AppUtils';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';

const TAG = 'CustomMenuComponent';
const DELIVER_START_FINISHED_CODE = '1000';
const DELIVER_START_INVALID_CODE = '0';
const CONTAINER_START_PHASE = 'hmos_fusion_mgr.container.start.phase';
const CONTAINER_IS_EXIT = 'persist.hmos_fusion_mgr.ctl.support_hmos';
const CONTAINER_APP_INSTALLED_STATUS = 'container_app_installed_status';
const CONTAINER_COMPATIBLE_VERSION = 'persist.container.compatible.version';
const COMPATIBLE_VERSION_NUMBER = 1;

@Component
export struct CustomMenuComponent {
  @State tabsIndex: number = 0;
  private isDeviceEmulator: boolean = DeviceUtil.isDeviceEmulator();
  appTabChangeEventCallBack = (eventData: emitter.EventData) => {
    LogUtil.info(`${TAG} appTabChangeEventCallBack tableIndex: ${eventData.data?.tabIndex}`);
    this.tabsIndex = eventData.data?.tabIndex;
    LogUtil.info(`${TAG} appTabChangeEventCallBack tableIndex: ${this.tabsIndex}`);
  };

  build() {
    Menu() {
      if (this.tabsIndex === 0) {

        // MenuItemGroup() {
          MenuItem({ content: $r('app.string.more_application_text') })
            .onClick(() => {
              this.onMoreAppMenuClick();
            })
            .contentFont({
              size: $r('sys.float.Body_L'),
              weight: FontWeight.Medium,
            })
            .contentFontColor($r('sys.color.font_primary'))
        // }
      }
    }
    .width(PageConfig.getInstance().getMenuStyle()?.width as number + 8)
  }

  private onMoreAppMenuClick(): void {
    PageRouter.push(NavEntryKey.MORE_APPLICATION_ENTRY);
  }

  aboutToAppear(): void {
    LogUtil.showInfo(TAG, 'aboutToAppear');
    EventBus.getInstance().on(EVENT_ID_APP_TAB_CHANGE_EVENT, this.appTabChangeEventCallBack);
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'aboutToDisappear');
    EventBus.getInstance().detach(EVENT_ID_APP_TAB_CHANGE_EVENT, this.appTabChangeEventCallBack);
  }
}