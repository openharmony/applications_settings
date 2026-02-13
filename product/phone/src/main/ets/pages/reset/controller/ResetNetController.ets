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

import { distributedAccount } from '@kit.BasicServicesKit';
import policy from '@ohos.net.policy';
import promptAction from '@ohos.promptAction';
import radio from '@ohos.telephony.radio';
import connection from '@ohos.net.connection';
import access from '@ohos.bluetooth.access';
import wifiManager from '@ohos.wifiManager';
import { ButtonMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { DeviceNameUtil, DefaultName } from '@ohos/settings.common/src/main/ets/utils/DeviceNameUtils';
import { homeInitData } from '@ohos/settings.common/src/main/ets/sendable/HomeInitData';
import { BusinessError } from '@ohos.base';
import {
  HiSysEventUtil
} from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { SWITCH_ON_VAL } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { CapabilitySupportUtils } from '@ohos/settings.common/src/main/ets/utils/CapabilitySupportUtils';
import { HiSysAboutSystemSettingsEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
/* instrument ignore file */
const TAG: string = 'ResetNetController : ';
const SIM_CHECK_KEY = 'sim_check';
const ONE_CARD: string = '1';
const SETTINGS_DATA_DEVICE_NAME: string = 'settings.general.device_name';

/**
 * Do reset network settings
 *
 * @author yudenggao
 * @since 2023-08-29
 */
@Observed
export class ResetNetController extends ButtonMenuController {
  static CreateResetNetController(menu: SettingsBaseMenu): Controller {
    return new ResetNetController(menu);
  }

  onButton3Click() {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysAboutSystemSettingsEventGroup.CLICK_RESTORE_NETWORK_BUTTON);
    LogUtil.info(`${TAG} start reset network `);
    this.resetSimPolicies();
  }

  private async resetSimPolicies() {
    let checkSimId = SettingsDataUtils.getSettingsData(SIM_CHECK_KEY, '0');
    LogUtil.info(`${TAG} do reset network, slotIndex: ${checkSimId}.`);
    let promise = policy.resetPolicies(checkSimId);
    await promise.then(() => {
      try {
        promptAction.showToast({
          message: ResourceUtil.getStringSync($r('app.string.reset_net_result')),
          duration: 2000
        });
      } catch (error) {
        LogUtil.info(`${TAG} showToast args error code is ${(error as BusinessError)?.code}, message is ${(error as BusinessError)?.message}`);
      }
    }).catch((error: object) => {
      LogUtil.info(`${TAG} resetSimPolicies error.`);
    });
    //还原网络接口（飞行模式）
    try {
      connection.factoryReset();
    } catch (error) {
      LogUtil.error(`connection factoryReset error code： ${error?.code} , message：${error?.message}`);
    }

    //还原蓝牙
    try {
      access.factoryReset();
      let newDeviceName: string = DefaultName.getDefaultName();
      DeviceNameUtil.getDeviceManager()?.restoreLocalDeivceName();
      await DeviceNameUtil.setDisplayDeviceNameAsync(newDeviceName);
      AppStorage.setOrCreate<string>(SETTINGS_DATA_DEVICE_NAME, newDeviceName);
      homeInitData.deviceName = newDeviceName;
      DeviceNameUtil.setMigratedDeviceName('0');
    } catch (error) {
      LogUtil.error(`access factoryReset error code： ${error?.code} , message：${error?.message}`);
    }
    //还原wlan
    try {
      wifiManager.factoryReset();
    } catch (error) {
      LogUtil.error(`wlan factoryReset error code： ${(error as BusinessError)?.code} ,message：${(error as BusinessError)?.message}`);
    }
    //获取卡槽id
    let slotId = SettingsDataUtils.getSettingsData(SIM_CHECK_KEY, '0');
    LogUtil.info(`${TAG} getSettingsData slotId: ${slotId}`);
    this.resetNetwork(slotId === ONE_CARD ? 1 : 0);
  }

  private resetNetwork(slotId: number) {
    //还原电话接口
    try {
      radio.factoryReset(slotId)
    } catch (error) {
      LogUtil.error(`radio factoryReset error code： ${error?.code} , message：${error?.message}`);
    }
  }
}
