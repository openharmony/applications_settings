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
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import {
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BluetoothDevice } from '../model/BluetoothModel';
import { BluetoothItemModel } from '../model/BluetoothItemModel';


export class OppBluetoothDeviceController implements ComponentControl {
  public tag: string = 'OppBluetoothDeviceController : ';
  public device?: BluetoothDevice;

  init(): void {
    LogUtil.info(`${this.tag} init`);
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
  }

  sendBluetoothInfo(deviceId: string): void {
    LogUtil.info(`${this.tag} sendBluetoothInfo`);
    const session: UIExtensionContentSession | undefined =
      LocalStorage.getShared()?.get<UIExtensionContentSession>('session');
    if (session === undefined) {
      return;
    }
    session.sendData({
      action: 'sendDeviceInfo',
      deviceInfo: deviceId,
    });
    session.terminateSelf();
  }

  async closeSheetPage(): Promise<void> {
    LogUtil.info(`${this.tag} closeSheetPage`);
    const session: UIExtensionContentSession | undefined =
      LocalStorage.getShared()?.get<UIExtensionContentSession>('session');
    if (session === undefined) {
      return;
    }
    session.sendData({
      action: 'closeSheet',
    });
    session.terminateSelf();
  }

  async onClick(component: SettingBaseModel): Promise<void> {
    if (!component) {
      LogUtil.error(`${this.tag} onClick fail, component is invalid`);
      return;
    }

    LogUtil.info(`${this.tag} onClick, componentId: ${component.id}`);
    let itemModel: BluetoothItemModel = component as BluetoothItemModel;
    if (!itemModel || !itemModel.device) {
      LogUtil.error(`${this.tag} onClick fail, get device fail`);
      return;
    }

    this.sendBluetoothInfo(itemModel.device?.deviceId as string);
  }
}