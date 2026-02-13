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

import { describe, it, expect, TestType } from '@ohos/hypium';
import { MenuGroup, SettingsBaseMenu } from '@ohos/settings.common';
import { ApMenu, ConnectedApBaseController } from '@ohos/settings.wifi';
import { ApMenuData } from '@ohos/settings.wifi/src/main/ets/model/WifiModel';

let menuData1: Partial<ApMenuData> = {
  ssid: "Netgear_2G",
  bssid: "00:11:22:33:44:55",
  bssidType: 1,
  level: 70,
  securityType: 2,
  config: {
    ssid: "Netgear_2G",
    bssid: "00:11:22:33:44:55",
    securityType: 2,
    isHiddenSsid: false,
    preSharedKey: 'share1'
  },
  supportedWifiCategory: 1,
  isHiLinkNetwork: false,
  scanResults: []
}
class ConnectedApBaseControllerSon extends ConnectedApBaseController {
  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  getConnectedApMenu(): SettingsBaseMenu | null {
    return null;
  }
}
export default function ConnectedApBaseControllerTest() {
  let menu: SettingsBaseMenu = new SettingsBaseMenu();
  let ConnectedApBase = new ConnectedApBaseControllerSon(menu);
  describe('ConnectedApBaseControllerTest', () => {
    it('test_onWifiStateChange', TestType.FUNCTION, () => {
      let resA = ConnectedApBase.onWifiStateChange(7);
      expect(resA === null).assertFalse();
      let resB = ConnectedApBase.onWifiStateChange(0);
      expect(resB === null).assertFalse();
    });

    it('test_onWifiConnectionChange', TestType.FUNCTION, () => {
      let resA = ConnectedApBase.onWifiConnectionChange(1);
      expect(resA === null).assertFalse();
      let resB = ConnectedApBase.onWifiConnectionChange(0);
      expect(resB === null).assertFalse();
      let resC = ConnectedApBase.onWifiConnectionChange(21);
      expect(resC === null).assertFalse();
    });

    it('test_onDataChange', TestType.FUNCTION, () => {
      let resA = ConnectedApBase.onDataChange('wifi_switch', 7);
      expect(resA === null).assertFalse();
      let resB = ConnectedApBase.onDataChange('wifi_list_group', 7);
      expect(resB === null).assertFalse();
      let resC = ConnectedApBase.onDataChange('wifi_window_list_group', 'refresh');
      expect(resC === null).assertFalse();
      let resD = ConnectedApBase.onDataChange('wifi', 9);
      expect(resD === null).assertFalse();
    });

    it('test_getLastLinkedInfoAndUpdate', TestType.FUNCTION, () => {
      ConnectedApBase.targetState = 1;
      let resA: Object = (ConnectedApBase as object)['getLastLinkedInfoAndUpdate']();
      expect(resA === null).assertFalse();
      ConnectedApBase.targetState = 7;
      let resB: Object = (ConnectedApBase as object)['getLastLinkedInfoAndUpdate']();
      expect(resB === null).assertFalse();
    });

    it('test_hideConnectedApChange', TestType.FUNCTION, () => {
      let resA: Object = (ConnectedApBase as object)['hideConnectedApChange']();
      expect(resA === null).assertFalse();
      menu = new ApMenu(menuData1);
      ConnectedApBase.menu = new MenuGroup();
      let resB: Object = (ConnectedApBase as object)['hideConnectedApChange']();
      expect(resB === null).assertFalse();
    });

    it('test_onConnectedApChange', TestType.FUNCTION, () => {
      let resA: Object = (ConnectedApBase as object)['onConnectedApChange']();
      expect(resA === null).assertFalse();
      (ConnectedApBase as object)["accessPoint"] = true;
      menu = new ApMenu(menuData1);
      ConnectedApBase.menu = new MenuGroup();
      let resB: Object = (ConnectedApBase as object)['onConnectedApChange']();
      expect(resB === null).assertFalse();
      (ConnectedApBase as object)["accessPoint"] = false;
      let resC: Object = (ConnectedApBase as object)['onConnectedApChange']();
      expect(resC === null).assertFalse();
    });

  });
}