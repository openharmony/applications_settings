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

import {
  afterAll,
  beforeAll,
  describe,
  expect,
  it
} from '@ohos/hypium';
import i18n from '@ohos.i18n';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { Constants } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { SearchDataController } from '../../../../../Index';
import { TestUtil } from '../TestUtil';

const TAG: string = 'SearchControllerTest: ';

export default function SearchControllerTest() {
  describe('SearchControllerTest', () => {
    beforeAll(async () => {
      TestUtil.startSettingsAbility(TAG);
    });

    afterAll(async () => {
      TestUtil.clearSettings();
    });

    /*
    * @tc.number: initSearchData
    * @tc.name: 搜索数据表操作.
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 搜索数据库表操作，由于操作存在顺序，放在一个用例执行.
    */
    it('initSearchData', 0, async () => {
      await SearchDataController.initSearchTable();

      await PreferencesUtil.delete(`ClearItemInfoTable${Constants.ITEMINFO_TABLE_VERSION}`);
      await SearchDataController.deleteSearchData();
      await PreferencesUtil.delete(`ItemInfo${i18n.System.getSystemLocale()}${Constants.ITEMINFO_TABLE_VERSION}`);
      await SearchDataController.initSearchData();
      expect(PreferencesUtil.hasSync(`ItemInfo${i18n.System.getSystemLocale()}${Constants.ITEMINFO_TABLE_VERSION}`)).assertTrue();
      await PreferencesUtil.delete(`ItemInfo${i18n.System.getSystemLocale()}${Constants.ITEMINFO_TABLE_VERSION}`);

      await PreferencesUtil.delete(`InitUpdateItemInfo${Constants.ITEMINFO_TABLE_VERSION}`);
      await SearchDataController.updateSearchData();
      expect(PreferencesUtil.hasSync(`InitUpdateItemInfo${Constants.ITEMINFO_TABLE_VERSION}`)).assertTrue();
      await PreferencesUtil.delete(`InitUpdateItemInfo${Constants.ITEMINFO_TABLE_VERSION}`);

      await PreferencesUtil.delete(`ClearItemInfoTable${Constants.ITEMINFO_TABLE_VERSION}`);
      await SearchDataController.deleteSearchData();
      expect(PreferencesUtil.hasSync(`ClearItemInfoTable${Constants.ITEMINFO_TABLE_VERSION}`)).assertTrue();
      await SearchDataController.deleteSearchData();
      await PreferencesUtil.delete(`ClearItemInfoTable${Constants.ITEMINFO_TABLE_VERSION}`);
    })

    /*
    * @tc.number: SearchControllerGetSearchResult
    * @tc.name: 获取搜索结果.
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 获取搜索结果.
    */
    it('getSearchResult', 0, async () => {
      let result = await SearchDataController.getSearchResult('');
      expect(result.length).assertEqual(0);
      result = await SearchDataController.getSearchResult('test#*');
      expect(result.length).assertEqual(0);
    })
  })
}