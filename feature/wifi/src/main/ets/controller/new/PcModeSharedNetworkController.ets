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

// import lazy { default as networkSharing } from '@hms.collaboration.networksharing';
import { DeviceUtil } from "@ohos/settings.common/src/main/ets/utils/BaseUtils";
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { WifiUtils, WIFI_INACTIVE_HEIGHT } from '../../WifiUtils';
import { sharedNetworkTracker } from '../../SharedNetworkTracker';
import { PcModeSharedNetworkDataSource } from '../../model/PcModeSharedNetworkDataSource';
import { SharedNetworkMenu } from '../../model/SharedNetworkPanelModel';
import StatusbarPanelUtil from '@ohos/settings.commonUikit/src/main/ets/utils/StatusbarPanelUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  EVENT_ID_PC_MODE_SHARED_NETWORK_ITEM_CLICK,
  EVENT_ID_PC_MODE_SHARED_NETWORK_VISIBLE
} from '@ohos/settings.common/src/main/ets/event/types';

export const PLUGIN_WIFI_ICON_URL: string = 'pages/wifi/PluginWifiIcon.js';

const TAG: string = 'PcModeSharedNetworkController : ';
const SHARED_NETWORK_AP_GROUP: string = 'shared_network_ap_group';
const ID_MIN_LEN: number = 8;
const ANONYMOUS_LEN: number = 4;
const NOT_FOUND: number = -1;
const NETWORK_CONNECT_TIMEOUT: number = 60000;
const WIFI_SUBTITLE_HEIGHT: number = 32;
const WIFI_SECTION_HEIGHT: number = 56;
const DIVIDER_HEIGHT: number = 9;
const DIALOG_MAX_HEIGHT: number = StatusbarPanelUtil.getWindowPanelMaxHeight();

export enum ErrorResult {
  SUCCESS = 0,
  ERR_NO_RESOURCE = 1,
  ERR_BUS_FAILURE = 2,
  ERR_ACTIVATION_FAILURE = 3,
  ERR_ROUTE_FAILURE = 4,
  NETWORK_ERROR_FAILED_MSG = 100,
  NETWORK_ERROR_DATA_NOT_ENABLED = 200,
  NETWORK_ERROR_SUB_SWITCH_OFF = 210,
  NETWORK_ERROR_UNAVAILABLE = 220,
};

export enum DeviceConnectionState {
  IDLE = 0,
  CONNECTING = 1,
  CONNECTED = 2,
  FAILED = 3,
  OFFLINE = 4,
};

export enum NetworkState {
  INACTIVE = 0,
  ACTIVE = 1
};

export interface DeviceInfo {
  userName: string,
  deviceName: string,
  networkId: string,
  deviceConnectionState: DeviceConnectionState,
  networkState: NetworkState,
  errorResult: ErrorResult,
};

export class PcModeSharedNetworkController {
  private dataSource: PcModeSharedNetworkDataSource = new PcModeSharedNetworkDataSource();
  private timerId: number | null = null;
  private isRegister: boolean = false;

  // 数据初始化
  init():void {
    LogUtil.info(`${TAG} init`);
    this.setSharedNetworkVisible(false);
    if (!DeviceUtil.isDevicePad() && !DeviceUtil.isDevicePc()) {
      LogUtil.error(`${TAG} current device is not Pad or PC, return`);
      return;
    }

    if (!WifiUtils.isShared()) {
      LogUtil.error(`${TAG} const.booster.virtual_modem_switch is false`);
      return;
    }

    this.getDeviceInfos();
    this.registerDataChange();
    this.isRegister = true;
    AppStorage.setOrCreate('connectingNetworkId', '');
    AppStorage.setOrCreate('startTimer', false);
  }

