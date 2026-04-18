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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import wifiManager from '@ohos.wifiManager';
import taskpool from '@ohos.taskpool';
import { AccessPoint } from './model/WifiModel';
import { WifiUtils } from './WifiUtils';

export interface HotSpotTrackerListener {

  /**
   * 返回监听器的名称
   */
  getListenerName(): void;

  /**
   * HotSpotMenu菜单数据变化回调
   *
   * @param menu 数据变化的Ap菜单
   */
  onHotSpotMenuChanged(accessPoint: AccessPoint | null): void;

}

@Concurrent
function setSettingsDataPool(): void {
  SettingsDataUtils.setSettingsData('smartHotSpot', '');
}

const TAG: string = 'HotSpotTracker';
const SMART_HOTSPOT_KEY_CLICK: string = 'smartHotSpotClick';

export class HotSpotTracker {
  private isRegister: boolean = false;
  public hotSpotTrackerListenerList: HotSpotTrackerListener[] = [];
  public lastLinkedInfo: wifiManager.WifiLinkedInfo | null = null;

  constructor() {
  }

  // Wifi连接状态变化回调
  public onWifiConnectionChange = (state: number): void => {
    LogUtil.info(`${TAG} on HotSpot Wifi ConnectionChange : ${state}`);
    this.dealWifiConnectionChange();
  };

  async dealWifiConnectionChange(): Promise<void> {
    try {
      if (wifiManager.isConnected()) {
        LogUtil.info(`${TAG} wifi Connected`);
        this.lastLinkedInfo = await wifiManager.getLinkedInfo();
        if (this.lastLinkedInfo && this.lastLinkedInfo.connState !== 4) {
          LogUtil.error(`${TAG} lastLinkedInfo connState not connected`);
          return;
        }
        LogUtil.info(`${TAG} connState: ${this.lastLinkedInfo?.connState}, Connected netWorkId: ${this.lastLinkedInfo.networkId}, connState: ${this.lastLinkedInfo?.connState}`);
        let wifiDeviceConfig: wifiManager.WifiDeviceConfig | undefined = undefined;
        let configs: wifiManager.WifiDeviceConfig[] = wifiManager.getDeviceConfigs();
        if (configs && configs.length > 0) {
          for (let config of configs) {
            if (this.lastLinkedInfo.networkId === config.netId && this.lastLinkedInfo.ssid === config.ssid) {
              wifiDeviceConfig = config;
            }
          }
        }
        let accessPoint = new AccessPoint(null);
        if (!wifiDeviceConfig) {
          LogUtil.error(`${TAG} updateConnectedAp, find wifiDeviceConfig null.`);
        } else {
          accessPoint.setConfigs([wifiDeviceConfig]);
        }
        accessPoint.updateLastLinkedInfo(this.lastLinkedInfo);
        if (this.lastLinkedInfo) {
          accessPoint.supportedWifiCategory = this.lastLinkedInfo.supportedWifiCategory;
          accessPoint.isHiLinkNetwork = this.lastLinkedInfo.isHiLinkNetwork;
        }

        // 处理断开智能热点后，通过自动或者可用WLAN列表连接上智能热点场景
        if (SettingsDataUtils.getSettingsData('smartHotSpot', '') === '') {
          LogUtil.info(`${TAG} smartHotSpot info is null`);
          return;
        }
        AppStorage.SetOrCreate<boolean>(SMART_HOTSPOT_KEY_CLICK, false);
        this.hotSpotTrackerListenerList.forEach((listener, index) => {
          LogUtil.info(`${TAG} invoke listener onHotSpotMenuChanged : ${listener.getListenerName()}`);
          listener.onHotSpotMenuChanged(accessPoint);
        });
      } else {
        LogUtil.info(`${TAG} wifi disconnect`);
        this.clearSmartHotSpot()
      }
    } catch (error) {
      LogUtil.error(`${TAG} deal wifi connection change: ${error?.message}`);
      return;
    }
  }

  clearSmartHotSpot(): void {
    if (AppStorage.get<boolean>(SMART_HOTSPOT_KEY_CLICK)) {
      LogUtil.info(`${TAG} SMART_HOTSPOT_KEY_CLICK is true`);
    } else {
      try {
        let setSettingsDataTask: taskpool.Task = new taskpool.Task(setSettingsDataPool);
        taskpool.execute(setSettingsDataTask, taskpool.Priority.MEDIUM);
      } catch (error) {
        LogUtil.error(`${TAG} setSettingsDataTask catch code:${error?.code} message:${error?.message}`);
      }
    }
    this.hotSpotTrackerListenerList.forEach((listener, index) => {
      LogUtil.info(`${TAG} invoke listener onHotSpotMenuChanged : ${listener.getListenerName()}`);
      listener.onHotSpotMenuChanged(null);
    });
  }

  /**
   * 主动获取wifi连接状态
   * @returns
   */
  updateConnectedWifi(): void {
    LogUtil.info(`${TAG} updateConnectedWifi Info`);
    this.dealWifiConnectionChange();
  }

  onStart() {
    if (!this.isRegister) {
      LogUtil.info(`${TAG} onStart`);
      WifiUtils.wifiConnectionChangeOn(TAG, this.onWifiConnectionChange);
      this.isRegister = true;
    }
  }

  onStop() {
    if (this.isRegister) {
      LogUtil.info(`${TAG} onStop`);
      WifiUtils.wifiConnectionChangeOff(TAG, this.onWifiConnectionChange);
      this.isRegister = false;
    }
  }

  registerListener(hotSpotListener: HotSpotTrackerListener): void {
    if (!hotSpotListener) {
      LogUtil.error(`${TAG} registerListener invalid`);
      return;
    }

    for (const hotSpotTrackerListener of this.hotSpotTrackerListenerList) {
      if (hotSpotTrackerListener.getListenerName() === hotSpotListener.getListenerName()) {
        LogUtil.info(`${TAG} registerListener listener already register`);
        return;
      }
    }

    this.hotSpotTrackerListenerList.push(hotSpotListener);
    LogUtil.info(`${TAG} push ${hotSpotListener.getListenerName()} size: ${this.hotSpotTrackerListenerList.length}`);
  }

  unregisterListener(hotSpotListener: HotSpotTrackerListener): void {
    if (!hotSpotListener) {
      LogUtil.error(`${TAG} unregister hotSpotListener invalid`);
      return;
    }
    LogUtil.info(`${TAG} unregisterListener: ${hotSpotListener.getListenerName()}`);
    for (let index = 0; index < this.hotSpotTrackerListenerList.length; index++) {
      if (this.hotSpotTrackerListenerList[index].getListenerName() === hotSpotListener.getListenerName()) {
        LogUtil.info(`${TAG} unregisterLangChangeListener success: ${hotSpotListener.getListenerName()}`);
        this.hotSpotTrackerListenerList.splice(index, 1);
        return;
      }
    }
  }
}

export let hotSpotTracker = new HotSpotTracker();


