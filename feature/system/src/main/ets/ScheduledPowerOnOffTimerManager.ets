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

import settings from '@ohos.settings';
import wantAgent from '@ohos.app.ability.wantAgent';
import systemTimer from '@ohos.systemTimer';
import I18n from '@ohos.i18n';
import common from '@ohos.app.ability.common';
import taskpool from '@ohos.taskpool';
import { WantAgent } from '@ohos.wantAgent';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ContextUtils } from '@ohos/settings.common/src/main/ets/utils/baseutils/ContextUtils';
import {
  MIN_60,
  SCHEDULED_POWER_OFF_NOW_TIMER_ID,
  SCHEDULED_POWER_OFF_NOW_TIMER_NAME,
  SCHEDULED_POWER_OFF_TIMER_DATE,
  SCHEDULED_POWER_OFF_TIMER_ID,
  SCHEDULED_POWER_OFF_TIMER_NAME,
  SCHEDULED_POWER_ON_OFF_WEEK_REPEAT,
  SCHEDULED_POWER_ON_OFF_WORKDAY_REPEAT,
  SCHEDULED_POWER_ON_TIMER_DATE,
  SCHEDULED_POWER_ON_TIMER_ID,
  SCHEDULED_POWER_ON_TIMER_NAME,
  SCHEDULED_POWER_TIME_NOT_SET
} from './constants/ScheduledPowerOnOffConstant';
import { CalendarModel } from './model/CalendarModel';
import { ScheduledPowerOnOffDataUtil } from './utils/ScheduledPowerOnOffDataUtil';
import {
  ScheduledPowerOffSysEventUtil,
  FAULT_TYPE_CREATE_TIMER,
  FAULT_TYPE_DESTROY_TIMER
} from './utils/ScheduledPowerOffSysEventUtil';
import { destroyAlarmTask } from './utils/ScheduledPowerTaskManager';
/* instrument ignore file */
export const VALUE_ERROR: string = '-1';

export const ONE_DAY = 1;

// 定时触发时，拉起的 ability 归属的包名
const TIMER_BUNDLE = 'com.ohos.settings';
// 关机定时触发时，拉起的 ability 的名称
const POWER_OFF_TIMER_ABILITY = 'com.ohos.settings.ScheduledPowerOffService';
// 关机定时倒计时结束时触发，拉起的 ability 的名称
const POWER_OFF_NOW_TIMER_ABILITY = 'com.ohos.settings.ScheduledPowerOffNowService';
// 开机定时触发时，拉起的 ability 的名称
const POWER_ON_TIMER_ABILITY = 'com.ohos.settings.ScheduledPowerOnService';
// Days of a week
const DAYS_OF_WEEK_COUNT = 7;
const AGENT_REQUEST_CODE_NORMAL: number = 0;
const TAG: string = 'ScheduledPowerOnOffTimerManager: ';

/**
 * 定时开关机Timer管理类
 *
 * @since 2024-12-19
 */
export class ScheduledPowerOnOffTimerManager {
  private static menuManager: ScheduledPowerOnOffTimerManager | undefined = undefined;

  /**
   * 获取管理类实例
   *
   * @returns 管理类实例
   */
  public static getInstance(): ScheduledPowerOnOffTimerManager {
    if (ScheduledPowerOnOffTimerManager.menuManager) {
      return ScheduledPowerOnOffTimerManager.menuManager;
    }
    ScheduledPowerOnOffTimerManager.menuManager = new ScheduledPowerOnOffTimerManager();
    return ScheduledPowerOnOffTimerManager.menuManager;
  }

