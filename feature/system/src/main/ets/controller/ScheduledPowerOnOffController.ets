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

import dataShare from '@ohos.data.dataShare';
import { BusinessError } from '@kit.BasicServicesKit';
import settings from '@ohos.settings';
import { CompCtrlParam, ComponentControl, } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { HiSysSystemEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import {
  SCHEDULED_POWER_OFF_TIME,
  SCHEDULED_POWER_ON_OFF_OPEN,
  SCHEDULED_POWER_ON_OFF_REPEAT,
  SCHEDULED_POWER_ON_OFF_SWITCH,
  SCHEDULED_POWER_ON_OFF_WEEK_REPEAT,
  SCHEDULED_POWER_ON_TIME,
  SCHEDULED_POWER_TIME_NOT_SET
} from '../constants/ScheduledPowerOnOffConstant';
import { ScheduledPowerOnOffTimerManager } from '../ScheduledPowerOnOffTimerManager';
import { ScheduledPowerOnOffDataUtil } from '../utils/ScheduledPowerOnOffDataUtil';
/* instrument ignore file */
const TAG: string = 'ScheduledPowerOnOffController: ';
const WEEK_REPEAT: string = '2';

/**
 * 定时开关机基类Controller
 *
 * @since 2024-12-12
 */
export class ScheduledPowerOnOffController implements ComponentControl {
  protected compId: string = '';
  protected dataHelper?: dataShare.DataShareHelper;
  protected ScheduledPowerOnOffChangeCallback = () => {
    LogUtil.showInfo(TAG, `darkModeChangeCallback`);
  };

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.showError(TAG, `init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
  }

  protected registerDataHelper(): void {
    LogUtil.showInfo(TAG, `registerDataHelper`);
    if (this.dataHelper) {
      SettingsDataUtils.registerDataChange(this.dataHelper, SCHEDULED_POWER_ON_OFF_SWITCH,
        this.ScheduledPowerOnOffChangeCallback);
    } else {
      (SettingsDataUtils.createDataHelper(SCHEDULED_POWER_ON_OFF_SWITCH) as Promise<dataShare.DataShareHelper>)
        .then((dataShareHelper?: dataShare.DataShareHelper | undefined) => {
          LogUtil.showInfo(TAG, `createDataHelper success, ${dataShareHelper !== undefined}`);
          if (dataShareHelper) {
            this.dataHelper = dataShareHelper;
            SettingsDataUtils.registerDataChange(this.dataHelper, SCHEDULED_POWER_ON_OFF_SWITCH,
              this.ScheduledPowerOnOffChangeCallback);
          }
        })
        .catch((err: BusinessError) => {
          LogUtil.showError(TAG, `createDataHelper err: ${err?.code}`);
        })
    }
  }

  protected unRegisterDataHelper(): void {
    if (!this.dataHelper) {
      return;
    }
    SettingsDataUtils.unRegisterDataChange(this.dataHelper, SCHEDULED_POWER_ON_OFF_SWITCH);
  }

  protected setPowerOnTime(powerOnTime: string): void {
    SettingsDataUtils
      .setSettingsData(SCHEDULED_POWER_ON_TIME, powerOnTime, settings.domainName.DEVICE_SHARED);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemEventGroup.POWER_ON_TIME_SELECT);
  }

  protected setPowerOffTime(powerOffTime: string): void {
    SettingsDataUtils
      .setSettingsData(SCHEDULED_POWER_OFF_TIME, powerOffTime, settings.domainName.DEVICE_SHARED);
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemEventGroup.POWER_OFF_TIME_SELECT);
  }

  protected setSwitchModeType(switchMode: string): void {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemEventGroup.SCHEDULED_POWER_ON_OFF_SWITCH,
      this.isSwitchOpen(switchMode) ? 'on' : 'off');
    SettingsDataUtils.setSettingsData(SCHEDULED_POWER_ON_OFF_SWITCH, switchMode, settings.domainName.DEVICE_SHARED);
  }

  protected setRepeatMenuChose(currentSelect: string): void {
    SettingsDataUtils.setSettingsData(SCHEDULED_POWER_ON_OFF_REPEAT, currentSelect, settings.domainName.DEVICE_SHARED);
    let params: Record<string, Object> = {};
    params.REPEAT = currentSelect;
    params.WEEK = (currentSelect !== WEEK_REPEAT) ? SCHEDULED_POWER_TIME_NOT_SET
      : ScheduledPowerOnOffDataUtil.getRepeatWeekChose(TAG);
    HiSysEventUtil.reportBehaviorEventByUE(HiSysSystemEventGroup.SCHEDULED_REPEAT_SELECT, params);
  }

  protected isSwitchOpen(switchMode: string): boolean {
    return switchMode === SCHEDULED_POWER_ON_OFF_OPEN;
  }

  updateTimer(isForce?: boolean): void {
    LogUtil.showInfo(TAG, `updateTimer start`);
    if (String(ScheduledPowerOnOffDataUtil.getRepeatMenuChose(TAG)) == SCHEDULED_POWER_ON_OFF_WEEK_REPEAT) {
      if (StringUtil.isEmpty(ScheduledPowerOnOffDataUtil.getRepeatWeekChose(TAG))) {
        ScheduledPowerOnOffTimerManager.getInstance().destroyAlarm();
        LogUtil.showInfo(TAG, `updateTimer not invalid date in weekRepeat`);
        return;
      }
    }
    ScheduledPowerOnOffTimerManager.getInstance().calculateTimer(false, isForce);
    // 开机定时器暂不支持
    // ScheduledPowerOnOffTimerManager.getInstance().calculateTimer(true, isForce);
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy eventbus');
    this.unRegisterDataHelper();
  }
}