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
import { describe, expect, it } from '@ohos/hypium';
import { SettingsBaseMenu } from '@ohos/settings.common';
import { UsbDebugSwitchController } from '@ohos/settings.developeroptions';

class UsbDebugSwitchSon extends UsbDebugSwitchController {
  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  public handleCheckedChange(isChecked: boolean): boolean {
    return super.handleCheckedChange(isChecked);
  }
}

export default function UsbDebugSwitchControllerTest() {
  let menu: SettingsBaseMenu = new SettingsBaseMenu();
  let UsbDebugSwitch = new UsbDebugSwitchSon(menu);
  describe('UsbDebugSwitchControllerTest', () => {
    it('test_handleCheckedChange', 0, (done: Function): void => {
      try {
        let resA = UsbDebugSwitch.handleCheckedChange(true);
        expect(resA === null).assertFalse();
      } catch(e) {
        console.log(`error${e}`)
      } finally {
        done();
      }
    })

    it('test_setUsbState', 0, (): void => {
      let resB = UsbDebugSwitch.setUsbState(false);
      expect(resB === null).assertFalse();
    })

    it('test_aboutToAppear', 0, (): void => {
      let resA = UsbDebugSwitch.aboutToAppear();
      expect(resA === null).assertFalse();
    })
  })
}