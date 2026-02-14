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
import { Driver, ON } from '@ohos.UiTest';
import { afterAll, beforeAll, describe, it } from '@ohos/hypium';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { COMMON_DELAY, WAIT_DELAY } from '../types';

const TAG: string = 'BatteryPageTest';
const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function BatteryPageTest() {
  describe('BatteryPageTest', () => {
    let dr: Driver = Driver.create();
    beforeAll(async () => {
      try {
        await DELEGATOR.startAbility({
          'bundleName': 'com.ohos.settings',
          'abilityName': 'com.ohos.settings.MainAbility',
          'uri': NavEntryKey.BATTERY_ENTRY,
        }).then(() => {
          LogUtil.info(`${TAG} com.ohos.settings.MainAbility start success`);
        });
      } catch (err) {
        LogUtil.info(`${TAG} failed to startAbility. Code: ${err?.code}, message: ${err?.message}`);
      }
      ;
    });

    afterAll(async () => {
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });

    /*
    * @tc.number: batteryPageTest_002
    * @tc.name: 显示电量百分比开关验证
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 自动调节按钮测试
    */
    it('batteryPageTest_002', 0, batteryPageTest_002(dr));

    /*
    * @tc.number: batteryPageTest_003
    * @tc.name: 显示电量使用情况验证
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 自动调节按钮测试
    */
    it('batteryPageTest_003', 0, batteryPageTest_003(dr));
  })
}

function batteryPageTest_002(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} batteryPageTest_002 start`);
    await driver.delayMs(COMMON_DELAY);
    try {
      await driver.assertComponentExist(ON.id('Setting.Battery.charging_group.display_battery_percentage_switch.result'));
      let toggle =
        await driver.waitForComponent(ON.id('Setting.Battery.charging_group.display_battery_percentage_switch.result'),
          WAIT_DELAY);
      await toggle.click();
      await driver.delayMs(COMMON_DELAY);
      await driver.assertComponentExist(ON.checked(false)
        .id('Setting.Battery.charging_group.display_battery_percentage_switch.result'));

      toggle =
        await driver.waitForComponent(ON.id('Setting.Battery.charging_group.display_battery_percentage_switch.result'),
          WAIT_DELAY);
      await toggle.click();
      await driver.delayMs(COMMON_DELAY);
      LogUtil.info(`${TAG} automatic adjust toggle clicked`);

      await driver.assertComponentExist(ON.checked(true)
        .id('Setting.Battery.charging_group.display_battery_percentage_switch.result'));
    } catch (err) {
      LogUtil.showError(TAG, `batteryPageTest_002 err.code : ${err?.code}, message: ${err?.message}`);
    }
    done();
    LogUtil.info(`${TAG} batteryPageTest_002 end`);
  };
}

function batteryPageTest_003(dr: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${TAG} batteryPageTest_003 start`);
    try {
      // 校验电池页面存在以下组件
      await dr.delayMs(WAIT_DELAY);
      await dr.assertComponentExist(ON.id('Setting.Battery.power_consumption_detail_group'));
      if (DeviceUtil.isDevicePhone()) {
        await dr.assertComponentExist(ON.text('亮屏时长'));
        await dr.assertComponentExist(ON.text('息屏活动时长'));
      }
    } catch (err) {
      LogUtil.showError(TAG, `batteryPageTest_003 err code: ${err?.code} msg: ${err?.message}`);
    }
    LogUtil.info(`${TAG} batteryPageTest_003 end`);
    done();
  };
}