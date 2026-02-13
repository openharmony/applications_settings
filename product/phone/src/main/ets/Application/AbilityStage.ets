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

import AbilityStage from '@ohos.app.ability.AbilityStage';
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager';
import { CustomMenuManager } from '@ohos/settings.common/src/main/ets/custom/CustomMenuManager';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { Trace } from '@ohos/settings.common/src/main/ets/utils/Trace';
import taskpool from '@ohos.taskpool';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BusinessError } from '@ohos.base';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';

@Concurrent
async function loadCcmConfigs(): Promise<void> {
  LogUtil.info(`SettingsAbilityStage init data.`);
  CustomMenuManager.getInstance().loadCcmConfigs();
}

@Concurrent
async function isMainOsAccount(): Promise<boolean> {
  LogUtil.info(`isMainOsAccount start.`);
  try {
    let ns = await import('@ohos.account.osAccount');
    let isMainOsAccount: boolean = await ns.default.getAccountManager().isMainOsAccount() as boolean;
    LogUtil.info(`isMainOsAccount end isMainOsAccount ${isMainOsAccount} .`);
    return isMainOsAccount;
  } catch (err) {
    LogUtil.showError('HomePageMenuManager', `get isMainOsAccount result error: ${err?.message}`);
  }
  return false;
}

export default class SettingsAbilityStage extends AbilityStage {
  onCreate(): void {
    LogUtil.info('SettingsAbilityStage onCreate');
    Trace.start('SettingsAbilityStage onCreate');
    DynamicLoader.getInstance();
    AbilityContextManager.setStageContext(this.context);
    this.requestTimerResources();
    AbilityUtils.setCacheProcess(true, this.context);
    this.initDataSync();
    Trace.end('SettingsAbilityStage onCreate');
  }

  private async initDataSync(): Promise<void> {
    try {
      let initTask: taskpool.Task = new taskpool.Task(loadCcmConfigs, this.context);
      taskpool.execute(initTask, taskpool.Priority.MEDIUM);

      let parentControlTask: taskpool.Task = new taskpool.Task(isMainOsAccount, this.context);
      let isMainAccount = await taskpool.execute(parentControlTask, taskpool.Priority.MEDIUM);
      AppStorage.setOrCreate('isMainAccount', isMainAccount);
      LogUtil.info(`initDataSync is main account ${isMainAccount}.`);
    } catch (exception) {
      LogUtil.error(`SettingsAbilityStage catch exception, errmsg: ${(exception as BusinessError).message}`);
    }
  }

  /**
   * 申请timer能效资源
   */
  private requestTimerResources(): void {
    try {
      backgroundTaskManager.resetAllEfficiencyResources();
      let request: backgroundTaskManager.EfficiencyResourcesRequest = {
        resourceTypes: backgroundTaskManager.ResourceType.TIMER,
        isApply: true, // 申请资源
        timeOut: 0,
        reason: 'apply',
        isPersist: true,
        isProcess: false,
      };
      backgroundTaskManager.applyEfficiencyResources(request);
      LogUtil.info('Succeeded in invoking requestTimerResources.');
    } catch (err) {
      LogUtil.error(`requestTimerResources failed:${(err as BusinessError).code} ${(err as BusinessError).message}`);
    }
  }
}