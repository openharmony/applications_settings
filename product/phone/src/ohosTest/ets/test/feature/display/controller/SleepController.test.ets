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
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu'
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils'
import { SleepController, SleepKey } from '@ohos/settings.display/src/main/ets/controller/SleepController'

export default function SleepControllerTest() {
  describe('SleepControllerTest', () => {
    it('SleepControllerTest_001', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu()
      let eyeComfortModeC: SleepController = new SleepController(menu)
      let mocker: MockKit = new MockKit()
      let mockFun: Function = mocker.mockFunc(SettingsDataUtils, SettingsDataUtils.getSettingsData)
      when(mockFun)(ArgumentMatchers.any).afterReturn('')
      eyeComfortModeC.updateStatus()
      when(mockFun)(ArgumentMatchers.any).afterReturn(undefined)
      eyeComfortModeC.updateStatus()
      expect(eyeComfortModeC != null).assertTrue()
      mocker.clear(SettingsDataUtils)
    })
    it('SleepControllerTest_002', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu()
      menu.key = 'test'
      let eyeComfortModeC: SleepController = new SleepController(menu)
      eyeComfortModeC.aboutToAppear()
      eyeComfortModeC.menu.key = SleepKey.FIFTEEN_SECONDS_KEY
      eyeComfortModeC.aboutToAppear()
      eyeComfortModeC.menu.key = SleepKey.THIRTY_SECONDS_KEY
      eyeComfortModeC.aboutToAppear()
      eyeComfortModeC.menu.key = SleepKey.ONE_MINUTE_KEY
      eyeComfortModeC.aboutToAppear()
      eyeComfortModeC.menu.key = SleepKey.TWO_MINUTES_KEY
      eyeComfortModeC.aboutToAppear()
      eyeComfortModeC.menu.key = SleepKey.FIVE_MINUTES_KEY
      eyeComfortModeC.aboutToAppear()
      eyeComfortModeC.menu.key = SleepKey.TEN_MINUTES_KEY
      eyeComfortModeC.aboutToAppear()
      expect(eyeComfortModeC != null).assertTrue()
    })
  })
}