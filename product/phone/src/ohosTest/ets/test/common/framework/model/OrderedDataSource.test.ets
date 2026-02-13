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
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import {
  ComparableSettingItemModel,
  ItemType, SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';


export default function OrderedDataSourceTest() {
  let orderedDataSource: OrderedDataSource = new OrderedDataSource();
  let par:ComparableSettingItemModel = {
    type: ItemType.ITEM_TYPE_CUSTOM,
    id: ''
  };
  describe('OrderedDataSourceTest', () => {

    /*
    * @tc.number: MenuDataSourceTest_001
    * @tc.name: 用于显示菜单列表的懒加载数据源
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */

    it('test_getInsertIndex_return', 0, (): void => {
      let resA:Object = (orderedDataSource as object)['getInsertIndex'](par);
      expect(resA === 0).assertTrue();
      par.compare = ():number => {
				return 1
			}
      let resB:Object = (orderedDataSource as object)['getInsertIndex'](par);
      expect(resB === 0).assertTrue();
    })

    it('test_insertData_return', 0, (): void => {
      let resA = orderedDataSource.insertData( 0, par);
      expect(resA === null).assertFalse();
      let resB = orderedDataSource.insertData( 2, par);
      expect(resB === null).assertFalse();
    })

    it('test_pushData_return', 0, (): void => {
      let resA = orderedDataSource.pushData( par);
      expect(resA === null).assertFalse();

    })

    it('test_pushDataArrayToEnd_return', 0, (): void => {
      let resA = orderedDataSource.pushDataArrayToEnd( 0, []);
      expect(resA === null).assertFalse();
      let arr: ComparableSettingItemModel[] = [];
      for(let i=0; i<3; i++){
        arr.push(par)
      }
      let resB = orderedDataSource.pushDataArrayToEnd( 0, arr);
      expect(resB === null).assertFalse();

    })

    it('test_pushDataArray_return', 0, (): void => {
      let resA = orderedDataSource.pushDataArray([]);
      expect(resA === null).assertFalse();
      let arr: ComparableSettingItemModel[] = [];
      for(let i=0; i<3; i++){
        arr.push(par)
      }
      let resB = orderedDataSource.pushDataArray(arr);
      expect(resB === null).assertFalse();

    })

    it('test_removeDataByIndex_return', 0, (): void => {
      let resA = orderedDataSource.removeDataByIndex(0);
      expect(resA === null).assertFalse();

      let resB = orderedDataSource.removeDataByIndex(2);
      expect(resB === null).assertFalse();
    })

    it('test_removeData_return', 0, (): void => {
      let resA = orderedDataSource.removeData(par);
      expect(resA === null).assertFalse();

    })

    it('test_removeAll_return', 0, (): void => {
      let resA = orderedDataSource.removeAll();
      expect(resA === null).assertFalse();
      orderedDataSource.length = 2;
      let resB = orderedDataSource.removeAll();
      expect(resB === null).assertFalse();

    })

  });
}