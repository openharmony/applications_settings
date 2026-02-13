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

import wifiManager from '@ohos.wifiManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { AddOtherWlanConfigManager } from '../../AddOtherWlanConfigManager';
import { WifiPasswordConfigManager } from '../../WifiPasswordConfigManager';

/* instrument ignore file */
const TAG: string = 'WifiSetupIpButtonController : ';
const IP_INFO_SAVED: string = 'IP_INFO_SAVED';

export class WifiSetupIpButtonController implements ComponentControl {
  public param?: CompCtrlParam;
  public wifiConfig?: wifiManager.WifiDeviceConfig;
  private hasClickSaveButton: boolean = false;
  // 初始参数，如果没有保存就退出了，那么需要恢复数据
  private initIpType?: wifiManager.IpType;
  private initStaticIp?: wifiManager.IpConfig;
  private initStaticIpv6?: wifiManager.Ipv6Config;

  init(compParam: CompCtrlParam) {
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    let config: wifiManager.WifiDeviceConfig | undefined = AddOtherWlanConfigManager.getInstance().wifiConfig;
    if (config) {
      this.wifiConfig = config;
    } else {
      this.wifiConfig = WifiPasswordConfigManager.getInstance().getConfig();
    }
    this.initIpType = this.wifiConfig?.ipType;
    let staticIp: wifiManager.IpConfig | undefined = this.wifiConfig?.staticIp;
    let staticIpv6: wifiManager.Ipv6Config | undefined = this.wifiConfig?.staticIpv6;
    this.initStaticIp = {
      ipAddress: staticIp?.ipAddress ?? 0,
      gateway: staticIp?.gateway ?? 0,
      prefixLength: staticIp?.prefixLength ?? 0,
      dnsServers: staticIp?.dnsServers ?? [],
      domains: staticIp?.domains ?? [],
    };
    this.initStaticIpv6 = {
      ipAddress: staticIpv6?.ipAddress ?? '',
      gateway: staticIpv6?.gateway ?? '',
      prefixLength: staticIpv6?.prefixLength ?? 0,
      dnsServers: staticIpv6?.dnsServers ?? [],
      domains: staticIpv6?.domains ?? [],
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear.`);
    if (!this.wifiConfig) {
      LogUtil.error(`${TAG} destroy, wifi config is undefined.`);
      return;
    }
    if (this.hasClickSaveButton) {
      LogUtil.info(`${TAG} page destroy, has saved data: ${this.hasClickSaveButton}`);
      return;
    }
    // 没有点击保存就返回，需要恢复数据
    this.wifiConfig.ipType = this.initIpType;
    this.wifiConfig.staticIp = this.initStaticIp;
    this.wifiConfig.staticIpv6 = this.initStaticIpv6;
    let ipEntryId: string =
      `${PageRouter.getRouterName()}.wifi_password_config.wifi_config_ip_group.wifi_setup_ip_entry`;
    let config: wifiManager.WifiDeviceConfig | undefined = AddOtherWlanConfigManager.getInstance().wifiConfig;
    if (config) {
      ipEntryId = `${PageRouter.getRouterName()}.add_other_wlan_config.wifi_config_ip_group.wifi_setup_ip_entry`;
    }
    notifyCompStateChange(ipEntryId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: {
            content: this.initIpType === wifiManager.IpType.DHCP ?
            $r('app.string.wifi_ip_settings_dhcp') : $r('app.string.wifi_ip_settings_static'),
          }
        } as SettingResultState]]));
  }

  destroy(): void {
  }

  public onSaveButtonClicked(): void {
    LogUtil.info(`${TAG} onSaveButtonClicked.`);
    this.hasClickSaveButton = true;
    EventBus.getInstance().emit(IP_INFO_SAVED);
  }
}