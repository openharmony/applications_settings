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
// import lazy { default as networkSharing } from '@hms.collaboration.networksharing';
// import serviceDelivery from '@hms.collaboration.inner.serviceDelivery';
import { PADDING_40 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ComparableSettingItemModel,
  ItemDetailType,
  ItemType,
  SettingIconModel,
  SettingIconType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingDialogState,
  SettingStateType,
  SettingTextState,
  SettingToggleState
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  DialogContentComponent,
  OPERATOR_CONNECT_FAILED,
  OPERATOR_DISCONNECT
} from '../../component/DialogContentComponent';
import { SharedNetworkModel } from '../../model/SharedNetworkModel';
import { sharedNetworkTracker } from '../../SharedNetworkTracker';
import { WifiUtils } from '../../WifiUtils';
import { SharedNetworkDeviceController } from './SharedNetworkDeviceController';

const WLAN_SWITCH_ID: string = 'Setting.Wlan.WlanConfig.WlanSwitch.toggle';

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

@Builder export function requestDialogContentBuilder(param: SettingItemModel) {
  DialogContentComponent({item: param});
}

const TAG: string = 'SharedNetworkController : ';
const NETWOEK_CONNECT_TIMEOUT: number = 60000;
const NOT_FOUND: number = -1;
const ANONYMOUS_LEN: number = 4;
const ID_MIN_LEN: number = 8;

/**
 * 共享网络控制器
 *
 * @since 2024-09-01
 */
export default class SharedNetworkController implements ComponentControl {
  public isWlanLog: boolean = false;
  private isRegister: boolean = false;
  private connectingNetworkId: string = '';
  private isVisible: boolean = false;
  private dataSource?: OrderedDataSource;
  public compId?: string;
  private timerId: number | null = null;

  private anonymousId(id: string): string {
    if (id.length <= ID_MIN_LEN) {
      return id;
    }
    return id.substring(0, ANONYMOUS_LEN) + '***' + id.substring(id.length - ANONYMOUS_LEN);
  }

