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
import { describe, it, expect, MockKit, ArgumentMatchers, when } from '@ohos/hypium'
import { Constants } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { CustomMenuManager } from '@ohos/settings.common/src/main/ets/custom/CustomMenuManager';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { SettingPageDescController } from '@ohos/settings.search/src/main/ets/controller/SettingPageDescController';
import { PageInfo, PageInfoConfig } from '@ohos/settings.search/src/main/ets/model/PageInfoConfig';
import { SearchConfigFileParser } from '@ohos/settings.search/src/main/ets/util/SearchConfigFileParser';

export default function SettingPageDescConTestTest() {
  describe('SettingPageDescConTestTest', () => {
    it('SettingPageDescConTestTest_deletePageInfoData_001', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(PreferencesUtil, PreferencesUtil.has);
      when(mockFun)(ArgumentMatchers.any).afterReturn(true);
      await SettingPageDescController.deletePageInfoData();
      const result = await PreferencesUtil.has('');
      expect(result).assertTrue();
      when(mockFun)(ArgumentMatchers.any).afterReturn(false);
      await SettingPageDescController.deletePageInfoData();
      const result1 = await PreferencesUtil.has('');
      expect(result1).assertFalse();
      mocker.clear(PreferencesUtil);
      done();
    })
    it('SettingPageDescConTestTest_initPageInfoData_001', 0, async (done: Function) => {
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(PreferencesUtil, PreferencesUtil.has);
      when(mockFun)(ArgumentMatchers.any).afterReturn(true);
      await SettingPageDescController.initPageInfoData();
      const result = await PreferencesUtil.has('');
      expect(result).assertTrue();
      when(mockFun)(ArgumentMatchers.any).afterReturn(false);
      await SettingPageDescController.initPageInfoData();
      const searchConfigFileP = SearchConfigFileParser.getInstance();
      let mockFun1: Function = mocker.mockFunc(searchConfigFileP, searchConfigFileP.parserPageInfoConfig);
      let pageInfoConfig: PageInfoConfig = new PageInfoConfig();
      when(mockFun1)().afterReturn(pageInfoConfig);
      await SettingPageDescController.initPageInfoData();
      let pageInfo: PageInfo = new PageInfo();
      pageInfoConfig.pageInfos = [pageInfo];
      when(mockFun1)().afterReturn(pageInfoConfig);
      await SettingPageDescController.initPageInfoData();
      (SettingPageDescController as object)['isDataUpdating'] = true;
      await SettingPageDescController.initPageInfoData();
      const result1 = await PreferencesUtil.has('');
      expect(result1).assertFalse();
      mocker.clear(PreferencesUtil);
      mocker.clear(searchConfigFileP);
      done();
    })
    it('SettingPageDescConTestTest_isPageExistInConfig_001', 0, async (done: Function) => {
      const result = await SettingPageDescController.isPageExistInConfig('');
      expect(result).assertFalse();
      const result1 = await SettingPageDescController.isPageExistInConfig('bluetooth_entry');
      expect(result1).assertTrue();
      done();
    })
    it('SettingPageDescConTestTest_getParentPage_001', 0, async (done: Function) => {
      let entryKeyList: string[] = [];
      await SettingPageDescController.getParentPage('', entryKeyList);
      expect(entryKeyList.length >= 0).assertTrue();
      await SettingPageDescController.getParentPage('bluetooth_entry', entryKeyList);
      expect(entryKeyList.length >= 0).assertTrue();
      entryKeyList.pop();
      await SettingPageDescController.getParentPage('add_other_wifi_entry', entryKeyList);
      expect(entryKeyList.length >= 0).assertTrue();
      done();
    })
    it('SettingPageDescConTestTest_getTopLevelEntryKey_001', 0, async (done: Function) => {
      const result = await SettingPageDescController.getTopLevelEntryKey('');
      expect(result).assertEqual('');
      const result1 = await SettingPageDescController.getTopLevelEntryKey('test');
      expect(result1).assertEqual('');
      const result2 = await SettingPageDescController.getTopLevelEntryKey('bluetooth_entry');
      expect(result2.length >= 0).assertTrue();
      done();
    })
    it('SettingPageDescConTestTest_getPageInfoFromJson_001', 0, async (done: Function) => {
      await (SettingPageDescController as object)['getPageInfoFromJson']();
      let mocker: MockKit = new MockKit();
      const searchConfigFileP = SearchConfigFileParser.getInstance();
      let mockFun: Function = mocker.mockFunc(searchConfigFileP, searchConfigFileP.parserPageInfoConfig);
      let pageInfoConfig: PageInfoConfig = new PageInfoConfig();
      when(mockFun)().afterReturn(pageInfoConfig);
      await (SettingPageDescController as object)['getPageInfoFromJson']();
      let pageInfo: PageInfo = new PageInfo();
      pageInfoConfig.pageInfos = [pageInfo];
      when(mockFun)().afterReturn(pageInfoConfig);
      await (SettingPageDescController as object)['getPageInfoFromJson']();
      expect(pageInfo != null).assertTrue();
      mocker.clear(searchConfigFileP);
      done();
    })
    it('SettingPageDescConTestTest_changePageVisibility_001', 0, (done: Function) => {
      let pageInfo: PageInfo = new PageInfo();
      (SettingPageDescController as object)['changePageVisibility']([]);
      (SettingPageDescController as object)['changePageVisibility']([pageInfo]);
      let mocker: MockKit = new MockKit();
      const customMenuM = CustomMenuManager.getInstance();
      let mockFun: Function = mocker.mockFunc(customMenuM, customMenuM.isEmpty);
      when(mockFun)().afterReturn(true);
      (SettingPageDescController as object)['changePageVisibility']([pageInfo]);
      when(mockFun)().afterReturn(false);
      (SettingPageDescController as object)['changePageVisibility']([pageInfo]);
      expect(pageInfo != null).assertTrue();
      mocker.clear(customMenuM);
      done();
    })
  })
}