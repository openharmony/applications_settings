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
import rpc from '@ohos.rpc';
import ServiceExtensionAbility from '@ohos.app.ability.ServiceExtensionAbility';
import systemTimer from '@ohos.systemTimer';
import common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import wantAgent from '@ohos.app.ability.wantAgent';
import { WantAgent } from '@ohos.wantAgent';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ScheduledPowerOnOffTimerManager } from '@ohos/settings.system/src/main/ets/ScheduledPowerOnOffTimerManager';
import {
  ScheduledPowerOffSysEventUtil,
  FAULT_TYPE_CREATE_TIMER
} from '@ohos/settings.system/src/main/ets/utils/ScheduledPowerOffSysEventUtil';
/* instrument ignore file */
const TAG: string = 'ScheduledPowerCheckService';
const SEND_POWER_OFF_CHECK_REMOTE: number = 1;
const SEND_POWER_OFF_CHECK_REMOTE_KEY: string = 'remote_check';
const SEND_POWER_OFF_CHECK_REMOTE_NO_SELECT: string = '0';
const SEND_POWER_OFF_CHECK_REMOTE_REPLY_CODE_SUCCESS: number = 1;
const SEND_POWER_OFF_CHECK_REMOTE_REPLY_CODE_FAIL: number = 2;
const TIMER_DIFF: number = 20 * 1000;
const SCHEDULED_POWER_RESTORE_TIMER_NAME: string = 'restoreTimer';
const KEY_DESCRIPTOR: string = 'cancelScheduledPowerOn';
let globalContext = new Map<string, Object>();

/**
 * Service stub for ScheduledPowerSwitch
 *
 * @since 2024-12-24
 */
class Stub extends rpc.RemoteObject {
  async onRemoteMessageRequest(code: number, data: rpc.MessageSequence, reply: rpc.MessageSequence,
    options: rpc.MessageOption): Promise<boolean> {
    LogUtil.showInfo(TAG, `onRemoteRequest start`);
    let token = data.readInterfaceToken();
    if (token !== KEY_DESCRIPTOR) {
      LogUtil.showWarn(TAG, 'interface token invalid');
      return false;
    }
    const connectId = rpc.IPCSkeleton?.getCallingPid() + '-' + rpc.IPCSkeleton?.getCallingTokenId();
    LogUtil.showInfo(TAG, `${connectId} onRemoteRequest`);
    if (code === SEND_POWER_OFF_CHECK_REMOTE) {
      let result = await this.processSendRemoteObject(data, reply, connectId);
      LogUtil.showInfo(TAG, `processSendRemoteObject return`);
      return result;
    }
    return false;
  }

  private async processSendRemoteObject(data: rpc.MessageSequence, reply: rpc.MessageSequence,
    connectId: string): Promise<boolean> {
    LogUtil.showInfo(TAG, `onRemoteRequest code:1 start ${connectId}`);
    const size = data.readInt();
    LogUtil.showInfo(TAG, `onRemoteRequest code:1 size: ${size}`);
    if (size !== 1) {
      LogUtil.showError(TAG, `${connectId} onRemoteRequest code:1 parameters error size:${size}`);
      return false;
    }
    const key = data.readString();
    const value = data.readString();
    LogUtil.showInfo(TAG, `${connectId} onRemoteRequest code:1 check key:${key} value:${value}`);
    if (key !== SEND_POWER_OFF_CHECK_REMOTE_KEY || value !== SEND_POWER_OFF_CHECK_REMOTE_NO_SELECT) {
      return false;
    }
    await ScheduledPowerOnOffTimerManager.getInstance()
      .destroyAlarmSelf(ScheduledPowerOnOffTimerManager.getInstance()
        .getTimerId(true, (globalContext.get('TimerContext') as common.Context)));
    let timerId: number = 0;
    try {
      timerId = await systemTimer.createTimer({
        type: systemTimer.TIMER_TYPE_EXACT | systemTimer.TIMER_TYPE_WAKEUP,
        repeat: false,
        wantAgent: await this.getAlarmWantAgent(),
        autoRestore: true,
        name: SCHEDULED_POWER_RESTORE_TIMER_NAME
      });
      const now = new Date();
      let alarmTime: number = now.getTime() + TIMER_DIFF;
      await systemTimer.startTimer(timerId, alarmTime as number);
      LogUtil.showInfo(TAG,
        ` startRecoveryTimeAlarm timerId: ${timerId} alarmtime: ${alarmTime} nowtime: ${new Date().getTime()}`);
      reply.writeInt(SEND_POWER_OFF_CHECK_REMOTE_REPLY_CODE_SUCCESS);
      return true;
    } catch (error) {
      LogUtil.showError(TAG, `startRecoveryTimeAlarm failed : ${(error as BusinessError).message}`);
      reply.writeInt(SEND_POWER_OFF_CHECK_REMOTE_REPLY_CODE_FAIL);
      ScheduledPowerOffSysEventUtil.reportFailureEvent(FAULT_TYPE_CREATE_TIMER,
        `Code:${(error as BusinessError)?.code ??
          0};RecoveryTimer:${SCHEDULED_POWER_RESTORE_TIMER_NAME};TimerId:${timerId}`);
      return false;
    }
  }

  private async getAlarmWantAgent(): Promise<WantAgent | undefined> {
    LogUtil.showInfo(TAG, `getAlarmWantAgent`);
    try {
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: 'com.ohos.settings',
            abilityName: 'com.ohos.settings.ScheduledPowerOnService',
          }
        ],
        actionType: wantAgent.OperationType.START_ABILITY,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG],
        requestCode: 0,
      };
      return await wantAgent.getWantAgent(wantAgentInfo);
    } catch (error) {
      LogUtil.showError(TAG, `getAlarmWantAgent failed: ${(error as BusinessError).message}`);
    }
    return undefined;
  }
}

/**
 * Service ability for ScheduledPowerSwitch
 *
 * @since 2024-12-24
 */
export class ScheduledPowerCheckService extends ServiceExtensionAbility {
  onCreate(want: Want): void {
    LogUtil.showInfo(TAG, 'onCreate');
  }

  onRequest(want: Want, startId: number): void {
    LogUtil.showInfo(TAG,
      `${TAG} onRequest abilityName:${want.abilityName} bundleName:${want.bundleName} startId:${startId}`);
    globalContext.set('TimerContext', this.context);
  }

  onConnect(): Stub {
    LogUtil.showInfo(TAG, 'onConnect');
    return new Stub('ScheduledPowerCheckService stub');
  }

  onDestroy(): void {
    LogUtil.showInfo(TAG, `${TAG} onDestroy`);
  }
}

