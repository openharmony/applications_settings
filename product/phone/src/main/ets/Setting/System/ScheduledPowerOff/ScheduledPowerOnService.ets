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

import Want from '@ohos.app.ability.Want';
import ServiceExtensionAbility from '@ohos.app.ability.ServiceExtensionAbility';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ScheduledPowerOnOffTimerManager } from '@ohos/settings.system/src/main/ets/ScheduledPowerOnOffTimerManager';
import { ScheduledPowerOnOffDataUtil } from '@ohos/settings.system/src/main/ets/utils/ScheduledPowerOnOffDataUtil';
import {
  DEFAULT_SCHEDULED_POWER_ON_OFF_REPEAT,
  SCHEDULED_POWER_TIME_NOT_SET
} from '@ohos/settings.system/src/main/ets/constants/ScheduledPowerOnOffConstant';

/**
 * Service ability for ScheduledPowerOn
 *
 * @since 2024-12-21
 */
const TAG: string = 'ScheduledPowerOnService';
/* instrument ignore file */
export default class ScheduledPowerOnService extends ServiceExtensionAbility {
  async onCreate(want: Want) {
    LogUtil.showInfo(TAG, 'onCreate');
  }

  async onRequest(want: Want, startId: number) {
    LogUtil.showInfo(TAG, `onRequest abilityName:${want.abilityName} bundleName:${want.bundleName} startId:${startId}`);
    if (!this.verifyServiceRequest()) {
      // 通过startRecoveryTimeAlarm方式拉起恢复
      LogUtil.showInfo(TAG, `onRequest from autorestore`);
      // 开机定时器暂不支持
      // ScheduledPowerOnOffTimerManager.getInstance().calculateTimer(true, true, this.context);
      return;
    }
    if (ScheduledPowerOnOffDataUtil.getRepeatMenuChose(TAG, this.context) !==
    Number.parseInt(DEFAULT_SCHEDULED_POWER_ON_OFF_REPEAT)) {
      // 开机定时器暂不支持
      // ScheduledPowerOnOffTimerManager.getInstance().calculateTimer(true, false, this.context);
    } else {
      ScheduledPowerOnOffDataUtil.resetPowerOnTime(TAG, this.context);
      // 定时开机暂不支持，仅依据定时关机时间控制开关状态
      if (ScheduledPowerOnOffDataUtil.getPowerOffTime(TAG, this.context) === SCHEDULED_POWER_TIME_NOT_SET) {
        ScheduledPowerOnOffDataUtil.resetSwitchModeType(TAG, this.context);
      }
    }
  }

  private verifyServiceRequest(): boolean {
    const fixNow = new Date();
    fixNow.setMilliseconds(0);
    const powerOnDateTime = Number(ScheduledPowerOnOffDataUtil.getPowerOnDate(TAG, this.context));
    let minDiffDate = new Date(powerOnDateTime);
    // 5s buffer
    minDiffDate.setSeconds(minDiffDate.getSeconds() - 5);
    let maxDiffDate = new Date(powerOnDateTime);
    maxDiffDate.setMinutes(maxDiffDate.getMinutes() + 1);
    LogUtil.showInfo(TAG,
      `verifyServiceRequest :${minDiffDate.getTime()}-${maxDiffDate.getTime()} fixNow:${fixNow.getTime()}`);
    return minDiffDate.getTime() <= fixNow.getTime() && (fixNow.getTime() < maxDiffDate.getTime());
  }

  onDestroy() {
    LogUtil.showInfo(TAG, `onDestroy`);
  }
}