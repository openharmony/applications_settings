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
import settings from '@ohos.settings';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  ComponentControl,
  CompCtrlParam,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ItemResultType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
  SettingToggleState,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import {
  WIFI_CLOUD_SECURITY_CHECK,
  WIFI_CLOUD_SECURITY_ENABLED,
  WIFI_CLOUD_SECURITY_DISABLED
} from '@ohos/settings.common/src/main/ets/utils/Consts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { HiSysAboutBluetoothEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { EventResultConsts } from '@ohos/settings.common/src/main/ets/systemEvent/EventResultConsts';
import { wifiTracker } from '../../WifiTracker';
import { WifiManager } from '../../WifiManager';

const TAG = 'WifiSecuritySwitchController: ';

/**
 * Wifi WLAN安全检查控制器
 *
 * @since 2025-05-23
 */
export class WifiSecuritySwitchController implements ComponentControl {
  private isChecked: boolean = true;
  private compId: string = '';
  private toggleStateChangeEventCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleModel is invalid`);
      return;
    }
    let isChecked: boolean = toggleState.state;
    LogUtil.info(`${TAG} toggleState: ${isChecked}`);
    if (this.isChecked === isChecked) {
      LogUtil.warn(`${TAG} setChecked failed.`);
      return;
    }
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutBluetoothEventGroup.WIFI_SECURITY_SWITCH,
      isChecked ? EventResultConsts.SWITCH_ON : EventResultConsts.SWITCH_OFF);
    SettingsDataUtils.setSettingsDataDomain(WIFI_CLOUD_SECURITY_CHECK,
      isChecked ? WIFI_CLOUD_SECURITY_ENABLED : WIFI_CLOUD_SECURITY_DISABLED,
      settings.domainName.DEVICE_SHARED);
    WifiManager.getInstance().setWifiSecuritySwitchStatus(isChecked);
    this.setChecked(isChecked);
  };

  init(compParam: CompCtrlParam): void {
    if (!compParam) {
      LogUtil.info(`${TAG} init failed, param is empty.`);
      return;
    }
    this.compId = (compParam as CompCtrlParam).compId;
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
    SettingsDataUtils.getSettingsDataAsync(WIFI_CLOUD_SECURITY_CHECK, WIFI_CLOUD_SECURITY_DISABLED,
      settings.domainName.DEVICE_SHARED).then(res => {
      let isChecked: boolean = res === WIFI_CLOUD_SECURITY_ENABLED;
      WifiManager.getInstance().setWifiSecuritySwitchStatus(isChecked);
      LogUtil.info(`${TAG} init : ${isChecked}`);
      this.setChecked(isChecked);
    })
  }

  private setChecked(isChecked: boolean): void {
    this.isChecked = isChecked;
    LogUtil.info(`${TAG} setChecked, refresh : ${this.isChecked} compId:${this.compId}`);
    notifyCompStateChange(this.compId, new Map<SettingStateType, SettingResultState>(
      [[SettingStateType.STATE_TYPE_ITEM_RESULT, {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: {
          state: isChecked
        }
      } as SettingResultState]]
    ));
  }

  destroy(): void {
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeEventCallback);
  }
}