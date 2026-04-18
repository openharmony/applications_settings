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
  PsdInputMenuController,
  PsdInputMenuControllerSupportEditChange,
  SavedWifiButtonController,
  ConnectFailButtonController,
} from '@ohos/settings.wifi/src/main/ets/controller/WifiEntryBaseController';
import { Constant } from '../../../constant/Constant';

const MENU_KEY: string = 'wifi_entry';
const PASSWORD_INPUT: string = '11111111';
const IS_EDIT: boolean = true;

export default function WifiEntryBaseControllerTest() {
  describe('WifiEntryBaseControllerTest', () => {

    /*
    * @tc.number: WifiEntryBaseControllerTest_001
    * @tc.name: onTextInputChange
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('WifiEntryBaseControllerTest_001', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} WifiEntryBaseControllerTest_001 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let psdInputMenuController = new PsdInputMenuController(menu);
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(psdInputMenuController, psdInputMenuController.onTextInputChange);
      when(mockFunc)(PASSWORD_INPUT).afterReturn(true);
      let result = await psdInputMenuController.onTextInputChange(PASSWORD_INPUT);
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} WifiEntryBaseControllerTest_001 end`);
    });

    /*
    * @tc.number: WifiEntryBaseControllerTest_002
    * @tc.name: onEditChange
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('WifiEntryBaseControllerTest_002', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} WifiEntryBaseControllerTest_002 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let psdInputMenuControllerSupportEditChange = new PsdInputMenuControllerSupportEditChange(menu);
      let mocker: MockKit = new MockKit();
      let mockFunc: Function = mocker.mockFunc(psdInputMenuControllerSupportEditChange, psdInputMenuControllerSupportEditChange.onEditChange);
      when(mockFunc)(IS_EDIT).afterReturn(true);
      let result = await psdInputMenuControllerSupportEditChange.onEditChange(IS_EDIT);
      expect(result !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} WifiEntryBaseControllerTest_002 end`);
    });

    /*
    * @tc.number: WifiEntryBaseControllerTest_003
    * @tc.name: 菜单点击事件
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('WifiEntryBaseControllerTest_003', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} WifiEntryBaseControllerTest_003 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let savedWifiButtonController = new SavedWifiButtonController(menu);
      let mocker: MockKit = new MockKit();
      let mockFunc_1: Function = mocker.mockFunc(savedWifiButtonController, savedWifiButtonController.onButton1Click);
      when(mockFunc_1)().afterReturn(true);
      let result_1 = await savedWifiButtonController.onButton1Click();
      expect(result_1 !== null).assertTrue();
      let mockFunc_2: Function = mocker.mockFunc(savedWifiButtonController, savedWifiButtonController.onButton2Click);
      when(mockFunc_2)().afterReturn(true);
      let result_2 = await savedWifiButtonController.onButton2Click();
      expect(result_2 !== null).assertTrue();
      let mockFunc_3: Function = mocker.mockFunc(savedWifiButtonController, savedWifiButtonController.onButton3Click);
      when(mockFunc_3)().afterReturn(true);
      let result_3 = await savedWifiButtonController.onButton3Click();
      expect(result_3 !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} WifiEntryBaseControllerTest_003 end`);
    });

    /*
    * @tc.number: WifiEntryBaseControllerTest_004
    * @tc.name: 菜单点击事件
    * @tc.type: TestType.FUNCTION
    * @tc.desc: return true
    */
    it('WifiEntryBaseControllerTest_004', TestType.FUNCTION, async () => {
      LogUtil.info(`${Constant.TAG} WifiEntryBaseControllerTest_004 start`);
      new SettingsBaseMenu({
        key: MENU_KEY,
      });
      let menu: SettingsBaseMenu = new SettingsBaseMenu;
      let connectFailButtonController = new ConnectFailButtonController(menu);
      let mocker: MockKit = new MockKit();
      let mockFunc_1: Function = mocker.mockFunc(connectFailButtonController, connectFailButtonController.onButton1Click);
      when(mockFunc_1)().afterReturn(true);
      let result_1 = await connectFailButtonController.onButton1Click();
      expect(result_1 !== null).assertTrue();
      let mockFunc_2: Function = mocker.mockFunc(connectFailButtonController, connectFailButtonController.onButton3Click);
      when(mockFunc_2)().afterReturn(true);
      let result_2 = await connectFailButtonController.onButton3Click();
      expect(result_2 !== null).assertTrue();
      LogUtil.info(`${Constant.TAG} WifiEntryBaseControllerTest_004 end`);
    });
  });
}