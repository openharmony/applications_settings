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

import { wifiManager } from '@kit.ConnectivityKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import CommonEventManager from '@ohos.commonEventManager';
import { HotspotInfo } from '../../../Setting/MobileNetwork/HotSpot/HotspotWindowPage';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';

const TAG: string = 'HotspotDevicesWindowController: ';

export class HotspotDevicesWindowController {
  private hotspotList: Array<HotspotInfo> | undefined = undefined;
  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_WIFI_AP_STA_JOIN,
      CommonEventManager.Support.COMMON_EVENT_WIFI_AP_STA_LEAVE,
      CommonEventManager.Support.COMMON_EVENT_WIFI_POWER_STATE,
      CommonEventManager.Support.COMMON_EVENT_WIFI_HOTSPOT_STATE
    ]
  };
  private apConnectDevices: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    LogUtil.info(`${TAG} APConnectDevices connected`);
    this.getStationsFromWifiManager();
  });

  constructor() {
    LogUtil.info(`${TAG} constructor`);
  }

  public async getStationsFromWifiManager(): Promise<void> {
    try {
      let stations = wifiManager.getStations();
      this.hotspotList?.splice(0, this.hotspotList.length);
      LogUtil.info(`${TAG} getStationsFromWifiManager： ${stations.length}`);
      for (let index = 0; index < stations.length; index++) {
        let current = stations[index] as wifiManager.StationInfo;
        this.hotspotList?.push({
          deviceName: current.name,
          ipInfo: await ResourceUtil.getFormatString($r('app.string.wifi_ap_connected_user_ip'), current.ipAddress),
          macInfo: await ResourceUtil.getFormatString($r('app.string.wifi_ap_connected_user_mac'), current.macAddress)
        });
      }
    } catch (error) {
      LogUtil.error(`${TAG} getStations error： ${error?.code}, ${error?.message}`);
      this.hotspotList?.splice(0, this.hotspotList.length);
    }
  }

  public registerDataChange(): void {
    this.getStationsFromWifiManager();
    this.apConnectDevices.registerCommonEvent();
  }

  public unRegisterDataChange(): void {
    this.apConnectDevices.unRegisterCommonEvent();
  }

  public bindList(hotspotList: Array<HotspotInfo>) {
    this.hotspotList = hotspotList;
  }
}