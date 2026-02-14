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
import { SettingsDataUtils } from '@ohos/settings.common';
import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  DARK_MODE_OPEN_ALL_DAY,
  DARK_MODE_TIMED_ON,
  DEFAULT_DARK_MODE_STATE
} from '@ohos/settings.display/src/main/ets/constant/DarkModeConstant';
import { DarkModeController } from '@ohos/settings.display/src/main/ets/controller/darkmode/DarkModeController';

export default function DarkModeControllerTestTest() {
  describe('DarkModeControllerTestTest', () => {
    it("DarkModeControllerTest_001", 0, () => {
      let baseDarkModeC: DarkModeController = new DarkModeController();
      let compParamU: CompCtrlParam = AppStorage.get<CompCtrlParam>('compParam') as CompCtrlParam;
      baseDarkModeC.init(compParamU);
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
      when(mockFun)(ArgumentMatchers.any).afterReturn(DEFAULT_DARK_MODE_STATE);
      baseDarkModeC.init(compParamU);
      when(mockFun)(ArgumentMatchers.any).afterReturn(DARK_MODE_TIMED_ON);
      baseDarkModeC.init(compParamU);
      expect(baseDarkModeC != null).assertTrue();
      mocker.clear(SettingsDataUtils);
    })
    it("DarkModeControllerTest_002", 0, () => {
      let baseDarkModeC: DarkModeController = new DarkModeController();
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
      when(mockFun)(ArgumentMatchers.any).afterReturn('-1');
      (baseDarkModeC as object)['darkModeChangeCallback']();
      when(mockFun)(ArgumentMatchers.any).afterReturn(DARK_MODE_TIMED_ON);
      (baseDarkModeC as object)['darkModeChangeCallback']();
      when(mockFun)(ArgumentMatchers.any).afterReturn(DEFAULT_DARK_MODE_STATE);
      (baseDarkModeC as object)['darkModeChangeCallback']();
      when(mockFun)(ArgumentMatchers.any).afterReturn(DARK_MODE_OPEN_ALL_DAY);
      (baseDarkModeC as object)['darkModeChangeCallback']();
      expect(baseDarkModeC != null).assertTrue();
      mocker.clear(SettingsDataUtils);
    })
  })
}