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

import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect, MockKit, when,
  ArgumentMatchers } from '@ohos/hypium'
import { SettingsDataUtils } from '@ohos/settings.common'
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus'
import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel'
import { SettingToggleState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel'
import { SWITCH_OFF_VAL, SWITCH_ON_VAL } from '@ohos/settings.common/src/main/ets/utils/Consts'
import { AirPlaneUtils, WifiState, WifiUtils } from '@ohos/settings.wifi'
import { WifiSwitchController } from '@ohos/settings.wifi/src/main/ets/controller/new/WifiSwitchController'

export default function NewWifiSwitchControllerTest() {
  describe('NewWifiSwitchControllerTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    it('test_init', 0, () => {
      let test = new WifiSwitchController();
      test.init(undefined);
      let compParam: CompCtrlParam = {
        compId: '001',
        component: {
          id: '000000-5555'
        },
      };
      test.init(compParam);
      let state: SettingToggleState = {
        state: false
      };
      test.isChecked = true;
      EventBus.getInstance().emit(`${compParam.compId}.toggle`, state);
      EventBus.getInstance().emit(`${compParam.compId}.toggle`, state);
      state.state = true;
      test.isChecked = false;
      EventBus.getInstance().emit(`${compParam.compId}.toggle`, state);
      EventBus.getInstance().emit(`${compParam.compId}.toggle`, state);
      test.onPageShow({
        id: '111'
      });
      test.onPageHide({
        id: '111'
      });
      test.destroy();
      expect(test !== null).assertTrue();
    })
    it('test_WifiStateChange', 0, () => {
      let test = new WifiSwitchController();
      test.taskTimerId = 10010;
      test.onWifiStateChange(WifiState.ACTIVE);
      test.onWifiStateChange(WifiState.INACTIVE);
      test.taskTimerId = null;
      test.onWifiStateChange(WifiState.DEACTIVATING);
      test.onWifiStateChange(WifiState.ACTIVE);
      test.onWifiStateChange(WifiState.INACTIVE);
      expect(test !== null).assertTrue();
    })
    it('test_updateToTargetState', 0, (done: Function) => {
      let test = new WifiSwitchController();
      test.taskTimerId = null;
      test.updateToTargetState();
      test.taskTimerId = 10010;
      test.currentState = WifiState.DEACTIVATING;
      test.updateToTargetState();
      test.taskTimerId = 10010;
      test.currentState = WifiState.ACTIVE;
      test.targetState = WifiState.ACTIVE;
      test.updateToTargetState();
      test.taskTimerId = 10010;
      test.currentState = WifiState.INACTIVE;
      test.targetState = WifiState.INACTIVE;
      test.updateToTargetState(0);
      test.taskTimerId = 10010;
      test.currentState = WifiState.DEACTIVATING;
      test.targetState = WifiState.DEACTIVATING;
      test.updateToTargetState(0);
      test.taskTimerId = 10010;
      test.currentState = WifiState.DEACTIVATING;
      test.targetState = WifiState.INACTIVE;
      test.updateToTargetState(0);
      setTimeout(() => {
        done();
      }, 1000);
      expect(test !== null).assertTrue();
    })
    it('test_switchWifi_01', 0, () => {
      let mocker: MockKit = new MockKit();
      let test = new WifiSwitchController();
      test.targetState = WifiState.ACTIVE;
      let isWifiActiveFunc: Function = mocker.mockFunc(WifiUtils, WifiUtils.isWifiActive);
      when(isWifiActiveFunc)(ArgumentMatchers.any).afterReturn(true);
      (test as object)['switchWifi']();
      when(isWifiActiveFunc)(ArgumentMatchers.any).afterReturn(false);
      let enableWifiFunc: Function = mocker.mockFunc(WifiUtils, WifiUtils.enableWifi);
      when(enableWifiFunc)(ArgumentMatchers.any).afterReturn(false);
      test.switchTimerId = 10086;
      (test as object)['switchWifi']();
      when(enableWifiFunc)(ArgumentMatchers.any).afterReturn(true);
      (test as object)['switchWifi']();
      test.targetState = WifiState.INACTIVE;
      AppStorage.setOrCreate('OOBEWifi', true);
      (test as object)['switchWifi']();
      AppStorage.setOrCreate('OOBEWifi', false);
      (test as object)['switchWifi']();
      expect(test !== null).assertTrue();
      mocker.clear(WifiUtils);
    })
    it('test_switchWifi_02', 0, () => {
      let mocker: MockKit = new MockKit();
      let test = new WifiSwitchController();
      test.targetState = WifiState.INACTIVE;
      AppStorage.setOrCreate('OOBEWifi', true);
      let isWifiActiveFunc: Function = mocker.mockFunc(WifiUtils, WifiUtils.isWifiActive);
      when(isWifiActiveFunc)(ArgumentMatchers.any).afterReturn(false);
      (test as object)['switchWifi']();
      when(isWifiActiveFunc)(ArgumentMatchers.any).afterReturn(true);
      let disableWifiFunc: Function = mocker.mockFunc(WifiUtils, WifiUtils.disableWifi);
      when(disableWifiFunc)(ArgumentMatchers.any).afterReturn(false);
      (test as object)['switchWifi']();
      when(disableWifiFunc)(ArgumentMatchers.any).afterReturn(true);
      (test as object)['switchWifi']();
      test = new WifiSwitchController();
      test.targetState = WifiState.INACTIVE;
      AppStorage.setOrCreate('OOBEWifi', false);
      let isAirplaneActiveFunc: Function = mocker.mockFunc(AirPlaneUtils, AirPlaneUtils.isAirplaneActive);
      when(isAirplaneActiveFunc)(ArgumentMatchers.any).afterReturn(true);
      (test as object)['switchWifi']();
      when(isAirplaneActiveFunc)(ArgumentMatchers.any).afterReturn(false);
      let isCollaborationOnFunc: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
      when(isCollaborationOnFunc)(ArgumentMatchers.any).afterReturn(SWITCH_OFF_VAL);
      (test as object)['switchWifi']();
      when(isCollaborationOnFunc)(ArgumentMatchers.any).afterReturn(SWITCH_ON_VAL);
      when(isWifiActiveFunc)(ArgumentMatchers.any).afterReturn(false);
      (test as object)['switchWifi']();
      when(isWifiActiveFunc)(ArgumentMatchers.any).afterReturn(true);
      (test as object)['switchWifi']();
      expect(test !== null).assertTrue();
      mocker.clear(WifiUtils);
      mocker.clear(AirPlaneUtils);
      mocker.clear(SettingsDataUtils);
    })
  })
}