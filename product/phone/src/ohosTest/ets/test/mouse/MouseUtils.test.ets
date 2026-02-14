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
import { TestType } from '@ohos/hypium';

import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { MouseUtils } from '@ohos/settings.intent/src/main/ets/utils/MouseUtils';

export default function MouseUtilsTest() {
  describe('MouseUtilsTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })

    /*
      * @tc.number:MouseUtilsTest_001
      * @tc.name: 测试鼠标光标大小
      * @tc.type: TestType.FUNCTION
      * @tc.desc: 测试MouseUtils工具类接口.
      */
    it('MouseUtilsTest_001', TestType.FUNCTION, async () => {
      MouseUtils.setMousePointSize(2);
      MouseUtils.getMousePointSizeSliderMax();
      MouseUtils.getMousePointSizeSliderMin();
      MouseUtils.getMousePointSizeSliderStep();
      let size: number = MouseUtils.getMousePointSize();
      expect(size > -1).assertTrue();

    });

    /*
      * @tc.number:MouseUtilsTest_002
      * @tc.name: 测试鼠标光标样式
      * @tc.type: TestType.FUNCTION
      * @tc.desc: 测试MouseUtils工具类接口.
      */
    it('MouseUtilsTest_002', TestType.FUNCTION, async () => {
      MouseUtils.setMousePointerStyle('default');
      let style: string = MouseUtils.getMousePointerStyle();
      expect(style === '箭头').assertTrue();
    });

    /*
      * @tc.number:MouseUtilsTest_003
      * @tc.name: 测试鼠标光标样式
      * @tc.type: TestType.FUNCTION
      * @tc.desc: 测试MouseUtils工具类接口.
      */
    it('MouseUtilsTest_003', TestType.FUNCTION, async () => {
      MouseUtils.setMousePointerStyle('cursor_circle');
      let style: string = MouseUtils.getMousePointerStyle();
      expect(style === '圆形').assertTrue();
    });

    /*
      * @tc.number:MouseUtilsTest_004
      * @tc.name: 测试鼠标光标速度
      * @tc.type: TestType.FUNCTION
      * @tc.desc: 测试MouseUtils工具类接口.
      */
    it('MouseUtilsTest_004', TestType.FUNCTION, async () => {
      MouseUtils.setMousePointSpeed(5);
      MouseUtils.getMousePointSpeedSliderMax();
      MouseUtils.getMousePointSpeedSliderMin();
      MouseUtils.getMousePointSpeedSliderStep();
      let speed: number = MouseUtils.getMousePointSpeed();
      expect(speed === 5).assertTrue();
    });
  })
}