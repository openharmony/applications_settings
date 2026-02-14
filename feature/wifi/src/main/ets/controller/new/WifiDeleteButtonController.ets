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
import wifiManager from '@ohos.wifiManager';
import { BusinessError } from '@ohos.base';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysWlanEvenGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { wifiTracker } from '../../WifiTracker';
import { WifiUtils } from '../../WifiUtils';
import { WifiSecurityType } from '../../model/WifiModel';

const TAG = 'WifiDeleteButtonController';
const SMART_HOTSPOT_KEY: string = 'smartHotSpot';
const INVALID_NETWORK_ID: number = -1;

export class WifiDeleteButtonController implements ComponentControl {
  private config: wifiManager.WifiDeviceConfig | undefined;
  private isConnectedWlan: boolean = false;
  
  constructor(config: wifiManager.WifiDeviceConfig | undefined, isConnectedWlan: boolean) {
    this.config = config;
    this.isConnectedWlan = isConnectedWlan;
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
  }

  onClick(component: SettingBaseModel): void {
    HiSysEventUtil.reportDefaultBehaviorEvent(HiSysWlanEvenGroup.DELETE_CONNECTED_WLAN);
    // 已连接的网络，都通过netId删除
    this.removePskDeviceConfig();
    if (this.isConnectedWlan) {
      this.removeConnectedDeviceConfig();
    } else {
      LogUtil.info(`${TAG} start to removeWifiDevice`);
      wifiTracker.removeWifiDevice(this.config as wifiManager.WifiDeviceConfig);
    }
    AppStorage.setOrCreate<string>(SMART_HOTSPOT_KEY, '');
    SettingsDataUtils.setSettingsData(SMART_HOTSPOT_KEY, '');
    PageRouter.pop('Setting');
  }

  private removePskDeviceConfig(): void {
    if (!this.config) {
      LogUtil.warn(`${TAG} removePskDeviceConfig, config is invalid!`);
      return;
    }
    LogUtil.info(`${TAG} start to removePskDeviceConfig`);
    let savedConfig: wifiManager.WifiDeviceConfig = this.config as wifiManager.WifiDeviceConfig;
    if (savedConfig.securityType !== WifiSecurityType.WIFI_SEC_TYPE_SAE) {
      LogUtil.info(`${TAG} securityType is not SAE.`);
      return;
    }
    let deviceConfig: wifiManager.WifiDeviceConfig = 
      WifiUtils.getConfig(savedConfig.ssid, WifiSecurityType.WIFI_SEC_TYPE_PSK) as wifiManager.WifiDeviceConfig;
    if (deviceConfig) {
      LogUtil.info(`${TAG} delete config with securityType is psk.`);
      wifiTracker.removeWifiDevice(deviceConfig, false);
    }
  }

  private removeConnectedDeviceConfig(): void {
    LogUtil.info(`${TAG} start to remove connected without config wlan.`);
    WifiUtils.getLinkedInfo().then((linkInfo: wifiManager.WifiLinkedInfo | undefined) => {
      LogUtil.info(`${TAG} removeWifiDevice by id: ${linkInfo?.networkId ?? INVALID_NETWORK_ID}`);
      wifiTracker.removeWifiDeviceById(linkInfo?.networkId ?? INVALID_NETWORK_ID);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} get linked info error: ${error?.message}`);
    });
  }
}