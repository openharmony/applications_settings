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
import { BusinessError } from '@ohos.base';
import { Driver, ON } from '@ohos.UiTest';
import { afterAll, beforeAll, describe, it } from '@ohos/hypium';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SpecificCleanUtils } from '@ohos/settings.storage';
import { Constant } from '../constant/Constant';
import { COMMON_DELAY, WAIT_DELAY } from '../types';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function storagePageTest() {
  describe('storagePageTest', () => {
    // 定义Driver类
    let dr: Driver = Driver.create();
    beforeAll(async () => {
      // 跳转存储页面
      try {
        await DELEGATOR.startAbility({
          'bundleName': Constant.SETTINGS_BUNDLE_NAME,
          'abilityName': Constant.SETTINGS_MAIN_ABILITY_NAME,
          'uri': 'storage_settings',
        }).then(() => {
          LogUtil.info(`${Constant.TAG} com.ohos.settings.MainAbility start success`);
        });
      } catch (exception) {
        LogUtil.info(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
      }
      ;
    });

    afterAll(async () => {
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });

    /*
    * @tc.number:storagePageTest_001
    * @tc.name: 存储页面入口验证
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 进入存储页面正常，
    */
    it('storagePageTest_001', 0, storagePageTest_001(dr));

    /**
     * @tc.number:storagePageTest_002
     * @tc.name: 存储页面专项清理入口验证
     * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
     * @tc.desc: 进入存储页面正常，根据CCM配置存在专项清理入口，点击可跳转
     */
    it('storagePageTest_002', 0, storagePageTest_002(dr));
  });
}

function storagePageTest_001(dr: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${Constant.TAG} storagePageTest_001 start`);

    try {
      // 校验存储页面存在以下组件
      await dr.delayMs(WAIT_DELAY);
      await dr.assertComponentExist(ON.id('Setting.Storage.dataPanelGroup'));
      await dr.assertComponentExist(ON.text('应用'));
      await dr.assertComponentExist(ON.text('图片'));
      await dr.assertComponentExist(ON.text('音乐'));
      await dr.assertComponentExist(ON.text('视频'));
      await dr.assertComponentExist(ON.text('系统'));
      await dr.assertComponentExist(ON.text('其他'));
    } catch (err) {
      LogUtil.showError(Constant.TAG, `storagePageTest_001 err code: ${err?.code} msg: ${err?.message}`);
    }
    LogUtil.info(`${Constant.TAG} storagePageTest_001 end`);
    done();
  };
}

function storagePageTest_002(driver: Driver): Function {
  return async (done: Function) => {
    LogUtil.info(`${Constant.TAG} storagePageTest_002 start`);
    try {
      await driver.delayMs(COMMON_DELAY);

      // 校验专项清理按钮存在，并点击进入
      if (SpecificCleanUtils.shouldShowEntrance()) {
        await driver.assertComponentExist(ON.text('专项清理'));
        let specificCleanButton = await driver.waitForComponent(ON.text('专项清理'), WAIT_DELAY);
        await specificCleanButton.click();
        LogUtil.info(`${Constant.TAG} specificCleanButton clicked`);
        await driver.delayMs(COMMON_DELAY);
        await driver.pressBack();
      }
    } catch (err) {
      LogUtil.showError(Constant.TAG, `storagePageTest_002 err code: ${err?.code} msg: ${err?.message}`);
    }
    LogUtil.info(`${Constant.TAG} storagePageTest_002 end`);
    done();
  };
}