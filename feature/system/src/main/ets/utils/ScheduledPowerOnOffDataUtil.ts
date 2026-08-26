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

import common from '@ohos.app.ability.common';
import settings from '@ohos.settings';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  DEFAULT_SCHEDULED_POWER_OFF_TIME,
  DEFAULT_SCHEDULED_POWER_ON_OFF_REPEAT,
  DEFAULT_SCHEDULED_POWER_ON_OFF_WEEK_REPEAT,
  DEFAULT_SCHEDULED_POWER_ON_TIME,
  SCHEDULED_POWER_OFF_TIME,
  SCHEDULED_POWER_OFF_TIMER_DATE,
  SCHEDULED_POWER_ON_OFF_CALENDAR_DATA,
  SCHEDULED_POWER_ON_OFF_CLOSE,
  SCHEDULED_POWER_ON_OFF_REPEAT,
  SCHEDULED_POWER_ON_OFF_REPEAT_WEEK,
  SCHEDULED_POWER_ON_OFF_SWITCH,
  SCHEDULED_POWER_ON_TIME,
  SCHEDULED_POWER_ON_TIMER_DATE,
  SCHEDULED_POWER_TIME_NOT_SET
} from '../constants/ScheduledPowerOnOffConstant';
/* instrument ignore file */
const TAG: string = 'ScheduledPowerOnOffDataUtil: ';

/**
 * 定时开关机设置数据库工具类
 *
 * @since 2024-12-24
 */
export class ScheduledPowerOnOffDataUtil {
  /**
   * get SwitchMode Type
   *
   * @param tag tag标签
   * @param context context上下文
   */
  static getSwitchModeType(tag: string, context?: common.Context): string {
    let switchMode: string = context ? SettingsDataUtils
      .getSettingsDataWithContext(context, SCHEDULED_POWER_ON_OFF_SWITCH, SCHEDULED_POWER_ON_OFF_CLOSE,
        settings.domainName.DEVICE_SHARED) : SettingsDataUtils
      .getSettingsData(SCHEDULED_POWER_ON_OFF_SWITCH, SCHEDULED_POWER_ON_OFF_CLOSE, settings.domainName.DEVICE_SHARED);
    LogUtil.showInfo(TAG, `${tag} getSwitchModeType ${switchMode}`);
    return switchMode;
  }

  /**
   * get PowerOn Time
   *
   * @param tag tag标签
   * @param context context上下文
   */
  static getPowerOnTime(tag: string, context?: common.Context): string {
    let powerOnTime: string = context ? SettingsDataUtils
      .getSettingsDataWithContext(context, SCHEDULED_POWER_ON_TIME, DEFAULT_SCHEDULED_POWER_ON_TIME,
        settings.domainName.DEVICE_SHARED) : SettingsDataUtils
      .getSettingsData(SCHEDULED_POWER_ON_TIME, DEFAULT_SCHEDULED_POWER_ON_TIME,
        settings.domainName.DEVICE_SHARED);
    LogUtil.showInfo(TAG, `${tag} getPowerOnTime ${powerOnTime}`);
    return powerOnTime;
  }

  /**
   * get PowerOff Time
   *
   * @param tag tag标签
   * @param context context上下文
   */
  static getPowerOffTime(tag: string, context?: common.Context): string {
    let powerOffTime: string = context ? SettingsDataUtils
      .getSettingsDataWithContext(context, SCHEDULED_POWER_OFF_TIME, DEFAULT_SCHEDULED_POWER_OFF_TIME,
        settings.domainName.DEVICE_SHARED) : SettingsDataUtils
      .getSettingsData(SCHEDULED_POWER_OFF_TIME, DEFAULT_SCHEDULED_POWER_OFF_TIME,
        settings.domainName.DEVICE_SHARED);
    LogUtil.showInfo(TAG, `${tag} getPowerOffTime ${powerOffTime}`);
    return powerOffTime;
  }

