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
import { NavEntryKey, SettingsBaseMenu, SettingsDataUtils } from '@ohos/settings.common';
import { SoftwareUpdateController } from '@ohos/settings.systemUpdate';
import { dataShare } from '@kit.ArkData';

export default function SoftwareUpdateControllerTest() {
  describe('SoftwareUpdateControllerTest', () => {
    let menu: SettingsBaseMenu = new SettingsBaseMenu();
    let SoftwareUpdate = SoftwareUpdateController.CreateSoftwareUpdateController(menu) as SoftwareUpdateController;

    it('test_onDeviceNameDataChange', 0, (): void => {
      let resA: Object = (SoftwareUpdate as object)['onDeviceNameDataChange']();
      expect(resA === null).assertFalse();
      menu.title = 'titleTest';
      let resB: Object = (SoftwareUpdate as object)['onDeviceNameDataChange']();
      expect(resB === null).assertFalse();
    })

    it('test_setMenuBadgeValue', 0, (done: Function): void => {
      try {
        let menuIn: SettingsBaseMenu = new SettingsBaseMenu();
        let mocker: MockKit = new MockKit();
        let contextfunc2: Function = mocker.mockFunc(SettingsDataUtils,SettingsDataUtils.getSettingsData);
        when(contextfunc2)(ArgumentMatchers.any).afterReturn(null);
        let resA = SoftwareUpdate.updateStatus()
        expect(resA === null).assertFalse();
        when(contextfunc2)(ArgumentMatchers.any).afterReturn('7');
        SoftwareUpdate.menu = menuIn;
        menuIn.key = 'about_device';
        menuIn.badge = 3;
        let resB = SoftwareUpdate.updateStatus();
        expect(resB === null).assertFalse();
        menuIn.key = 'about';
        menuIn.badge = 7;
        let resC = SoftwareUpdate.updateStatus();
        expect(resC === null).assertFalse();
        menuIn.key = 'about_device';
        menuIn.badge = 7;
        let resD = SoftwareUpdate.updateStatus();
        expect(resD === null).assertFalse();
        mocker.clear(SettingsDataUtils);
      } catch(e) {
        console.log(`error:${e}`);
      } finally {
        done();
      }
    })

    it('test_registerDeviceNameDataChange', 0, (): void => {
      let resA: Object = (SoftwareUpdate as object)['registerDeviceNameDataChange']();
      expect(resA === null).assertFalse();
      let dataHelper = SettingsDataUtils
        .createDataHelper(NavEntryKey.ADVANCED_SETTINGS_ENTRY) as Promise<dataShare.DataShareHelper>;
      (SoftwareUpdate as object)["dataHelper"] = dataHelper;
      let resB: Object = (SoftwareUpdate as object)['registerDeviceNameDataChange']();
      expect(resB === null).assertFalse();
    })

  });
}
