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

import { SwitchMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { PageLifecycleObserverInterface } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import wifiManager from '@ohos.wifiManager';

/* instrument ignore file */
const TAG: string = 'phoneWifiScanController : ';
const WLAN_SCAN_KEY: string = 'wlan_scan';

/**
 * Wlan 扫描开关控制器
 *
 */
export class WifiScanController extends SwitchMenuController implements PageLifecycleObserverInterface {
  static CreateWifiScanController(menu: SettingsBaseMenu): Controller {
    return new WifiScanController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
  }

  onPageShow(): void {
    this.updateCheckedState();
  }

  onPageHide(): void {
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    SettingsDataUtils.setSettingsData(WLAN_SCAN_KEY, isChecked ? '1' : '0');
    this.publishDataChange(isChecked);
    try {
      wifiManager.setScanAlwaysAllowed(isChecked);
      LogUtil.info(`${TAG} setScanAlwaysAllowed: ${isChecked}`);
    } catch (err) {
      LogUtil.error(`${TAG} setScanAlwaysAllowed: err ${err}`);
    }
    this.updateStatus();
    return true;
  }

  /**
   * 返回开关的实时状态
   */
  protected updateCheckedState(): boolean {
    try {
      let state = wifiManager.getScanAlwaysAllowed();
      LogUtil.info(`${TAG} getScanAlwaysAllowed: ${state}`);
      return state;
    } catch (err) {
      LogUtil.error(`${TAG} getScanAlwaysAllowed: err ${err}`);
    }
    return true;
  }

  updateStatus(): void {
    let isChecked = this.updateCheckedState();
    this.setChecked(isChecked);
    this.refreshUi();
  }
}
