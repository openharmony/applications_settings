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
import { SearchHistoryController } from '../../../../../Index';
import { TestUtil } from '../TestUtil';

const TAG: string = 'SearchHistoryControllerTest: ';

export default function SearchHistoryControllerTest() {
  describe('SearchHistoryControllerTest', () => {
    beforeAll(async () => {
      TestUtil.startSettingsAbility(TAG);
    });

    afterAll(async () => {
      TestUtil.clearSettings();
    });

    /*
    * @tc.number: initSearchData
    * @tc.name: 添加搜索历史记录数据到数据库.
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 添加搜索历史记录数据到数据库.
    */
    it('initSearchData', 0, async () => {
      await SearchHistoryController.initSearchData();
      await SearchHistoryController.deleteSearchData();
      await SearchHistoryController.addSearchData({
        query: 'test_settings',
        timestamp: new Date().getTime()
      });
      let historyData = await SearchHistoryController.getSearchData();
      expect(historyData.length).assertEqual(1);

      await SearchHistoryController.deleteSearchData();
      historyData = await SearchHistoryController.getSearchData();
      expect(historyData.length).assertEqual(0);
    })
  })
}