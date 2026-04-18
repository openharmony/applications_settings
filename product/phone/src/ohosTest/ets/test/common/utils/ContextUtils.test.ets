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
import { describe, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium'
import { ContextUtils } from '@ohos/settings.common/src/main/ets/utils/baseutils/ContextUtils'
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils'

export default function ContextUtilsTest() {
  describe('ContextUtilsTest', () => {
    it('ContextUtilsTest', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(CheckEmptyUtils, CheckEmptyUtils.isEmpty)
      when(mockFun)(ArgumentMatchers.any).afterReturn(true);
      ContextUtils.getContext();
      expect(CheckEmptyUtils.isEmpty('')).assertTrue();
      when(mockFun)(ArgumentMatchers.any).afterReturn(false);
      ContextUtils.getContext();
      expect(CheckEmptyUtils.isEmpty('')).assertFalse();
      mocker.clear(CheckEmptyUtils);
    })
  })
}