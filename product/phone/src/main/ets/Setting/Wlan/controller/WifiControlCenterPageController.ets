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
import connection from '@ohos.net.connection';
import wifiManager from '@ohos.wifiManager';
import settings from '@ohos.settings';
import common from '@ohos.app.ability.common';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import {
  NavEntryKey,
  PUBLISHER_PERMISSION_ACCESS_SYSTEM_SETTINGS,
} from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Timer } from '@ohos/settings.common/src/main/ets/utils/Timer';
import { WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import {
  AdvSecurityModeManager,
  ConnectScene,
  IConnectData
} from '@ohos/settings.wifi/src/main/ets/AdvSecurityModeManager';
import {
  AccessPoint,
  ApMenu,
  WifiConnectionState,
  WifiSecurityType,
  WifiState,
} from '@ohos/settings.wifi/src/main/ets/model/WifiModel';
import {
  apConnectManager,
  WifiConnectListener,
  wifiTracker,
  WifiTrackerListener,
} from '@ohos/settings.wifi/src/main/ets/WifiTracker';
import {
  WIFI_CLOUD_SECURITY_CHECK,
  WIFI_CLOUD_SECURITY_ENABLED,
  WIFI_CLOUD_SECURITY_DISABLED,
} from '@ohos/settings.common/src/main/ets/utils/Consts';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import commonEventManager from '@ohos.commonEventManager';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { CONNECTED_AP_KEY, WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import { WifiManager } from '@ohos/settings.wifi/src/main/ets/WifiManager';
import { ShareWlanController } from '@ohos/settings.wifi/src/main/ets/controller/new/ShareWlanController';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { ControlCenterWlanDataSource } from '../model/ControlCenterWlanDataSource';
import { UIExtensionContentSession } from '@kit.AbilityKit';

const TAG: string = 'WifiControlCenterPageController : ';
const DELAY: number = 100;
const PLUGIN_WIFI_WINDOW_URL: string = 'pages/wifi/model/WifiWindowPage.js';

export interface WifiEntryParams {
  config: wifiManager.WifiDeviceConfig;
  isHiLinkNetwork: boolean;
  capabilities?: string;
  needShowModal?: boolean;
  isFromMoreSetting?: boolean;
}

const SCAN_INTERVAL: number = 10000;

const SCAN_LOADING_INTERVAL: number = 2000;

const CONNECT_DELAYED: number = 50;

const netCon: connection.NetConnection = connection.createNetConnection({
  netCapabilities: {
    bearerTypes: [connection.NetBearType.BEARER_WIFI]
  }
});

/**
 * 控制中心wifi列表controller
 *
 * @since 2024-10-18
 */
export default class WifiControlCenterPageController implements WifiTrackerListener, WifiConnectListener {
  public isLoaded: boolean = false;
  public lastLinkedInfo: wifiManager.WifiLinkedInfo | null = null;
  public accessPoint: AccessPoint | null = null;
  public timerId: number | null = null;
  public timer: Timer | null = null;
  public isStarted: boolean = false;
  public targetState: number = WifiState.INACTIVE;
  public loadingTaskId: number | null = null;
  public customState: string = '';
  private dataSource: ControlCenterWlanDataSource | undefined = undefined;
  private isPortalUnauthenticated: boolean = false;
  private isNetworkUnavailable: boolean = false;
  private isShowingUnSaveDialog: boolean = false;
  private shareWlanController: ShareWlanController = new ShareWlanController();
  // 当前是否在外屏
  private isOuterScreen: boolean = CommonUtils.isOuterScreen();
  private subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [CommonEventConstant.EVENT_WLAN_UN_SAVE_DIALOG],
    publisherPermission: PUBLISHER_PERMISSION_ACCESS_SYSTEM_SETTINGS,
  };
  private closeUnSaveDialogEvent: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, async (err, data) => {
    LogUtil.info(`${TAG} receive close unSave dialog event ${data.parameters?.continueJoin}`);
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
  public onWifiStateChange = (state: number): void => {
    LogUtil.info(`${TAG} onWifiStateChange state: ${state}`);
    if (state !== this.targetState) {
      return;
    }
    if (state === WifiState.INACTIVE) {
      // 停止扫描
      this.stopTimer();
    } else if (state == WifiState.ACTIVE) {
      if (WifiUtils.isWifiActive()) {
        // 开始扫描
        this.startTimer();
      }
    }
  };
  public onWifiConnectionChange = (state: number): void => {
    // 控制中心这里连接上的时候立马去拿扫描结果用来把列表刷新已连接
    if (state === WifiConnectionState.CONNECTED) {
      wifiTracker.updateAll();
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
      if (this.isOuterScreen) {
        LogUtil.info(`${TAG} outScreen unSaved wlan clicked`);
        ToastUtil.showToast(ResourceUtil.getStringSync($r('app.string.expand_phone_use')), ToastUtil.SHORT_DURATION);
        return;
      }
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
    this.isShowingUnSaveDialog = false;
    let isChecked: boolean =
      SettingsDataUtils.getSettingsDataDomain(WIFI_CLOUD_SECURITY_CHECK, WIFI_CLOUD_SECURITY_DISABLED,
        settings.domainName.DEVICE_SHARED) === WIFI_CLOUD_SECURITY_ENABLED;
    WifiManager.getInstance().setWifiSecuritySwitchStatus(isChecked);
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
    LogUtil.info(`${TAG} onApMenusChanged, isShowingUnSaveDialog: ${this.isShowingUnSaveDialog}`);
    if (this.isShowingUnSaveDialog) {
      return;
    }
    if (!this.dataSource) {
      LogUtil.error(`${TAG} onApMenusChanged failed. dataSource is undefined.`);
      return;
    }
    this.dataSource.clearAll();
    // 已连接的wifi
    if (this.accessPoint && WifiUtils.isWifiConnected()) {
      LogUtil.info(`${TAG} onApMenusChanged getConnectedApMenu`);
      this.dataSource.pushData(this.getConnectedApMenu(this.accessPoint));
    } else {
      LogUtil.info(`${TAG} accessPoint invalid`);
    }
    if ((!data || data.length === 0) && this.dataSource.totalCount() === 0) {
      LogUtil.info(`${TAG} data is empty`);
      this.dataSource.notifyDataReload();
      return;
    }
    let step: number = this.accessPoint ? 1 : 0;
    for (let i = 0; i < data.length; i++) {
      data[i].index = i + step;
      this.dataSource.pushData(data[i]);
    }
    this.dataSource.notifyDataReload();
    LogUtil.info(`${TAG} onApMenusChanged ${this.dataSource.totalCount()}`);
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
    menu.summary = $r('app.string.wifi_status_connecting');
    this.dataSource?.updateData(menu.index ?? 0, menu);
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
        AdvSecurityModeManager.getInstance()
          .showWifiUnsafeDialog(AbilityContextManager.getContext() as common.UIAbilityContext);
        return;
      }
      // 已保存网络
      this.startConnect(detailApMenu.config, false, this);
      detailApMenu.summary = $r('app.string.wifi_status_connecting');
      this.dataSource?.updateData(detailApMenu.index ?? 0, detailApMenu);
    } else if (!this.isOuterScreen) {
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
      const session: UIExtensionContentSession | undefined =
        LocalStorage.getShared().get<UIExtensionContentSession>('wifiExtensionSession');
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
          session?.sendData({ 'method': 'hideControlCenter' });
          // WindowManager.closePluginWindow(PLUGIN_WIFI_WINDOW_URL, true);
        });
      }
    } else {
      LogUtil.info(`${TAG} outScreen openConnectPage`);
      ToastUtil.showToast(ResourceUtil.getStringSync($r('app.string.expand_phone_use')), ToastUtil.SHORT_DURATION);
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
    EventBus.getInstance().on('EVENT_ID_CONTROL_CENTER_WLAN_CLICK_EVENTS', this.onMenuClick);
    this.closeUnSaveDialogEvent.registerCommonEvent();
    WifiUtils.wifiStateChangeOn(TAG, this.onWifiStateChange);
    WifiUtils.wifiConnectionChangeOn(TAG, this.onWifiConnectionChange);
    WifiUtils.wifiRssiChangeOn(TAG, this.onWifiRssiChange);
    WifiUtils.registerNetCapabilitiesChange(netCon, this.onNetCapabilitiesChange, TAG);

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

  private unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    EventBus.getInstance().detach('EVENT_ID_CONTROL_CENTER_WLAN_CLICK_EVENTS', this.onMenuClick);
    this.closeUnSaveDialogEvent.unRegisterCommonEvent();
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
      LogUtil.info(`${TAG} updateConnectedAp: ${accessPoint?.toString()}`);
      this.accessPoint = accessPoint;
      this.updateSharePage();
    } catch (error) {
      LogUtil.error(`${TAG} update connected ap error: ${error?.message}`);
    }
  }

  private updateSharePage(): void {
    if (this.isLoaded) {
      this.shareWlanController.setAccessPoint(this.accessPoint as AccessPoint);
      this.shareWlanController.onPageShow();
    }
  }

  private async updateConnectedItemInfo(): Promise<void> {
    let lastLinkedInfo2: wifiManager.WifiLinkedInfo | undefined = await WifiUtils.getLinkedInfo();
    LogUtil.info(`${TAG} update linked menu info, portal state: ${this.isPortalUnauthenticated}, network unavailable state: ${this.isNetworkUnavailable}`);
    if (!this.dataSource || this.dataSource.totalCount() === 0) {
      LogUtil.error(`${TAG} update connected item error: data is empty.`);
      return;
    }
    if (!this.accessPoint) {
      LogUtil.error(`${TAG} accessPoint is empty.`);
      return;
    }
    let connectedApMenu: ApMenu | undefined = undefined;
    let connectedApMenuIndex: number = 0;
    for (let i = 0; i < this.dataSource.totalCount(); i++) {
      let item: ApMenu = this.dataSource.getData(i);
      if (item.isShowConnected) {
        connectedApMenuIndex = i;
        connectedApMenu = item;
        break;
      }
    }
    if (!connectedApMenu) {
      LogUtil.error(`${TAG} do not find connected ap menu.`);
      let connectedMenu: ApMenu = this.getConnectedApMenu(this.accessPoint);
      this.refreshConnectedMenu(connectedMenu);
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
    this.dataSource.updateData(connectedApMenuIndex, connectedApMenu);
  }

  public startTimer(): void {
    this.getTimer().restart();
    this.startLoading();
  }

  public stopTimer(): void {
    if (this.timer) {
      this.timer.stop();
    }
  }

  public bindList(dataSource: ControlCenterWlanDataSource): void {
    this.dataSource = dataSource;
  }

  private hideConnectedApChange(): void {
    LogUtil.info(`${TAG} hideConnectedApChange`);
    this.accessPoint = null;
    if (!this.dataSource || this.dataSource.totalCount() === 0) {
      return;
    }
    for (let i = 0; i < this.dataSource.totalCount(); i++) {
      let item: ApMenu = this.dataSource.getData(i);
      if (item.isShowConnected) {
        LogUtil.info(`${TAG} update dataSource: onWifiDisConnected.`);
        this.dataSource?.removeDataByIndex(i);
        return;
      }
    }
  }

  private refreshConnectedMenu(connectedMenu: ApMenu): void {
    LogUtil.info(`${TAG} refreshConnectedMenu`);
    if (!this.dataSource || this.dataSource.totalCount() === 0 || !connectedMenu) {
      return;
    }
    const count: number = this.dataSource.totalCount();
    for (let i = 0; i < count; i++) {
      let item: ApMenu = this.dataSource.getData(i);
      if (item.ssid === connectedMenu.ssid && item.securityType === connectedMenu.securityType) {
        this.dataSource.removeDataByIndex(i);
        break;
      }
    }
    this.dataSource.addData(0, connectedMenu);
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
    this.startLoading();
  }

  private startLoading(): void {
    AppStorage.setOrCreate('WlanListLoadingVisible', true);
    LogUtil.info(`${TAG} setLoading`);
    if (this.loadingTaskId != null) {
      clearTimeout(this.loadingTaskId);
      this.loadingTaskId = null;
    }
    this.loadingTaskId = setTimeout(() => {
      LogUtil.info(`${TAG} setLoading false`);
      AppStorage.setOrCreate('WlanListLoadingVisible', false);
    }, SCAN_LOADING_INTERVAL);
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
