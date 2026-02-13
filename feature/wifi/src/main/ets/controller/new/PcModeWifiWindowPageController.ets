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

import connection from '@ohos.net.connection';
import common from '@ohos.app.ability.common';
import commonEventManager from '@ohos.commonEventManager';
import wifiManager from '@ohos.wifiManager';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import {
  AccessPoint,
  ApMenu,
  WifiConnectionState,
  WifiSecurityType,
  WifiState,
} from '../../model/WifiModel';
import { AdvSecurityModeManager, ConnectScene, IConnectData } from '../../AdvSecurityModeManager';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  EVENT_ID_PC_MODE_WLAN_LIST_COLLAPSE_STATE_CHANGE,
  EVENT_ID_PC_MODE_WLAN_LIST_VISIBLE,
  EVENT_ID_PC_MODE_WLAN_SWITCH,
  EVENT_ID_PC_MODE_WLAN_CONNECTED_VISIBLE,
  EVENT_ID_PC_MODE_WLAN_ITEM_CLICK_EVENTS
} from '@ohos/settings.common/src/main/ets/event/types';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  NavEntryKey,
  PUBLISHER_PERMISSION_ACCESS_SYSTEM_SETTINGS,
} from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import StatusbarPanelUtil from '@ohos/settings.commonUikit/src/main/ets/utils/StatusbarPanelUtil';
import { Timer } from '@ohos/settings.common/src/main/ets/utils/Timer';
import { WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import { CONNECTED_AP_KEY, WifiUtils } from '../../WifiUtils';
import { apConnectManager, WifiConnectListener, wifiTracker, WifiTrackerListener, } from '../../WifiTracker';
import { PcModeWifiWindowDataSource } from '../../model/PcModeWifiWindowDataSource';
import { ShareWlanController } from './ShareWlanController';

/* instrument ignore file */
const TAG: string = 'PcModeWifiWindowPageController : ';
const PLUGIN_WIFI_WINDOW_URL: string = 'pages/wifi/PluginWifiIcon.js';

export interface WifiEntryParams {
  config: wifiManager.WifiDeviceConfig;
  isHiLinkNetwork: boolean;
  capabilities?: string;
  needShowModal?: boolean;
  isFromMoreSetting?: boolean;
}

const SCAN_INTERVAL: number = 10000;
const CONNECT_DELAYED: number = 50;
const WIFI_INACTIVE_HEIGHT: number = 109;
const WIFI_SUBTITLE_HEIGHT: number = 32;
const WIFI_SECTION_HEIGHT: number = 56;
const DIVIDER_HEIGHT: number = 9;
const SUBTITLE_COUNT: number = 2;
const WIFI_TITLE_MARGIN_BOTTOM: number = 4;
const DIALOG_MAX_HEIGHT: number = StatusbarPanelUtil.getWindowPanelMaxHeight();
const CUT_STEP_1: number = 1;

const netCon: connection.NetConnection = connection.createNetConnection({
  netCapabilities: {
    bearerTypes: [connection.NetBearType.BEARER_WIFI]
  }
});

export const AVAILABLE_LIST_MAX_HEIGHT_CONNECTED: number = DIALOG_MAX_HEIGHT - WIFI_INACTIVE_HEIGHT -
  WIFI_SUBTITLE_HEIGHT * SUBTITLE_COUNT - WIFI_SECTION_HEIGHT - DIVIDER_HEIGHT;

export const AVAILABLE_LIST_MAX_HEIGHT_UNCONNECTED: number = DIALOG_MAX_HEIGHT - WIFI_INACTIVE_HEIGHT -
  WIFI_SUBTITLE_HEIGHT;

export const PLUGIN_WIFI_ICON_URL: string = 'pages/wifi/PluginWifiIcon.js';

/**
 * PC模式控制中心wifi列表controller
 *
 * @since 2025-06-30
 */
export class PcModeWifiWindowPageController implements WifiTrackerListener, WifiConnectListener {
  public isLoaded: boolean = false;
  public lastLinkedInfo: wifiManager.WifiLinkedInfo | null = null;
  public accessPoint: AccessPoint | null = null;
  public timer: Timer | null = null;
  public isStarted: boolean = false;
  public targetState: number = WifiState.INACTIVE;
  private dataSource: PcModeWifiWindowDataSource | undefined = undefined;
  private isPortalUnauthenticated: boolean = false;
  private isNetworkUnavailable: boolean = false;
  private isShowingUnSaveDialog: boolean = false;
  private shareWlanController: ShareWlanController = new ShareWlanController();
  // 整个WLAN LIST组件是否可见
  private isListVisible: boolean = false;
  // 已连接WLAN是否可见
  private isConnectedApVisible: boolean = false;
  private currentTotalDataCnt: number = 0;
  // 可用WLAN列表是否展开
  private isAvailableListExpand: boolean = true;
  // 已连接的WLAN数据
  private connectedMenus: PcModeWifiWindowDataSource | undefined = undefined;
  private collapseStateChangeListener = (isListExpand: boolean) => {
    LogUtil.info(`${TAG} receive collapse state change event: ${isListExpand}`);
    this.onApMenusListCollapseStateChanged(isListExpand);
  }
  private subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [CommonEventConstant.EVENT_WLAN_UN_SAVE_DIALOG],
    publisherPermission: PUBLISHER_PERMISSION_ACCESS_SYSTEM_SETTINGS,
  };
  private closeUnSaveDialogEvent: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, async (err, data) => {
    if (err?.code) {
      LogUtil.error(`${TAG} subscribe failed ${err?.code}`);
      return;
    }
    LogUtil.info(`${TAG} receive close unSave dialog event ${data?.parameters?.continueJoin}`);
    this.isShowingUnSaveDialog = false;
    let apMenu: ApMenu | undefined = AdvSecurityModeManager.getInstance().getConnectData()?.apMenu;
    if (apMenu && apMenu.capabilities) {
      HiSysEventUtil.reportUnsafeWifiDialogButtonEvent(WifiUtils.getUnsafeNetworkType(apMenu.securityType,
        apMenu.capabilities), data.parameters?.continueJoin);
    }
    if (!data.parameters?.continueJoin) {
      return;
    }
    this.joinUnSavaNet(AdvSecurityModeManager.getInstance().getConnectData());
  });
  private onWifiRssiChange = (state: number): void => {
    if (this.isNetworkUnavailable) {
      LogUtil.info(`${TAG} network unavailable, don't update icon by signal.`);
      return;
    }
    LogUtil.info(`${TAG} wifi rssi change : ${state}`);
    // 返回以dBm为单位的RSSI值
    this.updateConnectedItemInfo();
  };
  private onNetCapabilitiesChange = (data: connection.NetCapabilityInfo): void => {
    let caps = data?.netCap?.networkCap;
    let bearerTypes = data?.netCap?.bearerTypes;
    LogUtil.info(`${TAG} netCapabilitiesChange, bearerTypes: ${bearerTypes?.join(',')}, caps: ${caps?.join(',')}`);
    if (!WifiUtils.isBearerWifi(bearerTypes)) {
      LogUtil.info(`${TAG} the network is not wifi, no need to handle.`);
      return;
    }
    if (WifiUtils.isWifiNetworkValidated(caps)) {
      this.isPortalUnauthenticated = false;
      this.isNetworkUnavailable = false;
    } else {
      this.isPortalUnauthenticated = WifiUtils.isPortalWifiNetwork(caps);
      this.isNetworkUnavailable = true;
    }
    // 刷新已连接网络显示
    this.updateConnectedItemInfo();
  };
  private onWifiStateChange = (state: number): void => {
    LogUtil.info(`${TAG} onWifiStateChange state: ${state}, targetState: ${this.targetState}`);
    if (state !== this.targetState) {
      return;
    }
    if (state === WifiState.INACTIVE) {
      this.isListVisible = false;
      // 停止扫描
      this.stopTimer();
    } else if (state == WifiState.ACTIVE) {
      if (WifiUtils.isWifiActive()) {
        this.isListVisible = true;
        // 开始扫描
        this.startTimer();
      }
    }
  };
  private onWifiConnectionChange = (state: number): void => {
    // 控制中心这里连接上的时候立马去拿扫描结果用来把列表刷新已连接
    if (state === WifiConnectionState.CONNECTED) {
      wifiTracker.updateAll();
    }
    if (state === WifiConnectionState.DISCONNECTED) {
      if (AppStorage.get('PluginWindowHeight')) {
        let pluginWindowHeight: number = Number(AppStorage.get('PluginWindowHeight'));
        LogUtil.info(`${TAG} original pluginWindowHeight : ${pluginWindowHeight}`);
        if ((pluginWindowHeight !== WIFI_INACTIVE_HEIGHT) && this.isConnectedApVisible) {
          pluginWindowHeight = pluginWindowHeight - WIFI_SUBTITLE_HEIGHT - WIFI_SECTION_HEIGHT - DIVIDER_HEIGHT;
          WindowManager.updatePluginWindowHeight(PLUGIN_WIFI_ICON_URL, Math.min(DIALOG_MAX_HEIGHT, pluginWindowHeight));
        }
      }
    }
    LogUtil.info(`${TAG} wifi connection state change : ${state}`);
    this.getLastLinkedInfoAndUpdate();
  };
  private onMenuClick = (clickedApMenu: ApMenu) => {
    if (!clickedApMenu) {
      LogUtil.info(`${TAG} onMenuClick occurs error.`);
      return;
    }
    // 已连接网络
    if (clickedApMenu.isShowConnected) {
      if (this.isPortalUnauthenticated) {
        LogUtil.info(`${TAG} onMenuClick: start portal certification.`)
        WifiUtils.startPortalCertification();
      }
      return;
    }
    LogUtil.info(`${TAG} onMenuClick, ${WifiUtils.getApLogKey(clickedApMenu.ssid, clickedApMenu.securityType)}`);
    if (WifiUtils.isOpenAp(clickedApMenu.securityType) && !clickedApMenu.config) {
      if (AdvSecurityModeManager.getInstance().isNeedShowWifiUnsafeDialog(clickedApMenu.securityType ?? 0,
        clickedApMenu.capabilities ?? '', clickedApMenu.ssid ?? '')) {
        AdvSecurityModeManager.getInstance().setConnectData({
          connectScene: ConnectScene.CONTROL_CENTER_WLAN_LIST,
          apMenu: clickedApMenu,
        });
        this.isShowingUnSaveDialog = true;
        AdvSecurityModeManager.getInstance()
          .showWifiUnsafeDialog(AbilityContextManager.getContext() as common.UIAbilityContext);
        return;
      }
      // 未保存的开放网络直接连
      this.connectOpenAp(clickedApMenu);
      return;
    }
    LogUtil.info(`${TAG} onMenuClick openDialog`);
    this.openConnectPage(clickedApMenu);
  };

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear `);
    this.isListVisible = WifiUtils.isWifiActive();
    this.isShowingUnSaveDialog = false;
    let connectAccessPoint: AccessPoint | undefined = wifiTracker.getConnectAccessPoint()
    if (connectAccessPoint) {
      this.accessPoint = connectAccessPoint;
    }
    wifiTracker.setListener(this);
    this.registerDataChange();
    this.startWifiTimerAndTracker();
    wifiTracker.loadCacheMenus();
    this.getLastLinkedInfoAndUpdate();
    this.isLoaded = true;
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear `);
    this.unRegisterDataChange();
    this.stopWifiTimerAndTracker();
    this.timer = null;
    wifiTracker.onQuit();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow `);
    this.startWifiTimerAndTracker();
    if (!this.isLoaded) {
      this.getLastLinkedInfoAndUpdate();
      this.isLoaded = true;
    }
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide `);
    this.shareWlanController.onPageHide();
    // 结束扫描
    this.stopWifiTimerAndTracker();
    this.isLoaded = false;
  }

  onConnectResult(result: number): void {
    LogUtil.info(`${TAG} onConnectResult: ${result}`);
  }

  onApMenuChanged(menu: ApMenu): void {
  }

  onApMenusChanged(data: ApMenu[]): void {
    LogUtil.info(`${TAG} onApMenusChanged, isShowingUnSaveDialog: ${this.isShowingUnSaveDialog}, isAvailableListShow: ${this.isAvailableListExpand}`);
    if (this.isShowingUnSaveDialog) {
      return;
    }
    if (!this.dataSource) {
      LogUtil.error(`${TAG} onApMenusChanged failed. dataSource is undefined.`);
      return;
    }
    this.dataSource.clearAll();
    this.connectedMenus?.clearAll();

    this.getLastLinkedInfoAndUpdate();

    // 已连接的热点
    if (this.accessPoint && WifiUtils.isWifiConnected() && this.connectedMenus) {
      this.connectedMenus.pushData(this.getConnectedApMenu(this.accessPoint));
      this.connectedMenus.notifyDataReload();
      LogUtil.info(`${TAG} onApMenusChanged add connectedMenus`);
    } else {
      LogUtil.info(`${TAG} accessPoint invalid`);
    }

    if ((!data || data.length === 0) && this.dataSource.totalCount() === 0) {
      LogUtil.info(`${TAG} data is empty`);
      this.dataSource.notifyDataReload();
      return;
    }

    for (let i = 0; i < data.length; i++) {
      this.dataSource.pushData(data[i]);
    }
    this.dataSource.notifyDataReload();
    this.currentTotalDataCnt = this.dataSource.totalCount();

    LogUtil.info(`${TAG} onApMenusChanged ${this.dataSource.totalCount()}`);
    if (!this.isListVisible) {
      LogUtil.info(`${TAG} wifiAvailableList not visible`);
      return;
    }

    let height: number = this.calculateWindowHeight();
    AppStorage.setOrCreate('PluginWindowHeight', Math.min(DIALOG_MAX_HEIGHT, height));
    LogUtil.info(`${TAG} onApMenusChanged, height: ${height},maxHeight: ${DIALOG_MAX_HEIGHT} Math.min ${Math.min(DIALOG_MAX_HEIGHT,
      height)}`);
    WindowManager.updatePluginWindowHeight(PLUGIN_WIFI_ICON_URL, Math.min(DIALOG_MAX_HEIGHT, height));
    LogUtil.info(`${TAG} onApListChanged end`);
  }

  onApMenusListCollapseStateChanged(isListExpand: boolean): void {
    LogUtil.info(`${TAG} onApMenusListVisibleChanged, isListExpand: ${isListExpand}, totalDataCnt: ${this.currentTotalDataCnt}`);
    this.isAvailableListExpand = isListExpand;

    if (!this.isListVisible) {
      LogUtil.info(`${TAG} wifiListComponent not visible`);
      return;
    }

    if (this.currentTotalDataCnt <= 0) {
      LogUtil.info(`${TAG} wifiList not ready, operate later.`);
      return;
    }

    let height: number = this.calculateWindowHeight();

    AppStorage.setOrCreate('PluginWindowHeight', Math.min(DIALOG_MAX_HEIGHT, height));
    LogUtil.info(`${TAG} onApMenusListCollapseChanged, height: ${height}, maxHeight: ${DIALOG_MAX_HEIGHT},
      Math.min ${Math.min(DIALOG_MAX_HEIGHT, height)}`);
    WindowManager.updatePluginWindowHeight(PLUGIN_WIFI_ICON_URL, Math.min(DIALOG_MAX_HEIGHT, height));
    LogUtil.info(`${TAG} onApMenusListCollapseChanged end`);
  }


  public bindList(dataSource: PcModeWifiWindowDataSource): void {
    this.dataSource = dataSource;
  }

  public bindConnectedWifiList(connectedMenus: PcModeWifiWindowDataSource): void {
    this.connectedMenus = connectedMenus;
  }

  public resetCollapseState(): void {
    this.isAvailableListExpand = true;
  }

  private hideOrShowList(isShow: boolean): void {
    this.isListVisible = isShow;
    EventBus.getInstance().emit(EVENT_ID_PC_MODE_WLAN_LIST_VISIBLE, isShow);
  }

  private calculateWindowHeight(): number {
    let height: number = 0;
    let sharedMenuSize: number = Number(AppStorage.get('SharedMenuSize'));
    if (this.isAvailableListExpand) {
      if (wifiManager.isConnected()) {
        // 高度计算需要计算已连接WLAN和可用WLAN高度，所以高度需要乘以2，已连接状态的data数量统计时会减一所以需要加1统计
        height = WIFI_INACTIVE_HEIGHT + WIFI_SUBTITLE_HEIGHT * SUBTITLE_COUNT +
          (this.currentTotalDataCnt + CUT_STEP_1) * WIFI_SECTION_HEIGHT + DIVIDER_HEIGHT + WIFI_TITLE_MARGIN_BOTTOM;
      } else {
        height = WIFI_INACTIVE_HEIGHT + WIFI_SUBTITLE_HEIGHT + this.currentTotalDataCnt * WIFI_SECTION_HEIGHT +
          WIFI_TITLE_MARGIN_BOTTOM;
      }
    } else {
      if (wifiManager.isConnected()) {
        height = WIFI_INACTIVE_HEIGHT + WIFI_SUBTITLE_HEIGHT * SUBTITLE_COUNT +
          CUT_STEP_1 * WIFI_SECTION_HEIGHT + DIVIDER_HEIGHT + WIFI_TITLE_MARGIN_BOTTOM;
      } else {
        height = WIFI_INACTIVE_HEIGHT + WIFI_SUBTITLE_HEIGHT + WIFI_TITLE_MARGIN_BOTTOM;
      }
    }

    if (sharedMenuSize) {
      return height + WIFI_SUBTITLE_HEIGHT + sharedMenuSize * WIFI_SECTION_HEIGHT + DIVIDER_HEIGHT;
    }
    return height;
  }

  /**
   * 这里只会接受按钮的回调 专门处理列表是否显示
   */
  private onSwitchStateChange = (toggleState: number): void => {
    this.targetState = toggleState;
    LogUtil.info(`${TAG} onSwitchStateChange toggleState: ${toggleState}`);
    if (toggleState === WifiState.INACTIVE) { // 关闭
      this.resetWindowHeight();
      this.hideApList();
    }
    this.hideOrShowList(toggleState === WifiState.ACTIVE);
  }

  private hideApList(): void {
    LogUtil.info(`${TAG} hideApList `);
    if (!this.isListVisible) {
      LogUtil.info(`${TAG} clear all data.`);
      this.dataSource?.clearAll();
    }
  }

  private resetWindowHeight(): void {
    AppStorage.setOrCreate('PluginWindowHeight', WIFI_INACTIVE_HEIGHT);
    WindowManager.updatePluginWindowHeight(PLUGIN_WIFI_ICON_URL, WIFI_INACTIVE_HEIGHT);
    this.resetCollapseState();
  }

  private connectOpenAp(menu?: ApMenu): void {
    if (!menu) {
      LogUtil.error(`${TAG} connectOpenAp failed, menu is null.`);
      return;
    }
    let config = {
      ssid: menu.ssid, securityType: menu.securityType
    } as wifiManager.WifiDeviceConfig;
    this.startConnect(config, false, this);
    if (menu.index) {
      menu.summary = $r('app.string.wifi_status_connecting');
      this.dataSource?.updateData(menu.index, menu);
    }
  }

  private openConnectPage(detailApMenu: ApMenu): void {
    if (detailApMenu.config) {
      if (AdvSecurityModeManager.getInstance().isNeedShowWifiUnsafeDialog(detailApMenu.securityType ?? 0,
        detailApMenu.capabilities ?? '', detailApMenu.ssid ?? '')) {
        AdvSecurityModeManager.getInstance().setConnectData({
          connectScene: ConnectScene.CONTROL_CENTER_WLAN_LIST,
          apMenu: detailApMenu,
        });
        this.isShowingUnSaveDialog = true;
        WindowManager.closePluginWindow(PLUGIN_WIFI_ICON_URL, false);
        AdvSecurityModeManager.getInstance()
          .showWifiUnsafeDialog(AbilityContextManager.getContext() as common.UIAbilityContext);
        return;
      }
      // 已保存网络
      this.startConnect(detailApMenu.config, false, this);
      detailApMenu.summary = $r('app.string.wifi_status_connecting');
    } else {
      let apConfig = WifiUtils.getWifiConfig(detailApMenu) as wifiManager.WifiDeviceConfig;
      let bundleName = PackagesConstant.SETTINGS_BUNDLE_NAME;
      let abilityName = PackagesConstant.SETTINGS_MAIN_ABILITY_NAME;
      let navEntryKey = NavEntryKey.WIFI_ENTRY;
      let message: string = `bundleName: ${bundleName}, abilityName: ${abilityName}, navEntryKey: ${navEntryKey}`;
      LogUtil.info(`${TAG} openConnectPage: ${message}`);
      const param: WifiEntryParams = {
        config: apConfig,
        isHiLinkNetwork: detailApMenu.isHiLinkNetwork,
        capabilities: detailApMenu.capabilities,
        // 进入WLAN列表界面后，展示密码输入半模态
        needShowModal: true,
        isFromMoreSetting: true,
      };
      if (bundleName && abilityName) {
        AbilityUtils.startAbilityForResult({
          bundleName: bundleName,
          abilityName: abilityName,
          uri: navEntryKey,
          parameters: {
            pushParams: param,
          },
        }, () => {
          // 关闭wifi plugin弹窗
          WindowManager.closePluginWindow(PLUGIN_WIFI_WINDOW_URL, true);
        });
      }
    }
  }

  private startConnect(config: wifiManager.WifiDeviceConfig, isConfigUpdate: boolean, listener:
    WifiConnectListener): void {
    setTimeout(() => {
      apConnectManager.startConnect(config, isConfigUpdate, listener);
    }, CONNECT_DELAYED);
  }

  private registerDataChange(): void {
    LogUtil.info(`${TAG} registerDataChange`);
    EventBus.getInstance().on(EVENT_ID_PC_MODE_WLAN_ITEM_CLICK_EVENTS, this.onMenuClick);
    EventBus.getInstance().on(EVENT_ID_PC_MODE_WLAN_SWITCH, this.onSwitchStateChange);
    EventBus.getInstance().on(EVENT_ID_PC_MODE_WLAN_LIST_COLLAPSE_STATE_CHANGE, this.collapseStateChangeListener);

    this.closeUnSaveDialogEvent.registerCommonEvent();
    WifiUtils.wifiStateChangeOn(TAG, this.onWifiStateChange);
    WifiUtils.wifiConnectionChangeOn(TAG, this.onWifiConnectionChange);
    WifiUtils.wifiRssiChangeOn(TAG, this.onWifiRssiChange);
    WifiUtils.registerNetCapabilitiesChange(netCon, this.onNetCapabilitiesChange, TAG);
  }

  private unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    this.closeUnSaveDialogEvent.unRegisterCommonEvent();
    EventBus.getInstance().detach(EVENT_ID_PC_MODE_WLAN_ITEM_CLICK_EVENTS, this.onMenuClick);
    EventBus.getInstance().detach(EVENT_ID_PC_MODE_WLAN_SWITCH, this.onSwitchStateChange);
    EventBus.getInstance().detach(EVENT_ID_PC_MODE_WLAN_LIST_COLLAPSE_STATE_CHANGE, this.collapseStateChangeListener);
    WifiUtils.wifiStateChangeOff(TAG, this.onWifiStateChange);
    WifiUtils.wifiConnectionChangeOff(TAG, this.onWifiConnectionChange);
    WifiUtils.wifiRssiChangeOff(TAG, this.onWifiRssiChange);
    WifiUtils.unRegisterNetCapabilitiesChange(netCon, TAG);
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
      this.onConnectedApChange(true);
      if (this.accessPoint?.isSameAp(accessPoint)) {
        LogUtil.warn(`${TAG} updateConnectedAp, ap is same, return`);
        return;
      }
      LogUtil.info(`${TAG} updateConnectedAp: ${accessPoint?.toString()}`);
      this.accessPoint = accessPoint;
      if (this.connectedMenus && this.dataSource) {
        // 如果可用列表有此热点 切换连接视图的时候 需要先删除掉 避免视图短暂有两个同名的item
        let connectedIndex: number =
          this.dataSource.getArray().findIndex(item => (item.ssid === this.accessPoint?.ssid &&
            item.securityType === this.accessPoint?.securityType));
        LogUtil.info(`${TAG} updateConnectedAp, removeDataByIndex connectedIndex: ${connectedIndex}`);
        if (connectedIndex !== -1) {
          this.dataSource.removeDataByIndex(connectedIndex);
        }
        // 已连接wifi切换更新时及时刷新数据
        this.connectedMenus.clearAll();
        this.connectedMenus.pushData(this.getConnectedApMenu(this.accessPoint));
      }
      this.updateSharePage();
    } catch (error) {
      LogUtil.error(`${TAG} update connected ap error: ${error?.message}`);
    }
  }

  private onConnectedApChange(isShow: boolean): void {
    this.isConnectedApVisible = isShow;
    EventBus.getInstance().emit(EVENT_ID_PC_MODE_WLAN_CONNECTED_VISIBLE, isShow);
  }

  private updateSharePage(): void {
    if (this.isLoaded) {
      this.shareWlanController.setAccessPoint(this.accessPoint as AccessPoint);
      this.shareWlanController.onPageShow();
    }
  }

  private async updateConnectedItemInfo(): Promise<void> {
    LogUtil.info(`${TAG} update linked menu info, portal state: ${this.isPortalUnauthenticated}, network unavailable state: ${this.isNetworkUnavailable}`);
    if (!this.connectedMenus || this.connectedMenus.totalCount() === 0) {
      LogUtil.error(`${TAG} update connected item error: data is empty.`);
      return;
    }
    if (!this.accessPoint) {
      LogUtil.error(`${TAG} accessPoint is empty.`);
      return;
    }
    let connectedApMenu: ApMenu | undefined = undefined;
    let connectedApMenuIndex: number = 0;
    for (let i = 0; i < this.connectedMenus.totalCount(); i++) {
      let item: ApMenu = this.connectedMenus.getData(i);
      if (item.isShowConnected) {
        connectedApMenuIndex = i;
        connectedApMenu = item;
        break;
      }
    }
    if (!connectedApMenu) {
      LogUtil.error(`${TAG} do not find connected ap menu.`);
      return;
    }
    let isUnsecuredWifi: boolean = this.accessPoint?.isUnsecuredWifiDetect();
    connectedApMenu.accessibilityDescription = this.isPortalUnauthenticated ? '' : ' ';
    if (this.isNetworkUnavailable) {
      connectedApMenu.stateIcon = WifiUtils.getNetworkUnavailableStateIcon(this.accessPoint);
      connectedApMenu.summary = WifiUtils.getConnectedSummary(this.isPortalUnauthenticated, isUnsecuredWifi);
    } else {
      let lastLinkedInfo: wifiManager.WifiLinkedInfo | undefined = await WifiUtils.getLinkedInfo();
      if (!lastLinkedInfo) {
        LogUtil.warn(`${TAG} empty lastLinkedInfo, update linked menu failed.`);
        return;
      }
      LogUtil.info(`${TAG} update linked menu icon and summary to normal state.`);
      this.accessPoint.updateLastLinkedInfo(lastLinkedInfo);
      connectedApMenu.stateIcon = this.accessPoint.getStateIcon();
      connectedApMenu.summary = WifiUtils.getConnectedSummary(false, isUnsecuredWifi);
    }
    this.connectedMenus.updateData(connectedApMenuIndex, connectedApMenu);
  }

  private startTimer(): void {
    this.getTimer().restart();
  }

  private stopTimer(): void {
    if (this.timer) {
      this.timer.stop();
    }
  }

  private hideConnectedApChange(): void {
    LogUtil.info(`${TAG} hideConnectedApChange`);
    this.accessPoint = null;
    if (!this.connectedMenus || this.connectedMenus.totalCount() === 0) {
      return;
    }
    for (let i = 0; i < this.connectedMenus.totalCount(); i++) {
      let item: ApMenu = this.connectedMenus.getData(i);
      if (item.isShowConnected) {
        LogUtil.info(`${TAG} update connectedMenus: onWifiDisConnected.`);
        this.connectedMenus?.removeDataByIndex(i);
        this.onConnectedApChange(false);
        return;
      }
    }
  }

  private startWifiTimerAndTracker(): void {
    LogUtil.info(`${TAG} startWifiTimerAndTracker isStarted:${this.isStarted}`);
    wifiTracker.onStart();
    if (!this.isStarted) {
      this.startTimer();
      this.isStarted = true;
    }
  }

  private stopWifiTimerAndTracker(): void {
    LogUtil.info(`${TAG} stopWifiTimerAndTracker isStarted:${this.isStarted}`);
    wifiTracker.onStop();
    if (this.isStarted) {
      this.stopTimer();
      this.isStarted = false;
    }
  }

  private getTimer(): Timer {
    if (!this.timer) {
      this.timer = new Timer(SCAN_INTERVAL, () => {
        LogUtil.info(`${TAG} scanOnce`);
        this.scanOnce();
      })
    }
    return this.timer;
  }

  private scanOnce(): void {
    if (!this.isStarted) {
      return;
    }
    wifiTracker.scanAp();
  }

  private getConnectedApMenu(accessPoint: AccessPoint): ApMenu {
    let isUnsecuredWifi: boolean | undefined = this.accessPoint?.isUnsecuredWifiDetect();
    let menu: ApMenu = new ApMenu({
      title: accessPoint.getTitle(),
      ssid: accessPoint.ssid,
      bssid: accessPoint.bestBssid,
      bssidType: accessPoint.bssidType,
      securityType: accessPoint.securityType,
      config: accessPoint.getBestConfig(),
      supportedWifiCategory: accessPoint.supportedWifiCategory,
      isHiLinkNetwork: accessPoint.isHiLinkNetwork,
      scanResults: accessPoint.scanResults,
      isShowConnected: true,
      stateIcon: this.isNetworkUnavailable ? WifiUtils.getNetworkUnavailableStateIcon(accessPoint) :
      accessPoint.getStateIcon(),
      summary: this.isNetworkUnavailable ?
      WifiUtils.getConnectedSummary(this.isPortalUnauthenticated, isUnsecuredWifi) :
      WifiUtils.getConnectedSummary(false, isUnsecuredWifi),
      key: CONNECTED_AP_KEY + accessPoint.apKey,
      index: 0,
      accessibilityDescription: this.isPortalUnauthenticated ? '' : ' ',
    });
    return menu;
  }

  private joinUnSavaNet(connectData?: IConnectData): void {
    if (connectData?.connectScene !== ConnectScene.CONTROL_CENTER_WLAN_LIST) {
      LogUtil.error(`${TAG} connectScene is wrong.`);
      return;
    }
    if (connectData.apMenu?.securityType === WifiSecurityType.WIFI_SEC_TYPE_OPEN) {
      this.connectOpenAp(connectData.apMenu);
      return;
    }
    let apMenu: ApMenu | undefined = connectData.apMenu;
    if (!apMenu) {
      LogUtil.error(`${TAG} joinUnSavaNet failed, apMenu is null.`);
      return;
    }
    this.startConnect(apMenu.config, false, this);
    apMenu.summary = $r('app.string.wifi_status_connecting');
    this.dataSource?.updateData(apMenu.index ?? 0, apMenu);
    AdvSecurityModeManager.getInstance().clearConnectData();
  }
}