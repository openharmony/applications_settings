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

import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { SettingsDataUtils } from '@ohos/settings.common';
import { NotDisturbTimerManager, NotDisturbTimerPararm, NotDisturbUtils } from '@ohos/settings.notDisturb';

export default function NotDisturbUtilsTest() {
  describe('NotDisturbUtilsTest', () => {

    it('test_getDaysOfWeekLabels', 0, async (): Promise<void> => {
      let resA = await NotDisturbUtils.handleHmosToNextNotDisturbRestore();
      expect(resA === null).assertFalse();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(NotDisturbTimerManager, NotDisturbTimerManager.getContext);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(null);
      let resB = await NotDisturbUtils.handleHmosToNextNotDisturbRestore();
      expect(resB === null).assertFalse();
      let mockfunc2: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsDataWithContext);
      when(mockfunc2)(ArgumentMatchers.any).afterReturn(true);
      let resC = await NotDisturbUtils.handleHmosToNextNotDisturbRestore();
      expect(resC === null).assertFalse();
      mocker.clear(SettingsDataUtils);
      mocker.clear(NotDisturbTimerManager);
    })

    it('test_handleNotDisturbRestore', 0, async (): Promise<void> => {
      let mocker: MockKit = new MockKit();
      await NotDisturbUtils.handleNotDisturbRestore('');
      let contextFunc = mocker.mockFunc(NotDisturbTimerManager,NotDisturbTimerManager.getContext);
      let context: Context = AppStorage.get<Context>('pageContext') as Context;
      when(contextFunc)(ArgumentMatchers.any).afterReturn(context);
      let resA = await NotDisturbUtils.handleNotDisturbRestore('');
      expect(resA === null).assertFalse();
      let resB = await NotDisturbUtils.handleNotDisturbRestore('a');
      expect(resB === null).assertFalse();
      let mockfunc: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsDataWithContext);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
      let resC = await NotDisturbUtils.handleNotDisturbRestore('hmos_to_next');
      expect(resC === null).assertFalse();
      when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
      let resD = await NotDisturbUtils.handleNotDisturbRestore('hmos');
      expect(resD === null).assertFalse();
      mocker.clear(SettingsDataUtils);
      mocker.clear(NotDisturbTimerManager);
    })

    it('test_forMatTime', 0, (): void => {
      let resA = NotDisturbUtils.forMatTime('2024-5-31');
      expect(resA === null).assertFalse();
      let resB = NotDisturbUtils.forMatTime('2024');
      expect(resB === null).assertFalse();
    })

    it('test_getNextTime', 0, (): void => {
      let par:NotDisturbTimerPararm = new NotDisturbTimerPararm();
      let resA = NotDisturbUtils.getNextTime(par);
      expect(resA === null).assertFalse();
      par.repeatType = 1;
      par.skipEndTime = 1;
      let resB = NotDisturbUtils.getNextTime(par);
      expect(resB === null).assertFalse();
    })

    it('test_getTimerSummary', 0, (): void => {
      let format:Intl.DateTimeFormat = AppStorage.get<Intl.DateTimeFormat>('null') as Intl.DateTimeFormat;
      let resA = NotDisturbUtils.getTimerSummary(format, '', '');
      expect(resA === '').assertTrue();
      let resB = NotDisturbUtils.getTimerSummary(NotDisturbUtils.getFormat(), '2024-01-01', '2025-12-31');
      expect(typeof resB === 'string').assertTrue();
    })

    it('test_getTimerSummaryForDate', 0, (): void => {
      let format:Intl.DateTimeFormat = AppStorage.get<Intl.DateTimeFormat>('null') as Intl.DateTimeFormat;
      let resA = NotDisturbUtils.getTimerSummaryForDate(format, new Date(''), new Date(''));
      expect(resA === '').assertTrue();
      let resB = NotDisturbUtils.getTimerSummaryForDate(NotDisturbUtils.getFormat(), new Date('2024-01-01'), new Date('2025-12-31'));
      expect(typeof resB === 'string').assertTrue();
    })

    it('test_getZenModeScheduleRepeatText', 0, (): void => {
      let resA = NotDisturbUtils.getZenModeScheduleRepeatText('');
      expect(resA === null).assertFalse();
      let resB = NotDisturbUtils.getZenModeScheduleRepeatText('123');
      expect(typeof resB === 'string').assertTrue();
      let resC = NotDisturbUtils.getZenModeScheduleRepeatText('77');
      expect(typeof resC === 'string').assertTrue();
    })

    it('test_getWeekResourceStr', 0, (): void => {
      let resA:Object = (NotDisturbUtils as object)['getWeekResourceStr'](['1']);
      expect(resA === null).assertFalse();
      let resB:Object = (NotDisturbUtils as object)['getWeekResourceStr'](['1', '2']);
      expect(resB === null).assertFalse();
      let resC:Object = (NotDisturbUtils as object)['getWeekResourceStr'](['1', '2', '3']);
      expect(resC === null).assertFalse();
      let resD:Object = (NotDisturbUtils as object)['getWeekResourceStr'](['1', '2', '3', '4']);
      expect(resD === null).assertFalse();
      let resE:Object = (NotDisturbUtils as object)['getWeekResourceStr'](['1', '2', '3', '4', '5']);
      expect(resE === null).assertFalse();
      let resF:Object = (NotDisturbUtils as object)['getWeekResourceStr'](['1', '2', '3', '4', '5', '6']);
      expect(resF === null).assertFalse();
      let resG:Object = (NotDisturbUtils as object)['getWeekResourceStr'](['1', '2', '3', '4', '5', '6', '7']);
      expect(resG === null).assertFalse();
    })

    it('test_getCurrentLocaleDays', 0, (): void => {
      let resA:Object =
        (NotDisturbUtils as object)['getCurrentLocaleDays']((NotDisturbUtils as object)['getCalendar']());
      expect(resA === null).assertFalse();
    })

    it('test_getScheduleRepeatText', 0, (): void => {
      let resA:Object = (NotDisturbUtils as object)['getScheduleRepeatText']([1, 2, 3, 4, 5, 6, 7]);
      expect(resA === null).assertFalse();
      let resB:Object = (NotDisturbUtils as object)['getScheduleRepeatText']([1, 2, 3, 4, 5, 6]);
      expect(resB === null).assertFalse();
      let resC:Object = (NotDisturbUtils as object)['getScheduleRepeatText']([1, 2, 3, 4, 5]);
      expect(resC === null).assertFalse();
      let resD:Object = (NotDisturbUtils as object)['getScheduleRepeatText']([3, 4, 5, 6, 7]);
      expect(resD === null).assertFalse();
      let resE:Object = (NotDisturbUtils as object)['getScheduleRepeatText']([3, 4, 5, 6]);
      expect(resE === null).assertFalse();
    })

    it('test_getEndTimeSummary', 0, (): void => {
      let resA = NotDisturbUtils.getEndTimeSummary('2025-12-30', '2025-12-31');
      expect(resA === null).assertFalse();
      let resB = NotDisturbUtils.getEndTimeSummary('2025-12-30', '2025-12-29');
      expect(resB === null).assertFalse();
    })

    it('test_setModeStatus', 0, (): void => {
      let resA = NotDisturbUtils.setModeStatus(true);
      expect(resA === null).assertFalse();
      let resB = NotDisturbUtils.setModeStatus(false);
      expect(resB === null).assertFalse();
    })

  })
}