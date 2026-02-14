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
import { dataShare } from '@kit.ArkData';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SLEEP_NOTIFICATION_CHANGE_EVENT } from '../../constant/PowerSaveConstants';
import { PowerSaveTaskManager, SLEEP_NOTIFICATION_ENABLE, TaskKey } from '../../PowerSaveTaskManager';
import { PowerSaveSuggestionModel } from '../PowerSaveSuggestionModel';

const TAG: string = 'NotificationWhenSleepModel';

@Concurrent
async function disableNotificationWhenSleep(context: Context): Promise<boolean> {
  try {
    SettingsDataUtils.setSettingsDataWithContext(context, SLEEP_NOTIFICATION_ENABLE, '0');
    return true;
  } catch (err) {
    LogUtil.error(`NotificationWhenSleepModel: disableNotificationWhenSleep error code: ${err?.code} message: ${err?.message}`);
    return false;
  }
}

async function needShow(): Promise<boolean> {
  let value: string = SettingsDataUtils.getSettingsData(SLEEP_NOTIFICATION_ENABLE, '0');
  return value === '1';
}

function registerStateChange(callback: Callback<boolean>): void {
  LogUtil.info(`${TAG} registerStateChange key: ${SLEEP_NOTIFICATION_ENABLE}`);
  EventBus.getInstance().on(SLEEP_NOTIFICATION_CHANGE_EVENT, callback);
}

function unregisterStateChange(callback: Callback<boolean>): void {
  LogUtil.info(`${TAG} unregisterStateChange key: ${SLEEP_NOTIFICATION_ENABLE}`)
  EventBus.getInstance().detach(SLEEP_NOTIFICATION_CHANGE_EVENT, callback)
}

async function generateModel(): Promise<PowerSaveSuggestionModel> {
  return {
    key: TaskKey.NOTIFICATION_WHEN_SLEEP,
    title: $r('app.string.disable_notification_when_hibernation'),
    subscription: $r('app.string.disable_notification_when_hibernation_sub'),
  }
}

PowerSaveTaskManager.getInstance().loadTask(TaskKey.NOTIFICATION_WHEN_SLEEP, {
  modelGenerator: generateModel,
  needShow: needShow,
  optimizationTask: disableNotificationWhenSleep,
  registerStateChange: registerStateChange,
  unregisterStateChange: unregisterStateChange
})