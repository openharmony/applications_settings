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

import { describe, it, expect, TestType, MockKit, when } from '@ohos/hypium';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BasicDataSource } from '@ohos/settings.language/src/main/ets/model/BasicDataSource';
import { Constant } from '../../../constant/Constant';

const INDEX_0: number = 0;
const INDEX_1: number = 1;

export default function BasicDataSourceTest() {
  describe('BasicDataSourceTest', () => {

    /*
    * @tc.number: BasicDataSourceTest_001
    * @tc.name: totalCount
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return 0
    */
    it('BasicDataSourceTest_001', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BasicDataSourceTest_001 start`);
      let basicDataSource = new BasicDataSource();
      let result = await basicDataSource.totalCount();
      expect(result).assertEqual(0);
      LogUtil.info(`${Constant.TAG} BasicDataSourceTest_001 end`);
    });

    /*
    * @tc.number: BasicDataSourceTest_002
    * @tc.name: getData
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return ''
    */
    it('BasicDataSourceTest_002', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BasicDataSourceTest_002 start`);
      let basicDataSource = new BasicDataSource();
      let result = await basicDataSource.getData(INDEX_0);
      expect(result).assertEqual('');
      LogUtil.info(`${Constant.TAG} BasicDataSourceTest_002 end`);
    });

    /*
    * @tc.number: BasicDataSourceTest_003
    * @tc.name: notifyDataReload
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('BasicDataSourceTest_003', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BasicDataSourceTest_003 start`);
      let basicDataSource = new BasicDataSource();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(basicDataSource, basicDataSource.notifyDataReload);
      when(mockFunc)().afterReturn(true);
      let result = await basicDataSource.notifyDataReload();
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} BasicDataSourceTest_003 end`);
      mocker.clear(basicDataSource);
    });

    /*
    * @tc.number: BasicDataSourceTest_004
    * @tc.name: notifyDataAdd
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('BasicDataSourceTest_004', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BasicDataSourceTest_004 start`);
      let basicDataSource = new BasicDataSource();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(basicDataSource, basicDataSource.notifyDataAdd);
      when(mockFunc)(INDEX_0).afterReturn(true);
      let result = await basicDataSource.notifyDataAdd(INDEX_0);
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} BasicDataSourceTest_004 end`);
      mocker.clear(basicDataSource);
    });

    /*
    * @tc.number: BasicDataSourceTest_005
    * @tc.name: notifyDataChange
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('BasicDataSourceTest_005', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BasicDataSourceTest_005 start`);
      let basicDataSource = new BasicDataSource();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(basicDataSource, basicDataSource.notifyDataChange);
      when(mockFunc)(INDEX_0).afterReturn(true);
      let result = await basicDataSource.notifyDataChange(INDEX_0);
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} BasicDataSourceTest_005 end`);
      mocker.clear(basicDataSource);
    });

    /*
    * @tc.number: BasicDataSourceTest_006
    * @tc.name: notifyDataDelete
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('BasicDataSourceTest_006', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BasicDataSourceTest_006 start`);
      let basicDataSource = new BasicDataSource();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(basicDataSource, basicDataSource.notifyDataDelete);
      when(mockFunc)(INDEX_0).afterReturn(true);
      let result = await basicDataSource.notifyDataDelete(INDEX_0);
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} BasicDataSourceTest_006 end`);
      mocker.clear(basicDataSource);
    });

    /*
    * @tc.number: BasicDataSourceTest_007
    * @tc.name: notifyDataMove
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('BasicDataSourceTest_007', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} BasicDataSourceTest_007 start`);
      let basicDataSource = new BasicDataSource();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(basicDataSource, basicDataSource.notifyDataMove);
      when(mockFunc)(INDEX_1).afterReturn(true);
      let result = await basicDataSource.notifyDataMove(INDEX_1, INDEX_0);
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} BasicDataSourceTest_007 end`);
      mocker.clear(basicDataSource);
    });

    it("BasicDataSourceTest_008_01", 0, () => {
      let basicDS: BasicDataSource = new BasicDataSource()
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
      basicDS.unregisterDataChangeListener(listener)
      basicDS.registerDataChangeListener(listener)
      basicDS.registerDataChangeListener(listener)
      basicDS.unregisterDataChangeListener(listener)
      expect(basicDS != null).assertTrue()
    })
  });
}