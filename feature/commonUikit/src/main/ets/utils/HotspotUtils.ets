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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
/* instrument ignore file */
const TAG: string = 'HotspotUtils : ';

export class HotspotUtils {
  /**
   * 是否支持双频（5G和2.4G）
   *
   * @returns 是否支持双频
   */
  static isHotspotDualBandSupported(): boolean {
    try {
      let isHotspotDualBandSupported: boolean = wifiManager.isHotspotDualBandSupported();
      LogUtil.info(`${TAG} isHotspotDualBandSupported: ${isHotspotDualBandSupported}`);
      return isHotspotDualBandSupported;
    } catch (error) {
      LogUtil.error(`${TAG} isHotspotDualBandSupported fail: ${error?.message}`);
    }
    return false;
  }

  /**
   * 获取国家码信息
   *
   * @returns 国家码信息
   */
  static getCountryCode(): string {
    try {
      let countryCode: string = wifiManager.getCountryCode();
      if (StringUtil.isEmpty(countryCode)) {
        LogUtil.info(`${TAG} current countryCode is empty.`);
        return '';
      }
      LogUtil.info(`${TAG} getCountryCode success.`);
      return countryCode;
    } catch (error) {
      LogUtil.error(`${TAG} getCountryCode fail code: ${error?.code}, message: ${error?.message}`);
    }
    return '';
  }

  static disableHotspot(): boolean {
    try {
      wifiManager.disableHotspot();
      return true;
    } catch (err) {
      LogUtil.error(`${TAG} disableHotspot error code: ${err?.code}, message: ${err?.message}`);
    }
    return false;
  }

  static isHotspotActive(): boolean {
    try {
      return wifiManager.isHotspotActive();
    } catch (err) {
      LogUtil.error(`${TAG} isHotspotActive error code: ${err?.code}, message: ${err?.message}`);
    }
    return false;
  }
}