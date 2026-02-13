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

import { describe, it, expect, TestType } from '@ohos/hypium';
import { BasicDataSource } from '@ohos/settings.common/src/main/ets/core/model/datasource/BasicDataSource';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Constant } from '../../../../constant/Constant';

export default function CommonBasicDataSourceTest() {
  let basicDataSource = new BasicDataSource();
  let listener: DataChangeListener = {
    onDataReloaded: (): void => {
      throw new Error('Function not implemented.');
    },
    onDataAdded: (index: number): void => {
      throw new Error('Function not implemented.');
    },
    onDataAdd: (index: number): void => {
      throw new Error('Function not implemented.');
    },
    onDataMoved: (from: number, to: number): void => {
      throw new Error('Function not implemented.');
    },
    onDataMove: (from: number, to: number): void => {
      throw new Error('Function not implemented.');
    },
    onDataDeleted: (index: number): void => {
      throw new Error('Function not implemented.');
    },
    onDataDelete: (index: number): void => {
      throw new Error('Function not implemented.');
    },
    onDataChanged: (index: number): void => {
      throw new Error('Function not implemented.');
    },
    onDataChange: (index: number): void => {
      throw new Error('Function not implemented.');
    },
    onDatasetChange: (dataOperations: DataOperation[]): void => {
      throw new Error('Function not implemented.');
    }
  }

  describe('CommonBasicDataSourceTest', () => {

    /*
    * @tc.number: CommonBasicDataSourceTest_001
    * @tc.name: 懒加载数据源基类
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('test_registerDataChangeListener_return', 0, (): void => {
      (basicDataSource as object)["listeners"].push( listener );
      let resA = basicDataSource.registerDataChangeListener(listener);
      expect(resA === null).assertFalse();
      (basicDataSource as object)["listeners"] = [];
      let resB = basicDataSource.registerDataChangeListener(listener);
      expect(resB === null).assertFalse();

    })

    it('test_unregisterDataChangeListener_return', 0, (): void => {
      (basicDataSource as object)["listeners"] = [];
      let resA = basicDataSource.unregisterDataChangeListener(listener);
      expect(resA === null).assertFalse();
      (basicDataSource as object)["listeners"].push( listener );
      let resB = basicDataSource.unregisterDataChangeListener(listener);
      expect(resB === null).assertFalse();

    })

  });
}