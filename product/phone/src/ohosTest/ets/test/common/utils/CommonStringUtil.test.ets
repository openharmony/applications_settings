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
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';

export default function commonStringUtilTest() {
  describe('CommonStringUtilTest', () => {
    it('CommonStringUtilTest_isEmpty1', 0, () => {
      const result: boolean = StringUtil.isEmpty(null);
      expect(result).assertTrue();
    })

    it('CommonStringUtilTest_isEmpty2', 0, () => {
      const result: boolean = StringUtil.isEmpty(undefined);
      expect(result).assertTrue();
    })

    it('CommonStringUtilTest_isEmpty3', 0, () => {
      const result: boolean = StringUtil.isEmpty('');
      expect(result).assertTrue();
    })

    it('CommonStringUtilTest_isEmpty4', 0, () => {
      const result: boolean = StringUtil.isEmpty('  ');
      expect(result).assertFalse();
    })

    it('CommonStringUtilTest_isEmpty5', 0, () => {
      const result: boolean = StringUtil.isEmpty('1');
      expect(result).assertFalse();
    })

    it('CommonStringUtilTest_isNotEmpty1', 0, () => {
      const result: boolean = StringUtil.isNotEmpty(null);
      expect(result).assertFalse();
    })

    it('CommonStringUtilTest_isNotEmpty2', 0, () => {
      const result: boolean = StringUtil.isNotEmpty(undefined);
      expect(result).assertFalse();
    })

    it('CommonStringUtilTest_isNotEmpty3', 0, () => {
      const result: boolean = StringUtil.isNotEmpty('');
      expect(result).assertFalse();
    })

    it('CommonStringUtilTest_isNotEmpty4', 0, () => {
      const result: boolean = StringUtil.isNotEmpty('11');
      expect(result).assertTrue();
    })

    it('CommonStringUtilTest_getStringLength1', 0, () => {
      const result: number = StringUtil.getStringLength(undefined);
      expect(result === 0).assertTrue();
    })

    it('CommonStringUtilTest_getStringLength2', 0, () => {
      const result: number = StringUtil.getStringLength(null);
      expect(result === 0).assertTrue();
    })

    it('CommonStringUtilTest_getStringLength3', 0, () => {
      const result: number = StringUtil.getStringLength('1');
      expect(result === 1).assertTrue();
    })

    it('CommonStringUtilTest_anonymizeString1', 0, () => {
      const result: string = StringUtil.anonymizeString('1');
      expect(result === '1').assertTrue();
    })

    it('CommonStringUtilTest_anonymizeString2', 0, () => {
      const result: string = StringUtil.anonymizeString('');
      expect(result === '').assertTrue();
    })
  })
}