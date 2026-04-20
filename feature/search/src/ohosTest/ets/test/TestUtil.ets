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

import { BusinessError } from '@ohos.base';
import { Driver } from '@ohos.UiTest';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';

const COMMON_TEST_DELAY: number = 5000;

export class TestUtil {
  public static async startSettingsAbility(tag: string): Promise<void> {
    const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
    try {
      await DELEGATOR.startAbility({
        'bundleName': PackagesConstant.SETTINGS_BUNDLE_NAME,
        'abilityName': PackagesConstant.SETTINGS_MAIN_ABILITY_NAME,
      }).then(() => {
        LogUtil.showInfo(tag, 'com.ohos.settings.MainAbility start success!');
      });
    } catch (exception) {
      LogUtil.info(`${tag} failed to startAbility. Message: ${(exception as BusinessError).message}`);
    }
  }

  public static async clearSettings(): Promise<void> {
    let dr: Driver  = await Driver.create();
    await dr.delayMs(COMMON_TEST_DELAY);
    await dr.pressHome();
    await dr.delayMs(COMMON_TEST_DELAY);
  }
}