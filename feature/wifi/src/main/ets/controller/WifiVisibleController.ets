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

import Window from '@ohos.window';
import wifiManager from '@ohos.wifiManager';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import {
  extraType,
  MenuGroup,
  SettingsBaseMenu
} from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import {
  CaCertificateType,
  WIFI_EAP_ANONYMOUS,
  WIFI_EAP_CA_CERTIFICATE,
  WIFI_EAP_CA_CERTIFICATE_SUMMARY,
  WIFI_EAP_DOMAIN,
  WIFI_EAP_IDENTITY,
  WIFI_EAP_INPUT_MENU_GROUP,
  WIFI_EAP_METHOD,
} from '../WifiMenuManager';

/**
 * wifi menu visible controller
 * @since 2023-10-05
 */
@Observed
export class WifiVisibleController extends MenuController {
  static CreateWifiVisibleController(menu: SettingsBaseMenu): Controller {
    return new WifiVisibleController(menu);
  }

  public tag: string = 'WifiEapGroupController : ';
  public supportEapMethod: Array<number>;
  public isCurrentVisible: boolean;
  public listenMenuKeyArray: Array<string>;
  // CA证书提示语 显示变量
  public caVisible: boolean = true;
  public caSummaryVisible: boolean = false;
  // allInputGroup 显示变量
  public domainVisible: boolean = false;
  public identityVisible: boolean = true;
  public anonymousVisible: boolean = true;
  // 初始子组件
  public initialMenus: SettingsBaseMenu[] = [];

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    if (!this.menu?.extra) {
      LogUtil.info(`${this.tag} router params apConfig is invalid`);
    }
    /* instrument ignore if*/
    if (this.menu instanceof MenuGroup) {
      this.initialMenus = this.menu.getMenus()
    }
    this.supportEapMethod = (this.menu.extra as extraType)?.supportEapMethod ?? [];
    this.isCurrentVisible = (this.menu.extra as extraType)?.isCurrentVisible ?? true;
    this.listenMenuKeyArray = (this.menu.extra as extraType)?.listenMenuKeyArray ?? [];
    /* instrument ignore if*/
    if (this.getLogKey() === WIFI_EAP_INPUT_MENU_GROUP) {
      this.updateAllInputMenus();
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear ${this.getLogKey()}`);
    super.aboutToAppear();
    this.setVisible(this.isCurrentVisible);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear ${this.getLogKey()}`);
    super.aboutToDisappear();
  }

  registerDataChange(): void {
    LogUtil.info(`${this.tag} registerDataChange`);
    this.listenMenuKeyArray.forEach(key => {
      this.registerControllerDataChange(key);
    });
  }

  unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange`);
    this.listenMenuKeyArray.forEach(key => {
      this.unRegisterControllerDataChange(key);
    });
  }

  /**
   * ca证书提示语显隐控制
   */
  private setCASummaryVisible(fromKey: string, data: number): void {
    if (fromKey === WIFI_EAP_METHOD) {
      this.caVisible = [
        wifiManager.EapMethod.EAP_PEAP,
        wifiManager.EapMethod.EAP_TLS,
        wifiManager.EapMethod.EAP_TTLS,
      ].includes(data);
      this.setVisible(this.caVisible && this.caSummaryVisible);
    }
    if (fromKey === WIFI_EAP_CA_CERTIFICATE) {
      this.caSummaryVisible = [CaCertificateType.CA_CERTIFICATE_TYPE_NONE].includes(data);
      this.setVisible(this.caVisible && this.caSummaryVisible);
    }
  }

  /**
   * allInputGroup 显隐控制/内部菜单控制
   */
  private setAllInputVisible(fromKey: string, data: number): void {
    if (fromKey === WIFI_EAP_METHOD) {
      // 身份
      this.identityVisible = [
        wifiManager.EapMethod.EAP_PEAP,
        wifiManager.EapMethod.EAP_TLS,
        wifiManager.EapMethod.EAP_TTLS,
        wifiManager.EapMethod.EAP_PWD,
      ].includes(data);
      // 匿名身份
      this.anonymousVisible = [wifiManager.EapMethod.EAP_PEAP, wifiManager.EapMethod.EAP_TTLS].includes(data);
      // ca证书
      this.caVisible = [
        wifiManager.EapMethod.EAP_PEAP,
        wifiManager.EapMethod.EAP_TLS,
        wifiManager.EapMethod.EAP_TTLS,
      ].includes(data);
    }
    if (fromKey === WIFI_EAP_CA_CERTIFICATE) {
      // 域名
      this.domainVisible = [CaCertificateType.CA_CERTIFICATE_TYPE_SYSTEM].includes(data);
    }
    // 身份没有 那这个group就没有
    this.setVisible(this.identityVisible);
    this.updateAllInputMenus();
  }

  /**
   * update allInputGroup menus
   */
  private updateAllInputMenus(): void {
    const showKeys: string [] = [];
    if (this.identityVisible) {
      showKeys.push(WIFI_EAP_IDENTITY);
    }
    if (this.anonymousVisible) {
      showKeys.push(WIFI_EAP_ANONYMOUS);
    }
    /* instrument ignore if*/
    if (this.domainVisible && this.caVisible) {
      showKeys.push(WIFI_EAP_DOMAIN);
    }
    if (this.menu instanceof MenuGroup) {
      this.menu.updateMenus(this.initialMenus.filter(it => showKeys.includes(it.key as string)));
      this.refreshUi();
    }
  }

  onDataChange(fromKey: string, data: number): void {
    LogUtil.info(`${this.tag} onDataChange, fromKey: ${fromKey}`);
    if (this.getLogKey() === WIFI_EAP_CA_CERTIFICATE_SUMMARY) {
      this.setCASummaryVisible(fromKey, data)
      return;
    }
    if (this.getLogKey() === WIFI_EAP_INPUT_MENU_GROUP) {
      this.setAllInputVisible(fromKey, data)
      return;
    }
    if (typeof data === 'number') {
      // 添加网络界面安全性被勾选时，不提供截屏功能
      if (fromKey === 'key_security_selector') {
        if (data !== 0) {
          PasswordUtil.setWindowPrivacyMode((AppStorage.get<Window.WindowStage>('windowStage') as
          Window.WindowStage), true);
        } else {
          PasswordUtil.setWindowPrivacyMode((AppStorage.get<Window.WindowStage>('windowStage') as
          Window.WindowStage), false);
        }
      }
      this.setVisible(this.supportEapMethod.includes(data));
    }
  }
}