  /**
   * 计算开关机timer生效的时间区间
   *
   * @param isPowerOn 是否为开机Timer
   * @param isForce 是否强制刷新
   * @param context context上下文
   * @returns 开关机timer生效结果
   */
  async calculateTimer(isPowerOn: boolean, isForce: boolean = false, context?: common.Context): Promise<void> {
    LogUtil.showInfo(TAG, `calculateTimer start`);
    let powerTime = this.getNextTime(isPowerOn, context);
    LogUtil.showInfo(TAG, `calculateTimer powerTime: ${powerTime}, isPowerOn: ${isPowerOn}`);
    let oldPowerTime = Number(isPowerOn ? ScheduledPowerOnOffDataUtil.getPowerOnDate(TAG, context) :
    ScheduledPowerOnOffDataUtil.getPowerOffDate(TAG, context));
    if (oldPowerTime !== powerTime || isForce) {
      if (context) {
        SettingsDataUtils.setSettingsDataWithContext(context,
          isPowerOn ? SCHEDULED_POWER_ON_TIMER_DATE : SCHEDULED_POWER_OFF_TIMER_DATE, String(powerTime),
          settings.domainName.DEVICE_SHARED);
      } else {
        SettingsDataUtils.setSettingsData(isPowerOn ? SCHEDULED_POWER_ON_TIMER_DATE : SCHEDULED_POWER_OFF_TIMER_DATE,
          String(powerTime), settings.domainName.DEVICE_SHARED);
      }
      if (powerTime === Number(SCHEDULED_POWER_TIME_NOT_SET)) {
        this.destroyAlarmSelf(this.getTimerId(isPowerOn, context));
        return;
      }
      this.startTimeAlarm(powerTime, isPowerOn, context);
    }
  }

  /**
   * 获取下一个timer生效的时间区间
   *
   * @param isPowerOn 是否为开机Timer
   * @param context context上下文
   * @returns 开始时间和结束时间
   */
  private getNextTime(isPowerOn: boolean, context?: common.Context): number {
    let powerTimeNumber: number = Number.parseInt(isPowerOn ? ScheduledPowerOnOffDataUtil.getPowerOnTime(TAG, context) :
    ScheduledPowerOnOffDataUtil.getPowerOffTime(TAG, context));
    if (powerTimeNumber === Number(SCHEDULED_POWER_TIME_NOT_SET)) {
      return powerTimeNumber;
    }
    let powerHour: number = Math.floor(powerTimeNumber / MIN_60);
    let powerMinute: number = powerTimeNumber % MIN_60;

    const powerAlarmTime = new Date();
    powerAlarmTime.setHours(powerHour);
    powerAlarmTime.setMinutes(powerMinute);
    powerAlarmTime.setSeconds(0);
    powerAlarmTime.setMilliseconds(0);

    const now = new Date();
    if (powerAlarmTime.getTime() <= now.getTime()) {
      // 开始时间小于等于当前时间，表示本次timer已过去，计算下一天
      powerAlarmTime.setDate(powerAlarmTime.getDate() + ONE_DAY);
    }
    let repeatType = String(ScheduledPowerOnOffDataUtil.getRepeatMenuChose(TAG, context));
    if (repeatType === SCHEDULED_POWER_ON_OFF_WORKDAY_REPEAT) {
      let calendarString = ScheduledPowerOnOffDataUtil.getCalendarData(TAG, context);
      while (!this.isStatutoryWorkingDay(calendarString, powerAlarmTime)) {
        // 不是法定工作日，计算下一天
        powerAlarmTime.setDate(powerAlarmTime.getDate() + ONE_DAY);
      }
    } else {
      if (repeatType === SCHEDULED_POWER_ON_OFF_WEEK_REPEAT) {
        let daysOfWeek: number[] =
          this.getDaysOfWeek(ScheduledPowerOnOffDataUtil.getRepeatWeekChose(TAG, context) as string);
        const powerDaysToAdd = this.getDaysToNextAlarm(daysOfWeek, powerAlarmTime.getDay() + 1);
        powerAlarmTime.setDate(powerAlarmTime.getDate() + powerDaysToAdd);
      }
    }
    LogUtil.showInfo(TAG,
      `getNextTime powerOnAlarmTime:${powerAlarmTime.getFullYear()}/${powerAlarmTime.getMonth() +
        1}/${powerAlarmTime.getDate()}-${powerAlarmTime.getHours()}:${powerAlarmTime.getMinutes()}, isPowerOn: ${isPowerOn}`);
    return powerAlarmTime.getTime();
  }

