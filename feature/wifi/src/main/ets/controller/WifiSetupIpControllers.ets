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
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { Controller, LogUtil, MenuController, SettingsBaseMenu } from '@ohos/settings.common/index';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { extraType } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LifecycleObserverInterface } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import {
  WIFI_IP_ADDRESS,
  WIFI_IP_DNS_SERVERS_1,
  WIFI_IP_DNS_SERVERS_2,
  WIFI_IP_GATEWAY,
  WIFI_IP_PREFIX_LENGTH
} from '../WifiMenuManager';
import { WifiBaseConfigManager } from '../WifiBaseConfigManager';
import { IPV4_FAMILY_FLAG, IPV6_FAMILY_FLAG, WifiUtils } from '../WifiUtils';
import { WifiPasswordButtonMenuController } from './WifiPasswordButtonMenuController';
import { PendingIpConfig } from '../model/WifiModel';

const KEY_IP_OPTION_DHCP: string = 'key_ip_option_dhcp';

const KEY_IP_OPTION_STATIC: string = 'key_ip_option_static';

const KEY_PROXY_OPTION_NONE = 'key_proxy_option_none';

const KEY_PROXY_OPTION_MANUAL = 'key_proxy_option_manual';

const KEY_PROXY_OPTION_AUTO = 'key_proxy_option_auto';

const WIFI_IP_CHANGED: string = 'wifi_ip_changed';

/**
 * WiFi连接-设置IP入口Controller
 *
 * @since 2024-04-12
 */
export class WifiSetupIpEntryController extends MenuController implements LifecycleObserverInterface {
  static Creator(menu: SettingsBaseMenu): Controller {
    return new WifiSetupIpEntryController(menu);
  }

  public wifiConfig: wifiManager.WifiDeviceConfig;
  public ipConfig: wifiManager.IpConfig;
  public ipv6Config: wifiManager.Ipv6Config;
  public pendingIpConfig: PendingIpConfig | null = null;

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
 * @since 2024-04-12
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
 * @since 2024-04-12
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

/**
 * WiFi连接-设置IP界面-底部按钮Controller
 *
 * @since 2025-7-18
 */
export class WifiSetupIpButtonController extends WifiPasswordButtonMenuController {
  static Creator(menu: SettingsBaseMenu): Controller {
    return new WifiSetupIpButtonController(menu);
  }

  public listenKeys: string[] = [KEY_IP_OPTION_DHCP, KEY_IP_OPTION_STATIC, WIFI_IP_ADDRESS,
    WIFI_IP_GATEWAY, WIFI_IP_PREFIX_LENGTH, WIFI_IP_DNS_SERVERS_1, WIFI_IP_DNS_SERVERS_2]
  public pendingIpConfig: PendingIpConfig;
  public isIpConfigValid: boolean = false;
  public tag: string = 'WifiSetupIpButtonController: ';
  // 修改前的参数
  private currentIpType: wifiManager.IpType = wifiManager.IpType.STATIC;
  private ipAddress: string = '';
  private gateway: string = '';
  private netmask: string = '';
  private primaryDns: string = '';
  private secondDns: string = '';
  private ipv6Address: string = '';
  private ipv6Gateway: string = '';
  private ipv6Netmask: string = '';
  private ipv6PrimaryDns: string = '';
  private ipv6SecondDns: string = '';
  private isIpv4ConfigValid: boolean = false;
  private isIpv6ConfigValid: boolean = false;



  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.pendingIpConfig = menu.extra as PendingIpConfig;
    if (this.pendingIpConfig.dnsServers?.length > 1 && this.pendingIpConfig.dnsServers[1] === 0) {
      this.pendingIpConfig.dnsServers = this.pendingIpConfig.dnsServers.slice(0, 1);
    }
    this.refreshIpConfigValid();
    this.currentIpType = this.pendingIpConfig?.ipType;
    try {
      let ip4Info: wifiManager.IpInfo | null = wifiManager.getIpInfo();
      let ipv6Info: wifiManager.Ipv6Info | null = wifiManager.getIpv6Info();
      this.ipAddress = `${ip4Info?.ipAddress}`;
      this.gateway = `${ip4Info?.gateway}`;
      this.netmask = ip4Info?.netmask ? String(WifiUtils.getPrefixLength(ip4Info?.netmask)) : '';
      this.primaryDns = `${ip4Info?.primaryDns}`;
      this.secondDns = `${ip4Info?.secondDns}`;

      this.ipv6Address = `${ipv6Info?.globalIpv6Address}`;
      this.ipv6Gateway = `${ipv6Info?.gateway}`;
      this.ipv6Netmask = ipv6Info?.netmask ? String(WifiUtils.ipv6PrefixToNumber(ipv6Info?.netmask)) : '';
      this.ipv6PrimaryDns = `${ipv6Info?.primaryDNS}`;
      this.ipv6SecondDns = `${ipv6Info?.secondDNS}`;
    } catch (error) {
      LogUtil.error(`${this.tag} getIpInfo error: ${error?.code}`);
    }
  }

