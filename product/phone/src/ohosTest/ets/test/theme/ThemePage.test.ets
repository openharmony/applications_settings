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
import { COMMON_DELAY, SWIPE_DELAY } from '../types';
import { Constant } from '../constant/Constant';
import { WAIT_DELAY } from '../types';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const TAG: string = 'themePageTest';

export default function themePageTest() {
  describe('themePageTest', () => {
    beforeAll(async () => {
      try {
        await DELEGATOR.startAbility({
          'bundleName': Constant.SETTINGS_BUNDLE_NAME,
          'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
          'uri': 'theme_settings',
        }).then(() => {
          LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success`);
        });
      } catch (exception) {
        LogUtil.error(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
      };
      // 定义Driver类
      let dr: Driver = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
    });

    afterAll(async () => {
      let dr: Driver = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });
    /*
    * @tc.number: themePageTest_001
    * @tc.name: 桌面和个性化页面跳转验证
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 桌面和个性化页面跳转成功
    */
    it('themePageTest_001', 0, async () => {
      LogUtil.error(`${Constant.TAG} themePageTest_001 start`);
      // 定义Driver类
      let dr: Driver = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      try {
        // 检验是否进入桌面和个性化页面
        await dr.assertComponentExist(ON.text(Constant.THEME));
        await dr.assertComponentExist(ON.text(Constant.WALLPAPERS));
        await dr.assertComponentExist(ON.text(Constant.SCREE_OFF_DISPLAY));
        await dr.assertComponentExist(ON.text(Constant.THEME_ICON));

        // 向下滑动，校验页面元素：桌面设置和熄屏设置
        const START_X: number = 260;
        const START_Y: number = 1900;
        const END_X: number = 200;
        const END_Y: number = 397;
        const SPEED: number = 6000;
        await dr.swipe(START_X, START_Y, END_X, END_Y, SPEED);
        await dr.delayMs(SWIPE_DELAY);
        await dr.assertComponentExist(ON.text(Constant.DESKTOP_SETTINGS));
        await dr.assertComponentExist(ON.text(Constant.SCREE_OFF_SETTINGS));
        await dr.delayMs(COMMON_DELAY);
      } catch (err) {
        LogUtil.showError(TAG, `err.code : ${(err as BusinessError)?.code}, message: ${(err as BusinessError).message}`);
      }
      LogUtil.info(`${Constant.TAG} themePageTest_001 end`);
    });

    /*
     * @tc.number: themePageTest_002
     * @tc.name: 托管上云主题跳转验证
     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
     * @tc.desc: 托管上云主题跳转成功
     */
    it('themePageTest_002', 0, async () => {
      LogUtil.error(`${Constant.TAG} themePageTest_002 start`);
      // 定义Driver类
      let dr: Driver = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      try {
        // 点击托管上云主题按钮
        let themeOnLineButton = await dr.waitForComponent(ON.type('Button').text(Constant.THEME_ONLINE), WAIT_DELAY);
        await themeOnLineButton.click();
        await dr.delayMs(COMMON_DELAY);
        LogUtil.info(`${Constant.TAG} themeOnLineButton clicked`);
      } catch (err) {
        LogUtil.showError(TAG,
          `err.code : ${(err as BusinessError)?.code}, message: ${(err as BusinessError).message}`);
      }
      LogUtil.info(`${Constant.TAG} themePageTest_002 end`);
    });
  });
}