  destroy(): void {
    if (!DeviceUtil.isDevicePad() && !DeviceUtil.isDevicePc()) {
      this.setSharedNetworkVisible(false);
      LogUtil.info(`${TAG} destroy isTablet false`);
      return;
    }

    LogUtil.info(`${TAG} destroy. isRegister:${this.isRegister}`);
    if (this.isRegister) {
      this.unRegisterDataChange();
      this.isRegister = false;
    }
  }

  public bindList(dataSource: PcModeSharedNetworkDataSource): void {
    this.dataSource = dataSource;
  }

  private getDeviceInfos(): void {
    LogUtil.info(`${TAG} getDeviceInfos`);
    try {
      // sharedNetworkTracker.getDeviceInfos()
      //   .then((data) => {
      //     this.refreshMenus(data);
      //   })
      //   .catch((error: Error) => {
      //     this.setSharedNetworkVisible(false);
      //     LogUtil.error(`${TAG} getDeviceInfos .catch: ${error?.message}`);
      //   })
    } catch (error) {
      this.setSharedNetworkVisible(false);
      LogUtil.error(`${TAG} getDeviceInfos catch: ${error?.message}`);
    }
  }

  private refreshMenus(data: DeviceInfo[]): void {
    LogUtil.info(`${TAG} refreshMenus`);
    if (!this.dataSource) {
      LogUtil.error(`${TAG} refreshMenus failed. dataSource is undefined.`);
      return;
    }

    this.dataSource.clearAll();
    for (let index = 0; index < data.length; index++) {
      if((data[index] as DeviceInfo).deviceName.length === 0 ||
        (data[index] as DeviceInfo).networkId.length === 0) {
        continue;
      }

      if(data[index]?.networkState === NetworkState.ACTIVE) {
        this.dataSource.getArray().unshift(this.createApMenu(data[index] as DeviceInfo));
      } else {
        this.dataSource.getArray().push(this.createApMenu(data[index] as DeviceInfo));
      }
    }

    this.setSharedNetworkVisible((this.dataSource.totalCount() ?? 0) > 0);
    let oldSize: number = Number(AppStorage.get('SharedMenuSize'));
    this.updateHeight(oldSize, this.dataSource.totalCount());
    this.dataSource.notifyDataReload();
  }

  private createApMenu(info: DeviceInfo): SharedNetworkMenu {
    let menu: SharedNetworkMenu = new SharedNetworkMenu();
    menu.stateIcon = $r('app.media.ic_status_bar_distributed_modem');
    menu.title = info.deviceName;
    menu.index =30;
    menu.isShowConnected = info.networkState === NetworkState.ACTIVE;
    menu.summary = this.getSummary(info.networkId, info.networkState);
    menu.key = SHARED_NETWORK_AP_GROUP;
    menu.networkId = info.networkId;
    menu.userName = info.userName;
    menu.deviceName = info.deviceName;
    menu.connectState = info.deviceConnectionState;
    menu.networkState = info.networkState;
    menu.errorResult = info.errorResult;

    // 作为唯一标识
    menu.extra = this.generateId(info);
    return menu;
  }

  private generateId(info: DeviceInfo): string {
    let connectState: string = info.networkId === AppStorage.get('connectingNetworkId') ? '0' : '1';
    let id = 'ap' + info.networkId + info.deviceName + info.deviceConnectionState + info.networkState + connectState;
    return id;
  };

  private getSummary(id: string, nState: NetworkState): ResourceStr {
    if (nState === NetworkState.ACTIVE) {
      return $r('app.string.wifi_status_connected');
    }
    if (AppStorage.get('connectingNetworkId') !== '' && id === AppStorage.get('connectingNetworkId')) {
      return $r('app.string.wifi_status_connecting');
    }
    return '';
  }

  private registerDataChange(): void {
    LogUtil.info(`${TAG} registerDataChange`);

    this.registerDeviceStateChange();
    this.registerDeviceListChange();
    EventBus.getInstance().on(EVENT_ID_PC_MODE_SHARED_NETWORK_ITEM_CLICK, this.onMenuClick);
  }