  registerDataChange(): void {
    for (let key of this.listenKeys) {
      this.registerControllerDataChange(key);
    }
  }

  unRegisterDataChange(): void {
    for (let key of this.listenKeys) {
      this.unRegisterControllerDataChange(key);
    }
  }

  onDataChange(fromKey: string, data: string): void {
    switch (fromKey) {
      case KEY_IP_OPTION_DHCP:
        this.pendingIpConfig.ipType = wifiManager.IpType.DHCP;
        break;
      case KEY_IP_OPTION_STATIC:
        this.pendingIpConfig.ipType = wifiManager.IpType.STATIC;
        break;
      case WIFI_IP_ADDRESS:
        this.pendingIpConfig.ipv6Address = WifiBaseConfigManager.convertIpv6String(data);
        this.pendingIpConfig.ipAddress = WifiBaseConfigManager.convertIpString2Number(data);
        break;
      case WIFI_IP_GATEWAY:
        this.pendingIpConfig.ipv6Gateway = WifiBaseConfigManager.convertIpv6String(data);
        this.pendingIpConfig.gateway = WifiBaseConfigManager.convertIpString2Number(data);
        break;
      case WIFI_IP_PREFIX_LENGTH:
        this.pendingIpConfig.ipv6PrefixLength = WifiBaseConfigManager.convertString2Number(data);
        this.pendingIpConfig.prefixLength = WifiBaseConfigManager.convertString2Number(data);
        break;
      case WIFI_IP_DNS_SERVERS_1:
        if(!this.pendingIpConfig.ipv6DnsServers){
          this.pendingIpConfig.ipv6DnsServers = [];
        }
        if (!this.pendingIpConfig.dnsServers) {
          this.pendingIpConfig.dnsServers = [];
        }
        this.pendingIpConfig.ipv6DnsServers[0] = WifiBaseConfigManager.convertIpv6String(data);
        this.pendingIpConfig.dnsServers[0] = WifiBaseConfigManager.convertIpString2Number(data);
        break;
      case WIFI_IP_DNS_SERVERS_2:
        if(!this.pendingIpConfig.ipv6DnsServers){
          this.pendingIpConfig.ipv6DnsServers = [];
        }
        if (CheckEmptyUtils.isEmpty(data)) {
          this.pendingIpConfig.ipv6DnsServers = this.pendingIpConfig.ipv6DnsServers.slice(0, 1);
        } else {
          this.pendingIpConfig.ipv6DnsServers[1] = WifiBaseConfigManager.convertIpv6String(data);
        }
        if (!this.pendingIpConfig.dnsServers) {
          this.pendingIpConfig.dnsServers = [];
        }
        if (CheckEmptyUtils.isEmpty(data)) {
          this.pendingIpConfig.dnsServers = this.pendingIpConfig.dnsServers.slice(0, 1);
        } else {
          this.pendingIpConfig.dnsServers[1] = WifiBaseConfigManager.convertIpString2Number(data);
        }
        break;
    }
    if (this.refreshIpConfigValid()) {
      this.refreshUi();
    }
  }

