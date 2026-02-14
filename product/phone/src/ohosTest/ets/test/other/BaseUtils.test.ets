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
import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium'
import { DeviceUtil, JsonUtil } from '@ohos/settings.common';
import { DeviceStateUtils, MenuUUID, SatelliteUtils } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { resourceManager } from '@kit.LocalizationKit';

export default function BaseUtilsTest() {
  describe('BaseUtilsTest', () => {
    let deviceUtilInstance = DeviceUtil;
    let jsonUtil = JsonUtil;
    let deviceStateUtils = DeviceStateUtils;
    let satelliteUtils = SatelliteUtils;
    let menuUUID = MenuUUID;

    it('BaseUtilsTest_menuUUID', 0, () => {
      let result = menuUUID.uuid();
      expect(result !== null).assertTrue();
    })

    it('BaseUtilsTest_isSupport', 0, () => {
      let result = satelliteUtils.isSupport();
      expect(result !== null).assertTrue();

      let result2 = satelliteUtils.isSupport();
      expect(result2 !== null).assertTrue();
    })

    it('BaseUtilsTest_isSupportMessage', 0, () => {
      let result = satelliteUtils.isSupportMessage();
      expect(result !== null).assertTrue();
    })

    it('BaseUtilsTest_isCommunicationOpen', 0, () => {
      let result = satelliteUtils.isCommunicationOpen();
      expect(result !== null).assertTrue();
    })

    it('BaseUtilsTest_isSupportCarSatellite', 0, () => {
      let result = satelliteUtils.isSupportCarSatellite();
      expect(result !== null).assertTrue();
    })

    it('BaseUtilsTest_getStringByFileAsync', 0, async (done: Function) => {
      try {
        let params: resourceManager.ResourceManager | undefined = undefined;
        let result = await jsonUtil.getStringByFileAsync(params, 'test');
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    })
    it('BaseUtilsTest_getStringByFileAsync2', 0, async (done: Function) => {
      try {
        let params: resourceManager.ResourceManager = {} as resourceManager.ResourceManager;
        let result = await jsonUtil.getStringByFileAsync(params, '')
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    })

    it('BaseUtilsTest_isWearable', 0, () => {
      let result = deviceUtilInstance.isWearable();
      expect(result !== null).assertTrue();
    })

    it('BaseUtilsTest_isDeviceEmulator', 0, () => {
      let result = deviceUtilInstance.isDeviceEmulator();
      expect(result !== null).assertTrue();
    })

    it('BaseUtilsTest_isDeviceDefaultSplit', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(deviceUtilInstance, deviceUtilInstance.isSmallFoldProduct);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
      let result = deviceUtilInstance.isDeviceDefaultSplit();
      expect(result !== null).assertTrue();

      let mockfunc2: Function = mocker.mockFunc(deviceUtilInstance, deviceUtilInstance.isSmallFoldProduct);
      when(mockfunc2)(ArgumentMatchers.any).afterReturn(false);
      let result2 = deviceUtilInstance.isDeviceDefaultSplit();
      expect(result2 !== null).assertTrue();
      mocker.clear(deviceUtilInstance);
    })

    it('BaseUtilsTest_isFoldExpand', 0, () => {
      let result = deviceUtilInstance.isFoldExpand();
      expect(result !== null).assertTrue();
    })

    it('BaseUtilsTest_isFoldFold', 0, () => {
      let result = deviceUtilInstance.isFoldFold();
      expect(result !== null).assertTrue();
    })

    it('BaseUtilsTest_isDevicePortrait', 0, () => {
      let result = deviceUtilInstance.isDevicePortrait();
      expect(result !== null).assertTrue();
    })

    it('BaseUtilsTest_getDisplayOrientation', 0, () => {
      let result = deviceUtilInstance.getDisplayOrientation();
      expect(result !== null).assertTrue();
    })

    it('BaseUtilsTest_isSmallFoldProduct', 0, () => {
      let result = deviceUtilInstance.isSmallFoldProduct();
      expect(result !== null).assertTrue();
    })

    it('BaseUtilsTest_isNexFormsProduct', 0, () => {
      let result = deviceUtilInstance.isNexFormsProduct();
      expect(result !== null).assertTrue();
    })

    it('BaseUtilsTest_isLargeInFoldProduct', 0, () => {
      let result = deviceUtilInstance.isLargeInFoldProduct();
      expect(result !== null).assertTrue();
    })

    it('BaseUtilsTest_getFoldProductType', 0, () => {
      (deviceUtilInstance as object)['sFoldProductTypeValue'] = 0;
      (deviceUtilInstance as object)['getFoldProductType']();
    })

    it('BaseUtilsTest_isDevicePhone', 0, () => {
      let result = deviceUtilInstance.isDevicePhone();
      expect(result !== null).assertTrue();
    })

    it('BaseUtilsTest_isDevicePc', 0, () => {
      let result = deviceUtilInstance.isDevicePc();
      expect(result !== null).assertTrue();
    })

    it('BaseUtilsTest_isDevicePad', 0, () => {
      let result = deviceUtilInstance.isDevicePad();
      expect(result !== null).assertTrue();
    })

    it('BaseUtilsTest_isDeviceTv', 0, () => {
      let result = deviceUtilInstance.isDeviceTv();
      expect(result !== null).assertTrue();
    })

    it('BaseUtilsTest_Wearable', 0, () => {
      let result = deviceUtilInstance.isWearable();
      expect(result !== null).assertTrue();
    })

    it('BaseUtilsTest_DeviceEmulator', 0, () => {
      let result = deviceUtilInstance.isDeviceEmulator();
      expect(result !== null).assertTrue();
    })

    it('BaseUtilsTest_isSuperFoldProduct', 0, () => {
      let result = deviceUtilInstance.isSuperFoldProduct();
      expect(result !== null).assertTrue();
    })
  })
}