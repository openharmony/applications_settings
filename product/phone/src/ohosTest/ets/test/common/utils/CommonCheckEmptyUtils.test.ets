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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, Level } from '@ohos/hypium';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';

export default function commonCheckEmptyUtilsTest() {
  describe('commonCheckEmptyUtilsTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('commonCheckEmptyUtilsTest_isEmptyTest_001', Level.LEVEL0, (): void => {
      expect(CheckEmptyUtils.isEmpty(null)).assertTrue();
    });

    it('commonCheckEmptyUtilsTest_isEmptyTest_002', Level.LEVEL0, (): void => {
      expect(CheckEmptyUtils.isEmpty('')).assertTrue();
    });

    it('commonCheckEmptyUtilsTest_isEmptyTest_003', Level.LEVEL0, (): void => {
      expect(CheckEmptyUtils.isEmpty('123')).assertFalse();
    });

    it('commonCheckEmptyUtilsTest_isEmptyTest_004', Level.LEVEL0, (): void => {
      expect(CheckEmptyUtils.isEmpty(undefined)).assertTrue();
    });

    it('commonCheckEmptyUtilsTest_checkStrIsEmptyTest_001', Level.LEVEL0, (): void => {
      expect(CheckEmptyUtils.checkStrIsEmpty(null)).assertTrue();
    });

    it('commonCheckEmptyUtilsTest_checkStrIsEmptyTest_002', Level.LEVEL0, (): void => {
      expect(CheckEmptyUtils.checkStrIsEmpty(undefined)).assertTrue();
    });

    it('commonCheckEmptyUtilsTest_checkStrIsEmptyTest_003', Level.LEVEL0, (): void => {
      expect(CheckEmptyUtils.checkStrIsEmpty('')).assertTrue();
    });

    it('commonCheckEmptyUtilsTest_checkStrIsEmptyTest_004', Level.LEVEL0, (): void => {
      expect(CheckEmptyUtils.checkStrIsEmpty('  ')).assertTrue();
    });

    it('commonCheckEmptyUtilsTest_checkStrIsEmptyTest_005', Level.LEVEL0, (): void => {
      expect(CheckEmptyUtils.checkStrIsEmpty('12')).assertFalse();
    });

    it('commonCheckEmptyUtilsTest_checkEmptyArrTest_001', Level.LEVEL0, (): void => {
      expect(CheckEmptyUtils.isEmptyArr(undefined)).assertTrue();
    });

    it('commonCheckEmptyUtilsTest_checkEmptyArrTest_002', Level.LEVEL0, (): void => {
      expect(CheckEmptyUtils.isEmptyArr(null)).assertTrue();
    });

    it('commonCheckEmptyUtilsTest_checkEmptyArrTest_003', Level.LEVEL0, (): void => {
      expect(CheckEmptyUtils.isEmptyArr([])).assertTrue();
    });

    it('commonCheckEmptyUtilsTest_checkEmptyArrTest_004', Level.LEVEL0, (): void => {
      expect(CheckEmptyUtils.isEmptyArr([1])).assertFalse();
    });
  })
}