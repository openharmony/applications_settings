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
import {
  BatteryLevelController,
  BatteryStatusController,
  BluetoothAddressController,
  IpAddressController,
  NearLinkMacController,
  PowerOnDurationController,
  WlanMacController
} from '@ohos/settings.aboutdevice/src/main/ets/controller/StatusInfoController';
import {
  BATTERY_STATUS_CHARGING,
  BATTERY_STATUS_FILLED
} from '@ohos/settings.common/src/main/ets/constant/BatteryConstant';
import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { NearLinkUtils } from '@ohos/settings.nearlink';
import { WifiUtils } from '@ohos/settings.wifi';

export default function StatusInfoControllerTest() {

  describe('StatusInfoControllerTest', (): void => {
    it('StatusInfoControllerTest_init_001', 0, (done: Function) => {
      try {
        let batteryStatusController = new BatteryStatusController();
        let compParam: CompCtrlParam = {
          compId: '123456', component: {
            id: 'componentId', url: 'pathUrl', type: PageType.PAGE_TYPE_STANDARD
          } as SettingPageModel
        };
        let result = batteryStatusController.init(compParam);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('StatusInfoControllerTest_updateBatteryStatusByEvent_002', 0, (done: Function) => {
      try {
        let batteryStatusController = new BatteryStatusController();
        (batteryStatusController as object)['updateBatteryStatusByEvent'](BATTERY_STATUS_CHARGING);
        (batteryStatusController as object)['updateBatteryStatusByEvent'](BATTERY_STATUS_FILLED);
        (batteryStatusController as object)['updateBatteryStatusByEvent'](5);
      } catch (e) {
      } finally {
        done()
      }
    });

    it('StatusInfoControllerTest_init_003', 0, (done: Function) => {
      try {
        let batteryLevelController = new BatteryLevelController();
        let compParam: CompCtrlParam = {
          compId: '123456', component: {
            id: 'componentId', url: 'pathUrl', type: PageType.PAGE_TYPE_STANDARD
          } as SettingPageModel
        };
        let result = batteryLevelController.init(compParam);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('StatusInfoControllerTest_init_004', 0, (done: Function) => {
      try {
        let ipAddressController = new IpAddressController();
        let compParam: CompCtrlParam = {
          compId: '123456', component: {
            id: 'componentId', url: 'pathUrl', type: PageType.PAGE_TYPE_STANDARD
          } as SettingPageModel
        };
        let result = ipAddressController.init(compParam);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('StatusInfoControllerTest_init_005', 0, (done: Function) => {
      try {
        let wlanMacController = new WlanMacController();
        let compParam: CompCtrlParam = {
          compId: '123456', component: {
            id: 'componentId', url: 'pathUrl', type: PageType.PAGE_TYPE_STANDARD
          } as SettingPageModel
        };
        let result = wlanMacController.init(compParam);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('StatusInfoControllerTest_getWifiState_006', 0, async  (done: Function) => {
      try {
        let wlanMacController = new WlanMacController();
        let result = wlanMacController.getWifiState(true);
        let mocker = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(WifiUtils, await WifiUtils.wifiLinkedInfo);
        when(mockfunc)(ArgumentMatchers.any).afterReturn('wifi');
        expect(result !== null).assertTrue();
        mocker.clear(WifiUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('StatusInfoControllerTest_getWifiState_007', 0, (done: Function) => {
      try {
        let wlanMacController = new WlanMacController();
        let result = wlanMacController.getWifiState(false);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('StatusInfoControllerTest_init_008', 0, (done: Function) => {
      try {
        let bluetoothAddressController = new BluetoothAddressController();
        let compParam: CompCtrlParam = {
          compId: '123456', component: {
            id: 'componentId', url: 'pathUrl', type: PageType.PAGE_TYPE_STANDARD
          } as SettingPageModel
        };
        let result = bluetoothAddressController.init(compParam);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('StatusInfoControllerTest_getBluetoothState_009', 0, async (done: Function) => {
      try {
        let bluetoothAddressController = new BluetoothAddressController();
        let result = await bluetoothAddressController.getBluetoothState(false);
        expect(result !== null).assertTrue();
        let result2 = await bluetoothAddressController.getBluetoothState(true);
        expect(result2 !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('StatusInfoControllerTest_init_010', 0, (done: Function) => {
      try {
        let nearLinkMacController = new NearLinkMacController();
        let compParam: CompCtrlParam = {
          compId: '123456', component: {
            id: 'componentId', url: 'pathUrl', type: PageType.PAGE_TYPE_STANDARD
          } as SettingPageModel
        };
        let result = nearLinkMacController.init(compParam);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('StatusInfoControllerTest_getNearLinkState_012', 0, (done: Function) => {
      try {
        let mocker = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(NearLinkUtils, NearLinkUtils.isOn);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
        (NearLinkMacController as object)['getNearLinkState']();

        let mockfunc2: Function =
          mocker.mockFunc(NearLinkUtils, NearLinkUtils.isOn);
        when(mockfunc2)(ArgumentMatchers.any).afterReturn(false);
        (NearLinkMacController as object)['getNearLinkState']();
        mocker.clear(NearLinkUtils);
      } catch (e) {
      } finally {
        done()
      }
    });

    it('StatusInfoControllerTest_init_013', 0, (done: Function) => {
      try {
        let powerOnDurationController = new PowerOnDurationController();
        let compParam: CompCtrlParam = {
          compId: '123456', component: {
            id: 'componentId', url: 'pathUrl', type: PageType.PAGE_TYPE_STANDARD
          } as SettingPageModel
        };
        let result = powerOnDurationController.init(compParam);
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('StatusInfoControllerTest_batteryStatusState_014', 0, (done: Function) => {
      try {
        (BatteryStatusController as object)['batteryStatusState'](() =>{});
      } catch (e) {
      } finally {
        done()
      }
    });
  })
}

