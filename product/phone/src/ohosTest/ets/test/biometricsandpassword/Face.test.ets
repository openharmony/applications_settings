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
import { BusinessError } from '@ohos.base';
import { COMMON_DELAY, SWIPE_DELAY, WAIT_DELAY } from '../types';
import { Constant } from '../constant/Constant';
import { LogUtil, PasswordUtil } from '@ohos/settings.common';
import IamSystemParamUtil from
  '../../../../main/ets/pages/biometricsandpassword/module/fingerprint/iambigdata/IamSystemParamUtil';
import { UserIdmModel } from '@hw-hmos/settings-face-auth';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const driver: Driver = Driver.create();

export default function faceTest() {
  describe('faceTest', () => {
    beforeAll(async () => {
      try {
        await DELEGATOR.startAbility({
          'bundleName': Constant.SETTINGS_BUNDLE_NAME,
          'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
          'uri': 'biometrics_and_password_settings',

        }).then(() => {
          LogUtil.info(`${Constant.TAG} start biometrics and password page success`);
        });
      } catch (exception) {
        LogUtil.error(`${Constant.TAG} Failed to startAbility, code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
      }
    });

    afterAll(async () => {
      // 定义Driver类
      await driver.delayMs(COMMON_DELAY);
      await driver.pressHome();
      await driver.delayMs(COMMON_DELAY);
    });
  })
}

/**
 * 进入人脸页面用例
 */
async function faceTest1() {
  LogUtil.info(`${Constant.TAG} FaceTest_001 start`);
  // 校验页面是否存在“人脸”入口
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.FACE));
  // Step1: 点击"人脸识别“
  let facePasswd = await driver.waitForComponent(ON.text(Constant.FACE), WAIT_DELAY);
  await facePasswd.click();
  LogUtil.info(`${Constant.TAG} lockedPasswd clicked`);
  // 校验设置锁屏数字密码是否存在以下入口
  await driver.delayMs(COMMON_DELAY);
  PasswordUtil.hasPinPassword(async (hasPinPassword) => {
    if (hasPinPassword) {
      for (let i = 0; i < 6; i++) {
        await driver.triggerKey(2000);
      }
    } else {
      for (let i = 0; i < 6; i++) {
        await driver.triggerKey(2000);
      }
      await driver.delayMs(COMMON_DELAY);
      // Step3: 点击弹框‘继续使用’
      let continueBtn = await driver.waitForComponent(ON.text(Constant.USE_ANYWAY), WAIT_DELAY);
      await continueBtn.click()
      await driver.delayMs(COMMON_DELAY);
      LogUtil.info(`${Constant.TAG} USE_ANYWAY clicked`);
      await driver.assertComponentExist(ON.text(Constant.INPUT_PASSWORD_AGAIN));
      // Step4: 再次输入与上次输入一致的6位数字锁屏密码
      await driver.delayMs(COMMON_DELAY);
      for (let i = 0; i < 6; i++) {
        await driver.triggerKey(2000);
      }
    }
  })
  LogUtil.info(`${Constant.TAG} password inputed`);
  LogUtil.info(`${Constant.TAG} FaceTest_001 end`);
}
