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

import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { describe, beforeAll, beforeEach, it, expect, TestType, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Driver } from '@ohos.UiTest';
import { CheckEmptyUtils, CustomMenuManager } from '@ohos/settings.common';
import { BusinessError } from '@ohos.base';
import { Constant } from '../../constant/Constant';
import { COMMON_DELAY } from '../../types';

const CCM_PATH = 'etc/settings/hide_menu.json';
const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function customMenuManagerTest() {
  describe('customMenuManagerTest', () => {
    let driver = Driver.create();

    beforeAll(async () => {
      try {
        await DELEGATOR.startAbility({
          'bundleName': Constant.SETTINGS_BUNDLE_NAME,
          'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME
        }).then(() => {
          LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success`);
        });
      } catch (exception) {
        LogUtil.info(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
      }
      await driver.delayMs(COMMON_DELAY);
    })

    beforeEach(() => {
      CustomMenuManager.getInstance().getHideMenus().clear();
    });

    it("customMenuManagerTest_001", 0, () => {
      let customMenuM: CustomMenuManager = CustomMenuManager.getInstance();
      let customMenuM1: CustomMenuManager = CustomMenuManager.getInstance();
      expect(customMenuM == customMenuM1).assertTrue();
    })
    it("customMenuManagerTest_002", 0, () => {
      let customMenuM: CustomMenuManager = CustomMenuManager.getInstance();
      customMenuM.isMenuHide(undefined);
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(customMenuM, customMenuM.isEmpty);
      when(mockFun)().afterReturn(false);
      customMenuM.isMenuHide('undefined');
      expect(customMenuM != null).assertTrue();
      mocker.clear(customMenuM);
    })
    it("customMenuManagerTest_003", 0, async (done: Function) => {
      let customMenuM: CustomMenuManager = CustomMenuManager.getInstance();
      await customMenuM.loadCcmConfigs();
      let mocker1: MockKit = new MockKit();
      let mockFun1: Function = mocker1.mockFunc(CheckEmptyUtils, CheckEmptyUtils.isEmptyArr);
      when(mockFun1)(ArgumentMatchers.any).afterReturn(true);
      await customMenuM.loadCcmConfigs();
      expect(customMenuM != null).assertTrue();
      mocker1.clear(CheckEmptyUtils);
      done();
    })
  });
}