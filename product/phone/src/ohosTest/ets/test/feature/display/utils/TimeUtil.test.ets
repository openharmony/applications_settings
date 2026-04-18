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
import { describe, it, expect } from '@ohos/hypium'
import { TimeUtil } from '@ohos/settings.display/src/main/ets/utils/TimeUtil'

export default function TimeUtilTest() {
  describe('TimeUtilTest', () => {
    it('TimeUtilTest_001', 0, () => {
      let result = TimeUtil.timeFormat(1)
      expect(result).assertEqual('01')
      result = TimeUtil.timeFormat(11)
      expect(result).assertEqual('11')
    })
    it('TimeUtilTest_002', 0, () => {
      let result = TimeUtil.formatTime('360')
      expect(result.length >= 0).assertTrue()
      result = TimeUtil.formatTime('360', true)
      expect(result.length >= 0).assertTrue()
      const dateD = new Date()
      result = TimeUtil.formatTime(dateD, true)
      expect(result.length >= 0).assertTrue()
    })
  })
}