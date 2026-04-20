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

import { describe, expect, it } from '@ohos/hypium';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import { ItemType, SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';


export default function DynamicDataSourceTest() {
  let dynamicDataSource: DynamicDataSource = new DynamicDataSource();

  describe('DynamicDataSourceTest', () => {

    /*
    * @tc.number: MenuDataSourceTest_001
    * @tc.name: 用于显示菜单列表的懒加载数据源
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */

    it('test_pushData_return', 0, (): void => {
      let resA = dynamicDataSource.pushData();
      expect(resA === 0).assertTrue();
      let itemObj: SettingItemModel = {
        type: ItemType.ITEM_TYPE_CUSTOM,
        id: ''
      }
      let arr: SettingItemModel[] = []
      for(let i=0; i<3; i++){
        arr.push(itemObj)
      }
      let resB = dynamicDataSource.pushData(...arr);
      expect(resB === 2).assertFalse();

    })

    it('test_removeDataById_return', 0, (): void => {
      let resA = dynamicDataSource.removeDataById('-1')
      expect(resA === null).assertFalse();
      let resB = dynamicDataSource.removeDataById('0')
      expect(resB === null).assertFalse();

    })

    it('test_insertData_return', 0, (): void => {
      let itemObj: SettingItemModel = {
        type: ItemType.ITEM_TYPE_CUSTOM,
        id: ''
      }
      let resA = dynamicDataSource.insertData(0,itemObj)
      expect(resA === null).assertFalse();
      let resB = dynamicDataSource.insertData(2,itemObj)
      expect(resB === null).assertFalse();
    })

  });
}