  refreshIpConfigValid(): boolean {
    this.isIpv6ConfigValid =
      WifiUtils.isValidWifiIpv6Config(this.pendingIpConfig.ipType, this.pendingIpConfig.getIpv6Config());
    this.isIpv4ConfigValid = WifiUtils.isValidWifiIpConfig(this.pendingIpConfig.ipType, this.pendingIpConfig);
    this.pendingIpConfig.family = this.isIpv6ConfigValid ? IPV6_FAMILY_FLAG : IPV4_FAMILY_FLAG;
    const newIsIpConfigValid = this.isIpv6ConfigValid || this.isIpv4ConfigValid;
    if (this.isIpConfigValid !== newIsIpConfigValid) {
      this.isIpConfigValid = newIsIpConfigValid;
      return true;
    }
    return false;
  }

  isButton1Enabled(): boolean {
    return this.isIpConfigValid;
  }

  isButton3Enabled(): boolean {
    return this.isIpConfigValid;
  }

  onButton1Click(): void {
    this.onButtonClick();
  }

  onButton3Click(): void {
    this.onButtonClick();
  }

  private onButtonClick(): void {
    if (this.hasEdit()) {
      this.pendingIpConfig.modified = true;
      EventBus.getInstance().emit(WIFI_IP_CHANGED);
      this.menu.pathInfos?.pop();
    } else {
      this.menu.pathInfos?.pop();
      PageRouter.pop('Setting');
    }
  }

  private hasEdit(): boolean {
    if (this.isIpv4ConfigValid) {
      return this.ipv4HasEdit();
    }
    if (this.isIpv6ConfigValid) {
      return this.ipv6HasEdit();
    }
    return false;
  }

  private ipv4HasEdit(): boolean {
    if (this.currentIpType !== this.pendingIpConfig?.ipType) {
      LogUtil.info(`${this.tag} ipType changed.`);
      return true;
    }
    if (this.currentIpType === wifiManager.IpType.DHCP && this.pendingIpConfig?.ipType === wifiManager.IpType.DHCP) {
      LogUtil.info(`${this.tag} ipType do not change, current ip type is DHCP.`);
      return false;
    }
    if (this.ipAddress !== `${this.pendingIpConfig?.ipAddress}`) {
      LogUtil.info(`${this.tag} ipAddress has changed.`);
      return true;
    }
    if (this.gateway !== `${this.pendingIpConfig?.gateway}`) {
      LogUtil.info(`${this.tag} gateway has changed.`);
      return true;
    }
    if (this.netmask !== `${this.pendingIpConfig?.prefixLength}`) {
      LogUtil.info(`${this.tag} prefixLength has changed.`);
      return true;
    }
    if (this.primaryDns !== `${this.pendingIpConfig?.dnsServers[0]}`) {
      LogUtil.info(`${this.tag} primaryDns has changed.`);
      return true;
    }
    if (this.secondDns !== `${this.pendingIpConfig?.dnsServers[1]}`) {
      LogUtil.info(`${this.tag} secondDns has changed.`);
      return true;
    }
    LogUtil.info(`${this.tag} has not edit any ip infos.`);
    return false;
  }

  private ipv6HasEdit(): boolean {
    if (this.ipv6Address !== `${this.pendingIpConfig?.ipv6Address}`) {
      LogUtil.info(`${this.tag} ipv6Address has changed.`);
      return true;
    }
    if (this.ipv6Gateway !== `${this.pendingIpConfig?.ipv6Gateway}`) {
      LogUtil.info(`${this.tag} ipv6Gateway has changed.`);
      return true;
    }
    if (this.ipv6Netmask !== `${this.pendingIpConfig?.ipv6PrefixLength}`) {
      LogUtil.info(`${this.tag} ipv6Netmask has changed.`);
      return true;
    }
    if (this.ipv6PrimaryDns !== `${this.pendingIpConfig?.ipv6DnsServers[0]}`) {
      LogUtil.info(`${this.tag} ipv6PrimaryDns has changed.`);
      return true;
    }
    if (this.ipv6SecondDns !== `${this.pendingIpConfig?.ipv6DnsServers[1]}`) {
      LogUtil.info(`${this.tag} ipv6SecondDns has changed.`);
      return true;
    }
    return false;
  }
}