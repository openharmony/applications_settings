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
import { describe, it, expect } from '@ohos/hypium'
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource'
import { CompCtrlParam, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel'
import { TouchpadEnableController } from '../../../../../main/ets/Setting/Touchpad/controller/TouchpadEnableController'

export default function TouchpadEnableControllerTest() {
  describe('TouchpadEnableControllerTest', () => {

    it('TouchpadEnableControllerTest_init', 0, (done: Function) => {
      let initController = new TouchpadEnableController();
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
      initController.destroy();
      done()
    })

    it('TouchpadEnableControllerTest_handleCheckedChange', 0, (done: Function) => {
      let initController = new TouchpadEnableController();
      (initController as object)['handleCheckedChange'](true);
      (initController as object)['handleCheckedChange'](false);
      expect(initController).not().assertUndefined();
      done();
    })

    it('TouchpadEnableControllerTest_getChecked', 0, (done: Function) => {
      let initController = new TouchpadEnableController();
      (initController as object)['refreshIsCheckd'](() => {
      })
      expect(initController).not().assertUndefined();
      done();
    })

    it('TouchpadEnableControllerTest_toggleStateChangeEventCallback', 0, (done: Function) => {
      let initController = new TouchpadEnableController();
      (initController as object)['toggleStateChangeEventCallback'](() => {
      })
      done();
    })

  })
}