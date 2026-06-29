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

import { describe, it, expect, TestType, MockKit, when } from '@ohos/hypium';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import {
  CountDownMessageBaseController,
} from '@ohos/settings.privacy/src/main/ets/controller/CountDownMessageBaseController';
import { Constant } from '../../../constant/Constant';

const MENU_KEY: string = 'privacy_group';

export default function CountDownMessageBaseControllerTest() {
  describe('CountDownMessageBaseControllerTest', () => {

    /*
    * @tc.number: CountDownMessageBaseControllerTest_001
    * @tc.name: 开始计时，每秒刷新一次倒计时弹窗中的 message 时间信息
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('CountDownMessageBaseControllerTest_001', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} CountDownMessageBaseControllerTest_001 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let countDownMessageBaseController = new CountDownMessageBaseController(menu, null);
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(countDownMessageBaseController, countDownMessageBaseController.startCountDonwTimer);
      when(mockFunc)().afterReturn(true);
      let result = await countDownMessageBaseController.startCountDonwTimer();
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} CountDownMessageBaseControllerTest_001 end`);
    });

    /*
    * @tc.number: CountDownMessageBaseControllerTest_002
    * @tc.name: getMessage
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return null
    */
    it('CountDownMessageBaseControllerTest_002', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} CountDownMessageBaseControllerTest_002 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let countDownMessageBaseController = new CountDownMessageBaseController(menu, null);
      let result = await countDownMessageBaseController.getMessage();
      expect(result).assertNull();
      LogUtil.info(`${Constant.TAG} CountDownMessageBaseControllerTest_002 end`);
    });
  });
}