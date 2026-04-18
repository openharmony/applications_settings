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

import { describe, it, beforeAll, afterAll, expect } from '@ohos/hypium';
import { Driver, ON } from '@ohos.UiTest';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { PasswordUtil } from '@ohos/settings.common';
import { BusinessError } from '@ohos.base';
import { COMMON_DELAY, WAIT_DELAY } from '../types';
import { Constant } from '../constant/Constant';
import window from '@ohos.window';
import { FingerprintManager } from '@ohos/settings.common/src/main/ets/data/index';
import { FingerprintInfo } from '@ohos/settings.common/src/main/ets/data/types';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const driver: Driver = Driver.create();

export default function fingerprintTest() {
  describe('fingerprintTest', () => {
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

    /*
     * @tc.number:FingerprintTest_008
     * @tc.name: 查询指纹数据接口
     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
     * @tc.desc: 查询指纹数据接口
     */
    it('FingerprintTest_008', 0, fingerprintTest8);
  })
}

/**
 * 进入指纹页面用例
 */
async function fingerprintTest1() {
  LogUtil.info(`${Constant.TAG} FingerprintTest_001 start`);
  // 校验页面是否存在“指纹”入口
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT));
  // Step1: 点击"指纹“
  let fingerprintPasswd = await driver.waitForComponent(ON.text(Constant.FINGERPRINT), WAIT_DELAY);
  await fingerprintPasswd.click();
  LogUtil.info(`${Constant.TAG} lockedPasswd clicked`);
  // 校验设置锁屏数字密码是否存在以下入口
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.SET_LOCK_SCREEN_PWD));
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT_PASSWORD_MSG));
  await driver.assertComponentExist(ON.text(Constant.OTHER_PASSWORD_TYPE));
  // Step2: 输入6位数字锁屏密码
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
  LogUtil.info(`${Constant.TAG} password inputed`);
  // Step5: 校验指纹界面
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT));
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT_USED_FOR));
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT_UNLOCK));
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT_NOTE_TITLE));
  await driver.assertComponentExist(ON.text(Constant.ADD_FINGERPRINT));
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT_NOTE_1));
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT_NOTE_2));
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT_NOTE_3));
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT_NOTE_4));
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT_NOTE_5));
  // Step6: 点击返回图标返回
  await driver.delayMs(COMMON_DELAY);
  let backBtn = await driver.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
  await backBtn.click()
  // 校验是否存在以下入口
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.BIOMETRICS));
  await driver.assertComponentExist(ON.text(Constant.UPDATE_LOCK_SCREEN_PWD));
  await driver.assertComponentExist(ON.text(Constant.CLOSE_LOCK_SCREEN_PWD));
  LogUtil.info(`${Constant.TAG} FingerprintTest_001 end`);
}

/**
 * 新建指纹用例
 */
async function fingerprintTest2() {
  LogUtil.info(`${Constant.TAG} FingerprintTest_002 start`);
  // 校验页面是否存在“指纹”入口
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT));
  // Step1: 点击"指纹“
  let fingerprintPasswd = await driver.waitForComponent(ON.text(Constant.FINGERPRINT), WAIT_DELAY);
  await fingerprintPasswd.click();
  LogUtil.info(`${Constant.TAG} fingerprintPasswd clicked`);
  // 校验设置锁屏数字密码是否存在以下入口
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.INPUT_LOCK_SCREEN_PWD));
  // Step2: 输入锁屏密码
  for (let i = 0; i < 6; i++) {
    await driver.triggerKey(2000);
  }
  await driver.delayMs(COMMON_DELAY);
  // Step3: 点击‘新建指纹’
  let addFingerprintBtn = await driver.waitForComponent(ON.text(Constant.ADD_FINGERPRINT), WAIT_DELAY);
  await addFingerprintBtn.click();
  await driver.delayMs(COMMON_DELAY);
  LogUtil.info(`${Constant.TAG} addFingerprintBtn clicked`);
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT_INTRO_SUMMARY_01));
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT_NOTICE_MESSAGE_INFO));
  // Step4: 点击"开始录入"
  let startAddFingerprintBtn = await driver.waitForComponent(ON.text(Constant.FINGERPRINT_INNER_SCREEN_BTN), WAIT_DELAY);
  await startAddFingerprintBtn.click()
  LogUtil.info(`${Constant.TAG} startAddFingerprintBtn clicked`);
  // Step5: 校验弹窗提示内容，点击弹窗按钮“知道了”
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT_INNER_SCREEN_NOTE));
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT_COVER_MESSAGE));
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT_NO_PROMPT));
  let ConfirmedBtn = await driver.waitForComponent(ON.text(Constant.FINGERPRINT_CONFIRMED_BTN), WAIT_DELAY);
  await ConfirmedBtn.click()
  LogUtil.info(`${Constant.TAG} ConfirmedBtn clicked`);
  // Step6: 校验新建指纹页面提示
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT_SCREEN_ENROLL_PLACE));
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT_SCREEN_ENROLL_PLACE_SUMMARY_01));
  // Step7: 返回指纹页面
  await driver.pressBack();
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT_UNLOCK));
  await driver.pressBack();
  await driver.delayMs(COMMON_DELAY);
  // 校验是否存在以下入口
  await driver.assertComponentExist(ON.text(Constant.BIOMETRICS));
  await driver.assertComponentExist(ON.text(Constant.UPDATE_LOCK_SCREEN_PWD));
  await driver.assertComponentExist(ON.text(Constant.CLOSE_LOCK_SCREEN_PWD));
  LogUtil.info(`${Constant.TAG} FingerprintTest_002 end`);
}

