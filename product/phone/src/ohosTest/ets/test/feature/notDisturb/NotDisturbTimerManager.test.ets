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
import { CheckEmptyUtils, SettingsDataUtils } from '@ohos/settings.common';
import { NotDisturbTimerManager, NotDisturbTimerPararm } from '@ohos/settings.notDisturb';

export default function NotDisturbTimerManagerTest() {
  describe('NotDisturbTimerManagerTest', () => {

    let notDisturbTimerManager = NotDisturbTimerManager.getInstance();

    it('test_getInstance', 0, (): void => {
      let manager1 = NotDisturbTimerManager.getInstance();
      let manager2 = NotDisturbTimerManager.getInstance();
      expect(manager1 === manager2).assertTrue();
      let mocker: MockKit = new MockKit();
      let contextfunc: Function = mocker.mockFunc(CheckEmptyUtils,CheckEmptyUtils.isEmpty);
      when(contextfunc)(ArgumentMatchers.any).afterReturn(true);
      let context = NotDisturbTimerManager.getContext();
      expect(context !== null).assertTrue();
      mocker.clear(CheckEmptyUtils);
      context = NotDisturbTimerManager.getContext();
      expect(context !== null).assertTrue();
      mocker.clear(CheckEmptyUtils);
    })

    it('test_checkTimerResources', 0, (): void => {
      let resA:Object = (notDisturbTimerManager as object)['stopAlarmSelf'](-1);
      expect(resA === null).assertFalse();
      let resB:Object = (notDisturbTimerManager as object)['stopAlarmSelf'](200);
      expect(resB === null).assertFalse();
    })

    it('test_stopAlarmSelf', 0, (): void => {
      let resA:Object = (notDisturbTimerManager as object)['stopAlarmSelf'](-1);
      expect(resA === null).assertFalse();
      let resB:Object = (notDisturbTimerManager as object)['stopAlarmSelf'](200);
      expect(resB === null).assertFalse();
    })

    it('test_getTimers', 0, (): void => {
      let par: Context = AppStorage.get<Context>('') as Context;
      let resA = notDisturbTimerManager.getTimers(par);
      expect(resA === null).assertFalse();
      par = NotDisturbTimerManager.getContext();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsDataWithContext);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
      let resB = notDisturbTimerManager.getTimers(par);
      expect(resB === null).assertFalse();
      when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
      let resC = notDisturbTimerManager.getTimers(par);
      expect(resC === null).assertFalse();
      mocker.clear(SettingsDataUtils);
    })

    it('test_getTimerById', 0, (): void => {
      let zenTimersArrays: NotDisturbTimerPararm[] = [];
      let obj: NotDisturbTimerPararm = new NotDisturbTimerPararm();
      for (let i: number=0; i<3; i++) {
        obj.id = i;
        zenTimersArrays.push(obj);
      }
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(notDisturbTimerManager, notDisturbTimerManager.getTimers);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(JSON.stringify(zenTimersArrays));
      let par: Context = NotDisturbTimerManager.getContext();
      let resA = notDisturbTimerManager.getTimerById(par, 1);
      expect(resA === null).assertFalse();
      let resB = notDisturbTimerManager.getTimerById(par, 7);
      expect(resB === null).assertTrue();
      mocker.clear(notDisturbTimerManager);
    })

    it('test_initOtherConfig', 0, async (): Promise<void> => {
      let par: Context = AppStorage.get<Context>('') as Context;
      let resA = await notDisturbTimerManager.initOtherConfig(par, false);
      expect(resA === null).assertFalse();
      par = NotDisturbTimerManager.getContext();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsDataWithContext);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
      let resB = await notDisturbTimerManager.initOtherConfig(par, true);
      expect(resB === null).assertFalse();
      when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
      mocker.clear(SettingsDataUtils);
    })

    it('test_queryTrustAppDataInfo', 0, async (): Promise<void> => {
      let resA = await notDisturbTimerManager.queryTrustAppDataInfo();
      expect(resA === null).assertFalse();
    })

    it('test_isNotDisturbWhiteApp', 0, async (): Promise<void> => {
      let resA:Object = await (notDisturbTimerManager as object)['isNotDisturbWhiteApp']('com.ohos.settings');
      expect(resA === false).assertTrue();
      let resB:Object = await (notDisturbTimerManager as object)['isNotDisturbWhiteApp']('com.ohos.clock');
      expect(resB === false).assertFalse();
      let resC:Object = await (notDisturbTimerManager as object)['isNotDisturbWhiteApp']('com.ohos.mms');
      expect(resC === true).assertFalse();
      let resD:Object = await (notDisturbTimerManager as object)['isNotDisturbWhiteApp']('haha');
      expect(resD === true).assertFalse();
    })

    it('test_closeTypeOncesDb', 0, (): void => {
      let zenTimersArrays: NotDisturbTimerPararm[] = [];
      let obj: NotDisturbTimerPararm = new NotDisturbTimerPararm();
      for (let i: number = 0; i < 3; i++) {
        i % 2 === 0 ? obj.isOpen = true : obj.isOpen = false;
        i % 2 === 0 ? obj.repeatType = 0 : obj.repeatType = 1;
        i === 0 ? obj.skipEndTime = 0 : i === 1 ? obj.skipEndTime = 1 : obj.skipEndTime = new Date().getTime();
        i === 0 ? obj.startTime = '00:00' : obj.startTime = '08:00';
        zenTimersArrays.push(obj);
      }
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(notDisturbTimerManager, notDisturbTimerManager.getTimers);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(zenTimersArrays);
      let resA = notDisturbTimerManager.closeTypeOncesDb(false);
      expect(resA === null).assertFalse();
      let resB = notDisturbTimerManager.closeTypeOncesDb(true);
      expect(resB === null).assertFalse();
      mocker.clear(notDisturbTimerManager);
    })

    it('test_closeNowChange', 0, (): void => {
      let date: Date = new Date();
      let nowTime: number = date.getTime();
      let zenTimersArrays: NotDisturbTimerPararm[] = [];
      let obj: NotDisturbTimerPararm = new NotDisturbTimerPararm();
      for (let i: number = 0; i < 3; i++) {
        i % 2 === 0 ? obj.isOpen = true : obj.isOpen = false;
        i % 2 === 0 ? obj.repeatType = 0 : obj.repeatType = 1;
        i === 0 ? obj.skipEndTime = 0 : i === 1 ? obj.skipEndTime = 1 : obj.skipEndTime = new Date().getTime();
        i === 0 ? obj.startTime = '00:00' : obj.startTime = '08:00';
        zenTimersArrays.push(obj);
      }
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(notDisturbTimerManager, notDisturbTimerManager.getTimers);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(zenTimersArrays);
      let resA = notDisturbTimerManager.closeNowChange(nowTime, false);
      expect(resA === null).assertFalse();
      let resB = notDisturbTimerManager.closeNowChange(nowTime, true);
      expect(resB === null).assertFalse();
      mocker.clear(notDisturbTimerManager);
    })

    it('test_refreshTimer', 0, async (): Promise<void> => {
      let zenTimers:NotDisturbTimerPararm[] = [];
      let resA = await notDisturbTimerManager.refreshTimer(false, zenTimers);
      expect(resA === null).assertFalse();
      let obj: NotDisturbTimerPararm = new NotDisturbTimerPararm();
      for (let i: number = 0; i < 3; i++) {
        zenTimers.push(obj);
      }
      let resB = await notDisturbTimerManager.refreshTimer(true, zenTimers);
      expect(resB === null).assertFalse();
    })

    it('test_calNextTime', 0, (): void => {
      let zenTimers:NotDisturbTimerPararm[] = [];
      let resA = notDisturbTimerManager.calNextTime(zenTimers);
      expect(resA === null).assertFalse();
      let obj: NotDisturbTimerPararm = new NotDisturbTimerPararm();
      for (let i: number = 0; i < 3; i++) {
        i % 2 === 0 ? obj.isOpen = true : obj.isOpen = false;
        i === 0 ? obj.skipEndTime = 0 : i === 1 ? obj.skipEndTime = 1 : obj.skipEndTime = new Date().getTime();
        i === 0 ? obj.startTime = '00:00' : obj.startTime = '08:00';
        zenTimers.push(obj);
      }
      let resB = notDisturbTimerManager.calNextTime(zenTimers);
      expect(resB === null).assertFalse();
    })

    it('test_isCheckStartTimeWithNow', 0, (): void => {
      let resA = notDisturbTimerManager.isCheckStartTimeWithNow('2025-12-30', 0);
      expect(resA === false).assertTrue();
      let resB = notDisturbTimerManager.isCheckStartTimeWithNow('2025-12-30', 90000000000000000000);
      expect(resB === false).assertTrue();
      let resC = notDisturbTimerManager.isCheckStartTimeWithNow('2000-12-30', 0);
      expect(resC === false).assertTrue();
    })

    it('test_setTimerStatus', 0, (): void => {
      let context:Context = NotDisturbTimerManager.getContext();
      let resA = notDisturbTimerManager.setTimerStatus(context, 10000000, 1000000000, true);
      expect(resA === null).assertFalse();
      let resB = notDisturbTimerManager.setTimerStatus(context, 1000000000, 90000000000000000000, true);
      expect(resB === null).assertFalse();
      let resC = notDisturbTimerManager.setTimerStatus(context, 10000000000000000000, 9, false);
      expect(resC === null).assertFalse();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsDataWithContext);
      when(mockfunc)(ArgumentMatchers.any).afterReturn('1');
      let resD = notDisturbTimerManager.setTimerStatus(context, 10000000000000000000, 90000000000000000000, false);
      expect(resD === null).assertFalse();
      let resE = notDisturbTimerManager.setTimerStatus(context, 1, 90000000000000000000, false);
      expect(resE === null).assertFalse();
      mocker.clear(SettingsDataUtils);
    })

    it('test_isNotDisturbOpen', 0, (): void => {
      let par: Context = AppStorage.get<Context>('null') as Context;
      let resA = notDisturbTimerManager.isNotDisturbOpen(par);
      expect(resA === false).assertTrue();
      par = AppStorage.get<Context>('isNotDisturbOpen') as Context;
      let resB = notDisturbTimerManager.isNotDisturbOpen(par);
      expect(resB === false).assertTrue();
      let a: Context = NotDisturbTimerManager.getContext();
      let resC = notDisturbTimerManager.isNotDisturbOpen(a);
      expect(resC === false).assertTrue();
    })

  })
}