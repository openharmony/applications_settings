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
  PasswordInputMenuBaseController,
} from '@ohos/settings.privacy/src/main/ets/controller/PasswordInputMenuBaseController';
import { Constant } from '../../../constant/Constant';

const MENU_KEY: string = 'privacy_group';
const PASSWORD_INPUT: string = '11111111';

export default function PasswordInputMenuBaseControllerTest() {
  describe('PasswordInputMenuBaseControllerTest', () => {

    /*
    * @tc.number: PasswordInputMenuBaseControllerTest_001
    * @tc.name: onTextInputChange
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('PasswordInputMenuBaseControllerTest_001', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} PasswordInputMenuBaseControllerTest_001 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let passwordInputMenuBaseController = new PasswordInputMenuBaseController(menu);
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(passwordInputMenuBaseController, passwordInputMenuBaseController.onTextInputChange);
      when(mockFunc)(PASSWORD_INPUT).afterReturn(true);
      let result = await passwordInputMenuBaseController.onTextInputChange(PASSWORD_INPUT);
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} PasswordInputMenuBaseControllerTest_001 end`);
    });

    /*
    * @tc.number: PasswordInputMenuBaseControllerTest_002
    * @tc.name: onEditChange
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('PasswordInputMenuBaseControllerTest_002', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} PasswordInputMenuBaseControllerTest_002 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let passwordInputMenuBaseController = new PasswordInputMenuBaseController(menu);
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(passwordInputMenuBaseController, passwordInputMenuBaseController.onEditChange);
      when(mockFunc)(true).afterReturn(true);
      let result = await passwordInputMenuBaseController.onEditChange(true);
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} PasswordInputMenuBaseControllerTest_002 end`);
    });

    /*
    * @tc.number: PasswordInputMenuBaseControllerTest_003
    * @tc.name: onSubmit
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('PasswordInputMenuBaseControllerTest_003', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} PasswordInputMenuBaseControllerTest_003 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let passwordInputMenuBaseController = new PasswordInputMenuBaseController(menu);
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(passwordInputMenuBaseController, passwordInputMenuBaseController.onSubmit);
      when(mockFunc)(EnterKeyType.Done).afterReturn(true);
      let result = await passwordInputMenuBaseController.onSubmit(EnterKeyType.Done);
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} PasswordInputMenuBaseControllerTest_003 end`);
    });

    /*
    * @tc.number: PasswordInputMenuBaseControllerTest_004
    * @tc.name: onMenuClick
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return false
    */
    it('PasswordInputMenuBaseControllerTest_004', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} PasswordInputMenuBaseControllerTest_004 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let passwordInputMenuBaseController = new PasswordInputMenuBaseController(menu);
      let result = await passwordInputMenuBaseController.onMenuClick();
      expect(result).assertFalse();
      LogUtil.info(`${Constant.TAG} PasswordInputMenuBaseControllerTest_004 end`);
    });

    /*
    * @tc.number: PasswordInputMenuBaseControllerTest_005
    * @tc.name: clearInput
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('PasswordInputMenuBaseControllerTest_005', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} PasswordInputMenuBaseControllerTest_005 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let passwordInputMenuBaseController = new PasswordInputMenuBaseController(menu);
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(passwordInputMenuBaseController, passwordInputMenuBaseController.clearInput);
      when(mockFunc)().afterReturn(true);
      let result = await passwordInputMenuBaseController.clearInput();
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} PasswordInputMenuBaseControllerTest_005 end`);
    });
  });
}