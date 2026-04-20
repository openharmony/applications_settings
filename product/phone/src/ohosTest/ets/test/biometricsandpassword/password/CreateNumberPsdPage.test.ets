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
import { LogUtil } from '@ohos/settings.common/index';
import { COMMON_DELAY, WAIT_DELAY } from '../../types';
import { Constant } from '../../constant/Constant';


const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const driver: Driver = Driver.create();

export default function createNumberPsdPageTest() {
  describe('createNumberPsdPageTest', () => {
    beforeAll(async () => {
      // 进入设置主页的"生物识别和密码"
      try {
        await DELEGATOR.startAbility({
          'bundleName': Constant.SETTINGS_BUNDLE_NAME,
          'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
          'uri': 'biometrics_and_password_settings'
        }).then(() => {
          LogUtil.info(`${Constant.TAG} start biometrics and password page success`);
        });
      } catch (exception) {
        LogUtil.info(`${Constant.TAG} Failed to startAbility, code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
      }
      ;
    });

    afterAll(async () => {
      // 定义Driver类
      let dr = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });

    /*
    * @tc.number:CreateNumberPsdPageTest_004
    * @tc.name: 创建pin数字密码
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 创建pin数字密码
    */
    it('CreateNumberPsdPageTest_004', 0, createNumberPsdPageTest4);
  });
}

/**
 * 其它类型密码创建
 */
async function createNumberPsdPageTest1() {
  LogUtil.info(`${Constant.TAG} CreateNumberPsdPageTest_001 start`);
  // Step1: 点击锁屏密码
  let lockedPasswd = await driver.waitForComponent(ON.text(Constant.LOCK_SCREEN_PWD), WAIT_DELAY);
  await lockedPasswd.click();
  LogUtil.info(`${Constant.TAG} lockedPasswd clicked`);
  // 校验设置锁屏数字密码是否存在以下入口
  await driver.assertComponentExist(ON.text(Constant.SET_LOCK_SCREEN_PWD));
  await driver.assertComponentExist(ON.text(Constant.PIN_PASSWORD_MSG));
  await driver.assertComponentExist(ON.text(Constant.OTHER_PASSWORD_TYPE));
  // Step2: 点击"其他密码类型"按钮
  let otherPasswdTypeBtn = await driver.waitForComponent(ON.text(Constant.OTHER_PASSWORD_TYPE), WAIT_DELAY);
  await otherPasswdTypeBtn.click();
  LogUtil.info(`${Constant.TAG} otherPasswdTypeBtn clicked`);
  // 校验点击"其他密码类型"按钮后是否会出现以下文字
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.NUMBER_PASSWORD_TYPE));
  await driver.assertComponentExist(ON.text(Constant.MIXED_PASSWORD_TYPE));
  // Step3: 点击"自定义数据密码"按钮
  let customDigitBtn = await driver.waitForComponent(ON.text(Constant.NUMBER_PASSWORD_TYPE), WAIT_DELAY);
  await customDigitBtn.click();
  LogUtil.info(`${Constant.TAG} customDigitBtn clicked`);
  // 校验点击"自定义数据密码"按钮后是否会出现以下文字
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.NUMBER_PASSWORD_MSG));
  // Step4: 输入超过32位数字密码
  let textInput = await driver.waitForComponent(ON.type('TextInput'), WAIT_DELAY);
  await textInput.inputText(Constant.NUMBER_PASSWORD_TOO_LONG);
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.NUMBER_PASSWORD_TOO_LONG_MSG));
  LogUtil.info(`${Constant.TAG} NUMBER_PASSWORD_TOO_LONG_MSG`);
  // 清空密码
  for (let i = 0; i < 32; i++) {
    await driver.triggerKey(2055);
  }
  // Step5: 输入符合规范的8位数字密码
  await textInput.inputText(Constant.MIXED_PASSWORD_NOT_INCLUDE_LETTER);
  // Step6: 点击"继续"按钮
  let continueBtn = await driver.waitForComponent(ON.text(Constant.CONTINUE), WAIT_DELAY);
  await continueBtn.click();
  LogUtil.info(`${Constant.TAG} continueBtn clicked`);
  // Step7: 点击弹框‘继续使用’
  await driver.delayMs(COMMON_DELAY);
  let useAnywayBtn = await driver.waitForComponent(ON.text(Constant.USE_ANYWAY), WAIT_DELAY);
  await useAnywayBtn.click()
  LogUtil.info(`${Constant.TAG} USE_ANYWAY clicked`);
  // 校验点击"继续"按钮后是否会出现以下文字
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.INPUT_PASSWORD_AGAIN));
  await driver.assertComponentExist(ON.text(Constant.NUMBER_PASSWORD_TOO_SHORT_MSG));
  // Step8: 重新输入正确8位数字锁屏密码
  await textInput.inputText(Constant.MIXED_PASSWORD_NOT_INCLUDE_LETTER);
  // Step9: 点击"确定"按钮
  let confirmBtn = await driver.waitForComponent(ON.text(Constant.CONFIRM), WAIT_DELAY);
  await confirmBtn.click();
  LogUtil.info(`${Constant.TAG} confirmBtn clicked`);
  // Step10: 点击弹窗’稍后录入‘按钮
  await driver.delayMs(COMMON_DELAY);
  let enterLaterBtn = await driver.waitForComponent(ON.text(Constant.ENTER_LATER), WAIT_DELAY);
  await enterLaterBtn.click()
  // 校验点击"稍后录入"按钮后是否会出现以下文字
  await driver.assertComponentExist(ON.text(Constant.UPDATE_LOCK_SCREEN_PWD));
  await driver.assertComponentExist(ON.text(Constant.CLOSE_LOCK_SCREEN_PWD));
  LogUtil.info(`${Constant.TAG} CreateNumberPsdPageTest_001 end`);
}

/**
 * 更改密码用例
 */
async function createNumberPsdPageTest2() {
  LogUtil.info(`${Constant.TAG} CreateNumberPsdPageTest_002 start`);
  // Step1: 点击更改锁屏密码
  let changeLockedPasswd = await driver.waitForComponent(ON.text(Constant.UPDATE_LOCK_SCREEN_PWD), WAIT_DELAY);
  await changeLockedPasswd.click();
  LogUtil.info(`${Constant.TAG} lockedPasswd clicked`);
  // 校验是否存在以下入口
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.INPUT_CURRENT_LOCK_SCREEN_PWD));
  // Step2: 校验之前的锁屏密码
  let textInput = await driver.waitForComponent(ON.id('check_password_input_key'), WAIT_DELAY);
  await textInput.inputText(Constant.MIXED_PASSWORD_NOT_INCLUDE_LETTER);
  let nextStepBtn = await driver.waitForComponent(ON.text(Constant.NEXT_STEP), WAIT_DELAY);
  await nextStepBtn.click();
  // 校验设置锁屏数字密码是否存在以下入口
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.SET_NEW_LOCK_SCREEN_PWD));
  await driver.assertComponentExist(ON.text(Constant.PIN_PASSWORD_MSG));
  await driver.assertComponentExist(ON.text(Constant.OTHER_PASSWORD_TYPE));
  // Step3: 点击"其他密码类型"按钮
  let otherPasswdTypeBtn = await driver.waitForComponent(ON.text(Constant.OTHER_PASSWORD_TYPE), WAIT_DELAY);
  await otherPasswdTypeBtn.click();
  LogUtil.info(`${Constant.TAG} otherPasswdTypeBtn clicked`);
  // 校验点击"其他密码类型"按钮后是否会出现以下文字
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.NUMBER_PASSWORD_TYPE));
  await driver.assertComponentExist(ON.text(Constant.MIXED_PASSWORD_TYPE));
  // Step4: 点击"自定义数字密码"按钮
  let numberPsdBtn = await driver.waitForComponent(ON.text(Constant.NUMBER_PASSWORD_TYPE), WAIT_DELAY);
  await numberPsdBtn.click();
  LogUtil.info(`${Constant.TAG} numberPsdBtn clicked`);
  // 校验点击"自定义数字密码"按钮后是否会出现以下文字
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.NUMBER_PASSWORD_MSG));
  // Step5: 输入修改后的自定义数字密码
  let numberPsdInput = await driver.waitForComponent(ON.id('number_psd_input_key'), WAIT_DELAY);
  await numberPsdInput.inputText(Constant.NUMBER_PASSWORD_UPDATE);
  let continueBtn = await driver.waitForComponent(ON.text(Constant.CONTINUE), WAIT_DELAY);
  await continueBtn.click();
  LogUtil.info(`${Constant.TAG} continueBtn clicked`);
  // Step6: 点击弹框‘继续使用’
  await driver.delayMs(COMMON_DELAY);
  let useAnywayBtn = await driver.waitForComponent(ON.text(Constant.USE_ANYWAY), WAIT_DELAY);
  await useAnywayBtn.click()
  LogUtil.info(`${Constant.TAG} USE_ANYWAY clicked`);
  // 校验是否存在以下入口
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.INPUT_PASSWORD_AGAIN));
  // Step6: 再次输入修改后的自定义数字密码
  await numberPsdInput.inputText(Constant.NUMBER_PASSWORD_UPDATE);
  let confirmBtn = await driver.waitForComponent(ON.text(Constant.CONFIRM), WAIT_DELAY);
  await confirmBtn.click();
  LogUtil.info(`${Constant.TAG} confirmBtn clicked`);
  // 校验是否存在以下入口
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.UPDATE_LOCK_SCREEN_PWD));
  await driver.assertComponentExist(ON.text(Constant.CLOSE_LOCK_SCREEN_PWD));
  LogUtil.info(`${Constant.TAG} CreateNumberPsdPageTest_002 end`);
}

/**
 * 关闭锁屏密码
 */
async function createNumberPsdPageTest3() {
  LogUtil.info(`${Constant.TAG} CreateNumberPsdPageTest_003 start`);
  // Step1: 点击关闭锁屏密码
  let closeLockedPasswdBtn = await driver.waitForComponent(ON.text(Constant.CLOSE_LOCK_SCREEN_PWD), WAIT_DELAY);
  LogUtil.info(`${Constant.TAG} get closeLockedPasswdBtn`);
  await closeLockedPasswdBtn.click();
  LogUtil.info(`${Constant.TAG} closeLockedPasswdBtn clicked`);
  // 点击弹框"关闭"按钮
  let confirmBtn = await driver.waitForComponent(ON.text(Constant.CLOSE), WAIT_DELAY);
  await confirmBtn.click();
  LogUtil.info(`${Constant.TAG} confirmBtn clicked`);
  // 校验是否存在以下入口
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.INPUT_LOCK_SCREEN_PWD));
  // Step2: 输入锁屏密码, 点击"下一步"按钮
  let textInput = await driver.waitForComponent(ON.type('TextInput'), WAIT_DELAY);
  await textInput.inputText(Constant.NUMBER_PASSWORD_UPDATE);
  let nextStepBtn = await driver.waitForComponent(ON.text(Constant.NEXT_STEP), WAIT_DELAY);
  await nextStepBtn.click();
  // 校验是否存在以下入口
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.LOCK_SCREEN_PWD));
  LogUtil.info(`${Constant.TAG} CreateNumberPsdPageTest_003 end`);
}

/**
 * 创建pin锁屏密码用例
 */
async function createNumberPsdPageTest4() {
  LogUtil.info(`${Constant.TAG} CreateNumberPsdPageTest_004 start`);
  // Step1: 点击锁屏密码
  let lockedPasswd = await driver.waitForComponent(ON.text(Constant.LOCK_SCREEN_PWD), WAIT_DELAY);
  await lockedPasswd.click();
  LogUtil.info(`${Constant.TAG} lockedPasswd clicked`);
  // 校验设置锁屏数字密码是否存在以下入口
  await driver.assertComponentExist(ON.text(Constant.SET_LOCK_SCREEN_PWD));
  await driver.assertComponentExist(ON.text(Constant.PIN_PASSWORD_MSG));
  await driver.assertComponentExist(ON.text(Constant.OTHER_PASSWORD_TYPE));
  // Step2: 点击"其他密码类型"按钮
  let otherPasswdTypeBtn = await driver.waitForComponent(ON.text(Constant.SET_LOCK_SCREEN_PWD), WAIT_DELAY);
  await otherPasswdTypeBtn.click();
  LogUtil.info(`${Constant.TAG} CreateNumberPsdPageTest_004 end`);
}