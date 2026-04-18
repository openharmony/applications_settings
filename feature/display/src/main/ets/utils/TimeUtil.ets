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

import { i18n } from '@kit.LocalizationKit';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { HOUR_12, HOUR_24, MIN_60 } from '../constant/DisplayConstant';


export class TimeUtil {
  public static NUMBER_TEN: number = 10;
  
  static timeFormat(time: number): string {
    if (time < TimeUtil.NUMBER_TEN) {
      return '0' + time.toString();
    }
    return time.toString();
  }

  static getDateTimeFormat(): Intl.DateTimeFormat {
    return new Intl.DateTimeFormat(
      new Intl.Locale(i18n.System.getSystemLanguage()).toString(),
      {
        timeStyle: 'short',
        hour12: !i18n.System.is24HourClock(),
        timeZone: i18n.getTimeZone().getID()
      });
  }

  static getTimeFormatString(format: Intl.DateTimeFormat, hour: number, minute: number): string {
    const currentDate: Date = new Date();
    currentDate.setHours(hour, minute);
    return format.format(currentDate);
  }

  /**
   * 正午分界时间
   */
  public static getNoonTime(): number {
    return HOUR_12 * MIN_60;
  }

  /**
   * 次日分界时间
   */
  public static getNextDayTime(): number {
    return HOUR_24 * MIN_60;
  }

  /**
   * 次日正午分界时间
   */
  public static getNextDayNoonTime(): number {
    return (HOUR_24 + HOUR_12) * MIN_60;
  }

  /**
   * 将时间数转换成时间
   *
   * @param dateTime 时间数
   * @param isShowNextDay 是否显示次日
   * @returns 格式化时间
   */
  public static formatTime(dateTime: string | Date, isShowNextDay: boolean = false): string {
    if (dateTime instanceof Date) {
      dateTime = (dateTime.getHours() * MIN_60 + dateTime.getMinutes()).toString();
    }
    let hour: number = Math.floor(Number.parseInt(dateTime) / MIN_60);
    let minute: number = Number.parseInt(dateTime) % MIN_60;
    let content: string = TimeUtil.getTimeFormatString(TimeUtil.getDateTimeFormat(), hour, minute);
    return isShowNextDay ? ResourceUtil.getFormatStringSync($r('app.string.not_disturb_nextday'), content) : content;
  }
}