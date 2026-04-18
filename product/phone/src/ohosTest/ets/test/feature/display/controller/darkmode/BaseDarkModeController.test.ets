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
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils'
import {
  DARK_MODE_TIMED_ON,
  DEFAULT_DARK_MODE_STATE
} from '@ohos/settings.display/src/main/ets/constant/DarkModeConstant'
import { BaseDarkModeController } from '@ohos/settings.display/src/main/ets/controller/darkmode/BaseDarkModeController'

export default function BaseDarkModeControllerTest() {
  describe('BaseDarkModeControllerTest', () => {
    it('BaseDarkModeControllerTest_001', 0, () => {
      let baseDarkModeC: BaseDarkModeController = new BaseDarkModeController();
      let compParamU: CompCtrlParam = AppStorage.get<CompCtrlParam>('compParam') as CompCtrlParam;
      baseDarkModeC.init(compParamU);
      let component: SettingBaseModel = {
        id: '1'
      };
      let compParam: CompCtrlParam = {
        compId: '1',
        component: component
      };
      baseDarkModeC.init(compParam);
      expect(baseDarkModeC != null).assertTrue();
    })
    it('BaseDarkModeControllerTest_002', 0, () => {
      let baseDarkModeC: BaseDarkModeController = new BaseDarkModeController();
      (baseDarkModeC as object)['registerDataHelper']();
      expect(baseDarkModeC != null).assertTrue();
    })
    it('BaseDarkModeControllerTest_003', 0, () => {
      let baseDarkModeC: BaseDarkModeController = new BaseDarkModeController();
      (baseDarkModeC as object)['dataHelper'] = {};
      (baseDarkModeC as object)['unRegisterDataHelper']();
      expect(baseDarkModeC != null).assertTrue();
    })
    it('BaseDarkModeControllerTest_004', 0, () => {
      let baseDarkModeC: BaseDarkModeController = new BaseDarkModeController();
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData);
      when(mockFun)(ArgumentMatchers.any).afterReturn(DEFAULT_DARK_MODE_STATE);
      let result = (baseDarkModeC as object)['isInDarkModeOnTime']() as boolean;
      expect(result).assertFalse();
      when(mockFun)(ArgumentMatchers.any).afterReturn(DARK_MODE_TIMED_ON);
      result = (baseDarkModeC as object)['isInDarkModeOnTime']() as boolean;
      expect(result).assertFalse();
      mocker.clear(SettingsDataUtils);
    })
  })
}