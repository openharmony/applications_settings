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

import { beforeAll, describe, it, afterAll, MockKit, expect } from '@ohos/hypium';
import { QuickGesturesUtils } from '../../../../main/ets/Setting/System/QuickGestures/utils/QuickGesturesUtils'

const TAG: string = 'QuickGesturesUtils';

export default function QuickGesturesUtilsTest() {
  describe('QuickGesturesUtilsTest', () => {
    it('isSupportCameraSmartControl', 0, isSupportCameraSmartControlTest);

    it('isSupportSlide', 0, isSupportSlideTest);
  });
}

function isSupportCameraSmartControlTest() {
  let data: ESObject = {
    'isSupportCameraSmartControl': true,
    'isSupportSlide': false
  }
  AppStorage.setOrCreate('smart_key_data', data);
  let res = QuickGesturesUtils.isSupportCameraSmartControl();
  expect(res).assertTrue();

  AppStorage.setOrCreate('smart_key_data', undefined);
  QuickGesturesUtils.isSupportCameraSmartControl();
}

function isSupportSlideTest() {
  let data: ESObject = {
    'isSupportCameraSmartControl': true,
    'isSupportSlide': false
  }
  AppStorage.setOrCreate('smart_key_data', data);
  let res = QuickGesturesUtils.isSupportSlide();
  expect(res).assertFalse();
}
