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
import { Controller, LogUtil, MenuController, SettingsBaseMenu } from '@ohos/settings.common/index';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { WIFI_PROXY_EXCLUSIONLIST_LABEL, WIFI_PROXY_HOSTNAME_LABEL, WIFI_PROXY_PORT_LABEL } from '../WifiMenuManager';
import { WifiUtils } from '../WifiUtils';
import { WifiPasswordButtonMenuController } from './WifiPasswordButtonMenuController';

const KEY_PROXY_OPTION_NONE = 'key_proxy_option_none';

const KEY_PROXY_OPTION_MANUAL = 'key_proxy_option_manual';

const KEY_PROXY_OPTION_AUTO = 'key_proxy_option_auto';

const KEY_WIFI_SETUP_PROXY_PAC_INPUT = 'key_wifi_setup_proxy_pac_input';

const WIFI_PROXY_CHANGED: string = 'wifi_proxy_changed';

/**
 * WiFi连接-设置代理中转数据
 *
 * @since 2024-04-12
 */
export class PendingProxyConfig implements wifiManager.WifiProxyConfig {
  public proxyMethod?: wifiManager.ProxyMethod;
  public pacWebAddress?: string;
  public serverHostName?: string;
  public serverPort?: number;
  public exclusionObjects?: string;
  public modified: boolean = false;

  constructor(proxyConfig?: wifiManager.WifiProxyConfig) {
    this.proxyMethod = proxyConfig?.proxyMethod ?? wifiManager.ProxyMethod.METHOD_NONE;
    this.pacWebAddress = proxyConfig?.pacWebAddress;
    this.serverHostName = proxyConfig?.serverHostName;
    this.serverPort = proxyConfig?.serverPort;
    this.exclusionObjects = proxyConfig?.exclusionObjects;
  }

  copyData(wifiConfig: wifiManager.WifiDeviceConfig) {
    if (!wifiConfig) {
      LogUtil.error(`wifiConfig is undefined`);
      return;
    }
    if (this.proxyMethod === wifiManager.ProxyMethod.METHOD_MANUAL) {
      wifiConfig.proxyConfig = {
        proxyMethod: this.proxyMethod,
        serverHostName: this.serverHostName,
        serverPort: this.serverPort,
        exclusionObjects: this.exclusionObjects,
      }
    } else if (this.proxyMethod === wifiManager.ProxyMethod.METHOD_AUTO) {
      wifiConfig.proxyConfig = {
        proxyMethod: this.proxyMethod,
        pacWebAddress: this.pacWebAddress,
      }
    } else {
      wifiConfig.proxyConfig = undefined;
    }
  }
}

/**
 * WiFi连接-设置代理入口Controller
 *
 * @since 2024-04-12
 */
export class WifiSetupProxyEntryController extends MenuController {
  static Creator(menu: SettingsBaseMenu): Controller {
    return new WifiSetupProxyEntryController(menu);
  }

  public wifiConfig: wifiManager.WifiDeviceConfig;
  public pendingProxyConfig: PendingProxyConfig | null = null;
  public tag: string = 'WifiSetupProxyEntryController';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.wifiConfig = menu.extra as wifiManager.WifiDeviceConfig;
    this.getObserverKey = () => this.menu.key as string;
    if (this.wifiConfig?.proxyConfig?.proxyMethod === wifiManager.ProxyMethod.METHOD_MANUAL) {
      this.menu.state = $r('app.string.wifi_proxy_settings_manual');
    } else if (this.wifiConfig?.proxyConfig?.proxyMethod === wifiManager.ProxyMethod.METHOD_AUTO) {
      this.menu.state = $r('app.string.wifi_proxy_settings_auto');
    } else {
      this.menu.state = $r('app.string.wifi_proxy_settings_none');
    }
  }

  registerDataChange() {
    this.menu?.getRoot()?.getLifecycleOwner()?.addObserver(this);
  }

  unRegisterDataChange() {
    this.menu?.getRoot()?.getLifecycleOwner()?.removeObserver(this.menu.key as string);
  }

  onPageShow() {
    if (this.pendingProxyConfig?.modified) {
      this.pendingProxyConfig.copyData(this.wifiConfig);
      if (this.pendingProxyConfig?.proxyMethod === wifiManager.ProxyMethod.METHOD_MANUAL) {
        this.menu.state = $r('app.string.wifi_proxy_settings_manual');
      } else if (this.pendingProxyConfig?.proxyMethod === wifiManager.ProxyMethod.METHOD_AUTO) {
        this.menu.state = $r('app.string.wifi_proxy_settings_auto');
      } else {
        this.menu.state = $r('app.string.wifi_proxy_settings_none');
      }
      this.refreshUi();
      WifiUtils.reconnectWithNewConfig(this.tag, this.wifiConfig);
      this.pendingProxyConfig.modified = false;
    }
  }

  onPageHide() {
  }

  onMenuClick(): boolean {
    if (this.pendingProxyConfig === null) {
      this.pendingProxyConfig = new PendingProxyConfig(this.wifiConfig.proxyConfig);
    } else {
      this.pendingProxyConfig.proxyMethod = this.wifiConfig.proxyConfig?.proxyMethod ??
      wifiManager.ProxyMethod.METHOD_NONE;
    }
    this.menu.pushName(this.menu.key as string, new PushParam(this.pendingProxyConfig));
    return true;
  }
}

/**
 * WiFi连接-设置代理界面-代理输入框组Controller
 *
 * @since 2024-04-12
 */
