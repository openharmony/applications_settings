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

import { afterAll, beforeAll, describe, expect, it } from '@ohos/hypium';
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import { ItemType, SettingIconType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { BluetoothDevice, BondState, BondStateParam } from '@ohos/settings.bluetooth/src/main/ets/model/BluetoothModel';
import { BluetoothAdapter } from '@ohos/settings.bluetooth/src/main/ets/BluetoothAdapter';
import { BluetoothItemModel } from '@ohos/settings.bluetooth/src/main/ets/model/BluetoothItemModel';
import { AvailableDeviceController } from '@ohos/settings.bluetooth/src/main/ets/controller/AvailableDeviceController';

export default function availableDeviceControllerTest() {
  describe('availableDeviceControllerTest', () => {

    beforeAll(() => {
    });

    afterAll(() => {
    });

    testInit_001();
    testOnDeviceAdded_001();
    testOnDeviceAdded_002();
    testOnAvailableDevicesRefresh_001();
    testOnAvailableDevicesRefresh_002();
    testOnAvailableDeviceClear_001();
    testOnChangeLoadingStatus_001();
    testOnClick_001();
    testOnDeviceAttributesChanged_001();
    testOnBluetoothBondStateChange_001();
    testOnRemoveSummary_001();
    testOnPairResult_001();
    testOnBluetoothStateChange_001();
  });
}

function testInit_001(): void {
  it('initTest_001', 0, () => {
    let controller = new AvailableDeviceController()
    expect(controller.getListenKey()).assertEqual('Available_Device_Controller');
    controller.init({compId: '', component: { id: 'componentId'}});

    BluetoothAdapter.getInstance().currentState = 2;
    controller.init({compId: '123456', component: { id: 'componentId'}});
    expect(controller.compId).assertEqual('123456');
    controller.onBluetoothPinRequired({
      deviceId: 'deviceId',
      pinCode: 'pinCode',
      pinType: 0,
    });
    controller.destroy();
  });
}

function testOnDeviceAdded_001(): void {
  it('onDeviceAddedTest_001', 0, () => {
    let controller = new AvailableDeviceController();
    let datasource: OrderedDataSource = new OrderedDataSource();
    controller.init({compId: '123456', component: { id: 'componentId'}, dataSource: datasource });
    let deviceId: string = 'deviceId';
    let device = new BluetoothDevice(deviceId);
    BluetoothAdapter.getInstance().setBondedDevice(deviceId, device);
    controller.onDeviceAdded(device);
    expect(controller.dataSource?.length).assertEqual(0);
  });
}

function testOnDeviceAdded_002(): void {
  it('onDeviceAddedTest_002', 0, () => {
    let controller = new AvailableDeviceController();
    let deviceId: string = 'deviceId';
    let device = new BluetoothDevice(deviceId);
    let datasource: OrderedDataSource = new OrderedDataSource();
    datasource.pushData({
      id: device.deviceId,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: {
        icon: device.getIcon(),
        iconType: SettingIconType.ICON_TYPE_TIP,
        style: { width: 24, height: 24, fillColor: $r('sys.color.icon_primary') },
      },
      title: { content: device.deviceName ?? device.deviceId },
      rssi: device.getRssi(),
      device: device,
    } as BluetoothItemModel);
    controller.init({compId: '123456', component: { id: 'componentId'}, dataSource: datasource });
    controller.onDeviceAdded(device);
    expect(controller.dataSource?.length).assertEqual(1);
  });
}

function testOnAvailableDevicesRefresh_001(): void {
  it('onAvailableDevicesRefreshTest_001', 0, () => {
    let controller = new AvailableDeviceController();
    let deviceId: string = 'deviceId';
    let device = new BluetoothDevice(deviceId);
    let datasource: OrderedDataSource = new OrderedDataSource();
    datasource.pushData({
      id: device.deviceId,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: {
        icon: device.getIcon(),
        iconType: SettingIconType.ICON_TYPE_TIP,
        style: { width: 24, height: 24, fillColor: $r('sys.color.icon_primary') },
      },
      title: { content: device.deviceName ?? device.deviceId },
      rssi: device.getRssi(),
      device: device,
    } as BluetoothItemModel);
    controller.init({compId: '123456', component: { id: 'componentId'}, dataSource: datasource });

    controller.onAvailableDevicesRefresh();
    expect(controller.dataSource?.length).assertEqual(1);
  });
}

function testOnAvailableDevicesRefresh_002(): void {
  it('onAvailableDevicesRefreshTest_002', 0, () => {
    let controller = new AvailableDeviceController();
    controller.init({compId: '123456', component: { id: 'componentId'} });

    controller.onAvailableDevicesRefresh();
    expect(controller.dataSource?.length).assertUndefined();
  });
}

function testOnAvailableDeviceClear_001(): void {
  it('onAvailableDeviceClearTest_001', 0, () => {
    let controller = new AvailableDeviceController();
    let deviceId: string = 'deviceId';
    let device = new BluetoothDevice(deviceId);
    let datasource: OrderedDataSource = new OrderedDataSource();
    datasource.pushData({
      id: device.deviceId,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: {
        icon: device.getIcon(),
        iconType: SettingIconType.ICON_TYPE_TIP,
        style: { width: 24, height: 24, fillColor: $r('sys.color.icon_primary') },
      },
      title: { content: device.deviceName ?? device.deviceId },
      rssi: device.getRssi(),
      device: device,
    } as BluetoothItemModel);
    controller.init({compId: '123456', component: { id: 'componentId'}, dataSource: datasource });

    controller.onAvailableDeviceClear();
    expect(controller.dataSource?.length).assertEqual(0);
  });
}

function testOnChangeLoadingStatus_001(): void {
  it('onChangeLoadingStatusTest_001', 0, () => {
    let controller = new AvailableDeviceController();
    controller.init({compId: '123456', component: { id: 'componentId'} });
    controller.isScanLoadingShow = true;
    controller.onChangeLoadingStatus(false);
    expect(controller.isScanLoadingShow).assertFalse();
  });
}

function testOnClick_001(): void {
  it('testOnClick_001', 0, () => {
    let controller = new AvailableDeviceController();
    controller.init({compId: '123456', component: { id: 'componentId'}});
    let deviceId: string = 'deviceId';
    let device = new BluetoothDevice(deviceId);
    controller.onClick({
      id: device.deviceId,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: {
        icon: device.getIcon(),
        iconType: SettingIconType.ICON_TYPE_TIP,
        style: { width: 24, height: 24, fillColor: $r('sys.color.icon_primary') },
      },
      title: { content: device.deviceName ?? device.deviceId },
      rssi: device.getRssi(),
      device: device,
    } as BluetoothItemModel);
  });
}

function testOnDeviceAttributesChanged_001(): void {
  it('testOnDeviceAttributesChanged_001', 0, () => {
    let controller = new AvailableDeviceController();
    controller.init({compId: '123456', component: {id: 'componentId'}});
    let deviceId: string = 'deviceId';
    let device = new BluetoothDevice(deviceId);
    controller.onDeviceAttributesChanged(device);
    controller.onDeviceDeleted(device);
  });
}

function testOnBluetoothBondStateChange_001(): void {
  it('testOnBluetoothBondStateChange_001', 0, () => {
    let controller = new AvailableDeviceController()
    controller.init({compId: '123456', component: { id: 'componentId'}});
    controller.onBluetoothBondStateChange({
      deviceId: 'deviceId',
      state: BondState.BOND_STATE_BONDED,
    } as BondStateParam);

    let deviceId: string = 'deviceId';
    let device = new BluetoothDevice(deviceId);
    let controller2 = new AvailableDeviceController();
    let datasource: OrderedDataSource = new OrderedDataSource();
    datasource.pushData({
      id: device.deviceId,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: {
        icon: device.getIcon(),
        iconType: SettingIconType.ICON_TYPE_TIP,
        style: { width: 24, height: 24, fillColor: $r('sys.color.icon_primary') },
      },
      title: { content: device.deviceName ?? device.deviceId },
      rssi: device.getRssi(),
      device: device,
    } as BluetoothItemModel);
    controller2.init({compId: '123456', component: { id: 'componentId'}, dataSource: datasource });
    controller.onBluetoothBondStateChange({
      deviceId: deviceId,
      state: BondState.BOND_STATE_BONDED,
    } as BondStateParam);
  });
}

function testOnRemoveSummary_001(): void {
  it('testOnRemoveSummary_001', 0, () => {
    let controller = new AvailableDeviceController();
    controller.init({compId: '123456', component: {id: 'componentId'}});
    let deviceId: string = 'deviceId';
    controller.onRemoveSummary(deviceId);
  });
}

function testOnPairResult_001(): void {
  let controller = new AvailableDeviceController()
  controller.init({compId: '123456', component: { id: 'componentId'}});
  controller.onPairResult('123456', 0, true);
  controller.onPairResult('', 0, true);
  controller.onPairResult('123456', 2, false);
  controller.onPairResult('123456', 0, false);
}

function testOnBluetoothStateChange_001(): void {
  let controller = new AvailableDeviceController();
  let datasource: OrderedDataSource = new OrderedDataSource();
  let deviceId: string = 'deviceId';
  let device = new BluetoothDevice(deviceId);
  datasource.pushData({
    id: device.deviceId,
    type: ItemType.ITEM_TYPE_STANDARD,
    icon: {
      icon: device.getIcon(),
      iconType: SettingIconType.ICON_TYPE_TIP,
      style: { width: 24, height: 24, fillColor: $r('sys.color.icon_primary') },
    },
    title: { content: device.deviceName ?? device.deviceId },
    rssi: device.getRssi(),
    device: device,
  } as BluetoothItemModel);
  controller.init({compId: '123456', component: { id: 'componentId'}, dataSource: datasource });
  controller.isSearchMessageShow = true;
  controller.isScanLoadingShow = true;
  controller.onBluetoothStateChange(0);
  expect(controller.isSearchMessageShow).assertTrue();

  controller.isSearchMessageShow = false;
  controller.onBluetoothStateChange(0);
  expect(controller.isSearchMessageShow).assertFalse();

  controller.isSearchMessageShow = true;
  controller.isScanLoadingShow = true;
  controller.onBluetoothStateChange(2);
  expect(controller.isSearchMessageShow).assertTrue();

  controller.isSearchMessageShow = false;
  controller.onBluetoothStateChange(2);
  expect(controller.isSearchMessageShow).assertFalse();
}