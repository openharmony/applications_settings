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

import { DateAndTimeUtil } from '@ohos/settings.datetime/src/main/ets/utils/DateAndTimeUtil';


export default function dateAndTimeUtilTest() {
  describe('dateAndTimeUtilTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {

    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('test_set24HourTimFormat', 0, () => {
      let result = DateAndTimeUtil.set24HourTimFormat(false);
      expect(result === true ).assertTrue();
    });

    it('test_getFixedTime', 0, () => {
      let result: TimePickerResult = AppStorage.get<TimePickerResult>('null') as TimePickerResult;
      let resA = DateAndTimeUtil.getFixedTime(result);
      expect(resA === null).assertFalse();
      result = {
        hour: new Date().getHours(),
        minute: 5,
        second: 1
      };
      let resB = DateAndTimeUtil.getFixedTime(result);
      expect(resB === null).assertFalse();
    });

    getPerSecondInMillis();
    getPerMinInMillis();
    getPerHourInMillis();
    getPerDayInMillis();
    getSystemDateInMills();
    get24HourTimeFormat();
    set24HourTimFormat();
    getSystemDateInMills02();
    getSystemTime01();
    getSystemTime02();
    getSystemDate();
    getFixedTime();
    recordCurrentDate();
  })
}

function recordCurrentDate() {
  it('DateAndTimeUtilTest_recordCurrentDate', 0, () => {
    let res = 'test';
    DateAndTimeUtil.recordCurrentDate();
    expect(res).not().assertNull();
  });
}

function getFixedTime() {
  it('DateAndTimeTest_getFixedTime', 0, () => {
    let result: TimePickerResult = {
      hour: 16,
      minute: 5,
      second: 1
    };
    let fixedTime = DateAndTimeUtil.getFixedTime(result);
    expect(fixedTime.getHours()).assertEqual(result.hour);
    expect(fixedTime.getMinutes()).assertEqual(result.minute);
  });
}

function getSystemDate() {
  it('DateAndTimeTest_getSystemDate', 0, () => {
    let date: string = DateAndTimeUtil.getSystemDate();
    expect(date).not().assertNull();
  });
}

function getSystemTime02() {
  it('DateAndTimeUtilTest_getSystemTime_02', 0, () => {
    let res = DateAndTimeUtil.getSystemTime(false);
    expect(res).not().assertNull();
  });
}

function getSystemTime01() {
  it('DateAndTimeUtilTest_getSystemTime_01', 0, () => {
    let res = DateAndTimeUtil.getSystemTime(true);
    expect(res).not().assertNull();
  });
}

function getSystemDateInMills02() {
  it('DateAndTimeUtilTest_setTime', 0, async () => {
    expect(DateAndTimeUtil.getSystemDateInMills()).not().assertUndefined();
  });
}

function set24HourTimFormat() {
  it('DateAndTimeUtilTest_set24HourTimFormat', 0, () => {
    let result = DateAndTimeUtil.set24HourTimFormat(true);
    expect(result === true ).assertTrue();
  });
}

function get24HourTimeFormat() {
  it('DateAndTimeTest_get24HourTimeFormat', 0, () => {
    let res = DateAndTimeUtil.get24HourTimeFormat();
    expect(res).assertEqual(false);
  });
}

function getSystemDateInMills() {
  it('DateAndTimeUtilTest_getSystemDateInMills', 0, () => {
    let currentTime = DateAndTimeUtil.getSystemDateInMills();
    expect(currentTime).assertInstanceOf('Number');
  });
}

function getPerDayInMillis() {
  it('DateAndTimeUtilTest_getPerDayInMillis', 0, () => {
    const result: number = DateAndTimeUtil.getPerDayInMillis();
    const expectedResult: number = DateAndTimeUtil.getPerHourInMillis() * 24;
    expect(result).assertEqual(expectedResult);
  });
}

function getPerHourInMillis() {
  it('DateAndTimeUtilTest_getPerHourInMillis', 0, () => {
    const expectedms = DateAndTimeUtil.getPerMinInMillis() * 60;
    const ms = DateAndTimeUtil.getPerHourInMillis();
    expect(ms).assertEqual(expectedms);
  });
}

function getPerMinInMillis() {
  it('DateAndTimeUtilTest_getPerMinInMillis', 0, () => {
    const expectedms = DateAndTimeUtil.getPerSecondInMillis() * 60;
    const ms = DateAndTimeUtil.getPerMinInMillis();
    expect(ms).assertEqual(expectedms);
  });
}

function getPerSecondInMillis() {
  it('DateAndTimeUtilTest_getPerSecondInMillis', 0, () => {
    expect(DateAndTimeUtil.getPerSecondInMillis()).assertEqual(1000);
  });
}
