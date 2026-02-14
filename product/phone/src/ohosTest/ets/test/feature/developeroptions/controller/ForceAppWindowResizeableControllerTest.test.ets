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
import { ArgumentMatchers, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { SettingsBaseMenu, SystemParamUtils } from '@ohos/settings.common';
import { ForceResizableAppInterfacesController } from '@ohos/settings.developeroptions';

class ForceResizableAppInterfacesSon extends ForceResizableAppInterfacesController {
  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  public updateCheckedState(): boolean {
    return super.updateCheckedState();
  }

  public handleCheckedChange(isChecked: boolean): boolean {
    return super.handleCheckedChange(isChecked);
  }
}

export default function ForceResizableAppInterfacesControllerTest() {
  let menu: SettingsBaseMenu = new SettingsBaseMenu();
  let ForceResizableAppInterfaces = new ForceResizableAppInterfacesSon(menu);
  describe('ForceResizableAppInterfacesControllerTest', () => {
    it('test_handleCheckedChange', 0, (): void => {
      let resA = ForceResizableAppInterfaces.handleCheckedChange(true);
      expect(resA === null).assertFalse();
      let resB = ForceResizableAppInterfaces.handleCheckedChange(false);
      expect(resB === null).assertFalse();
      let resC = ForceResizableAppInterfaces.updateCheckedState();
      expect(resC === null).assertFalse();
      let mocker: MockKit = new MockKit();
      let contextfunc: Function = mocker.mockFunc(SystemParamUtils,SystemParamUtils.getSystemParam);
      when(contextfunc)(ArgumentMatchers.any).afterReturn('');
      let resD = ForceResizableAppInterfaces.updateCheckedState();
      expect(resD === null).assertFalse();
      mocker.clear(SystemParamUtils)
    })

  })
}