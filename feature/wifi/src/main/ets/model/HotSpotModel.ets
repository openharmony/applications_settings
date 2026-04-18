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

import { BaseEntryMenu, BaseEntryMenuData } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';

export interface HotSpotMenuData extends BaseEntryMenuData {
  deviceId: string;
  networkId ?: string;
  deviceName: string;
  deviceType: string;
  bssid: string;
}

export class HotSpotMenu extends BaseEntryMenu implements HotSpotMenuData {
  public deviceId: string;
  public networkId?: string;
  public deviceName: string;
  public deviceType: string;
  public isConnected: boolean;
  public bssid: string;

  constructor(menu: Partial<HotSpotMenuData>) {
    super(menu);
    this.deviceId = menu.deviceId as string;
    this.networkId = menu.networkId as string;
    this.deviceName = menu.deviceName as string;
    this.deviceType = menu.deviceType as string;
    this.isConnected = false;
    this.bssid = menu.bssid as string;
  }

  toString(): string {
    return `key:${this.key}, timestamp:${this.timestamp}, isConnected: ${this.isConnected}`;
  }
}
