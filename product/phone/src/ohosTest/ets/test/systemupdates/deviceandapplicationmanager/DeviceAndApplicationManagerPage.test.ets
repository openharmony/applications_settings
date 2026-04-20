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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BusinessError } from '@ohos.base';
import { COMMON_DELAY, WAIT_DELAY } from '../../types';
import { Constant } from '../../constant/Constant';
import bundleManager from '@ohos.bundle.bundleManager';
import settings from '@ohos.settings';

const context: Context = AppStorage.get<Context>('pageContext') as Context;
const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const COM_ENTERPRISE_ENTERPRISE_DEVICE_MANAGER_DISPLAY: string = 'com.enterprise.enterprise_device_manager_display';
const TAG: string = 'Settingstest';

export default function DeviceAndApplicationManagerPageTest() {
  describe('DeviceAndApplicationManagerPageTest', () => {
    beforeAll(async () => {
      // 跳转到通用界面
      try {
        await DELEGATOR.startAbility({
          'bundleName': Constant.SETTINGS_BUNDLE_NAME,
          'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
          'uri': 'system_and_updates',
        }).then(() => {
          LogUtil.info(`${Constant.TAG} system_and_updates start success`);
        });
      } catch (exception) {
        LogUtil.error(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
      }
      // 定义Driver类
      let dr: Driver = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      LogUtil.info(`${TAG} resetTab clicked OK`);
    });
    afterAll(async () => {
      // 定义Driver类
      let dr = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      // 点击返回按钮到设置页面
      let settingsBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
      await settingsBackIcon.click();
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });
  });
}
