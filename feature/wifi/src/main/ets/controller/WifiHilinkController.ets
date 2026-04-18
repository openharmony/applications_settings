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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { WifiUtils } from '../WifiUtils';
import { WifiConnectionState } from '../model/WifiModel';
import { WIFI_PRIVACY_MAC_ADDRESS_SETTINGS } from '../WifiMenuManager';

const TAG: string = 'WifiHilinkController : ';

/**
 * Hilink提示文字及自动连接
 */
export class WifiHilinkController extends MenuController {
  private isHilink: boolean = false;
  private isDisconnect: boolean = false;
  private bssid: string = '';
  private apConfig?: wifiManager.WifiDeviceConfig;
  // 隐私类型缓存
  private randomMacTypeCache?: wifiManager.DeviceAddressType;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateWifiHilinkController(menu: SettingsBaseMenu): Controller {
    return new WifiHilinkController(menu);
  }

  public onWifiConnectionChange = (state: number): void => {
    LogUtil.info(`${TAG} onWifiConnectionChange : ${state}`);
    // hiLink 自动连接是先给2先断开
    if (state === WifiConnectionState.HILINK) {
      this.isDisconnect = true;
    }
    // 0表示才开始连接
    if (this.isDisconnect && state === WifiConnectionState.DISCONNECTED) {
      this.isDisconnect = false;
      this.publishDataChange(WifiConnectionState.HILINK);
    }
  };

  aboutToAppear(): void {
    super.aboutToAppear();
    WifiUtils.wifiConnectionChangeOn(TAG, this.onWifiConnectionChange);
    this.isHilink = this.menu?.isNeedShowIcon as boolean;
    if (CheckEmptyUtils.isEmpty((this.menu?.extra as wifiManager.WifiDeviceConfig)?.ssid)) {
      LogUtil.warn(`${TAG} router params apConfig is invalid`);
    } else {
      this.apConfig = this.menu.extra as wifiManager.WifiDeviceConfig;
      this.bssid = this.apConfig?.bssid || '';
    }

    if (this.isHilinkConnectSupport()) {
      LogUtil.info(`${TAG} aboutToAppear, isHilink = ${this.isHilink}, set hilink summary visible.`);
      this.setVisible(true);
      this.randomMacTypeCache = this.apConfig?.randomMacType;
      WifiUtils.enableHiLinkHandshake(true, this.bssid, this.apConfig as wifiManager.WifiDeviceConfig);
    } else {
      LogUtil.info(`${TAG} aboutToAppear, set hilink summary invisible.`);
      this.setVisible(false);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    super.aboutToDisappear();
    WifiUtils.wifiConnectionChangeOff(TAG, this.onWifiConnectionChange);
    if (this.isHilinkConnectSupport()) {
      WifiUtils.enableHiLinkHandshake(false, this.bssid, this.apConfig as wifiManager.WifiDeviceConfig);
    }
  }

  public getObserverKey = (): string => {
    return this.menu?.key ?? '';
  }

  registerDataChange(): void {
    LogUtil.info(`${TAG} registerDataChange`);
    this.registerControllerDataChange(WIFI_PRIVACY_MAC_ADDRESS_SETTINGS);
  }

  unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    this.unRegisterControllerDataChange(WIFI_PRIVACY_MAC_ADDRESS_SETTINGS);
  }

  onDataChange(fromKey: string, data: number): void {
    LogUtil.info(`${TAG} onDataChange, fromKey: ${fromKey}`);
    // 隐私切换
    if (fromKey === WIFI_PRIVACY_MAC_ADDRESS_SETTINGS && typeof data === 'number') {
      if (this.isHilinkConnectSupport() && this.randomMacTypeCache !== data) {
        this.randomMacTypeCache = data;
        (this.apConfig as wifiManager.WifiDeviceConfig).randomMacType = data;
        WifiUtils.enableHiLinkHandshake(true, this.bssid, this.apConfig as wifiManager.WifiDeviceConfig);
      }
    }
  }

  private isHilinkConnectSupport(): boolean {
    return this.isHilink && !CheckEmptyUtils.isEmpty(this.apConfig);
  }
}