  /**
   * get RepeatMenu Chose
   *
   * @param tag tag标签
   * @param context context上下文
   */
  static getRepeatMenuChose(tag: string, context?: common.Context): number {
    let repeatType: number = Number(context ? SettingsDataUtils
      .getSettingsDataWithContext(context, SCHEDULED_POWER_ON_OFF_REPEAT, DEFAULT_SCHEDULED_POWER_ON_OFF_REPEAT,
        settings.domainName.DEVICE_SHARED) : SettingsDataUtils
      .getSettingsData(SCHEDULED_POWER_ON_OFF_REPEAT, DEFAULT_SCHEDULED_POWER_ON_OFF_REPEAT,
        settings.domainName.DEVICE_SHARED));
    LogUtil.showInfo(TAG, `${tag} getrepeatType ${repeatType}`);
    return repeatType;
  }

  /**
   * get RepeatWeek Chose
   *
   * @param tag tag标签
   * @param context context上下文
   */
  static getRepeatWeekChose(tag: string, context?: common.Context): string {
    let repeatWeek: string = context ?
    SettingsDataUtils.getSettingsDataWithContext(context, SCHEDULED_POWER_ON_OFF_REPEAT_WEEK,
      DEFAULT_SCHEDULED_POWER_ON_OFF_WEEK_REPEAT,
      settings.domainName.DEVICE_SHARED) :
    SettingsDataUtils.getSettingsData(SCHEDULED_POWER_ON_OFF_REPEAT_WEEK, DEFAULT_SCHEDULED_POWER_ON_OFF_WEEK_REPEAT,
      settings.domainName.DEVICE_SHARED);
    LogUtil.showInfo(TAG, `${tag} getrepeatWeek ${repeatWeek}`);
    if (repeatWeek === SCHEDULED_POWER_TIME_NOT_SET) {
      return '';
    }
    return repeatWeek;
  }

  /**
   * get CalendarData
   *
   * @param tag tag标签
   * @param context context上下文
   */
  static getCalendarData(tag: string, context?: common.Context): string {
    let calendarData: string = context ?
    SettingsDataUtils.getSettingsDataWithContext(context, SCHEDULED_POWER_ON_OFF_CALENDAR_DATA,
      SCHEDULED_POWER_TIME_NOT_SET, settings.domainName.USER_PROPERTY) :
    SettingsDataUtils.getSettingsData(SCHEDULED_POWER_ON_OFF_CALENDAR_DATA, SCHEDULED_POWER_TIME_NOT_SET,
      settings.domainName.USER_PROPERTY);
    LogUtil.showInfo(TAG, `${tag} getCalendarData ${calendarData}`);
    return calendarData;
  }

  /**
   * get PowerOn Date
   *
   * @param tag tag标签
   * @param context context上下文
   */
  static getPowerOnDate(tag: string, context?: common.Context): string {
    let powerOnTime: string = context ? SettingsDataUtils
      .getSettingsDataWithContext(context, SCHEDULED_POWER_ON_TIMER_DATE, SCHEDULED_POWER_TIME_NOT_SET,
        settings.domainName.DEVICE_SHARED) : SettingsDataUtils
      .getSettingsData(SCHEDULED_POWER_ON_TIMER_DATE, SCHEDULED_POWER_TIME_NOT_SET,
        settings.domainName.DEVICE_SHARED);
    LogUtil.showInfo(TAG, `${tag} getPowerOnDate ${powerOnTime}`);
    return powerOnTime;
  }

  /**
   * get PowerOff Date
   *
   * @param tag tag标签
   * @param context context上下文
   */
  static getPowerOffDate(tag: string, context?: common.Context): string {
    let powerOffTime: string = context ? SettingsDataUtils
      .getSettingsDataWithContext(context, SCHEDULED_POWER_OFF_TIMER_DATE, SCHEDULED_POWER_TIME_NOT_SET,
        settings.domainName.DEVICE_SHARED) : SettingsDataUtils
      .getSettingsData(SCHEDULED_POWER_OFF_TIMER_DATE, SCHEDULED_POWER_TIME_NOT_SET,
        settings.domainName.DEVICE_SHARED);
    LogUtil.showInfo(TAG, `${tag} getPowerOffDate ${powerOffTime}`);
    return powerOffTime;
  }