  private isStatutoryWorkingDay(calendarString: string, powerAlarmTime: Date): boolean {
    if (calendarString === SCHEDULED_POWER_TIME_NOT_SET) {
      LogUtil.showWarn(TAG, `getCalendarData invalid`);
      return !this.getCalendar().isWeekend(powerAlarmTime);
    }
    try {
      let items: CalendarModel[] = JSON.parse(calendarString) as Array<CalendarModel>;
      const now = new Date();
      for (let i: number = 0; i < items.length; i++) {
        let calendarModel: CalendarModel = items[i];
        if (!calendarModel) {
          continue;
        }
        if (Number.parseInt(calendarModel.year) < now.getFullYear()) {
          continue;
        }
        let workday: number | undefined = calendarModel.workday.find((item: number) =>
          this.isSameDay(Number.parseInt(calendarModel.year), item, powerAlarmTime));
        if (workday) {
          return true;
        }
        let freeday: number | undefined = calendarModel.freeday.find((item: number) =>
          this.isSameDay(Number.parseInt(calendarModel.year), item, powerAlarmTime));
        if (freeday) {
          return false;
        }
        // isWeekend 判断指定日期在日历中是否为周末,true--周末
        return !this.getCalendar().isWeekend(powerAlarmTime);
      }
    } catch (err) {
      LogUtil.showError(TAG, `rawContent JSON error code: ${err?.code}, message: ${err?.message}`);
    }
    return !this.getCalendar().isWeekend(powerAlarmTime);
  }

  private isSameDay(itemYear: number, workday: number, powerAlarmTime: Date): boolean {
    let workdayItem: string = String(Math.abs(workday));
    if (workdayItem.length !== 4 && workdayItem.length !== 3) {
      // (m)mdd长度
      return false;
    }
    let year = (workday < 0) ? itemYear - 1 : itemYear;
    let month = Number.parseInt(workdayItem.substring(0, workdayItem.length - 2));
    let day = Number.parseInt(workdayItem.substring(workdayItem.length - 2, workdayItem.length));
    return (year === powerAlarmTime.getFullYear()) &&
      (month === powerAlarmTime.getMonth() + 1) && (day === powerAlarmTime.getDate());
  }

  /**
   * 启动定时timer
   *
   * @param alarmTime 定时时间
   * @param isPowerOn 是否为开机Timer
   * @param context context上下文
   * @return 启动结果
   */
  private async startTimeAlarm(alarmTime: number, isPowerOn: boolean, context?: common.Context): Promise<void> {
    let timerId: number = 0;
    try {
      let oldTimerId = this.getTimerId(isPowerOn, context);
      if (oldTimerId !== Number(SCHEDULED_POWER_TIME_NOT_SET)) {
        this.destroyAlarmSelf(oldTimerId);
      }
      if (isPowerOn) {
        timerId = await systemTimer.createTimer({
          type: systemTimer.TIMER_TYPE_EXACT | systemTimer.TIMER_TYPE_WAKEUP,
          repeat: false,
          wantAgent: await this.getAlarmWantAgent(POWER_ON_TIMER_ABILITY),
          autoRestore: true,
          name: SCHEDULED_POWER_ON_TIMER_NAME
        });
      } else {
        timerId = await systemTimer.createTimer({
          type: systemTimer.TIMER_TYPE_EXACT | systemTimer.TIMER_TYPE_WAKEUP,
          repeat: false,
          wantAgent: await this.getAlarmWantAgent(POWER_OFF_TIMER_ABILITY),
          autoRestore: true,
          name: SCHEDULED_POWER_OFF_TIMER_NAME
        });
      }
      if (context) {
        SettingsDataUtils.setSettingsDataWithContext(context,
          isPowerOn ? SCHEDULED_POWER_ON_TIMER_ID : SCHEDULED_POWER_OFF_TIMER_ID, String(timerId),
          settings.domainName.DEVICE_SHARED);
      } else {
        SettingsDataUtils.setSettingsData(isPowerOn ? SCHEDULED_POWER_ON_TIMER_ID : SCHEDULED_POWER_OFF_TIMER_ID,
          String(timerId), settings.domainName.DEVICE_SHARED);
      }
      LogUtil.showInfo(TAG,
        `startTime timerId:${timerId} alarmtime:${alarmTime} nowtime:${new Date().getTime()} isPowerOn:${isPowerOn}`);
      await systemTimer.startTimer(timerId, alarmTime as number);
      LogUtil.showInfo(TAG, `startTimer end`);
    } catch (error) {
      LogUtil.showError(TAG, `startTimeAlarm start timer failed : ${(error as BusinessError).message}`);
      ScheduledPowerOffSysEventUtil.reportFailureEvent(FAULT_TYPE_CREATE_TIMER,
        `Code:${(error as BusinessError)?.code ?? 0};CreateTimer:${SCHEDULED_POWER_OFF_TIMER_NAME};TimerId:${timerId}`);
    }
  }

