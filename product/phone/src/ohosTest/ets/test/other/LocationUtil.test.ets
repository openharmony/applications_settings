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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, MockKit,Level } from '@ohos/hypium';

import { LocationUtil } from '@ohos/settings.privacy/src/main/ets/LocationUtil';

export default function locationUtilTest() {
  describe('locationUtilTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('LocationUtilTest_start', 0, () => {
      let res = 'test';
      LocationUtil.getInstance().start();
      expect(res).not().assertNull();
    })

    it('LocationUtilTest_stop', 0, () => {
      LocationUtil.getInstance().stop();
      expect(LocationUtil.getInstance().isStart).assertTrue();
    })

    it('getInstanceTest', 0, () => {
      let isSame = LocationUtil.getInstance() === LocationUtil.getInstance();
      expect(isSame).assertTrue();
    })

  })
}

