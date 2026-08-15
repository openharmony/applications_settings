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
import power from '@ohos.power';
import ServiceExtensionAbility from '@ohos.app.ability.ServiceExtensionAbility';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  DEFAULT_SCHEDULED_POWER_ON_OFF_REPEAT
  // SCHEDULED_POWER_TIME_NOT_SET // 原开机时间判断已注释，暂不需要
} from '@ohos/settings.system/src/main/ets/constants/ScheduledPowerOnOffConstant';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysSystemEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { ScheduledPowerOnOffTimerManager } from '@ohos/settings.system/src/main/ets/ScheduledPowerOnOffTimerManager';
import { ScheduledPowerOnOffDataUtil } from '@ohos/settings.system/src/main/ets/utils/ScheduledPowerOnOffDataUtil';
import { POWER_OFF_DIALOG_EVENT, SUBMIT_ACTION } from './ScheduledPowerOffDialog';

/**
 * Service ability for ScheduledPowerOn
 *
 * @since 2025-01-20
 */
const TAG: string = 'ScheduledPowerOffNowService';
/* instrument ignore file */
export default class ScheduledPowerOffNowService extends ServiceExtensionAbility {
  async onCreate(want: Want) {
    LogUtil.showInfo(TAG, 'onCreate');
  }

  async onRequest(want: Want, startId: number) {
    LogUtil.showInfo(TAG, `onRequest abilityName:${want.abilityName} startId:${startId}`);
    let isSuccess = EventBus.getInstance().emit(POWER_OFF_DIALOG_EVENT, SUBMIT_ACTION);
    if (!isSuccess) {
      this.updateTimerWithAction();
    }
  }

  async updateTimerWithAction() {
    await this.updateTimer();
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemEventGroup.SCHEDULED_POWER_OFF, 'OK');
    LogUtil.showInfo(TAG, 'shutdown_by_settings_timer');
    power.shutdown('shutdown_by_settings_timer');
  }

  async updateTimer() {
    if (ScheduledPowerOnOffDataUtil.getRepeatMenuChose(TAG, this.context) !==
      Number.parseInt(DEFAULT_SCHEDULED_POWER_ON_OFF_REPEAT)) {
      await ScheduledPowerOnOffTimerManager.getInstance().calculateTimer(false, false, this.context);
    } else {
      ScheduledPowerOnOffDataUtil.resetPowerOffTime(TAG, this.context);
      // 定时开机暂不支持，仅依据定时关机时间控制开关状态
      // 原逻辑：开机时间未设置时才关闭开关
      // if (ScheduledPowerOnOffDataUtil.getPowerOnTime(TAG, this.context) === SCHEDULED_POWER_TIME_NOT_SET) {
      //   ScheduledPowerOnOffDataUtil.resetSwitchModeType(TAG, this.context);
      // }
      ScheduledPowerOnOffDataUtil.resetSwitchModeType(TAG, this.context);
    }
  }

  onDestroy() {
    LogUtil.showInfo(TAG, `onDestroy`);
  }
}