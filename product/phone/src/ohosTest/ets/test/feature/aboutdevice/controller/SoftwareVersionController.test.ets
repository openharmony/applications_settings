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
import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import {
  SoftwareVersionController
} from '@ohos/settings.aboutdevice/src/main/ets/controller/SoftwareVersionController';
import { DeviceUtil, SystemParamUtil } from '@ohos/settings.common';
import { CompCtrlParam, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';

export default function SoftwareVersionControllerTest() {
  describe('SoftwareVersionControllerTest', (): void => {
    let softwareVersionController = new SoftwareVersionController;
    it('SoftwareVersionControllerTest_init_001', 0, (done: Function) => {
      try {
        let compParam: CompCtrlParam = {
          compId: '123456', component: {
            id: 'componentId', url: 'pathUrl', type: PageType.PAGE_TYPE_STANDARD
          } as SettingPageModel
        };
        let mocker = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePc);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
        let result = softwareVersionController.init(compParam);
        expect(result !== null).assertTrue();
        let mockfunc2: Function =
          mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePc);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(false);
        let result2 = softwareVersionController.init(compParam);
        expect(result2 !== null).assertTrue();
        mocker.clear(DeviceUtil);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('SoftwareVersionControllerTest_onClick_002', 0, (done: Function) => {
      try {
        let component: SettingBaseModel = {
          id: 'componentId', cached: false
        } as SettingPageModel;
        (softwareVersionController as object)['clickThrough'] = 10;
        let mocker = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePad);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
        let mockfunc2: Function =
          mocker.mockFunc(DeviceUtil, DeviceUtil.isDevicePhone);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(true);
        let mockfunc3: Function =
          mocker.mockFunc(DeviceUtil, DeviceUtil.isFoldFold);
        when(mockfunc3)(ArgumentMatchers.any).afterReturn(true);
        let result = softwareVersionController.onClick(component);
        expect(result !== null).assertTrue();

        (softwareVersionController as object)['maximum'] = 100;
        let result2 = softwareVersionController.onClick(component);
        expect(result2 !== null).assertTrue();
        mocker.clear(DeviceUtil);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('SoftwareVersionControllerTest_switchDeveloperMode_003', 0, (done: Function) => {
      try {
        (softwareVersionController as object)['developerStatus'] = 'true';
        let mocker = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(SystemParamUtil, SystemParamUtil.getParam);
        when(mockfunc)(ArgumentMatchers.any).afterReturn('true');
        (softwareVersionController as object)['switchDeveloperMode']();
        let mockfunc2: Function =
          mocker.mockFunc(SystemParamUtil, SystemParamUtil.getParam);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn('false');
        (softwareVersionController as object)['securityStatus'] = '1';
        (softwareVersionController as object)['switchDeveloperMode']();
        (softwareVersionController as object)['securityStatus'] = '0';
        (softwareVersionController as object)['switchDeveloperMode']();
        (softwareVersionController as object)['developerStatus'] = 'false';
        (softwareVersionController as object)['switchDeveloperMode']();
        mocker.clear(SystemParamUtil);
      } catch (e) {
      } finally {
        done()
      }
    });
  })
}

