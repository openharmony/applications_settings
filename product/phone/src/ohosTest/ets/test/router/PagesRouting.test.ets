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

import { describe, beforeAll, it, afterAll, expect } from '@ohos/hypium';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Driver, ON } from '@ohos.UiTest';
import { BusinessError } from '@ohos.base';
import { COMMON_DELAY, WAIT_DELAY } from '../types';
import { Constant } from '../constant/Constant';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const TAG: string = 'PagesRoutingTest : ';

export default function PagesRoutingTest() {
  describe('PagesRoutingTest', () => {
    let driver = Driver.create();
    beforeAll(async () => {
      try {
        await DELEGATOR.startAbility({
          'bundleName': 'com.ohos.settings',
          'abilityName': 'com.ohos.settings.MainAbility',
        }).then(() => {
          LogUtil.info(`${TAG} com.ohos.settings.MainAbility start success`);
        });
      } catch (exception) {
        LogUtil.info(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
      }
    });

    afterAll(async () => {
      await driver.delayMs(COMMON_DELAY);
    });

    /*
     * @tc.number: PagesRoutingTest_001
     * @tc.name: 路由到设置WLAN界面
     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
     * @tc.desc: 在设置应用内拉起WLAN界面
     */
    it('PagesRoutingTest_001', 0, async () => {
      LogUtil.info(`${TAG} routing wlan page`);
      await driver.delayMs(COMMON_DELAY);
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': 'wifi_entry',
      }).then(() => {
        LogUtil.info(`${TAG} start wifi page success`);
      });
      await driver.delayMs(COMMON_DELAY);
      await driver.pressHome();
      await driver.delayMs(COMMON_DELAY);
    });

    /*
     * @tc.number: PagesRoutingTest_002
     * @tc.name: 路由到设置BLUETOOTH界面
     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
     * @tc.desc: 在设置应用内拉起蓝牙界面
     */
    it('PagesRoutingTest_002', 0, async () => {
      LogUtil.info(`${TAG} routing bluetooth page`);
      await driver.delayMs(COMMON_DELAY);
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': 'bluetooth_entry',
      }).then(() => {
        LogUtil.info(`${TAG} start bluetooth page success`);
      });
      await driver.delayMs(COMMON_DELAY);
      await driver.pressHome();
      await driver.delayMs(COMMON_DELAY);
    });

    /*
     * @tc.number: PagesRoutingTest_003
     * @tc.name: 路由到设置关于本机界面
     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
     * @tc.desc: 在设置应用内拉起关于本机界面
     */
    it('PagesRoutingTest_003', 0, async () => {
      LogUtil.info(`${TAG} routing about device page`);
      await driver.delayMs(COMMON_DELAY);
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': 'about_device',
      }).then(() => {
        LogUtil.info(`${TAG} start about device page success`);
      });
      await driver.delayMs(COMMON_DELAY);
      await driver.pressHome();
      await driver.delayMs(COMMON_DELAY);
    });

    /*
     * @tc.number: PagesRoutingTest_004
     * @tc.name: 路由到应用详情页
     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
     * @tc.desc: 在设置应用内拉起应用详情页
    */
    it('PagesRoutingTest_004', 0, async () => {
      LogUtil.info(`${TAG} routing about application info page`);
      await driver.delayMs(COMMON_DELAY);
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': 'application_info_entry',
        'parameters': {
          'pushParams': 'com.ohos.clock',
        }
      }).then(() => {
        LogUtil.info(`${TAG} start about applition info page success`);
      });
      await driver.delayMs(COMMON_DELAY);
      await driver.pressHome();
      await driver.delayMs(COMMON_DELAY);
    });

    /*
    * @tc.number: PagesRoutingTest_005
    * @tc.name: 路由到应用详情页
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 连续拉起两个应用，界面正常
    */
    it('PagesRoutingTest_005', 0, async () => {
      LogUtil.info(`${TAG} routing about application info page`);
      await driver.delayMs(COMMON_DELAY);
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': 'application_info_entry',
        'parameters': {
          'pushParams': 'com.ohos.tips.widget',
        }
      }).then(() => {
        LogUtil.info(`${TAG} start com.ohos.tips.widget applition info page success`);
      });

      await driver.pressHome();
      await driver.delayMs(COMMON_DELAY);
      await DELEGATOR.startAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'com.ohos.settings.MainAbility',
        'uri': 'application_info_entry',
        'parameters': {
          'pushParams': 'com.ohos.clock',
        }
      }).then(() => {
        LogUtil.info(`${TAG} start com.ohos.clock applition info page success`);
      });
      await driver.delayMs(COMMON_DELAY);
      try {
        await driver.assertComponentExist(ON.text(Constant.APPLICATION_CLOCK_TITLE));
        await driver.pressHome();
        await driver.delayMs(COMMON_DELAY);
      } catch(err) {
        LogUtil.showError(TAG, `err.code : ${(err as BusinessError)?.code}, message: ${(err as BusinessError).message}`);
      }
    });
  });
}