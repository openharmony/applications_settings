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

import access from '@ohos.bluetooth.access';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { homeInitData } from '@ohos/settings.common/src/main/ets/sendable/HomeInitData';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import lazy { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';

const TAG = 'BluetoothController';

export class BluetoothController implements ComponentControl {
  private isBluetoothStateOn: boolean = false;

  private onBluetoothCommonEvent = () => {
    LogUtil.info(`${TAG} receive bluetoothStateChange`);
    if (this.isBluetoothStateOn !== homeInitData.bluetoothState) {
      this.setBluetoothState(homeInitData.bluetoothState);
    }
  };

  private onBluetoothStateChange = (state: number) => {
    LogUtil.info(`${TAG} onBluetoothStateChange, state : ${state}`);
    let isBluetoothOn: boolean = BluetoothUtils.isBluetoothStateOn(state);
    if (this.isBluetoothStateOn !== isBluetoothOn) {
      this.setBluetoothState(isBluetoothOn);
    }
  }

  init(compParam: CompCtrlParam): void {
    console.log('zzzzzzzzz bt init')
    let isBluetoothStateOn: boolean = this.getBluetoothState() === access.BluetoothState.STATE_ON;
    LogUtil.info(`${TAG} init, state : ${isBluetoothStateOn}`);
    this.setBluetoothState(isBluetoothStateOn);
    this.registerStateChange();
    AbilityContextManager.getContext()?.eventHub.on(CommonEventConstant.EVENT_BLUETOOTH_STATE_CHANGE,
      this.onBluetoothCommonEvent);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    this.unRegisterStateChange();
    AbilityContextManager.getContext()?.eventHub.off(CommonEventConstant.EVENT_BLUETOOTH_STATE_CHANGE, this.onBluetoothCommonEvent);
  }

  async setBluetoothState(isBluetoothOn: boolean): Promise<void> {
    LogUtil.info(`${TAG} setBluetoothState`);
    this.isBluetoothStateOn = isBluetoothOn;
    homeInitData.bluetoothState = isBluetoothOn;
    notifyCompStateChange('bluetooth_entry',
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: isBluetoothOn ? $r('app.string.bluetooth_state_on_text') : $r('app.string.bluetooth_state_off_text') } } as SettingResultState]]));
    LogUtil.info(`${TAG} setBluetoothState bluetooth state: ${isBluetoothOn}`);
  }

  private async registerStateChange(): Promise<void> {
    try {
      await Promise.all([access.on('stateChange', this.onBluetoothStateChange)]);
    } catch (error) {
      LogUtil.info(`${TAG} registerStateChange error: ${error?.message}`);
    }
  }

  private async unRegisterStateChange(): Promise<void> {
    try {
      access.off('stateChange', this.onBluetoothStateChange);
    } catch (error) {
      LogUtil.info(`${TAG} unregisterStateChange error: ${error?.message}`);
    }
  }

  private getBluetoothState(): access.BluetoothState {
    let bluetoothState: access.BluetoothState = access.BluetoothState.STATE_OFF;
    try {
      bluetoothState = access.getState();
    } catch (e) {
      LogUtil.error(`${TAG} access.getState() error error.code ${e?.code} error.message ${e?.message}`);
    }
    return bluetoothState;
  }
}