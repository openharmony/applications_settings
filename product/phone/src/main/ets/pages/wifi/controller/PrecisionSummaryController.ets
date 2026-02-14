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

import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { WifiUtils, WLAN_SCAN_KEY } from '@ohos/settings.wifi';

/* instrument ignore file */
const TAG: string = 'phonePrecisionSummaryController : ';

/**
 * 提高精确度文字 跳转控制器
 *
 */
export class PrecisionSummaryController extends MenuController {
  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }
  static CreatePrecisionSummaryController(menu: SettingsBaseMenu): Controller {
    return new PrecisionSummaryController(menu);
  }

  public wifiStatus : boolean = false;

  aboutToAppear(): void {
    super.aboutToAppear();
    this.wifiStatus = WifiUtils.isWifiActive();
    if (this.wifiStatus === true) {
      LogUtil.info(`${TAG} this.wifiStatus =  ${this.wifiStatus}`);
      this.setVisible(false);
    } else {
      this.setVisible(true);
    }
  }
  /**
   * 注册事件监听时使用
   */
  protected registerDataChange(): void {
    this.registerControllerDataChange(WLAN_SCAN_KEY);
    WifiUtils.wifiStateChangeOn(TAG, this.onWifiStateChange);
  }

  protected unRegisterDataChange(): void {
    this.unRegisterControllerDataChange(WLAN_SCAN_KEY);
    WifiUtils.wifiStateChangeOff(TAG, this.onWifiStateChange);
  }
  public onWifiStateChange = (state: number): void => {
    LogUtil.info(`${TAG} wifi state change : ${state}`);
    if (state === 0 || state === 3) { // 关闭
      this.setVisible(true);
    }
    if (state === 1 || state === 2) { // 开启
      this.setVisible(false);
    }
  }
}
