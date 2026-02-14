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

import {
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { BluetoothPageController } from '@ohos/settings.bluetooth/src/main/ets/controller/BluetoothPageController';
import { BluetoothSwitchController } from '@ohos/settings.bluetooth/src/main/ets/controller/BluetoothSwitchController';
import { BondedDeviceController } from '@ohos/settings.bluetooth/src/main/ets/controller/BondedDeviceController';
import { BluetoothAdapter } from '@ohos/settings.bluetooth/src/main/ets/BluetoothAdapter';
import { AvailableDeviceController } from '@ohos/settings.bluetooth/src/main/ets/controller/AvailableDeviceController';
import DeviceNameDisable from '@ohos/settings.common/src/main/ets/utils/DeviceNameDisable';
/* instrument ignore file */
/**
 * 蓝牙页面控制器类
 *
 * @since 2022-06-18
 */
export class BluetoothPhonePageController extends BluetoothPageController {
  public tag: string = 'BluetoothPhonePageController: ';
  private switchController: BluetoothSwitchController;
  private bondedDeviceController: BondedDeviceController;
  private availableDeviceController: AvailableDeviceController;

  constructor(switchController: BluetoothSwitchController, bondedDeviceController: BondedDeviceController,
    availableDeviceController: AvailableDeviceController) {
    super();
    this.switchController = switchController;
    this.bondedDeviceController = bondedDeviceController;
    this.availableDeviceController = availableDeviceController;
    DeviceNameDisable.getInstance().disableItems();
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onPageShow`);
    if (DeviceNameDisable.getInstance().disableItems()) {
      DeviceNameDisable.getInstance().notifyMenuDisable();
    }
    super.onPageShow(component);
    if (BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState)) {
      BluetoothAdapter.getInstance().updateBondedDevices();
      BluetoothAdapter.getInstance().updatePairingState();
    }

    this.switchController?.onPageShow();
    this.availableDeviceController?.onPageShow();
    this.bondedDeviceController?.onPageShow();
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onPageHide`);
    super.onPageHide(component);
    this.availableDeviceController?.onPageHide();
  }
}
