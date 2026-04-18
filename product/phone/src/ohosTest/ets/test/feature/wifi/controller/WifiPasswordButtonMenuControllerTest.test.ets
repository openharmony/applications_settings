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

import { describe, it, expect, TestType, MockKit, when, ArgumentMatchers } from '@ohos/hypium';
import { SettingsBaseMenu } from '@ohos/settings.common';
import { WifiUtils } from '@ohos/settings.wifi';
import {
  WifiPasswordButtonMenuController
} from '@ohos/settings.wifi/src/main/ets/controller/WifiPasswordButtonMenuController';
export default function WifiPasswordButtonMenuControllerTest() {
  let menu: SettingsBaseMenu = new SettingsBaseMenu();
  let wifiPasswordButton = new WifiPasswordButtonMenuController(menu);
  describe('WifiPasswordButtonMenuControllerTest', () => {
    it('test_init', TestType.FUNCTION, () => {
      let resA = WifiPasswordButtonMenuController.CreateWifiPasswordButtonMenuController(menu);
      menu.extra = {
        isCurrentVisible: true,
        supportEapMethod: [1, 2],
        listenMenuKeyArray: ['wifi_security_type_options', 'wifi_security_type_eap'],
      };
      let resB = WifiPasswordButtonMenuController.CreateWifiPasswordButtonMenuController(menu);
      expect(resA === resB).assertFalse();
    });

    it('test_onDataChange', TestType.FUNCTION, () => {
      let resA = wifiPasswordButton.onDataChange('wifi_password_input', 1000);
      expect(resA === null).assertFalse();
      let resB = wifiPasswordButton.onDataChange('wifi', 1000);
      expect(resB === null).assertFalse();
    });

    it('test_refreshButton', TestType.FUNCTION, () => {
      let resA: Object = (wifiPasswordButton as object)['refreshButton'](true);
      expect(resA === null).assertFalse();
      let resB: Object = (wifiPasswordButton as object)['refreshButton'](false);
      expect(resB === null).assertFalse();
    });

    it('test_onConnectResult', TestType.FUNCTION, () => {
      let resA = wifiPasswordButton.onConnectResult(1);
      expect(resA === null).assertFalse();
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(WifiUtils, WifiUtils.needShowConnectFailedDialog);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
      let mockfunc2: Function = mocker.mockFunc(WifiUtils, WifiUtils.getDisconnectedReason);
      when(mockfunc2)(ArgumentMatchers.any).afterReturn(4);
      let resB = wifiPasswordButton.onConnectResult(0);
      expect(resB === null).assertFalse();
      when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
      when(mockfunc2)(ArgumentMatchers.any).afterReturn(1);
      let resC = wifiPasswordButton.onConnectResult(0);
      expect(resC === null).assertFalse();
      when(mockfunc2)(ArgumentMatchers.any).afterReturn(7);
      let resD = wifiPasswordButton.onConnectResult(0);
      expect(resD === null).assertFalse();
      mocker.clear(WifiUtils);
    });

  });
}