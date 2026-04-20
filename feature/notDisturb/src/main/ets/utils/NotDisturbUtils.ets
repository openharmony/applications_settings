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

import { BusinessError } from '@ohos.base';
import { WantAgent } from '@ohos.wantAgent';
import I18n from '@ohos.i18n';
import i18n from '@ohos.i18n';
import settings from '@ohos.settings';
import wantAgent from '@ohos.app.ability.wantAgent';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysNotDisturbEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { GlobalContext } from '@ohos/settings.common/src/main/ets/utils/GlobalContext';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { TimeUtil } from '@ohos/settings.common/src/main/ets/utils/TimeUtil';
import {
  NotDisturbReportParams,
  NotDisturbTimerPararm,
  NotDisturbTimerRepeatType,
  ReportItem,
  NotDisturbReportSources,
} from '../model/NotDisturbTimerPararm';
import { NotDisturbTimeUtil } from './NotDisturbTimeUtil';
import {
  NotDisturbTimerManager,
  DISTURB_MODE_TRIGGER_START_TIME,
  DISTURB_MODE_TRIGGER_END_TIME,
} from '../NotDisturbTimerManager';

/* instrument ignore file */
const TAG: string = 'NotDisturbUtils';
// 定时触发时，拉起的 ability 归属的包名
const NOTDISTURB_TIMER_BUNDLE = 'com.ohos.settings';
// 定时触发时，拉起的 ability 的名称
const NOTDISTURB_TIMER_ABILITY = 'com.ohos.settings.NotDisturbService';
const AGENT_REQUEST_CODE_NORMAL = 0;
export const ONE_DAY = 1;
const HOUR_TO_MIN: number = 60;
const INDEX_HOUR: number = 0;
const INDEX_MIN: number = 1;
const DEFAULT_VALUE: string = '1';
const STATUS_ON: string = 'on';
const STATUS_OFF: string = 'off';
const DEFAULT_LOCALE_DAYS: number[] = [1, 2, 3, 4, 5, 6, 7];
const DAYS_SIZE: number = DEFAULT_LOCALE_DAYS.length;
const DAY_OF_WEEK: string = 'day_of_week';
export const EVENT_SET_NOT_DISTURB_TIMER_COMPLETE: string = 'event_set_not_disturb_timer_complete';
export const FOCUS_MODE_REPEATE_CALLERS_ENABLE: string = 'focus_mode_repeate_callers_enable';
export const FOCUS_MODE_CALL_MESSAGE_POLICY: string = 'focus_mode_call_message_policy';
export const FOCUS_MODE_ENABLED: string = 'focus_mode_enable';
export const FOCUS_MODE_MANUAL_ENABLE: string = 'focus_mode_manual_enable';
export const NOT_DISTURB_VALUE_ERROR: string = '-1';
export const NOT_DISTURB_VALUE_DISABLE: string = '0';
export const NOT_DISTURB_VALUE_ENABLE: string = '1';
export const ALLOW_FAVORITE_CONTACTS: string = '4';
export const NOT_DISTURB_NUMBER_MINUS: number = -1;
export const NOT_DISTURB_NUMBER_DEFAULT: number = 0;
export const NOT_DISTURB_NUMBER_ONE: number = 1;
const NOT_DISTURB_MIGRATE_FLAG: string = 'not_disturb_migrate_flag';
const HMOS_TO_NEXT: string = 'hmos_to_next';

