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

import { afterAll, afterEach,
  ArgumentMatchers,
  beforeAll, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';
import { SettingsBaseMenu } from '@ohos/settings.common';
import { extraType } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { WifiVisibleController } from '@ohos/settings.wifi/src/main/ets/controller/WifiVisibleController';


export default function wifiVisibleControllerTest() {
  let menu: SettingsBaseMenu = new SettingsBaseMenu();
  let wifiVisibleController = new WifiVisibleController(menu);
  describe('wifiVisibleControllerTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('WifiVisibleControllerTest_constructor', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu();
      menu.key = 'wifi_ap_visibility';
      menu.extra = {
        isCurrentVisible: true,
        supportEapMethod: [1, 2],
        listenMenuKeyArray: ['wifi_security_type_options', 'wifi_security_type_eap'],
      } as extraType;
      let controller: WifiVisibleController = new WifiVisibleController(menu);
      expect(controller.supportEapMethod.length).assertEqual(2);
      expect(controller.isCurrentVisible).assertEqual(true);
      expect(controller.listenMenuKeyArray.length).assertEqual(2);
    });
    it('WifiVisibleControllerTest_constructor_null', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu();
      menu.key = 'wifi_ap_visibility';
      let controller: WifiVisibleController = new WifiVisibleController(menu);
      expect(controller.supportEapMethod.length).assertEqual(0);
      expect(controller.isCurrentVisible).assertEqual(true);
      expect(controller.listenMenuKeyArray.length).assertEqual(0);
    });

    it('WifiVisibleControllerTest_aboutToAppear', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu();
      let wifiVisibleController = new WifiVisibleController(menu);
      wifiVisibleController.aboutToAppear();
      expect(wifiVisibleController).not().assertNull();
    })

    it('WifiVisibleControllerTest_aboutToDisappear', 0, () => {
      let wifiVisibleController = new WifiVisibleController(new SettingsBaseMenu());
      wifiVisibleController.aboutToDisappear();
      expect(wifiVisibleController).not().assertNull();
    })

    it('wifiVisibleControllerTest_registerDataChange', 0, () => {
      let wifiVisibleController = new WifiVisibleController(new SettingsBaseMenu());
      wifiVisibleController.registerDataChange();
      expect(wifiVisibleController).not().assertNull();
    });

    it('test_setCASummaryVisible', 0, () => {
      let resA: Object = (wifiVisibleController as object)['setCASummaryVisible']('wifi_eap_method', 1000);
      expect(resA === null).assertFalse();
      let resB: Object = (wifiVisibleController as object)['setCASummaryVisible']('wifi_eap_ca_certificate', 1000);
      expect(resB === null).assertFalse();
      let resC: Object = (wifiVisibleController as object)['setCASummaryVisible']('wifi_eap', 1000);
      expect(resC === null).assertFalse();
    });

    it('test_setAllInputVisible', 0, () => {
      let resA: Object = (wifiVisibleController as object)['setAllInputVisible']('wifi_eap_method', 1000);
      expect(resA === null).assertFalse();
      let resB: Object = (wifiVisibleController as object)['setAllInputVisible']('wifi_eap_ca_certificate', 1000);
      expect(resB === null).assertFalse();
      let resC: Object = (wifiVisibleController as object)['setAllInputVisible']('wifi_eap', 1000);
      expect(resC === null).assertFalse();
    });

    it('test_updateAllInputMenus', 0, () => {
      wifiVisibleController.identityVisible = true;
      let resA: Object = (wifiVisibleController as object)['updateAllInputMenus']();
      expect(resA === null).assertFalse();
      wifiVisibleController.identityVisible = false;
      wifiVisibleController.anonymousVisible = true;
      let resB: Object = (wifiVisibleController as object)['updateAllInputMenus']();
      expect(resB === null).assertFalse();
      wifiVisibleController.anonymousVisible = false;
      wifiVisibleController.domainVisible= true;
      wifiVisibleController.caVisible = true;
      let resC: Object = (wifiVisibleController as object)['updateAllInputMenus']();
      expect(resC === null).assertFalse();
      wifiVisibleController.domainVisible= false;
      wifiVisibleController.caVisible = false;
      let resD: Object = (wifiVisibleController as object)['updateAllInputMenus']();
      expect(resD === null).assertFalse();
    });

    it('test_onDataChange', 0, () => {
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(wifiVisibleController, wifiVisibleController.getLogKey);
      when(mockfunc)(ArgumentMatchers.any).afterReturn('wifi_eap_ca_certificate_summary');
      let resA = wifiVisibleController.onDataChange('', 1000);
      expect(resA === null).assertFalse();
      when(mockfunc)(ArgumentMatchers.any).afterReturn('wifi_eap_input_menu_group');
      let resB = wifiVisibleController.onDataChange('', 1000);
      expect(resB === null).assertFalse();
      when(mockfunc)(ArgumentMatchers.any).afterReturn('wifi_eap');
      let resC = wifiVisibleController.onDataChange('key_security_selector', 1000);
      expect(resC === null).assertFalse();
      let resD = wifiVisibleController.onDataChange('key_security_selector', 0);
      expect(resD === null).assertFalse();
      mocker.clear(wifiVisibleController);
    });

  })
}

