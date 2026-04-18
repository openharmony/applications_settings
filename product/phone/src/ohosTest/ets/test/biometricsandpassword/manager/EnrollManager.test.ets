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
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import {
  EnrollEvent,
  EnrollManager
} from '../../../../../main/ets/pages/biometricsandpassword/module/fingerprint/manager/EnrollManager';

export default function EnrollManagerTest() {
  describe('enrollManagerTest', () => {
    it('enrollManagerTest_001', 0, () => {
      const enrollManager = EnrollManager.getInstance();
      enrollManager.enterEnrollPage();
      expect(enrollManager.isEnrollTimeout()).assertFalse();
    });

    it('enrollManagerTest_002', 0, () => {
      const enrollManager = EnrollManager.getInstance();
      expect(enrollManager.isPrivacyUser(1111)).assertTrue();
      expect(enrollManager.isPrivacyUser(100)).assertFalse();
    });

    it('enrollManagerTest_009', 0, () => {
      const enrollManager = EnrollManager.getInstance();
      expect(enrollManager.getOutScreenEnrollTips(EnrollEvent.FINGERPRINT_TIP_FINGER_DOWN, 1).titleText)
        .assertEqual('');
    });
  });
}