  /**
   * reset SwitchMode Type
   *
   * @param tag tag标签
   * @param context context上下文
   */
  static resetSwitchModeType(tag: string, context?: common.Context): void {
    LogUtil.showInfo(TAG, `${tag} resetSwitchModeType`);
    if (context) {
      SettingsDataUtils.setSettingsDataWithContext(context, SCHEDULED_POWER_ON_OFF_SWITCH, SCHEDULED_POWER_ON_OFF_CLOSE,
        settings.domainName.DEVICE_SHARED);
      SettingsDataUtils.setSettingsDataWithContext(context, SCHEDULED_POWER_ON_TIME, DEFAULT_SCHEDULED_POWER_ON_TIME,
        settings.domainName.DEVICE_SHARED);
      SettingsDataUtils.setSettingsDataWithContext(context, SCHEDULED_POWER_OFF_TIME, DEFAULT_SCHEDULED_POWER_OFF_TIME,
        settings.domainName.DEVICE_SHARED);
    } else {
      SettingsDataUtils.setSettingsData(SCHEDULED_POWER_ON_OFF_SWITCH, SCHEDULED_POWER_ON_OFF_CLOSE,
        settings.domainName.DEVICE_SHARED);
      SettingsDataUtils.setSettingsData(SCHEDULED_POWER_ON_TIME, DEFAULT_SCHEDULED_POWER_ON_TIME,
        settings.domainName.DEVICE_SHARED);
      SettingsDataUtils.setSettingsData(SCHEDULED_POWER_OFF_TIME, DEFAULT_SCHEDULED_POWER_OFF_TIME,
        settings.domainName.DEVICE_SHARED);
    }
  }

  /**
   * reset PowerOff Time
   *
   * @param tag tag标签
   * @param context context上下文
   */
  static resetPowerOffTime(tag: string, context?: common.Context): void {
    LogUtil.showInfo(TAG, `${tag} resetPowerOffTime`);
    if (context) {
      SettingsDataUtils.setSettingsDataWithContext(context, SCHEDULED_POWER_OFF_TIME, SCHEDULED_POWER_TIME_NOT_SET,
        settings.domainName.DEVICE_SHARED);
      SettingsDataUtils.setSettingsDataWithContext(context, SCHEDULED_POWER_OFF_TIMER_DATE,
        SCHEDULED_POWER_TIME_NOT_SET,
        settings.domainName.DEVICE_SHARED);
    } else {
      SettingsDataUtils.setSettingsData(SCHEDULED_POWER_OFF_TIME, SCHEDULED_POWER_TIME_NOT_SET,
        settings.domainName.DEVICE_SHARED);
      SettingsDataUtils.setSettingsData(SCHEDULED_POWER_OFF_TIMER_DATE, SCHEDULED_POWER_TIME_NOT_SET,
        settings.domainName.DEVICE_SHARED);
    }
  }

  /**
   * reset PowerOn Time
   *
   * @param tag tag标签
   * @param context context上下文
   */
  static resetPowerOnTime(tag: string, context?: common.Context): void {
    LogUtil.showInfo(TAG, `${tag} resetPowerOnTime`);
    if (context) {
      SettingsDataUtils.setSettingsDataWithContext(context, SCHEDULED_POWER_ON_TIME, SCHEDULED_POWER_TIME_NOT_SET,
        settings.domainName.DEVICE_SHARED);
      SettingsDataUtils.setSettingsDataWithContext(context, SCHEDULED_POWER_ON_TIMER_DATE, SCHEDULED_POWER_TIME_NOT_SET,
        settings.domainName.DEVICE_SHARED);
    } else {
      SettingsDataUtils.setSettingsData(SCHEDULED_POWER_ON_TIME, SCHEDULED_POWER_TIME_NOT_SET,
        settings.domainName.DEVICE_SHARED);
      SettingsDataUtils.setSettingsData(SCHEDULED_POWER_ON_TIMER_DATE, SCHEDULED_POWER_TIME_NOT_SET,
        settings.domainName.DEVICE_SHARED);
    }
  }
}