export class NotDisturbUtils {
  static async getAlarmWantAgent(): Promise<WantAgent | undefined> {
    LogUtil.info(`${TAG} getAlarmWantAgent`);
    try {
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: NOTDISTURB_TIMER_BUNDLE,
            abilityName: NOTDISTURB_TIMER_ABILITY,
          }
        ],
        actionType: wantAgent.OperationType.START_ABILITY,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG],
        requestCode: AGENT_REQUEST_CODE_NORMAL,
      }
      return await wantAgent.getWantAgent(wantAgentInfo);
    } catch (error) {
      LogUtil.error(`${TAG} getAlarmWantAgent failed: ${(error as BusinessError).message}`);
      return;
    }
  }

  /**
   * 处理双升级单场景的免打扰数据生效
   *
   * @returns void
   */
  static async handleHmosToNextNotDisturbRestore(): Promise<void> {
    let context: Context = NotDisturbTimerManager.getContext();
    if (!context) {
      LogUtil.warn(`${TAG} context is null`);
      return;
    }
    // 仅双升单完成一次即可，后续不再触发，双升单免打扰数据迁移完成，settings data会写入NOT_DISTURB_VALUE_ENABLE
    let isNeedRestore: boolean =
      SettingsDataUtils.getSettingsDataWithContext(context, NOT_DISTURB_MIGRATE_FLAG, NOT_DISTURB_VALUE_DISABLE,
        settings.domainName.USER_PROPERTY) === NOT_DISTURB_VALUE_ENABLE;
    if (!isNeedRestore) {
      LogUtil.info(`${TAG} handleHmosToNextNotDisturbRestore return`);
      return;
    }
    await NotDisturbUtils.handleNotDisturbRestore(HMOS_TO_NEXT);
  }

  /**
   * 处理免打扰数据迁移
   *
   * @param data 迁移类型
   * @param context 上下文
   * @returns void
   */
  static async handleNotDisturbRestore(data: string): Promise<void> {
    LogUtil.info(`${TAG} handleNotDisturbClone start`);
    let context: Context = NotDisturbTimerManager.getContext();
    if (!context || CheckEmptyUtils.isEmpty(data)) {
      LogUtil.warn(`${TAG} param is empty`);
      return;
    }
    try {
      await NotDisturbTimerManager.getInstance().initOtherConfig(context, true);
      SettingsDataUtils.setSettingsDataWithContext(context, DISTURB_MODE_TRIGGER_START_TIME,
        NOT_DISTURB_VALUE_ERROR, settings.domainName.USER_PROPERTY);
      SettingsDataUtils.setSettingsDataWithContext(context, DISTURB_MODE_TRIGGER_END_TIME,
        NOT_DISTURB_VALUE_ERROR, settings.domainName.USER_PROPERTY);
      let isManualTurnOn: boolean =
        SettingsDataUtils.getSettingsDataWithContext(context, FOCUS_MODE_MANUAL_ENABLE, NOT_DISTURB_VALUE_DISABLE,
          settings.domainName.USER_PROPERTY) === NOT_DISTURB_VALUE_ENABLE;
      GlobalContext.getInstance().set('TimerContext', context);
      if (isManualTurnOn) {
        SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_ENABLED, NOT_DISTURB_VALUE_ENABLE,
          settings.domainName.USER_SECURITY);
        NotDisturbTimerManager.getInstance().stopAlarm();
      } else {
        await NotDisturbTimerManager.getInstance().refreshTimer(true);
      }
      if (data === HMOS_TO_NEXT) {
        SettingsDataUtils.setSettingsDataWithContext(context, NOT_DISTURB_MIGRATE_FLAG,
          NOT_DISTURB_VALUE_DISABLE, settings.domainName.USER_PROPERTY);
      }
    } catch (err) {
      LogUtil.error(`${TAG} handleNotDisturbClone error: ${err?.message}`);
    }
    LogUtil.info(`${TAG} handleNotDisturbClone end`);
  }

  /**
   * 格式化time的字符串
   *
   * @param timeStr 待格式化的字符串
   * @returns 小时和分钟
   */
  static forMatTime(timeStr: string): Array<number> {
    LogUtil.info(`${TAG}, timeStr: ${timeStr}`);
    if (timeStr.length > 5) {
      timeStr = timeStr.slice(2, 7);
    }
    let timeArray: string[] = timeStr.split(':');
    const hour: number = Number(timeArray[0]);
    const minute: number = Number(timeArray[1]);
    return [hour, minute];
  }

  /**
   * 获取下一个timer生效的时间区间
   *
   * @param zenTimerParam 定时规则
   * @returns 开始时间和结束时间
   */
  static getNextTime(zenTimerParam: NotDisturbTimerPararm): Array<number> {
    const timeStart: number[] = NotDisturbUtils.forMatTime(zenTimerParam.startTime as string);
    const timeEnd: number[] = NotDisturbUtils.forMatTime(zenTimerParam.endTime as string);

    const startAlarmTime = new Date();
    startAlarmTime.setHours(timeStart[0]);
    startAlarmTime.setMinutes(timeStart[1]);
    startAlarmTime.setSeconds(0);
    startAlarmTime.setMilliseconds(0);

    const endAlarmTime = new Date();
    endAlarmTime.setHours(timeEnd[0]);
    endAlarmTime.setMinutes(timeEnd[1]);
    endAlarmTime.setSeconds(0);
    endAlarmTime.setMilliseconds(0);

    const now = new Date();
    if (startAlarmTime.getTime() >= endAlarmTime.getTime()) {
      if (endAlarmTime.getTime() > now.getTime()) {
        startAlarmTime.setDate(startAlarmTime.getDate() - ONE_DAY);
      } else {
        endAlarmTime.setDate(endAlarmTime.getDate() + ONE_DAY);
      }
    }
    const repeatType = zenTimerParam.repeatType;
    if (repeatType == NotDisturbTimerRepeatType.ONES) {
      if (endAlarmTime.getTime() <= now.getTime()) {
        // 结束时间小于等于当前时间，表示本次timer已过去
        startAlarmTime.setDate(startAlarmTime.getDate() + ONE_DAY);
        endAlarmTime.setDate(endAlarmTime.getDate() + ONE_DAY);
      }
    } else {
      if (endAlarmTime.getTime() <= now.getTime()) {
        // 结束时间小于等于当前时间，表示本次timer已过去，计算下一次
        startAlarmTime.setDate(startAlarmTime.getDate() + ONE_DAY);
        endAlarmTime.setDate(endAlarmTime.getDate() + ONE_DAY);
      } else if (zenTimerParam.skipEndTime != 0) {
        // 针对手动关闭立即开启开关场景，跳过包含关闭时间点的所有tiemr，计算下一次
        startAlarmTime.setDate(startAlarmTime.getDate() + ONE_DAY);
        endAlarmTime.setDate(endAlarmTime.getDate() + ONE_DAY);
      }
      let daysOfWeek: number[] = NotDisturbTimeUtil.getDaysOfWeek(zenTimerParam.repeat as string);
      const daysToAdd = NotDisturbTimeUtil.getDaysToNextAlarm(daysOfWeek, startAlarmTime.getDay() + 1);
      startAlarmTime.setDate(startAlarmTime.getDate() + daysToAdd);
      endAlarmTime.setDate(endAlarmTime.getDate() + daysToAdd);
    }
    LogUtil.info(`${TAG} getNextTime startAlarmTime: ${startAlarmTime.getDate()} - ${startAlarmTime.getHours()} - ${startAlarmTime.getMinutes()}`);
    LogUtil.info(`${TAG} getNextTime endAlarmTime: ${endAlarmTime.getDate()} - ${endAlarmTime.getHours()} - ${endAlarmTime.getMinutes()}`);
    return [startAlarmTime.getTime(), endAlarmTime.getTime()];
  }

  public static getFormat(): Intl.DateTimeFormat {
    return new Intl.DateTimeFormat(
      new Intl.Locale(I18n.System.getSystemLanguage()).toString(),
      {
        timeStyle: 'short',
        hour12: !I18n.System.is24HourClock(),
        timeZone: i18n.getTimeZone().getID()
      });
  }

  public static getWeekdayFormat(): Intl.DateTimeFormat {
    return new Intl.DateTimeFormat(
      new Intl.Locale(I18n.System.getSystemLanguage()).toString(),
      {
        weekday: 'short'
      });
  }

  public static getTimerSummary(format: Intl.DateTimeFormat, startTime: string, endTime: string): string {
    if (CheckEmptyUtils.isEmpty(format) || CheckEmptyUtils.isEmpty(startTime) || CheckEmptyUtils.isEmpty(endTime)) {
      return '';
    }
    LogUtil.info(`${TAG} getTimerSummary startTime:${startTime}-endTime:${endTime}`);
    const timeStart: number[] = NotDisturbUtils.forMatTime(startTime);
    const timeEnd: number[] = NotDisturbUtils.forMatTime(endTime);
    return NotDisturbUtils.getSummary(format, timeStart, timeEnd);
  }

  public static getTimerSummaryForDate(format: Intl.DateTimeFormat, startTime: Date, endTime: Date): string {
    if (CheckEmptyUtils.isEmpty(format) || CheckEmptyUtils.isEmpty(startTime) || CheckEmptyUtils.isEmpty(endTime)) {
      return '';
    }
    const timeStart: number[] = [startTime.getHours(), startTime.getMinutes()];
    const timeEnd: number[] = [endTime.getHours(), endTime.getMinutes()];
    return NotDisturbUtils.getSummary(format, timeStart, timeEnd);
  }

  public static getZenModeScheduleRepeatText(repeat: string): ResourceStr {
    if (CheckEmptyUtils.checkStrIsEmpty(repeat)) {
      return ResourceUtil.getStringSync($r('app.string.no_repeat'));
    }
    const dayStrings: string[] = repeat.split(',');
    const days: number[] = dayStrings.map(Number);
    let text: ResourceStr = NotDisturbUtils.getScheduleRepeatText(days);
    if (text !== '') {
      return text;
    }
    let calendar: i18n.Calendar = NotDisturbUtils.getCalendar();
    const localDays: number[] = NotDisturbUtils.getCurrentLocaleDays(calendar);
    const length: number = localDays.length;
    let dayOfWeek: number = calendar.get(DAY_OF_WEEK);
    const format: Intl.DateTimeFormat = NotDisturbUtils.getWeekdayFormat();
    const weeks: string[] = [];
    for (let i = 0; i < length; i++) {
      let day: number = localDays[i];
      for (let newDay of days) {
        if (day == newDay) {
          let temp: number = newDay - dayOfWeek;
          calendar.add(DAY_OF_WEEK, temp);
          let week: string = format.format(calendar.getTimeInMillis());
          calendar.add(DAY_OF_WEEK, -temp);
          weeks.push(week);
        }
      }
    }
    return NotDisturbUtils.getWeekResourceStr(weeks);
  }

  private static getWeekResourceStr(weeks: string[]): ResourceStr {
    const weekLength: number = weeks.length;
    if (weekLength === 1) {
      return weeks[0];
    }
    if (weekLength === 2) {
      return ResourceUtil.getAnyStrFormatStringSync(
        $r('app.string.week_description_two_format'), weeks[0], weeks[1]);
    }
    if (weekLength === 3) {
      return ResourceUtil.getAnyStrFormatStringSync(
        $r('app.string.week_description_three_format'), weeks[0], weeks[1], weeks[2]);
    }
    if (weekLength === 4) {
      return ResourceUtil.getAnyStrFormatStringSync(
        $r('app.string.week_description_four_format'), weeks[0], weeks[1], weeks[2], weeks[3]);
    }
    if (weekLength === 5) {
      return ResourceUtil.getAnyStrFormatStringSync(
        $r('app.string.week_description_five_format'), weeks[0], weeks[1], weeks[2], weeks[3], weeks[4]);
    }
    if (weekLength === 6) {
      return ResourceUtil.getAnyStrFormatStringSync(
        $r('app.string.week_description_six_format'), weeks[0], weeks[1], weeks[2], weeks[3], weeks[4], weeks[5]);
    }
    return '';
  }

  private static getCurrentLocaleDays(calendar: i18n.Calendar): number[] {
    const firstDay: number = calendar.getFirstDayOfWeek();
    if (DEFAULT_LOCALE_DAYS.indexOf(firstDay) < 0) {
      return DEFAULT_LOCALE_DAYS;
    }
    const indexOfFirstDay: number = DEFAULT_LOCALE_DAYS.indexOf(firstDay);
    if (indexOfFirstDay === 0) {
      return DEFAULT_LOCALE_DAYS;
    }
    let index: number = indexOfFirstDay;
    let orderIndex: number = 0;
    let currentLocaleDays: number[] = [];
    while (index < DAYS_SIZE && orderIndex < DAYS_SIZE) {
      currentLocaleDays[orderIndex] = DEFAULT_LOCALE_DAYS[index];
      index++;
      orderIndex++;
    }
    index = 0;
    while (index < indexOfFirstDay && orderIndex < DAYS_SIZE) {
      currentLocaleDays[orderIndex] = DEFAULT_LOCALE_DAYS[index];
      index++;
      orderIndex++;
    }
    return currentLocaleDays;
  }

  private static getCalendar(): I18n.Calendar {
    let locale = I18n.System.getSystemLocale();
    let language = I18n.System.getSystemLanguage();
    return I18n.getCalendar(locale, language);
  }

  private static getScheduleRepeatText(days: number[]): ResourceStr {
    if (days.length == 7) {
      return $r('app.string.not_disturb_everyday');
    }
    if (days.length != 5) {
      return '';
    }
    for (let day of days) {
      if (day == 1) {
        return '';
      }
      if (day == 7) {
        return '';
      }
    }
    return $r('app.string.zen_mode_schedule_repeat_monday_to_friday');
  }

  private static getSummary(format: Intl.DateTimeFormat, timeStart: number[], timeEnd: number[]): string {
    try {
      const startString: string = NotDisturbUtils.getTimeFormatString(format, timeStart);
      const endString: string = NotDisturbUtils.getTimeFormatString(format, timeEnd);
      if (NotDisturbUtils.isNextDay(timeStart, timeEnd)) {
        return ResourceUtil.getAnyStrFormatStringSync(
          $r('app.string.zen_mode_ruletime_nextday'), startString, endString);
      } else {
        return ResourceUtil.getAnyStrFormatStringSync(
          $r('app.string.timer_between'), startString, endString);
      }
    } catch (err) {
      LogUtil.info(`${TAG} getSummary error:${err?.message}`);
      return '';
    }
  }

  public static getTimeFormatString(format: Intl.DateTimeFormat, timeArray: number[]): string {
    try {
      const currentDate: Date = new Date();
      currentDate.setHours(timeArray[0], timeArray[1]);
      let formatString = TimeUtil.formatTime(currentDate, {
        hour: '2-digit',
        minute: '2-digit',
        dayPeriod: 'long',
      });
      return formatString;
    } catch (err) {
      LogUtil.error(`${TAG} getSummary error:${err?.message}`);
      return '';
    }
  }

  private static isNextDay(timeStart: number[], timeEnd: number[]): boolean {
    const startMin: number = HOUR_TO_MIN * timeStart[INDEX_HOUR] + timeStart[INDEX_MIN];
    const endMin: number = HOUR_TO_MIN * timeEnd[INDEX_HOUR] + timeEnd[INDEX_MIN];
    return startMin >= endMin;
  }

  /**
   * 获取当前需要展示的系统时间
   *
   * @param startTime 开始时间，永远是24小时制时间
   * @param endTime 结束时间，永远是24小时制时间
   * @returns 需要展示的系统时间字符串
   */
  public static getEndTimeSummary(startTime: string, endTime: string): string {
    const timeStart: number[] = NotDisturbUtils.forMatTime(startTime);
    const timeEnd: number[] = NotDisturbUtils.forMatTime(endTime);

    if (NotDisturbUtils.isNextDay(timeStart, timeEnd)) {
      return ResourceUtil.getFormatStringSync($r('app.string.not_disturb_nextday'),
        NotDisturbUtils.getSysFormatTime(endTime));
    }
    return NotDisturbUtils.getSysFormatTime(endTime);
  }

  /**
   * 获取和系统时间设置一致的时间格式
   *
   * @param time 待格式化的时间
   * @returns 系统格式化后的时间
   */
  public static getSysFormatTime(time: string) {
    const timeNumber: number[] = NotDisturbUtils.forMatTime(time);
    return NotDisturbUtils.getTimeFormatString(NotDisturbUtils.getFormat(), timeNumber);
  }


  public static getDateFromTime(time: string) {
    const timeNumber: number[] = NotDisturbUtils.forMatTime(time);
    const currentDate: Date = new Date();
    currentDate.setHours(timeNumber[0], timeNumber[1]);
    return currentDate;
  }

  /**
   * 打点获取定时规则信息
   */
  private static getTimersMessage(): string {
    let reprotArray: ReportItem[] = [];
    const context: Context = NotDisturbTimerManager.getContext();
    let zenTimersArrays: NotDisturbTimerPararm[] = NotDisturbTimerManager.getInstance().getTimers(context);
    for (let index = 0; index < zenTimersArrays.length; index++) {
      let reportItem: ReportItem = new ReportItem();
      reportItem.isOpen = zenTimersArrays[index].isOpen ? STATUS_ON : STATUS_OFF;
      reportItem.startTime = zenTimersArrays[index].startTime;
      reportItem.endTime = zenTimersArrays[index].endTime;
      reportItem.repeat = zenTimersArrays[index].repeat;
      reprotArray.push(reportItem);
    }
    return JSON.stringify(reprotArray);
  }

  /**
   * 打点获取来电允许类型
   *
   * @returns 来电允许类型
   */
  static getCallPolicy(): number {
    const context: Context = NotDisturbTimerManager.getContext();
    let contactPolicy = SettingsDataUtils.getSettingsDataWithContext(context, FOCUS_MODE_CALL_MESSAGE_POLICY,
      DEFAULT_VALUE, settings.domainName.USER_PROPERTY);
    return Number(contactPolicy);
  }

  /**
   * 打点获取来电铃声重复状态
   *
   * @returns 来电铃声重复状态
   */
  private static getRingStatus(): string {
    const context: Context = NotDisturbTimerManager.getContext();
    let ringStatus = SettingsDataUtils.getSettingsDataWithContext(context, FOCUS_MODE_REPEATE_CALLERS_ENABLE,
      DEFAULT_VALUE, settings.domainName.USER_PROPERTY) === DEFAULT_VALUE;
    return ringStatus ? STATUS_ON : STATUS_OFF;
  }

  /**
   * 打点获取通知应用允许列表
   *
   * @returns 通知应用允许列表
   */
  static async getPkgNameList(): Promise<string[]> {
    let selectList: string[] = [];
    let appDataInfoList = await NotDisturbTimerManager.getInstance().queryTrustAppDataInfo();
    appDataInfoList.forEach(item => {
      selectList.push(item.bundleName);
    })
    return selectList;
  }

  public static async reportNotDisturb(status: string, source: number) {
    let selectList = await NotDisturbUtils.getPkgNameList();
    let pkgsize = selectList.length;
    let pkgname = JSON.stringify(selectList);
    if (!HiSysEventUtil.applicationVersion) {
      await HiSysEventUtil.getApplicationVersion();
    }
    let param: NotDisturbReportParams = {
      PNAMEID: HiSysEventUtil.getPkgName(),
      PVERSIONID: HiSysEventUtil.applicationVersion,
      MODE_NAME: 'Not disturb',
      STATUS: status,
      SOURCES: source,
      TIMERS: NotDisturbUtils.getTimersMessage(),
      CALL_POLICY: NotDisturbUtils.getCallPolicy(),
      RING_STATUS: NotDisturbUtils.getRingStatus(),
      PKGSUM: pkgsize,
      PKGNAME: pkgname,
    };
    HiSysEventUtil.reportNotDisturbEvent(HiSysNotDisturbEventGroup.EVENT_NOT_DISTURB_SWITCH, param);
  }

  static setModeStatus(isOpen: boolean): void {
    let context: Context = NotDisturbTimerManager.getContext();
    GlobalContext.getInstance().set('TimerContext', context);
    SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_MANUAL_ENABLE,
      isOpen ? NOT_DISTURB_VALUE_ENABLE : NOT_DISTURB_VALUE_DISABLE, settings.domainName.USER_PROPERTY);
    SettingsDataUtils.setSettingsDataWithContext(context, FOCUS_MODE_ENABLED,
      isOpen ? NOT_DISTURB_VALUE_ENABLE : NOT_DISTURB_VALUE_DISABLE, settings.domainName.USER_SECURITY);
    const status = isOpen ? 'on' : 'off';
    NotDisturbUtils.reportNotDisturb(status, NotDisturbReportSources.CONTROL_CENTRE);
    if (isOpen) {
      NotDisturbTimerManager.getInstance().initOtherConfig(context);
      NotDisturbTimerManager.getInstance().stopAlarm();
      SettingsDataUtils.setSettingsDataWithContext(context,
        DISTURB_MODE_TRIGGER_START_TIME, NOT_DISTURB_VALUE_ERROR, settings.domainName.USER_PROPERTY);
      SettingsDataUtils.setSettingsDataWithContext(context,
        DISTURB_MODE_TRIGGER_END_TIME, NOT_DISTURB_VALUE_ERROR, settings.domainName.USER_PROPERTY);
    } else {
      NotDisturbTimerManager.getInstance().closeNowChange(new Date().getTime());
    }
  }
}