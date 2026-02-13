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

import { describe, expect, it, beforeAll, afterAll } from '@ohos/hypium';
import { Driver, ON } from '@ohos.UiTest';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BusinessError } from '@ohos.base';
import { COMMON_DELAY, WAIT_DELAY } from '../types';
import { Constant } from '../constant/Constant';
import { MouseSettingsManager } from '../../../../main/ets/Setting/Mouse/MouseSettingsManager';
import { Utils } from '../../../../main/ets/Setting/Mouse/utils/Utils';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const TAG: string = 'MouseSettingstest';

export default function phoneMouseSettingsTest() {


  describe('phoneMouseSettingsPageTest', () => {
    const driver = Driver.create();

    beforeAll(async () => {
      try {
        await DELEGATOR.startAbility({
          'bundleName': Constant.SETTINGS_BUNDLE_NAME,
          'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
          'uri': 'phone_mouse_settings',
        }).then(() => {
          LogUtil.info(`${Constant.TAG} system_and_updates start success`);
        });
      } catch (exception) {
        LogUtil.error(`Failed to startAbility. Code: ${(exception as BusinessError).code},
        message: ${(exception as BusinessError).message}`);
      }
      LogUtil.info(`${TAG} dphone_mouse_settingsTab clicked`);
    });

    afterAll(async () => {
    })

    it('phoneMouseSettingsPageTest_001', 0, async () => {
      LogUtil.showInfo(TAG, 'phoneMouseSettingsPageTest_001 it begin');
      const radios = await driver.findComponents(ON.type('Radio'));
      if (!radios) {
        return;
      }
      for (const radio of radios) {
        await radio.click();
        await driver.delayMs(1000);
      }
      expect().assertUndefined();
    });
  });
}
