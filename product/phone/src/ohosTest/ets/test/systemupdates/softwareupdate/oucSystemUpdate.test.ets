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
import { LogUtil, NavEntryKey } from '@ohos/settings.common';
import { COMMON_DELAY, WAIT_DELAY } from '../../types';
import { BusinessError } from '@ohos.base';
import { Constant } from '../../constant/Constant';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const TAG: string = 'Settingstest';

export default function oucSystemUpdatePageTest() {
  describe('oucSystemUpdatePageTest', () => {
    // 定义Driver类
    let dr: Driver | null = null;
    beforeAll(async () => {
      // 跳转到通用界面
      await startSystemAndUpdates();
    });

    afterAll(async () => {
      // 定义Driver类
      dr = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      // 点击返回按钮到设置页面
      let settingsBackIcon = await dr.waitForComponent(ON.type('BackButtonImage'), WAIT_DELAY);
      await settingsBackIcon.click();
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });

    /*
    * @tc.number:oucSystemUpdatePageTest_001
    * @tc.name: 软件更新通知跳转验证
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 成功进入软件更新页面
    */
    it('oucSystemUpdatePageTest_001', 0, oucSystemUpdatePageTest_001);

    /*
    * @tc.number:oucSystemUpdatePageTest_002
    * @tc.name: 软件更新通知跳转验证
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 成功进入软件更新页面
    */
    it('oucSystemUpdatePageTest_002', 0, oucSystemUpdatePageTest_002);
  });
}

async function startSystemAndUpdates() {
  try {
    await DELEGATOR.startAbility({
      'bundleName': 'com.ohos.settings',
      'abilityName': 'com.ohos.settings.MainAbility',
      'uri': 'system_and_updates',
    }).then(() => {
      LogUtil.info(`${TAG} com.ohos.settings.MainAbility start success`);
    });
  } catch (exception) {
    LogUtil.info(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
  }
}

async function oucSystemUpdatePageTest_001() {
  LogUtil.info(`${Constant.TAG} oucSystemUpdatePageTest_001 start`);
  try {
    // 定义Driver类
    let dr: Driver = await Driver.create();
    await dr.delayMs(COMMON_DELAY);
    await DELEGATOR.startAbility({
      'bundleName': 'com.ohos.settings',
      'abilityName': 'com.ohos.settings.MainAbility',
      'uri': NavEntryKey.OUC_SOFTWARE_UPDATE_SETTINGS,
      parameters: {
        'subUri': 'com_hmos_ouc_config_settings',
      },
    }).then(() => {
      LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success`);
    });
    await dr.delayMs(COMMON_DELAY);
    await DELEGATOR.startAbility({
      'bundleName': 'com.ohos.settings',
      'abilityName': 'com.ohos.settings.MainAbility',
      'uri': NavEntryKey.OUC_SOFTWARE_UPDATE_SETTINGS,
      parameters: {
        'subUri': 'com_hmos_ouc_current_version_settings',
      },
    }).then(() => {
      LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success`);
    });
    await dr.delayMs(COMMON_DELAY);
    await dr.assertComponentExist(ON.text(Constant.SOFTWARE_UPDATE));
    await dr.pressBack();
  } catch {
    LogUtil.error(`${Constant.TAG} oucParamVersionPageTest_001 execute exception failed!`);
  }
}

async function oucSystemUpdatePageTest_002() {
  LogUtil.info(`${Constant.TAG} oucSystemUpdatePageTest_002 start`);
  try {
    // 定义Driver类
    let dr: Driver = await Driver.create();
    await dr.delayMs(COMMON_DELAY);
    // 定义Driver类
    await DELEGATOR.startAbility({
      'bundleName': 'com.ohos.settings',
      'abilityName': 'com.ohos.settings.MainAbility',
      'uri': NavEntryKey.OUC_SOFTWARE_UPDATE_SETTINGS,
      parameters: {
        'pushParams': 'com_hmos_ouc_config_settings,isShowBack:false',
      },
    }).then(() => {
      LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success`);
    });
    await dr.delayMs(COMMON_DELAY);
    await dr.assertComponentExist(ON.text(Constant.SOFTWARE_UPDATE_NIGHT_UPGRADE));
    await dr.pressBack();
  } catch {
    LogUtil.error(`${Constant.TAG} oucParamVersionPageTest_001 execute exception failed!`);
  }
}
