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

import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import {
  PageLifecycleLoadingGroupController
} from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import wifiManager from '@ohos.wifiManager';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';

/* instrument ignore file */
const TAG: string = 'WIFIQRCodeController : ';
const SLOT_ID_UNDEFINED: number = -1;

export class WIFIQRCodeController extends PageLifecycleLoadingGroupController {
  public wifiDeviceConfig?: wifiManager.WifiDeviceConfig;
  public defaultSlotId = SLOT_ID_UNDEFINED;

  static CreateWIFIQRCodeController(menu: SettingsBaseMenu): Controller {
    return new WIFIQRCodeController(menu);
  }

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    if ((menu.extra as wifiManager.WifiDeviceConfig)?.ssid) {
      this.wifiDeviceConfig = menu.extra as wifiManager.WifiDeviceConfig;
      const securityType = WifiUtils.securityType2str(this.wifiDeviceConfig?.securityType);
      this.menu.searchKeyWords = `WIFI:T:${securityType};S:${this.wifiDeviceConfig.ssid};P:${this.wifiDeviceConfig.preSharedKey};;`
      LogUtil.info(`${TAG} searchKeyWords ssid =${WifiUtils.getLogSsidString(this.wifiDeviceConfig.ssid)}`);
    }
  }

  aboutToAppear(): void {
    super.aboutToAppear();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
  }

  updateStatus(): void {

  }

}