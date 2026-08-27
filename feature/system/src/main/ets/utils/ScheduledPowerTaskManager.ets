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

import settings from '@ohos.settings';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  SCHEDULED_POWER_OFF_TIMER_ID,
  SCHEDULED_POWER_ON_TIMER_ID,
  SCHEDULED_POWER_TIME_NOT_SET
} from '../constants/ScheduledPowerOnOffConstant';
import { ScheduledPowerOnOffTimerManager } from '../ScheduledPowerOnOffTimerManager';

@Concurrent
export async function destroyAlarmTask(context: Context): Promise<void> {
  LogUtil.info('ScheduledPowerTaskManager destroy alarms start');
  await ScheduledPowerOnOffTimerManager.getInstance()
    .destroyAlarmSelf(ScheduledPowerOnOffTimerManager.getInstance().getTimerId(true, context));
  SettingsDataUtils.setSettingsDataWithContext(context, SCHEDULED_POWER_ON_TIMER_ID, SCHEDULED_POWER_TIME_NOT_SET,
    settings.domainName.DEVICE_SHARED);
  ScheduledPowerOnOffTimerManager.getInstance().stopPowerOffNowTimer(context);
  await ScheduledPowerOnOffTimerManager.getInstance()
    .destroyAlarmSelf(ScheduledPowerOnOffTimerManager.getInstance().getTimerId(false, context));
  SettingsDataUtils.setSettingsDataWithContext(context, SCHEDULED_POWER_OFF_TIMER_ID, SCHEDULED_POWER_TIME_NOT_SET,
    settings.domainName.DEVICE_SHARED);
}