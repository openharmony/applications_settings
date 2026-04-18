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

import { describe, it, expect, afterAll, beforeAll} from '@ohos/hypium';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BatteryParamUtil } from '../../../../main/ets/Setting/Battery/utils/BatteryParamUtil';

const TAG: string = 'batteryParamUtilTest';

/**
 * BatteryParamUtil测试工具类
 */
export default function batteryParamUtilTest() {
  describe('batteryParamUtilTest', () => {
    beforeAll(() => {
      LogUtil.info(`${TAG} beforeAll`);
    });

    afterAll(() => {
      LogUtil.info(`${TAG} afterAll`);
    });

    it('batteryParamUtilTest_002', 0, batteryParamUtilTest_002());

    it('batteryParamUtilTest_003', 0, batteryParamUtilTest_003());
  });
}


/**
 * getAppPowerEntryFromPathInfo方法测试
 *
 * @returns 测试函数
 */
function batteryParamUtilTest_002(): Function {
  return () => {
    let result = BatteryParamUtil.getAppPowerEntryFromPathInfo();
    LogUtil.info(`${TAG} batteryParamUtilTest_002 result: ${result}`);
    expect(result === undefined).assertTrue();
  };
}

/**
 * ifUsePcBatteryPage方法测试
 *
 * @returns 测试函数
 */
function batteryParamUtilTest_003(): Function {
  return () => {
    let result: boolean = BatteryParamUtil.ifUsePcBatteryPage();
    LogUtil.info(`${TAG} batteryParamUtilTest_003 result: ${result}`);
    expect(result !== undefined).assertTrue();
  };
}