  /**
   * 启动关机调用定时器
   *
   * @param powerOffAlarmTime 关机弹窗时间
   * @param context context上下文
   */
  async startPowerOffNowTimer(powerOffAlarmTime: number, context: common.Context): Promise<void> {
    let timerId: number = 0;
    try {
      await this.stopPowerOffNowTimer(context);
      timerId = await systemTimer.createTimer({
        type: systemTimer.TIMER_TYPE_EXACT | systemTimer.TIMER_TYPE_WAKEUP,
        repeat: false,
        wantAgent: await this.getAlarmWantAgent(POWER_OFF_NOW_TIMER_ABILITY),
        autoRestore: true,
        name: SCHEDULED_POWER_OFF_NOW_TIMER_NAME
      });
      SettingsDataUtils.setSettingsDataWithContext(context, SCHEDULED_POWER_OFF_NOW_TIMER_ID, String(timerId),
        settings.domainName.DEVICE_SHARED);
      let powerOffNowTime = new Date(powerOffAlarmTime);
      powerOffNowTime.setMinutes(powerOffNowTime.getMinutes() + 1);
      LogUtil.showInfo(TAG, `startPowerOffNowTimer timerId:${timerId} alarmtime:${powerOffNowTime.getTime()}`);
      await systemTimer.startTimer(timerId, powerOffNowTime.getTime());
      LogUtil.showInfo(TAG, `startTimer end`);
    } catch (error) {
      LogUtil.showError(TAG, `startTimeAlarm start timer failed : ${(error as BusinessError).message}`);
      ScheduledPowerOffSysEventUtil.reportFailureEvent(FAULT_TYPE_CREATE_TIMER,
        `Code:${(error as BusinessError)?.code ??
          0};CreateTimer:${SCHEDULED_POWER_OFF_NOW_TIMER_NAME};TimerId:${timerId}`);
    }
  }

