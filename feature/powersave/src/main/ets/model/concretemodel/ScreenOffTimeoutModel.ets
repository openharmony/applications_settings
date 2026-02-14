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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SleepTime } from '@ohos/settings.display/src/main/ets/controller/SleepController';
import { PowerSaveTaskManager, TaskKey, DATA_SCREEN_OFF_TIMEOUT } from '../../PowerSaveTaskManager';
import { PowerSaveSuggestionModel } from '../PowerSaveSuggestionModel';

const TAG: string = 'ScreenOffTimeoutModel';
const SLEEP_TIME_30: number = 30000;

@Concurrent
async function setScreenOffTimeOut(context: Context): Promise<boolean> {
  try {
    SettingsDataUtils.setSettingsDataWithContext(context, DATA_SCREEN_OFF_TIMEOUT, SleepTime.THIRTY_SECONDS);
    return true;
  } catch (err) {
    LogUtil.error(`ScreenOffTimeoutModel: setRefreshRateMode failed, code: ${err?.code} message: ${err?.message}`);
    return false;
  }
}

async function needShow(): Promise<boolean> {
  let sleepTimeStr: string = SettingsDataUtils.getSettingsData(DATA_SCREEN_OFF_TIMEOUT, SleepTime.THIRTY_SECONDS);
  let sleepTime: number = parseInt(sleepTimeStr);
  return sleepTime > SLEEP_TIME_30;
}

function registerStateChange(callback: Callback<boolean>): void {
  SettingsDataUtils.registerKeyObserver(DATA_SCREEN_OFF_TIMEOUT, () => {
    let curState: string = SettingsDataUtils.getSettingsData(DATA_SCREEN_OFF_TIMEOUT, SleepTime.THIRTY_SECONDS);
    callback(parseInt(curState) > SLEEP_TIME_30);
  })
}

function unregisterStateChange(callback: Callback<boolean>): void {
  SettingsDataUtils.unregisterKeyObserver(DATA_SCREEN_OFF_TIMEOUT);
}

async function generateModel(): Promise<PowerSaveSuggestionModel> {
  return {
    key: TaskKey.SCREEN_OFF_TIME_OUT,
    title: ResourceUtil.getNumberFormatStringSync($r('app.string.set_sleep_time_30'), '30'),
    subscription: ResourceUtil.getNumberFormatStringSync($r('app.string.set_sleep_time_30_sub'), '30'),
  }
}

PowerSaveTaskManager.getInstance().loadTask(TaskKey.SCREEN_OFF_TIME_OUT, {
  modelGenerator: generateModel,
  needShow: needShow,
  optimizationTask: setScreenOffTimeOut,
  registerStateChange: registerStateChange,
  unregisterStateChange: unregisterStateChange
})