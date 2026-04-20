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
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { Constants } from '../constant/Constants';
import { EthernetUtil } from '../util/EthernetUtil';
import { EthernetConnectionManager } from './EthernetConnectionManager';
import { IEthernetInfo } from './IEthernetInfo';
import { IEthernetInterfaceInfoModel } from './IEthernetInterfaceInfoModel';
import {
  IEthernetConnectionManager,
  IEthernetEventCallback,
  INVALID_ETH_INDEX,
  NetworkEventType
} from './IEthernetConnectionManager';

const EVT_LSR_KEY: string = '[Network] ';
const TAG: string = 'EthernetInterfaceInfoModel : ';

export class IFaceData {
  iface: string = '';
  active: boolean = false;

  constructor(iface: string, active: boolean) {
    this.iface = iface;
    this.active = active;
  }
}

/**
 * Modeling For Ethernet IFC Data
 */
class EthernetInterfaceInfoModel implements IEthernetInterfaceInfoModel {
  private ethernetInfoList: IEthernetInfo[] | null = null;
  private ethConnectionManager: IEthernetConnectionManager | null = null;

  public constructor() {
    this.ethernetInfoList = [];
  }

  public initModel(): void {
    LogUtil.info(`${TAG} EthernetInterfaceInfoModel initModel`);
    if (!this.ethConnectionManager) {
      this.ethConnectionManager = new EthernetConnectionManager();
      this.ethConnectionManager.registerNetworkStatusChangeListener();
    }

    if (this.ethConnectionManager) {
      this.ethConnectionManager.registerEventCallback(NetworkEventType.AVAILABLE,
        (data) => this.handleNetEvent4NetAvailable(data), EVT_LSR_KEY);
      this.ethConnectionManager.registerEventCallback(NetworkEventType.CAPABILITIES,
        (data) => this.handleNetEvent4NetCapabilitiesChange(data), EVT_LSR_KEY);
      this.ethConnectionManager.registerEventCallback(NetworkEventType.PROPERTIES,
        (data) => this.handleNetEvent4NetConnectionPropertiesChange(data), EVT_LSR_KEY);
      this.ethConnectionManager.registerEventCallback(NetworkEventType.LOST,
        (data) => this.handleNetEvent4NetLost(data), EVT_LSR_KEY);
    }
  }

  public registerEventCallback(type: NetworkEventType, callback: IEthernetEventCallback<object>, key: string): void {
    if (this.ethConnectionManager) {
      this.ethConnectionManager.registerEventCallback(type, callback, key);
    }
  }

  public unregisterEventCallback(type: NetworkEventType, callback: IEthernetEventCallback<object>, key: string): void {
    if (this.ethConnectionManager) {
      this.ethConnectionManager.unregisterEventCallback(type, callback, key);
    }
  }

  public unregisterNetStatusListener(): void {
    this.ethernetInfoList = [];
    AppStorage.setOrCreate('ethernetList', this.ethernetInfoList);
    EventBus.getInstance().emit(Constants.ETHERNET_CHANGE_EVENT);
    if (this.ethConnectionManager) {
      this.ethConnectionManager.unregisterNetworkStatusChangeListener();
      this.ethConnectionManager = null;
    }
  }

  handleNetEvent4NetLost(data): void {
    try {
      LogUtil.info(`${TAG} handleNetEvent4NetLost`);
      this.ethernetInfoList = (this.ethernetInfoList as IEthernetInfo[]).filter((net: IEthernetInfo) => data?.netId !==
        net?.netHandle?.netId);
      this.refreshModelData();
      EventBus.getInstance().emit(Constants.ETHERNET_INTERNET_AVAILABLE_EVENT, false);
    } catch (err) {
      LogUtil.error(`${TAG} handleNetEvent4NetLost error: ${err?.code}`);
    }
  }

  handleNetEvent4NetConnectionPropertiesChange(data): void {
    LogUtil.info(`${TAG} handleNetEvent4NetConnectionPropertiesChange`);
    this.doCapabilitiesOrConnectionChange(data);
  }

  handleNetEvent4NetCapabilitiesChange(data): void {
    LogUtil.info(`${TAG} handleNetEvent4NetCapabilitiesChange, networkCap : ${data?.netCap?.networkCap}`);
    if (EthernetUtil.isEthernetNetworkValidated(data?.netCap?.networkCap)) {
      EventBus.getInstance().emit(Constants.ETHERNET_INTERNET_AVAILABLE_EVENT, true);
    } else {
      EventBus.getInstance().emit(Constants.ETHERNET_INTERNET_AVAILABLE_EVENT, false);
    }
    this.doCapabilitiesOrConnectionChange(data);
  }

  doCapabilitiesOrConnectionChange(data): void {
    const index =
      (this.ethernetInfoList as IEthernetInfo[]).findIndex((net: IEthernetInfo) => data?.netHandle?.netId ===
        net?.netHandle?.netId);
    if (index === INVALID_ETH_INDEX) {
      (this.ethernetInfoList as IEthernetInfo[]).push(data);
    } else {
      (this.ethernetInfoList as IEthernetInfo[])[index] = {
        ...(this.ethernetInfoList as IEthernetInfo[])[index],
        ...data,
      };
    }
    this.refreshModelData();
  }

  refreshModelData(): void {
    LogUtil.info(`${TAG} refreshModelData`);
    AppStorage.setOrCreate('ethernetList', (this.ethernetInfoList as IEthernetInfo[]).filter((net: IEthernetInfo) => {
      return Array.isArray(net?.netCap?.bearerTypes) &&
      net?.netCap?.bearerTypes.includes(connection.NetBearType.BEARER_ETHERNET);
    }));
    EventBus.getInstance().emit(Constants.ETHERNET_CHANGE_EVENT);
  }

  handleNetEvent4NetAvailable(data): void {
    LogUtil.info(`${TAG} handleNetEvent4NetAvailable`);
    const index = (this.ethernetInfoList as IEthernetInfo[]).findIndex((net: IEthernetInfo) => data?.netId ===
      net?.netHandle?.netId);
    if (index === INVALID_ETH_INDEX) {
      (this.ethernetInfoList as IEthernetInfo[]).push({
        netHandle: data,
      });
    }
    LogUtil.info(`${TAG} handleNetEvent4NetAvailable, push end ethernetIfcList index : ${index}`);
  }
}

export { EthernetInterfaceInfoModel };
