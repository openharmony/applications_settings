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

import { BatteryHistory } from '../data/BatteryLineDataType';
import { LogUtil } from './LogUtil';

const TAG: string = 'DateTimeUtil : ';

export class DateTimeUtil {
  public static readonly TIME_HOUR_IN_SECONDS: number = 3600;
  private static readonly TIME_SECOND_IN_MILLIS: number = 1000;
  private static appPowerData: BatteryHistory[];

  // 获取一秒钟内的毫秒时间
  static getPerSecondInMillis(): number {
    return DateTimeUtil.TIME_SECOND_IN_MILLIS;
  }

  // 获取一分钟内的毫秒时间
  static getPerMinInMillis(): number {
    return DateTimeUtil.getPerSecondInMillis() * 60;
  }

  // 获取每小时的毫秒时间
  static getPerHourInMillis(): number {
    return DateTimeUtil.getPerMinInMillis() * 60;
  }

  // 获取每天的毫秒时间
  static getPerDayInMillis(): number {
    return DateTimeUtil.getPerHourInMillis() * 24;
  }

  // 获取系统毫秒时间
  static getSystemDateInMills(): number {
    return new Date().getTime();
  }

  //判断当前时间距离上次是否超过半个小时
  static isHalfAnHour(lastTime: number): boolean {
    let currentTimeStamp: number = new Date().getTime();
    return currentTimeStamp - lastTime > DateTimeUtil.getPerHourInMillis() / 2;
  }

  // 判断上次距离当前时间是否超过半个小时
  static isLastHalfAnHour(lastTime: number): boolean {
    let currentTimeStamp: number = new Date().getTime();
    return lastTime - currentTimeStamp > DateTimeUtil.getPerHourInMillis() / 2;
  }

  //取过去最近的整点或半点
  static getPassTimestamp(): number {
    let currentTimeStamp: number = new Date().getTime();
    return currentTimeStamp - currentTimeStamp % (DateTimeUtil.getPerHourInMillis() / 2);
  }

  public static setAppPowerData(data: BatteryHistory[]) {
    LogUtil.info(`DateTimeUtil setAppPowerData}`)
    DateTimeUtil.appPowerData = data;
  }

  public static getAppPowerData(): BatteryHistory[] {
    LogUtil.info(`DateTimeUtil getAppPowerData`)
    return DateTimeUtil.appPowerData;
  }
}
