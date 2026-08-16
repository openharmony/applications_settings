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

import {
  CompCtrlParam,
  ComponentControl
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { HiSysSystemEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { ScheduledPowerOnOffSwitchController } from './ScheduledPowerOnOffSwitchController';
import { ScheduledPowerOnOffRepeatController } from './ScheduledPowerOnOffRepeatController';
import { ScheduledPowerOnOffDataUtil } from '../utils/ScheduledPowerOnOffDataUtil';
import {
  DEFAULT_SCHEDULED_POWER_ON_OFF_REPEAT,
  SCHEDULED_POWER_TIME_NOT_SET
} from '../constants/ScheduledPowerOnOffConstant';
/* instrument ignore file */
const TAG: string = 'ScheduledPowerOnOffController: ';

/**
 * 定时开关机Controller
 *
 * @since 2024-12-12
 */
export class ScheduledPowerOnOffPageController implements ComponentControl {
  private compId: string = '';
  private settingPageModel?: SettingPageModel;

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.showError(TAG, `init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    LogUtil.showInfo(TAG, `init ${this.compId}`);
    this.settingPageModel = compParam.component as SettingPageModel;

    this.checkSwitchState();
    this.addSwitchGroup();
    this.addRepeatGroup();
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemEventGroup.SCHEDULED_POWER_ON_OFF_ENTRY);
  }

  private checkSwitchState(): void {
    if (ScheduledPowerOnOffDataUtil.getRepeatMenuChose(TAG) !==
      Number.parseInt(DEFAULT_SCHEDULED_POWER_ON_OFF_REPEAT)) {
      return;
    }
    const now = new Date();
    // 定时开机暂不支持，仅依据定时关机时间控制开关状态
    // 原逻辑：开机时间过期重置
    // if (Number(ScheduledPowerOnOffDataUtil.getPowerOnDate(TAG)) < now.getTime()) {
    //   ScheduledPowerOnOffDataUtil.resetPowerOnTime(TAG);
    // }
    if (Number(ScheduledPowerOnOffDataUtil.getPowerOffDate(TAG)) < now.getTime()) {
      ScheduledPowerOnOffDataUtil.resetPowerOffTime(TAG);
    }
    // 原逻辑：开机、关机时间同时未设置才关闭开关
    // if (ScheduledPowerOnOffDataUtil.getPowerOnTime(TAG) === SCHEDULED_POWER_TIME_NOT_SET &&
    //   ScheduledPowerOnOffDataUtil.getPowerOffTime(TAG) === SCHEDULED_POWER_TIME_NOT_SET) {
    //   ScheduledPowerOnOffDataUtil.resetSwitchModeType(TAG);
    // }
    if (ScheduledPowerOnOffDataUtil.getPowerOffTime(TAG) === SCHEDULED_POWER_TIME_NOT_SET) {
      ScheduledPowerOnOffDataUtil.resetSwitchModeType(TAG);
    }
  }

  private addSwitchGroup(): void {
    let item: SettingGroupModel = {
      id: 'switch_time',
      type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
      compControl: new ScheduledPowerOnOffSwitchController(),
    };
    this.settingPageModel?.groups?.push(item);
  }

  private addRepeatGroup(): void {
    let item: SettingGroupModel = {
      id: 'repeat_time',
      type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
      compControl: new ScheduledPowerOnOffRepeatController(),
    };
    this.settingPageModel?.groups?.push(item);
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy eventbus');
  }
}