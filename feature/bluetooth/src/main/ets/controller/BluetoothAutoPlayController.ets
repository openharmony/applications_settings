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
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SwitchMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BluetoothDevice } from '../model/BluetoothModel';

const TAG: string = 'BluetoothAutoPlayController';

// 表示自动播报已开启
const AUTO_PLAY_OPEN: number = -1;

// 拦截时间默认值
const AUTO_PLAY_INTERCEPT_DEFAULT_VALUE: number = 3000;

/**
 * 蓝牙页面已配对设备自动播放控制器类
 *
 * @since 2024-04-11
 */
export class BluetoothAutoPlayController extends SwitchMenuController {
  private device: BluetoothDevice;
  private a2dpProfile: a2dp.A2dpSourceProfile | undefined = undefined;

  static createBluetoothAutoPlayController(menu: SettingsBaseMenu): Controller {
    return new BluetoothAutoPlayController(menu);
  }

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.device = this.menu?.extra as BluetoothDevice;
    try {
      this.a2dpProfile = a2dp.createA2dpSrcProfile();
    } catch (error) {
      LogUtil.error(`${TAG} createA2dpSrcProfile error: ${error?.message}`);
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear ${this.getLogKey()}`);
    if (this.a2dpProfile && this.device.deviceId) {
      this.a2dpProfile.getAutoPlayDisabledDuration(this.device.deviceId).then((disabledDuration: number) => {
        let deviceId: string = BluetoothUtils.getLogMAC(this.device.deviceId);
        LogUtil.info(`${TAG} getAutoPlayDisabledDuration is: ${disabledDuration}, device id is: ${BluetoothUtils.getLogMAC(deviceId)}`);
        this.setChecked(disabledDuration === AUTO_PLAY_OPEN);
      }).catch((error: Error) => {
        LogUtil.error(`${TAG} getAutoPlayDisabledDuration error, ${error?.message}`);
      });
    } else {
      LogUtil.error(`${TAG} getAutoPlayDisabledDuration failed, param is incorrect.`);
    }
  }

  protected handleCheckedChange(isChecked: boolean): boolean {
    if (!this.a2dpProfile) {
      LogUtil.error(`${TAG} handleCheckedChange failed, a2dpProfile is undefine.`);
      return true;
    }
    LogUtil.info(`${TAG} handleCheckedChange ${isChecked}`);
    try {
      if (isChecked) {
        this.a2dpProfile.enableAutoPlay(this.device.deviceId);
      } else {
        this.a2dpProfile.disableAutoPlay(this.device.deviceId, AUTO_PLAY_INTERCEPT_DEFAULT_VALUE);
      }
    } catch (error) {
      LogUtil.error(`${TAG} deal auto play error: ${error?.message}`);
    }
    return true;
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    super.aboutToDisappear();
  }
}