  private unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);

    this.unRegisterDeviceStateChange();
    this.unRegisterDeviceListChange();
    EventBus.getInstance().detach(EVENT_ID_PC_MODE_SHARED_NETWORK_ITEM_CLICK, this.onMenuClick);
  }

  private registerDeviceStateChange(): void {
    try {
      // networkSharing.on('deviceStateChange', this.onDeviceStateChange);
    } catch (error) {
      LogUtil.error(`${TAG} registerDeviceStateChange error: ${error?.message}`);
    }
  }

  private registerDeviceListChange(): void {
    try {
      // networkSharing.on('deviceListChange', this.onDeviceListChange);
    } catch (error) {
      LogUtil.error(`${TAG} registerDeviceListChange error: ${error?.message}`);
    }
  }

  private onDeviceListChange = (infos: DeviceInfo[]): void => {
    LogUtil.info(`${TAG} onDeviceListChange`);
    if (infos.length === 0) {
      this.finishConnect();
    }

    let menusCache: SharedNetworkMenu[] = [];
    let menus: SharedNetworkMenu[] = this.dataSource.getArray();
    infos.forEach((info: DeviceInfo) => {
      let index = menus.findIndex(
        item => (item as SharedNetworkMenu).networkId === info.networkId) ?? NOT_FOUND;
      if (index === NOT_FOUND) {
        LogUtil.info(`${TAG} add new device`);
        let menu: SharedNetworkMenu = this.createApMenu(info);
        info.networkState === NetworkState.ACTIVE ? menusCache.unshift(menu) : menusCache.push(menu);
      } else {
        let menu: SharedNetworkMenu = menus[index] as SharedNetworkMenu;
        this.dataSource.removeDataByIndex(index);
        if (info.deviceConnectionState === menu.connectState && info.networkState === menu.networkState) {
          info.networkState === NetworkState.ACTIVE ? menusCache.unshift(menu) : menusCache.push(menu);
        } else {
          LogUtil.info(`${TAG} deviceState has changed`);
          let newMenu: SharedNetworkMenu = this.createApMenu(info);
          info.networkState === NetworkState.ACTIVE ? menusCache.unshift(newMenu) : menusCache.push(newMenu);
        }
      }
    });

    this.dataSource.updateManus(menusCache);
    this.dataSource.notifyDataReload();
    let oldSize: number = Number(AppStorage.get('SharedMenuSize'));
    this.updateHeight(oldSize, menusCache.length);
  }

  public clearDeviceInfos(): void {
    if (this.dataSource === undefined || this.dataSource?.length === 0) {
      LogUtil.info(`${TAG} dataSource already clear`);
      return;
    }
    this.dataSource.clearAll();
  };

  private setSharedNetworkVisible(isShow: boolean): void {
    EventBus.getInstance().emit(EVENT_ID_PC_MODE_SHARED_NETWORK_VISIBLE, isShow);
  }

  private onDeviceStateChange =  (info: DeviceInfo): void => {
    LogUtil.info(`${TAG} onDeviceStateChange, ${this.toLogString(info)}`);
    let menus: SharedNetworkMenu[] = this.dataSource.getArray();
    let index = menus.findIndex(
      item => (item as SharedNetworkMenu).networkId === info.networkId) ?? NOT_FOUND;
    if (index === NOT_FOUND) {
      LogUtil.info(`${TAG} ${this.anonymousId(info.networkId)}, not found`);
      this.addDeviceInfo(info, menus);
      return;
    }

    let menu: SharedNetworkMenu = menus[index] as SharedNetworkMenu;
    if (info.networkId === AppStorage.get('connectingNetworkId') && info.errorResult !== ErrorResult.SUCCESS) {
      LogUtil.error(`${TAG} networkId:${this.anonymousId(info.networkId)}, connect failed`);
      this.finishConnect();
      this.ProcConnectFailed(menu, info.errorResult);
      menus.splice(index, 1);
      this.addDeviceInfo(info, menus);
      this.dataSource.notifyDataReload();
      return;
    }

    if (info.networkId === AppStorage.get('connectingNetworkId') && info.networkState === NetworkState.ACTIVE) {
      LogUtil.info(`${TAG} networkId:${this.anonymousId(info.networkId)}, connnct success`);
      this.finishConnect();
    }

    if (info.deviceConnectionState !== DeviceConnectionState.OFFLINE && menu.networkState === info.networkState) {
      LogUtil.info(`${TAG} networkId:${this.anonymousId(info.networkId)}, not refresh`);
      return;
    }

    menus.splice(index, 1);
    if (info.deviceConnectionState === DeviceConnectionState.OFFLINE) {
      LogUtil.info(`${TAG} device offline ${info.deviceName}`);
      if (info.networkId === AppStorage.get('connectingNetworkId')) {
        this.finishConnect();
      }
      this.dataSource.updateManus(menus);
      this.dataSource.notifyDataReload();
      return;
    }

    LogUtil.info(`${TAG} addInfo, index: ${index}`);
    this.addDeviceInfo(info, menus);
  }

  private ProcConnectFailed(menu: SharedNetworkMenu, errorCode: ErrorResult): void {
    AppStorage.setOrCreate('connectingNetworkId', '');
    AppStorage.setOrCreate('startTimer', false);
    if (!menu.deviceName) {
      LogUtil.error(`${TAG} connect failed, deviceName is undefined, return`);
      return;
    }
    let msg: ResourceStr = '';
    LogUtil.info(`${TAG} Shared_Network failed dialog, errorCode=${errorCode}`);
    let errorMessages = new Map<ErrorResult, Resource>([
      [ErrorResult.NETWORK_ERROR_FAILED_MSG, $r('app.string.ensure_mobile_data_enabled')],
      [ErrorResult.NETWORK_ERROR_DATA_NOT_ENABLED, $r('app.string.mobile_data_not_enabled')],
      [ErrorResult.NETWORK_ERROR_SUB_SWITCH_OFF, $r('app.string.network_sharing_sub_switch_not_enabled')],
      [ErrorResult.NETWORK_ERROR_UNAVAILABLE, $r('app.string.mobile_network_unavailable')]
    ]);
    let errorMsgKey = errorMessages.get(errorCode)|| $r('app.string.ensure_mobile_data_enabled');
    LogUtil.info(`${TAG} errorMsgKey: ${errorMsgKey}`);
    msg = ResourceUtil.getStringSync(errorMsgKey);

    AlertDialog.show({
      title: $r('app.string.bt_connect_failed_title'),
      message: msg,
      autoCancel: true,
      alignment: DialogAlignment.Center,

      primaryButton: {
        value: $r('app.string.dialog_know'),
        action: () => {
          LogUtil.info(`${TAG} failed dialog disappear`);
        }
      }
    });
    menu.summary = '';
    this.dataSource.notifyDataReload();
  }

  private finishConnect(): void {
    LogUtil.info(`${TAG} finishConnect`);
    if (this.timerId !== null) {
      clearTimeout(this.timerId);
      this.timerId = null;
    }
    AppStorage.setOrCreate('connectingNetworkId', '');
    AppStorage.setOrCreate('startTimer', false);
  }

  private addDeviceInfo(info: DeviceInfo, menus: SharedNetworkMenu[]): void {
    LogUtil.error(`${TAG} addDeviceInfo: ${this.toLogString(info)}`);
    if (info.deviceConnectionState === DeviceConnectionState.OFFLINE) {
      LogUtil.info(`${TAG} device offline`);
      return;
    }
    let menu = this.createApMenu(info);
    if (info.networkState === NetworkState.ACTIVE) {
      menus.unshift(menu);
    } else {
      menus.push(menu);
    }

    this.dataSource.updateManus(menus);
    this.dataSource.notifyDataReload();
    let oldSize: number = Number(AppStorage.get('SharedMenuSize'));
    this.updateHeight(oldSize, this.dataSource.totalCount());
    this.setSharedNetworkVisible((this.dataSource.totalCount()?? 0) > 0);
  }

  private toLogString(info: DeviceInfo): string {
    return 'id: ' + this.anonymousId(info.networkId) +
      ', cState: ' + info.deviceConnectionState +
      ', nState: ' + info.networkState +
      ', err: ' + info.errorResult;
  }

  private anonymousId(id: string): string {
    if (id.length <= ID_MIN_LEN) {
      return id;
    }
    return id.substring(0, ANONYMOUS_LEN) + '***' + id.substring(id.length - ANONYMOUS_LEN);
  }

  private updateHeight(oldSize: number, newSize: number): void {
    AppStorage.setOrCreate('SharedMenuSize', newSize);
    let height: number = Number(AppStorage.get('PluginWindowHeight'));
    if (height) {
      height = height - this.calculateHeight(oldSize) + this.calculateHeight(newSize);
    } else {
      height = WIFI_INACTIVE_HEIGHT + this.calculateHeight(newSize);
    }
    WindowManager.updatePluginWindowHeight(PLUGIN_WIFI_ICON_URL, Math.min(DIALOG_MAX_HEIGHT, height));
  }

  private calculateHeight(size: number): number {
    return WIFI_SUBTITLE_HEIGHT + WIFI_SECTION_HEIGHT * size + DIVIDER_HEIGHT;
  }

  private unRegisterDeviceStateChange(): void {
    try {
      // networkSharing.off('deviceStateChange', this.onDeviceStateChange);
    } catch (error) {
      LogUtil.error(`${TAG} unRegisterDeviceStateChange error: ${error?.message}`);
    }
  }

  private unRegisterDeviceListChange(): void {
    try {
      // networkSharing.off('deviceListChange', this.onDeviceListChange);
    } catch (error) {
      LogUtil.error(`${TAG} unRegisterDeviceListChange error: ${error}`);
    }
  }

  private onMenuClick = (clickedMenu: SharedNetworkMenu, info: DeviceInfo) => {
    LogUtil.info(`${TAG} onMenuClick.`);
    if (!clickedMenu || !(clickedMenu instanceof SharedNetworkMenu)) {
      LogUtil.error(`${TAG} onMenuClick error`);
      return;
    }
    if (!clickedMenu.networkId) {
      LogUtil.error(`${TAG} onMenuClick networkId error`);
      return;
    }

    if (clickedMenu.networkState === NetworkState.ACTIVE) {
      LogUtil.info(`${TAG} networkId: ${this.anonymousId(clickedMenu.networkId)} is already connected, do nothing`);
      return;
    }
    if (AppStorage.get('connectingNetworkId') !== '') {
      LogUtil.info(`${TAG} there is a network connecting, ${this.anonymousId(AppStorage.get('connectingNetworkId'))}`);
      return;
    }

    AppStorage.setOrCreate('connectingNetworkId', clickedMenu.networkId);
    sharedNetworkTracker.startConnect(clickedMenu.networkId);
    clickedMenu.summary = $r('app.string.wifi_status_connecting');
    this.dataSource.notifyDataReload();

    this.timerId = setTimeout(() => {
      this.checkTimer(clickedMenu as SharedNetworkMenu, info as DeviceInfo);
    }, NETWORK_CONNECT_TIMEOUT);
    AppStorage.setOrCreate('startTimer', true);
  }

  private checkTimer(menu: SharedNetworkMenu, info: DeviceInfo): void {
    if (AppStorage.get('startTimer')) {
      LogUtil.info(`${TAG} connect timeout`);
      this.ProcConnectFailed(menu, info.errorResult);
    }
  }
}