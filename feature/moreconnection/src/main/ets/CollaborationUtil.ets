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

import { BusinessError } from '@ohos.base';
import wifiManager from '@ohos.wifiManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';

const TAG: string = 'CollaborationUtil: ';
const INACTIVE: number = 0;
const UNKNOWN: number = -1;
const SEMI_ACTIVATING : number = 4;
const SEMI_ACTIVE : number = 5;

export class CollaborationUtil {
  /**
   * 如果WLAN是半关闭状态，则再次调用关闭接口
   */
  static disableWifiIfNeed(): void {
    try {
      let wifiState: number = CollaborationUtil.getDetailState();
      LogUtil.info(`${TAG} disableWifiIfNeed: current wifi state is ${wifiState}`);
      if (wifiState !== SEMI_ACTIVE && wifiState !== SEMI_ACTIVATING) {
        return;
      }
      WifiUtils.disableWifi();
      LogUtil.info(`${TAG} change wifi state from SEMIACTIVE to IACTIVE success.`);
    } catch (error) {
      LogUtil.error(`Failed to get wifi detail state, errCode:${(error as BusinessError).code}, message:${(error as BusinessError).message}`);
    }
  }

  /**
   * 如果WLAN是关闭状态，则再次调用切换至半关闭接口
   */
  static enableWifiIfNeed(): void {
    try {
      let wifiState: number = CollaborationUtil.getDetailState();
      LogUtil.info(`${TAG} enableWifiIfNeed: current wifi state is ${wifiState}`);
      if (wifiState !== INACTIVE) {
        return;
      }
      WifiUtils.enableSemiWifi();
      LogUtil.info(`${TAG} change wifi state from INACTIVE to SEMIACTIVE success.`);
    } catch (error) {
      LogUtil.error(`Failed to get wifi detail state, errCode:${(error as BusinessError).code}, message:${(error as BusinessError).message}`);
    }
  }

  /**
   * 获取当前wifi开启状态
   *
   * @returns 当前wifi开启状态
   */
  static getDetailState(): number {
    try {
      return wifiManager.getWifiDetailState();
    } catch (error) {
      LogUtil.error(`Failed to get wifi detail state, errCode:${(error as BusinessError).code}, message:${(error as BusinessError).message}`);
      return UNKNOWN;
    }
  }
}