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

import { describe, it, expect, MockKit, when,
  ArgumentMatchers,
  TestType} from '@ohos/hypium'
import { CommonUtils, MenuGroup, SettingsBaseMenu, Timer } from '@ohos/settings.common'
import { ApMenu, ApMenuData, WifiState } from '@ohos/settings.wifi/src/main/ets/model/WifiModel'
import { WifiListBaseController, WifiUtils } from '@ohos/settings.wifi'
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
class WifiListBaseControllerSon extends WifiListBaseController {
  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  getScanInternal(): number {
    return 7;
  }

  getScanLoadingInternal(): number {
    return 7;
  }

  createApMenu(item: Partial<ApMenuData>): ApMenu {
    return new ApMenu(menuData1);
  }
}
export default function WifiListBaseControllerOuterTest() {
  let menu: SettingsBaseMenu = new SettingsBaseMenu();
  let wifiListBase = new WifiListBaseControllerSon(menu);
  describe('WifiListBaseControllerOuterTest', () => {
    it('test_onWifiStateChange', TestType.FUNCTION, () => {
      wifiListBase.targetState = WifiState.INACTIVE;
      wifiListBase.onWifiStateChange(WifiState.ACTIVE);
      wifiListBase.onWifiStateChange(WifiState.INACTIVE);
      wifiListBase.targetState = WifiState.ACTIVE;
      wifiListBase.onWifiStateChange(WifiState.ACTIVE);
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(WifiUtils, WifiUtils.isWifiActive);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
      wifiListBase.onWifiStateChange(WifiState.ACTIVE);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
      wifiListBase.onWifiStateChange(WifiState.ACTIVE);
      wifiListBase.targetState = WifiState.ACTIVATING;
      wifiListBase.onWifiStateChange(WifiState.ACTIVATING);
      mocker.clear(WifiUtils);
    });

    it('test_onSwitchStateChange', TestType.FUNCTION, () => {
      let resA = wifiListBase.onSwitchStateChange(7);
      expect(resA === null).assertFalse();
      let resB = wifiListBase.onSwitchStateChange(0);
      expect(resB === null).assertFalse();
      let resC = wifiListBase.onWifiStateChange(1);
      expect(resC === null).assertFalse();
    });

    it('test_onDataChange', TestType.FUNCTION, () => {
      let resA = wifiListBase.onDataChange('wifi_switch', 7);
      expect(resA === null).assertFalse();
      let resB = wifiListBase.onDataChange('data_change_key_4_state', 7);
      expect(resB === null).assertFalse();
      let resC = wifiListBase.onDataChange('wifi_connected_ap_group', 'refresh');
      expect(resC === null).assertFalse();
      let resD = wifiListBase.onDataChange('wifi', 9);
      expect(resD === null).assertFalse();
    });

    it('test_aboutToAppear', TestType.FUNCTION, () => {
      let resA = wifiListBase.aboutToAppear();
      expect(resA === null).assertFalse();
    });

    it('test_aboutToDisappear', TestType.FUNCTION, () => {
      let mocker: MockKit = new MockKit();
      let mockfunc: Function = mocker.mockFunc(CommonUtils, CommonUtils.isPageExist);
      when(mockfunc)(ArgumentMatchers.any).afterReturn(false);
      let resA = wifiListBase.aboutToDisappear();
      expect(resA === null).assertFalse();
      when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
      let resB = wifiListBase.aboutToDisappear();
      expect(resB === null).assertFalse();
      mocker.clear(CommonUtils);
    });

    it('test_startWifiTimerAndTracker', TestType.FUNCTION, () => {
      wifiListBase.isStarted = true;
      let resA: Object = (wifiListBase as object)['startWifiTimerAndTracker']();
      expect(resA === null).assertFalse();
      wifiListBase.isStarted = false;
      let resB: Object = (wifiListBase as object)['startWifiTimerAndTracker']();
      expect(resB === null).assertFalse();
    });

    it('test_stopWifiTimerAndTracker', TestType.FUNCTION, () => {
      wifiListBase.isStarted = false;
      let resA: Object = (wifiListBase as object)['stopWifiTimerAndTracker'](false);
      expect(resA === null).assertFalse();
      wifiListBase.isStarted = true;
      let resB: Object = (wifiListBase as object)['stopWifiTimerAndTracker'](false);
      expect(resB === null).assertFalse();
    });

    it('test_stopTimer', TestType.FUNCTION, () => {
      let timer: Timer | null = null;
      wifiListBase.timer = timer;
      let resA = wifiListBase.stopTimer();
      expect(resA === null).assertFalse();
      timer = new Timer(10000, () => {});
      wifiListBase.timer = timer;
      let resB = wifiListBase.stopTimer();
      expect(resB === null).assertFalse();
    });

    it('test_getTimer', TestType.FUNCTION, () => {
      let timer: Timer | null = new Timer(10000, () => {});
      wifiListBase.timer = timer;
      let resA: Object = (wifiListBase as object)['getTimer']();
      expect(resA === null).assertFalse();
      timer = null;
      wifiListBase.timer = timer;
      let resB: Object = (wifiListBase as object)['getTimer']();
      expect(resB === null).assertFalse();
    });

    it('test_scanOnce', TestType.FUNCTION, () => {
      wifiListBase.isStarted = false;
      let resA: Object = (wifiListBase as object)['scanOnce']();
      expect(resA === null).assertFalse();
      wifiListBase.isStarted = true;
      let resB: Object = (wifiListBase as object)['scanOnce']();
      expect(resB === null).assertFalse();
    });

    it('test_startLoading', TestType.FUNCTION, () => {
      wifiListBase.loadingTaskId = null;
      wifiListBase.targetState = 1;
      let resA: Object = (wifiListBase as object)['startLoading']();
      expect(resA === null).assertFalse();
      wifiListBase.targetState = 0;
      let resB: Object = (wifiListBase as object)['startLoading']();
      expect(resB === null).assertFalse();
      wifiListBase.loadingTaskId = 7;
      let resC: Object = (wifiListBase as object)['startLoading']();
      expect(resC === null).assertFalse();
    });

    it('test_hideApList', TestType.FUNCTION, () => {
      let resA = wifiListBase.hideApList();
      expect(resA === null).assertFalse();
      wifiListBase.menu = new MenuGroup();
      let resB = wifiListBase.hideApList();
      expect(resB === null).assertFalse();
    });

    it('test_removeLinkedApMenu', TestType.FUNCTION, () => {
      let resA = wifiListBase.removeLinkedApMenu('Netgear_2G');
      expect(resA === null).assertFalse();
      wifiListBase.menu = new MenuGroup();
      let resB = wifiListBase.removeLinkedApMenu('hh');
      expect(resB === null).assertFalse();
    });

    it('test_onApMenuChanged', TestType.FUNCTION, () => {
      let menu: ApMenu = AppStorage.get<ApMenu>('null') as ApMenu;
      let resA = wifiListBase.onApMenuChanged(menu);
      expect(resA === null).assertFalse();
      menu = new ApMenu(menuData1);
      let resB = wifiListBase.onApMenuChanged(menu);
      expect(resB === null).assertFalse();
    });

    it('test_onApMenusChanged', TestType.FUNCTION, () => {
      let baseMenu: SettingsBaseMenu = new SettingsBaseMenu();
      wifiListBase = new WifiListBaseControllerSon(baseMenu);
      let menu: ApMenu = AppStorage.get<ApMenu>('null') as ApMenu;
      let arr: Array<ApMenu> = [];
      let resA = wifiListBase.onApMenusChanged(arr);
      expect(resA === null).assertFalse();
      menu = new ApMenu(menuData1);
      wifiListBase.menu = new MenuGroup();
      let resB = wifiListBase.onApMenusChanged(arr);
      expect(resB === null).assertFalse();
    });
  })
}
