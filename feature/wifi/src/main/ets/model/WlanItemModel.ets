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

import wifiManager from '@ohos.wifiManager';
import { ComparableSettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { AccessPoint, WifiScanResult } from './WifiModel';

export interface WlanItemModel extends ComparableSettingItemModel {
  key?: string;
  isLast?: boolean,
  wlanName?: ResourceStr;
  securityType?: number;
  ssid?: string;
  bssid?: string;
  level?: number;
  bssidType?: wifiManager.DeviceAddressType | undefined;
  summary?: ResourceStr | string;
  stateIcon?: ResourceStr | undefined;
  isHiLinkNetwork?: boolean;
  isHiLinkProNetwork?: boolean;
  config?: wifiManager.WifiDeviceConfig | undefined;
  isLoading?: boolean;
  apKey?: string;
  timestamp?: number;
  supportedWifiCategory?: number;
  state?: string;
  scanResults?: WifiScanResult[];
  accessPoint?: AccessPoint;
  status?: boolean;
  capabilities?: string;
}

