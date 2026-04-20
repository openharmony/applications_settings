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

import Settings from '@ohos.settings';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { PowerSaveTaskManager, TaskKey, AUTO_SCREEN_ON_KEY } from '../../PowerSaveTaskManager';
import { PowerSaveSuggestionModel } from '../PowerSaveSuggestionModel';

const TAG: string = 'AutoScreenOnModel';

@Concurrent
async function disableAutoScreenOn(context: Context): Promise<boolean> {
  try {
    SettingsDataUtils.setSettingsDataWithContext(context, AUTO_SCREEN_ON_KEY, 'false', Settings.domainName.USER_SECURITY);
    return true;
  } catch (err) {
    LogUtil.error(`AutoScreenOnModel: disableAutoScreenOn error code: ${err?.code} message: ${err?.message}`);
  }
  return false;
}

async function needShow(): Promise<boolean> {
  let value: string = SettingsDataUtils.getSecureValue(AUTO_SCREEN_ON_KEY, 'false');
  return value === 'true'
}

function registerStateChange(callback: Callback<boolean>): void {
  let onStateChange = () => {
    const curState: string = SettingsDataUtils.getSecureValue(AUTO_SCREEN_ON_KEY, 'false');
    callback(curState === 'true');
  }
  SettingsDataUtils.registerKeyObserverWithDomain(AUTO_SCREEN_ON_KEY, Settings.domainName.USER_SECURITY, onStateChange);
}

function unregisterStateChange(callback: Callback<boolean>): void {
  SettingsDataUtils.unregisterKeyObserverWithDomain(AUTO_SCREEN_ON_KEY, Settings.domainName.USER_SECURITY);
}

async function generateModel(): Promise<PowerSaveSuggestionModel> {
  return {
    key: TaskKey.AUTO_SCREEN_ON_WITH_NOTIFICATION,
    title: $r('app.string.disable_wakeup_notification'),
    subscription: $r('app.string.disable_wakeup_notification_sub'),
  }
}

PowerSaveTaskManager.getInstance().loadTask(TaskKey.AUTO_SCREEN_ON_WITH_NOTIFICATION, {
  modelGenerator: generateModel,
  needShow: needShow,
  optimizationTask: disableAutoScreenOn,
  registerStateChange: registerStateChange,
  unregisterStateChange: unregisterStateChange
})