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
import { BusinessError } from '@ohos.base';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { COMMON_DELAY, WAIT_DELAY } from '../types';
import { Constant } from '../constant/Constant';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

const TAG: string = 'nfcPageTest';

export default function nfcPageTest() {
  describe('nfcPageTest', () => {
    let dr: Driver = Driver.create();
    beforeAll(async () => {
      try {
        await DELEGATOR.startAbility({
          'bundleName': Constant.SETTINGS_BUNDLE_NAME,
          'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
          'uri': NavEntryKey.MORE_CONNECTION_ENTRY,
        }).then(() => {
          LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success`);
        });
      } catch (exception) {
        LogUtil.info(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
      };
    });

    afterAll(async () => {
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });

    /*
    * @tc.number: nfcPageTest_001
    * @tc.name: nfc默认关闭测试
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: nfc默认关闭测试
    */
    it('nfcPageTest_001', 0, nfcPageTest_001(dr));

    /*
    * @tc.number: nfcPageTest_002
    * @tc.name: 校验nfc页面展示正确
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 校验nfc页面展示正确
    */
    it('nfcPageTest_002', 0, nfcPageTest_002(dr));

    /*
    * @tc.number: nfcPageTest_003
    * @tc.name: 校验nfc开启功能
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 校验nfc开启功能
    */
    it('nfcPageTest_003', 0, nfcPageTest_003(dr));
  });
}

function nfcPageTest_001(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} nfcPageTest_001 start`);
    await driver.delayMs(COMMON_DELAY);
    try {
      // 校验NFC默认已关闭
      await driver.assertComponentExist(ON.text(Constant.MORE_CONNECTION_SWITCH_OFF));
    } catch (err) {
      LogUtil.showError(TAG, `nfcPageTest_001 err.code : ${err?.code}, message: ${err?.message}`);
    }
    done();
    LogUtil.info(`${TAG} displayPageTest_001 end`);
  };
}

function nfcPageTest_002(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${Constant.TAG} nfcPageTest_002 start`);
    await driver.delayMs(COMMON_DELAY);
    try {
      // 点击NFC
      let nfcTab = await driver.waitForComponent(ON.text('NFC'), WAIT_DELAY);
      await nfcTab.click();
      LogUtil.info(`${TAG} nfcTab1 clicked1`);
      // 校验NFC页面展示正确
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.text(Constant.NFC_HOW_TO_USE_DESCRIPTION));
      await driver.assertComponentExist(ON.text(Constant.DEFAULT_FAULT_PAYMENT_APP));
    } catch (err) {
      LogUtil.showError(TAG, `nfcPageTest_002 err.code : ${err?.code}, message: ${err?.message}`);
    }
    done();
    LogUtil.info(`${TAG} nfcPageTest_002 end`);
  };
}

function nfcPageTest_003(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} nfcPageTest_003 start`);
    await driver.delayMs(COMMON_DELAY);
    try {
      // 打开NFC开关
      let nfcAccessTab = await driver.waitForComponent(ON.id('entry_toggle_nfc_access_enable'), WAIT_DELAY);
      await nfcAccessTab.click();
      LogUtil.info(`${TAG} nfcAccessTab1 clicked1`);
      // 校验NFC打开成功
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.checked(true).text('entry_toggle_nfc_access_enable'));
    } catch (err) {
      LogUtil.showError(TAG, `nfcPageTest_003 err.code : ${err?.code}, message: ${err?.message}`);
    }
    done();
    LogUtil.info(`${TAG} nfcPageTest_003 end`);
  };
}