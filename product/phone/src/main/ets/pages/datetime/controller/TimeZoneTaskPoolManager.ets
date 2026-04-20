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
/* instrument ignore file */
class TimeZoneTPManager {
  public timeZoneInfoObject: BasicTimeZoneInfo = new BasicTimeZoneInfo()
  public readonly RAW_OFFSET_HOUR_MOD: number = 3600000;
  public readonly RAW_OFFSET_MINUTE_MOD: number = 60000;
  public readonly GMT_REG_EXP_STRING: string = 'GMT%1$s%2$s:%3$s';

  getStringSync(resource: ResourceStr): string {
    if (!resource) {
      return '';
    }
    if (typeof resource === 'string') {
      return resource;
    }
    let resourceManager = (AppStorage.get<Context>('pageContext') as Context)?.resourceManager;
    if (!resourceManager) {
      return '';
    }
    return resourceManager.getStringSync(resource.id);
  }

  getAnyStrFormatStringSync(resource: string, ...subStrs: Array<string>): string {
    let result = resource;
    if (!result) {
      return '';
    }
    for (let i = 0; i < subStrs.length; i++) {
      result = result.replace(new RegExp('%' + (i + 1) + '\\$s', 'gm'), subStrs[i]);
    }
    return result;
  }

  /*
    * 当前TaskPool有如下限制：
    *   1. 不可用globalThis属性，故需要将globalThis相关的内容作为参数传入
    *   2. 尽量避免函数调用，尽量在同一个函数中完成工作
    *   3. 复杂类需要以import的形式导入，不可在taskpool.execute同个文件中定义
   */
  getTimeZoneInfo(): BasicTimeZoneInfo {
    // 获取底层时区信息
    let timeZoneCityItemArray: I18n.TimeZoneCityItem[] = I18n.SystemLocaleManager.getTimeZoneCityItemArray();

    this.timeZoneInfoObject.keyArray = [];
    this.timeZoneInfoObject.titleArray = [];
    this.timeZoneInfoObject.settingSummary = [];
    this.timeZoneInfoObject.clockSummary = [];
    this.timeZoneInfoObject.extra = [];

    let cityId: string;
    let rawOffSet: string;

    for (let timeZoneCityItem of timeZoneCityItemArray) {
      cityId = timeZoneCityItem.cityId
      let offset: number = timeZoneCityItem.offset;
      let flag: string = offset >= 0 ? '+' : '-';
      let hour: number = Math.trunc(Math.abs(offset) / this.RAW_OFFSET_HOUR_MOD);
      let minute: number = Math.trunc((Math.abs(offset) % this.RAW_OFFSET_HOUR_MOD) / this.RAW_OFFSET_MINUTE_MOD);
      if (hour === 0 && minute === 0) {
        rawOffSet = this.getAnyStrFormatStringSync(this.GMT_REG_EXP_STRING, flag, '0', '00');
      } else if (minute === 0) {
        rawOffSet = this.getAnyStrFormatStringSync(this.GMT_REG_EXP_STRING, flag, hour.toString(), '00');
      } else if (hour === 0) {
        rawOffSet = this.getAnyStrFormatStringSync(this.GMT_REG_EXP_STRING, flag, '0', minute.toString());
      } else {
        rawOffSet = this.getAnyStrFormatStringSync(this.GMT_REG_EXP_STRING, flag, hour.toString(), minute.toString());
      }
      // 插入信息
      this.timeZoneInfoObject.keyArray.push(cityId);
      this.timeZoneInfoObject.titleArray.push(timeZoneCityItem.cityDisplayName)
      this.timeZoneInfoObject.settingSummary.push(rawOffSet)
      this.timeZoneInfoObject.extra.push(cityId)
    }
    return this.timeZoneInfoObject;
  }
}

export class BasicTimeZoneInfo {
  public keyArray: string[] = [];
  public titleArray: string[] = [];
  public settingSummary: string[] = [];
  public clockSummary: string[] = [];
  public extra: string[] = [];
}

export default new TimeZoneTPManager()