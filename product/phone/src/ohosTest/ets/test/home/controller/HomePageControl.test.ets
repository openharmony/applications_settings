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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { DeviceUtil, SystemParamUtil } from '@ohos/settings.common'
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource'
import { CompCtrlParam, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel'
import { SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel'
import { homeInitData, HomeInitData } from '@ohos/settings.common/src/main/ets/sendable/HomeInitData';
import { HomePageControl } from '../../../../../main/ets/Setting/Home/controller/HomePageControl'
import { HomePageMenuManager } from '../../../../../main/ets/Setting/Home/controller/HomePageMenuManager'


const PRODUCT_MODEL: string = 'const.product.model';
const PRODUCT_MODEL_EMULATOR: string = 'emulator';
const PRODUCT_DEVICE_TYPE: string = 'const.product.devicetype';
const PRODUCT_DEVICE_TYPE_PHONE: string = 'phone';

export default function HomePageControllerTest() {
  describe('HomePageControllerTest', () => {
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
    it('HomePageControllerTest_init', 0, (done: Function) => {
      try {
        let initController: HomePageControl = new HomePageControl();
        let dataSource = new DynamicDataSource();
        let component: SettingBaseModel|null = {
          id: ''
        }
        let params: CompCtrlParam = {
          compId: 'xxxxx1223',
          dataSource,
          component: component
        }
        initController.init(params);
        initController.destroy();
      } catch (e) {
      } finally {
        done();
      }
    });
    it('HomePageControllerTest_init_02', 0, (done: Function) => {
      try {
        let initController: HomePageControl = new HomePageControl();
        let dataSource = new DynamicDataSource();
        let component: SettingPageModel = {
          id: '',
          url:'ab',
          type: 0,
          groups: []
        }
        let params: CompCtrlParam = {
          compId: 'xxxxx1223',
          dataSource,
          component: component
        }
        DeviceUtil.deviceType = 'tablet';
        initController.init(params);
        initController.destroy();
      } catch (e) {
      } finally {
        done();
      }
    });

    // HomePageMenuManager
    it('HomePageControllerTest_init_03', 0, (done: Function) => {
      try {
        SystemParamUtil.setParam(PRODUCT_MODEL, PRODUCT_MODEL_EMULATOR);
        SystemParamUtil.setParam(PRODUCT_DEVICE_TYPE, PRODUCT_DEVICE_TYPE_PHONE);
        let initController: HomePageMenuManager = new HomePageMenuManager();
        initController.isPhoneEntryNotSupported();
        homeInitData.supportHiWrite = true;
        DeviceUtil.deviceType = 'tablet';
        initController.isHiWriteNotSupport();
      } catch (e) {
      } finally {
        done();
      }
    });
  })
}