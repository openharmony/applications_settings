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
import { systemParameterEnhance } from '@kit.BasicServicesKit';
import { DeviceUtil } from './BaseUtils';
import { DateTimeUtil } from './DateTimeUtil';
import { LogUtil } from './LogUtil';
import { ResourceUtil } from './ResourceUtil';
import { LanguageUtils } from './LanguageUtils';


/**
 * 应用耗电数据转换工具类
 *
 * @since 2024-01-02
 */
export class PowerDataFormatUtil {
  private static readonly TAG: string = 'PowerDataFormatUtil : ';
  private static readonly USE_PC_BATTERY_PAGE: string = 'const.settings.use_pc_battery_page';
  private static readonly TIME_HOUR_IN_SECONDS: number = 3600;

  /**
   * 毫秒转换成 xx 小时 xx 分钟 xx 秒
   * @param timeMillis
   * @returns 转换后时间字符串
   */
  public static formatTimeMillis(timeMillis: number): string {
    let hour: number = Math.floor(timeMillis / DateTimeUtil.getPerHourInMillis());
    let minute: number = Math.floor(
      (timeMillis - hour * DateTimeUtil.getPerHourInMillis()) / DateTimeUtil.getPerMinInMillis());
    let second: number = Math.floor(
      (timeMillis - hour * DateTimeUtil.getPerHourInMillis() - minute * DateTimeUtil.getPerMinInMillis()) /
      DateTimeUtil.getPerSecondInMillis());
    let result: string = '';
    if (hour === 0 && minute === 0 && second === 0) {
      result = ResourceUtil.getStringByName('time_less_than_one_second');
    } else if (hour === 0 && minute === 0) {
      result = ResourceUtil.getPluralStringByNameSync('time_second', second);
    } else if (hour === 0) {
      let secondStr: string = ResourceUtil.getPluralStringByNameSync('time_second', second);
      let minuteStr: string = ResourceUtil.getPluralStringByNameSync('time_minute', minute);
      result = ResourceUtil.getAnyStrFormatStringByName('time_minute_second', minuteStr, secondStr);
    } else {
      let secondStr: string = ResourceUtil.getPluralStringByNameSync('time_second', second);
      let minuteStr: string = ResourceUtil.getPluralStringByNameSync('time_minute', minute);
      let hourStr: string = ResourceUtil.getPluralStringByNameSync('time_hour', hour);
      result = ResourceUtil.getAnyStrFormatStringByName('time_hour_minute_second', hourStr, minuteStr, secondStr);
    }
    LogUtil.info(PowerDataFormatUtil.TAG + result);
    return result;
  }

  /**
   * 毫秒转换成 xx 小时 xx 分钟
   * @param timeMillis
   * @returns 转换后时间字符串
   */
  public static formatTimeMillisToHourMinute(timeMillis: number): string {
    let hour: number = Math.floor(timeMillis / DateTimeUtil.getPerHourInMillis());
    let minute: number = Math.floor(
      (timeMillis - hour * DateTimeUtil.getPerHourInMillis()) / DateTimeUtil.getPerMinInMillis());
    let result: string = '';
    if (hour === 0 && minute === 0) {
      result = ResourceUtil.getStringByName('time_less_than_one_minute');
    } else if (hour === 0) {
      result = ResourceUtil.getPluralStringByNameSync('time_minute', minute);
    } else {
      let minuteStr: string = ResourceUtil.getPluralStringByNameSync('time_minute', minute);
      let hourStr: string = ResourceUtil.getPluralStringByNameSync('time_hour', hour);
      result = ResourceUtil.getAnyStrFormatStringByName('time_hour_minute', hourStr, minuteStr);
    }
    LogUtil.info(PowerDataFormatUtil.TAG + result);
    return result;
  }

  /**
   * mAs->mAh or mWs->mWh
   *
   * @param power mAs or mWs
   * @returns mAh or mWh
   */
  public static formatPowerConsumption(power: number): string {
    let powerMilliAmpHour: number = power / PowerDataFormatUtil.TIME_HOUR_IN_SECONDS;
    // 保留两位小数
    powerMilliAmpHour = Math.round(powerMilliAmpHour * 100) / 100;
    if (powerMilliAmpHour < 1) {
      return ResourceUtil.getStringByName(PowerDataFormatUtil.ifUseWattHourUnits() ? 'less_than_one_mwh' :
        'less_than_one_mah');
    } else {
      return ResourceUtil.getNumberFormatStringByName(PowerDataFormatUtil.ifUseWattHourUnits() ?
        'power_consumption_mwh' : 'power_consumption_mah', LanguageUtils.getNumberFormat(powerMilliAmpHour));
    }
  }

  private static ifUseWattHourUnits(): boolean {
    let ifUsePcBatteryPage = false;
    try {
      const value = systemParameterEnhance.getSync(PowerDataFormatUtil.USE_PC_BATTERY_PAGE, 'false');
      LogUtil.info(`${PowerDataFormatUtil.TAG} ifUseNewPage: ${value}`);
      ifUsePcBatteryPage = value === 'true';
    } catch (err) {
      LogUtil.error(`${PowerDataFormatUtil.TAG} ifUsePcBatteryPage get value failed, code: ${err?.code}, msg: ${err?.message}`);
    }
    return DeviceUtil.isDevicePc() || ifUsePcBatteryPage;
  }

  /**
   * 按系统时区 是否24H格式 返回月日时分 例如 x月x日 下午x:x
   * @param timeMillis 时间毫秒值
   * @returns 当地语言时间
   */
  public static getDateTimeByTimeMillis(timeMillis: number): string {
    let locale = new Intl.Locale(I18n.System.getSystemLanguage());
    let dateFormat = new Intl.DateTimeFormat(locale.toString(), {
      month: `short`,
      day: `numeric`,
      hour: `numeric`,
      minute: `numeric`,
      hour12: !I18n.System.is24HourClock(),
    });
    return dateFormat.format(new Date(timeMillis));
  }
}