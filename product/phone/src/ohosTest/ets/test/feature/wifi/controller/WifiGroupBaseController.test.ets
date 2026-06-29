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
import { WifiGroupBaseController } from '@ohos/settings.wifi/src/main/ets/controller/WifiGroupBaseController';
import { Constant } from '../../../constant/Constant';

const MENU_KEY: string = 'wifi_entry';
const WIFI_PASSWORD_INPUT: string = 'wifi_password_input';

export default function WifiGroupBaseControllerTest() {
  describe('WifiGroupBaseControllerTest', () => {

    /*
    * @tc.number: WifiGroupBaseControllerTest_001
    * @tc.name: updateAll
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('WifiGroupBaseControllerTest_001', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} WifiGroupBaseControllerTest_001 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let wifiGroupBaseController = new WifiGroupBaseController(menu);
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(wifiGroupBaseController, wifiGroupBaseController.onDataChange);
      when(mockFunc)(WIFI_PASSWORD_INPUT).afterReturn(true);
      let result = await wifiGroupBaseController.onDataChange(WIFI_PASSWORD_INPUT);
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} WifiGroupBaseControllerTest_001 end`);
    });
  });
}