/**
 * 关闭锁屏密码用例
 */
async function fingerprintTest3() {
  LogUtil.info(`${Constant.TAG} FingerprintTest_003 start`);
  // Step1: 点击关闭锁屏密码
  let closeLockedPasswdBtn = await driver.waitForComponent(ON.text(Constant.CLOSE_LOCK_SCREEN_PWD), WAIT_DELAY);
  await closeLockedPasswdBtn.click();
  LogUtil.info(`${Constant.TAG} closeLockedPasswdBtn clicked`);
  // 点击弹框"关闭"按钮
  await driver.delayMs(COMMON_DELAY);
  let confirmBtn = await driver.waitForComponent(ON.text(Constant.CLOSE), WAIT_DELAY);
  await confirmBtn.click();
  LogUtil.info(`${Constant.TAG} confirmBtn clicked`);
  // 校验是否存在以下入口
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.INPUT_LOCK_SCREEN_PWD));
  LogUtil.info(`${Constant.TAG} INPUT_LOCK_SCREEN_PWD page`);
  // Step2: 输入正确锁屏密码
  for (let i = 0; i < 6; i++) {
    await driver.triggerKey(2000);
  }
  // 校验是否存在以下入口
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.LOCK_SCREEN_PWD));
  LogUtil.info(`${Constant.TAG} FingerprintTest_003 end`);
}

/**
 * 新建指纹页面返回到指纹主页
 */
async function fingerprintTest4() {
  LogUtil.info(`${Constant.TAG} FingerprintTest_004 start`);
  // 校验页面是否存在“指纹”入口
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT));
  // Step1: 点击"指纹“
  let fingerprintPasswd = await driver.waitForComponent(ON.text(Constant.FINGERPRINT), WAIT_DELAY);
  await fingerprintPasswd.click();
  LogUtil.info(`${Constant.TAG} lockedPasswd clicked`);
  // 校验设置锁屏数字密码是否存在以下入口
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.SET_LOCK_SCREEN_PWD));
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT_PASSWORD_MSG));
  await driver.assertComponentExist(ON.text(Constant.OTHER_PASSWORD_TYPE));
  await driver.delayMs(COMMON_DELAY);
  await driver.pressBack();
  // 校验是否存在以下入口
  await driver.delayMs(COMMON_DELAY);
  await driver.pressBack();
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT));
  LogUtil.info(`${Constant.TAG} FingerprintTest_004 end`);
}

/**
 * 生物识别与密码页面是否有指纹组件
 */
async function fingerprintTest5() {
  LogUtil.info(`${Constant.TAG} FingerprintTest_005 start`);
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT));
  // Step1: 点击"指纹“
  let fingerprintPasswd = await driver.waitForComponent(ON.text(Constant.FINGERPRINT), WAIT_DELAY);
  await fingerprintPasswd.click();
  LogUtil.info(`${Constant.TAG} FingerprintTest_005 end`);
}

/**
 * 新建指纹页面返回用例
 */
async function fingerprintTest6() {
  LogUtil.info(`${Constant.TAG} FingerprintTest_006 start`);
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT));
  // Step1: 点击"指纹“
  let fingerprintPasswd = await driver.waitForComponent(ON.text(Constant.FINGERPRINT), WAIT_DELAY);
  await fingerprintPasswd.click();
  // Step2: 点击‘新建指纹’
  let addFingerprintBtn = await driver.waitForComponent(ON.text(Constant.ADD_FINGERPRINT), WAIT_DELAY);
  await addFingerprintBtn.click();
  await driver.delayMs(COMMON_DELAY);
  // Step3: 判断‘密码保险箱’功能是否存在
  let passwordVault = await driver.assertComponentExist(ON.text(Constant.FINGERPRINT_PASSWORD_VAULT));
  await driver.pressBack();
  LogUtil.info(`${Constant.TAG} FingerprintTest_006 end`);
}

/**
 * 新建指纹页面返回用例
 */
async function fingerprintTest7() {
  LogUtil.info(`${Constant.TAG} FingerprintTest_007 start`);
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT));
  // Step1: 点击"指纹“
  let fingerprintPasswd = await driver.waitForComponent(ON.text(Constant.FINGERPRINT), WAIT_DELAY);
  await fingerprintPasswd.click();
  // Step2: 设置当前页面是为隐私页面
  let windowStage: window.WindowStage = AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage;
  PasswordUtil.setWindowPrivacyMode(windowStage, true);
  LogUtil.info(`${Constant.TAG} FingerprintTest_007 end`);
}

/**
 * 指纹数据查询接口
 */
async function fingerprintTest8() {
  LogUtil.info(`${Constant.TAG} FingerprintTest_008 start`);
  await driver.delayMs(COMMON_DELAY);
  await driver.assertComponentExist(ON.text(Constant.FINGERPRINT));
  // Step1: 查询"指纹“数据
  let fgArray: FingerprintInfo[] = await FingerprintManager.getAllFingerprints();
  expect(fgArray.length >= 0).assertTrue();
  LogUtil.info(`${Constant.TAG} FingerprintTest_008 end`);
}