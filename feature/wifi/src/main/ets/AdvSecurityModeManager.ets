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

import rpc from '@ohos.rpc';
import wifiManager from '@ohos.wifiManager';
import common from '@ohos.app.ability.common';
import systemParameterEnhance from '@ohos.systemParameterEnhance';
import { BusinessError } from '@ohos.base';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { ApMenu } from './model/WifiModel';
import { WifiUtils } from './WifiUtils';

const TAG: string = 'AdvSecurityModeManager : ';
const SYS_KEY_ADVANCE_SECURITY_MODE: string = 'ohos.boot.advsecmode.state';
const MODE_DEFAULT_VALUE: string = '0';
const REQUEST_CODE: number = 1;

export enum ConnectScene {
  // wlan界面，可用wlan
  WLAN_PAGE_AVAILABLE_WLAN = 0,

  // wlan界面，加密wlan
  WLAN_PAGE_OTHER_WLAN = 1,

  // 控制中心界面
  CONTROL_CENTER_WLAN_LIST = 2,
}

export interface IConnectData {
  connectScene: ConnectScene;
  ssid?: string;
  securityType?: number;
  config?: wifiManager.WifiDeviceConfig;
  apMenu?: ApMenu;
  capabilities?: string;
}

/**
 * WLAN 高级安全模式业务管理类
 *
 * @since 2024-11-05
 */
export class AdvSecurityModeManager {
  private static instance: AdvSecurityModeManager;
  private connectionId: number = -1;
  private connectData: IConnectData | undefined = undefined;
  private sysDialogWant: Want = {
    bundleName: 'com.ohos.sceneboard',
    abilityName: 'com.ohos.sceneboard.systemdialog'
  };
  private options: common.ConnectOptions = {
    onConnect(elementName, remote): void {
      LogUtil.info(`${TAG} onConnect callback`);
      /* instrument ignore if*/
      if (remote === null) {
        LogUtil.error(`${TAG} onConnect remote is null`);
        return;
      }
      let data: rpc.MessageSequence = new rpc.MessageSequence();
      let reply: rpc.MessageSequence = new rpc.MessageSequence();
      try {
        data.writeInt(3);
        data.writeString('bundleName');
        data.writeString('com.ohos.settings');
        data.writeString('abilityName');
        data.writeString('WifiUnSaveNetDialogAbility');
        data.writeString('parameters');
        // 拉起系统弹窗传参，由于需要在控制中心上层显示，因此sysDialogZOrder设置为2
        data.writeString(`{"ability.want.params.uiExtensionType":"sysDialog/common","sysDialogZOrder":2 }`);
        remote.sendMessageRequest(REQUEST_CODE, data, reply, new rpc.MessageOption()).then((result) => {
          LogUtil.showInfo(TAG, `sendMessageRequest callback errCode is ${result.errCode}`);
        }).catch((error: BusinessError) => {
          LogUtil.showError(TAG, `sendMessageRequest failed: ${error?.code}, message: ${error?.message}`);
        });
      } catch (error) {
        LogUtil.showError(TAG, `onConnect failed: ${error?.code}, message: ${error?.message}`);
      } finally {
        data.reclaim();
        reply.reclaim();
      }
    },
    onDisconnect(elementName): void {
      LogUtil.showInfo(TAG, `onDisconnect callback`);
    },
    onFailed(code): void {
      LogUtil.showError(TAG, `onFailed callback: ${code}`);
      AdvSecurityModeManager.getInstance().clearConnectData();
    }
  }

  public static getInstance(): AdvSecurityModeManager {
    if (AdvSecurityModeManager.instance) {
      return AdvSecurityModeManager.instance;
    }
    AdvSecurityModeManager.instance = new AdvSecurityModeManager();
    return AdvSecurityModeManager.instance;
  }

  isAdvSecurityModeEnable(): boolean {
    try {
      let securityStatus: string = systemParameterEnhance.getSync(SYS_KEY_ADVANCE_SECURITY_MODE, MODE_DEFAULT_VALUE);
      LogUtil.showInfo(TAG, `securityStatus: ${securityStatus}`);
      return !CheckEmptyUtils.checkStrIsEmpty(securityStatus) && securityStatus !== MODE_DEFAULT_VALUE;
    } catch (error) {
      LogUtil.showError(TAG, `get security status failed: code = ${error?.code}, message: ${error?.message}`);
    }
    return false;
  }

  isNeedShowWifiUnsafeDialog(securityType: number, capabilities: string, ssid: string): boolean {
    return this.isAdvSecurityModeEnable() && WifiUtils.isUnsafeNetwork(securityType, capabilities, ssid);
  }

  setConnectData(data: IConnectData): void {
    this.connectData = data;
  }

  getConnectData(): IConnectData | undefined {
    return this.connectData;
  }

  clearConnectData(): void {
    this.connectData = undefined;
    this.connectionId = -1;
  }

  showWifiUnsafeDialog(context: common.UIAbilityContext): void {
    if (!context) {
      LogUtil.error(`${TAG} showWifiUnsafeDialog failed, context is null.`);
      return;
    }
    try {
      this.connectionId = context.connectServiceExtensionAbility(this.sysDialogWant, this.options);
      LogUtil.info(`${TAG} connectAbility connectionId ${this.connectionId}`);
    } catch (error) {
      LogUtil.showError(TAG, `connectServiceExtensionAbility failed: ${error?.code}, message: ${error?.message}`);
    }
  }
}