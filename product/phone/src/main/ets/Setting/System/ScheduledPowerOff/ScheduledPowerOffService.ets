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
import common from '@ohos.app.ability.common';
import rpc from '@ohos.rpc';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ScheduledPowerOnOffTimerManager } from '@ohos/settings.system/src/main/ets/ScheduledPowerOnOffTimerManager';
import { ScheduledPowerOnOffDataUtil } from '@ohos/settings.system/src/main/ets/utils/ScheduledPowerOnOffDataUtil';
import {
  DEFAULT_SCHEDULED_POWER_ON_OFF_REPEAT
  // SCHEDULED_POWER_TIME_NOT_SET // 原开机时间判断已注释，暂不需要
} from '@ohos/settings.system/src/main/ets/constants/ScheduledPowerOnOffConstant';

/**
 * Service ability for ScheduledPowerOff
 *
 * @since 2024-12-21
 */
const TAG: string = 'ScheduledPowerOffService';
/* instrument ignore file */
export default class ScheduledPowerOffService extends ServiceExtensionAbility {
  async onCreate(want: Want) {
    LogUtil.showInfo(TAG, 'onCreate');
  }

  async onRequest(want: Want, startId: number) {
    LogUtil.showInfo(TAG, `onRequest abilityName:${want.abilityName} bundleName:${want.bundleName} startId:${startId}`);
    this.openConfirmDialog();
  }

  private async openConfirmDialog(): Promise<void> {
    if (!this.verifyServiceRequest()) {
      LogUtil.showInfo(TAG, 'onRequest from autorestore');
      await this.updateTimer();
      return;
    }
    LogUtil.showInfo(TAG, 'startDialog');
    let sysDialogWant: Want = {
      bundleName: 'com.ohos.sceneboard',
      abilityName: 'com.ohos.sceneboard.systemdialog'
    }
    let options: common.ConnectOptions = {
      onConnect(elementName, remote): void {
        LogUtil.showInfo(TAG, 'onConnect callback');
        if (remote === null) {
          LogUtil.showWarn(TAG, 'onConnect remote is null');
          return;
        }
        let option = new rpc.MessageOption();
        let data = new rpc.MessageSequence();
        let reply = new rpc.MessageSequence();
        data.writeInt(3);
        data.writeString('bundleName');
        data.writeString('com.ohos.settings');
        data.writeString('abilityName');
        data.writeString('ScheduledPowerOffDialogAbility');
        data.writeString('parameters');
        data.writeString(`{"ability.want.params.uiExtensionType":"sysDialog/common","sysDialogZOrder": 1 }`);

        remote.sendMessageRequest(1, data, reply, option).then((ret) => {
          let msg = reply.readInt();
          LogUtil.showInfo(TAG, `sendMessageRequest msg: ${msg}`);
        }).catch((error: BusinessError) => {
          LogUtil.showError(TAG, `sendMessageRequest failed err: ${error?.message}`);
        }).finally(() => {
          data.reclaim();
          reply.reclaim();
        });
      },
      onDisconnect(elementName): void {
        LogUtil.showInfo(TAG, 'onDisconnect callback');
      },
      onFailed(code): void {
        LogUtil.showInfo(TAG, `onFailed, code: ${code}`);
      }
    }

    try {
      let connectionId =
        (this.context as common.ServiceExtensionContext).connectServiceExtensionAbility(sysDialogWant, options);
      LogUtil.showInfo(TAG, `connectionId: ${connectionId}`);
    } catch (err) {
      LogUtil.showError(TAG, `err code: ${err?.code} message: ${err?.message}`);
    }
  }

  private verifyServiceRequest(): boolean {
    const fixNow = new Date();
    fixNow.setMilliseconds(0);
    const powerOffDateTime = Number(ScheduledPowerOnOffDataUtil.getPowerOffDate(TAG, this.context));
    let minDiffDate = new Date(powerOffDateTime);
    // 5s buffer
    minDiffDate.setSeconds(minDiffDate.getSeconds() - 5);
    let maxDiffDate = new Date(powerOffDateTime);
    maxDiffDate.setMinutes(maxDiffDate.getMinutes() + 1);
    LogUtil.showInfo(TAG,
      `verifyServiceRequest :${minDiffDate.getTime()}-${maxDiffDate.getTime()} fixNow:${fixNow.getTime()}`);
    return minDiffDate.getTime() <= fixNow.getTime() && (fixNow.getTime() < maxDiffDate.getTime());
  }

  private async updateTimer() {
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
    LogUtil.showInfo(TAG, 'onDestroy');
  }
}
