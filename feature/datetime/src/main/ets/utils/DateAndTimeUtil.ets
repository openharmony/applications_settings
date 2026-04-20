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

import systemDateTime from '@ohos.systemDateTime';
import I18n from '@ohos.i18n';
import Settings from '@ohos.settings';
import { DateTimeUtil } from '@ohos/settings.common/src/main/ets/utils/DateTimeUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';

/**
 * 时间日期相关工具类
 *
 * @since 2022-04-27
 */
export class DateAndTimeUtil {
  private static readonly TAG: string = 'DateAndTimeUtil : ';
  public static readonly TIME_FORMAT_KEY: string = Settings.date.TIME_FORMAT;
  private static readonly TIME_FORMAT_24: string = '24';
  private static readonly TIME_FORMAT_12: string = '12';
  private static readonly TIME_SECOND_IN_MILLIS: number = 1000;

  static getPerSecondInMillis(): number {
    return DateAndTimeUtil.TIME_SECOND_IN_MILLIS;
  }

  static getPerMinInMillis(): number {
    return DateAndTimeUtil.getPerSecondInMillis() * 60;
  }

  static getPerHourInMillis(): number {
    return DateAndTimeUtil.getPerMinInMillis() * 60;
  }

  static getPerDayInMillis(): number {
    return DateAndTimeUtil.getPerHourInMillis() * 24;
  }

  static getSystemDateInMills(): number {
    return new Date().getTime();
  }

  static get24HourTimeFormat(): boolean {
    return I18n.System.is24HourClock();
  }

  static set24HourTimFormat(format: boolean): boolean {
    SettingsDataUtils.setSettingsData(DateAndTimeUtil.TIME_FORMAT_KEY,
      format ? DateAndTimeUtil.TIME_FORMAT_24 : DateAndTimeUtil.TIME_FORMAT_12);
    try {
      I18n.System.set24HourClock(format);
      return true;
    } catch (err) {
      LogUtil.error(`${DateAndTimeUtil.TAG} set24HourClock, err.msg: ${err?.message}, err.code: ${err?.code}`);
      return false;
    }
  }

  static setTime(time: number): Promise<void> {
    return systemDateTime.setTime(time)
  }

  static setDate(date: Date): Promise<void> {
    return systemDateTime.setDate(date)
  }

  static getSystemTime(is24hFormat: boolean): string {
    let locale: Intl.Locale = new Intl.Locale(I18n.System.getSystemLanguage());
    let timezone: string = systemDateTime.getTimezoneSync();
    let timeFormat: Intl.DateTimeFormat =
      new Intl.DateTimeFormat(locale.toString(), { timeStyle: 'short', hour12: !is24hFormat, timeZone: timezone });
    return timeFormat.format(new Date());
  }

  static getSystemDate(): string {
    let locale: Intl.Locale = new Intl.Locale(I18n.System.getSystemLanguage());
    let timezone: string = systemDateTime.getTimezoneSync();
    let dateFormat: Intl.DateTimeFormat =
      new Intl.DateTimeFormat(locale.toString(), { dateStyle: 'medium', timeZone: timezone });
    return dateFormat.format(new Date());
  }

  public static getFixedTime(result: TimePickerResult): Date {
    if (!result) {
      LogUtil.error(`${DateAndTimeUtil.TAG} getFixedTime result is invalid`);
      return new Date();
    }
    let datetime = new Date();
    LogUtil.info(`${DateAndTimeUtil.TAG} getFixedTime datetime:${datetime} ${datetime.getTime()}`);
    if (result.second === 0) {
      datetime.setHours(result.hour, result.minute, result.second);
    } else {
      datetime.setHours(result.hour, result.minute);
    }
    // dst不相等，说明设置时间和get到的时间不一致，说明进入了临界点，需要计算一个偏移来消除误差
    // 如果dst相等，说明正常情况，dstOffset = 0，后面不会影响
    let dst = datetime.getHours() - result.hour;
    let dstOffset = 0;
    if (dst != 0) {
      let oneHourMs = DateTimeUtil.getPerHourInMillis();
      dstOffset = dst < 0 ? (oneHourMs) : (-oneHourMs);
    }
    let newTime = datetime.getTime() + dstOffset;
    let newDate = new Date(newTime);
    LogUtil.info(`${DateAndTimeUtil.TAG} getFixedTime dst:${dst}, dstOffset:${dstOffset}, newDate:${newDate} ${newDate.getTime()}`);
    return newDate;
  }

  public static recordCurrentDate(): void {
    const date = new Date();
    LogUtil.info(`${DateAndTimeUtil.TAG} recordCurrentDate ${date} ${date.getTime()}`);
  }

  public static formatDate(date: Date): string {
    let locale: Intl.Locale = new Intl.Locale(I18n.System.getSystemLanguage());
    let timezone: string = systemDateTime.getTimezoneSync();
    let timeFormat = new Intl.DateTimeFormat(locale.toString(), {
      dateStyle: 'long',
      timeStyle: 'short',
      hour12: false,
      timeZone: timezone
    });
    return timeFormat.format(date);
  }
}
