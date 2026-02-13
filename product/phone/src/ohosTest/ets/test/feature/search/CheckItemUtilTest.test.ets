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
import { describe, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium'
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { CheckItem, SearchItem } from '@ohos/settings.search/src/main/ets/model/SearchPageConfig';
import { CheckItemUtil } from '@ohos/settings.search/src/main/ets/util/CheckItemUtil';

export default function CheckItemUtilTestTest() {
  describe('CheckItemUtilTestTest', () => {
    it('CheckItemUtilTestTest_checkItemEnable_001', 0, async (done: Function) => {
      let searchItemU: SearchItem = AppStorage.get<SearchItem>('searchItem') as SearchItem;
      const result = await CheckItemUtil.checkItemEnable(searchItemU);
      expect(result).assertFalse();
      done();
    })
    let searchItem: SearchItem = new SearchItem();
    it('CheckItemUtilTestTest_checkItemEnable_002', 0, async (done: Function) => {
      const result = await CheckItemUtil.checkItemEnable(searchItem);
      expect(result).assertTrue();
      searchItem.enable = 'true';
      const result1 = await CheckItemUtil.checkItemEnable(searchItem);
      expect(result1).assertTrue();
      let checkI: CheckItem = new CheckItem();
      const result2 = await CheckItemUtil.checkItemEnable(searchItem);
      expect(result2).assertTrue();
      searchItem.checkItem = checkI;
      searchItem.checkItem.type = 'testType';
      const result3 = await CheckItemUtil.checkItemEnable(searchItem);
      expect(result3).assertTrue();
      done();
    })
    it('CheckItemUtilTestTest_checkItemEnable_003', 0, async (done: Function) => {
      searchItem.checkItem.checkKey = 'testCheckKey';
      searchItem.checkItem.value = 'testValue';
      const result = await CheckItemUtil.checkItemEnable(searchItem);
      expect(result).assertTrue();
      done();
    })
    it('CheckItemUtilTestTest_checkItemEnable_004', 0, async (done: Function) => {
      searchItem.checkItem.type = CheckType.FUNCTION;
      const result = await CheckItemUtil.checkItemEnable(searchItem);
      expect(result).assertTrue();
      searchItem.checkItem.checkKey = 'isSupportVibrate';
      const result1 = await CheckItemUtil.checkItemEnable(searchItem);
      expect(result1).assertFalse();
      searchItem.checkItem.value = 'true';
      const result2 = await CheckItemUtil.checkItemEnable(searchItem);
      expect(result2).assertTrue();
      done();
    })
    let mocker: MockKit = new MockKit();
    it('CheckItemUtilTestTest_checkItemEnable_005', 0, async (done: Function) => {
      searchItem.checkItem.type = CheckType.SETTINGDATA;
      let mockFun: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
      when(mockFun)(ArgumentMatchers.any).afterReturn('true');
      const result = await CheckItemUtil.checkItemEnable(searchItem);
      expect(result).assertTrue();
      when(mockFun)(ArgumentMatchers.any).afterReturn('false');
      const result1 = await CheckItemUtil.checkItemEnable(searchItem);
      expect(result1).assertFalse();
      mocker.clear(SettingsDataUtils);
      done();
    })
    it('CheckItemUtilTestTest_checkItemEnable_006', 0, async (done: Function) => {
      searchItem.checkItem.type = CheckType.PREFERENCE;
      let mockFun: Function = mocker.mockFunc(PreferencesUtil, PreferencesUtil.getSync);
      when(mockFun)(ArgumentMatchers.any).afterReturn('true');
      const result = await CheckItemUtil.checkItemEnable(searchItem);
      expect(result).assertTrue();
      when(mockFun)(ArgumentMatchers.any).afterReturn('false');
      const result1 = await CheckItemUtil.checkItemEnable(searchItem);
      expect(result1).assertFalse();
      mocker.clear(PreferencesUtil);
      done();
    })
    it('CheckItemUtilTestTest_checkItemEnable_007', 0, async (done: Function) => {
      searchItem.checkItem.type = CheckType.PARAM;
      searchItem.checkItem.value = 'testValue';
      const result = await CheckItemUtil.checkItemEnable(searchItem);
      expect(result).assertFalse();
      searchItem.checkItem.value = 'true|false';
      const result1 = await CheckItemUtil.checkItemEnable(searchItem);
      expect(result1).assertFalse();
      done();
    })
  })
}

enum CheckType {
  PARAM = 'param',
  PREFERENCE = 'preference',
  SETTINGDATA = 'settingData',
  FUNCTION = 'function'
}
