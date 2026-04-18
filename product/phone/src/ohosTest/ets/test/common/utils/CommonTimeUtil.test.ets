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

import { describe, expect, it } from '@ohos/hypium';
import I18n from '@ohos.i18n';
import Intl from '@ohos.intl';
import { TimeUtil, TimeFormat } from '@ohos/settings.common/src/main/ets/utils/TimeUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

export default function commonTimeUtilTest() {
  describe('CommonTimeUtilTest', () => {
    it('CommonTimeUtilTest_obtainFormatTime0', 0, () => {
      const date: string = TimeUtil.obtainFormatTime('2025-07-28', TimeFormat.MONTH_DAY_NUMERIC);
      expect(date === '7/28').assertTrue();
    })

    it('CommonTimeUtilTest_obtainFormatTime1', 0, () => {
      const date: string = TimeUtil.obtainFormatTime('2025-07-28 10:00:00', TimeFormat.HOUR_MINUTE);
      expect(date.includes('10')).assertTrue();
    })

    it('CommonTimeUtilTest_obtainFormatTime2', 0, () => {
      const date: string = TimeUtil.obtainFormatTime('2025-07-28 10:00:00', TimeFormat.YEAR);
      expect(date === '').assertTrue();
    })

    it('CommonTimeUtilTest_getLocalId', 0, () => {
      const result: string = TimeUtil.getLocalId();
      let locale = new Intl.Locale();
      let localeID = locale.toString();
      expect(result === localeID).assertTrue();
    })

    it('CommonTimeUtilTest_getIs24HourClock', 0, () => {
      const result: boolean = TimeUtil.getIs24HourClock();
      let is24HourClock: boolean = true;
      try {
        is24HourClock = I18n.System.is24HourClock(); // 系统24小时开关是否开启
      } catch (error) {
        LogUtil.error(`CT_getIs24HourClock failed, error code: ${error.code}, message: ${error.message}.`);
      }
      expect(result === is24HourClock).assertTrue();
    })

    it('CommonTimeUtilTest_getTimeZone', 0, () => {
      const result: number = TimeUtil.getTimeZone();
      expect(result !== null).assertTrue();
    })

    it('CommonTimeUtilTest_parseZoneNumberToStr0', 0, () => {
      const result: string = TimeUtil.parseZoneNumberToStr(1);
      expect(result === 'GMT+1:00').assertTrue();
    })

    it('CommonTimeUtilTest_parseZoneNumberToStr1', 0, () => {
      const result: string = TimeUtil.parseZoneNumberToStr(2);
      expect(result === 'GMT+2:00').assertTrue();
    })

    it('CommonTimeUtilTest_parseZoneNumberToStr2', 0, () => {
      const result: string = TimeUtil.parseZoneNumberToStr(-1);
      expect(result === 'GMT-1:00').assertTrue();
    })

    it('CommonTimeUtilTest_parseZoneNumberToStr3', 0, () => {
      const result: string = TimeUtil.parseZoneNumberToStr(0);
      expect(result === 'GMT+0:00').assertTrue();
    })

    it('CommonTimeUtilTest_isToday0', 0, () => {
      const result: boolean = TimeUtil.isToday(new Date('2024-07-28').getDate());
      expect(result === false).assertTrue();
    })
  })
}