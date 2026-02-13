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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when,
  ArgumentMatchers } from '@ohos/hypium'
import { DeviceUtil } from '@ohos/settings.common'
import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel'
import {
  AddOtherWlanGroupController
} from '@ohos/settings.wifi/src/main/ets/controller/new/AddOtherWlanGroupController'
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus'
import { WLAN_SWITCH_ID } from '@ohos/settings.wifi/src/main/ets/model/WifiModel'
import { SettingToggleState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel'
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource'

export default function AddOtherWlanGroupControllerTest() {
  describe('AddOtherWlanGroupControllerTest', () => {
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
    it('test_AddOtherWlanGroup', 0, () => {
      let compParam: CompCtrlParam = {
        compId: '001',
        component: {
          id: '000000-5555'
        },
        dataSource: new DynamicDataSource()
      }
      let test = new AddOtherWlanGroupController()
      let mocker: MockKit = new MockKit()
      let mockFunc: Function = mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePc)
      when(mockFunc)(ArgumentMatchers.any).afterReturn(true)
      test.init(compParam)
      when(mockFunc)(ArgumentMatchers.any).afterReturn(false)
      test.init(compParam)
      EventBus.getInstance().emit(WLAN_SWITCH_ID)
      let state: SettingToggleState = {
        state: false
      }
      EventBus.getInstance().emit(WLAN_SWITCH_ID, state)
      test.destroy()
      expect(test != null).assertTrue()
      mocker.clear(DeviceUtil);
    })
  })
}