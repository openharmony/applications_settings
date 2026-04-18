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

import { Callback } from '@ohos.base';
import wifiManager from '@ohos.wifiManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { EventBus, EventCb } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { SettingDialogModel,
  SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { HiLinkLoadingComponent } from '../../component/HiLinkLoadingComponent';
import { ConnectFailedComponent } from '../../component/ConnectFailedComponent';
import {
  apConnectManager,
  WifiConnectListener,
  wifiTracker
} from '../../WifiTracker';
import {
  RANDOM_MAC_TYPE_CHANGED_EVENT,
  WifiConnectionState,
  WlanDisconnectedReason,
  WLAN_SWITCH_GROUP_ID,
} from '../../model/WifiModel';
import { WifiUtils } from '../../WifiUtils';
import { WifiPasswordConfigManager } from '../../WifiPasswordConfigManager';
import { PADDING_24 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { WifiMenuManager } from '../../WifiMenuManager';

const TAG = 'WifiHilinkController';

@Builder
function hiLinkLoadingBuilder(param: object): void {
  HiLinkLoadingComponent();
}

@Builder
function connectFailedBuilder(param: object): void {
  ConnectFailedComponent();
}

export class WifiHilinkController implements ComponentControl, WifiConnectListener {
  private apConfig: wifiManager.WifiDeviceConfig | undefined;
  private isHiLink: boolean = false;
  private isDisconnect: boolean = false;
  private bssid: string = '';
  private wlanSwitchGroupId: string = '';
  private onWifiConnectionChange: Callback<number> = (state: number): void => {
    LogUtil.info(`${TAG} onWifiConnectionChange : ${state}`);
    // hiLink 自动连接是先给2先断开
    if (state === WifiConnectionState.HILINK) {
      this.isDisconnect = true;
    }
    // 0表示才开始连接
    if (this.isDisconnect && state === WifiConnectionState.DISCONNECTED) {
      this.isDisconnect = false;
      apConnectManager.hiLinkConnecting(this);
      // 显示加载中弹窗
      ResourceUtil.getAnyStrFormatString($r('app.string.wifi_connecting'), this.apConfig?.ssid ?? '').then((result) => {
        this.showOrHideLoadingDialog(true, result);
      })
    }
  };
  private onRandomMacTypeChangeCallback: EventCb = (data: number) => {
    if (this.isHiLinkConnectSupport()) {
      (this.apConfig as wifiManager.WifiDeviceConfig).randomMacType = data;
      WifiUtils.enableHiLinkHandshake(true, this.bssid, this.apConfig as wifiManager.WifiDeviceConfig);
    }
  };

  constructor(config: wifiManager.WifiDeviceConfig | undefined, isHiLink?: boolean) {
    if (!config) {
      LogUtil.warn(`${TAG} apConfig is invalid`);
    }
    this.apConfig = config;
    this.isHiLink = isHiLink ?? false;
    this.bssid = this.apConfig?.bssid || '';
  }

  onConnectResult(result: number): void {
    LogUtil.info(`${TAG} onConnectResult: ${result}`);
    if (AppStorage.get<Boolean>('isConnectCancel')) {
      LogUtil.info(`${TAG} connect cancel, ignore result`);
      return;
    }
    this.showOrHideLoadingDialog(false);
    if (result) {
      LogUtil.info(`${TAG} connect success.`);
      // 关闭半模态
      notifyCompStateChange(`${PageRouter.getRouterName()}.Wlan.EditSheetConfig.EditSheet`,
        new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SHEET,
          {
            state: false,
          } as SettingCompState]]
        ));
      return;
    }
    if (!this.apConfig) {
      LogUtil.error(`${TAG} apConfig is undefined.`);
      return;
    }
    if (WifiUtils.needShowConnectFailedDialog(this.apConfig)) {
      this.showConnectFailedDialog();
    }
    let failReason: number = WifiUtils.getDisconnectedReason();
    if (failReason === WlanDisconnectedReason.DISC_REASON_IGNORE) {
      LogUtil.info(`${TAG} connect failed with ignore resaon, no need to handle.`);
      return;
    }
    if (failReason == WlanDisconnectedReason.WRONG_PWD) {
      LogUtil.info(`${TAG} connect with wrong pwd , remove wifi device.`);
      wifiTracker.removeWifiDevice(this.apConfig);
    }
  }

  init(): void {
  }

  destroy(): void {
  }

  aboutToAppear(): void {
    WifiUtils.wifiConnectionChangeOn(TAG, this.onWifiConnectionChange);
    if (this.isHiLinkConnectSupport()) {
      LogUtil.info(`${TAG} aboutToAppear, isHilink = ${this.isHiLink}, set hilink summary visible.`);
      WifiUtils.enableHiLinkHandshake(true, this.bssid, this.apConfig as wifiManager.WifiDeviceConfig);
    } else {
      LogUtil.info(`${TAG} aboutToAppear, set hilink summary invisible.`);
    }
    /* instrument ignore if*/
    if (WifiMenuManager.isExternalNetworkStage()) {
      this.wlanSwitchGroupId = 'OpenNetWorkSetting.NetworkSetting.WlanConfig.WlanSwitch';
    } else {
      this.wlanSwitchGroupId = WLAN_SWITCH_GROUP_ID;
    }
    EventBus.getInstance().on(RANDOM_MAC_TYPE_CHANGED_EVENT, this.onRandomMacTypeChangeCallback);
  }

  aboutToDisappear(): void {
    WifiUtils.wifiConnectionChangeOff(TAG, this.onWifiConnectionChange);
    if (this.isHiLinkConnectSupport()) {
      LogUtil.info(`${TAG} aboutToDisappear, disableHiLinkHandshake`);
      WifiUtils.enableHiLinkHandshake(false, this.bssid, this.apConfig as wifiManager.WifiDeviceConfig);
    } else {
      LogUtil.info(`${TAG} aboutToDisappear`);
    }
    EventBus.getInstance().detach(RANDOM_MAC_TYPE_CHANGED_EVENT, this.onRandomMacTypeChangeCallback);
  }

  private isHiLinkConnectSupport(): boolean {
    return this.isHiLink && !CheckEmptyUtils.isEmpty(this.apConfig);
  }

  private showOrHideLoadingDialog(isShow: boolean, content?: ResourceStr): void {
    if (isShow && content) {
      WifiPasswordConfigManager.getInstance().hiLinkLoadingContent = content;
    }
    if (isShow) {
      let state = new Map<SettingStateType, SettingDialogModel>([[SettingStateType.STATE_TYPE_ITEM_DIALOG,
        {
          contentBuilder: wrapBuilder(hiLinkLoadingBuilder),
          style: {
            // 框架侧读取是.left .right这种方式读取，因此无法直接写成padding: { 24 }
            padding: {
              start: PADDING_24,
              top: PADDING_24,
              end: PADDING_24,
              bottom: PADDING_24,
            },
          },
        } as SettingDialogModel]]);
      notifyCompStateChange(this.wlanSwitchGroupId, state);
    } else {
      let state = new Map<SettingStateType, SettingDialogModel>([[SettingStateType.STATE_TYPE_ITEM_DIALOG,
        {} as SettingDialogModel]]);
      notifyCompStateChange(this.wlanSwitchGroupId, state);
    }
  }

  private showConnectFailedDialog(): void {
    let state = new Map<SettingStateType, SettingDialogModel>([[SettingStateType.STATE_TYPE_ITEM_DIALOG,
      {
        contentBuilder: wrapBuilder(connectFailedBuilder),
        buttons: [
          {
            value: $r('app.string.dialog_know'),
            action: (component: SettingItemModel) => {
            }
          }
        ]
      } as SettingDialogModel]]);
    notifyCompStateChange(this.wlanSwitchGroupId, state);
  }
}