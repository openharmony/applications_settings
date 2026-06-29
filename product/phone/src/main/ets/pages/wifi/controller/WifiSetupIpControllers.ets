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
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { Controller, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { extraType, SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LifecycleObserverInterface } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import {
  WIFI_IP_ADDRESS,
  WIFI_IP_DNS_SERVERS_1,
  WIFI_IP_DNS_SERVERS_2,
  WIFI_IP_GATEWAY,
  WIFI_IP_PREFIX_LENGTH
} from '@ohos/settings.wifi/src/main/ets/WifiMenuManager';
import { PendingIpConfig } from '@ohos/settings.wifi/src/main/ets/model/WifiModel';
import { WifiBaseConfigManager } from '@ohos/settings.wifi/src/main/ets/WifiBaseConfigManager';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { KEY_IP_OPTION_DHCP, KEY_IP_OPTION_STATIC } from '../model/WifiSetupIpModel';
import { WifiPasswordButtonMenuController } from './WifiPasswordButtonMenuController';
import { KEY_PROXY_OPTION_AUTO, KEY_PROXY_OPTION_MANUAL, KEY_PROXY_OPTION_NONE } from '../model/WifiSetupProxyModel';

/* instrument ignore file */
const WIFI_IP_CHANGED: string = 'wifi_ip_changed';

/**
 * WiFi连接-设置IP入口Controller
 *
 * @since 2023-12-08
 */
export class WifiSetupIpEntryController extends MenuController implements LifecycleObserverInterface {
  static Creator(menu: SettingsBaseMenu): Controller {
    return new WifiSetupIpEntryController(menu);
  }

  public wifiConfig: wifiManager.WifiDeviceConfig;
  public ipConfig: wifiManager.IpConfig;
  public ipv6Config: wifiManager.Ipv6Config;
  public pendingIpConfig: PendingIpConfig | null = null;
  public tag: string = 'WifiSetupIpEntryController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.wifiConfig = menu.extra as wifiManager.WifiDeviceConfig;
    this.ipConfig = this.wifiConfig?.staticIp as wifiManager.IpConfig;
    this.ipv6Config = this.wifiConfig?.staticIpv6 as wifiManager.Ipv6Config;
    this.getObserverKey = () => this.menu.key as string;
    if (this.wifiConfig?.ipType === wifiManager.IpType.DHCP) {
      this.menu.state = $r('app.string.wifi_ip_settings_dhcp');
    } else {
      this.menu.state = $r('app.string.wifi_ip_settings_static');
    }
  }

  registerDataChange() {
    this.menu?.getRoot()?.getLifecycleOwner()?.addObserver(this);
  }

  unRegisterDataChange() {
    this.menu?.getRoot()?.getLifecycleOwner()?.removeObserver(this.menu.key as string);
  }

  onPageShow() {
    LogUtil.info(`${this.tag} onPageShow modified:${this.pendingIpConfig?.modified}`);
    if (!this.pendingIpConfig?.modified) {
      return;
    }
    this.pendingIpConfig.modified = false;
    this.pendingIpConfig.copyData(this.wifiConfig);
    if (this.wifiConfig?.ipType === wifiManager.IpType.DHCP) {
      this.menu.state = $r('app.string.wifi_ip_settings_dhcp');
    } else {
      this.menu.state = $r('app.string.wifi_ip_settings_static');
    }
    this.refreshUi();
    // 不是已连接详情页面 不执行下面重新连接热点逻辑
    if (!this.menu.pathInfos?.getAllPathName().includes(NavEntryKey.WIFI_MENU_CONFIG_ENTRY)) {
      return;
    }
    WifiUtils.reconnectWithNewConfig(this.tag, this.wifiConfig);
    // 退出页面重进 用来刷新 mac 和 ip 显示
    this.menu.pathInfos?.pop();
  }

  onPageHide() {
    LogUtil.info(`${this.tag} onPageHide`);
  }

  onMenuClick(): boolean {
    if (this.pendingIpConfig === null) {
      this.pendingIpConfig =
        new PendingIpConfig(this.wifiConfig?.ipType ?? wifiManager.IpType.DHCP, this.ipConfig, this.ipv6Config);
    } else {
      this.pendingIpConfig.ipType = this.wifiConfig?.ipType ?? wifiManager.IpType.DHCP;
    }
    this.menu.pushName(this.menu.key as string, new PushParam(this.pendingIpConfig));
    return true;
  }
}

/**
 * 添加其他网络-通用选项Controller
 *
 * @since 2023-12-07
 */
export class WifiSetupCommonOptionController extends MenuController {
  static Creator(menu: SettingsBaseMenu): Controller {
    return new WifiSetupCommonOptionController(menu);
  }

  public listenMenuKeyArray: Array<string>;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.listenMenuKeyArray = (this.menu?.extra as extraType).listenMenuKeyArray ?? [];
  }

  registerDataChange(): void {
    this.listenMenuKeyArray.forEach(key => {
      this.registerControllerDataChange(key);
    });
  }

  unRegisterDataChange(): void {
    this.listenMenuKeyArray.forEach(key => {
      this.unRegisterControllerDataChange(key);
    });
  }

  onDataChange(): void {
    if (this.menu.status) {
      this.menu.status = false;
      this.refreshUi();
    }
  }

  onMenuClick(): boolean {
    if (this.menu.status) {
      return true;
    }
    this.menu.status = true;
    this.refreshUi();
    // 这里publishDataChange用以取消其他option的选中效果，不需要data；针对代理，需要data来控制部分信息的展示和隐藏
    if (this.menu.key === KEY_PROXY_OPTION_NONE) {
      this.publishDataChange(wifiManager.ProxyMethod.METHOD_NONE);
    } else if (this.menu.key === KEY_PROXY_OPTION_MANUAL) {
      this.publishDataChange(wifiManager.ProxyMethod.METHOD_MANUAL);
    } else if (this.menu.key === KEY_PROXY_OPTION_AUTO) {
      this.publishDataChange(wifiManager.ProxyMethod.METHOD_AUTO);
    } else {
      this.publishDataChange(undefined);
    }
    return true;
  }
}


/**
 * WiFi连接-设置IP界面-IP输入框组Controller
 *
 * @since 2023-12-11
 */
export class WifiSetupIpInputGroupController extends MenuController {
  static Creator(menu: SettingsBaseMenu): Controller {
    return new WifiSetupIpInputGroupController(menu);
  }

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.setVisible(this.menu.status ?? false);
  }

  registerDataChange(): void {
    this.registerControllerDataChange(KEY_IP_OPTION_DHCP);
    this.registerControllerDataChange(KEY_IP_OPTION_STATIC);
  }

  unRegisterDataChange(): void {
    this.unRegisterControllerDataChange(KEY_IP_OPTION_DHCP);
    this.unRegisterControllerDataChange(KEY_IP_OPTION_STATIC);
  }

  onDataChange(fromKey: string): void {
    this.setVisible(fromKey === KEY_IP_OPTION_STATIC);
  }
}