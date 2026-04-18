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

import systemparameter from '@ohos.systemparameter';
import { WifiUtils } from '@ohos/settings.wifi';
import emitter from '@ohos.events.emitter';
import { BusinessError } from '@ohos.base';
import systemParameterEnhance from '@ohos.systemParameterEnhance';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { MenuPageComponent } from '@ohos/settings.uikit/src/main/ets/component/MenuPageComponent';
import { SYSTEM_ROLLBACK_WANT } from '@ohos/settings.uikit/src/main/ets/utils/Consts';
import { EnableUtils } from '@ohos/settings.common/src/main/ets/utils/baseutils/EnableUtils';
import {
  EVENT_ID_WIRELESS_STATE_NUM,
  EVENT_ID_WIRELESS_TYPE_NUM
} from '@ohos/settings.common/src/main/ets/event/types';
import { HiSysSystemAndUpdatesEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { SystemParamUtils } from '@ohos/settings.common/src/main/ets/screenReader/utils/SystemParamUtils';
import { DeveloperOptionsPage } from './model/DeveloperOptionsPage';

/* instrument ignore file */
const TAG: string = 'DeveloperOptionsSettings : ';

@Builder
export function DeveloperOptionsSettingsLoader($$: Params): void {
  DeveloperOptionsSettings({ params: $$ as Object as PushParam });
}

@Component
export struct DeveloperOptionsSettings {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  title: string = ResourceUtil.getStringSync($r('app.string.developer_options_settings_title'));
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;
  @StorageProp('developerOptionsSettingsSystemRollback')
  @Watch('checkSystemRollBackFlagAndProcess') systemRollback: number = 0;
  @StorageProp('navigationMode') navigationMode: NavigationMode | undefined = NavigationMode.Stack;
  build() {
    NavDestination() {
      Column() {
        // Blank().height($r('app.float.navigation_56'))
        MenuPageComponent({ menuPage: this.pageRoot.menuPage })//.margin({bottom: $r('app.float.navigation_56')});
      }
      .size({ width: '100%'})
    }
    .hideTitleBar(false)
    .title(this.title)
    .title(this.title)
    // .titleBar({content: {title: {mainTitle: this.title}}})
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
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.ENTER_DEVELOPER_OPTIONS);
    LogUtil.info(`${TAG} aboutToAppear`);
    try {
      let status: string = systemParameterEnhance.getSync('const.security.developermode.state', '0');
      LogUtil.info(`${TAG} const.security.developermode.state success: ${status}`);
      this.pageRoot
        .aboutToAppear(new DeveloperOptionsPage(this.pathInfos, this.params as PushParam, JSON.parse(status)));
      if (AppStorage.get<number>('developerOptionsSettingsSystemRollback') === 1) {
        this.checkSystemRollBackFlagAndProcess();
      }
      EnableUtils.setItemEnable(this.pageRoot.menuPage);
    } catch (err) {
      LogUtil.error(`${TAG} const.security.developermode.state fial: ${err}`);
    }

  }

  async getWifiState() {
    try {
      let wifiName = await WifiUtils.wifiLinkedInfo();
      if (!wifiName) {
        this.setEmit()
        return
      }
    } catch (err) {
      LogUtil.error(`${TAG} WifiUtils.wifiLinkedInfo fail ${err}`)
      this.setEmit()
      return
    }
    try {
      let app: number | undefined = AppStorage.get('wifi_ip_mode')
      LogUtil.info(`${TAG} get wifi_ip_mode ${app}`)
      let ipAddress = await WifiUtils.wifiIpAddress();
      if (ipAddress !== app) {
        this.setEmit()
      }
    } catch (err) {
      LogUtil.error(`ipAddress app fail  ${err}`)
    }
  }

  async setEmit() {
    let wirelessState: string = SystemParamUtils.getSystemParam('persist.hdc.mode.tcp', 'disable');
    LogUtil.showInfo(TAG, `wirelessState: ${wirelessState}`);
    if (wirelessState !== 'enable') {
      return;
    }
    let mode: Promise<void> = systemparameter.set('persist.hdc.mode', '');
    mode.then(async (value: void) => {
      await systemparameter.set('persist.hdc.mode.tcp', 'disable');
      emitter.emit({
        eventId: EVENT_ID_WIRELESS_STATE_NUM,
      }, { data: { isChecked: false } });
      emitter.emit({ eventId: EVENT_ID_WIRELESS_TYPE_NUM }, { data: { isChecked: false } });
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} ${err.code} BusinessError`);
    });
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
  }

  private checkSystemRollBackFlagAndProcess(): void {
    LogUtil.info(`${TAG} systemRollback flag :${this.systemRollback}`);
    if (this.systemRollback === 1) {
      AbilityUtils.startServiceExtensionForResult(SYSTEM_ROLLBACK_WANT, () => {
        LogUtil.info(`${TAG} after startServiceExtensionForResult`);
      });
      AppStorage.setOrCreate<number>('developerOptionsSettingsSystemRollback', 0);
    }
  }
}

