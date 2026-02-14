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
import a2dp from '@ohos.bluetooth.a2dp';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingResultState,
  SettingStateType,
  SettingToggleState,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysAboutBluetoothEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

export class BluetoothDeviceVolumeSyncPhoneSwitchMenuController implements ComponentControl {
  public tag: string = 'BluetoothDeviceVolumeSyncPhoneSwitchMenuController';
  public compId?: string;
  public deviceId: string;
  public absoluteVolumeEnabled: boolean = false;
  private toggleStateChangeCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${this.tag} toggleModel is invalid`);
      return;
    }
    this.handleCheckedChange(toggleState.state);
  };

  constructor(deviceId: string, isVolumeSyncParamOn: boolean) {
    this.deviceId = deviceId;
    this.absoluteVolumeEnabled = isVolumeSyncParamOn;
  }

  init(compParam: CompCtrlParam): void {
    this.compId = compParam.compId;
    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeCallback);
  }

  destroy(): void {
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeCallback);
  }

  private setChecked(isChecked: boolean): void {
    notifyCompStateChange(this.compId as string, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TOGGLE, result: {state: isChecked} } as SettingResultState]]
    ));
  }

  /**
   * 开关变化的回调
   */
  protected handleCheckedChange(isChecked: boolean): boolean {
    LogUtil.info(`${this.tag} handleCheckedChange ${isChecked}`);
    if (isChecked) {
      this.enableAbsoluteVolume();
    } else {
      this.disableAbsoluteVolume();
    }
    return true;
  }

  /**
   * 开启蓝牙设备音量与手机同步开关
   */
  private async enableAbsoluteVolume(): Promise<void> {
    if (this.deviceId) {
      try {
        await a2dp.createA2dpSrcProfile()?.enableAbsoluteVolume(this.deviceId).then(() => {
          LogUtil.info(`${this.tag} enableAbsoluteVolume success`);
          HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutBluetoothEventGroup.BLUETOOTH_SYNC_VOLUME_SWITCH, 'on');
        });
      } catch (err) {
        LogUtil.error(`${this.tag} errCode: ${err?.code} , errMessage: ${err?.message}`);
        this.setChecked(false);
      }
    }
  }

  /**
   * 关闭蓝牙设备音量与手机同步开关
   */
  private async disableAbsoluteVolume(): Promise<void> {
    if (this.deviceId) {
      try {
        await a2dp.createA2dpSrcProfile()?.disableAbsoluteVolume(this.deviceId).then(() => {
          LogUtil.info(`${this.tag} disableAbsoluteVolume success`);
          HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutBluetoothEventGroup.BLUETOOTH_SYNC_VOLUME_SWITCH, 'off');
        });
      } catch (err) {
        LogUtil.error(`${this.tag}  : errCode: ${err?.code} , errMessage: ${err?.message}`);
        this.setChecked(true);
      }
    }
  }
}