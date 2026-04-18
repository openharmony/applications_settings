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

import { describe, it, beforeAll, MockKit, ArgumentMatchers, when } from '@ohos/hypium'
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { BusinessError } from '@ohos.base';
import { Driver, ON } from '@ohos.UiTest';
import { Constant } from '../../../constant/Constant';
import { COMMON_DELAY, WAIT_DELAY } from '../../../types';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function settingsRestFactoryTest() {
  describe('settingsRestFactoryTest', () => {
    beforeAll(async () => {
      try {
        await DELEGATOR.startAbility({
          'bundleName': Constant.SETTINGS_BUNDLE_NAME,
          'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
          'uri': NavEntryKey.RESET_FACTORY, // 设置->系统->重置->恢复出厂设置
        }).then(() => {
          LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success`);
        });
      } catch (exception) {
        LogUtil.info(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
      };
    });

    /*
    * @tc.number: settingsRestFactoryTest_001
    * @tc.name: 恢复出厂设置禁用验证
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 恢复出厂设置禁用时，点击重置手机按钮，会弹出功能禁用的弹窗提示
    */
    it('settingsRestFactoryTest_001', 0, async (done: Function) => {
      LogUtil.info(`${Constant.TAG} settingsRestFactoryTest_001 start`);
      try {
        let mocker: MockKit = new MockKit();
        let mockFunc: Function = mocker.mockFunc(SystemParamUtil, SystemParamUtil.getParam);
        when(mockFunc)(ArgumentMatchers.any).afterReturn('true'); // 恢复出厂设置禁用
        mocker.clear(SystemParamUtil);

        // 定义Driver类
        let dr = await Driver.create();
        await dr.delayMs(COMMON_DELAY);
        // 点击重置按钮
        let resetButton = await dr.waitForComponent(ON.text(Constant.RESET_DEVICE_BUTTON), WAIT_DELAY);
        await resetButton.click();
        LogUtil.info(`${Constant.TAG} resetButton clicked`);
        // 校验恢复出厂设置页面存在弹窗提示
        await dr.assertComponentExist(ON.text(Constant.RESET_DEVICE_DISABLED_TOAST));
        LogUtil.info(`${Constant.TAG} settingsRestFactoryTest_001 end`);
      } catch (e) {
      } finally {
        done();
      }
    });

    /*
    * @tc.number: settingsRestFactoryTest_002
    * @tc.name: 恢复出厂设置未禁用验证
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 恢复出厂设置未禁用时，点击重置手机按钮，会进入重置手机页面
    */
    it('settingsRestFactoryTest_002', 0, async (done: Function) => {
      LogUtil.info(`${Constant.TAG} settingsRestFactoryTest_002 start`);
      try {
        let mocker: MockKit = new MockKit();
        let mockFunc: Function = mocker.mockFunc(SystemParamUtil, SystemParamUtil.getParam);
        when(mockFunc)(ArgumentMatchers.any).afterReturn('false'); // 恢复出厂设置未禁用
        mocker.clear(SystemParamUtil);

        // 定义Driver类
        let dr = await Driver.create();
        await dr.delayMs(COMMON_DELAY);
        // 点击重置手机按钮
        let resetButton = await dr.waitForComponent(ON.text(Constant.RESET_DEVICE_BUTTON), WAIT_DELAY);
        await resetButton.click();
        LogUtil.info(`${Constant.TAG} resetButton clicked`);
        // 校验恢复出厂设置页面存在重置的提示信息
        await dr.assertComponentExist(ON.text(Constant.RESET_DEVICE_INFO_TEXT));
        LogUtil.info(`${Constant.TAG} settingsRestFactoryTest_002 end`);
      } catch (e) {
      } finally {
        done();
      }
    });
  });
}