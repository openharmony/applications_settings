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
import type { BusinessError } from '@ohos.base';
import connection from '@ohos.net.connection';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { IEthernetConnectionManager, IEthernetEventCallback, NetworkEventType } from './IEthernetConnectionManager';

const TAG: string = 'EthernetConnectionManager : ';

/**
 * 以太网连接管理
 */
class EthernetConnectionManager implements IEthernetConnectionManager {
  private ethernetConnection: connection.NetConnection | null = null;
  private networkStatusChangeListener: ((error: BusinessError) => void) | null = null;
  private netEventListenerMap: Map<NetworkEventType, IEthernetEventCallback<object>> = null;
  private netEventListenerKeys: Map<NetworkEventType, object> = null;

  public constructor() {
    // 建立以太网网络的系统侧句柄
    this.ethernetConnection = connection.createNetConnection({
      netCapabilities: {
        bearerTypes: [connection.NetBearType.BEARER_ETHERNET]
      }
    });

    // 网络连接状态监听器实例化
    this.networkStatusChangeListener = (error: BusinessError): void => {
      LogUtil.info(`${TAG} Network status change received`);
      if (error) {
        LogUtil.error(`${TAG} Network status change error:${error.code}`);
      }
    };

    // 以太网网络事件监听器初始化
    this.initializeNetEventListeners();
  }

  public registerEventCallback(type: NetworkEventType, callback: IEthernetEventCallback<object>, key: string = ''): void {
    if (!this.netEventListenerMap[type].includes(callback) && !(this.netEventListenerKeys[type]).includes(key)) {
      this.netEventListenerMap[type].push(callback);
      this.netEventListenerKeys[type].push(key);
    }
  }

  public unregisterEventCallback(type: NetworkEventType, callback: IEthernetEventCallback<object>, key: string = ''): void {
    this.netEventListenerMap[type] = this.netEventListenerMap[type].filter((fn) => fn !== callback);
    this.netEventListenerKeys[type] = this.netEventListenerKeys[type].filter((k) => k !== key);
  }

  public registerNetworkStatusChangeListener(): void {
    LogUtil.info(`${TAG} Register net status change listener start`);

    if (this.ethernetConnection) {
      this.ethernetConnection.register(this.networkStatusChangeListener as () => void);
    }
  }

  public unregisterNetworkStatusChangeListener(): void {
    LogUtil.info(`${TAG} Unregister net status change listener start`);

    if (this.ethernetConnection) {
      this.ethernetConnection.unregister(this.networkStatusChangeListener as () => void);
    }
  }

  private initializeNetEventListeners(): void {
    this.netEventListenerMap = new Map();
    this.netEventListenerKeys = new Map();

    try {
      for (let evt in NetworkEventType) {
        this.netEventListenerMap[NetworkEventType[evt]] = [];
        this.netEventListenerKeys[NetworkEventType[evt]] = [];

        // 注册以太网网络事件的监听器
        (this.ethernetConnection as connection.NetConnection).on(NetworkEventType[evt],
          (data?: Record<string, Object> | void) => {
            this.emit(NetworkEventType[evt], data);
          });

      }
    } catch (error) {
      LogUtil.error(`${TAG} init net evt error: ${error?.code}`);
    }
  }

  private emit(type: NetworkEventType, data: Record<string, Object> | void): void {
    this.netEventListenerMap[type].forEach((handleFunc) => {
      if (Object.prototype.toString.call(handleFunc) === '[object Function]') {
        handleFunc(data);
      }
    });
  }
}

export { EthernetConnectionManager };
