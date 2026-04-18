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

import { describe, beforeAll, it, afterAll } from '@ohos/hypium';
import { BusinessError } from '@ohos.base';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { LogUtil, NavEntryKey } from '@ohos/settings.common';
import { Driver, ON } from '@ohos.UiTest';
import { COMMON_DELAY, WAIT_DELAY } from '../types';
import { Constant } from '../constant/Constant';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const TAG: string = 'Settings Display test';

export default function RefreshRatePageTest() {
  describe('RefreshRatePageTest', () => {
    // 定义Driver类
    let dr: Driver | null = null;
    beforeAll(async () => {
      // 跳转到显示界面和亮度页面
      try {
        await DELEGATOR.startAbility({
          'bundleName': Constant.SETTINGS_BUNDLE_NAME,
          'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
          'uri': NavEntryKey.DISPLAY_ENTRY,
        }).then(() => {
          LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success`);
        });
      }
      catch (exception) {
        LogUtil.info(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
      }
      ;
    });

    afterAll(async () => {
      // 定义Driver类
      dr = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      // 返回设置
      await dr.pressBack();
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });

    /*
    * @tc.number:RefreshRatePageTest_001
    * @tc.name: 屏幕刷新率菜单入口验证
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 点击进入屏幕刷新率entry，相关布局展示
    */
    it('RefreshRatePageTest_001', 0, async () => {
      LogUtil.info(`${TAG} check radio exist... `);
      // 定义Driver类
      dr = await Driver.create();
      // 跳转屏幕刷新率界面
      await dr.delayMs(COMMON_DELAY);
      try {
        let refreshRateTab = await dr.waitForComponent(ON.id('entry_title_screen_refresh_rate_entry'), WAIT_DELAY);
        await refreshRateTab.click();
        LogUtil.info(`${TAG} refreshRateTab clicked`);
        await dr.delayMs(COMMON_DELAY);
        // 相关布局校验
        await dr.assertComponentExist(ON.text(Constant.SCREEN_REFRESH_RATE_TITLE));
        await dr.assertComponentExist(ON.text(Constant.SCREEN_REFRESH_RATE_STANDARD));
        // 返回显示和亮度页面
        await dr.pressBack();
      } catch (err) {
        LogUtil.showError(TAG, `err.code : ${(err as BusinessError)?.code}, message: ${(err as BusinessError).message}`);
      }
      await dr.delayMs(COMMON_DELAY);
    })
  })
}