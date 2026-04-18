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
import { controllerCounter } from '@ohos/settings.common';

export default function ControllerCounterTest() {
  describe('ControllerCounterTest', () => {
    it('ControllerCounterTest_01', 0, () => {
      let result = controllerCounter.addController('test');
      expect(result === null).assertFalse();

      controllerCounter.useCount = new Map([["test", 10]]);
      let result2 = controllerCounter.addController('test');
      expect(result2 === null).assertFalse();
    })
    it('ControllerCounterTest_02', 0, () => {
      controllerCounter.useCount = new Map([["test", 0]]);
      let result2 = controllerCounter.removeController('test');
      expect(result2 === true).assertTrue();

      controllerCounter.useCount = new Map([["test", 10]]);
      let result3 = controllerCounter.removeController('test');
      expect(result3 === false).assertTrue();
    })
  })
}