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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when } from '@ohos/hypium'
import { MousePointerSliderController } from '../../../../main/ets/Setting/Mouse/controller/MouseStyleController'
import { MouseSettingsManager } from '../../../../main/ets/Setting/Mouse/MouseSettingsManager'
import { MouseSliderType } from '../../../../main/ets/Setting/Mouse/utils/Constants'
import { print } from '@kit.BasicServicesKit'
import hilog from '@ohos.hilog'

export default function MouseStyleControllerTest() {
  describe('MouseStyleControllerTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    it('assertEqual', 0, () => {
      // Defines a test case. This API supports three parameters: test case name, filter parameter, and test case function.
      let a = 'test'
      // Defines a variety of assertion methods, which are used to declare expected boolean conditions.
      expect(a).assertEqual('test')
    })

    let mocker = new MockKit()
    let obj = new MousePointerSliderController()
    it('MouseStyleControllerTest_001', 0, () => {

      obj.init(MouseSliderType.DEFAULT)
      obj.setSliderValue(0)

      obj.init(MouseSliderType.MousePointerSize)
      obj.setSliderValue(1)

      obj.init(MouseSliderType.MousePointerSpeed)
      obj.setSliderValue(2)

      obj.onSliderChange(0, SliderChangeMode.Begin)
      let res = obj.onSliderChange(0, SliderChangeMode.End)
      expect(res == null).assertTrue()
    })

    it('MouseStyleControllerTest_002', 0, () => {

      let func1: Function = mocker.mockFunc(obj, obj.getSliderValue)
      when(func1)().afterReturn(0)
      func1()

      when(func1)().afterReturn(1)
      func1()

      when(func1)().afterReturn(2)
      func1()

      expect(func1()).assertEqual(2)
      mocker.clear(obj)
    })
  })
}