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

import wifiManager from '@ohos.wifiManager';
import {
  Controller,
  LogUtil,
  PageLifecycleMenuGroupController,
  SettingsBaseMenu,
  SettingsDataUtils,
} from '@ohos/settings.common/index';
import { HiSysWlanEvenGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { wifiTracker } from '../WifiTracker';

const TAG: string = 'WifiDeleteButtonController';
const SMART_HOTSPOT_KEY: string = 'smartHotSpot';

/**
 * wifi 删除控制器
 *
 * @since 2024-04-12
 */
export class WifiDeleteButtonController extends PageLifecycleMenuGroupController {
  static CreateDeleteButtonController(menu: SettingsBaseMenu): Controller {
    return new WifiDeleteButtonController(menu);
  }

  public config?: wifiManager.WifiDeviceConfig;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    if ((menu.extra as wifiManager.WifiDeviceConfig)?.ssid) {
      this.config = menu.extra as wifiManager.WifiDeviceConfig;
    } else {
      LogUtil.warn(`${TAG} invalid config for delete controller.`);
    }
  }

  public onMenuClick(): boolean {
    HiSysEventUtil.reportDefaultBehaviorEvent(HiSysWlanEvenGroup.DELETE_CONNECTED_WLAN);
    LogUtil.info(`${TAG} start to removeWifiDevice`);
    wifiTracker.removeWifiDevice(this.config as wifiManager.WifiDeviceConfig);
    AppStorage.SetOrCreate<string>(SMART_HOTSPOT_KEY, '');
    SettingsDataUtils.setSettingsData(SMART_HOTSPOT_KEY, '');
    this.menu.pathInfos?.pop();
    return true;
  }
}