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

import { Driver, ON } from '@ohos.UiTest';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { afterAll, beforeAll, describe, expect, it } from '@ohos/hypium';
import { COMMON_DELAY } from '../../types';
import { Constant } from '../../constant/Constant';
import { KeyCode } from '@kit.InputKit';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function CreateLocalUserTest() {
  describe('createLocalUserTest', () => {
    let dr: Driver | null = null;
    beforeAll(async () => {
      try {
        await DELEGATOR.startAbility({
          'bundleName': Constant.SETTINGS_BUNDLE_NAME,
          'abilityName': Constant.OOBE_TEST_ABILITY_NAME,
        }).then(() => {
          LogUtil.info(`${Constant.TAG} com.ohos.settings.OobeLocalUserTestAbility start success`);
        });
      } catch (exception) {
        LogUtil.error(`Failed to startAbility. Code: ${(exception as BusinessError).code},
        message: ${(exception as BusinessError).message}`);
      }
      LogUtil.info(`${Constant.TAG} beforeAll end`);
      dr = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
    });

    afterAll(async () => {
      // 定义Driver类
      let dr = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      LogUtil.info(`${Constant.TAG} afterAll end`);
    });

    /*
    * @tc.number:createLocalUserUITest_001
    * @tc.name: 测试用户名超长
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: oobe创建本地用户，用户名不得超过255
    */
    it('createLocalUserUITest_001', 0, async () => {
      LogUtil.info(`createLocalUserUITest_001 start`);
      dr = await Driver.create();
      try {
        let nickName = await dr.findComponent(ON.id(Constant.OOBE_NICK_NAME_ID));
        await nickName.inputText('qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq' +
          'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' +
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' +
          'qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq');
        await dr.delayMs(COMMON_DELAY);
        await dr.assertComponentExist(ON.id(Constant.OOBE_NICK_NAME_WARN_ID));
        let nickNameWarn = await dr.findComponent(ON.id(Constant.OOBE_NICK_NAME_WARN_ID))
        await nickNameWarn.getText().then((txt) => {
          expect(txt).assertEqual('输入已达上限');
        });
        await dr.delayMs(COMMON_DELAY);
        await nickName.clearText();
      } catch {
        LogUtil.info(`${Constant.TAG} createLocalUserUITest_001 failed.`);
      }
    });

    /*
    * @tc.number:createLocalUserUITest_002
    * @tc.name: 测试帐号超长
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: oobe创建本地用户，帐号不得超过255
    */
    it('createLocalUserUITest_002', 0, async () => {
      LogUtil.info(`createLocalUserUITest_002 start`);
      dr = await Driver.create();
      try {
        let accountName = await dr.findComponent(ON.id(Constant.OOBE_ACCOUNT_NAME_ID));
        await accountName.inputText('qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq' +
          'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' +
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' +
          'qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq');
        await dr.delayMs(COMMON_DELAY);
        await dr.assertComponentExist(ON.id(Constant.OOBE_ACCOUNT_NAME_WARN_ID));
        let accountNameWarn = await dr.findComponent(ON.id(Constant.OOBE_ACCOUNT_NAME_WARN_ID));
        await accountNameWarn.getText().then((txt) => {
          expect(txt).assertEqual('输入已达上限');
        });
        await dr.delayMs(COMMON_DELAY);
        await accountName.clearText();
      } catch {
        LogUtil.info(`${Constant.TAG} createLocalUserUITest_002 failed.`);
      }
    });

    /*
    * @tc.number:createLocalUserUITest_003
    * @tc.name: 测试帐号非法
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: oobe创建本地用户，帐号不得出现特殊字符 < > | : " * ? / \\ 以及独立出现 . 和 ..
    */
    it('createLocalUserUITest_003', 0, async () => {
      LogUtil.info(`createLocalUserUITest_003 start`);
      dr = await Driver.create();
      try {
        let accountName = await dr.findComponent(ON.id(Constant.OOBE_ACCOUNT_NAME_ID));
        await accountName.inputText('qq//\\\\');
        await dr.delayMs(COMMON_DELAY);
        let accountNameWarn = await dr.findComponent(ON.id(Constant.OOBE_ACCOUNT_NAME_WARN_ID));
        await accountNameWarn.getText().then((txt) => {
          expect(txt).assertEqual('不允许出现特殊字符 < > | : " * ? / \\ 以及独立出现 . 和 ..');
        });
        await dr.delayMs(COMMON_DELAY);
        await accountName.clearText();
      } catch {
        LogUtil.info(`${Constant.TAG} createLocalUserUITest_003 failed.`);
      }
    });

    /*
    * @tc.number:createLocalUserUITest_004
    * @tc.name: 测试根据用户名自动带出帐号
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: oobe创建本地用户，输入用户名后，自动带出帐号
    */
    it('createLocalUserUITest_004', 0, async () => {
      LogUtil.info(`createLocalUserUITest_004 start`);
      dr = await Driver.create();
      try {
        let nickName = await dr.findComponent(ON.id(Constant.OOBE_NICK_NAME_ID));
        let accountName = await dr.findComponent(ON.id(Constant.OOBE_ACCOUNT_NAME_ID));
        await nickName.inputText('test');
        await dr.delayMs(COMMON_DELAY);
        await accountName.click();
        await dr.delayMs(COMMON_DELAY);
        await accountName.getText().then((txt) => {
          expect(txt).assertEqual('test');
        })
        await accountName.clearText();
        await nickName.clearText();
      } catch {
        LogUtil.info(`${Constant.TAG} createLocalUserUITest_004 failed.`);
      }
    });

    /*
    * @tc.number:createLocalUserUITest_005
    * @tc.name: 测试锁屏密码长度不足
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: oobe创建本地用户，锁屏密码不得少于6位
    */
    it('createLocalUserUITest_005', 0, async () => {
      LogUtil.info(`createLocalUserUITest_005 start`);
      dr = await Driver.create();
      try {
        let nickName = await dr.findComponent(ON.id(Constant.OOBE_NICK_NAME_ID));
        let password = await dr.findComponent(ON.id(Constant.OOBE_PASSWORD_ID));
        await password.inputText('11111');
        await dr.delayMs(COMMON_DELAY);
        await nickName.click();
        await dr.delayMs(COMMON_DELAY);
        let passwordWarn = await dr.findComponent(ON.id(Constant.OOBE_PASSWORD_WARN_ID));
        await passwordWarn.getText().then((txt) => {
          expect(txt).assertEqual('密码必须大于 5 个字符');
        });
        await dr.delayMs(COMMON_DELAY);
        await password.clearText();
      } catch {
        LogUtil.info(`${Constant.TAG} createLocalUserUITest_005 failed.`);
      }
    });

    /*
    * @tc.number:createLocalUserUITest_006
    * @tc.name: 校验测试锁屏密码
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: oobe创建本地用户，锁屏密码与确认锁屏密码有一个为空时，先提示密码为空
    */
    it('createLocalUserUITest_006', 0, async () => {
      LogUtil.info(`createLocalUserUITest_006 start`);
      dr = await Driver.create();
      try {
        let nickName = await dr.findComponent(ON.id(Constant.OOBE_NICK_NAME_ID));
        let confirmPassword = await dr.findComponent(ON.id(Constant.OOBE_CONFIRM_PASSWORD_ID));
        await confirmPassword.inputText('11');
        await dr.delayMs(COMMON_DELAY);
        await nickName.click();
        await dr.delayMs(COMMON_DELAY);
        let confirmPasswordWarn = await dr.findComponent(ON.id(Constant.OOBE_CONFIRM_PASSWORD_WARN_ID));
        await confirmPasswordWarn.getText().then((txt) => {
          expect(txt).assertEqual('密码不一致');
        })
        await dr.delayMs(COMMON_DELAY);
        await confirmPassword.clearText();
      } catch {
        LogUtil.info(`${Constant.TAG} createLocalUserUITest_006 failed.`);
      }
    });

    /*
    * @tc.number:createLocalUserUITest_007
    * @tc.name: 测试锁屏密码为空
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: oobe创建本地用户，输入锁屏密码后，必须输入确认锁屏密码
    */
    it('createLocalUserUITest_007', 0, async () => {
      LogUtil.info(`createLocalUserUITest_007 start`);
      dr = await Driver.create();
      try {
        let nickName = await dr.findComponent(ON.id(Constant.OOBE_NICK_NAME_ID));
        let password = await dr.findComponent(ON.id(Constant.OOBE_PASSWORD_ID));
        let confirmPassword = await dr.findComponent(ON.id(Constant.OOBE_CONFIRM_PASSWORD_ID));
        await password.inputText('111111');
        await dr.delayMs(COMMON_DELAY);
        await confirmPassword.click();
        await dr.delayMs(COMMON_DELAY);
        await nickName.inputText('111');
        await dr.delayMs(COMMON_DELAY);
        let confirmPasswordWarn = await dr.findComponent(ON.id(Constant.OOBE_CONFIRM_PASSWORD_WARN_ID));
        await confirmPasswordWarn.getText().then((txt) => {
          expect(txt).assertEqual('密码不一致');
        });
        await dr.delayMs(COMMON_DELAY);
        await password.clearText();
      } catch {
        LogUtil.info(`${Constant.TAG} createLocalUserUITest_007 failed.`);
      }
    });

    /*
    * @tc.number:createLocalUserUITest_008
    * @tc.name: 测试锁屏密码不一致
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: oobe创建本地用户，锁屏密码与确认锁屏密码要一致
    */
    it('createLocalUserUITest_008', 0, async () => {
      LogUtil.info(`createLocalUserUITest_008 start`);
      dr = await Driver.create();
      try {
        let nickName = await dr.findComponent(ON.id(Constant.OOBE_NICK_NAME_ID));
        let password = await dr.findComponent(ON.id(Constant.OOBE_PASSWORD_ID));
        await password.inputText('111111');
        await dr.delayMs(COMMON_DELAY);
        await nickName.click();
        let confirmPassword = await dr.findComponent(ON.id(Constant.OOBE_CONFIRM_PASSWORD_ID));
        await confirmPassword.inputText('222222');
        await dr.delayMs(COMMON_DELAY);
        await dr.triggerKey(KeyCode.KEYCODE_ENTER);
        await dr.delayMs(COMMON_DELAY);
        let confirmPasswordWarn = await dr.findComponent(ON.id(Constant.OOBE_CONFIRM_PASSWORD_WARN_ID));
        await confirmPasswordWarn.getText().then((txt) => {
          expect(txt).assertEqual('密码不一致');
        });
        await dr.delayMs(COMMON_DELAY);
        await password.clearText();
        await confirmPassword.clearText();
      } catch {
        LogUtil.info(`${Constant.TAG} createLocalUserUITest_008 failed.`);
      }
    });

    /*
    * @tc.number:createLocalUserUITest_009
    * @tc.name: 密码为空创建用户时弹窗
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: oobe创建本地用户，密码为空时，进行弹窗提示
    */
    it('createLocalUserUITest_009', 0, async () => {
      LogUtil.info(`createLocalUserUITest_009 start`);
      dr = await Driver.create();
      try {
        let nickName = await dr.findComponent(ON.id(Constant.OOBE_NICK_NAME_ID));
        await nickName.inputText('qqq');
        await dr.delayMs(COMMON_DELAY);
        await dr.triggerKey(KeyCode.KEYCODE_ENTER);
        await dr.delayMs(COMMON_DELAY);
        await dr.assertComponentExist(ON.text('确定创建用户？'));
        let cancelButton = await dr.findComponent(ON.id(Constant.OOBE_CANCEL_BUTTON_ID));
        await dr.delayMs(COMMON_DELAY);
        await cancelButton.click();
        await dr.delayMs(COMMON_DELAY);
        let continueButton = await dr.findComponent(ON.id(Constant.OOBE_CONTINUE_BUTTON_ID));
        await dr.delayMs(COMMON_DELAY);
        await continueButton.click();
        let okButton = await dr.findComponent(ON.id(Constant.OOBE_OK_BUTTON_ID));
        await dr.delayMs(COMMON_DELAY);
        okButton.click();
      } catch {
        LogUtil.info(`${Constant.TAG} createLocalUserUITest_009 failed.`);
      }
    });

    /*
    * @tc.number:createLocalUserUITest_010
    * @tc.name: 密码为空创建用户时弹窗
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: oobe创建本地用户，第一次密码校验不一致后，后续锁屏密码动态校验
    */
    it('createLocalUserUITest_010', 0, async () => {
      LogUtil.info(`createLocalUserUITest_010 start`);
      dr = await Driver.create();
      try {
        let nickName = await dr.findComponent(ON.id(Constant.OOBE_NICK_NAME_ID));
        let password = await dr.findComponent(ON.id(Constant.OOBE_PASSWORD_ID));
        let confirmPassword = await dr.findComponent(ON.id(Constant.OOBE_CONFIRM_PASSWORD_ID));
        await confirmPassword.inputText('111');
        await dr.delayMs(COMMON_DELAY);
        await nickName.inputText('qqq');
        await dr.delayMs(COMMON_DELAY);
        await password.inputText('1111111');
        await dr.delayMs(COMMON_DELAY);
        await dr.triggerKey(KeyCode.KEYCODE_ENTER);
        await nickName.click();
        confirmPassword = await dr.findComponent(ON.id(Constant.OOBE_CONFIRM_PASSWORD_ID));
        await confirmPassword.inputText('1111111');
        await confirmPassword.clearText();
        await password.clearText();
      } catch {
        LogUtil.info(`${Constant.TAG} createLocalUserUITest_010 failed.`);
      }
    });

    /*
    * @tc.number:createLocalUserUITest_011
    * @tc.name: 密码为空创建用户时弹窗
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: oobe创建本地用户，密码为空时，进行弹窗提示
    */
    it('createLocalUserUITest_011', 0, async () => {
      LogUtil.info(`createLocalUserUITest_011 start`);
      dr = await Driver.create();
      try {
        let nickName = await dr.findComponent(ON.id(Constant.OOBE_NICK_NAME_ID));
        let password = await dr.findComponent(ON.id(Constant.OOBE_PASSWORD_ID));
        await nickName.inputText('qqq');
        await dr.delayMs(COMMON_DELAY);
        await password.inputText('111111');
        await dr.delayMs(COMMON_DELAY);
        await nickName.click();
        let confirmPassword = await dr.findComponent(ON.id(Constant.OOBE_CONFIRM_PASSWORD_ID));
        await confirmPassword.inputText('111111');
        await dr.delayMs(COMMON_DELAY);
        await dr.triggerKey(KeyCode.KEYCODE_ENTER);
        await dr.delayMs(COMMON_DELAY);
      } catch {
        LogUtil.info(`${Constant.TAG} createLocalUserUITest_011 failed.`);
      }
    });
  });
}
