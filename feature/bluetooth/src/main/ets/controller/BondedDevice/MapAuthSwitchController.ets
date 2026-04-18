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

import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingResultState,
  SettingStateType,
  SettingToggleState,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BluetoothAdapter } from '../../BluetoothAdapter';

/* instrument ignore file */
enum AccessAuthorization {
  UNKNOWN = 0,
  ALLOWED = 1,
  REJECTED = 2,
}

/**
 * 信息授权控制器类
 *
 * @since 2023-05-11
 */
export class MapAuthSwitchController implements ComponentControl {
  public tag: string = 'MapAuthSwitchController: ';
  public compId?: string;
  private deviceId?: string;
  public mapProfile = BluetoothAdapter.getInstance().profileManager.mapProfile;
  private currentStatus: boolean = false;
  private toggleStateChangeCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${this.tag} toggleModel is invalid`);
      return;
    }
    this.handleCheckedChange(toggleState.state);
  };

  constructor(deviceId: string) {
    this.deviceId = deviceId;
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }

    LogUtil.info(`${this.tag} init MapAuthSwitchController, ${compParam.compId}`);
    this.compId = compParam.compId;
    this.updateStatus();
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeCallback);
    LogUtil.info(`${this.tag} init compId is ${this.compId}`);
  }

  updateStatus(): void {
    LogUtil.info(`${this.tag} init updateStatus`);
    try {
      LogUtil.info(`${this.tag} init updateStatus getMessageAccessAuthorization: ${BluetoothUtils.getLogMAC(this.deviceId)}`);
      this.mapProfile?.getMessageAccessAuthorization(this.deviceId).then((permission) => {
        LogUtil.info(`${this.tag} init updateStatus updateStatus permission: ${permission}`);
        this.currentStatus = permission === AccessAuthorization.ALLOWED;
        notifyCompStateChange(this.compId as string, new Map<SettingStateType, SettingBaseState>(
          [[SettingStateType.STATE_TYPE_ITEM_RESULT,
            { type: ItemResultType.RESULT_TYPE_TOGGLE, result: {state: this.currentStatus} } as SettingResultState]]
        ));
      })
    } catch (err) {
      LogUtil.error(`'map'  error. code: ${err?.code} ,message: ${err?.message}`);
    }
  }

  /**
   * 处理开关变化
   */
  private handleCheckedChange(isOn: boolean): boolean {
    let deviceId: string = this.deviceId as string;
    if (isOn) {
      try {
        this.mapProfile?.setMessageAccessAuthorization(deviceId, AccessAuthorization.ALLOWED).then(() => {
          LogUtil.info(`${this.tag} accessAuthorization: ${AccessAuthorization.ALLOWED}`);
        })
      } catch (err) {
        LogUtil.error(`'setMessageAccessAuthorization'  error. code: ${err?.code} ,message: ${err?.message}`);
      }
    } else {
      try {
        this.mapProfile?.setMessageAccessAuthorization(deviceId, AccessAuthorization.REJECTED).then(() => {
          LogUtil.info(`${this.tag} accessAuthorization: ${AccessAuthorization.REJECTED}`);
        })
      } catch (err) {
        LogUtil.error(`${this.tag} setMessageAccessAuthorization error.code: ${err?.code}, message: ${err?.message}`);
      }
    }
    return true;
  }

  destroy(): void {
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeCallback);
  }
}