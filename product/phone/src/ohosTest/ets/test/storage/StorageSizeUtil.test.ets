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

import { describe, it, expect, MockKit, when } from '@ohos/hypium';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { StorageSizeUtil } from '@ohos/settings.storage';
import { Constant } from '../constant/Constant';

export default function storageSizeUtilTest() {
  describe('storageSizeUtilTest', () => {
    /*
    * @tc.number:formatData_001
    * @tc.name: formatData方法校验1
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: val<1000
    */
    it('formatData_001', 0, async () => {
      LogUtil.info(`${Constant.TAG} formatData_001 start`);
      // 定义formatData入参
      const VAL: number = 500;
      const COUNT: number = 0;
      let result: string = StorageSizeUtil.formatData(VAL, COUNT);
      const EXPECT_RESULT: string = '500 B';
      expect(result).assertEqual(EXPECT_RESULT);
      LogUtil.info(`${Constant.TAG} formatData_001 end`);
    });

    /*
    * @tc.number:formatData_002
    * @tc.name: formatData方法校验2
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 1000< val < 1000 * 1000
    */
    it('formatData_002', 0, async () => {
      LogUtil.info(`${Constant.TAG} formatData_002 start`);
      // 定义formatData入参
      const VAL: number = 100000;
      const COUNT: number = 0;
      let result: string = StorageSizeUtil.formatData(VAL, COUNT);
      const EXPECT_RESULT: string = '100 KB';
      expect(result).assertEqual(EXPECT_RESULT);
      LogUtil.info(`${Constant.TAG} formatData_002 end`);
    });

    /*
    * @tc.number:formatData_003
    * @tc.name: formatData方法校验3
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 1000 * 1000< val< 1000 * 1000 * 1000
    */
    it('formatData_003', 0, async () => {
      LogUtil.info(`${Constant.TAG} formatData_003 start`);
      // 定义formatData入参
      const VAL: number = 100000000;
      const COUNT: number = 2;
      let result: string = StorageSizeUtil.formatData(VAL, COUNT);
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} formatData_003 end`);
    });

    /*
    * @tc.number:formatData_004
    * @tc.name: formatData方法校验4
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 1000 * 1000 * 1000 <val< 1000 * 1000 * 1000 * 1000
    */
    it('formatData_004', 0, async () => {
      LogUtil.info(`${Constant.TAG} formatData_004 start`);
      // 定义formatData入参
      const VAL: number = 100000000000;
      const COUNT: number = 1;
      let result: string = StorageSizeUtil.formatData(VAL, COUNT);
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} formatData_004 end`);
    });

    /*
    * @tc.number:formatData_005
    * @tc.name: formatData方法校验5
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: val> 1000 * 1000 * 1000 * 1000
    */
    it('formatData_005', 0, async () => {
      LogUtil.info(`${Constant.TAG} formatData_005 start`);
      // 定义formatData入参
      const VAL: number = 2000000000000;
      const COUNT: number = 1;
      let result: string = StorageSizeUtil.formatData(VAL, COUNT);
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} formatData_005 end`);
    });
    // formatData
    it('storageSizeUtilTest_001', 0, () => {
      const VAL: number = 500 * 1000;
      const COUNT: number = 0;
      let result: string = StorageSizeUtil.formatData(VAL, COUNT);
      const EXPECT_RESULT: string = '500 KB';
      expect(result).assertEqual(EXPECT_RESULT);
    })
    it('storageSizeUtilTest_001_01', 0, () => {
      const VAL: number = 500 * 1000 * 1000;
      const COUNT: number = 0;
      let result: string = StorageSizeUtil.formatData(VAL, COUNT);
      const EXPECT_RESULT: string = '500 MB';
      expect(result).assertEqual(EXPECT_RESULT);
    })
    it('storageSizeUtilTest_001_02', 0, () => {
      const VAL: number = 500 * 1000 * 1000 * 1000;
      const COUNT: number = 0;
      let result: string = StorageSizeUtil.formatData(VAL, COUNT);
      const EXPECT_RESULT: string = '500 GB';
      expect(result).assertEqual(EXPECT_RESULT);
    })
    it('storageSizeUtilTest_001_03', 0, () => {
      const VAL: number = 512 * 1000 * 1000 * 1000 * 1000;
      const COUNT: number = 0;
      let result: string = StorageSizeUtil.formatData(VAL, COUNT);
      const EXPECT_RESULT: string = '500 TB';
      expect(result).assertEqual(EXPECT_RESULT);
    })
    it('storageSizeUtilTest_001_04', 0, () => {
      const VAL: number = 1024 * 1000 * 1000 * 1000 * 1000;
      const COUNT: number = 0;
      let result: string = StorageSizeUtil.formatData(VAL, COUNT);
      const EXPECT_RESULT: string = '1000 TB';
      expect(result).assertEqual(EXPECT_RESULT);
    })
    it('storageSizeUtilTest_001_05', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(LanguageUtils, LanguageUtils.isLtrDirection);
      when(mockFun)().afterReturn(false);
      const VAL: number = 1024 * 1000 * 1000 * 1000 * 1000;
      const COUNT: number = 0;
      let result: string = StorageSizeUtil.formatData(VAL, COUNT);
      const EXPECT_RESULT: string = '1000TB';
      mocker.clear(LanguageUtils);
      expect(result).assertEqual(EXPECT_RESULT);
    })
    // formatDataRound
    it('storageSizeUtilTest_002', 0, () => {
      const VAL: number = 500;
      const COUNT: number = -Number.MAX_SAFE_INTEGER;
      let result: string = StorageSizeUtil.formatDataRound(VAL, COUNT);
      const EXPECT_RESULT: string = '';
      expect(result).assertEqual(EXPECT_RESULT);
    })
    it('storageSizeUtilTest_002_01', 0, () => {
      const VAL: number = 500;
      const COUNT: number = 0;
      let result: string = StorageSizeUtil.formatDataRound(VAL, COUNT);
      const EXPECT_RESULT: string = '500 B';
      expect(result).assertEqual(EXPECT_RESULT);
    })
    it('storageSizeUtilTest_002_02', 0, () => {
      const VAL: number = 500 * 1000;
      const COUNT: number = 0;
      let result: string = StorageSizeUtil.formatDataRound(VAL, COUNT);
      const EXPECT_RESULT: string = '500 KB';
      expect(result).assertEqual(EXPECT_RESULT);
    })
    it('storageSizeUtilTest_002_03', 0, () => {
      const VAL: number = 500 * 1000 * 1000;
      const COUNT: number = 0;
      let result: string = StorageSizeUtil.formatDataRound(VAL, COUNT);
      const EXPECT_RESULT: string = '500 MB';
      expect(result).assertEqual(EXPECT_RESULT);
    })
    it('storageSizeUtilTest_002_04', 0, () => {
      const VAL: number = 500 * 1000 * 1000 * 1000;
      const COUNT: number = 0;
      let result: string = StorageSizeUtil.formatDataRound(VAL, COUNT);
      const EXPECT_RESULT: string = '500 GB';
      expect(result).assertEqual(EXPECT_RESULT);
    })
    it('storageSizeUtilTest_002_05', 0, () => {
      const VAL: number = 512 * 1000 * 1000 * 1000 * 1000;
      const COUNT: number = 0;
      let result: string = StorageSizeUtil.formatDataRound(VAL, COUNT);
      const EXPECT_RESULT: string = '500 TB';
      expect(result).assertEqual(EXPECT_RESULT);
    })
    it('storageSizeUtilTest_002_06', 0, () => {
      const VAL: number = 1024 * 1000 * 1000 * 1000 * 1000;
      const COUNT: number = 0;
      let result: string = StorageSizeUtil.formatDataRound(VAL, COUNT);
      const EXPECT_RESULT: string = '1000 TB';
      expect(result).assertEqual(EXPECT_RESULT);
    })
    it('storageSizeUtilTest_002_07', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(LanguageUtils, LanguageUtils.isLtrDirection);
      when(mockFun)().afterReturn(false);
      const VAL: number = 1024 * 1000 * 1000 * 1000 * 1000;
      const COUNT: number = 0;
      let result: string = StorageSizeUtil.formatDataRound(VAL, COUNT);
      const EXPECT_RESULT: string = '1000TB';
      mocker.clear(LanguageUtils);
      expect(result).assertEqual(EXPECT_RESULT);
    })
    // handleData
    it('storageSizeUtilTest_003', 0, () => {
      const DATA: number = 50;
      let result: number = StorageSizeUtil.handleData(DATA);
      const EXPECT_RESULT: number = 50;
      expect(result).assertEqual(EXPECT_RESULT);
    })
  })
}