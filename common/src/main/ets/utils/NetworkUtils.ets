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
import { LogUtil } from './LogUtil';

/* instrument ignore file */
const TAG: string = 'NetworkUtils : ';

export class NetworkUtils {
  public static isNetworkAvailable(): boolean {
    let isAvailable = false;
    try {
      let netHandle = connection.getDefaultNetSync();
      if (!netHandle) {
        LogUtil.warn(`${TAG} getNetworkValidated, network not connect`)
        return isAvailable;
      }
      let netCapabilities = connection.getNetCapabilitiesSync(netHandle);
      if (!netCapabilities) {
        LogUtil.warn(`${TAG} getNetworkValidated, netCapabilitiesSync is null`)
        return false;
      }
      let hasInternet = netCapabilities?.networkCap?.includes(connection.NetCap.NET_CAPABILITY_INTERNET);
      let internetValidated = netCapabilities?.networkCap?.includes(connection.NetCap.NET_CAPABILITY_VALIDATED);
      if (hasInternet && internetValidated) {
        isAvailable = true;
      }
      LogUtil.info(`${TAG} isNetworkAvailable ${hasInternet} ${internetValidated}`);
    } catch (err) {
      LogUtil.error(`${TAG} get network state is error, code: ${err?.code}, message: ${err?.message}`);
    }
    return isAvailable;
  }
}