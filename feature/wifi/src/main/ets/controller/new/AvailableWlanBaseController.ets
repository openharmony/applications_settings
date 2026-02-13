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

import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import wifiManager from '@ohos.wifiManager';
import { BusinessError } from '@ohos.base';
import { connection } from '@kit.NetworkKit';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import {
  SettingDialogModel,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { HiSysWlanEvenGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { WifiUtils, IS_DEBUG } from '../../WifiUtils';
import { ConnectFailedComponent } from '../../component/ConnectFailedComponent';
import { AVAILABLE_LIST_DATA_CHANGE } from '../../component/OtherWlanHeaderComponent';
import {
  apConnectManager,
  WifiConnectListener,
  wifiTracker,
  WifiTrackerListener,
  WIFI7_EMLSR
} from '../../WifiTracker';
import {
  ApMenu,
  ApMenuData,
  AccessPoint,
  WifiConnectionState,
  WifiState,
  WlanDisconnectedReason,
  CONNECT_RESULT_EVENT,
  CONNECTED_DATA_CHANGE_EVENT,
} from '../../model/WifiModel';
import { WlanItemModel } from '../../model/WlanItemModel';
import { WifiPasswordConfigManager } from '../../WifiPasswordConfigManager';
import { AddOtherWlanConfigManager } from '../../AddOtherWlanConfigManager';
import { WifiBaseConfigManager } from '../../WifiBaseConfigManager';
import { WifiMenuManager } from '../../WifiMenuManager';

/* instrument ignore file */
const TAG: string = 'AvailableWlanBaseController:';

@Builder
function connectFailedBuilder(param: object): void {
  ConnectFailedComponent();
}

/**
 * 可用WLAN信息展示控制器
 *
 * @since 2024-05-29
 */
export abstract class AvailableWlanBaseController implements ComponentControl,
WifiTrackerListener, WifiConnectListener {
  public lastLinkedInfo: wifiManager.WifiLinkedInfo | null = null;
  public lastMultiLinkedInfo: Array<wifiManager.WifiLinkedInfo> | null = null;
  public accessPoint?: AccessPoint;
  public isWlanLog: boolean = false;
  private isRegister: boolean = false;
  protected isNetworkUnavailable: boolean = false;
  protected isPortalUnauthenticated: boolean = false;
  protected isFirstConnect: boolean = false;
  protected isVisible: boolean = false;
  protected isPageShow: boolean = false;
  private dataSource?: OrderedDataSource;
  private connectionNetCaps: connection.NetCap[] | undefined;
  private compId: string = '';
  private wlanSwitchComId: string = '';
  private netCon: connection.NetConnection = connection.createNetConnection({
    netCapabilities: {
      bearerTypes: [connection.NetBearType.BEARER_WIFI]
    }
  });
  private addOtherWlanConfigManager: AddOtherWlanConfigManager = AddOtherWlanConfigManager.getInstance();
  protected onWifiStateChange = (state: number): void => {
    LogUtil.info(`${TAG} wifi state change : ${state}`);
    if (state === WifiState.INACTIVE) {
      this.hideConnectedApChange();
    }
  };
  private onWifiConnectionChange = (state: number): void => {
    LogUtil.info(`${TAG} onWifiConnectionChange : ${state}`);
    if (state === WifiConnectionState.DISCONNECTED) {
      this.onWifiDisConnected();
    } else if (state === WifiConnectionState.CONNECTED) {
      this.updateConnectedAp();
    }
  };
  private updateNetworkStatus = (caps: connection.NetCap[] | undefined): void => {
    if (WifiUtils.isWifiNetworkValidated(caps)) {
      this.isPortalUnauthenticated = false;
      this.isNetworkUnavailable = false;
    } else {
      this.isPortalUnauthenticated = WifiUtils.isPortalWifiNetwork(caps);
      this.isNetworkUnavailable = true;
    }
    this.updateMenuStateInfo();
  };

  private onNetCapabilitiesChange = (data: connection.NetCapabilityInfo): void => {
    let caps = data?.netCap?.networkCap;
    let bearerTypes = data?.netCap?.bearerTypes;
    LogUtil.info(`${TAG} netCapabilitiesChange, bearerTypes: ${bearerTypes?.join(',')}, caps: ${caps?.join(',')}`);
    if (!WifiUtils.isBearerWifi(bearerTypes)) {
      LogUtil.info(`${TAG} the network is not wifi, no need to handle.`);
      return;
    }
    this.connectionNetCaps = caps;
    this.updateNetworkStatus(caps);
  };
  private onToggleChangeCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleState is invalid`);
      return;
    }
    LogUtil.info(`${TAG} receive toggle state change: ${toggleState.state}`);
    this.isVisible = toggleState.state;
    this.hideOrShowList(this.isVisible);
  };
  private onWifiRssiChange = (state: number): void => {
    if (!this.isRegister) {
      return;
    }
    LogUtil.info(`${TAG} wifi rssi change : ${state}`);
    // 返回以dBm为单位的RSSI值
    if (WifiUtils.isWifiConnected()) {
      this.updateLinkedInfo();
    }
  };

  // 点击菜单连接WLAN的回调
  onConnectResult(result: number): void {
    let config: wifiManager.WifiDeviceConfig | undefined = WifiPasswordConfigManager.getInstance().getConfig();
    let isFromMoreSetting: boolean | object =
      (AppStorage.get<Want>('wantParams') as Want)?.parameters?.fromMoreSetting ?? false;
    let reportParams: Record<string, Object> = {};
    reportParams.VALUE = config?.ssid || '';
    reportParams.IS_SETTINGS_OPEN = isFromMoreSetting ? '0' : '1';
    HiSysEventUtil.reportBehaviorEventByUE(HiSysWlanEvenGroup.CONNECT_WLAN, reportParams);
    // 连接失败
    if (!result) {
      // wlan开关关闭情况下，无需弹出失败提示框
      const isShowConnectFailed =
        this.isVisible && WifiUtils.needShowConnectFailedDialog(apConnectManager.connectConfig);
      if (isShowConnectFailed && this.addOtherWlanConfigManager.getAddOtherWlanPageFlag()) {
        let failReason: number = WifiUtils.getDisconnectedReason();
        WifiUtils.reportWlanConnectFailureEvent(failReason);
        let failedReasonString = WifiBaseConfigManager.getDisconnectedMessage(failReason);
        WifiUtils.showToast(failedReasonString, ToastUtil.SHORT_DURATION);
      } else if (isShowConnectFailed) {
        this.showConnectFailedDialog();
        if (WifiMenuManager.isInOObeStage()) {
          this.isFirstConnect = true;
        }
      }
      let failReason: number = WifiUtils.getDisconnectedReason();
      LogUtil.info(`${TAG} connectFailed: ${result}, failReason is ${failReason} isFirstConnect:${this.isFirstConnect}, is current visiable:${this.isVisible}`);
      if (failReason === WlanDisconnectedReason.WRONG_PWD && apConnectManager.connectConfig && this.isFirstConnect) {
        LogUtil.info(`${TAG} connect with wrong pwd , remove wifi device.`);
        wifiTracker.removeWifiDevice(apConnectManager.connectConfig);
      }
      return;
    }
    // 连接成功
    EventBus.getInstance().emit(CONNECT_RESULT_EVENT, true);
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init. isRegister:${this.isRegister}`);
    this.dataSource = compParam.dataSource as OrderedDataSource;
    this.compId = compParam.compId as string;
    let index: number = this.compId.lastIndexOf('.');
    if (index != -1) {
      this.wlanSwitchComId = `${this.compId.substring(0, index)}.WlanConfig.WlanSwitch`;
    }
    this.isVisible = compParam.component.visible ?? false;
    if (WifiUtils.isWifiConnected()) {
      this.updateConnectedAp(true);
    }
    if (this.isRegister) {
      return;
    }
    this.registerDataChange();
    this.isRegister = true;
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy. isRegister:${this.isRegister}`);
    if (!this.isRegister) {
      return;
    }
    this.unRegisterDataChange();
    this.isRegister = false;
  }

  onClick?(component: SettingBaseModel): void {
  }

  protected hideOrShowList(isShow: boolean): void {
    let state: Map<SettingStateType, SettingCompState> =
      new Map<SettingStateType, SettingCompState>([[SettingStateType.STATE_TYPE_GROUP_VISIBLE,
        { state: isShow } as SettingCompState]]);
    if (isShow && (this.dataSource as OrderedDataSource)?.length > 0) {
      this.showOrHideHeader(true);
    } else {
      this.showOrHideHeader(false);
    }
    notifyCompStateChange(this.compId, state);
  }

  private showConnectFailedDialog(): void {
    let showInSubWindow: boolean = false;
    if (WifiMenuManager.isExternalNetworkStage()) {
      showInSubWindow = true;
    }
    let state = new Map<SettingStateType, SettingDialogModel>([[SettingStateType.STATE_TYPE_ITEM_DIALOG,
      {
        contentBuilder: wrapBuilder(connectFailedBuilder),
        showInSubWindow: showInSubWindow,
        buttons: [
          {
            value: $r('app.string.dialog_know'),
            action: (component: SettingItemModel) => {
            },
            style: {
              buttonStyle: ButtonStyleMode.TEXTUAL,
              width: '100%',
            }
          }
        ],
        style: {
          autoCancel: true
        }
      } as SettingDialogModel]]);
    notifyCompStateChange(this.wlanSwitchComId, state);
  }

  private async updateMenuStateInfo(): Promise<void> {
    LogUtil.info(`${TAG} updateMenuStateInfo, state:${this.isPortalUnauthenticated}/${this.isNetworkUnavailable}`);
    let isUnsecuredWifi = this.accessPoint?.isUnsecuredWifiDetect();
    if (this.isNetworkUnavailable) {
      if (!this.accessPoint) {
        LogUtil.warn(`${TAG} empty accessPoint, update linked menu failed.`);
        return;
      }
      let lastLinkedInfo = await wifiTracker.getLinkedInfoByTaskPool();
      if (lastLinkedInfo) {
        this.accessPoint.updateLastLinkedInfo(lastLinkedInfo);
        await this.getMultiLinkedInfo(lastLinkedInfo);
        this.updateConnectedSummary(WifiUtils.getConnectedSummary(this.isPortalUnauthenticated, isUnsecuredWifi),
          WifiUtils.getNetworkUnavailableStateIcon(this.accessPoint));
      }
    } else {
      let lastLinkedInfo = await wifiTracker.getLinkedInfoByTaskPool();
      if (!lastLinkedInfo) {
        LogUtil.warn(`${TAG} empty lastLinkedInfo, update linked menu failed.`);
        return;
      }
      this.accessPoint?.updateLastLinkedInfo(lastLinkedInfo);
      await this.getMultiLinkedInfo(lastLinkedInfo);
      this.updateConnectedSummary(WifiUtils.getConnectedSummary(false, isUnsecuredWifi),
        this.accessPoint?.getStateIcon());
    }
  }

  private async getMultiLinkedInfo(linkedInfo: wifiManager.WifiLinkedInfo): Promise<void> {
    let wifiLinkType = linkedInfo.wifiLinkType;
    if (!wifiLinkType || wifiLinkType !== WIFI7_EMLSR) {
      return;
    }
    let lastMultiLinkedInfo = await wifiTracker.getMultiLinkedInfoByTaskPool();
    if (lastMultiLinkedInfo) {
      this.accessPoint?.updateMultiLinkedInfo(lastMultiLinkedInfo);
    }
  }

  private updateConnectedSummary(summary: ResourceStr, stateIcon: ResourceStr | undefined): void {
    if (this.accessPoint && this.dataSource && this.dataSource.length > 0) {
      let index = this.dataSource.findIndex(item => (item as WlanItemModel).accessPoint);
      if (index !== -1) {
        LogUtil.info(`${TAG} update dataSource: updateConnectedSummary,dataSource: ${this.dataSource.length}`);
        let multiLinkedInfo = WifiUtils.getLastMultiLinkedInfo(this.accessPoint);
        let linkedInfo = WifiUtils.getLastLinkedInfo(this.accessPoint);
        const description = this.isWlanLog ? WifiUtils.getConnectedDescription(multiLinkedInfo, linkedInfo) : '';
        let item: WlanItemModel = this.dataSource[index] as WlanItemModel;
        if (!item.accessPoint) {
          return;
        }
        if (item.icon) {
          item.icon.icon = stateIcon ?? $r('app.media.ic_wlan_error');
        }
        if (item.desc) {
          item.desc.content = this.getContent(summary, description);
        }
        item.id = this.getId(item?.accessPoint, summary as Resource, item.icon?.icon as Resource, description);
        this.dataSource.notifyDataChange(index);
      }
    }
  }

  private async updateLinkedInfo(): Promise<void> {
    let lastLinkedInfo = await wifiTracker.getLinkedInfoByTaskPool();
    if (lastLinkedInfo) {
      this.accessPoint?.updateLastLinkedInfo(lastLinkedInfo);
      await this.getMultiLinkedInfo(lastLinkedInfo);
      this.refreshConnectedMenu();
    }
  }

  protected registerDataChange(): void {
    wifiTracker.setListener(this);
    WifiUtils.wifiStateChangeOn(TAG, this.onWifiStateChange);
    WifiUtils.wifiConnectionChangeOn(TAG, this.onWifiConnectionChange);
    WifiUtils.wifiRssiChangeOn(TAG, this.onWifiRssiChange);
    WifiUtils.registerNetCapabilitiesChange(this.netCon, this.onNetCapabilitiesChange, TAG);
    EventBus.getInstance().on(`${this.wlanSwitchComId}.toggle`, this.onToggleChangeCallback);
  }

  protected unRegisterDataChange(): void {
    WifiUtils.wifiStateChangeOff(TAG, this.onWifiStateChange);
    WifiUtils.wifiConnectionChangeOff(TAG, this.onWifiConnectionChange);
    WifiUtils.wifiRssiChangeOff(TAG, this.onWifiRssiChange);
    EventBus.getInstance().detach(`${this.wlanSwitchComId}.toggle`, this.onToggleChangeCallback);
    WifiUtils.unRegisterNetCapabilitiesChange(this.netCon, TAG);
    let isExist: boolean = CommonUtils.isPageExist(NavEntryKey.WIFI_ENTRY);
    if (isExist) {
      wifiTracker.releaseResource(this);
      LogUtil.info(`${TAG} the wifi_entry page exist, not unregister`);
      return;
    }
    wifiTracker.onQuit(this);
  }

  public onApMenusChanged(data: Array<ApMenu>): void {
    if (this.dataSource === undefined) {
      LogUtil.info(`${TAG} onApMenusChanged occurs error, dataSource is undefined.`);
      return;
    }
    this.getLastLinkedInfoAndUpdate();
    let menus: WlanItemModel[] = [];
    // 把已连接的热点加到第一个
    if (this.dataSource.length > 0 && (this.dataSource[0] as WlanItemModel).accessPoint &&
    WifiUtils.isWifiConnected()) {
      LogUtil.info(`${TAG} onApMenusChanged has connectedMenu.`);
      menus.push(this.dataSource[0] as WlanItemModel);
    }
    let arr: ApMenu[] = [];
    if (this.isNeedDiversionShow()) {
      // 过滤出可用wlan
      arr = data.filter((it) => this.isAvailableNetworks(it));
    } else {
      // 外部拉起半模态场景下，不需要过滤
      arr = data;
    }
    if (arr.length < 1) {
      LogUtil.error(`${TAG} onApMenusChanged failed, arr length is 0.`);
      this.dataSource.splice(0, this.dataSource.length);
      this.dataSource.pushDataArray(menus);
      this.showOrHideHeader(menus.length > 0);
      return;
    }
    const lastIndex = arr.length - 1;
    // 处理分割线
    arr.forEach((it, index) => {
      menus.push(this.createApMenu(it, index === lastIndex));
    })
    LogUtil.info(`${TAG} update dataSource: onApMenusChanged. menus.length:${menus.length}`);
    // 清空旧的数据
    this.dataSource.splice(0, this.dataSource.length);
    this.dataSource.pushDataArray(menus);
    // 没有热点的时候 标题也不要
    this.showOrHideHeader(menus.length > 0);
  }

  onApMenuChanged(menu: ApMenu): void {
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.isPageShow = true;
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.isPageShow = false;
  }

  private showOrHideHeader(isShow: boolean): void {
    LogUtil.info(`${TAG} showOrHideHeader isShow:${isShow} isVisible:${this.isVisible}`);
    notifyCompStateChange(`${this.compId}.header`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow && this.isVisible } as SettingCompState]]
    ));
    // 没有可用WLAN数据的时候，其他WLAN的head高度要变低
    EventBus.getInstance().emit(AVAILABLE_LIST_DATA_CHANGE, !isShow);
  }

  private isAvailableNetworks(model: ApMenu): boolean {
    if (this.isModelLoading(model.key ?? '')) {
      LogUtil.info(`${TAG} ${WifiUtils.getLogSsidString(model?.ssid)} is connecting.`);
      return true;
    }
    return !CheckEmptyUtils.isEmpty(model.config) ||
      model.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_OPEN;
  }

  private getId(item: AccessPoint, summary: Resource, stateIcon: Resource, description: string): string {
    let key = WifiUtils.getLogSsidString(item?.ssid ?? '') + item.securityType;
    let summaryId: string = summary?.id?.toString() || '';
    let stateIconId: string = stateIcon?.id?.toString() || '';
    let isHiLinkNetwork = item?.isHiLinkNetwork;
    return key + summaryId + stateIconId + description + isHiLinkNetwork;
  }

  private getLastLinkedInfoAndUpdate(): void {
    if (WifiUtils.isWifiConnected()) {
      LogUtil.info(`${TAG} getLastLinkedInfoAndUpdate connected`);
      this.updateConnectedAp();
    } else {
      LogUtil.info(`${TAG} getLastLinkedInfoAndUpdate not connected`);
      this.hideConnectedApChange();
    }
  }

  private async updateConnectedAp(refreshNetCapabilities?: boolean): Promise<void> {
    LogUtil.info(`${TAG} updateConnectedAp start, refreshNetCapabilities: ${refreshNetCapabilities}`);
    try {
      let linkInfo = await wifiTracker.getLinkedInfoByTaskPool();
      if (!linkInfo) {
        return;
      }
      this.lastLinkedInfo = linkInfo;
      LogUtil.info(`${TAG} updateConnectedAp ${WifiUtils.getLogSsidString(this.lastLinkedInfo?.ssid)},
        connState: ${this.lastLinkedInfo?.connState},supportedWifiCategory:${this.lastLinkedInfo?.supportedWifiCategory}`);
      let wifiLinkType = linkInfo.wifiLinkType;
      if (wifiLinkType && wifiLinkType === WIFI7_EMLSR) {
        let multiLinkInfo = await wifiTracker.getMultiLinkedInfoByTaskPool();
        if (multiLinkInfo) {
          this.lastMultiLinkedInfo = multiLinkInfo;
        }
      }
      if (this.lastLinkedInfo.connState !== wifiManager.ConnState.CONNECTED) {
        LogUtil.error(`${TAG} lastLinkedInfo connState not connected`);
        this.hideConnectedApChange();
        return;
      }
      let accessPoint = this.createAccessPoint();
      if (!accessPoint) {
        return;
      }
      this.accessPoint = accessPoint;
      EventBus.getInstance().emit(CONNECTED_DATA_CHANGE_EVENT, this.accessPoint);
      let smartHotSpot = SettingsDataUtils.getSettingsData('smartHotSpot', '');
      LogUtil.info(`${TAG} this.accessPoint.ssid: ${WifiUtils.getLogSsidString(this.accessPoint.ssid)}`);
      if (this.accessPoint.ssid !== smartHotSpot) {
        LogUtil.info(`${TAG} accessPoint is not the same with smartHotSpot.`);
        this.refreshConnectedMenu();
      } else {
        LogUtil.info(`${TAG} accessPoint is the same with smartHotSpot.`);
      }
      if (refreshNetCapabilities && this.connectionNetCaps) {
        // 主动获取网络状态(适配重复进入菜单场景，不可上网热点不显示感叹号问题)
        this.updateNetworkStatus(this.connectionNetCaps);
      }
    } catch (error) {
      LogUtil.error(`${TAG} updateConnectedAp failed: ${error?.message}`);
    }
  }

  private createAccessPoint(): AccessPoint | undefined {
    if (!this.lastLinkedInfo) {
      return;
    }
    let accessPoint = new AccessPoint(null);
    let wifiDeviceConfig: wifiManager.WifiDeviceConfig | undefined = this.getDeviceConfigs();
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
    if (this.lastMultiLinkedInfo) {
      accessPoint.updateMultiLinkedInfo(this.lastMultiLinkedInfo);
    }
    return accessPoint;
  }

  private getDeviceConfigs(): wifiManager.WifiDeviceConfig | undefined {
    if (!this.lastLinkedInfo) {
      return;
    }
    try {
      let configs: wifiManager.WifiDeviceConfig[] = wifiManager.getDeviceConfigs();
      LogUtil.info(`${TAG} wifiManager getDeviceConfigs.length: ${configs?.length}`);
      if (configs && configs.length > 0) {
        for (let config of configs) {
          if (IS_DEBUG) {
            LogUtil.info(`${TAG} config : ${WifiUtils.getLogSsidString(config.ssid)}`);
          }
          if (this.lastLinkedInfo.ssid === config.ssid && this.lastLinkedInfo.networkId === config.netId) {
            LogUtil.info(`${TAG} getDeviceConfigs success: ${WifiUtils.getLogSsidString(config.ssid)},
              netId: ${config.netId}`);
            return config;
          }
        }
      }
    } catch (error) {
      LogUtil.error(`${TAG} wifiManager getDeviceConfigs failed: ${error?.message}`)
    }
    return;
  }

  protected hideConnectedApChange(): void {
    LogUtil.info(`${TAG} hideConnectedApChange ${this.isVisible}`);
    if (!this.isVisible) {
      this.dataSource?.splice(0, this.dataSource?.length);
      this.accessPoint = undefined;
      EventBus.getInstance().emit(CONNECTED_DATA_CHANGE_EVENT, this.accessPoint);
    }
  }

  // 已连接WLAN和可用WLAN是否需要分流显示
  protected isNeedDiversionShow(): boolean {
    return true;
  }

  private onWifiDisConnected(): void {
    if (!this.dataSource || this.dataSource.length <= 0) {
      return;
    }
    EventBus.getInstance().emit(CONNECTED_DATA_CHANGE_EVENT, undefined);
    let index = this.dataSource.findIndex(item => (item as WlanItemModel).accessPoint);
    if (index !== -1) {
      LogUtil.info(`${TAG} update dataSource: onWifiDisConnected, isPageShow: ${this.isPageShow}`);
      this.dataSource.removeDataByIndex(index);
      // 启动一次扫描 用来快速把旧的已连接刷到可用列表
      if (this.isPageShow) {
        wifiTracker.scanAp();
      }
    }
    this.showOrHideHeader(this.dataSource.length > 0);
  }

  private refreshConnectedMenuState(connectedMenu: WlanItemModel): void {
    LogUtil.info(`${TAG} refreshConnectedMenuState state:${this.isPortalUnauthenticated}/${this.isNetworkUnavailable}`);
    let isUnsecuredWifi = this.accessPoint?.isUnsecuredWifiDetect();
    let multiLinkedInfo = WifiUtils.getLastMultiLinkedInfo(this.accessPoint);
    let linkedInfo = WifiUtils.getLastLinkedInfo(this.accessPoint);
    const description = this.isWlanLog ? WifiUtils.getConnectedDescription(multiLinkedInfo, linkedInfo) : '';
    if (connectedMenu.desc && connectedMenu.icon) {
      connectedMenu.desc.content =
        this.getContent(WifiUtils.getConnectedSummary(this.isPortalUnauthenticated, isUnsecuredWifi), description);
      if (this.isNetworkUnavailable && this.accessPoint) {
        connectedMenu.icon.icon = WifiUtils.getNetworkUnavailableStateIcon(this.accessPoint);
      } else {
        connectedMenu.icon.icon = this.accessPoint?.getStateIcon() as ResourceStr;
      }
      // 更新资源必须重新刷新id
      connectedMenu.id = this.getId(this.accessPoint as AccessPoint, connectedMenu.desc.content as Resource,
        connectedMenu.icon.icon as Resource, description)
    }
  }

  private refreshConnectedMenu(): void {
    LogUtil.info(`${TAG} refreshConnectedMenu.`);
    if (this.dataSource === undefined) {
      return;
    }
    let connectedIndex = this.dataSource?.findIndex(item => (item as WlanItemModel).accessPoint) ?? -1;
    let connectingIndex = this.dataSource?.findIndex(item => (item as WlanItemModel).isLoading) ?? -1;
    if (connectedIndex === -1) {
      if (connectingIndex !== -1) {
        LogUtil.info(`${TAG} update dataSource: remove connectingIndex.`);
        this.dataSource.removeDataByIndex(connectingIndex);
      }
      let connectedMenu = this.getConnectedApMenu();
      if (connectedMenu) {
        // 刷新已连接wlan icon和state
        this.refreshConnectedMenuState(connectedMenu);
        LogUtil.info(`${TAG} update dataSource: add connected menu.`);
        this.updatesConnectedMenu(connectedMenu)
      }
    } else {
      let connectedMenu = this.getConnectedApMenu();
      if (connectedMenu) {
        this.refreshConnectedMenuState(connectedMenu);
        LogUtil.info(`${TAG} update dataSource: refresh connected menu.`);
        // 把旧的已连接的删除
        this.dataSource.removeDataByIndex(connectedIndex);
        this.updatesConnectedMenu(connectedMenu)
      }
    }
  }

  private updatesConnectedMenu(connectedMenu: WlanItemModel): void {
    // 新增已连接热点 如果可用列表有此热点 切换连接视图的时候 需要先删除掉 避免视图短暂有两个同名的item
    const index = this.dataSource?.findIndex(
      (item: WlanItemModel) => item?.ssid === connectedMenu?.ssid &&
        item?.securityType === connectedMenu?.securityType
    ) ?? -1;
    if (index !== -1) {
      this.dataSource?.removeDataByIndex(index);
    }
    this.showOrHideHeader(true);
    this.dataSource?.insertData(0, connectedMenu);
  }

  public getContent(summary: ResourceStr | undefined, description: string): ResourceStr {
    if (this.isWlanLog) {
      return `${ResourceUtil.getStringSync(summary)}\n${description}`;
    }
    return summary || '';
  }

  protected abstract getConnectedApMenu(): WlanItemModel | null;

  protected abstract isModelLoading(key: string): boolean;

  protected abstract refreshList(): void;

  protected abstract createApMenu(item: Partial<ApMenuData>, isLast: boolean): WlanItemModel;
}