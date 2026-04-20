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

import bluetooth from '@ohos.bluetooth';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingStateType,
  SettingTextState,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { BluetoothAdapter } from '@ohos/settings.bluetooth/src/main/ets/BluetoothAdapter';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';

/* instrument ignore file */
export class UnpairButtonController implements ComponentControl {
  public tag: string = 'UnpairButtonController : ';
  public deviceId?: string;
  public subDeviceId?: string;
  public compId?: string;

  constructor(deviceId: string, subDeviceId: string) {
    this.deviceId = deviceId;
    this.subDeviceId = subDeviceId;
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${this.tag} init`);
    this.compId = compParam.compId;
    notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_TITLE, { fontColor: $r('sys.color.ohos_id_color_handup') } as SettingTextState]]
    ));
  }

  destroy(): void {
  }

  onClick(component: SettingBaseModel): void {
    LogUtil.info(`${this.tag} onClick start to disconnect and unpair`);
    if (!CheckEmptyUtils.checkStrIsEmpty(this.deviceId)) {
      let disconnectResult: boolean = BluetoothAdapter.getInstance().disconnectDevice(this.deviceId as string);
      LogUtil.info(`${this.tag} disconnectResult : ${disconnectResult}`);
      let cancelPairedResult: boolean = bluetooth.cancelPairedDevice(this.deviceId as string);
      LogUtil.info(`${this.tag} cancelPairedDevice result : ${cancelPairedResult}`);
    }

    if (!CheckEmptyUtils.checkStrIsEmpty(this.subDeviceId)) {
      let disconnectResult: boolean = BluetoothAdapter.getInstance().disconnectDevice(this.subDeviceId as string);
      LogUtil.info(`${this.tag} subdevice disconnectResult : ${disconnectResult}`);
      let cancelPairedResult: boolean = bluetooth.cancelPairedDevice(this.subDeviceId as string);
      LogUtil.info(`${this.tag} subdevice cancelPairedDevice result : ${cancelPairedResult}`);
    }
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAccessibilityEventGroup.ENTER_UPPAIR_HEARING_AID);
    PageRouter.pop('Setting');
  }
}