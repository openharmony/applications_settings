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
import { describe, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium'
import { CommonUtils, DeviceUtil } from '@ohos/settings.common'
import { common } from '@kit.AbilityKit';

export default function CommonUtilsTest() {
  describe('CommonUtilsTest', () => {
    let commonUtilsInstance = CommonUtils;
    it('commonUtilsTest_01', 0, (done: Function) => {
      try {
        let result = commonUtilsInstance.isPageExist('key');
        expect(result === null).assertFalse();
      } catch (e) {
      } finally {
        done()
      }
    })

    it('commonUtilsTest_02', 0, (done: Function) => {
      try {
        let result = commonUtilsInstance.isPageActive('key');
        expect(result === null).assertFalse();
      } catch (e) {
      } finally {
        done()
      }
    })

    it('commonUtilsTest_03', 0, async (done: Function) => {
      try {
        let context = AppStorage.get<Context>('pageContext') as common.UIAbilityContext;
        let result = await commonUtilsInstance.getScreenHeight(context);
        expect(result === null).assertFalse();

        let context2: common.Context = AppStorage.get<common.Context>('context') as common.Context;
        let result2 = await commonUtilsInstance.getScreenHeight(context2);
        expect(result2 === -1).assertTrue();
      } catch (e) {
      } finally {
        done();
      }

    })

    it('commonUtilsTest_04', 0, (done: Function) => {
      try {
        let result = commonUtilsInstance.isFromSearch();
        expect(result === null).assertFalse();
      } catch (e) {
      } finally {
        done()
      }
    })

    it('commonUtilsTest_05', 0, () => {
      let deviceUtilInstance = DeviceUtil;
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(deviceUtilInstance, deviceUtilInstance.isDevicePc);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
      let result = commonUtilsInstance.getSettingsPagePadding(10);
      expect(result === 10).assertTrue();

      let mockfunc2: Function = mocker.mockFunc(deviceUtilInstance, deviceUtilInstance.isDevicePc);
      when(mockfunc2)(ArgumentMatchers.any).afterReturn(false);
      let result2 = commonUtilsInstance.getSettingsPagePadding(10);
      expect(result2 === 0).assertTrue();
      mocker.clear(deviceUtilInstance);
    })

  })
}