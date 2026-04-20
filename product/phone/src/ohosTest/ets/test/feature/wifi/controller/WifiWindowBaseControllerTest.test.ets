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
import { ApMenu, WifiWindowBaseController } from '@ohos/settings.wifi';
import { AccessPoint, ApMenuData, WifiScanResult } from '@ohos/settings.wifi/src/main/ets/model/WifiModel';


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
class WifiWindowBaseControllerSon extends WifiWindowBaseController {
  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  public registerDataChange(): void {
    return super.registerDataChange();
  }

  public onPageShow(): void {
    return super.onPageShow();
  }

  public getScanInternal(): number {
    throw new Error('Method not implemented.');
  }

  public getScanLoadingInternal(): number {
    throw new Error('Method not implemented.');
  }

  public createApMenu(item: Partial<ApMenuData>): ApMenu {
    throw new Error('Method not implemented.');
  }

  getConnectedApMenu(): SettingsBaseMenu | null {
    return null;
  }
}
export default function WifiWindowBaseControllerTest() {
  let menu: SettingsBaseMenu = new SettingsBaseMenu();
  let wifiWindowBase = new WifiWindowBaseControllerSon(menu);
  describe('WifiWindowBaseControllerTest', () => {
    it('test_onWifiConnectionChange', TestType.FUNCTION, () => {
      (wifiWindowBase as object)["isRegister"] = false;
      let resA = wifiWindowBase.onWifiConnectionChange(7);
      expect(resA === null).assertFalse();
      (wifiWindowBase as object)["isRegister"] = true;
      let resB = wifiWindowBase.onWifiConnectionChange(1);
      expect(resB === null).assertFalse();
      let resC = wifiWindowBase.onWifiConnectionChange(7);
      expect(resC === null).assertFalse();
    });

    it('test_registerDataChange', TestType.FUNCTION, () => {
      wifiWindowBase.timerId = 1000000;
      let resA = wifiWindowBase.registerDataChange();
      expect(resA === null).assertFalse();
      wifiWindowBase.timerId = null;
      let resB = wifiWindowBase.registerDataChange();
      expect(resB === null).assertFalse();
    });

    it('test_onApMenusChanged', TestType.FUNCTION, () => {
      let data: Array<ApMenu> = [];
      data.push(new ApMenu(menuData1));
      let par = new WifiScanResult();
      wifiWindowBase.accessPoint = new AccessPoint([par]);
      let resA = wifiWindowBase.onApMenusChanged(data);
      expect(resA === null).assertFalse();
      menu = new ApMenu(menuData1);
      wifiWindowBase.menu = new MenuGroup();
    });

    it('test_getLastLinkedInfoAndUpdate', TestType.FUNCTION, () => {
      let resA: Object = (wifiWindowBase as object)['getLastLinkedInfoAndUpdate']();
      expect(resA === null).assertFalse();
    });

    it('test_updateConnectedAp', TestType.FUNCTION, async () => {
      let resA: Object = await (wifiWindowBase as object)['updateConnectedAp']();
      expect(resA === null).assertFalse();
    });

    it('test_hideConnectedApChange', TestType.FUNCTION, () => {
      let par = new WifiScanResult();
      wifiWindowBase.accessPoint = new AccessPoint([par]);
      let resA: Object = (wifiWindowBase as object)['hideConnectedApChange'](false);
      expect(resA === null).assertFalse();
      wifiWindowBase.accessPoint = null;
      let resB: Object = (wifiWindowBase as object)['hideConnectedApChange'](false);
      expect(resB === null).assertFalse();
    });

  });
}