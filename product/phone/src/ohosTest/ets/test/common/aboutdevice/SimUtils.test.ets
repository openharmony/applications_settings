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

import { describe, it, expect, MockKit, when } from '@ohos/hypium'
import { SimUtils } from '@ohos/settings.common/src/main/ets/utils/SimUtils';

export default function SimUtilsTest() {
  describe('SimUtilsTest', () => {
    it('SimUtilsTest_001', 0, () => {
      SimUtils.getCardSlotNum();
      (SimUtils as object)['firstIsWithCardSlot'] = false;
      (SimUtils as object)['cardSlotNum'] = 0;
      let result1 = SimUtils.getCardSlotNum();
      expect(result1 >= -1).assertTrue();
    })
    it('SimUtilsTest_002', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(SimUtils, SimUtils.getCardSlotNum);
      when(mockFun)().afterReturn(0);
      let result = SimUtils.hasSimCard();
      expect(result).assertFalse();
      when(mockFun)().afterReturn(1);
      result = SimUtils.hasSimCard();
      expect(result).assertFalse();
      mocker.clear(SimUtils);
    })
  })
}