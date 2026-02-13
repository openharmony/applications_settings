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

import { afterAll, beforeAll, describe, expect, it } from '@ohos/hypium';
import { BusinessError } from '@ohos.base';
import { Driver, ON } from '@ohos.UiTest';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { LogUtil, NavEntryKey } from '@ohos/settings.common';
import { COMMON_DELAY, WAIT_DELAY } from '../types';
import { Constant } from '../constant/Constant';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const TAG: string = 'wlanPageTest';

export default function wlanPageTest() {
  describe('wlanPageTest', () => {
    // 定义Driver类
    let dr: Driver | null = null;
    beforeAll(async () => {
      try {
        DELEGATOR.startAbility({
          bundleName: Constant.SETTINGS_BUNDLE_NAME,
          abilityName: Constant.SETTINGS_MAIN_ABILITY_NAME,
          'uri': NavEntryKey.WIFI_ENTRY,
        }).then(() => {
          LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success.`);
        });
      } catch (exception) {
        LogUtil.error(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
      }
      LogUtil.info(`${Constant.TAG} wlanConnectTest describe end`);
    })

    afterAll(async () => {
      // 定义Driver类
      let dr: Driver = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      try {
        // 恢复关闭WLAN
        let WLANSwitch = await dr.waitForComponent(ON.id('entry_toggle_wifi_switch'), WAIT_DELAY);
        let switchStatus: boolean = await WLANSwitch.isChecked();
        if (switchStatus) {
          LogUtil.info(`${Constant.TAG} WLANSwitch clicked close ddd`);
          await WLANSwitch.click();
          LogUtil.info(`${Constant.TAG} WLANSwitch clicked`);
        }
        await dr.delayMs(WAIT_DELAY);
        // 校验WIFI为关闭
        await dr.assertComponentExist(ON.checked(false).id('entry_toggle_wifi_switch'));
        await dr.pressHome();
      } catch (err) {
        LogUtil.showError(TAG, `err.code : ${(err as BusinessError)?.code}, message: ${(err as BusinessError).message}`);
      }
    })

    /*
    * @tc.number:wlanPageTest_001
    * @tc.name: WLAN入口验证
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 设置入口进入WLAN页面，WLAN配置项存在
    */
    it('wlanPageTest_001', 0, async () => {
      LogUtil.info(`${Constant.TAG} wlanPageTest_001 start`);
      // 定义Driver类
      dr = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      try {
        // 校验WIFI初始开关为关闭
        await dr.assertComponentExist(ON.checked(false).id('entry_toggle_wifi_switch'));
        // 校验WLAN为关闭时页面存在控件
        await dr.assertComponentExist(ON.text(Constant.WIFI_PRECISION_TEXT));
      } catch (err) {
        LogUtil.showError(TAG, `err.code : ${(err as BusinessError)?.code}, message: ${(err as BusinessError).message}`);
      }
      LogUtil.info(`${Constant.TAG} wlanPageTest_001 end`);
    })

    /*
    * @tc.number:wlanPageTest_002
    * @tc.name: WLAN开关校验
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 开启、关闭WLAN开关
    */
    it('wlanPageTest_002', 0, async () => {
      LogUtil.info(`${Constant.TAG} wlanPageTest_002 start`);
      // 定义Driver类
      dr = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      try {
        // 开启WLAN
        let wlanSwitch = await dr.waitForComponent(ON.id('entry_toggle_wifi_switch'), WAIT_DELAY);
        await wlanSwitch.click();
        await dr.delayMs(WAIT_DELAY);
        LogUtil.info(`${Constant.TAG} wlanSwitch clicked`);
        // 校验开关开启后页面字样
        await dr.assertComponentExist(ON.text(Constant.WIFI_AVAILABLE_AP_GROUP));
        // 关闭WLAN的开关
        await wlanSwitch.click();
        await dr.delayMs(WAIT_DELAY);
        LogUtil.info(`${Constant.TAG} wlanSwitch clicked`);
        // 校验开关关掉后无可用WLAN字样
        let availableDevices = await dr.waitForComponent(ON.text(Constant.WIFI_AVAILABLE_AP_GROUP), WAIT_DELAY);
        await expect(availableDevices).assertNull();
        await wlanSwitch.click();
        // 校验开关打开后无提高精确度文本
        let improvePrecision = await dr.waitForComponent(ON.text(Constant.WlAN_PRECISION), WAIT_DELAY);
        await expect(improvePrecision).assertNull();
      } catch (err) {
        LogUtil.showError(TAG, `err.code : ${(err as BusinessError)?.code}, message: ${(err as BusinessError).message}`);
      }
      LogUtil.info(`${Constant.TAG} wlanPageTest_002 end`);
    })

    /*
     * @tc.number:wlanPageTest_003
     * @tc.name: WLAN关闭页面验证
     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
     * @tc.desc: WLAN关闭页面，无可用WLAN字样
     */
    it('wlanPageTest_003', 0, async () => {
      LogUtil.info(`${Constant.TAG} wlanPageTest_003 start`);
      // 定义Driver类
      dr = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      try {
        // 校验WIFI初始开关为关闭
        await dr.assertComponentExist(ON.checked(false).id('entry_toggle_wifi_switch'));
        // 校验WLAN为关闭时无可用WLAN字样
        let availableWlan = await dr.waitForComponent(ON.text(Constant.WIFI_AVAILABLE_AP_GROUP), WAIT_DELAY);
        await expect(availableWlan).assertNull();
      } catch (err) {
        LogUtil.showError(TAG, `err.code : ${(err as BusinessError)?.code}, message: ${(err as BusinessError).message}`);
      }
      LogUtil.info(`${Constant.TAG} wlanPageTest_003 end`);
    })

    /*
     * @tc.number:wlanPageTest_004
     * @tc.name: WLAN关闭初始状态验证
     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
     * @tc.desc: WLAN初始开关为关闭
     */
    it('wlanPageTest_004', 0, async () => {
      LogUtil.info(`${Constant.TAG} wlanPageTest_004 start`);
      // 定义Driver类
      dr = await Driver.create();
      await dr.delayMs(COMMON_DELAY);

      try {
        // 校验WIFI初始开关为关闭
        await dr.assertComponentExist(ON.checked(false).id('entry_toggle_wifi_switch'));
      } catch (err) {
        LogUtil.showError(TAG, `err.code : ${(err as BusinessError)?.code}, message: ${(err as BusinessError).message}`);
      }
      LogUtil.info(`${Constant.TAG} wlanPageTest_004 end`);
    })
  })
}