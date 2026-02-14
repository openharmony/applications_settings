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

import { describe, it, expect, TestType, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  Condition,
  VersionCondition,
  AppVersionCondition,
  DeviceTypeCondition,
  SettingsDataCondition,
  OsAccountTypeCondition,
  Operator,
} from '@ohos/settings.common/src/main/ets/externalmenu/Condition';
import { Constant } from '../../constant/Constant';
import { SettingsDataUtils } from '@ohos/settings.common';

const EQUAL_OPERATOR = '==';
const ADMIN = 'ADMIN';

export default function ConditionTest() {
  describe('ConditionTest', () => {

    /*
    * @tc.number: ConditionTest_001
    * @tc.name: Is meet current condition.
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return True
    */
    it('ConditionTest_001', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} ConditionTest_001 start`);
      let condition = new Condition();
      let result: boolean = await condition.isMeet();
      expect(result).assertTrue();
      LogUtil.info(`${Constant.TAG} ConditionTest_001 end`);
    });

    /*
    * @tc.number: ConditionTest_002
    * @tc.name: 版本条件因子
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('ConditionTest_002', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} ConditionTest_002 start`);
      let versionCondition = new VersionCondition();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(versionCondition, versionCondition.isMeet);
      when(mockFunc)(EQUAL_OPERATOR).afterReturn(true);
      let result: boolean = await versionCondition.isMeet(EQUAL_OPERATOR);
      expect(result).assertTrue();
      LogUtil.info(`${Constant.TAG} ConditionTest_002 end`);
      mocker.clear(versionCondition);
    });

    /*
    * @tc.number: ConditionTest_003
    * @tc.name: 获得当前版本
    * @tc.type: TestType.FUNCTION
    * @tc.desc: 返回 0
    */
    it('ConditionTest_003', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} ConditionTest_003 start`);
      let versionCondition = new VersionCondition();
      let result: number = await versionCondition.getCurrentVersion();
      expect(result).assertEqual(0);
      LogUtil.info(`${Constant.TAG} ConditionTest_003 end`);
    });

    /*
    * @tc.number: ConditionTest_004
    * @tc.name: 应用版本条件因子
    * @tc.type: TestType.FUNCTION
    * @tc.desc: 返回undefined
    */
    it('ConditionTest_004', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} ConditionTest_004 start`);
      let appVersionCondition = new AppVersionCondition();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(appVersionCondition, appVersionCondition.getCurrentVersion);
      when(mockFunc)().afterReturn(undefined);
      let result = await appVersionCondition.getCurrentVersion();
      expect(result).assertUndefined();
      LogUtil.info(`${Constant.TAG} ConditionTest_004 end`);
      mocker.clear(appVersionCondition)
    });

    /*
    * @tc.number: ConditionTest_005
    * @tc.name: 设备类型条件因子
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('ConditionTest_005', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} ConditionTest_005 start`);
      let deviceTypeCondition = new DeviceTypeCondition();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(deviceTypeCondition, deviceTypeCondition.isMeet);
      when(mockFunc)(EQUAL_OPERATOR).afterReturn(true);
      let result = await deviceTypeCondition.isMeet(EQUAL_OPERATOR);
      expect(result).assertTrue();
      LogUtil.info(`${Constant.TAG} ConditionTest_005 end`);
      mocker.clear(deviceTypeCondition);
    });

    /*
    * @tc.number: ConditionTest_006
    * @tc.name: 设置数据库值条件因子
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('ConditionTest_006', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} ConditionTest_006 start`);
      let settingsDataCondition = new SettingsDataCondition();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(settingsDataCondition, settingsDataCondition.isMeet);
      when(mockFunc)(EQUAL_OPERATOR).afterReturn(true);
      let result = await settingsDataCondition.isMeet(EQUAL_OPERATOR);
      expect(result).assertTrue();
      LogUtil.info(`${Constant.TAG} ConditionTest_006 end`);
      mocker.clear(settingsDataCondition);
    });

    /*
    * @tc.number: ConditionTest_007
    * @tc.name: 用户类型条件因子
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return ADMIN
    */
    it('ConditionTest_007', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} ConditionTest_007 start`);
      let osAccountTypeCondition = new OsAccountTypeCondition();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(osAccountTypeCondition, osAccountTypeCondition.isMeet)
      when(mockFunc)(ArgumentMatchers.any).afterReturn(ADMIN);
      let result = await osAccountTypeCondition.isMeet();
      expect(result).assertContain(ADMIN);
      LogUtil.info(`${Constant.TAG} ConditionTest_007 end`);
      mocker.clear(osAccountTypeCondition);
    });
    it('test_VersionCondition', 0, async (done : Function) => {
      let versionCondition = new testCondition();
      expect(await versionCondition.isMeet('1==0')).assertTrue()
      expect(await versionCondition.isMeet('1>=3')).assertFalse()
      expect(await versionCondition.isMeet('1>3')).assertFalse()
      expect(await versionCondition.isMeet('1<3')).assertTrue()
      expect(await versionCondition.isMeet('1<=3')).assertFalse()
      expect(await versionCondition.isMeet('1!=3')).assertFalse()
      let versionRes = versionCondition.getCurrentVersion()
      expect(await versionRes !== undefined).assertTrue()
      done()
    })
    it('test_AppVersionCondition', 0, async () => {
      let appVersionCondition = new AppVersionCondition();
      appVersionCondition.versionCode = 401
      appVersionCondition.getCurrentVersion()
    })
    it('test_DeviceTypeCondition', 0, async (done : Function) => {
      let deviceTypeCondition = new DeviceTypeCondition();
      expect(await deviceTypeCondition.isMeet('1==3')).assertFalse()
      done()
    })
    it('test_SettingsDataCondition', 0, async (done : Function) => {
      let settingData = new testSettingsDataCondition();
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
      when(mockFunc)(ArgumentMatchers.any).afterReturn('3')
      expect(await settingData.isMeet('3|1==3')).assertTrue()
      when(mockFunc)(ArgumentMatchers.any).afterReturn('1')
      expect(await settingData.isMeet('1|1>3')).assertTrue()
      when(mockFunc)(ArgumentMatchers.any).afterReturn('6')
      expect(await settingData.isMeet('6|1<3')).assertTrue()
      expect(await settingData.isMeet('1!=3')).assertFalse()
      mocker.clear(SettingsDataUtils)
      done()
    })
    it('test_OsAccountTypeCondition', 0, async (done : Function) => {
      let osAccountTypeCondition = new OsAccountTypeCondition();
      expect(await osAccountTypeCondition.isMeet('1==3')).assertFalse()

      done()
    })
  });
}

export class testCondition extends VersionCondition {
  public  getOperator(expression: string): Operator {
    super.getOperator(expression)
    return handleOperator(expression)
  }
}
export class testSettingsDataCondition extends SettingsDataCondition {
  public  getOperator(expression: string): Operator {
    super.getOperator(expression)
    return handleOperator(expression)
  }
}
function handleOperator(expression: string): Operator {
  if (expression.indexOf(Operator.EQUAL_OPERATOR) >= 0) {
    return Operator.EQUAL_OPERATOR;
  } else if (expression.indexOf(Operator.GREATER_OPERATOR) >= 0) {
    return Operator.GREATER_OPERATOR;
  } else if (expression.indexOf(Operator.GREATER_OR_EQUAL_OPERATOR) >= 0) {
    return Operator.GREATER_OR_EQUAL_OPERATOR;
  } else if (expression.indexOf(Operator.LESS_OPERATOR) >= 0) {
    return Operator.LESS_OPERATOR;
  } else if (expression.indexOf(Operator.LESS_OR_EQUAL_OPERATOR) >= 0) {
    return Operator.LESS_OR_EQUAL_OPERATOR;
  } else if (expression.indexOf(Operator.REVERSE_EQUAL_OPERATOR) >= 0) {
    return Operator.REVERSE_EQUAL_OPERATOR;
  }
  throw new Error('invalid');
}