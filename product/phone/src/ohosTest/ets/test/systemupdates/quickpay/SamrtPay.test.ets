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

import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { beforeAll, describe, it, afterAll } from '@ohos/hypium';
import { Driver, ON } from '@ohos.UiTest';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BusinessError } from '@ohos.base';
import { Constant } from '../../constant/Constant';
import { COMMON_DELAY, WAIT_DELAY } from '../../types';

const TAG: string = 'SmartPayTest';
const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function SmartPayTest() {
  describe('SmartPayTest',  () => {
    beforeAll(beforeAllTest);

    afterAll(afterAllTest);

    /*
    * @tc.number: SmartPayTest_001
    * @tc.name: 智感支付页面跳转验证（需确保智感支付App已安装最新版本）
    * @tc.type: 0 || TestType.FUNCTION || Level.LEVEL0
    * @tc.desc: 点击设置-系统和更新-智感支付tab项跳转到智感支付页面
    *
     */
    it('SmartPayTest_001', 0, smartPayTest);

    it('SmartPayTest_002', 0, smartPaySwitchTest);

    it('SmartPayTest_003', 0, smartPayReturnTest);
  });
}

async function beforeAllTest() {
  let dr: Driver = await Driver.create();
  //启动设置
  try {
    await DELEGATOR.startAbility({
      'bundleName': Constant.SETTINGS_BUNDLE_NAME,
      'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
      'uri': 'system_and_updates',
    }).then(() => {
      LogUtil.info(`${TAG} com.ohos.settings.MainAbility start success`);
    })
  } catch(exception) {
    LogUtil.error(`Failed to startAbility. Code: ${(exception as BusinessError).code}, Message: ${(exception as BusinessError).message}`);
  }
}

async function smartPayTest() {
  LogUtil.info(`${TAG} SmartPayTest_001 start`)
  let dr: Driver = await Driver.create();
  await dr?.delayMs(COMMON_DELAY);
  //找到二级菜单里的“智感支付”的菜单，并点击
  let systemDataCloneTab = await dr?.waitForComponent(ON.text(Constant.SMART_PAY), WAIT_DELAY);
  //触发点击事件
  await systemDataCloneTab?.click();
  LogUtil.info(`${TAG} SmartPayTab clicked`);
}

async function smartPaySwitchTest() {
  LogUtil.info(`${TAG} SmartPayTest_002 start`)
  let dr: Driver = await Driver.create();
  await dr?.delayMs(COMMON_DELAY);
  //找到智感支付设置页面的开关，并点击
  let SmartPaySwitch = await dr?.waitForComponent(ON.type('Toggle'), WAIT_DELAY);
  //触发点击事件
  await SmartPaySwitch?.click();
  LogUtil.info(`${TAG} SmartPaySwitch clicked`);
}

async function smartPayReturnTest() {
  LogUtil.info(`${TAG} SmartPayTest_003 start`)
  let dr: Driver = await Driver.create();
  await dr?.delayMs(COMMON_DELAY);
  //找到智感支付设置页面的返回图标，并点击
  let SmartPayReturn = await dr?.waitForComponent(ON.type('Image'), WAIT_DELAY);
  //触发点击事件
  await SmartPayReturn?.click();
  LogUtil.info(`${TAG} SmartPayReturn clicked`);
}

async function afterAllTest() {
  let dr: Driver = await Driver.create();
  await dr.delayMs(COMMON_DELAY);
  await dr.pressHome();
  await dr.delayMs(COMMON_DELAY);
}