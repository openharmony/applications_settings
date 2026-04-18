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

/* instrument ignore file */
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CompCtrlParam, ComponentControl, } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingStateType,
  SettingTextState,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogMaskUtil, LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  BluetoothAdapter,
  BluetoothDeviceNameUpdateListener,
  BluetoothProfileStateChangeListener
} from '../BluetoothAdapter';
import { BluetoothItemModel } from '../model/BluetoothItemModel';
import { BluetoothDevice, ProfileId, StateChangeParam } from '../model/BluetoothModel';

export class BluetoothBondedDeviceController implements ComponentControl, BluetoothProfileStateChangeListener,
BluetoothDeviceNameUpdateListener {
  public tag: string = 'BluetoothBondedDeviceController: ';
  private device?: BluetoothDevice;
  public isRegisterProfileStateChange: boolean = false;
  public compId?: string;
  public itemModel?: BluetoothItemModel;
  private deviceNameChangeCallback = (newDeviceName: string) => {
    LogUtil.info(`${this.tag} device name change`);
    this.refreshDeviceName(newDeviceName);
  };

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId || !compParam?.component) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${this.tag} init, compId: ${compParam?.compId}, ${compParam?.component?.id}`);
    this.compId = compParam?.compId;
    this.itemModel = compParam?.component as BluetoothItemModel;
    if (!this.itemModel) {
      LogUtil.error(`${this.tag} init fail, get itemModel fail`);
      return;
    }

    this.device = this.itemModel.device;
    if (!this.device) {
      return;
    }
    let isConnect: boolean = this.device.isConnected();
    if (isConnect) {
      notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingBaseState>(
        [[SettingStateType.STATE_TYPE_ITEM_TITLE,
          { fontColor: isConnect ? $r('sys.color.ohos_id_color_text_primary_activated') :
            $r('sys.color.ohos_id_color_text_primary') } as SettingTextState]]
      ));
    }

    EventBus.getInstance().on(`${this.device?.deviceId}updateName`, this.deviceNameChangeCallback);
    this.registerProfileStateChange();
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    EventBus.getInstance().detach(`${this.device?.deviceId}updateName`, this.deviceNameChangeCallback);
    this.unRegisterProfileStateChange();
  }

  getListenKey(): string {
    return `Bluetooth_Bonded_Device_Controller${this.compId}`;
  }

  onDeviceNameUpdate(device: BluetoothDevice): void {
    LogUtil.info(`${this.tag} onDeviceNameUpdate deviceId: ${BluetoothUtils.getLogMAC(device?.deviceId)}, this.deviceId: ${BluetoothUtils.getLogMAC(this.device?.deviceId)} newDeviceName: ${LogMaskUtil.getLogNickNameString(device?.deviceName)}`);
    if (device?.deviceId !== this.device?.deviceId || CheckEmptyUtils.checkStrIsEmpty(device?.deviceName)) {
      LogUtil.info(`${this.tag} it does not change the name of the device.`);
      return;
    }

    this.refreshDeviceName(device?.deviceName);
  }

  private registerProfileStateChange(): void {
    if (!this.isRegisterProfileStateChange) {
      BluetoothAdapter.getInstance().registerProfileStateChangeListener(this);
      BluetoothAdapter.getInstance().registerDeviceNameUpdateListener(this);
      this.isRegisterProfileStateChange = true;
    }
  }

  private unRegisterProfileStateChange(): void {
    if (this.isRegisterProfileStateChange) {
      BluetoothAdapter.getInstance().unRegisterProfileStateChangeListener(this);
      BluetoothAdapter.getInstance().unRegisterDeviceNameUpdateListener(this);
      this.isRegisterProfileStateChange = false;
    }
  }

  private refreshDeviceName(deviceName: string): void {
    notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_TITLE, { content: deviceName } as SettingTextState]]
    ));
  }

  onBluetoothProfileStateChange(profileId: ProfileId, stateChangeParam: StateChangeParam): void {
  }

  onConnectResult(deviceId: string, result: number, isSuccess: boolean): void {
  }
}