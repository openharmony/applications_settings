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
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysAboutBluetoothEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { BluetoothDevice } from '../model/BluetoothModel';
import { BluetoothItemModel } from '../model/BluetoothItemModel';
import { BluetoothAdapter } from '../BluetoothAdapter';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';

const CLICK_BLUETOOTH_NAME: string = 'click_bluetooth_name';

export class BluetoothDeviceController implements ComponentControl {
  public tag: string = 'BluetoothDeviceController : ';
  public device?: BluetoothDevice;

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${this.tag} BluetoothDeviceController init, compId: ${compParam.compId}`);
  }

  destroy(): void {
  }

  async onClick(component: SettingBaseModel): Promise<void> {
    /* instrument ignore if*/
    if (!component) {
      LogUtil.error(`${this.tag} onClick fail, component is invalid`);
      return;
    }

    LogUtil.info(`${this.tag} onClick, componentId: ${component.id}`);
    let itemModel: BluetoothItemModel = component as BluetoothItemModel;
    /* instrument ignore if*/
    if (!itemModel || !itemModel.device) {
      LogUtil.error(`${this.tag} onClick fail, get device fail`);
      return;
    }
    let reportParams: Record<string, Object> = {};
    reportParams.VALUE = itemModel.device?.deviceName || '';
    reportParams.IS_SETTINGS_OPEN = '1';
    HiSysEventUtil.reportBehaviorEventByUE(HiSysAboutBluetoothEventGroup.SELECT_BLUETOOTH_PAIRING, reportParams);
    HiSysEventUtil.reportButtonEvent(CLICK_BLUETOOTH_NAME, '');
    BluetoothAdapter.getInstance().pairDevice(itemModel.device?.deviceId as string);
    EventBus.getInstance().emit('clickpair');
  }
}