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
import CommonEventManager from '@ohos.commonEventManager';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
/* instrument ignore file */
const TAG: string = 'HotspotConnectedController';

export class HotspotConnectedController implements ComponentControl {
  private compId: string = '';
  private stations: Array<wifiManager.StationInfo> = [];

  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_WIFI_AP_STA_JOIN,
      CommonEventManager.Support.COMMON_EVENT_WIFI_AP_STA_LEAVE,
      CommonEventManager.Support.COMMON_EVENT_WIFI_POWER_STATE,
      CommonEventManager.Support.COMMON_EVENT_WIFI_HOTSPOT_STATE,
    ]
  };

  private apConnectDevices: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    LogUtil.info(`${TAG} APConnectDevices connected`);
    this.updateStatus();
  });

  init(compParam: CompCtrlParam): void {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${TAG} init, compId: ${compParam.compId}`);
    this.compId = compParam.compId;
    this.apConnectDevices.registerCommonEvent();
    this.updateStatus();
  }

  destroy(): void {
    this.apConnectDevices.unRegisterCommonEvent();
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.updateStatus();
    this.apConnectDevices.registerCommonEvent();
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.apConnectDevices.unRegisterCommonEvent();
  }

  async updateStatus(): Promise<void> {
    try {
      this.stations = wifiManager.getStations();
    } catch (error) {
      LogUtil.error(`${TAG} getStations ： ${error?.message}`);
      this.stations = [];
    }
    let message: string = await ResourceUtil.getNumberFormatString($r('app.string.wifiap_connect_accounts'),
      this.stations.length.toString());
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: message } } as SettingResultState]]));
  }
}