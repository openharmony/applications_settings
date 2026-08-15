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

import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import Want from '@ohos.app.ability.Want';
import call from '@ohos.telephony.call';
import power from '@ohos.power';
import observer from '@ohos.telephony.observer';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { ScheduledPowerOnOffTimerManager } from '@ohos/settings.system/src/main/ets/ScheduledPowerOnOffTimerManager';
import { ScheduledPowerOnOffDataUtil } from '@ohos/settings.system/src/main/ets/utils/ScheduledPowerOnOffDataUtil';
import {
  FAULT_TYPE_SCHEDULED_SHUTDOWN_FAILED,
  ScheduledPowerOffSysEventUtil } from '@ohos/settings.system/src/main/ets/utils/ScheduledPowerOffSysEventUtil';
import {
  DEFAULT_SCHEDULED_POWER_ON_OFF_REPEAT
  // SCHEDULED_POWER_TIME_NOT_SET // 原开机时间判断已注释，暂不需要
} from '@ohos/settings.system/src/main/ets/constants/ScheduledPowerOnOffConstant';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysSystemEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { POWER_OFF_DIALOG_EVENT, SUBMIT_ACTION } from '../Setting/System/ScheduledPowerOff/ScheduledPowerOffDialog';

/* instrument ignore file */
const TAG: string = 'ScheduledPowerOffDialogAbility : ';
const COUNT_DOWN_SECOND: number = 60;

/**
 * Ability for ScheduledPowerOffDialog
 *
 * @since 2025-2-7
 */
export default class ScheduledPowerOffDialogAbility extends UIExtensionAbility {
  private powerOffDialogEventCallback = (action: string) => {
    LogUtil.showInfo(TAG, `powerOffDialogEventCallback:${action}`);
    ScheduledPowerOnOffTimerManager.getInstance().stopPowerOffNowTimer(this.context);
    this.updateTimerWithAction(action);
  };

  async updateTimerWithAction(action: string) {
    await this.updateTimer();
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemEventGroup.SCHEDULED_POWER_OFF,
      (action == SUBMIT_ACTION) ? 'OK' : 'cancel');
    EventBus.getInstance().detach(POWER_OFF_DIALOG_EVENT, this.powerOffDialogEventCallback);
    if (action == SUBMIT_ACTION) {
      LogUtil.showInfo(TAG, 'shutdown_by_settings_timer');
      power.shutdown('shutdown_by_settings_timer');
    }
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

  onCreate() {
    LogUtil.showInfo(TAG, 'onCreate is called');
    AbilityContextManager.addContext(this.context);
    let para: Record<string, number> = {
      'countDownTime': COUNT_DOWN_SECOND
    };
    let storage: LocalStorage = new LocalStorage(para);
    EventBus.getInstance().on(POWER_OFF_DIALOG_EVENT, this.powerOffDialogEventCallback);
    PreferencesUtil.putSync('CallState', call.getCallStateSync());
  }

  onDestroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy is called');
    AbilityContextManager.removeContext(this.context);
    EventBus.getInstance().detach(POWER_OFF_DIALOG_EVENT, this.powerOffDialogEventCallback);
  }

  onForeground(): void {
    LogUtil.showInfo(TAG, 'onForeground is called');
  }

  onBackground(): void {
    LogUtil.showInfo(TAG, 'onBackground is called');
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    LogUtil.showInfo(TAG, 'onSessionCreate is called');
    if (PreferencesUtil.getSync('CallState', 0) === call.CallState.CALL_STATE_OFFHOOK) {
      LogUtil.showInfo(TAG, 'onRequest in calling, cancel current scheduled shutdown task');
      ScheduledPowerOffSysEventUtil.reportFailureEvent(FAULT_TYPE_SCHEDULED_SHUTDOWN_FAILED,
        `During the call, cancel current scheduled shutdown task`);
      this.updateTimer();
      return;
    }
    try {
      let dialogSession: UIExtensionContentSession =
        (AppStorage.get<UIExtensionContentSession>('scheduledPowerOffDialogSession') as UIExtensionContentSession);
      if (dialogSession) {
        dialogSession.terminateSelf();
      }
      if (CheckEmptyUtils.isEmpty(session)) {
        LogUtil.showError(TAG, 'session is empty');
        return;
      }
      ScheduledPowerOnOffTimerManager.getInstance()
        .startPowerOffNowTimer(Number(ScheduledPowerOnOffDataUtil.getPowerOffDate(TAG, this.context)), this.context);
      AppStorage.setOrCreate<UIExtensionContentSession>('scheduledPowerOffDialogSession', session);
      session.loadContent('Setting/System/ScheduledPowerOff/ScheduledPowerOffDialog');
      session.setWindowBackgroundColor('#00000000');
    } catch (err) {
      LogUtil.showError(TAG, `onSessionCreate failed, err is code: ${err?.code} message: ${err?.message}`);
      session.terminateSelf();
    }
    LogUtil.showInfo(TAG, 'onSessionCreate end');
  }
}