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

import I18n from '@ohos.i18n';
import Intl from '@ohos.intl';
import { LogUtil } from './LogUtil';

type TimeStampType = string | number | Date;

const TAG: string = 'TimeUtil: ';

/**
 * 时间工具类
 */
export class TimeUtil {
  /**
   * 获取格式化时间字符串
   *
   * @param timestamp 精确到毫秒的时间戳
   * @param format 格式化样式 {@link TimeFormat}
   * @param timeZone 时区，如8，-2
   * @returns 格式化时间字符串
   */
  public static obtainFormatTime(timestamp: TimeStampType,
                                 format: TimeFormat, timeZone?: number): string {
    let formatString = '';
    let date: Date = new Date(timestamp);
    let timeZoneStr = timeZone ? TimeUtil.parseZoneNumberToStr(timeZone) :
    TimeUtil.parseZoneNumberToStr(TimeUtil.getTimeZone());
    LogUtil.info(`${TAG} obtainFormatTime timeZone: ${timeZone}, timeZoneStr: ${timeZoneStr}`);
    switch (format) {
      case TimeFormat.MONTH_DAY_NUMERIC:
        formatString = TimeUtil.formatTime(date, { month: 'numeric', day: 'numeric', timeZone: timeZoneStr });
        break;
      case TimeFormat.HOUR_MINUTE:
        formatString = TimeUtil.formatTime(date, {
          hour: '2-digit',
          minute: '2-digit',
          timeZone: timeZoneStr,
          dayPeriod: 'long',
        });
        break;
      case TimeFormat.HOUR_MINUTE_SHORT:
        formatString = TimeUtil.formatTime(date, {
          hour: '2-digit',
          minute: '2-digit',
          timeZone: timeZoneStr
        });
        break;
      case TimeFormat.MOTH_DAY_HOUR_MINUTE_SYSTEM:
        formatString = TimeUtil.formatTime(date, { month: 'long', day: 'numeric', hour: 'numeric', minute: 'numeric' });
        break;
      case TimeFormat.HALF_BLOCK_HOUR_MINUTE:
        formatString = TimeUtil.formatTime(date, { timeStyle: 'short', hour12: true });
        break;
      default:
        LogUtil.warn('missing format implement.');
        formatString = '';
        break;
    }
    return formatString;
  }

  /**
   * 格式化时间戳
   * @param timestamp 时间戳
   * @param options 格式化选项
   * @returns
   */
  private static dateTimeFormatCache: Map<string, Intl.DateTimeFormat> = new Map();

  public static formatTime(timestamp: TimeStampType, options: Intl.DateTimeOptions): string {
    if (!timestamp) {
      return '';
    }

    const local = options.locale ?? TimeUtil.getLocalId();
    if (options.hour12 === undefined) {
      options.hour12 = !TimeUtil.getIs24HourClock();
    }

    const cacheKey = `${local}-${options?.month}-${options?.day}-${options?.timeZone}-${options?.hour}
    -${options?.minute}-${options?.timeStyle}-${options?.hour12}`;
    let dateTimeFormat = TimeUtil.dateTimeFormatCache.get(cacheKey);

    if (!dateTimeFormat) {
      LogUtil.info('call DateTimeFormat');
      dateTimeFormat = new Intl.DateTimeFormat(local, options);
      TimeUtil.dateTimeFormatCache.set(cacheKey, dateTimeFormat);
    }

    return dateTimeFormat.format(new Date(timestamp));
  }

  /**
   * 获取系统当前locale
   * @returns 系统当前locale。如中文环境返回 zh-CN
   */
  public static getLocalId(): string {
    let locale = new Intl.Locale();
    let localeID = locale.toString();
    return localeID;
  }

  /**
   * 判断系统时间是否为24小时制。
   * @returns true表示是24小时制
   */
  public static getIs24HourClock(): boolean {
    let is24HourClock: boolean = true;
    try {
      is24HourClock = I18n.System.is24HourClock(); // 系统24小时开关是否开启
    } catch (error) {
      LogUtil.error(`call System.is24HourClock failed, error code: ${error.code}, message: ${error.message}.`);
    }
    return is24HourClock;
  }

