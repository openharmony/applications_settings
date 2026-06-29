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
import intl from '@ohos.intl';
/* instrument ignore file */
class TimeZoneExtensionTPManager {
  public timeZoneInfoObject: BasicTimeZoneExtensionInfo = new BasicTimeZoneExtensionInfo();
  public timeZoneCityItemArray: Array<I18n.TimeZoneCityItem> = [];

  getTimeZoneInfo(locale: string, isFirstLoading: Boolean, firstLoadNum: number): BasicTimeZoneExtensionInfo {
    // 获取底层时区信息
    if (this.timeZoneCityItemArray.length < 1) {
      this.timeZoneCityItemArray = I18n.SystemLocaleManager.getTimeZoneCityItemArray();
    }

    let cityId: string;
    let timeZone: I18n.TimeZone;
    let rawOffSet: string = '';

    let is24hFormat: boolean = I18n.is24HourClock();
    let itemCount: number = 0;
    for (let timeZoneCityItem of this.timeZoneCityItemArray) {
      cityId = timeZoneCityItem.cityId;
      timeZone = I18n.TimeZone.getTimezoneFromCity(cityId);
      let getTimeInfoFlag: boolean = (isFirstLoading && itemCount < firstLoadNum) ||
        (!isFirstLoading && itemCount >= firstLoadNum);
      if (getTimeInfoFlag) {
        let currentDateFormat: intl.DateTimeFormat = new intl.DateTimeFormat(locale, { month: 'long', day: 'numeric' });
        let dateFormat: intl.DateTimeFormat = new intl.DateTimeFormat(locale.toString(), {
          month: 'long',
          day: 'numeric',
          timeZone: timeZone.getID()
        });
        let timeFormat: intl.DateTimeFormat = new intl.DateTimeFormat(locale.toString(), {
          timeStyle: 'short',
          hour12: !is24hFormat,
          timeZone: timeZone.getID()
        });
        let obj: Date = new Date();
        let currentDate: string = currentDateFormat.format(obj);
        let date: string = dateFormat.format(obj);
        let time: string = timeFormat.format(obj);
        if (date === currentDate) {
          rawOffSet = time;
        } else {
          rawOffSet = date + ' ' + time;
        }
      }

      if (isFirstLoading) {
        // 第一次加载push数据
        this.timeZoneInfoObject.keyArray.push(cityId);
        this.timeZoneInfoObject.titleArray.push(timeZoneCityItem.cityDisplayName);
        if (itemCount < firstLoadNum) {
          this.timeZoneInfoObject.clockSummary.push(rawOffSet);
        } else {
          this.timeZoneInfoObject.clockSummary.push(' ');
        }
        this.timeZoneInfoObject.extra.push(cityId);
      } else {
        // 第二次只替换clockSummary讯息
        this.timeZoneInfoObject.clockSummary[itemCount] = rawOffSet;
      }
      itemCount++;
    }

    return this.timeZoneInfoObject;
  }
}

export class BasicTimeZoneExtensionInfo {
  public keyArray: Array<string> = [];
  public titleArray: Array<string> = [];
  public clockSummary: Array<string> = [];
  public extra: Array<string> = [];
}

export default new TimeZoneExtensionTPManager();