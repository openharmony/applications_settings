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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, MockKit } from '@ohos/hypium';

import { TimeZoneUtil } from '@ohos/settings.datetime/src/main/ets/utils/TimeZoneUtil';
import i18n from '@ohos.i18n';

export default function timeZoneUtilTest() {
  describe('timeZoneUtilTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {

    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('test_getRawOffsetSummary', 0, () => {
      let timeZone: i18n.TimeZone = i18n.getTimeZone('Asia/Beijing');
      let resA = TimeZoneUtil.getRawOffsetSummary(timeZone, true);
      expect(typeof resA === 'string' ).assertTrue();
      let resB = TimeZoneUtil.getRawOffsetSummary(timeZone, false);
      expect(typeof resB === 'string' ).assertTrue();
      timeZone = i18n.getTimeZone('Asia/Shanghai');
      let resC = TimeZoneUtil.getRawOffsetSummary(timeZone, true);
      expect(typeof resC === 'string' ).assertTrue();
      let resD = TimeZoneUtil.getRawOffsetSummary(timeZone, false);
      expect(typeof resD === 'string' ).assertTrue();
      timeZone = i18n.getTimeZone('America/Los_Angeles');
      let resE = TimeZoneUtil.getRawOffsetSummary(timeZone, true);
      expect(typeof resE === 'string' ).assertTrue();
      let resF = TimeZoneUtil.getRawOffsetSummary(timeZone, false);
      expect(typeof resF === 'string' ).assertTrue();
      timeZone = i18n.getTimeZone('America/Las_Vegas');
      let resG = TimeZoneUtil.getRawOffsetSummary(timeZone, true);
      expect(typeof resG === 'string' ).assertTrue();
      let resH = TimeZoneUtil.getRawOffsetSummary(timeZone, false);
      expect(typeof resH === 'string' ).assertTrue();
    });

    getAvailableTimeZoneIDs();
    getAvailableZoneCityIDs();
    getCityLocalDisplayName();
    getCityDisplayName();
    getTimezoneFromCity();
    getSelectCitySummary();
  })
}

function getSelectCitySummary() {
  it('TimeZoneUtilTest_getSelectCitySummary', 0, () => {
    let timeZone: i18n.TimeZone = i18n.getTimeZone('Asia/Shanghai');
    let locale: string = 'zh-CN';
    let result1 = TimeZoneUtil.getSelectCitySummary(timeZone, locale);
    expect(result1.length).assertLarger(0);
    let locale1: string = 'en-US';
    let result2 = TimeZoneUtil.getSelectCitySummary(timeZone, locale1);
    expect(result2.length).assertLarger(0);
  });
}

function getTimezoneFromCity() {
  it('TimeZoneUtilTest_getTimezoneFromCity', 0, () => {
    let cityId = 'Asia/Shanghai';
    let timezone = TimeZoneUtil.getTimezoneFromCity(cityId);
    let expectedData: i18n.TimeZone = i18n.TimeZone.getTimezoneFromCity(cityId);
    expect(JSON.stringify(timezone)).assertEqual(JSON.stringify(expectedData));
  });
}

function getCityDisplayName() {
  it('TimeZoneUtilTest_getCityDisplayName', 0, () => {
    let cityDisplayName = TimeZoneUtil.getCityDisplayName('Asia/Shanghai', 'en-US');
    expect(cityDisplayName).not().assertUndefined();
  });
}

function getCityLocalDisplayName() {
  it('TimeZoneUtilTest_getCityLocalDisplayName', 0, () => {
    let cityLocalDisplayName = TimeZoneUtil.getCityLocalDisplayName('Asia/Shanghai');
    expect(cityLocalDisplayName).not().assertUndefined();
  });
}

function getAvailableZoneCityIDs() {
  it('TimeZoneUtilTest_getAvailableZoneCityIDs', 0, () => {
    let cityIDs = TimeZoneUtil.getAvailableZoneCityIDs();
    expect(cityIDs).assertInstanceOf('Array');
  });
}

function getAvailableTimeZoneIDs() {
  it('TimeZoneUtilTest_getAvailableTimeZoneIDs', 0, () => {
    let timeZoneIDs = TimeZoneUtil.getAvailableTimeZoneIDs();
    expect(timeZoneIDs).assertInstanceOf('Array');
  });
}
