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

import { describe, it, expect, TestType } from '@ohos/hypium';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PasswordUtil, ResourceUtil } from '@ohos/settings.common';
import { Constant } from '../../constant/Constant';
import {
  CHECK_PASSWORD_TYPE_CONTAIN_ILLEGAL_CHARACTER,
  CHECK_PASSWORD_TYPE_TOO_LONG,
  CHECK_PASSWORD_TYPE_TOO_SHORT,
  CHECK_PASSWORD_TYPE_VALID,
  PinSubType,
  SPACE_PLACE_HOLDER_STRING} from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';

export default function PasswordUtilTest() {
  describe('PasswordUtilTest', () => {

    /*
    * @tc.number: PasswordUtilTest_001
    * @tc.name: getPasswordValidStatus
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('PasswordUtilTest_001', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} PasswordUtilTest_001 start`);
      // 输入正常密码
      let result: number = await PasswordUtil.getPasswordValidStatus(Constant.PIN_TEST_PSD);
      expect(result === CHECK_PASSWORD_TYPE_VALID).assertTrue();
      result = await PasswordUtil.getPasswordValidStatus(Constant.NUMBER_PASSWORD_TOO_LONG);
      expect(result === CHECK_PASSWORD_TYPE_TOO_LONG).assertTrue();
      result = await PasswordUtil.getPasswordValidStatus(Constant.MIXED_PASSWORD_TOO_SHORT);
      expect(result === CHECK_PASSWORD_TYPE_TOO_SHORT).assertTrue();
      result = await PasswordUtil.getPasswordValidStatus(Constant.MIXED_PASSWORD_NULL);
      expect(result === CHECK_PASSWORD_TYPE_TOO_SHORT).assertTrue();
      result = await PasswordUtil.getPasswordValidStatus(Constant.PASSWORD_ILLEGAL_CHARACTER);
      expect(result === CHECK_PASSWORD_TYPE_CONTAIN_ILLEGAL_CHARACTER).assertTrue();
      LogUtil.info(`${Constant.TAG} PasswordUtilTest_001 end`);
    });

    /*
    * @tc.number: PasswordUtilTest_002
    * @tc.name: isContainIllegalCharacter
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('PasswordUtilTest_002', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} PasswordUtilTest_002 start`);
      // 输入正常密码
      let result: boolean = await PasswordUtil.isContainIllegalCharacter(Constant.MIXED_PASSWORD_NULL);
      expect(result === false).assertTrue();
      LogUtil.info(`${Constant.TAG} PasswordUtilTest_002 end`);
    });

    /*
    * @tc.number: PasswordUtilTest_003
    * @tc.name: isOnlyNumber
    * @tc.type: TestType.FUNCTION
    * @tc.desc: 判断密码是不是纯数字
    */
    it('PasswordUtilTest_003', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} PasswordUtilTest_003 start`);
      // 输入空密码
      let result: boolean = await PasswordUtil.isOnlyNumber(Constant.MIXED_PASSWORD_NULL);
      expect(result === false).assertTrue();
      LogUtil.info(`${Constant.TAG} PasswordUtilTest_003 end`);
    });

    /*
    * @tc.number: PasswordUtilTest_004
    * @tc.name: isIncludeAtLeastOneLetter
    * @tc.type: TestType.FUNCTION
    * @tc.desc: 判断密码是否至少包含一个字母
    */
    it('PasswordUtilTest_004', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} PasswordUtilTest_004 start`);
      // 输入空字符串
      let result: boolean = await PasswordUtil.isIncludeAtLeastOneLetter(Constant.MIXED_PASSWORD_NULL);
      expect(result === false).assertTrue();
      LogUtil.info(`${Constant.TAG} PasswordUtilTest_004 end`);
    });

    /*
    * @tc.number: PasswordUtilTest_005
    * @tc.name: getFirstWarningMessage
    * @tc.type: TestType.FUNCTION
    * @tc.desc: 校验密码是否合规，如果不合规，返回对应的提示文本
    */
    it('PasswordUtilTest_005', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} PasswordUtilTest_005 start`);
      try {
        // 输入太短且包含非法字符密码,校验所有规则
        let result: ResourceStr =
          await PasswordUtil.getFirstWarningMessage(Constant.PASSWORD_TOO_SHORT_ILLEGAL_CHARACTER, true);
        await expect(result !== SPACE_PLACE_HOLDER_STRING).assertTrue();
        // 输入空密码,校验所有规则
        result = await PasswordUtil.getFirstWarningMessage(Constant.MIXED_PASSWORD_NULL, true);
        await expect(result === SPACE_PLACE_HOLDER_STRING).assertTrue();
        // 输入包含非法字符密码,校验所有规则
        result = await PasswordUtil.getFirstWarningMessage(Constant.PASSWORD_ILLEGAL_CHARACTER, true);
        await expect(result !== SPACE_PLACE_HOLDER_STRING).assertTrue();
        // 输入太短字符密码,校验所有规则
        result = await PasswordUtil.getFirstWarningMessage(Constant.MIXED_PASSWORD_TOO_SHORT, true);
        await expect(result !== SPACE_PLACE_HOLDER_STRING).assertTrue();
        // 输入超长字符密码,校验所有规则
        result = await PasswordUtil.getFirstWarningMessage(Constant.NUMBER_PASSWORD_TOO_LONG, true);
        await expect(result !== SPACE_PLACE_HOLDER_STRING).assertTrue();
        // 输入正常密码,校验所有规则
        result = await PasswordUtil.getFirstWarningMessage(Constant.NUMBER_PASSWORD_UPDATE, true);
        await expect(result === SPACE_PLACE_HOLDER_STRING).assertTrue();
        // 输入正常密码,只校验字符是否合法
        result = await PasswordUtil.getFirstWarningMessage(Constant.NUMBER_PASSWORD_UPDATE, false);
        await expect(result === SPACE_PLACE_HOLDER_STRING).assertTrue();
        // 输入太长且包含非法字符密码,只校验字符是否合法
        result = await PasswordUtil.getFirstWarningMessage(Constant.PASSWORD_TOO_LONG_ILLEGAL_CHARACTER, false);
        await expect(result !== SPACE_PLACE_HOLDER_STRING).assertTrue();
        // 输入太长且包含非法字符密码,校验所有规则
        result = await PasswordUtil.getFirstWarningMessage(Constant.PASSWORD_TOO_LONG_ILLEGAL_CHARACTER, true);
        await expect(result !== SPACE_PLACE_HOLDER_STRING).assertTrue();
      } catch (e) {
        LogUtil.info(`${Constant.TAG} getFirstWarningMessage failed`);
      }
      LogUtil.info(`${Constant.TAG} PasswordUtilTest_005 end`);
    });

    /*
    * @tc.number: PasswordUtilTest_006
    * @tc.name: getConfirmWarningMessage
    * @tc.type: TestType.FUNCTION
    * @tc.desc: 根据当前剩余时间来获取应该显示的倒计时弹窗提示信息
    */
    it('PasswordUtilTest_006', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} PasswordUtilTest_006 start`);
      try {
        // 输入两次相同密码
        let result: ResourceStr =
          await PasswordUtil.getConfirmWarningMessage(Constant.MIXED_PASSWORD_NOT_INCLUDE_LETTER, Constant.MIXED_PASSWORD_NOT_INCLUDE_LETTER);
        LogUtil.info(`${Constant.TAG} getConfirmWarningMessage same passwords,result:${result}`);
        await expect(result === SPACE_PLACE_HOLDER_STRING).assertTrue();
        // 输入不同密码
        result =
          await PasswordUtil.getConfirmWarningMessage(Constant.MIXED_PASSWORD_NOT_INCLUDE_LETTER, Constant.NUMBER_PASSWORD_UPDATE);
        await expect(result !== SPACE_PLACE_HOLDER_STRING).assertTrue();
      } catch (e) {
        LogUtil.info(`${Constant.TAG} getConfirmWarningMessage failed`);
      }
      LogUtil.info(`${Constant.TAG} PasswordUtilTest_006 end`);
    });

    /*
    * @tc.number: PasswordUtilTest_007
    * @tc.name: getCountDownDialogMessage
    * @tc.type: TestType.FUNCTION
    * @tc.desc: 根据当前剩余时间来获取应该显示的倒计时弹窗提示信息
    */
    it('PasswordUtilTest_007', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} PasswordUtilTest_007 start`);
      // 无剩余时间
      let result: ResourceStr = await PasswordUtil.getCountDownDialogMessage(Constant.PASSWORD_MILLISECONDS_TIME_0);
      expect(result === SPACE_PLACE_HOLDER_STRING).assertTrue();
      // 剩余时间大于1h
      result = await PasswordUtil.getCountDownDialogMessage(Constant.PASSWORD_MILLISECONDS_TIME_2H);
      await expect(result !== SPACE_PLACE_HOLDER_STRING).assertTrue();
      LogUtil.info(`${Constant.TAG} PasswordUtilTest_007 end`);
    });

    /*
    * @tc.number: PasswordUtilTest_008
    * @tc.name: getPinSubType
    * @tc.type: TestType.FUNCTION
    * @tc.desc: 根据用户输入的密码来匹配对应的密码子类型
    */
    it('PasswordUtilTest_008', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} PasswordUtilTest_008 start`);
      // 传入空字符串
      let result: number = await PasswordUtil.getPinSubType(Constant.MIXED_PASSWORD_NULL);
      expect(result === PinSubType.PIN_MIXED).assertTrue();
      // 传入6位数字密码
      result = await PasswordUtil.getPinSubType(Constant.PIN_TEST_PSD);
      expect(result === PinSubType.PIN_SIX).assertTrue();
      // 传入大于6位数字密码
      result = await PasswordUtil.getPinSubType(Constant.MIXED_PASSWORD_NOT_INCLUDE_LETTER);
      expect(result === PinSubType.PIN_NUMBER).assertTrue();
      // 传入混合密码
      result = await PasswordUtil.getPinSubType(Constant.MIXED_PASSWORD_CHANGED);
      expect(result === PinSubType.PIN_MIXED).assertTrue();
      LogUtil.info(`${Constant.TAG} PasswordUtilTest_008 end`);
    });

    /*
    * @tc.number: PasswordUtilTest_009
    * @tc.name: getPinSubType
    * @tc.type: TestType.FUNCTION
    * @tc.desc: 判断当前输入密码类型是不是弱密码
    */
    it('PasswordUtilTest_009', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} PasswordUtilTest_009 start`);
      // 传入空字符串
      let result: boolean = await PasswordUtil.isWeakPasswords(Constant.MIXED_PASSWORD_NULL);
      expect(result === true).assertTrue();
      // 传入等差数列密码
      result = await PasswordUtil.isWeakPasswords(Constant.PIN_ISOVARIANCE_SERIES_PSD);
      expect(result).assertTrue();
      LogUtil.info(`${Constant.TAG} PasswordUtilTest_009 end`);
    });
  });
}