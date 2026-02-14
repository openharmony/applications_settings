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
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';

// 表示自动播报已开启
const AUTO_PLAY_OPEN: number = -1;
// 拦截时间默认值
const AUTO_PLAY_INTERCEPT_DEFAULT_VALUE: number = 3000;

/**
 * 蓝牙页面已配对设备自动播放控制器类
 *
 * @since 2024-04-11
 */
export class BluetoothAutoPlayController implements ComponentControl {
  private tag: string = 'BluetoothAutoPlayController: ';
  public compId?: string;
  private deviceId: string;
  private a2dpProfile: a2dp.A2dpSourceProfile | undefined = undefined;
  private toggleStateChangeCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${this.tag} toggleModel is invalid`);
      return;
    }
    this.handleCheckedChange(toggleState.state);
  };

  constructor(deviceId: string) {
    this.deviceId = deviceId;
    try {
      this.a2dpProfile = a2dp.createA2dpSrcProfile();
    } catch (error) {
      LogUtil.error(`${this.tag} createA2dpSrcProfile error: ${error?.message}`);
    }
  }

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${this.tag} init fail, compParam is invalid`);
      return;
    }

    LogUtil.info(`${this.tag} init compId: ${compParam.compId}`);
    this.compId = compParam.compId;
    if (this.a2dpProfile && this.deviceId) {
      this.a2dpProfile.getAutoPlayDisabledDuration(this.deviceId).then((disabledDuration: number) => {
        LogUtil.info(`${this.tag} getAutoPlayDisabledDuration is: ${disabledDuration}, device id is: ${BluetoothUtils.getLogMAC(this.deviceId)}`);
        this.setChecked(disabledDuration === AUTO_PLAY_OPEN);
      }).catch((error: Error) => {
        LogUtil.error(`${this.tag} getAutoPlayDisabledDuration error, ${error?.message}`);
      });
    } else {
      LogUtil.error(`${this.tag} getAutoPlayDisabledDuration failed, param is incorrect.`);
    }

    EventBus.getInstance().on(`${this.compId}.toggle`, this.toggleStateChangeCallback);
  }

  private setChecked(isChecked: boolean): void {
    notifyCompStateChange(this.compId as string, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TOGGLE, result: {state: isChecked} } as SettingResultState]]
    ));
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    EventBus.getInstance().detach(`${this.compId}.toggle`, this.toggleStateChangeCallback);
  }

  protected handleCheckedChange(isChecked: boolean): boolean {
    if (!this.a2dpProfile) {
      LogUtil.error(`${this.tag} handleCheckedChange failed, a2dpProfile is undefine.`);
      return true;
    }
    LogUtil.info(`${this.tag} handleCheckedChange ${isChecked}`);
    try {
      if (isChecked) {
        this.a2dpProfile.enableAutoPlay(this.deviceId);
      } else {
        this.a2dpProfile.disableAutoPlay(this.deviceId, AUTO_PLAY_INTERCEPT_DEFAULT_VALUE);
      }
    } catch (error) {
      LogUtil.error(`${this.tag} deal auto play error: ${error?.message}`);
    }
    return true;
  }
}