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

import { describe, expect, it } from '@ohos/hypium'
import { AirPlaneUtils } from '../../../../main/ets/utils/AirPlaneUtils';

export default function airPlaneUtilsTest() {
  describe('airPlaneTest', () => {

    it('airPlaneTest_isEdmDisableAirplane', 0, () => {
      let result = AirPlaneUtils.isEdmDisableAirplane();
      expect(result !== null).assertTrue();
    })

    it('airPlaneTest_isAirPlaneOperateEnable', 0, () => {
      let result = AirPlaneUtils.isAirPlaneOperateEnable();
      expect(result !== null).assertTrue();
    })

    it('airPlaneTest_isPersonalHotspot', 0, () => {
      let result = AirPlaneUtils.isPersonalHotspot();
      expect(result !== null).assertTrue();
    })

    it('airPlaneTest_isTouchFeedback', 0, () => {
      let result = AirPlaneUtils.isTouchFeedback();
      expect(result !== null).assertTrue();
    })
  })
}