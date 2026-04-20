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

import emitter from '@ohos.events.emitter';
import wifiManager from '@ohos.wifiManager';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import {
  EVENT_ID_WLAN_LIST_COLLAPSE_STATE_CHANGE,
  EVENT_ID_WLAN_LIST_COLLAPSE_STATE_RESET
} from '@ohos/settings.common/src/main/ets/event/types';
import { PageLifecycleMenuGroupController } from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import { MenuGroup } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import StatusbarPanelUtil from '@ohos/settings.commonUikit/src/main/ets/utils/StatusbarPanelUtil';
import { AccessPoint } from '../model/WifiModel';
import {
  WifiUtils,
  WIFI_SWITCH_KEY,
  IS_DEBUG,
  WIFI_LIST_GROUP,
  WIFI_WINDOW_LIST_GROUP,
  WIFI_INACTIVE_HEIGHT
} from '../WifiUtils';
import { REFRESH_LIST } from './WifiListBaseController';
import { WifiState, WifiConnectionState } from '../model/WifiModel';

/* instrument ignore file */
export const PLUGIN_WIFI_ICON_URL: string = 'pages/wifi/PluginWifiIcon.js';

const WIFI_SUBTITLE_HEIGHT: number = 32;
const WIFI_SECTION_HEIGHT: number = 56;
const DIVIDER_HEIGHT: number = 9;
const WIFI_CONNECTED_HEIGHT = WIFI_SUBTITLE_HEIGHT + WIFI_SECTION_HEIGHT + DIVIDER_HEIGHT;
const TAG: string = 'ConnectedApBaseController : ';

const DIALOG_MAX_HEIGHT: number = StatusbarPanelUtil.getWindowPanelMaxHeight();

/**
 * 已连接Wifi段信息展示控制器
 *
 * @since 2022-03-21
 */
