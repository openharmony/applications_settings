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

import { afterAll, beforeAll, describe, it } from '@ohos/hypium';
import { Driver, ON } from '@ohos.UiTest';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { LogUtil, NavEntryKey } from '@ohos/settings.common';
import { BusinessError } from '@ohos.base';
import { COMMON_DELAY, WAIT_DELAY } from '../../types';
import { Constant } from '../../constant/Constant';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function DragPageTest() {
  describe('DragPageTest', () => {
    beforeAll(beforeAllFn);
    afterAll(afterAllFn);

    /*
    * @tc.number:DragPageTest_001
    * @tc.name: 系统-全局拖拽页面验证
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
  */
    it('DragTabPageTest_001', 0, dragTabPageTest_001);
  });
}

async function beforeAllFn() {
  try {
    await DELEGATOR.startAbility({
      'bundleName': Constant.SETTINGS_BUNDLE_NAME,
      'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
      'uri': NavEntryKey.SYSTEM_UPDATE_ENTRY,
    }).then(() => {
      LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success`);
    });
  } catch (exception) {
    LogUtil.info(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
  }
}

async function afterAllFn() {
  // 定义Driver类
  let dr = await Driver.create();
  await dr.delayMs(COMMON_DELAY);
  await dr.pressHome();
  await dr.delayMs(COMMON_DELAY);
}

/**
 * 系统-全局拖拽页面验证
 */
async function dragTabPageTest_001() {
  return async (done: Function) => {
    LogUtil.info(`${Constant.TAG} DragPageTest_001 start`);
    try {
      // 定义Driver类
      let dr: Driver = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      // 点击拖拽
      let DragTab = await dr.waitForComponent(ON.text(Constant.DRAG), WAIT_DELAY);
      await DragTab.click();
      LogUtil.info(`${Constant.TAG} Drag Tab clicked`);
      // 点击左上角返回按钮到系统页面
      await dr.delayMs(COMMON_DELAY);
      await dr.click(104, 214);
      LogUtil.info(`${Constant.TAG} click back arrow`);
      await dr.delayMs(COMMON_DELAY);
      LogUtil.info(`${Constant.TAG} Drag DragBackIcon`);
      await dr.assertComponentExist(ON.text(Constant.SYSTEM_TITLE));
      // 再次点击返回按钮到设置页面
      await dr.delayMs(COMMON_DELAY);
      await dr.click(104, 214);
      await dr.pressBack();
      await dr.delayMs(COMMON_DELAY);
    } catch (err) {
      LogUtil.showError(Constant.TAG, `DisplayPageTest_003 err.code : ${err?.code}, message: ${err?.message}`);
    }
    done();
    LogUtil.info(`${Constant.TAG} Drag BackButton`);
    LogUtil.info(`${Constant.TAG} DragPageTest_001 end`);
  }
}
