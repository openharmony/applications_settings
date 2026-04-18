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
import {
  ErrorBodyTextStyle,
  ErrorTitleTextStyle,
  OutScreenBodyTextStyle,
  OutScreenTitleTextStyle,
  UnderScreenBodyTextStyle,
  UnderScreenTitleTextStyle,
} from '../../../../../main/ets/pages/biometricsandpassword/module/fingerprint/manager/EnrollTips';

export default function EnrollTipsTest() {
  describe('enrollTipsTest', () => {
    it('enrollTipsTest_001', 0, () => {
      const underScreenTitleTextStyle = new UnderScreenTitleTextStyle();
      expect(underScreenTitleTextStyle.font.weight).assertEqual(FontWeight.Medium);
    });

    it('enrollTipsTest_002', 0, () => {
      const outScreenTitleTextStyle = new OutScreenTitleTextStyle();
      expect(outScreenTitleTextStyle.font.weight).assertEqual(FontWeight.Medium);
    });

    it('enrollTipsTest_003', 0, () => {
      const errorTitleTextStyle = new ErrorTitleTextStyle();
      expect(errorTitleTextStyle.font.weight).assertEqual(FontWeight.Medium);
    });

    it('enrollTipsTest_004', 0, () => {
      const outScreenBodyTextStyle = new OutScreenBodyTextStyle();
      expect(outScreenBodyTextStyle.font.weight).assertEqual(FontWeight.Regular);
    });

    it('enrollTipsTest_005', 0, () => {
      const errorBodyTextStyle = new ErrorBodyTextStyle();
      expect(errorBodyTextStyle.font.weight).assertEqual(FontWeight.Regular);
    });

    it('enrollTipsTest_006', 0, () => {
      const underScreenBodyTextStyle = new UnderScreenBodyTextStyle();
      expect(underScreenBodyTextStyle.font.weight).assertEqual(FontWeight.Regular);
    });
  });
}