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
import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium'
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus'
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource'
import { CompCtrlParam, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel'
import { SettingToggleState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel'
import {
  MouseOtherSettingsGroupController
} from '../../../../main/ets/Setting/Mouse/controller/MouseSettingsGroupController'
import { MouseSettingsManager } from '../../../../main/ets/Setting/Mouse/MouseSettingsManager'
import { Utils } from '../../../../main/ets/Setting/Mouse/utils/Utils'

export default function MouseSettingsGroupControllerTest() {

  describe('MouseSettingsGroupControllerTest', () => {
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

    let mocker: MockKit = new MockKit();
    let model: SettingBaseModel = {
      id: ""
    }
    let cls: MouseOtherSettingsGroupController = new MouseOtherSettingsGroupController();
    let com: CompCtrlParam = {
      compId: '1',
      component: model,
      dataSource: new DynamicDataSource()
    }

    it('mouseSettingsGroupControllerTest_001', 0, () => {

      let func1: Function = mocker.mockFunc(Utils, Utils.isEnableMagicCursor);
      when(func1)().afterReturn(false);
      cls.init(com);
      expect(func1()).assertFalse();
      mocker.clear(Utils);
    })

    it('mouseSettingsGroupControllerTest_002', 0, () => {

      (cls as object)['length'] = 1;
      let func1: Function = mocker.mockFunc(Utils, Utils.isEnableMagicCursor);
      when(func1)().afterReturn(true);

      let func2: Function =
        mocker.mockFunc(MouseSettingsManager.getInstance(), MouseSettingsManager.getInstance().isCircleStyle);
      when(func2)().afterReturn(false);

      cls.init(com);
      expect(func2()).assertFalse();
      mocker.clear(Utils);
      mocker.clear(MouseSettingsManager.getInstance());
    })

    it('mouseSettingsGroupControllerTest_003', 0, () => {

      let func1: Function = mocker.mockFunc(Utils, Utils.isEnableMagicCursor);
      when(func1)().afterReturn(true);

      let func2: Function =
        mocker.mockFunc(MouseSettingsManager.getInstance(), MouseSettingsManager.getInstance().isCircleStyle);
      when(func2)().afterReturn(true);
      cls.init(com)
      expect(func2()).assertTrue();
      mocker.clear(Utils);
      mocker.clear(MouseSettingsManager.getInstance());
    })

    it('mouseSettingsGroupControllerTest_004', 0, () => {

      let status: SettingToggleState = {
        state: false
      }
      EventBus.getInstance().emit('1.MouseSmartChangeItem.toggle', status)

      status.state = true
      let func1: Function = mocker.mockFunc(Utils, Utils.isEnableMagicCursor);
      when(func1)().afterReturn(false);
      EventBus.getInstance().emit('1.MouseSmartChangeItem.toggle', status)

      when(func1)().afterReturn(true);
      let res = EventBus.getInstance().emit('1.MouseSmartChangeItem.toggle', status)
      expect(res).assertTrue()
      mocker.clear(Utils);
    })


    it('mouseSettingsGroupControllerTest_005', 0, () => {

      let func1: Function = mocker.mockFunc(Utils, Utils.isEnableMagicCursor);
      when(func1)().afterReturn(false);
      EventBus.getInstance().emit('mouse_style_changed', false)

      when(func1)().afterReturn(true);
      EventBus.getInstance().emit('mouse_style_changed', false)
      let res = EventBus.getInstance().emit('mouse_style_changed', true)
      expect(res).assertTrue()
      mocker.clear(Utils);
    })
  })
}