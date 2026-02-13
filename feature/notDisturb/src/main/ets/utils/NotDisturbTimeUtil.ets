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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

export const MONTH_LIST = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
export const SATURDAY = 6;
export const SUNDAY = 0;
export const ONE_DAY = 1;
// Days of a week
const DAYS_OF_WEEK_COUNT = 7;
export const CACHE_HOLIDAYS_LIST = 'cache_holidays_list';
// 获取 “某个数字对应的是周几” 时，使用的基准时间（相关JS 接口，年、月传 0，日传入 daysOfWeek 中存放的数字，即可完成周几的本地化转换）
export const WEEK_DAY_BASIC_YEAR = 2023;
export const WEEK_DAY_BASIC_MONTH = 0;
// 中文的语言编码
export const LANGUAGE_ZH = 'zh';
// 英文的语言编码
export const LANGUAGE_EN = 'en';

export interface urlType {
  url: string,
}

export interface HolidaysType {
  year: number,
  version: String,
  workday: number[],
  freeday: number[]
}

export interface NetHolidaysType {
  year: number,
  version: String,
  workday: number[],
  freeday: number[],
  allRecess: HolidaysType[]
}

export interface WeekListField {
  label: string;
  value: number,
  selected: boolean;
}

/**
 * 获取 “某个数字对应的是周几” 时，调用 JS 接口使用的格式（资料推荐使用 JS 接口查询，而不是提翻译）
 */
export enum WeekDayFormat {
  Narrow = 'narrow', // 中文是一、二、三等，英文是M、T、W等，小语种按照业界通用方式翻译
  Short = 'short', // 中文是周一、周二、周三等，英文是Mon、Tue、Web等，小语种按照业界通用方式翻译
  Long = 'long', // 中文是星期一、星期二、星期三等，英文是Monday、Tuesday、Wednesday等，小语种按照业界通用方式翻译
}

/**
 * 时间处理工具类
 */
export class NotDisturbTimeUtil {
  private static daysOfWeekLabelCache: Map<string, string[]> = new Map<string, string[]>();

  /**
   * 查询第N天是星期几
   *
   * @param day查询星期的索引
   * @param weekDayFormat 星期格式，默认为WeekDayFormat.Short
   * @return 要查询星期几的相应语言描述
   */
  static getDayOfWeek(day: number, weekDayFormat: WeekDayFormat): string {
    const options: Intl.DateTimeOptions = { weekday: weekDayFormat || WeekDayFormat.Short };
    const date = new Date(WEEK_DAY_BASIC_YEAR, WEEK_DAY_BASIC_MONTH);
    date.setDate(day + 1);
    let locale = new Intl.Locale(I18n.System.getSystemLanguage());
    const timeWithFormat = new Intl.DateTimeFormat(locale.toString(), options).format(date);
    return timeWithFormat;
  }

  /**
   * 获取相应语言的一周中每一天的描述
   *
   * @format 格式化样式
   * @return 用相应的语言对一周中每一天的描述
   */
  static getDaysOfWeekLabels(format?: WeekDayFormat): string[] {
    const language = I18n.getSystemLanguage();
    let weekLabels = NotDisturbTimeUtil.daysOfWeekLabelCache.get(language);
    /* instrument ignore if*/
    if (weekLabels) {
      return weekLabels;
    }
    const weekDayFormat = format ?? (language.startsWith(LANGUAGE_ZH) ||
    language.startsWith(LANGUAGE_EN) ? WeekDayFormat.Short : WeekDayFormat.Long);
    weekLabels = [0, 1, 2, 3, 4, 5, 6].map(weekDay => NotDisturbTimeUtil.getDayOfWeek(weekDay, weekDayFormat));
    NotDisturbTimeUtil.daysOfWeekLabelCache.set(language, weekLabels);
    return weekLabels;
  }

  static getDaysOfWeek(strdaysOfWeek: string): Array<number> {
    let arrayStr: string[] = strdaysOfWeek.split(',');
    let daysOfWeek: number[] = [];
    for (let index = 0; index < arrayStr.length; index++) {
      daysOfWeek.push(Number(arrayStr[index]));
    }
    return daysOfWeek;
  }

  static getDaysToNextAlarm(daysOfWeek: number[], nearWeekDay: number): number {
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
    LogUtil.info(`${'NotDisturbUtils'} getDaysToNextAlarm week: ${week}`);
    if (week >= 1) {
      dayCount--;
    }
    return dayCount;
  }
}

