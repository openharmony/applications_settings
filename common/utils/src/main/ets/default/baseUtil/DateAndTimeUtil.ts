/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
/**
 * date package tool class
 */

import ConfigData from './ConfigData';
import i18n from '@ohos.i18n';
import Intl from "@ohos.intl";

export class DateAndTimeUtil {
  getSystemTime(isUsing24hFormat: boolean) {
    let datetime = new Date();

    // @ts-ignore
    var datefmt= new Intl.DateTimeFormat(i18n.getSystemLanguage(), { timeStyle: 'short' });
    return datefmt.format(datetime);
  }

  getSystemDate() {
    let datetime = new Date();

    // @ts-ignore
    var datefmt= new Intl.DateTimeFormat(i18n.getSystemLanguage(), { dateStyle: 'long' });
    return datefmt.format(datetime);
  }

  fill(value) {
    return (value > 9 ? "" : "0") + value;
  };

  concatDate(year, month, date) {
    let nYear = AppStorage.Get(ConfigData.DATE_AND_TIME_YEAR);
    let nMonth = AppStorage.Get(ConfigData.DATE_AND_TIME_MONTH);
    let nDay = AppStorage.Get(ConfigData.DATE_AND_TIME_DAY);
    return year + nYear + month + nMonth + date + nDay;
  };

  concatTime(hours, minutes) {
    return `${this.fill(hours)}:${this.fill(minutes)}`;
  };

  convert(y, m, d) {
    if (m == 1 || m == 2) {
      m += 12;
      y--;
    }
    let a = 3 * (m + 1) / 5;
    let b = y / 4
    let c = y / 100
    let e = y / 400
    const week = (d + 2 * m + Math.floor(a) + y + Math.floor(b)
    - Math.floor(c) + Math.floor(e) + 1) % 7;
    switch (week) {
      case 0:
        return $r('app.string.sunday');
        break;
      case 1:
        return $r('app.string.monday');
        break;
      case 2:
        return $r('app.string.tuesday');
        break;
      case 3:
        return $r('app.string.wednesday');
        break;
      case 4:
        return $r('app.string.thursday');
        break;
      case 5:
        return $r('app.string.friday');
        break;
      case 6:
        return $r('app.string.saturday');
        break;
      default:
        break;
    }
  };
}

let dateAndTimeUtil = new DateAndTimeUtil();
export default dateAndTimeUtil as DateAndTimeUtil
