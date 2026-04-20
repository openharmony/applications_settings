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
import { MenuGroup, SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { WifiListBaseController } from './WifiListBaseController';
import { AccessPoint, ApMenu, WifiState, WifiConnectionState } from '../model/WifiModel';
import { CONNECTED_AP_KEY, IS_DEBUG, WifiUtils } from '../WifiUtils';
import { wifiTracker } from '../WifiTracker';

/* instrument ignore file */
const TAG: string = 'WifiWindowBaseController : ';
const DELAY: number = 100;

/**
 * 已连接和可用Wifi信息展示控制器
 *
 * @since 2023-03-13
 */
export abstract class WifiWindowBaseController extends WifiListBaseController {
  public isLoaded: boolean = false;
  public lastLinkedInfo: wifiManager.WifiLinkedInfo | null = null;
  public accessPoint: AccessPoint | null = null;
  public timerId: number | null = null;

  public onWifiConnectionChange = (state: number): void => {
    if (!this.isRegister) {
      return;
    }
    // 控制中心这里连接上的时候立马去拿扫描结果用来把列表刷新已连接
    if (state === WifiConnectionState.CONNECTED) {
      wifiTracker.updateAll();
    }
    LogUtil.info(`${TAG} wifi connection state change : ${state}`);
    this.getLastLinkedInfoAndUpdate();
  }

  protected registerDataChange(): void {
    LogUtil.info(`${TAG} registerDataChange`);
    super.registerDataChange();
    WifiUtils.wifiConnectionChangeOn(TAG, this.onWifiConnectionChange);

    if (this.timerId !== null) {
      clearInterval(this.timerId);
      this.timerId = null;
    }

    this.timerId = setInterval(() => {
      LogUtil.info(`${TAG} check wifi state`);
      try {
        if (wifiManager.isWifiActive()) {
          LogUtil.info(`${TAG} wifi is active`);
          clearInterval(this.timerId as number);
          this.timerId = null;
          this.targetState = WifiState.ACTIVE;
          this.onWifiStateChange(this.targetState);
        } else {
          LogUtil.info(`${TAG} wifi is inActive`);
        }
      } catch (error) {
        LogUtil.error(`${TAG} get wifi active state failed: ${error?.message}`);
      }
    }, DELAY);
  }

  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    super.unRegisterDataChange();
    WifiUtils.wifiConnectionChangeOff(TAG, this.onWifiConnectionChange);
  }

  onDataChange(fromKey: string, data: Object): void {
    return;
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.getLastLinkedInfoAndUpdate();
    this.isLoaded = true;
  }

  onPageShow(): void {
    super.onPageShow();
    if (!this.isLoaded) {
      this.getLastLinkedInfoAndUpdate();
      this.isLoaded = true;
    }
  }

  onPageHide(): void {
    super.onPageHide();
    this.isLoaded = false;
  }

  onApMenusChanged(data: Array<ApMenu>): void {
    LogUtil.info(`${TAG} onApMenusChanged`);
    if (!(this.menu instanceof MenuGroup)) {
      return;
    }

    let menus: SettingsBaseMenu[] = [];
    // 已连接的wifi
    if ((this.menu instanceof MenuGroup) && this.accessPoint) {
      LogUtil.info(`${TAG} onApMenusChanged getConnectedApMenu`);
      menus.push(this.getConnectedApMenu() as SettingsBaseMenu);
    }

    if ((!data || data.length === 0) && menus.length === 0) {
      LogUtil.info(`${TAG} data is empty`);
      this.menu.clear();
      this.refreshUi();
      return;
    }

    let originMenusMap: Map<string, ApMenu | null> = new Map<string, ApMenu | null>();
    for (let item of Array.from(this.menu.getMenus())) {
      originMenusMap.set(item.key as string, (item instanceof ApMenu) ? item : null)
    }

    // 可用的wifi
    for (let item of data) {
      let menu = originMenusMap.get(item.key as string);
      if (!menu) {
        menu = this.createApMenu(item);
      } else {
        originMenusMap.delete(menu.key as string);
        menu.update(item);
      }
      menus.push(menu);
    }
    LogUtil.info(`${TAG} onApMenusChanged ${menus.length}`);
    if (this.menu instanceof MenuGroup) {
      this.menu.updateMenus(menus);
      this.refreshUi();
    }
    LogUtil.info(`${TAG} onApListChanged end`);
  }

  /**
   * 连接的wifi
   */
  private getLastLinkedInfoAndUpdate(): void {
    LogUtil.info(`${TAG} getLastLinkedInfoAndUpdate`);
    try {
      if (wifiManager.isConnected()) {
        LogUtil.info(`${TAG} getLastLinkedInfoAndUpdate connected`);
        this.updateConnectedAp();
      } else {
        LogUtil.info(`${TAG} getLastLinkedInfoAndUpdate not connected`);
        this.hideConnectedApChange();
      }
    } catch (error) {
      LogUtil.error(`${TAG} get wifi connect state failed: ${error?.message}`);
    }
  }

  private async updateConnectedAp(): Promise<void> {
    try {
      LogUtil.info(`${TAG} updateConnectedAp start`);
      this.lastLinkedInfo = await wifiManager.getLinkedInfo();
      LogUtil.info(`${TAG} get lastLinkedInfo success`);

      if (this.lastLinkedInfo.connState !== wifiManager.ConnState.CONNECTED) {
        LogUtil.info(`${TAG} lastLinkedInfo connState not connected, state=${this.lastLinkedInfo.connState}`);
        this.hideConnectedApChange();
        return;
      }

      let wifiDeviceConfig: wifiManager.WifiDeviceConfig | null = null;
      let configs: wifiManager.WifiDeviceConfig[] = wifiManager.getDeviceConfigs();
      if (configs && configs.length > 0) {
        for (let config of configs) {
          if (IS_DEBUG) {
            LogUtil.info(`${TAG} config : ${WifiUtils.getLogSsidString(config.ssid)}`);
          }
          if (this.lastLinkedInfo.ssid === config.ssid && this.lastLinkedInfo.networkId === config.netId) {
            wifiDeviceConfig = config;
          }
        }
      }
      let accessPoint = new AccessPoint(null);
      if (!wifiDeviceConfig) {
        LogUtil.error(`${TAG} updateConnectedAp, find wifiDeviceConfig null`);
      } else {
        accessPoint.setConfigs([wifiDeviceConfig]);
      }
      accessPoint.updateLastLinkedInfo(this.lastLinkedInfo);
      if (this.lastLinkedInfo) {
        accessPoint.supportedWifiCategory = this.lastLinkedInfo.supportedWifiCategory;
        accessPoint.isHiLinkNetwork = this.lastLinkedInfo.isHiLinkNetwork;
      }
      if (this.accessPoint?.isSameAp(accessPoint)) {
        LogUtil.warn(`${TAG} updateConnectedAp, ap is same, return`);
        return;
      }
      LogUtil.info(`${TAG} updateConnectedAp: ${accessPoint?.toString()}`);
      this.accessPoint = accessPoint;
    } catch (error) {
      LogUtil.error(`${TAG} update connected ap error: ${error?.message}`);
    }
  }

  private hideConnectedApChange(): void {
    LogUtil.info(`${TAG} hideConnectedApChange`);
    if (this.menu instanceof MenuGroup && this.accessPoint) {
      this.menu.removeMenu(CONNECTED_AP_KEY + this.accessPoint.apKey);
    }
    this.accessPoint = null;
    this.refreshUi();
  }

  protected abstract getConnectedApMenu(): SettingsBaseMenu | null;
}