export class WifiSetupProxyInputGroupController extends MenuController {
  static Creator(menu: SettingsBaseMenu): Controller {
    return new WifiSetupProxyInputGroupController(menu);
  }

  public isManual: boolean;
  public listenKeys: string[] = [KEY_PROXY_OPTION_NONE, KEY_PROXY_OPTION_MANUAL, KEY_PROXY_OPTION_AUTO];

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.isManual = menu.extra as boolean;
    this.setVisible(this.menu.status ?? false);
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

  onDataChange(fromKey: string): void {
    if (this.isManual) {
      this.setVisible(fromKey === KEY_PROXY_OPTION_MANUAL);
    } else {
      this.setVisible(fromKey === KEY_PROXY_OPTION_AUTO);
    }
  }
}

/**
 * WiFi连接-设置代理界面-底部按钮Controller
 *
 * @since 2024-04-12
 */
export class WifiSetupProxyButtonController extends WifiPasswordButtonMenuController {
  static Creator(menu: SettingsBaseMenu): Controller {
    return new WifiSetupProxyButtonController(menu);
  }

  public listenKeys: string[] = [KEY_PROXY_OPTION_NONE, KEY_PROXY_OPTION_MANUAL,
    KEY_PROXY_OPTION_AUTO, WIFI_PROXY_HOSTNAME_LABEL, WIFI_PROXY_PORT_LABEL,
    WIFI_PROXY_EXCLUSIONLIST_LABEL, KEY_WIFI_SETUP_PROXY_PAC_INPUT]
  public pendingProxyConfig: PendingProxyConfig;
  public isProxyConfigValid: boolean = false;
  public tag: string = 'WifiSetupProxyButtonController: ';
  // 修改前的参数
  private proxyMethod: number = 0;
  private serverHostName: string = '';
  private serverPort: number = 0;
  private exclusionObjects: string = '';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    this.pendingProxyConfig = menu.extra as PendingProxyConfig;
    this.refreshProxyConfigValid();
    this.proxyMethod = this.pendingProxyConfig?.proxyMethod ?? 0;
    this.serverHostName = this.pendingProxyConfig?.serverHostName ?? '';
    this.serverPort = this.pendingProxyConfig?.serverPort ?? 0;
    this.exclusionObjects = this.pendingProxyConfig?.exclusionObjects ?? '';
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
      case KEY_PROXY_OPTION_NONE:
        this.pendingProxyConfig.proxyMethod = wifiManager.ProxyMethod.METHOD_NONE;
        break;
      case KEY_PROXY_OPTION_AUTO:
        this.pendingProxyConfig.proxyMethod = wifiManager.ProxyMethod.METHOD_AUTO;
        break;
      case KEY_PROXY_OPTION_MANUAL:
        this.pendingProxyConfig.proxyMethod = wifiManager.ProxyMethod.METHOD_MANUAL;
        break;
      case WIFI_PROXY_HOSTNAME_LABEL:
        this.pendingProxyConfig.serverHostName = data;
        break;
      case WIFI_PROXY_PORT_LABEL:
        this.pendingProxyConfig.serverPort = Number.parseInt(data) ?? undefined;
        break;
      case WIFI_PROXY_EXCLUSIONLIST_LABEL:
        this.pendingProxyConfig.exclusionObjects = data;
        break;
      case KEY_WIFI_SETUP_PROXY_PAC_INPUT:
        this.pendingProxyConfig.pacWebAddress = data;
        break;
    }
    if (this.refreshProxyConfigValid()) {
      this.refreshUi();
    }
  }

  refreshProxyConfigValid(): boolean {
    if (this.isProxyConfigValid !== WifiUtils.isValidProxyConfig(this.pendingProxyConfig)) {
      this.isProxyConfigValid = !this.isProxyConfigValid;
      return true;
    }
    return false;
  }

  isButton3Enabled(): boolean {
    return this.isProxyConfigValid;
  }

  onButton3Click(): void {
    if (this.hasEdit()) {
      this.pendingProxyConfig.modified = true;
      EventBus.getInstance().emit(WIFI_PROXY_CHANGED, this.pendingProxyConfig?.proxyMethod ?? 0);
      this.menu.pathInfos?.pop();
    } else {
      // 如果未做任何修改，则不需要重新连接
      this.menu.pathInfos?.pop();
      PageRouter.pop('Setting');
    }
  }

  private hasEdit(): boolean {
    if (this.proxyMethod !== this.pendingProxyConfig?.proxyMethod) {
      LogUtil.info(`${this.tag} proxyMethod changed.`);
      return true;
    }
    if (this.proxyMethod === wifiManager.ProxyMethod.METHOD_NONE &&
      this.pendingProxyConfig?.proxyMethod === wifiManager.ProxyMethod.METHOD_NONE) {
      LogUtil.info(`${this.tag} proxyMethod do not change, current proxyMethod is none.`);
      return false;
    }
    if (this.serverHostName !== this.pendingProxyConfig?.serverHostName) {
      LogUtil.info(`${this.tag} serverHostName has changed.`);
      return true;
    }
    if (this.serverPort !== this.pendingProxyConfig?.serverPort) {
      LogUtil.info(`${this.tag} serverPort has changed.`);
      return true;
    }
    if (this.exclusionObjects !== this.pendingProxyConfig?.exclusionObjects) {
      LogUtil.info(`${this.tag} exclusionObjects has changed.`);
      return true;
    }
    LogUtil.info(`${this.tag} has not edit any proxy infos.`);
    return false;
  }
}