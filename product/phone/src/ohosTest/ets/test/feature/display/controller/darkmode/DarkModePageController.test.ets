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

import { describe, it, expect } from '@ohos/hypium'
import { CompCtrlParam, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel'
import {
  DARK_MODE_OPEN_ALL_DAY,
  DEFAULT_DARK_MODE_STATE
} from '@ohos/settings.display/src/main/ets/constant/DarkModeConstant'
import { DarkModePageController } from '@ohos/settings.display/src/main/ets/controller/darkmode/DarkModePageController'

export default function DarkModePageControllerTest() {
  describe('DarkModePageControllerTest', () => {
    it('DarkModePageControllerTest_001', 0, () => {
      let darkModePageC: DarkModePageController = new DarkModePageController();
      let compParamU: CompCtrlParam = AppStorage.get<CompCtrlParam>('compParam') as CompCtrlParam;
      darkModePageC.init(compParamU);
      let component: SettingBaseModel = {
        id: '1'
      };
      let compParam: CompCtrlParam = {
        compId: '1',
        component: component
      };
      darkModePageC.init(compParam);
      expect(darkModePageC != null).assertTrue();
    })
    it('DarkModePageControllerTest_002', 0, () => {
      let darkModePageC: DarkModePageController = new DarkModePageController();
      (darkModePageC as object)['isDarkModeOpen'] = true;
      (darkModePageC as object)['darkModeType'] = DARK_MODE_OPEN_ALL_DAY;
      let result = (darkModePageC as object)['initOpenAllDayState']() as boolean;
      expect(result).assertTrue();
      (darkModePageC as object)['isDarkModeOpen'] = true;
      (darkModePageC as object)['darkModeType'] = '';
      result = (darkModePageC as object)['initOpenAllDayState']() as boolean;
      expect(result).assertFalse();
      (darkModePageC as object)['isDarkModeOpen'] = false;
      (darkModePageC as object)['darkModeType'] = DEFAULT_DARK_MODE_STATE;
      result = (darkModePageC as object)['initOpenAllDayState']() as boolean;
      expect(result).assertFalse();
    })
  })
}