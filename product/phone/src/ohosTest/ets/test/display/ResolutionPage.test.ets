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
import { LogUtil, NavEntryKey, SettingsDataUtils } from '@ohos/settings.common';
import { Driver, ON } from '@ohos.UiTest';
import { COMMON_DELAY, WAIT_DELAY } from '../types';
import { Constant } from '../constant/Constant';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const TAG: string = 'ResolutionPageTest';

export default function ResolutionPageTest() {
  describe('ResolutionPageTest', () => {
    // 定义Driver类
    let dr: Driver | null = null;
    beforeAll(async () => {
      // 跳转到显示和亮度界面
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
      };
      // 定义Driver类
      let dr = await Driver.create();
      // 跳转到显示和亮度界面
      await dr.delayMs(COMMON_DELAY);
    });

    afterAll(async () => {
      // 定义Driver类
      dr = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });

    /*
    * @tc.number:ResolutionPageTest_001
    * @tc.name: 屏幕分辨率菜单入口验证
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 点击进入屏幕分辨率entry，相关布局展示
    */
    it('ResolutionPageTest_001', 0, async () => {
      try {
        let type: string = SettingsDataUtils.getSettingsData('settings.display.resolution_style', Constant.SMART_RESOLUTION_TYPE);
        if (type === Constant.SMART_RESOLUTION_TYPE) {
          await dr?.assertComponentExist(ON.text(Constant.SMART_RESOLUTION_TITLE));
        } else {
          await dr?.assertComponentExist(ON.text(Constant.SCREEN_RESOLUTION_TITLE));
          let resolutionMenu = await dr?.waitForComponent(ON.type(Constant.SCREEN_RESOLUTION_TITLE), WAIT_DELAY);
          await resolutionMenu?.click();
          await dr?.assertComponentExist(ON.text(Constant.SCREEN_RESOLUTION_HIGH_TITLE));
          await dr?.assertComponentExist(ON.text(Constant.SCREEN_RESOLUTION_MIDDLE_TITLE));
          await dr?.assertComponentExist(ON.text(Constant.SCREEN_RESOLUTION_LOW_TITLE));
          let backIcon = await dr?.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
          await backIcon?.click();
        }
      } catch(err) {
        LogUtil.showError(TAG, `err.code : ${(err as BusinessError)?.code}, message: ${(err as BusinessError).message}`);
      }
    })
  })
}