  private showOrHideHeader(isShow: boolean): void {
    LogUtil.info(`${TAG} showOrHideHeader isShow:${isShow} isVisible:${this.isVisible}`);
    notifyCompStateChange(`${this.compId}.header`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow && this.isVisible } as SettingCompState]]
    ));
    this.showOrHideGroup(isShow);
  }

  private showOrHideGroup(isShow: boolean): void {
    LogUtil.info(`${TAG} showOrHideGroup isShow:${isShow} isVisible:${this.isVisible}`);
    notifyCompStateChange(`${this.compId}`, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_GROUP_VISIBLE, { state: isShow && this.isVisible} as SettingCompState]]
    ));
  }

  public clearDeviceInfos(): void {
    LogUtil.info(`${TAG} clear device infos`);
    if (this.dataSource === undefined || this.dataSource?.length === 0) {
      LogUtil.info(`${TAG} dataSource already clear`);
      return;
    }
    this.dataSource?.removeAll();
    this.showOrHideHeader(false);
  };

  private onToggleChangeCallback = (toggleState: SettingToggleState) => {
    if (!toggleState) {
      LogUtil.error(`${TAG} toggleState is invalid`);
      return;
    }
    this.clearDeviceInfos();
    LogUtil.info(`${TAG} receive toggle state change: ${toggleState.state}`);
    this.isVisible = toggleState.state;
    if (this.isVisible) {
      this.notifyUserInitiatedEvent();
      this.getDeviceInfos();
    }
    this.showOrHideHeader(this.isVisible);
  };

  private finishConnect(): void {
    LogUtil.info(`${TAG} finishConnect`);
    if (this.timerId !== null) {
      clearTimeout(this.timerId);
      this.timerId = null;
    }
    this.connectingNetworkId = '';
  }

  private addDeviceInfo(info: DeviceInfo): void {
    if (info.deviceConnectionState === DeviceConnectionState.OFFLINE) {
      LogUtil.info(`${TAG} device connection offline, return`);
      return;
    }
    let menu = this.createApMenu(info);
    if (info.networkState === NetworkState.ACTIVE) {
      this.dataSource?.insertData(0, menu);
    } else {
      this.dataSource?.pushData(menu);
    }

    this.showOrHideHeader((this.dataSource?.length ?? 0) > 0);
  }

  private onDeviceStateChange = (info: DeviceInfo): void => {
    LogUtil.info(`${TAG} id:${this.anonymousId(info.networkId)}, cState:${info.deviceConnectionState}, nState:${info.networkState}, err:${info.errorResult}`);
    let index = this.dataSource?.findIndex(
      item => (item as SharedNetworkModel).networkId === info.networkId) ?? NOT_FOUND;
    if (index === NOT_FOUND) {
      LogUtil.info(`${TAG} ${this.anonymousId(info.networkId)},not found`);
      this.addDeviceInfo(info);
      return;
    }

    let menu: SharedNetworkModel = this.dataSource?.getData(index) as SharedNetworkModel;
    if (info.networkId === this.connectingNetworkId && info.errorResult !== ErrorResult.SUCCESS) {
      LogUtil.error(`${TAG} networkId:${this.anonymousId(info.networkId)}, connect failed`);
      this.finishConnect();
      this.ProcConnectFailed(menu, info.errorResult);
      return;
    }

    if (info.networkId === this.connectingNetworkId && info.networkState === NetworkState.ACTIVE) {
      LogUtil.info(`${TAG} networkId:${this.anonymousId(info.networkId)}, connnct success`);
      this.finishConnect();
    }

    if (info.deviceConnectionState !== DeviceConnectionState.OFFLINE && menu.networkState === info.networkState) {
      LogUtil.info(`${TAG} networkId:${this.anonymousId(info.networkId)}, not refresh`);
      return;
    }

    this.dataSource?.removeDataByIndex(index);
    if (info.deviceConnectionState === DeviceConnectionState.OFFLINE) {
      LogUtil.info(`${TAG} device offline ${info.deviceName}`);
      if (info.networkId === this.connectingNetworkId) {
        this.finishConnect();
      }
      this.showOrHideHeader((this.dataSource?.length ?? 0) > 0);
      return;
    }
    this.addDeviceInfo(info);
  };

  private onDeviceListChange = (infos: DeviceInfo[]): void => {
    LogUtil.info(`${TAG} onDeviceListChange`);
    if (infos.length === 0) {
      this.finishConnect();
    }
    let availableDevice: SharedNetworkModel[] = [];
    let connectDevice: SharedNetworkModel[] = [];
    infos.forEach((info: DeviceInfo) => {
      let index = this.dataSource?.findIndex(
        item => (item as SharedNetworkModel).networkId === info.networkId) ?? NOT_FOUND;
      if (index === NOT_FOUND) {
        LogUtil.info(`${TAG} add new device`);
        let model: SharedNetworkModel = this.createApMenu(info);
        info.networkState === NetworkState.ACTIVE ? connectDevice.push(model) : availableDevice.push(model);
      } else {
        let menu: SharedNetworkModel = this.dataSource?.getData(index) as SharedNetworkModel;
        if (info.deviceConnectionState === menu.connectState && info.networkState === menu.networkState) {
          info.networkState === NetworkState.ACTIVE ? connectDevice.push(menu) : availableDevice.push(menu);
        } else {
          LogUtil.info(`${TAG} deviceState has changed`);
          let model: SharedNetworkModel = this.createApMenu(info);
          info.networkState === NetworkState.ACTIVE ? connectDevice.push(model) : availableDevice.push(model);
        }
      }
    });
    this.clearDeviceInfos();
    this.dataSource?.pushDataArray(connectDevice);
    this.dataSource?.pushDataArray(availableDevice);
    this.showOrHideHeader((this.dataSource?.length ?? 0) > 0);
  };

  private registerDeviceStateChange(): void {
    try {
      // networkSharing.on('deviceStateChange', this.onDeviceStateChange);
    } catch (error) {
      LogUtil.error(`${TAG} registerDeviceStateChange error: ${error}`);
    }
  };

  private unRegisterDeviceStateChange(): void {
    try {
      // networkSharing.off('deviceStateChange', this.onDeviceStateChange);
    } catch (error) {
      LogUtil.error(`${TAG} unRegisterDeviceStateChange error: ${error}`);
    }
  };

  private registerDeviceListChange(): void {
    try {
      // networkSharing.on('deviceListChange', this.onDeviceListChange);
    } catch (error) {
      LogUtil.error(`${TAG} registerDeviceListChange error: ${error}`);
    }
  };

  private unRegisterDeviceListChange(): void {
    try {
      // networkSharing.off('deviceListChange', this.onDeviceListChange);
    } catch (error) {
      LogUtil.error(`${TAG} unRegisterDeviceListChange error: ${error}`);
    }
  };

  private registerDataChange(): void {
    EventBus.getInstance().on(WLAN_SWITCH_ID, this.onToggleChangeCallback);
    this.registerDeviceStateChange();
    this.registerDeviceListChange();
  }

  private unRegisterDataChange(): void {
    EventBus.getInstance().detach(WLAN_SWITCH_ID, this.onToggleChangeCallback);
    this.unRegisterDeviceStateChange();
    this.unRegisterDeviceListChange();
  }

  private generateId(info: DeviceInfo): string {
    let id = info.networkId + info.deviceName + info.deviceConnectionState + info.networkState;
    LogUtil.info(`${TAG} generateId:${id}`);
    return id;
  };

  private getContent(info: DeviceInfo): ResourceStr {
    LogUtil.info(`${TAG} getContent, networkId:${this.anonymousId(info.networkId)} networkState:${info.networkState}`);
    if (info.networkState === NetworkState.ACTIVE) {
      return $r('app.string.wifi_status_connected');
    }
    return '';
  }

  private getIcon(info: DeviceInfo): SettingIconModel {
    LogUtil.info(`${TAG} getIcon, networkId:${this.anonymousId(info.networkId)} networkState:${info.networkState}`);
    return {
      icon: $r('app.media.ic_status_bar_distributed_modem'),
      isSymbolIcon: false,
      iconType : SettingIconType.ICON_TYPE_TIP,
      style : {
        width: 24,
        height: 24,
        objectFit: ImageFit.Contain,
        draggable: false,
        fillColor: $r('sys.color.icon_primary'),
      }
    }
  }

  private getFontColor(info: DeviceInfo): ResourceColor | undefined {
    if (info.networkState === NetworkState.ACTIVE) {
      return $r('sys.color.font_emphasize');
    }
    return $r('sys.color.font_primary');
  }

  private startConnect(item: SharedNetworkModel): void {
    this.connectingNetworkId = item.networkId;
    sharedNetworkTracker.startConnect(item.networkId);
    let controller: SharedNetworkDeviceController = item.compControl as SharedNetworkDeviceController;
    let compId: string = controller?.compId as string;
    notifyCompStateChange(compId, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_DESP, { content: $r('app.string.wifi_status_connecting') } as SettingTextState]]
    ));
    this.timerId = setTimeout(() => {
      LogUtil.info(`${TAG} connect timeout`);
      this.ProcConnectFailed(item, ErrorResult.NETWORK_ERROR_FAILED_MSG);
    }, NETWOEK_CONNECT_TIMEOUT);
  }

  private ProcConnectFailed(item: SharedNetworkModel, errorResult: ErrorResult): void {
    item.operator = OPERATOR_CONNECT_FAILED;
    item.errorResult = errorResult;
    this.connectingNetworkId = '';
    let controller: SharedNetworkDeviceController = item.compControl as SharedNetworkDeviceController;
    let compId:string = controller.compId as string;
    if (compId === undefined || compId.length === 0) {
      LogUtil.error(`${TAG} Connect Failed Dialog, compId null, return`);
      return;
    }

    notifyCompStateChange(compId, new Map<SettingStateType, SettingBaseState>(
      [[SettingStateType.STATE_TYPE_ITEM_DESP, { content: '' } as SettingTextState]]
    ));

    notifyCompStateChange(compId, new Map(
      [[SettingStateType.STATE_TYPE_ITEM_DIALOG, {
        contentBuilder: wrapBuilder(requestDialogContentBuilder),
        title: $r('app.string.bt_connect_failed_title'),
        buttons: [
          {
            value: $r('app.string.dialog_know'),
            style: {
              buttonStyle: ButtonStyleMode.TEXTUAL,
            },
            action: (component: SettingItemModel) => {
            },
          },
        ],
        buttonVertical: true,
      } as SettingDialogState]]
    ));
  }

  private openDisconnectRequestDialog(networkId: string, compId: string): void {
    LogUtil.info(`${TAG} openDisconnectRequestDialog`);
    notifyCompStateChange(compId, new Map(
      [[SettingStateType.STATE_TYPE_ITEM_DIALOG, {
        contentBuilder: wrapBuilder(requestDialogContentBuilder),
        title: $r('app.string.shared_network_disconnect_title'),
        buttons: [
          {
            value: $r('app.string.button_tittle_cancel'),
            style: { buttonStyle: ButtonStyleMode.TEXTUAL, },
            action: (component: SettingItemModel) => {},
          },
          {
            value: $r('app.string.shared_network_disconnect'),
            style: { buttonStyle: ButtonStyleMode.TEXTUAL, },
            action: (component: SettingItemModel) => {
              sharedNetworkTracker.deleteConnect(networkId);
            },
          },
        ],
        buttonVertical: true,
      } as SettingDialogState]]
    ));
  }

  private createApMenu(info: DeviceInfo): SharedNetworkModel {
    return {
      id: this.generateId(info),
      connectState : info.deviceConnectionState,
      networkState : info.networkState,
      networkId : info.networkId,
      deviceName : info.deviceName,
      errorResult : info.errorResult,
      compare: (dst: ComparableSettingItemModel) => {
        return 0;
      },
      divider: {
        leftPadding: PADDING_40,
      },
      key:  '',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: info.deviceName,
        style: {
          fontSize: $r('sys.float.Body_L'),
          fontColor: this.getFontColor(info),
          fontFamily: 'HarmonyHeiTi',
          fontWeight: FontWeight.Medium,
          textAlign: TextAlign.Start,
        }
      },
      desc: {
        content: this.getContent(info),
      },
      icon: this.getIcon(info),
      compControl: new SharedNetworkDeviceController(),
      detail : {
        type: ItemDetailType.DETAIL_TYPE_CUSTOM,
        icon: '',
        iconType: SettingIconType.ICON_TYPE_TIP,
        responseRegion: { width: 48, height: 48 },
        style: { width: 24, height: 24, fillColor: $r('sys.color.icon_secondary') },
        onItemClick: (component: SettingBaseModel) => {
          this.handleBondedDeviceItemClick(component);
        },
        onSelfClick: (component: SettingBaseModel) => {},
      },
    };
  }

  private handleBondedDeviceItemClick(component: SettingBaseModel): void {
    if (!component) {
      LogUtil.error(`${TAG} handleBondedDeviceItemClick fail, component is invalid`);
      return;
    }

    let sharedNetworkModel: SharedNetworkModel = component as SharedNetworkModel;
    if (!sharedNetworkModel || !(sharedNetworkModel?.compControl instanceof SharedNetworkDeviceController)) {
      LogUtil.error(`${TAG} SharedNetworkModel is invalid, return`);
      return;
    }

    let controller: SharedNetworkDeviceController = sharedNetworkModel.compControl as SharedNetworkDeviceController;
    let compId: string = controller?.compId as string;
    if (sharedNetworkModel.networkState === NetworkState.ACTIVE) {
       sharedNetworkModel.operator = OPERATOR_DISCONNECT;
       LogUtil.info(`${TAG} handleBondedDeviceItemClick, OPERATOR_DISCONNECT`);
       this.openDisconnectRequestDialog(sharedNetworkModel.networkId, compId);
       return;
    }

    if (this.connectingNetworkId.length !== 0) {
        LogUtil.info(`${TAG} connecting, networkId ${this.anonymousId(this.connectingNetworkId)}, return`);
        return;
    }

    this.startConnect(sharedNetworkModel);
  }

  private refreshDeviceList(data: DeviceInfo[]): void {
    LogUtil.info(`${TAG} refreshDeviceList`);
    this.dataSource?.removeAll();
    let availableDevice: SharedNetworkModel[] = [];
    for (let index = 0; index < data.length; index++) {
      if ((data[index] as DeviceInfo).deviceName.length === 0 ||
        (data[index] as DeviceInfo).networkId.length === 0) {
        continue;
      }
      if ((data[index] as DeviceInfo).networkState === NetworkState.ACTIVE) {
        this.dataSource?.insertData(0, this.createApMenu(data[index] as DeviceInfo));
        continue;
      }
      availableDevice.push(this.createApMenu(data[index] as DeviceInfo));
    }
    this.dataSource?.pushDataArray(availableDevice);
    this.showOrHideHeader((this.dataSource?.length ?? 0) > 0);
  }

  private notifyUserInitiatedEvent(): void {
    LogUtil.info(`${TAG} notifyUserInitiatedEvent for device online`);
    let event: Record<string, Object> = {
      'module': 'deviceDetect',
      'eventCode': 1
    };
    // serviceDelivery.notifyUserInitiatedEvent(JSON.stringify(event));
  }

  private getDeviceInfos(): void {
    LogUtil.info(`${TAG} getDeviceInfos`);
    try {
      // sharedNetworkTracker.getDeviceInfos()
      //   .then((data) => {
      //     this.refreshDeviceList(data);
      //   })
      //   .catch((error: Error) => {
      //     LogUtil.error(`${TAG} getDeviceInfos .catch: ${error.message}`);
      //     this.showOrHideHeader(false);
      //   });
    } catch (error) {
      this.showOrHideHeader(false);
      LogUtil.error(`${TAG} getDeviceInfos catch: ${error.message}`);
    }
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    this.showOrHideHeader(false);
    if (!DeviceUtil.isDevicePad() && !DeviceUtil.isDevicePc()) {
      LogUtil.error(`${TAG} init isDevicePadOrPc false`);
      return;
    }

    if (!WifiUtils.isShared()) {
      LogUtil.error(`${TAG} const.booster.virtual_modem_switch is false`);
      return;
    }

    this.dataSource = compParam.dataSource as OrderedDataSource;
    this.compId = compParam.compId as string;
    this.isVisible = true;
    this.registerDataChange();
    this.notifyUserInitiatedEvent();
    this.getDeviceInfos();
    this.isRegister = true;
  }

  destroy(): void {
    if (!DeviceUtil.isDevicePad() && !DeviceUtil.isDevicePc()) {
      LogUtil.info(`${TAG} destroy isTablet false`);
      this.showOrHideHeader(false);
      return;
    }
    LogUtil.info(`${TAG} destroy. isRegister:${this.isRegister}`);
    if (!this.isRegister) {
      return;
    }
    if (this.timerId !== null) {
      LogUtil.info(`${TAG} destroy.timerId: ${this.timerId}`);
      clearTimeout(this.timerId);
      this.timerId = null;
    }
    this.unRegisterDataChange();
    this.isRegister = false;
  }

  onClick?(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onClick`);
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} onPageHide`);
  }
}