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
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import lazy { WifiState, WifiConnectionState } from '@ohos/settings.wifi/src/main/ets/model/WifiModel';
import { homeInitData } from '@ohos/settings.common/src/main/ets/sendable/HomeInitData';

const TAG = 'WlanController';

export class WlanController implements ComponentControl {
  // Wifi开关状态变化回调
  private onWifiStateChange = (state: number): void => {
    LogUtil.info(`${TAG} wifi state change : ${state}`);
    AppStorage.setOrCreate<number>('wifi_state', state);
    // 开启与关闭
    if ([WifiState.INACTIVE, WifiState.ACTIVE].includes(state)) {
      this.setWifiState();
    }
  }

  // Wifi连接状态变化回调
  private onWifiConnectionChange = (connectState: number): void => {
    LogUtil.info(`${TAG} onWifiConnectionChange: ${connectState}`);
    // 连接与断链
    if ([WifiConnectionState.DISCONNECTED, WifiConnectionState.CONNECTED].includes(connectState)) {
      this.setWifiState();
    }
  };

  init(compParam: CompCtrlParam): void {
    this.setWifiState();
    this.registerStateChange();
  }

  destroy(): void {
    this.unRegisterStateChange();
  }

  // 更新wifi状态、名称
  async setWifiState(): Promise<void> {
    homeInitData.wifiState = WifiUtils.isWifiActive();
    let state: boolean = homeInitData.wifiState;
    LogUtil.info(`${TAG} setWifiState wifiActive state: ${state}`);
    WifiUtils.updateWifiStateInStorage(state);

    let wlanState: ResourceStr = $r('app.string.bluetooth_state_on_text');
    if (state) {
      wlanState = $r('app.string.bluetooth_state_on_text');
      let wifiInfo = await WifiUtils.wifiLinkedInfoDetail();
      if (wifiInfo) {
        LogUtil.info(`${TAG} wlan ssid: ${WifiUtils.getLogSsidString(wifiInfo.ssid)} connState: ${wifiInfo.connState}`);
      } else {
        LogUtil.warn(`${TAG} wifiInfo is null`);
      }

      if (wifiInfo && wifiInfo.ssid !== '' && wifiInfo.connState === wifiManager.ConnState.CONNECTED) {
        wlanState = wifiInfo.ssid;
      }
    } else {
      wlanState = $r('app.string.bluetooth_state_off_text');
    }
    notifyCompStateChange('wifi_entry',
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: wlanState } } as SettingResultState]]));
  }

  private async registerStateChange(): Promise<void> {
    setTimeout(() => {
      try {
        wifiManager.on('wifiStateChange', this.onWifiStateChange);
        wifiManager.on('wifiConnectionChange', this.onWifiConnectionChange);
      } catch (error) {
        LogUtil.info(`${TAG} registerStateChange error: ${error?.message}`);
      }
    }, 100);
  }

  private async unRegisterStateChange(): Promise<void> {
    try {
      wifiManager.off('wifiStateChange', this.onWifiStateChange);
      wifiManager.off('wifiConnectionChange', this.onWifiConnectionChange);
    } catch (error) {
      LogUtil.info(`${TAG} unregisterStateChange error: ${error?.message}`);
    }
  }
}