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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { SettingToggleState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { WifiUtils } from '../../WifiUtils';

const TAG: string = 'phoneWifiScanController : ';
const WLAN_SCAN_KEY: string = 'wlan_scan';

export class WifiScanController implements ComponentControl {
  private compId: string = '';
  private onToggleChange = (state: SettingToggleState) => {
    let isChecked = state.state;
    SettingsDataUtils.setSettingsData(WLAN_SCAN_KEY, isChecked ? '1' : '0');
    WifiUtils.setScanAlwaysAllowed(isChecked);
  }

  init(param?: object | undefined): void {
    LogUtil.info(`${TAG} WifiScanController init`);
    if (param) {
      this.compId = (param as CompCtrlParam).compId;
    }
    EventBus.getInstance().on(`${this.compId}.toggle`, this.onToggleChange);
  }

  destroy(): void {
    LogUtil.info(`${TAG} WifiScanController destroy`);
    EventBus.getInstance().off(`${this.compId}.toggle`);
  }

  onPageShow(): void {
  }

  onPageHide(): void {
  }
}