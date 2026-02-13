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

import access from '@ohos.bluetooth.access';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import {
  SETTINGS_DATA_COLLABORATION_RECOMMEND_SERVICE_SWITCH,
  SWITCH_OFF_VAL,
  SWITCH_ON_VAL,
} from '@ohos/settings.common/src/main/ets/utils/Consts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAboutBluetoothEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { CollaborationUtil } from '../CollaborationUtil';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';

const TAG: string = 'CollaborationServiceSwitchController: ';

export class CollaborationServiceSwitchController {
  /**
   * 处理开关状态变化
   *
   * @param isChecked 新的开关状态
   */
  public handleCheckedChange(isChecked: boolean): void {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutBluetoothEventGroup.COLLABORATION_SERVICE_SWITCH,
      isChecked ? 'on' : 'off');
    LogUtil.info(`${TAG} handleCheckedChange, new status: ${isChecked}`);
    if (isChecked) {
      // 多设备协同服务开关开启时，需将wifi状态从关闭状态变为半关闭状态，蓝牙状态从关闭状态变为开启状态
      CollaborationUtil.enableWifiIfNeed();
    } else {
      // 多设备协同服务开关关闭时，需将wifi/蓝牙状态从半关闭状态变为关闭状态
      CollaborationUtil.disableWifiIfNeed();
      try {
        if (access.getState() === access.BluetoothState.STATE_BLE_ON) {
          access.disableBluetooth();
          LogUtil.info(`${TAG} disabling enhanced services, Disabling Bluetooth.`);
        }
      } catch (error) {
        LogUtil.error(`${TAG} getState failed, message:${error?.message}`);
      }
    }

    let enhancedServicesState: string = isChecked ? SWITCH_ON_VAL : SWITCH_OFF_VAL;
    // 更新数据库，并同步更新BluetoothUtils中该开关的缓存
    BluetoothUtils.enhancedServicesState = enhancedServicesState;
    SystemParamUtil.setParam('persist.bluetooth.collaboration_service', enhancedServicesState);
  }

  /**
   * 处理协同推荐服务开关状态变化
   *
   * @param isChecked 新的开关状态
   */
  public handleRecommendServiceCheckedChange(isChecked: boolean): void {
    let isSwitchOn: boolean = SettingsDataUtils.getSettingsData(SETTINGS_DATA_COLLABORATION_RECOMMEND_SERVICE_SWITCH,
      SWITCH_OFF_VAL) === SWITCH_ON_VAL;
    if (isChecked === isSwitchOn) {
      LogUtil.info(`${TAG} handleRecommendServiceCheckedChange isChecked not change : ${isChecked}`);
      return;
    }
    LogUtil.info(`${TAG} handleRecommendServiceCheckedChange, new status: ${isChecked}`);
    let recommendServicesState: string = isChecked ? SWITCH_ON_VAL : SWITCH_OFF_VAL;
    SettingsDataUtils.setSettingsData(SETTINGS_DATA_COLLABORATION_RECOMMEND_SERVICE_SWITCH, recommendServicesState);
  }
}