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

import { afterAll, beforeAll, describe, expect, it, TestType } from '@ohos/hypium';
import { abilityDelegatorRegistry, DisplayRotation, Driver, ON } from '@kit.TestKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG = 'ViewTest';
const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function ViewTest() {
  describe('ViewTest', () => {
    const driver = Driver.create();

    beforeAll(async () => {
      LogUtil.showInfo(TAG, 'beforeAll');
      await DELEGATOR.startAbility({
        bundleName: 'com.ohos.settings',
        abilityName: 'com.ohos.settings.MainAbility',
        uri: 'phone_mouse_settings',
      });
      await driver.delayMs(1000);
    });

    afterAll(() => {
      LogUtil.showInfo(TAG, 'afterAll');
    });

    it('ViewTest_Slider_001', TestType.FUNCTION, async () => {
      LogUtil.showInfo(TAG, 'ViewTest_Slider_001 it begin');
      const sliders = await driver.findComponents(ON.type('Slider'));
      if (!sliders) {
        return
      }
      for (const slider of sliders) {
        await slider.click();
        await driver.delayMs(1000);
      }
      expect().assertUndefined();
    });

    it('ViewTest_Button_001', TestType.FUNCTION, async () => {
      LogUtil.showInfo(TAG, 'ViewTest_Button_001 it begin');
      const buttons = await driver.findComponents(ON.type('Button'));
      if (!buttons) {
        return
      }
      for (const button of buttons) {
        await button.click();
        await driver.delayMs(1000);
        const menuItems = await driver.findComponents(ON.type('MenuItem'));
        if (!menuItems) {
          continue;
        }
        for (const menuItem of menuItems) {
          await menuItem.click();
          await driver.delayMs(1000);
          break;
        }
      }
      expect().assertUndefined();
    });

    it('ViewTest_Toggle_001', TestType.FUNCTION, async () => {
      LogUtil.showInfo(TAG, 'ViewTest_Toggle_001 it begin');
      const toggles = await driver.findComponents(ON.type('Toggle'));
      if (!toggles) {
        return;
      }
      for (const toggle of toggles) {
        await toggle.click();
        await driver.delayMs(1000);
        await toggle.click();
        await driver.delayMs(1000);
      }
      expect().assertUndefined();
    });

    it('ViewTest_001', TestType.FUNCTION, async () => {
      LogUtil.showInfo(TAG, 'ViewTest_001 it begin');
      await driver.setDisplayRotation(DisplayRotation.ROTATION_90);
      await driver.delayMs(1000);
      await driver.setDisplayRotation(DisplayRotation.ROTATION_180);
      await driver.delayMs(1000);
      expect().assertUndefined();
    });
  });
}