  private async getAlarmWantAgent(abilityName: string): Promise<WantAgent | undefined> {
    LogUtil.showInfo(TAG, `getAlarmWantAgent`);
    try {
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: TIMER_BUNDLE,
            abilityName: abilityName,
          }
        ],
        actionType: wantAgent.OperationType.START_ABILITY,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG],
        requestCode: AGENT_REQUEST_CODE_NORMAL,
      };
      return await wantAgent.getWantAgent(wantAgentInfo);
    } catch (error) {
      LogUtil.showError(TAG, `getAlarmWantAgent failed: ${(error as BusinessError).message}`);
    }
    return undefined;
  }

  /**
   * 获取当前生效的定时器的 ID
   *
   * @param context
   * @param isPowerOn 是否为开机Timer
   * @return 当前生效的定时器的 ID
   */
  getTimerId(isPowerOn: boolean, context?: common.Context): number {
    const timerIdFromStorage = context ? SettingsDataUtils.getSettingsDataWithContext(context,
      isPowerOn ? SCHEDULED_POWER_ON_TIMER_ID : SCHEDULED_POWER_OFF_TIMER_ID, SCHEDULED_POWER_TIME_NOT_SET,
      settings.domainName.DEVICE_SHARED) :
    SettingsDataUtils.getSettingsData(isPowerOn ? SCHEDULED_POWER_ON_TIMER_ID : SCHEDULED_POWER_OFF_TIMER_ID,
      SCHEDULED_POWER_TIME_NOT_SET, settings.domainName.DEVICE_SHARED);
    return Number(timerIdFromStorage);
  }

  /**
   * 停止当前timer
   */
  async destroyAlarm(): Promise<void> {
    try {
      let task: taskpool.Task = new taskpool.Task(destroyAlarmTask, ContextUtils.getContext());
      await taskpool.execute(task);
    } catch (error) {
      LogUtil.showError(TAG, `destroyAlarmTask failed: ${(error as BusinessError).message}`);
    }
  }

  /**
   * 取消指定定时器
   *
   * @param 当前生效的timerId
   */
  async destroyAlarmSelf(timerId: number): Promise<void> {
    if (!timerId || timerId === Number(SCHEDULED_POWER_TIME_NOT_SET)) {
      return;
    }
    try {
      await systemTimer.destroyTimer(timerId);
      LogUtil.showInfo(TAG, `destroy timerId: ${timerId}`);
    } catch (error) {
      LogUtil.showError(TAG, `destroy timer failed: ${(error as BusinessError).message}`);
      let code: number = (error as BusinessError)?.code ?? 0;
      if (code !== 0) {
        ScheduledPowerOffSysEventUtil.reportFailureEvent(FAULT_TYPE_DESTROY_TIMER,
          `Code:${code};DestroyTimer:${timerId}`);
      }
    }
  }

  /**
   * 取消后台倒计时结束立刻关机定时器
   *
   * @param context context上下文
   */
  async stopPowerOffNowTimer(context: common.Context): Promise<void> {
    let oldTimerId = SettingsDataUtils.getSettingsDataWithContext(context, SCHEDULED_POWER_OFF_NOW_TIMER_ID,
      SCHEDULED_POWER_TIME_NOT_SET, settings.domainName.DEVICE_SHARED);
    LogUtil.showInfo(TAG, `destroyPowerOffNowTimer timerId: ${oldTimerId}`);
    if (oldTimerId !== SCHEDULED_POWER_TIME_NOT_SET) {
      await this.destroyAlarmSelf(Number.parseInt(oldTimerId));
      SettingsDataUtils.setSettingsDataWithContext(context, SCHEDULED_POWER_OFF_NOW_TIMER_ID,
        SCHEDULED_POWER_TIME_NOT_SET, settings.domainName.DEVICE_SHARED);
    }
  }

  /**
   * 格式化开关机时间显示
   *
   * @param isPowerOn 是否为开机时间
   * @returns 时间格式化显示
   */
  formatScheduledPowerTime(isPowerOn: boolean): string {
    let powerTimeNumber: number = Number.parseInt(isPowerOn ? ScheduledPowerOnOffDataUtil.getPowerOnTime(TAG) :
    ScheduledPowerOnOffDataUtil.getPowerOffTime(TAG));
    if (powerTimeNumber === -1) {
      return '-1';
    }
    let powerHour: number = Math.floor(powerTimeNumber / MIN_60);
    let powerMinute: number = powerTimeNumber % MIN_60;
    return powerHour + ':' + powerMinute;
  }

  private getDaysOfWeek(daysOfWeekStr: string): Array<number> {
    let arrayStr: string[] = daysOfWeekStr.split(',');
    let daysOfWeek: number[] = [];
    for (let index = 0; index < arrayStr.length; index++) {
      daysOfWeek.push(Number(arrayStr[index]));
    }
    return daysOfWeek;
  }

  private getDaysToNextAlarm(daysOfWeek: number[], nearWeekDay: number): number {
    let dayCount = 0;
    if (daysOfWeek.length <= 0) {
      return dayCount;
    }
    for (; dayCount < DAYS_OF_WEEK_COUNT; dayCount++) {
      const day = (nearWeekDay + dayCount) % (DAYS_OF_WEEK_COUNT + 1);
      if (daysOfWeek.some(item => item === day)) {
        break;
      }
    }
    const week = (nearWeekDay + dayCount) / (DAYS_OF_WEEK_COUNT + 1);
    LogUtil.info(`${TAG} getDaysToNextAlarm week: ${week}`);
    if (week >= 1) {
      dayCount--;
    }
    return dayCount;
  }

  private getCalendar(): I18n.Calendar {
    let locale = I18n.System.getSystemLocale();
    let language = I18n.System.getSystemLanguage();
    return I18n.getCalendar(locale, language);
  }
}