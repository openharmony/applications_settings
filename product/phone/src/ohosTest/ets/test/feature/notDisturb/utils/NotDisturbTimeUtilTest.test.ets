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
import { NotDisturbTimeUtil } from '@ohos/settings.notDisturb';

export default function NotDisturbTimeUtilTest() {
  describe('NotDisturbTimeUtilTest', () => {

    it('test_getDaysOfWeekLabels', 0, (): void => {
      let resA = NotDisturbTimeUtil.getDaysOfWeekLabels();
      expect(resA.length > 0).assertTrue();
    })

    it('test_getDaysToNextAlarm', 0, (): void => {
      let resA = NotDisturbTimeUtil.getDaysToNextAlarm([], 1);
      expect(resA === 0).assertTrue();
      let resB = NotDisturbTimeUtil.getDaysToNextAlarm([1, 2], 1);
      expect(resB === 0).assertTrue();
      let resC = NotDisturbTimeUtil.getDaysToNextAlarm([1, 2], 8);
      expect(resC === 0).assertTrue();
    })

  })
}