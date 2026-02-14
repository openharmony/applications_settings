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
import { describe, it, expect, MockKit } from '@ohos/hypium'
import { Response } from '@ohos/settings.common/src/main/ets/constant/Response';
import { CallMessage } from '@ohos/settings.common/src/main/ets/stub/BaseServiceStub';
import { SearchItems } from '@ohos/settings.search/src/main/ets/model/SearchItems';
import { EnableSearchEntry } from '@ohos/settings.search/src/main/ets/service/EnableSearchEntry';
import { EnableSearchItems } from '@ohos/settings.search/src/main/ets/service/EnableSearchItems';
import { RdbStoreInitService } from '@ohos/settings.search/src/main/ets/service/RdbStoreInitService';
import { SearchEnableService } from '@ohos/settings.search/src/main/ets/service/SearchEnableService';

export default function SearchServiceTestTest() {
  describe('SearchServiceTestTest', () => {
    it('SearchServiceTestTest_EnableSearchEntry_001', 0, async (done: Function) => {
      let enableSearchE: EnableSearchEntry = new EnableSearchEntry(true);
      let extra: SearchItems = new SearchItems();
      enableSearchE.execute(extra);
      extra.itemList = ['test'];
      enableSearchE.execute(extra);
      expect(enableSearchE != null).assertTrue();
      done();
    })
    it('SearchServiceTestTest_EnableSearchItems_001', 0, async (done: Function) => {
      let enableSearchItem: EnableSearchItems = new EnableSearchItems(true);
      let searchItem: SearchItems = new SearchItems();
      let result = await enableSearchItem.execute(searchItem);
      expect(result === Response.FAIL).assertTrue();
      let itemList: Array<string> = ['WLAN'];
      searchItem.setItemList(itemList);
      result = await enableSearchItem.execute(searchItem);
      expect(result === Response.SUCCESS).assertTrue();
      done();
    })

    it('SearchServiceTestTest_EnableSearchItemsService_001', 0, async (done: Function) => {
      let searchEnableS: SearchEnableService = new SearchEnableService();
      const result = await searchEnableS.onCall(JSON.stringify(''));
      expect(result === Response.INVALID_METHOD).assertTrue();

      let message: CallMessage = {
        method: 'enableSearchItems'
      };
      const result1 = await searchEnableS.onCall(JSON.stringify(message));
      expect(result1 !== null).assertTrue();
      done();
    })
  })
}