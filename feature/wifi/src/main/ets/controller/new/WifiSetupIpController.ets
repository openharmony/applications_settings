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
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { WifiUtils } from '../../WifiUtils';
import { ApMenuConfigData, AVAILABLE_WLAN_DETAIL_CHANGE_EVENT, PendingIpConfig } from '../../model/WifiModel';

const TAG: string = 'WifiSetupIpController : ';
const WIFI_IP_CHANGED: string = 'wifi_ip_changed';
const ENTER_INTERNAL_ENTRY: string = 'enter_internal_entry';
const WIFI_IP_KEY: string = 'Setting.wifi_config_menu.wifi_config_group_three.wifi_setup_ip_entry';

export class WifiSetupIpController implements ComponentControl {
  public pendingIpConfig: PendingIpConfig | null = null;
  public ipConfig: wifiManager.IpConfig;
  public ipv6Config: wifiManager.Ipv6Config;
  public wifiConfig?: wifiManager.WifiDeviceConfig;
  public param?: CompCtrlParam;
  private apMenu?: ApMenuConfigData;

  private onIpChanged = () => {
    if (!this.wifiConfig) {
      return;
    }
    if (this.pendingIpConfig?.modified) {
      this.pendingIpConfig.copyData(this.wifiConfig);
      let content = $r('app.string.wifi_ip_settings_static');
      if (this.wifiConfig.ipType === wifiManager.IpType.DHCP) {
        content = $r('app.string.wifi_ip_settings_dhcp');
      }
      let state = new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT, result: {
          content: content,
        }
        } as SettingResultState]]);
      notifyCompStateChange(WIFI_IP_KEY, state);
      try {
        /* instrument ignore if*/
        if (wifiManager.isConnected()) {
          WifiUtils.reconnectWithNewConfig(TAG, this.wifiConfig);
        } else {
          EventBus.getInstance().emit(AVAILABLE_WLAN_DETAIL_CHANGE_EVENT, this.apMenu);
        }
        PageRouter.pop('Setting');
      } catch (error) {
        LogUtil.error(`${TAG} wifi connect failed: ${error?.message}`);
      }
      this.pendingIpConfig.modified = false;
    }
  }

  constructor(config: wifiManager.WifiDeviceConfig | undefined, apMenu?: ApMenuConfigData) {
    this.apMenu = apMenu;
    this.wifiConfig = config;
    this.ipConfig = this.wifiConfig?.staticIp as wifiManager.IpConfig;
    this.ipv6Config = this.wifiConfig?.staticIpv6 as wifiManager.Ipv6Config;
  }

  init(param?: object | undefined): void {
    LogUtil.info(`${TAG} init`);
    if (!param) {
      LogUtil.error(`${TAG} init failed, param is empty.`);
      return;
    }
    this.param = (param as CompCtrlParam);
    EventBus.getInstance().on(WIFI_IP_CHANGED, this.onIpChanged);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().off(WIFI_IP_CHANGED);
  }

  onClick(): void {
    if (this.pendingIpConfig === null) {
      this.pendingIpConfig =
        new PendingIpConfig(this.wifiConfig?.ipType ?? wifiManager.IpType.DHCP, this.ipConfig, this.ipv6Config);
    } else {
      this.pendingIpConfig.ipType = this.wifiConfig?.ipType ?? wifiManager.IpType.DHCP;
    }
    this.pendingIpConfig.family = this.wifiConfig?.family ?? 0;
    this.pendingIpConfig.connState = this.apMenu?.connState;
    PageRouter.push(NavEntryKey.WIFI_SETUP_IP_ENTRY, new PushParam(this.pendingIpConfig));
    HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, 'pageUrl: pages/wifi/WifiSetupProxyPage');
  }
}