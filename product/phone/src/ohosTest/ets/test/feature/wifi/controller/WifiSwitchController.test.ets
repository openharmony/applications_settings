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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { WifiSwitchController } from '@ohos/settings.wifi/src/main/ets/controller/WifiSwitchController';
import { Constant } from '../../../constant/Constant';
import { AirPlaneUtils, WifiUtils } from '@ohos/settings.wifi';
import { SettingsDataUtils } from '@ohos/settings.common';

let menu: SettingsBaseMenu = new SettingsBaseMenu();
class WifiSwitchSon extends WifiSwitchController {
  constructor() {
    super(menu)
  }

  updateCheckedState(): boolean {
    return super.updateCheckedState();
  }

  handleCheckedChange(isChecked: boolean): boolean {
    return super.handleCheckedChange(isChecked);
  }
}
export default function WifiSwitchControllerTest() {
  let wifiSwitchController = new WifiSwitchController(menu);
  let wifiSwitchSon = new WifiSwitchSon();
  describe('WifiSwitchControllerTest', () => {
    it('test_onWifiStateChange', TestType.FUNCTION, () => {
      wifiSwitchController.taskTimerId = null;
      let resA = wifiSwitchController.onWifiStateChange(3);
      expect(resA === null).assertFalse();
      let resB = wifiSwitchController.onWifiStateChange(0);
      expect(resB === null).assertFalse();
      let resC = wifiSwitchController.onWifiStateChange(1);
      expect(resC === null).assertFalse();
      wifiSwitchController.taskTimerId = 7;
      let resD = wifiSwitchController.onWifiStateChange(0);
      expect(resD === null).assertFalse();
      let resE = wifiSwitchController.onWifiStateChange(1);
      expect(resE === null).assertFalse();
    });

    it('test_updateCheckedState', TestType.FUNCTION, () => {
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(WifiUtils, WifiUtils.isWifiActive);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
      let resA = wifiSwitchSon.updateCheckedState();
      expect(resA === null).assertFalse();
      when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
      let resB = wifiSwitchSon.updateCheckedState();
      expect(resB === null).assertFalse();
      mocker.clear(WifiUtils);
    });

    it('test_handleCheckedChange', TestType.FUNCTION, () => {
      let resA = wifiSwitchSon.handleCheckedChange(true);
      expect(resA === false).assertTrue();
      let resB = wifiSwitchSon.handleCheckedChange(false);
      expect(resB === true).assertTrue();
    });

    it('test_updateToTargetState', TestType.FUNCTION, () => {
      wifiSwitchController.taskTimerId = null;
      let resA = wifiSwitchController.updateToTargetState();
      expect(resA === true).assertTrue();
      wifiSwitchController.taskTimerId = 7;
      wifiSwitchController.currentState = 3;
      let resB = wifiSwitchController.updateToTargetState(10000);
      expect(resB === true).assertTrue();
      wifiSwitchController.currentState = 1;
      wifiSwitchController.targetState = 1;
      let resC = wifiSwitchController.updateToTargetState(10000);
      expect(resC === true).assertTrue();
      wifiSwitchController.currentState = 0;
      wifiSwitchController.targetState = 0;
      let resD = wifiSwitchController.updateToTargetState(10000);
      expect(resD === true).assertTrue();
      wifiSwitchController.currentState = 6;
      wifiSwitchController.targetState = 6;
      wifiSwitchController.switchTimerId = null;
      let resE = wifiSwitchController.updateToTargetState(10000);
      expect(resE === true).assertTrue();
      wifiSwitchController.currentState = 9;
      wifiSwitchController.switchTimerId = 5;
      let resF = wifiSwitchController.updateToTargetState(10000);
      expect(resF === true).assertTrue();
    });

    it('test_switchWifi', TestType.FUNCTION, () => {
      wifiSwitchController.targetState = 1;
      let resA: Object = (wifiSwitchController as object)['switchWifi']();
      expect(resA === null).assertFalse();
      wifiSwitchController.targetState = 9;
      let resB: Object = (wifiSwitchController as object)['switchWifi']();
      expect(resB === null).assertFalse();
    });

    it('test_stopTask', TestType.FUNCTION, () => {
      wifiSwitchController.taskTimerId = null;
      wifiSwitchController.switchTimerId = null;
      let resA: Object = (wifiSwitchController as object)['stopTask']();
      expect(resA === null).assertFalse();
      wifiSwitchController.taskTimerId = 7;
      wifiSwitchController.switchTimerId = 7;
      let resB: Object = (wifiSwitchController as object)['stopTask']();
      expect(resB === null).assertFalse();
      let resC: Object = (wifiSwitchController as object)['stopTask']();
      expect(resC === null).assertFalse();
    });

    it('test_enableWiFi', TestType.FUNCTION, () => {
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(WifiUtils, WifiUtils.isWifiActive);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
      let resA: Object = (wifiSwitchController as object)['enableWiFi']();
      expect(resA === true).assertTrue();
      when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
      let resB: Object = (wifiSwitchController as object)['enableWiFi']();
      expect(resB === false).assertFalse();
      mocker.clear(WifiUtils);
    });

    it('test_disableWifi', TestType.FUNCTION, () => {
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(WifiUtils, WifiUtils.isWifiActive);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
      let resA: Object = (wifiSwitchController as object)['disableWifi']();
      expect(resA === true).assertTrue();
      when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
      let resB: Object = (wifiSwitchController as object)['disableWifi']();
      expect(resB === false).assertFalse();
      mocker.clear(WifiUtils);
    });

    it('test_enableSemiWifi', TestType.FUNCTION, () => {
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(WifiUtils, WifiUtils.isWifiActive);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
      let resA: Object = (wifiSwitchController as object)['enableSemiWifi']();
      expect(resA === true).assertTrue();
      when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
      let resB: Object = (wifiSwitchController as object)['enableSemiWifi']();
      expect(resB === false).assertFalse();
      mocker.clear(WifiUtils);
    });

    it('test_processWifiDisable', TestType.FUNCTION, () => {
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(AirPlaneUtils, AirPlaneUtils.isAirplaneActive);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
      let resA: Object = (wifiSwitchController as object)['processWifiDisable']();
      expect(resA === true).assertTrue();
      when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
      let mockfunc2: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
      when(mockfunc2)(ArgumentMatchers.any).afterReturn(true);
      let resB: Object = (wifiSwitchController as object)['processWifiDisable']();
      expect(resB === false).assertFalse();
      when(mockfunc2)(ArgumentMatchers.any).afterReturn(false);
      let resC: Object = (wifiSwitchController as object)['processWifiDisable']();
      expect(resC === false).assertFalse();
      mocker.clear(AirPlaneUtils);
      mocker.clear(SettingsDataUtils);
    });

    it('test_isWifiSwitching', TestType.FUNCTION, () => {
      wifiSwitchController.currentState = 7;
      let resA: Object = (wifiSwitchController as object)['isWifiSwitching']();
      expect(resA === true).assertTrue();
      wifiSwitchController.currentState = 1;
      let resB: Object = (wifiSwitchController as object)['isWifiSwitching']();
      expect(resB === true).assertFalse();
    });
  });
}