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
import CommonEventManager from '@ohos.commonEventManager';
import batteryInfo from '@ohos.batteryInfo';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { BatteryQuantityModel } from '../model/BatteryQuantityModel';
import { BATTERY_STATE_CHANGE_EVENT } from '../constants/BatteryConsts';

const TAG: string = 'BatteryQuantityController: ';
export const CHARGING_ENABLE: number = 1;
export const CHARGING_FULL: number = 3;

/**
 * 电池电量显示
 */
export class BatteryQuantityController implements ComponentControl {
  private batteryStateCallback = () => {
    LogUtil.info(`${TAG} batteryStateCallback battery state changed`);
    this.updateBatteryStatus();
  };

  private onPageShowCallback = (() => {
    LogUtil.info(`${TAG} onPageShow`);
    this.updateBatteryStatus();
  });

  private updateBatteryStatus(): void {
    try {
      let batteryQuantity: string = String(batteryInfo.batterySOC);
      let isCharging: boolean =
        batteryInfo.chargingStatus === CHARGING_ENABLE || batteryInfo.chargingStatus === CHARGING_FULL;
      let summary: ResourceStr = isCharging ? $r('app.string.battery_info_status_charging') : '';
      LogUtil.info(`${TAG} batterySOC: ${batteryInfo.batterySOC}, charging status: ${batteryInfo.chargingStatus}`);
      let progressColor: ResourceStr;
      if (batteryInfo.batterySOC <= 10) {
        progressColor = '#FF3320';
      } else if (batteryInfo.batterySOC <= 20) {
        progressColor = '#FF9B1A';
      } else {
        progressColor = '#34C759';
      }

      EventBus.getInstance().emit(CommonEventConstant.EVENT_BATTERY_QUANTITY_REFRESH,
        new BatteryQuantityModel(batteryQuantity, isCharging, progressColor, summary));
    } catch (error) {
      LogUtil.error(`${TAG} get battery info fail: ${error?.code}, ${error?.message}`);
    }
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.updateBatteryStatus();
    EventBus.getInstance().on(BATTERY_STATE_CHANGE_EVENT, this.batteryStateCallback);
    EventBus.getInstance().on(CommonEventConstant.EVENT_BATTERY_PAGE_SHOW, this.onPageShowCallback);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().detach(BATTERY_STATE_CHANGE_EVENT, this.batteryStateCallback);
    EventBus.getInstance().detach(CommonEventConstant.EVENT_BATTERY_PAGE_SHOW, this.onPageShowCallback);
  }
}