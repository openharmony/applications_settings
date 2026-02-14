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
import { CallMessage } from '@ohos/settings.common/src/main/ets/stub/BaseServiceStub';
import { SearchEnableService } from '../../../../../Index';
import { SearchItems } from '../../../../main/ets/model/SearchItems';
import { TestUtil } from '../TestUtil';

const TAG: string = 'SearchEnableServiceTest: ';

export default function SearchEnableServiceTest() {
  describe('SearchEnableServiceTest', () => {
    beforeAll(async () => {
      TestUtil.startSettingsAbility(TAG);
    });

    afterAll(async () => {
      TestUtil.clearSettings();
    });

    /*
    * @tc.number: enableSearchItemsService
    * @tc.name: 搜索项使能服务.
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 搜索项使能服务.
    */
    it('enableSearchItemsService', 0, async () => {
      let searchEnableService: SearchEnableService = new SearchEnableService();
      let result = await searchEnableService.onCall(JSON.stringify(''));
      expect(result === Response.INVALID_METHOD).assertTrue();

      let message: CallMessage = { method: 'enableSearchItems' };
      result = await searchEnableService.onCall(JSON.stringify(message));
      expect(result === Response.FAIL).assertTrue();

      let searchItem: SearchItems = new SearchItems();
      let itemList: Array<string> = ['WLAN'];
      searchItem.setItemList(itemList);
      message.extra = searchItem;
      result = await searchEnableService.onCall(JSON.stringify(message));
      expect(result === Response.SUCCESS).assertTrue();
    })
  })
}