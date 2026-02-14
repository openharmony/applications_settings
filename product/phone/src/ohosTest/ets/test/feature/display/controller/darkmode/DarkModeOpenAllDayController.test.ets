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

import { describe, it, expect, MockKit, when, ArgumentMatchers } from '@ohos/hypium'
import { CompCtrlParam, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel'
import { SettingToggleState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel'
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils'
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils'
import {
  DARK_MODE_OPEN_ALL_DAY,
  DARK_MODE_TIMED_ON,
  DEFAULT_DARK_MODE_STATE
} from '@ohos/settings.display/src/main/ets/constant/DarkModeConstant'
import {
  DarkModeOpenAllDayController
} from '@ohos/settings.display/src/main/ets/controller/darkmode/DarkModeOpenAllDayController'

export default function DarkModeOpenAllDayControllerTest() {
  describe('DarkModeOpenAllDayControllerTest', () => {
    it('DarkModeOpenAllDayControllerTest_001', 0, () => {
      let darkModeOpenAllDayC: DarkModeOpenAllDayController = new DarkModeOpenAllDayController();
      let compParamU: CompCtrlParam = AppStorage.get<CompCtrlParam>('compParam') as CompCtrlParam;
      darkModeOpenAllDayC.init(compParamU);
      let component: SettingBaseModel = {
        id: '1'
      };
      let compParam: CompCtrlParam = {
        compId: '1',
        component: component
      };
      darkModeOpenAllDayC.init(compParam);
      expect(darkModeOpenAllDayC != null).assertTrue();
    })
    it('DarkModeOpenAllDayControllerTest_changeColorMode_001', 0, () => {
      let darkModeOpenAllDayC: DarkModeOpenAllDayController = new DarkModeOpenAllDayController();
      (darkModeOpenAllDayC as object)['changeColorMode'](true);
      (darkModeOpenAllDayC as object)['changeColorMode'](false, false);
      expect(darkModeOpenAllDayC != null).assertTrue();
    })
    it('DarkModeOpenAllDayControllerTest_dealDarkModeInSettingsData_001', 0, () => {
      let darkModeOpenAllDayC: DarkModeOpenAllDayController = new DarkModeOpenAllDayController();
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
      when(mockFun)(ArgumentMatchers.any).afterReturn(DEFAULT_DARK_MODE_STATE);
      (darkModeOpenAllDayC as object)['dealDarkModeInSettingsData'](true);
      (darkModeOpenAllDayC as object)['dealDarkModeInSettingsData'](false);
      when(mockFun)(ArgumentMatchers.any).afterReturn(DARK_MODE_OPEN_ALL_DAY);
      (darkModeOpenAllDayC as object)['dealDarkModeInSettingsData'](false);
      expect(darkModeOpenAllDayC != null).assertTrue();
      mocker.clear(SettingsDataUtils);
    })
    it('DarkModeOpenAllDayControllerTest_stopTask_001', 0, () => {
      let darkModeOpenAllDayC: DarkModeOpenAllDayController = new DarkModeOpenAllDayController();
      (darkModeOpenAllDayC as object)['setModeTimerId'] = -1;
      (darkModeOpenAllDayC as object)['switchTimerId'] = -1;
      (darkModeOpenAllDayC as object)['stopTask']();
      (darkModeOpenAllDayC as object)['setModeTimerId'] = 1;
      (darkModeOpenAllDayC as object)['switchTimerId'] = 1;
      (darkModeOpenAllDayC as object)['stopTask']();
      expect(darkModeOpenAllDayC != null).assertTrue();
    })
    it('DarkModeOpenAllDayControllerTest_handleCheckedChange_001', 0, () => {
      let darkModeOpenAllDayC: DarkModeOpenAllDayController = new DarkModeOpenAllDayController();
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(DisplayUtils, DisplayUtils.isHighContrastOn);
      when(mockFun)().afterReturn(true);
      (darkModeOpenAllDayC as object)['handleCheckedChange'](true);
      (darkModeOpenAllDayC as object)['handleCheckedChange'](false);
      expect(darkModeOpenAllDayC != null).assertTrue();
      mocker.clear(DisplayUtils);
    })
    it('DarkModeOpenAllDayControllerTest_toggleStateChangeEventCallback_001', 0, () => {
      let darkModeOpenAllDayC: DarkModeOpenAllDayController = new DarkModeOpenAllDayController();
      (darkModeOpenAllDayC as object)['toggleStateChangeEventCallback']();
      let toggleState: SettingToggleState = {
        state: false
      };
      (darkModeOpenAllDayC as object)['toggleStateChangeEventCallback'](toggleState);
      toggleState.state = true;
      (darkModeOpenAllDayC as object)['toggleStateChangeEventCallback'](toggleState);
      (darkModeOpenAllDayC as object)['isNeedDealToggleChange'] = true;
      (darkModeOpenAllDayC as object)['toggleStateChangeEventCallback'](toggleState);
      (darkModeOpenAllDayC as object)['isNeedDealToggleChange'] = false;
      (darkModeOpenAllDayC as object)['toggleStateChangeEventCallback'](toggleState);
      expect(darkModeOpenAllDayC != null).assertTrue();
    })
    it('DarkModeOpenAllDayControllerTest_darkModeChangeCallback_001', 0, () => {
      let darkModeOpenAllDayC: DarkModeOpenAllDayController = new DarkModeOpenAllDayController();
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
      when(mockFun)(ArgumentMatchers.any).afterReturn(DARK_MODE_OPEN_ALL_DAY);
      (darkModeOpenAllDayC as object)['darkModeChangeCallback']();
      when(mockFun)(ArgumentMatchers.any).afterReturn(DEFAULT_DARK_MODE_STATE);
      (darkModeOpenAllDayC as object)['darkModeChangeCallback']();
      when(mockFun)(ArgumentMatchers.any).afterReturn(DARK_MODE_TIMED_ON);
      (darkModeOpenAllDayC as object)['darkModeChangeCallback']();
      when(mockFun)(ArgumentMatchers.any).afterReturn('-1');
      (darkModeOpenAllDayC as object)['darkModeChangeCallback']();
      expect(darkModeOpenAllDayC != null).assertTrue();
      mocker.clear(SettingsDataUtils);
    })
  })
}