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

import { describe, it, beforeAll, afterAll } from '@ohos/hypium';
import { Driver, ON } from '@ohos.UiTest';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { LogUtil, NavEntryKey } from '@ohos/settings.common';
import { BusinessError } from '@ohos.base';
import { COMMON_DELAY, WAIT_DELAY } from '../types';
import { Constant } from '../constant/Constant';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function sleepSettingsTest() {
  describe('sleepSettingsTest', () => {
    beforeAll(async () => {
      // 跳转显示和亮度
      try {
        await DELEGATOR.startAbility({
          'bundleName': Constant.SETTINGS_BUNDLE_NAME,
          'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
          'uri': NavEntryKey.DISPLAY_ENTRY,
        }).then(() => {
          LogUtil.info(`${Constant.TAG} com.ohos.settings.AppInfoAbility start success`);
        });
      } catch (exception) {
        LogUtil.info(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
      }
      ;
      // 定义Driver类
      let dr = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      LogUtil.info(`${Constant.TAG} displayTab clicked`);
    })
    ;
    afterAll(async () => {
      // 定义Driver类
      let dr: Driver = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });
  });
}