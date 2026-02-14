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
import {
  CompCtrlParam,
  ComponentControl
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { NotDisturbTimerPararm } from '@ohos/settings.notDisturb/src/main/ets/model/NotDisturbTimerPararm';
import { NotDisturbUtils } from '@ohos/settings.notDisturb/src/main/ets/utils/NotDisturbUtils';
import { TimeUtil } from '@ohos/settings.common/src/main/ets/utils/TimeUtil';

const TAG: string = 'TimePickerController';

/**
 * 免打扰定时规则时间选择控制器
 */
export class TimePickerController implements ComponentControl {
  private timer: NotDisturbTimerPararm;
  private isMorning: boolean = true;

  constructor(param: NotDisturbTimerPararm, isMorning: boolean) {
    this.timer = param;
    this.isMorning = isMorning;
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
  }

  destroy(): void {
  }

  // 传入的time是 HHmm 格式 转为24小时  HH:mm 保存
  updateTime(time: string): void {
    let date: Date = TimeUtil.getDateByTimeStr(time);
    let finalTime = TimeUtil.formatTime(date, { timeStyle: 'short', hour12: false });
    LogUtil.info(`${TAG} finaltime is ` + finalTime);
    if (this.isMorning) {
      this.timer.startTime = finalTime;
    } else {
      this.timer.endTime = finalTime;
    }
  }

  // 从24小时 HH:mm 转为date
  getCurrentTime(): Date {
    if (this.isMorning) {
      LogUtil.info(`${TAG} time is ` + NotDisturbUtils.getDateFromTime(this.timer.startTime));
      return this.timer.startTime === undefined ? new Date() : NotDisturbUtils.getDateFromTime(this.timer.startTime);
    } else {
      LogUtil.info(`${TAG} time is ` + NotDisturbUtils.getDateFromTime(this.timer.endTime));
      return this.timer.endTime === undefined ? new Date() : NotDisturbUtils.getDateFromTime(this.timer.endTime);
    }
  }

  getMorning(): boolean {
    return this.isMorning;
  }

  // 获取当前系统时间制下的时间
  getEndTime(): string {
    return NotDisturbUtils.getEndTimeSummary(this.timer.startTime, this.timer.endTime);
  }

  getTitle(): string {
    if (this.isMorning) {
      return ResourceUtil.getStringSync($r('app.string.timer_start_time'));
    } else {
      return ResourceUtil.getStringSync($r('app.string.timer_end_time'));
    }
  }
}


