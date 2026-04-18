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

import i18n from '@ohos.i18n';
import intl from '@ohos.intl';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DateAndTimeUtil } from './DateAndTimeUtil';

const RAW_OFFSET_HOUR_MOD: number = 3600000;
const RAW_OFFSET_MINUTE_MOD: number = 60000;

/**
 * 时区相关工具类
 *
 * @since 2022-12-09
 */
export class TimeZoneUtil {
  private static readonly TAG: string = 'TimeZoneUtil : ';

  /**
   * 获取系统支持的时区ID集合
   *
   */
  static getAvailableTimeZoneIDs(): Array<string> {
    LogUtil.info(`${TimeZoneUtil.TAG} getAvailableTimeZoneIDs`);
    return i18n.TimeZone.getAvailableIDs();
  }

  /**
   * 获取系统支持的时区城市ID集合
   *
   */
  static getAvailableZoneCityIDs(): Array<string> {
    LogUtil.info(`${TimeZoneUtil.TAG} getAvailableZoneCityIDs`);
    return i18n.TimeZone.getAvailableZoneCityIDs();
  }

  /**
   * 获取某时区城市的本地化显示
   *
   */
  static getCityLocalDisplayName(cityID: string): string {
    let locale = new intl.Locale(i18n.System.getSystemLanguage());
    return i18n.TimeZone.getCityDisplayName(cityID, locale.toString());
  }

  static getSystemLanguage(): string {
    let locale = new intl.Locale(i18n.System.getSystemLanguage());
    return locale.toString();
  }

  /**
   * 获取某时区城市在locale下的本地化显示
   *
   */
  static getCityDisplayName(cityID: string, locale: string): string {
    return i18n.TimeZone.getCityDisplayName(cityID, locale);
  }

  /**
   * 创建某时区城市对应的时区对象
   *
   */
  static getTimezoneFromCity(cityID: string): i18n.TimeZone {
    return i18n.TimeZone.getTimezoneFromCity(cityID);
  }

  /**
   * 计算获取该时区与GMT时区之间的偏移量文本
   *
   */
  static getRawOffsetSummary(timeZone: i18n.TimeZone, isStandardFormat: boolean): string {
    let obj = new Date();
    let offset = timeZone.getOffset(obj.getTime());
    let flag = offset >= 0 ? '+' : '-';
    let hour: number = Math.trunc(Math.abs(offset) / RAW_OFFSET_HOUR_MOD);
    let minute: number = (Math.abs(offset) % RAW_OFFSET_HOUR_MOD) / RAW_OFFSET_MINUTE_MOD;
    if (hour == 0 && minute == 0) {
      return isStandardFormat ? ResourceUtil.getAnyStrFormatStringSync($r('app.string.time_zone_standard_format_offset'), flag, '0', '00') :
      ResourceUtil.getAnyStrFormatStringSync($r('app.string.time_zone_offset'), flag, '0', '00');
    } else if (minute == 0) {
      if (isStandardFormat) {
        return (hour.toString().length == 1) ? ResourceUtil.getAnyStrFormatStringSync($r('app.string.time_zone_standard_format_offset'), flag, hour.toString(), '00') :
        ResourceUtil.getAnyStrFormatStringSync($r('app.string.time_zone_offset'), flag, hour.toString(), '00');
      } else {
        return ResourceUtil.getAnyStrFormatStringSync($r('app.string.time_zone_offset'), flag, hour.toString(), '00');
      }
    } else if (hour == 0) {
      return isStandardFormat ? ResourceUtil.getAnyStrFormatStringSync($r('app.string.time_zone_standard_format_offset'), flag, '0', minute.toString()) :
      ResourceUtil.getAnyStrFormatStringSync($r('app.string.time_zone_offset'), flag, '0', minute.toString());
    } else {
      if (isStandardFormat) {
        return (hour.toString().length == 1) ? ResourceUtil.getAnyStrFormatStringSync($r('app.string.time_zone_standard_format_offset'), flag, hour.toString(), minute.toString()) :
        ResourceUtil.getAnyStrFormatStringSync($r('app.string.time_zone_offset'), flag, hour.toString(), minute.toString());
      } else {
        return ResourceUtil.getAnyStrFormatStringSync($r('app.string.time_zone_offset'), flag, hour.toString(), minute.toString());
      }
    }
  }

  /**
   * 获取选择城市页面的偏移量文本
   *
   */
  static getSelectCitySummary(timeZone: i18n.TimeZone, locale: string): string {
    let is24hFormat = DateAndTimeUtil.get24HourTimeFormat();
    let currentDateFormat = new intl.DateTimeFormat(locale, { month: 'long', day: 'numeric' });
    let dateFormat = new intl.DateTimeFormat(locale.toString(), {
      month: 'long',
      day: 'numeric',
      timeZone: timeZone.getID()
    });
    let timeFormat = new intl.DateTimeFormat(locale.toString(), {
      timeStyle: 'short',
      hour12: !is24hFormat,
      timeZone: timeZone.getID()
    });
    let obj = new Date();
    let currentDate = currentDateFormat.format(obj);
    let date = dateFormat.format(obj);
    let time = timeFormat.format(obj);
    if (date == currentDate) {
      return time;
    } else {
      return date + ' ' + time;
    }
  }
}
