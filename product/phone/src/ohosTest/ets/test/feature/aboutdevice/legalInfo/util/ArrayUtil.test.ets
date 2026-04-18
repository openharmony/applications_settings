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
import { ArrayUtil } from '@ohos/settings.aboutdevice/src/main/ets/legalInfo/util/ArrayUtil';

export default function ArrayUtilTest() {
  describe('ArrayUtilTest', (): void => {
    let arrayUtil = ArrayUtil;
    it('ArrayUtil_isEmpty_001', 0, (done: Function) => {
      try {
        let result = arrayUtil.isEmpty<undefined>(undefined)
        expect(result === true).assertTrue();
        let result2 = arrayUtil.isEmpty<null>(null);
        expect(result2 === true).assertTrue();
        let result3= arrayUtil.isEmpty<string>([]);
        expect(result3 === true).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });

    it('ArrayUtil_isNotEmpty_002', 0, (done: Function) => {
      try {
        let result = arrayUtil.isNotEmpty<string>(['1', '2'])
        expect(result === true).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });

    it('ArrayUtil_isMapEmpty_003', 0, (done: Function) => {
      try {
        let result = arrayUtil.isMapEmpty<null,undefined>(new Map([]));
        expect(result === true).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
  })
}

