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
import wifiManager from '@ohos.wifiManager';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ApBand } from '../constants/HotSpotConstants';

const TAG: string = 'HotSpotUtils : ';
export const MAX_MB_NUM: number = 1024;
export const MAX_BYTE_NUM: number = 1024;
export const MAX_KB_NUM: number = 1024;
export const MB_STR: string = 'MB';
export const GB_STR: string = 'GB';
export const KB_STR: string = 'KB';
export const BYTE_STR: string = 'B';
export const USER_DATA_LIMIT_CONFIRM_EVENT: string = 'limit_confirm';
export const DATA_LIMIT_KEY: string = 'wifiap_one_usage_limit';
export const USED_DATA_KEY: string = 'wifiap_one_usage_stats';
export const NEED_DIALOG_KEY: string = 'hotspot_need_open_dialog';
export const INPUT_EMPTY: string = 'input_empty';
export const NEED_DIALOG_VALUE: string = '1';
export const NO_NEED_DIALOG_VALUE: string = '0';
export const HOTSPOT_CONFIG_CHANGE_EVENT = 'hotspot_config_change';
export const UNIT_TRANSLATE: Map<string, string> = new Map([
  [MB_STR, 'megabyte'],
  [GB_STR, 'gigabyte'],
  [KB_STR, 'kilobyte'],
  [BYTE_STR, 'byte'],
]);

export class HotSpotUtils {
  public static getHotspotConfig(): wifiManager.HotspotConfig | null {
    try {
      return wifiManager.getHotspotConfig();
    } catch (err) {
      LogUtil.error(`${TAG} getHotspotConfig error: ${err?.message}`);
    }
    return null;
  }

  public static isHotspotActive(): boolean {
    try {
      return wifiManager.isHotspotActive();
    } catch (err) {
      LogUtil.error(`${TAG} isHotspotActive error: ${err?.message}`);
    }

    return false;
  }

  public static disableHotspot(): void {
    try {
      wifiManager.disableHotspot();
    } catch (err) {
      LogUtil.error(`${TAG} disableHotspot error: ${err?.message}`);
    }
  }

  public static enableHotspot(): void {
    try {
      wifiManager.enableHotspot();
    } catch (err) {
      LogUtil.error(`${TAG} enableHotspot error: ${err?.message}`);
    }
  }

  public static setHotspotConfig(config: wifiManager.HotspotConfig): void {
    if (!config) {
      LogUtil.error(`${TAG} setHotspotConfig fail, config is empty.`);
      return;
    }

    try {
      wifiManager.setHotspotConfig(config);
    } catch (err) {
      LogUtil.error(`${TAG} setHotspotConfig error: ${err?.message}`);
    }
  }

  public static getApBandResourceStr(apBand: number): ResourceStr {
    switch (apBand) {
      case ApBand.AP_BAND_2_4:
        return $r('app.string.hotspot_band_2_4');
      case ApBand.AP_BAND_5:
        return $r('app.string.hotspot_band_5');
      default:
        return $r('app.string.hotspot_band_2_4');
    }
  }

  public static getConvertedMb2Gb(value: string): string {
    let num: number = parseInt(value);
    if (Number.isNaN(num) || num < 0) {
      return ResourceUtil.getStringSync($r('app.string.no_limit'))
    }
    let unit: string = MB_STR;
    if (num >= MAX_MB_NUM) {
      unit = GB_STR;
      num = Math.floor(num / MAX_MB_NUM);
    }
    return num.toString() + ' ' + unit;
  }

  public static getLimitStringFromNumber(value: number): string {
    if (value < 0) {
      return ResourceUtil.getStringSync($r('app.string.no_limit'));
    }
    let unit: string = MB_STR;
    if (value >= MAX_MB_NUM) {
      unit = GB_STR;
      value = Math.floor(value / MAX_MB_NUM);
    }
    return value.toString() + unit;
  }

  public static getUnitByLimitString(limit: string): string {
    let result: number = parseInt(limit);
    if (Number.isNaN(result)) {
      return MB_STR;
    }
    if (result >= MAX_MB_NUM) {
      return GB_STR;
    }
    return MB_STR;
  }

  public static convertMb2GbNumberFormat(value: string): string {
    let valueNum = parseInt(value);
    if (Number.isNaN(valueNum)) {
      return '';
    }
    if (valueNum >= MAX_MB_NUM) {
      valueNum = Math.floor(valueNum / MAX_MB_NUM);
    }
    return valueNum.toString();
  }

  public static convertMb2GbNumber(value: number): number {
    if (Number.isNaN(value) || value < 0) {
      return -1;
    }
    if (value >= MAX_MB_NUM) {
      value = Math.floor(value / MAX_MB_NUM);
    }
    return value;
  }

  public static convertMb2Byte(value: number): number {
    if (Number.isNaN(value) || value < 0) {
      return -1;
    }
    return value * MAX_KB_NUM * MAX_BYTE_NUM;
  }

  public static convertByteUnit(value: string): string {
    let num: number = parseInt(value);
    if (Number.isNaN(num) || num < 0) {
      return '';
    }
    let resultNum: number = num;
    let unit: string = '';
    if (resultNum >= MAX_BYTE_NUM * MAX_KB_NUM * MAX_MB_NUM) {
      resultNum = Math.floor(resultNum / (MAX_BYTE_NUM * MAX_KB_NUM * MAX_MB_NUM));
      unit = GB_STR;
    } else if (resultNum >= MAX_BYTE_NUM * MAX_KB_NUM) {
      resultNum = Math.floor(resultNum / (MAX_BYTE_NUM * MAX_KB_NUM));
      unit = MB_STR;
    } else if (resultNum >= MAX_BYTE_NUM) {
      resultNum = Math.floor(resultNum / MAX_BYTE_NUM);
      unit = KB_STR;
    } else {
      unit = BYTE_STR;
    }
    return resultNum.toString() + ' ' + unit;
  }

  public static isSupportDualApBand(): boolean {
    try {
      return wifiManager.isHotspotDualBandSupported();
    } catch (e) {
      LogUtil.error(`${TAG} isSupportDualApBand fail, error code: ${e?.code}, message: ${e?.message}`);
      return false;
    }
  }
}