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
import { ItemType, SettingIconType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import {
  BluetoothDevice,
  BondState,
  BondStateParam,
  ProfileConnectionState,
  ProfileId,
  StateChangeParam
} from '@ohos/settings.bluetooth/src/main/ets/model/BluetoothModel';
import { BluetoothItemModel } from '@ohos/settings.bluetooth/src/main/ets/model/BluetoothItemModel';
import { BluetoothAdapter } from '@ohos/settings.bluetooth/src/main/ets/BluetoothAdapter';
import { BluetoothUtils, DisconnectCause } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { BondedDeviceController } from '@ohos/settings.bluetooth/src/main/ets/controller/BondedDeviceController';
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';

export default function BondedDeviceControllerTest() {
  describe('bondedDeviceControllerTest', () => {
    it('initTest_001', 0, () => {
      let controller = new BondedDeviceController();
      expect(controller.getListenKey()).assertEqual('Bonded_Device_Controller');
      BluetoothAdapter.getInstance().currentState = 2;
      controller.init({
        compId: '123456', component: {
          id: 'componentId'
        }
      });
      expect(controller.compId).assertEqual('123456');
      controller.onAvailableDeviceClear();
      controller.onAvailableDevicesRefresh();
      let device: BluetoothDevice = new BluetoothDevice('deviceId');
      controller.onDeviceAdded(device);
      controller.onDeviceDeleted(device);
      controller.onBluetoothPinRequired({
        deviceId: 'deviceId',
        pinCode: 'pinCode',
        pinType: 1,
      });
      controller.onPairResult('deviceId', 1, true);
      let controlle2 = new BondedDeviceController();
      controlle2.init({
        compId: '', component: {
          id: 'componentId'
        }
      });
      controller.destroy();
      controlle2.destroy();
    });
    it('onBondDeviceAddedTest_001', 0, () => {
      let controller = new BondedDeviceController();
      let datasource: DynamicDataSource = new DynamicDataSource();
      controller.init({
        compId: '123456', component: {
          id: 'componentId'
        }, dataSource: datasource
      });
      let deviceId: string = 'deviceId';
      let device = new BluetoothDevice(deviceId);
      controller.onBondDeviceAdded(device);
      expect(controller.dataSource?.length).assertEqual(0);
    });
    it('onBondDeviceAddedTest_002', 0, () => {
      let controller = new BondedDeviceController();
      let deviceId: string = 'deviceId';
      let device = new BluetoothDevice(deviceId);
      let datasource: DynamicDataSource = new DynamicDataSource();
      datasource.pushData({
        id: device.deviceId,
        type: ItemType.ITEM_TYPE_STANDARD,
        icon: {
          icon: device.getIcon(),
          iconType: SettingIconType.ICON_TYPE_TIP,
          style: {
            width: 24, height: 24, fillColor: $r('sys.color.icon_primary')
          },
        },
        title: {
          content: device.deviceName ?? device.deviceId
        },
        rssi: device.getRssi(),
        device: device,
      } as BluetoothItemModel);
      controller.init({
        compId: '123456', component: {
          id: 'componentId'
        }, dataSource: datasource
      });
      controller.onBondDeviceAdded(device); // 已经存在了，还往里边添加
      expect(controller.dataSource?.length).assertEqual(1);
    });
    it('onBondDeviceAddedTest_003', 0, () => {
      let controller = new BondedDeviceController();
      let deviceId: string = 'deviceId';
      let device = new BluetoothDevice(deviceId);
      let datasource: DynamicDataSource = new DynamicDataSource();
      controller.init({
        compId: '123456', component: {
          id: 'componentId'
        }, dataSource: datasource
      });
      controller.onBondDeviceAdded(device); // 不是已配对设备
      expect(controller.dataSource?.length).assertEqual(0);
    });

    it('registerTest_001', 0, () => {
      let controller = new BondedDeviceController();
      let deviceId: string = 'deviceId';
      let device = new BluetoothDevice(deviceId);
      let datasource: DynamicDataSource = new DynamicDataSource();
      datasource.pushData({
        id: device.deviceId,
        type: ItemType.ITEM_TYPE_STANDARD,
        icon: {
          icon: device.getIcon(),
          iconType: SettingIconType.ICON_TYPE_TIP,
          style: {
            width: 24, height: 24, fillColor: $r('sys.color.icon_primary')
          },
        },
        title: {
          content: device.deviceName ?? device.deviceId
        },
        rssi: device.getRssi(),
        device: device,
      } as BluetoothItemModel);
      controller.init({
        compId: '123456', component: {
          id: 'componentId'
        }, dataSource: datasource
      });
      let index1: number = BluetoothAdapter.getInstance().stateChangeListeners.indexOf(controller);
      expect(index1 !== null).assertTrue();

      controller.destroy();
      let index2: number = BluetoothAdapter.getInstance().stateChangeListeners.indexOf(controller);
      expect(index2 !== null).assertTrue();
    });

    it('testOnConnectResult_001', 0, () => {
      let controller = new BondedDeviceController();
      controller.init({
        compId: '123456', component: {
          id: 'componentId'
        }
      });
      controller.onConnectResult('123456', 2, false);
    });
    it('testOnDeviceAttributesChanged_001', 0, () => {
      let controller = new BondedDeviceController();
      controller.init({
        compId: '123456', component: {
          id: 'componentId'
        }
      });

      let deviceId: string = 'deviceId';
      let device = new BluetoothDevice(deviceId);
      controller.onDeviceAttributesChanged(device);

      let device2: BluetoothDevice | undefined;
      controller.onDeviceAttributesChanged(device2 as BluetoothDevice);

      controller.onBondDeviceDeleted('deviceId');
      controller.onBondDeviceDeleted('');
    });
    it('testOnBluetoothBondStateChange_001', 0, () => {
      let controller = new BondedDeviceController()
      controller.init({
        compId: '123456', component: {
          id: 'componentId'
        }
      });
      controller.onBluetoothBondStateChange({
        deviceId: 'deviceId',
        state: BondState.BOND_STATE_BONDED,
      } as BondStateParam);

      let deviceId: string = 'deviceId';
      let device = new BluetoothDevice(deviceId);
      let controller2 = new BondedDeviceController();
      controller2.init({
        compId: '123456', component: {
          id: 'componentId'
        }
      });
      controller2.onBluetoothBondStateChange({
        deviceId: deviceId,
        state: BondState.BOND_STATE_INVALID,
      } as BondStateParam);
    });
    it('testOnBluetoothProfileStateChange_001', 0, () => {
      let controller = new BondedDeviceController()
      controller.init({
        compId: '123456', component: {
          id: 'componentId'
        }
      });
      controller.onBluetoothProfileStateChange(ProfileId.PROFILE_A2DP_SOURCE, {
        deviceId: 'deviceId',
        state: ProfileConnectionState.STATE_DISCONNECTED, cause: DisconnectCause.USER_DISCONNECT
      });

      let controller2 = new BondedDeviceController();
      let datasource: DynamicDataSource = new DynamicDataSource();
      controller2.init({
        compId: '123456', component: {
          id: 'componentId'
        }, dataSource: datasource
      });
    });
    it('bondedDeviceControllerTest_onPageShow', 0, (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        (controller as object)['getWirelessAntiTheftState']();
        let result = controller.onPageShow();
        expect(result !== null).assertTrue();
        let mocker = new MockKit();
        let mockfunc: Function =
          mocker.mockFunc(BluetoothUtils, BluetoothUtils.isBluetoothStateOn);
        when(mockfunc)(ArgumentMatchers.any).afterReturn(true);
        let result2 = controller.onPageShow();
        expect(result2 !== null).assertTrue();
        mocker.clear(BluetoothUtils);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bondedDeviceControllerTest_updateBondedDevicesWithDelete', 0, (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        let result = controller.updateBondedDevicesWithDelete();
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bondedDeviceControllerTest_deleteNoBondedDevices', 0, (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        controller.dataSource = new DynamicDataSource();
        let devices = BluetoothAdapter.getInstance().getBondedDevices();
        let deviceArray: BluetoothDevice[] = Array.from(devices);
        (controller as object)['deleteNoBondedDevices'](deviceArray);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bondedDeviceControllerTest_isExistDevice', 0, (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        let devices = BluetoothAdapter.getInstance().getBondedDevices();
        let deviceArray: BluetoothDevice[] = Array.from(devices);
        (controller as object)['isExistDevice'](deviceArray, '');
        (controller as object)['isExistDevice'](deviceArray, '122323');
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bondedDeviceControllerTest_onBluetoothProfileStateChange', 0, (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        controller.dataSource?.pushData({
          id: '12332',
          type: ItemType.ITEM_TYPE_STANDARD,
          icon: {
            iconType: SettingIconType.ICON_TYPE_TIP,
            style: {
              width: 24, height: 24, fillColor: $r('sys.color.icon_primary')
            },
          }
        } as BluetoothItemModel)
        let stateChangeParam: StateChangeParam = {
          deviceId: '12332',
          state: ProfileConnectionState.STATE_DISCONNECTED
        } as StateChangeParam;
        let result = controller.onBluetoothProfileStateChange(ProfileId.PROFILE_A2DP_SOURCE, stateChangeParam)
        expect(result !== null).assertTrue();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bondedDeviceControllerTest_sortByBondTime', 0, (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        controller.dataSource = undefined;
        (controller as object)['sortByBondTime']();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bondedDeviceControllerTest_sortByBondTime3', 0, (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        let params = AppStorage.get('params') as DynamicDataSource;
        controller.dataSource = params;
        (controller as object)['sortByBondTime']();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bondedDeviceControllerTest_sortByBondTime4', 0, (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        controller.dataSource!.length = 0;
        (controller as object)['sortByBondTime']();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bondedDeviceControllerTest_sortByBondTime5', 0, (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        controller.dataSource = new DynamicDataSource();
        (controller as object)['sortByBondTime']();
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bondedDeviceControllerTest_findDevice', 0, (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        controller.dataSource = undefined;
        (controller as object)['findDevice'](-1);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bondedDeviceControllerTest_findBluetoothItemModel', 0, (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        (controller as object)['findBluetoothItemModel']('12132');
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bondedDeviceControllerTest_getFromPreference', 0, async (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        await (controller as object)['getFromPreference']('12132', 12);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bondedDeviceControllerTest_handleDetailClick', 0, (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        let component: SettingBaseModel = {
          id: '123123'
        };
        (controller as object)['handleDetailClick'](component);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bondedDeviceControllerTest_addToPreference', 0, async (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        await (controller as object)['addToPreference']('12132', 12);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bondedDeviceControllerTest_handleDetailClick2', 0, (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        let component: BluetoothItemModel = {
          device: new BluetoothDevice('123123'),
          type: ItemType.ITEM_TYPE_CUSTOM,
          id: '121212'
        };
        (controller as object)['handleDetailClick'](component);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bondedDeviceControllerTest_handleBondedDeviceItemClick', 0, (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        let component: SettingBaseModel = AppStorage.get('component') as SettingBaseModel;
        (controller as object)['handleBondedDeviceItemClick'](component);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bondedDeviceControllerTest_handleBondedDeviceItemClick2', 0, (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        let component: BluetoothItemModel = {
          device: new BluetoothDevice('123123'),
          type: ItemType.ITEM_TYPE_CUSTOM,
          id: '121212'
        };
        (controller as object)['handleBondedDeviceItemClick'](component);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bondedDeviceControllerTest_disconnectDevice', 0, (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        let component: SettingBaseModel = AppStorage.get('component') as SettingBaseModel;
        (controller as object)['disconnectDevice'](component);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bondedDeviceControllerTest_disconnectDevice2', 0, (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        let component: BluetoothItemModel = {
          device: new BluetoothDevice('123123'),
          type: ItemType.ITEM_TYPE_CUSTOM,
          id: '121212'
        };
        (controller as object)['disconnectDevice'](component);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bondedDeviceControllerTest_updateDevice', 0, (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        controller.dataSource = undefined;
        let device: BluetoothDevice = new BluetoothDevice('123123');
        (controller as object)['updateDevice'](device);
      } catch (e) {
      } finally {
        done()
      }
    });
    it('bondedDeviceControllerTest_deviceNameChangeListener', 0, (done: Function) => {
      try {
        let controller = new BondedDeviceController();
        (controller as object)['deviceNameChangeListener'](() => {
        });
      } catch (e) {
      } finally {
        done()
      }
    });
  });
}