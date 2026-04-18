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
import { Response } from '@ohos/settings.common/src/main/ets/constant/Response';
import { EnableSearchItems } from '../../../../main/ets/service/EnableSearchItems';
import { SearchItems } from '../../../../main/ets/model/SearchItems';
import { TestUtil } from '../TestUtil';

const TAG: string = 'EnableSearchItemsTest: ';

export default function EnableSearchItemsTest() {
  describe('EnableSearchItemsTest', () => {
    beforeAll(async () => {
      TestUtil.startSettingsAbility(TAG);
    });

    afterAll(async () => {
      TestUtil.clearSettings();
    });

    /*
    * @tc.number: enableSearchItems
    * @tc.name: 使能搜索项.
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 使能搜索项.
    */
    it('enableSearchItems', 0, async () => {
      let enableSearchItem: EnableSearchItems = new EnableSearchItems(true);
      let searchItem: SearchItems = new SearchItems();
      let result = await enableSearchItem.execute(searchItem);
      expect(result === Response.FAIL).assertTrue();

      let itemList: Array<string> = ['WLAN'];
      searchItem.setItemList(itemList);
      result = await enableSearchItem.execute(searchItem);
      expect(result === Response.SUCCESS).assertTrue();
    })
  })
}