  /**
   * sleep休眠
   *
   * @param ms
   * @returns
   */
  public static async sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms))
  }

  /**
   * 获取当前时区偏移量
   *
   * @return 当前时区偏移量
   */
  public static getTimeZone(): number {
    // 获取与0时区的时间差（单位：分钟）
    let offsetGmt: number = new Date().getTimezoneOffset();
    // 当前时区与0时区的偏移量（单位：小时）
    return 0 - offsetGmt / TimeEnum.MINUTE_TO_SECONDS;
  }

  /**
   * 转换number格式时区信息为string形式
   *
   * @param timeZone number时区信息
   * @returns string时区信息
   */
  public static parseZoneNumberToStr(timeZone: number): string {
    let operator: string = timeZone >= 0 ? '+' : '';
    return `GMT${operator}${String(timeZone)}:00`;
  }

  /**
   * 判断时间戳是否为当天
   * @param timestamp
   * @returns
   */
  public static isToday(timestamp: number): boolean {
    return new Date(timestamp).toDateString() === new Date().toDateString();
  }

  /**
   * 根据HHmm格式的时间字符串，获取Date
   *
   * @param timeStr HHmm格式的时间字符串
   * @returns Date
   */
  public static getDateByTimeStr(timeStr: string): Date {
    let date: Date = new Date();
    if (timeStr.length !== TimeEnum.HHMM_TIME_LENGTH || Number.isNaN(Number(timeStr))) {
      LogUtil.info('getDateByTimeStr data is abnormal!');
      return date;
    }

    date.setHours(Number(timeStr.slice(0, TimeEnum.HOURS_STR_LENGTH)));
    date.setMinutes(Number(timeStr.slice(TimeEnum.HOURS_STR_LENGTH)));
    return date;
  }

  /**
   * 根据yyyyMMdd格式的日期字符串，获取Date
   * @param dateStr yyyyMMdd格式的日期字符串
   * @returns
   */
  public static getDateByDateStr(dateStr: string): Date {
    let date: Date = new Date();
    if (dateStr.length !== TimeEnum.YYYYMMDD_DATE_LENGTH || Number.isNaN(Number(dateStr))) {
      LogUtil.info('getDateByDateStr data is abnormal!');
      return date;
    }
    let year = Number(dateStr.slice(0, TimeEnum.YEAR_STR_LENGTH));
    let month = Number(dateStr.slice(TimeEnum.YEAR_STR_LENGTH, TimeEnum.YEAR_MONTH_STR_LENGTH)) - 1;
    let day = Number(dateStr.slice(TimeEnum.YEAR_MONTH_STR_LENGTH));
    date.setFullYear(year, month, day);
    return date;
  }


  /**
   * 根据Date，获取HHmm格式的时间字符串
   *
   * @param date Date
   * @returns HHmm格式的时间字符串
   */
  public static getTimeStrByDate(date: Date): string {
    let timeStr: string = '';
    if (date === undefined) {
      LogUtil.warn('getTimeStrByDate data is undefined!');
      return timeStr;
    }

    let hours: number = date.getHours();
    let minutes: number = date.getMinutes();
    timeStr = hours?.toString().padStart(TimeEnum.HOURS_STR_LENGTH, '0') ?? '00';
    timeStr += minutes?.toString().padStart(TimeEnum.MINUTE_STR_LENGTH, '0') ?? '00';
    return timeStr;
  }

  /**
   * 时间字符串转换
   * HHmm → HH:mm
   *
   * @param timeStr HHmm 格式的时间字符串
   * @returns HH:mm 格式的时间字符串
   */
  public static getTimeStr(timeStr: string): string {
    let date: Date = TimeUtil.getDateByTimeStr(timeStr);
    return TimeUtil.obtainFormatTime(date, TimeFormat.HOUR_MINUTE);
  }

  public static getDateByTimestamp(timestamp: string): Date {
    let time: number = Number.parseInt(timestamp);
    return new Date(time)
  }

  public static getTimeStrbyTimestamp(timestamp: string): string {
    let date = new Date(Number.parseInt(timestamp))
    return TimeUtil.obtainFormatTime(date, TimeFormat.HOUR_MINUTE);
  }

  /**
   * 分钟数转化为对应的当天的时间点
   *
   * @param minutes 分钟数
   * @returns 日期
   */
  public static minutesToDate(minutes: number | undefined): Date {
    if (!minutes || minutes <= 0) {
      return new Date();
    }
    const hours = Math.floor(minutes / TimeEnum.HOUR_TO_MINUTES);
    const remainderMinutes = minutes % TimeEnum.HOUR_TO_MINUTES;
    const timeStr = hours.toString().padStart(2, '0') + remainderMinutes.toString().padStart(2, '0');
    return TimeUtil.getDateByTimeStr(timeStr);
  }

}

/**
 * 日期格式
 */
