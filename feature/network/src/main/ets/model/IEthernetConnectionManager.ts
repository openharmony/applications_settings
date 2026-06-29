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

enum NetworkEventType {
  PROPERTIES = 'netConnectionPropertiesChange',
  AVAILABLE = 'netAvailable',
  CAPABILITIES = 'netCapabilitiesChange',
  LOST = 'netLost',
  UNAVAILABLE = 'netUnavailable',
}

interface IEthernetEventCallback<T> {
  (data: T): void;
}

const INVALID_ETH_INDEX: number = -1;

interface IEthernetConnectionManager {
  /**
   * 根据网络事件类型注册回调
   */
  registerEventCallback(type: NetworkEventType, callback: IEthernetEventCallback<object>, key: string);

  /**
   * 根据网络事件类型注销回调
   */
  unregisterEventCallback(type: NetworkEventType, callback: IEthernetEventCallback<object>, key: string);

  /**
   * 网络状态监听器注册
   */
  registerNetworkStatusChangeListener(): void;

  /**
   * 网络状态监听器注销
   */
  unregisterNetworkStatusChangeListener(): void;
}

export type { IEthernetEventCallback, IEthernetConnectionManager };

export { INVALID_ETH_INDEX, NetworkEventType };
