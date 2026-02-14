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

import { describe, it, beforeAll, expect, afterAll } from '@ohos/hypium';
import { Driver, ON } from '@ohos.UiTest';
import { BusinessError } from '@ohos.base';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { ExternalMenuPreloadManager, LogUtil } from '@ohos/settings.common';
import { COMMON_DELAY, WAIT_DELAY } from '../types';
import { Constant } from '../constant/Constant';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function notificationAndStatusBarTest() {
  describe('notificationAndStatusBarTest', () => {
    beforeAll(async () => {
      // 跳转到通知和状态栏
      try {
        ExternalMenuPreloadManager.getInstance().preloadUIExtensionAbility('systemui_notification_settings',
          DELEGATOR.getAppContext());
        await DELEGATOR.startAbility({
          'bundleName': 'com.ohos.settings',
          'abilityName': 'com.ohos.settings.MainAbility',
          'uri': 'systemui_notification_settings',
        }).then(() => {
          LogUtil.info(`${Constant.TAG} Notifications and Status Bar page start success`);
        });
      } catch (exception) {
        LogUtil.error(`${Constant.TAG} Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
      }
    });

    afterAll(async () => {
      // 定义Driver类
      let dr = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });
  });
}