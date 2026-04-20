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

import { beforeAll, describe, it, afterAll } from '@ohos/hypium';
import { BusinessError } from '@ohos.base';
import { Driver, ON } from '@ohos.UiTest';
import abilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { COMMON_DELAY, WAIT_DELAY } from '../types';
import { Constant } from '../constant/Constant';

const DELEGATOR: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const TAG: string = 'Application Management test';

export default function ApplicationMgrPageTest() {
  describe('ApplicationMgrPageTest', () => {
    // 定义Driver类
    let dr: Driver | null = null;
    beforeAll(async () => {
      dr =await Driver.create();
      // 启动设置开始
      try {
        await DELEGATOR.startAbility({
          'bundleName': 'com.ohos.settings',
          'abilityName': 'com.ohos.settings.MainAbility',
        }).then(() => {
          LogUtil.info(`${TAG} com.ohos.settings.MainAbility start success`);
        });
      } catch (exception) {
        LogUtil.info(`Failed to startAbility. Code: ${(exception as BusinessError).code}, message: ${(exception as BusinessError).message}`);
      };
      await dr?.delayMs(COMMON_DELAY);
      // 在控件上滑动查找目标的控件
      const START_X: number = 260;
      const START_Y: number = 1900;
      const END_X: number = 200;
      const END_Y: number = 397;
      const SPEED: number = 1000;
      await dr?.swipe(START_X, START_Y, END_X, END_Y, SPEED);
      // 跳转到应用和元服务界面
      let appTab = await dr?.waitForComponent(ON.text(Constant.APPLICATION_AND_SERVICE), WAIT_DELAY);
      await appTab?.click();
      LogUtil.info(`${Constant.TAG} applicationTab clicked`);
    });

    afterAll(async () => {
      // 定义Driver类
      dr = await Driver.create();
      await dr.delayMs(COMMON_DELAY);
      await dr.pressHome();
      await dr.delayMs(COMMON_DELAY);
    });
    /*
    * @tc.number:ApplicationMgrPageTest_001
    * @tc.name: 应用与元服务入口验证
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 点击进入应用与元服务entry，相关布局展示
    */
    it('ApplicationMgrPageTest_001', 0, async () => {
      LogUtil.info(`${Constant.TAG} ApplicationMgrPageTest_001 start`);
      await dr?.delayMs(COMMON_DELAY);
      try {
        LogUtil.info(`${TAG} check app management menu exist... `);
        await dr?.assertComponentExist(ON.text(Constant.APPLICATION_AND_SERVICE));
      } catch(err) {
        LogUtil.showError(TAG, `err.code : ${(err as BusinessError)?.code}, message: ${(err as BusinessError).message}`);
      }

      LogUtil.info(`${Constant.TAG} ApplicationMgrPageTest_001 end`);
    })

    /*
    * @tc.number:ApplicationMgrPageTest_002
    * @tc.name: 应用与元服务退出验证页面
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: ApplicationMgrPageTest_001进入应用与元服务，然后退出
    */
    it('ApplicationMgrPageTest_002', 0, async () => {
      LogUtil.info(`${Constant.TAG} ApplicationMgrPageTest_002 start`);
      await dr?.delayMs(COMMON_DELAY);
      try {
        LogUtil.info(`${TAG} check app management menu exist... `);
        await dr?.assertComponentExist(ON.text(Constant.APPLICATION_AND_SERVICE));
        let backIcon = await dr?.waitForComponent(ON.type('BackButton'), WAIT_DELAY);
        await backIcon?.click();
        await dr?.assertComponentExist(ON.text(Constant.SETTINGS));
      } catch(err) {
        LogUtil.showError(TAG, `err.code : ${(err as BusinessError)?.code}, message: ${(err as BusinessError).message}`);
      }

      LogUtil.info(`${Constant.TAG} ApplicationMgrPageTest_002 end`);
    })
  })
}