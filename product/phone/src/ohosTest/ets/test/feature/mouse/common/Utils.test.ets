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
  it,
  TestType,
} from '@ohos/hypium';
import { ifUseNewPage, isCardWidthEnough, measureTextVp } from '@ohos/settings.mouse/src/main/ets/common/Utils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG = 'UtilsTest';

export default function MouseCommonUtilsTest() {
  describe('MouseCommonUtilsTest', () => {
    beforeAll(() => {
      LogUtil.showInfo(TAG, 'beforeAll');
    });

    afterAll(() => {
      LogUtil.showInfo(TAG, 'afterAll');
    });

    it('UtilsTest_001', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'UtilsTest_001 it begin');
      measureTextVp({ textContent: 'test text' });
      expect().assertUndefined();
    });

    it('UtilsTest_002', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'UtilsTest_002 it begin');
      const ifUse = ifUseNewPage();
      expect(typeof ifUse === 'boolean').assertTrue();
    });

    it('UtilsTest_003', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'UtilsTest_003 it begin');
      const isEnough = isCardWidthEnough(1);
      expect(typeof isEnough === 'boolean').assertTrue();
    });
  });
}
