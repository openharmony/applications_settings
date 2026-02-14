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
import { DisplayConstant } from '@ohos/settings.common/src/main/ets/constant/DisplayConstant'
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu'
import { FontSizeAdjustController } from '@ohos/settings.display/src/main/ets/controller/FontSizeAdjustController'

export default function FontSizeAdjustControllerTest() {
  describe('FontSizeAdjustControllerTest', () => {
    it('FontSizeAdjustControllerTest_001', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu()
      let fontSizeAdjustC: FontSizeAdjustController = new FontSizeAdjustController(menu)
      fontSizeAdjustC.onSliderChange(1)
      fontSizeAdjustC.onSliderChange(1)
      fontSizeAdjustC.onStartIconClick()
      fontSizeAdjustC.onEndIconClick()
      fontSizeAdjustC.onStartIconClick()
      fontSizeAdjustC.onSliderChange(5)
      fontSizeAdjustC.onEndIconClick()
      let result = fontSizeAdjustC.onSliderChange(2)
      expect(result).assertTrue()
    })
    it('FontSizeAdjustControllerTest_002', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu()
      let fontSizeAdjustC: FontSizeAdjustController = new FontSizeAdjustController(menu)
      for (let index = 0; index < 9; index++) {
        let result = fontSizeAdjustC.onSliderChange(index)
        expect(result).assertTrue()
      }
      // 恢复默认值
      fontSizeAdjustC.onSliderChange(DisplayConstant.TEXT_FONT_SIZE_NORMAL_STEP)
    })
  })
}