export abstract class ConnectedApBaseController extends PageLifecycleMenuGroupController {
  public lastLinkedInfo: wifiManager.WifiLinkedInfo | null = null;
  public accessPoint?: AccessPoint;
  public targetState: number = 0;
  private isListExpand: boolean = true;
  private collapseStateChangeListener = (eventData: emitter.EventData) => {
    if (CheckEmptyUtils.isEmpty(eventData?.data) || CheckEmptyUtils.isEmpty(eventData?.data?.isListExpand)) {
      LogUtil.error(`${TAG} receive collapse state change event, but params is invalid.`);
      return;
    }
    this.isListExpand = eventData?.data?.isListExpand;
    LogUtil.info(`${TAG} receive collapse state change event: ${this.isListExpand}`);
  }
  private collapseStateResetListener = () => {
    LogUtil.info(`${TAG} receive collapse state reset event.`);
    this.isListExpand = true;
  }

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    try {
      if (wifiManager.isConnected()) {
        this.updateConnectedAp();
      } else {
        this.setVisible(false);
      }
    } catch (error) {
      LogUtil.error(`${TAG} get wifi connect state failed: ${error?.message}`);
    }
  }

  public onWifiStateChange = (state: number): void => {
    LogUtil.info(`${TAG} wifi state change : ${state}`);
    if (state !== this.targetState) {
      return;
    }
    if (state === 0) { // 关闭
      this.hideConnectedApChange();
    }
  }
  public onWifiConnectionChange = (state: number): void => {
    LogUtil.info(`${TAG} onWifiConnectionChange : ${state}`);
    if (state === WifiConnectionState.DISCONNECTED) {
      // 计算已连接wifi断开后的wifi控件高度
      if (AppStorage.Get('PluginWindowHeight')) {
        let pluginWindowHeight = Number(AppStorage.Get('PluginWindowHeight'));
        LogUtil.info(`${TAG} original pluginWindowHeight : ${pluginWindowHeight}`);
        if ((pluginWindowHeight !== WIFI_INACTIVE_HEIGHT) && this.isVisibleStatus()) {
          pluginWindowHeight = pluginWindowHeight - WIFI_SUBTITLE_HEIGHT - WIFI_SECTION_HEIGHT - DIVIDER_HEIGHT;
          WindowManager.updatePluginWindowHeight(PLUGIN_WIFI_ICON_URL, Math.min(DIALOG_MAX_HEIGHT, pluginWindowHeight));
        }
      }
      this.hideConnectedApChange();
    } else if (state === WifiConnectionState.CONNECTED) {
      this.updateConnectedAp(true);
    }
  };

  protected registerDataChange(): void {
    LogUtil.info(`${TAG} registerDataChange`);
    this.registerControllerDataChange(WIFI_SWITCH_KEY);
    this.registerControllerDataChange(WIFI_LIST_GROUP);
    this.registerControllerDataChange(WIFI_WINDOW_LIST_GROUP);
    WifiUtils.wifiStateChangeOn(TAG, this.onWifiStateChange);
    WifiUtils.wifiConnectionChangeOn(TAG, this.onWifiConnectionChange);
  }

  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    this.unRegisterControllerDataChange(WIFI_SWITCH_KEY);
    this.unRegisterControllerDataChange(WIFI_LIST_GROUP);
    this.unRegisterControllerDataChange(WIFI_WINDOW_LIST_GROUP);
    WifiUtils.wifiStateChangeOff(TAG, this.onWifiStateChange);
    WifiUtils.wifiConnectionChangeOff(TAG, this.onWifiConnectionChange);
  }

  public onDataChange(fromKey: string, data: Object): void {
    if (fromKey === WIFI_SWITCH_KEY && typeof data === 'number') {
      LogUtil.info(`${TAG} onDataChange fromKey:${fromKey} data:${data}`);
      this.targetState = data;
      this.onWifiStateChange(this.targetState);
    }

    if ((fromKey === WIFI_LIST_GROUP || fromKey === WIFI_WINDOW_LIST_GROUP) && (data as string) === REFRESH_LIST) {
      LogUtil.info(`${TAG} onDataChange fromKey:${fromKey} wifiList refresh`);
      this.getLastLinkedInfoAndUpdate();
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    super.aboutToAppear();
    emitter.on({
      eventId: EVENT_ID_WLAN_LIST_COLLAPSE_STATE_CHANGE,
    }, this.collapseStateChangeListener);
    emitter.on({
      eventId: EVENT_ID_WLAN_LIST_COLLAPSE_STATE_RESET,
    }, this.collapseStateResetListener);
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    super.aboutToDisappear();
    emitter.off(EVENT_ID_WLAN_LIST_COLLAPSE_STATE_CHANGE, this.collapseStateChangeListener);
    emitter.off(EVENT_ID_WLAN_LIST_COLLAPSE_STATE_RESET, this.collapseStateResetListener);
  }

  private getLastLinkedInfoAndUpdate(): void {
    if (wifiManager.isConnected() && this.targetState === WifiState.ACTIVE) {
      LogUtil.info(`${TAG} getLastLinkedInfoAndUpdate connected`);
      this.updateConnectedAp();
    } else {
      LogUtil.info(`${TAG} getLastLinkedInfoAndUpdate not connected`);
      this.hideConnectedApChange();
    }
  }

  private async updateConnectedAp(isPublishChange: boolean = false): Promise<void> {
    LogUtil.info(`${TAG} updateConnectedAp start`);
    this.lastLinkedInfo = await wifiManager.getLinkedInfo();
    LogUtil.debug(`${TAG} updateConnectedAp ${WifiUtils.getLogSsidString(this.lastLinkedInfo?.ssid)}, connState: ${this.lastLinkedInfo?.connState}`);
    if (isPublishChange) {
      this.publishDataChange(this.lastLinkedInfo?.ssid);
    }
    // 暂时规避，后期需要改为wifiManager.ConnState.CONNECTED
    if (this.lastLinkedInfo.connState !== 4) {
      LogUtil.error(`${TAG} lastLinkedInfo connState not connected`);
      this.hideConnectedApChange();
      return;
    }

    let wifiDeviceConfig: wifiManager.WifiDeviceConfig | undefined = undefined;
    let configs: wifiManager.WifiDeviceConfig[] = wifiManager.getDeviceConfigs();
    LogUtil.info(`${TAG} wifiManager getDeviceConfigs.length: ${configs?.length}`);
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
    this.accessPoint = accessPoint;
    let smartHotSpot = SettingsDataUtils.getSettingsData('smartHotSpot', '');
    LogUtil.info(`${TAG} this.accessPoint.ssid: ${WifiUtils.getLogSsidString(this.accessPoint.ssid)},
      smartHotSpot from SettingsData: ${WifiUtils.getLogSsidString(smartHotSpot)}`);
    if (this.accessPoint.ssid !== smartHotSpot) {
      this.onConnectedApChange();
      if (isPublishChange && AppStorage.get('PluginWindowHeight')) {
        let pluginWindowHeight: number = Number(AppStorage.get('PluginWindowHeight'));
        if (!this.isListExpand && this.isVisibleStatus()) {
          // 收起态WLAN面板在已连接成功的时候立马刷新高度
          pluginWindowHeight = pluginWindowHeight + WIFI_CONNECTED_HEIGHT;
          LogUtil.info(`${TAG} update connected wlan height pluginWindowHeight: ${pluginWindowHeight}`);
          WindowManager.updatePluginWindowHeight(PLUGIN_WIFI_ICON_URL, Math.min(DIALOG_MAX_HEIGHT, pluginWindowHeight));
        }
      }
    } else {
      this.setVisible(false);
    }
  }

  private hideConnectedApChange(): void {
    LogUtil.info(`${TAG} hideConnectedApChange`);
    if (this.menu instanceof MenuGroup) {
      this.menu.clear();
    }
    this.accessPoint = undefined;
    this.setVisible(false);
    this.refreshUi();
  }

  private onConnectedApChange(): void {
    LogUtil.info(`${TAG} onConnectedApChange`);
    if (!(this.menu instanceof MenuGroup) || !this.accessPoint) {
      return;
    }

    this.menu.updateMenus([this.getConnectedApMenu() as SettingsBaseMenu])

    if (!this.isVisibleStatus()) {
      this.setVisible(true);
    }
    this.scrollEdge(Edge.Top);
    this.refreshUi();
  }

  protected abstract getConnectedApMenu(): SettingsBaseMenu | null;
}