export enum TimeFormat {
  /**
   * 年月日 时分秒 YYYY/MM/DD HH:mm:ss
   */
  YEAR_MONTH_DAY_HOUR_MINUTE_SECOND = 'YYYY/MM/DD HH:mm:ss',

  /**
   * 年月日 时分 YYYY/MM/DD HH:mm
   */
  YEAR_MONTH_DAY_HOUR_MINUTE = 'YYYY/MM/DD HH:mm',

  /**
   * 年月日 YYYY/MM/DD
   */
  YEAR_MONTH_DAY_NUMERIC = 'YYYY/MM/DD',

  /**
   * 年月日 月日一位数前不加0 YYYY年M月D日
   */
  YEAR_MONTH_DAY_MEDIUM = 'YYYY年M月D日',

  /**
   * 年月日 年取后两位 YY年M月D日
   */
  YEAR_MONTH_DAY_2_DIGIT = 'YY年M月D日',

  /**
   * 年月 年取后两位 YY年M月
   */
  YEAR_MONTH_2_DIGIT = 'YY年M月',

  /**
   * 年月 YYYY/MM
   */
  YEAR_MONTH_NUMERIC = 'YYYY/MM',

  /**
   * 年月 YYYY年M月
   */
  YEAR_MONTH = 'YYYY年M月',

  /**
   * 年 YYYY年
   */
  YEAR = 'YYYY年',

  /**
   * 月日 一位数前不加0 M/D
   */
  MONTH_DAY_NUMERIC = 'M/D',

  /**
   * 月日 一位数前不加0 M月D日
   */
  MONTH_DAY_SHORT = 'M月D日',

  /**
   * 月 一位数前不加0 M月
   */
  MONTH_SHORT = 'M月',

  /**
   * 时分秒 HH:mm:ss
   */
  HOUR_MINUTE_SECOND = 'HH:mm:ss',

  /**
   * 时分 HH:mm
   */
  HOUR_MINUTE = 'HH:mm',

  /**
   * HH:mm AM/PM
   */
  HOUR_MINUTE_SHORT = 'HH:mm AM',

  /**
   * 上午/下午 HH:mm
   */
  HALF_BLOCK_HOUR_MINUTE = '上午HH:mm',

  /**
   * 时分 HH:mm 跟随系统的时间来显示24或者12小时制
   */
  HOUR_MINUTE_SYSTEM = 'HH:mm sys',

  /**
   * 月天时分 HH:mm 跟随系统的时间来显示24或者12小时制
   */
  MOTH_DAY_HOUR_MINUTE_SYSTEM = 'M月D日 HH:mm',
}


/**
 * 时间相关枚举
 */
export enum TimeEnum {
  /**
   * 1秒: 1000毫秒
   */
  SECOND_TO_MILLISECONDS = 1000,
  /**
   * 30秒: 30* 1000毫秒
   */
  THIRTY_SECOND_TO_MILLISECONDS = 30 * 1000,
  /**
   * 1分钟：60s
   */
  MINUTE_TO_SECONDS = 60,

  /**
   * 5分钟：5*60*1000毫秒
   */
  FIVE_MINUTE_TO_MILLISECONDS = 5 * 60 * 1000,

  /**
   * 1小时：60min
   */
  HOUR_TO_MINUTES = 60,

  /**
   * 1分钟毫秒数
   */
  ONE_MINUTE_MILLS = 60000,

  /**
   * 1小时毫秒数
   */
  ONE_HOUR_MILLS = 3600000,

  /**
   * 1天毫秒数
   */
  ONE_DAY_MILLS = 86400000,

  /**
   * 1天: 24小时
   */
  HOURS = 24,

  /**
   * 1周: 7天
   */
  WEEK_TO_DAYS = 7,

  /**
   * 1年: 12个月
   */
  YEAR_TO_MONTHS = 12,

  /**
   * 1天: 86,400,000毫秒
   */
  DAY_TO_MILLISECONDS = 86400000,

  /**
   * HHmm格式的 时间字符串 长度
   */
  HHMM_TIME_LENGTH = 4,

  /**
   * 时间字符串中，小时的长度
   */
  HOURS_STR_LENGTH = 2,

  /**
   * 时间字符串中，分钟的长度
   */
  MINUTE_STR_LENGTH = 2,
  /**
   * yyyyMMdd格式的 日期字符串 长度
   */
  YYYYMMDD_DATE_LENGTH = 8,
  /**
   * 日期字符串中，年的长度
   */
  YEAR_STR_LENGTH = 4,

  /**
   * 日期字符串中，年月的长度
   */
  YEAR_MONTH_STR_LENGTH = 6
}