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
import { BusinessError } from '@ohos.base';
import connection from '@ohos.bluetooth.connection';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { InlineTextInputComponent } from '@ohos/settings.commonUikit/src/main/ets/component/InlineTextInputComponent';
import { SettingItemModel, } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { BluetoothDevice } from '../model/BluetoothModel';
import { BluetoothAdapter } from '../BluetoothAdapter';

const TAG: string = 'BluetoothDeviceNameComponent:';

@Builder
export function BluetoothDeviceNamePcBuilder(param: object) {
  BluetoothDeviceNameComponent({
    item: param as SettingItemModel,
  });
}

@Component
export struct BluetoothDeviceNameComponent {
  item?: SettingItemModel;
  @State value: string = '';
  private device?: BluetoothDevice;

  build() {
    InlineTextInputComponent({
      title: $r('app.string.device_name_settings_title'),
      value: this.value,
      tabInd: this.item?.tabIndex,
      onUpdate: (newName: string) => {
        let deviceId = this.device?.deviceId;
        connection.setRemoteDeviceName(deviceId, newName).then(() => {
          LogUtil.info(`${TAG} setRemoteDeviceName success.`);
          // 立即验证设备名称是否已更新
          if (deviceId) {
            if (this.device) {
              this.device.deviceName = newName;
              // 更新蓝牙适配器缓存，确保持久化
              BluetoothAdapter.getInstance().updateBluetoothCaches(deviceId, newName);
              BluetoothAdapter.getInstance().setBondedDevice(deviceId, this.device);
            }
            EventBus.getInstance().emit(`${deviceId}updateName`, newName);
          }
        }).catch((error: BusinessError) => {
          LogUtil.error(`${TAG} setRemoteDeviceName catch error. code:${error?.code} message:${error?.message}`);
        });
      },
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.device = this.item?.extra as BluetoothDevice;
    this.value = this.device?.deviceName;
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }
}