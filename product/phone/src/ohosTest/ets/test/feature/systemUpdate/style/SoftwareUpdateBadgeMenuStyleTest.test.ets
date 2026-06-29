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
import { SoftwareUpdateBadgeMenuStyle } from '@ohos/settings.systemUpdate';

export default function SoftwareUpdateBadgeMenuStyleTest() {
  let SoftwareUpdate :SoftwareUpdateBadgeMenuStyle = new SoftwareUpdateBadgeMenuStyle();

  describe('SoftwareUpdateBadgeMenuStyleTest', () => {

    it('test_setStateIconMarginLeft', 0, (): void => {
      let resA: Object = (SoftwareUpdate as object)['setStateIconMarginLeft'](undefined);
      expect(resA === null).assertFalse();
      let menu: SettingsBaseMenu = new SettingsBaseMenu();
      let resB: Object = (SoftwareUpdate as object)['setStateIconMarginLeft'](menu);
      expect(resB === null).assertFalse();
    })

    it('test_setStateContainerMarginLeft', 0, (): void => {
      let resA: Object = (SoftwareUpdate as object)['setStateContainerMarginLeft'](undefined);
      expect(resA === null).assertFalse();
      let resB: Object = (SoftwareUpdate as object)['setStateContainerMarginLeft'](1);
      expect(resB === null).assertFalse();
      let resC: Object = (SoftwareUpdate as object)['setStateContainerMarginLeft'](0);
      expect(resC === null).assertFalse();
    })

    it('test_changeStyle', 0, (): void => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu();
      let resA = SoftwareUpdate.changeStyle(menu);
      expect(resA === null).assertFalse();
      menu.badge = 10;
      let resB = SoftwareUpdate.changeStyle(menu);
      expect(resB === null).assertFalse();
    })

  });
}

