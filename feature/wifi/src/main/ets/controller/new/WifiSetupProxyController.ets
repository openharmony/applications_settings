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
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { PendingProxyConfig } from '../WifiSetupProxyControllers';
import { WifiUtils } from '../../WifiUtils';
import { ApMenuConfigData, AVAILABLE_WLAN_DETAIL_CHANGE_EVENT } from '../../model/WifiModel';

const TAG: string = 'WifiSetupProxyController : ';
const WIFI_PROXY_CHANGED: string = 'wifi_proxy_changed';
const ENTER_INTERNAL_ENTRY: string = 'enter_internal_entry';
const WIFI_PROXY_KEY: string = 'Setting.wifi_config_menu.wifi_config_group_three.wifi_setup_proxy_entry';

export class WifiSetupProxyController implements ComponentControl {
  public pendingProxyConfig: PendingProxyConfig | null = null;
  public wifiConfig: wifiManager.WifiDeviceConfig | undefined;
  public param?: CompCtrlParam;
  private apMenu?: ApMenuConfigData;

  constructor(config: wifiManager.WifiDeviceConfig | undefined, apMenu?: ApMenuConfigData) {
    this.wifiConfig = config;
    this.apMenu = apMenu;
  }

  private onProxyChanged = (proxyMethod: number) => {
    if (!this.pendingProxyConfig?.modified || !this.wifiConfig) {
      return;
    }
    let content = $r('app.string.wifi_proxy_settings_none');
    /* instrument ignore else*/
    if (proxyMethod === wifiManager.ProxyMethod.METHOD_MANUAL) {
      content = $r('app.string.wifi_proxy_settings_manual');
    } else if (proxyMethod === wifiManager.ProxyMethod.METHOD_AUTO) {
      content = $r('app.string.wifi_proxy_settings_auto');
    }
    let state = new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
      {
        type: ItemResultType.RESULT_TYPE_TEXT, result: {
        content: content,
      }
      } as SettingResultState]]);
    notifyCompStateChange(WIFI_PROXY_KEY, state);
    this.pendingProxyConfig.copyData(this.wifiConfig);
    /* instrument ignore if*/
    if (wifiManager.isConnected()) {
      WifiUtils.reconnectWithNewConfig(TAG, this.wifiConfig);
    } else {
      EventBus.getInstance().emit(AVAILABLE_WLAN_DETAIL_CHANGE_EVENT, this.apMenu);
    }
    PageRouter.pop('Setting');
    this.pendingProxyConfig.modified = false;
  }

  init(param?: object | undefined): void {
    LogUtil.info(`${TAG} init`);
    if (!param) {
      return;
    }
    this.param = (param as CompCtrlParam);
    EventBus.getInstance().on(WIFI_PROXY_CHANGED, this.onProxyChanged);
  }

  /* instrument ignore next*/
  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
    EventBus.getInstance().off(WIFI_PROXY_CHANGED);
  }

  onClick(): void {
    if (this.pendingProxyConfig === null) {
      this.pendingProxyConfig = new PendingProxyConfig(this.wifiConfig?.proxyConfig);
    } else {
      this.pendingProxyConfig.proxyMethod = this.wifiConfig?.proxyConfig?.proxyMethod ??
        wifiManager.ProxyMethod.METHOD_NONE;
    }
    PageRouter.push(NavEntryKey.WIFI_SETUP_PROXY_ENTRY, new PushParam(this.pendingProxyConfig));
    HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, 'pageUrl: pages/wifi/WifiSetupProxyPage');
  }
}