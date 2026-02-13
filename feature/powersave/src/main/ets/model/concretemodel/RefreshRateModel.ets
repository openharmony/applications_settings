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
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { RefreshRateUtils } from '@ohos/settings.display/src/main/ets/utils/RefreshRateUtils';
import {
  PowerSaveTaskManager,
  REFRESH_RATE_KEY,
  REFRESH_RATE_OPTION_DYNAMIC,
  REFRESH_RATE_OPTIONS_HIGH,
  TaskKey
} from '../../PowerSaveTaskManager';
import { PowerSaveSuggestionModel } from '../PowerSaveSuggestionModel';

const TAG: string = 'RefreshRateModel';

@Concurrent
async function setScreenRefreshRate(context: Context): Promise<boolean> {
  try {
    RefreshRateUtils.setScreenRefreshRate(REFRESH_RATE_OPTION_DYNAMIC);
    SettingsDataUtils.setSettingsDataWithContext(context, REFRESH_RATE_KEY, String(REFRESH_RATE_OPTION_DYNAMIC));
    return true;
  } catch (error) {
    LogUtil.error(`RefreshRateModel: setRefreshRateMode failed, code: ${error?.code} message: ${error?.message}`);
    return false;
  }
}

async function needShow(): Promise<boolean> {
  let refreshRate: number = RefreshRateUtils.getCurrentScreenRefreshRate();
  LogUtil.info(`${TAG} getCurrentScreenRefreshRate result: ${refreshRate}`);
  return refreshRate === REFRESH_RATE_OPTIONS_HIGH;
}

async function generateModel(): Promise<PowerSaveSuggestionModel> {
  return {
    key: TaskKey.REFRESH_RATE,
    title: $r('app.string.set_screen_refresh_rate_to_smart_mode'),
    subscription: $r('app.string.set_screen_refresh_rate_to_smart_mode_sub'),
  }
}

PowerSaveTaskManager.getInstance().loadTask(TaskKey.REFRESH_RATE, {
  modelGenerator: generateModel,
  needShow: needShow,
  optimizationTask: setScreenRefreshRate
})