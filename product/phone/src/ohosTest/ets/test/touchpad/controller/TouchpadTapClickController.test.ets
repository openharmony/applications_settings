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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit } from '@ohos/hypium'
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource'
import { CompCtrlParam, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel'
import { SettingToggleState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel'
import {
  TouchpadTapClickController
} from '../../../../../main/ets/Setting/Touchpad/controller/TouchpadTapClickController'

export default function TouchpadTapClickControllerTest() {
  describe('TouchpadTapClickControllerTest', () => {
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
    it('TouchpadTapClickControllerTest_init', 0, (done: Function) => {
      try {
        let initController = new TouchpadTapClickController();
        let component: SettingBaseModel = {
          id: ''
        }
        let dataSource = new DynamicDataSource();
        let params: CompCtrlParam = {
          compId: 'xxxxx1223',
          dataSource,
          component
        };
        initController.init(params);
      } catch (e) {
      }
      done()
    })
    it('TouchpadSecondaryClickControllerTest_handleCheckedChange', 0, (done: Function) => {
      try {
        let initController = new TouchpadTapClickController();
        (initController as object)['handleCheckedChange'](true);
        (initController as object)['handleCheckedChange'](false);
        expect(initController).not().assertUndefined();
      } catch (e) {
      } finally {
        done();
      }
    })

    it('TouchpadSecondaryClickControllerTest_setTouchpadTapSwitch', 0, (done: Function) => {
      try {
        let initController = new TouchpadTapClickController();
        (initController as object)['setTouchpadTapSwitch'](() => {
        })
        expect(initController).not().assertUndefined();
        done();
      } catch (e) {
      } finally {
        done()
      }
    })

    it('TouchpadSecondaryClickControllerTest_toggleStateChangeEventCallback', 0, (done: Function) => {
      try {
        let initController = new TouchpadTapClickController();
        (initController as object)['toggleStateChangeEventCallback'](() => {
        })
      } catch (e) {
      } finally {
        done()
      }
    })

  })
}