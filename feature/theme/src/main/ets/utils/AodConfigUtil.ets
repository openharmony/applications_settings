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
import systemParameterEnhance from '@ohos.systemParameterEnhance';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG: string = 'AodConfigUtil';

export enum AodSwitch {
  CLOSE = 0, // 关闭
  OPEN = 1, // 开启
}

export enum AodDisplayMode {
  INTELLIGENT_SHOW = 0, // 智能显示
  SCHEDULED_SHOW = 1, // 定时显示
  ALL_DAY_SHOW = 2, // 全天显示
}

export enum AodStateValue {
  UNKNOWN = 0, // 未知
  CLOSE = 1, // 关闭
  INTELLIGENT_SHOW = 2, // 智能显示
  SCHEDULED_SHOW = 3, // 定时显示
  ALL_DAY_SHOW = 4, // 全天显示
}

export class AodState {
  public switch: AodSwitch = AodSwitch.CLOSE;
  public displayMode: AodDisplayMode = AodDisplayMode.INTELLIGENT_SHOW;
}

export enum AodSupportType {
  NO = 0,
  SENSOR_HUB = 1,
  AP = 2,
}

export class AodConfigUtil {
  /**
   * 支持AOD类型索引范围
   */
  private static readonly INDEX_RANGE_SUPPORT_AOD: [number, number] = [0, 2];

  private static config: string = '';

  /**
   * 该设备是否支持Aod，第0,1位：表示是否支持AOD， 00：不支持， 01：支持SensorHub方案， 10：支持AP方案
   * @returns true：支持，false：不支持
   */
  public static isSupportAOD(): boolean {
    const config: number = AodConfigUtil.parseConfig(AodConfigUtil.INDEX_RANGE_SUPPORT_AOD);
    return [AodSupportType.SENSOR_HUB, AodSupportType.AP].includes(config);
  }

  private static parseConfig(indexRange: [number, number]): number {
    let config: string = AodConfigUtil.getConfig();
    if (config.trim().length === 0) {
      // 空字符串，赋默认值
      config = '0';
    }
    // 按照十进制将字符串转换成数字，按照二进制将数字转换成字符串
    const binary: string = Number.parseInt(config).toString(2);
    const length: number = binary.length;
    // 根据需要截取字符串
    let subBinary: string = binary.substring(length - indexRange[1], length - indexRange[0]);
    if (subBinary.trim().length === 0) {
      // 空字符串，赋默认值
      subBinary = '0';
    }
    // 按照二进制将字符串转换成数字
    return Number.parseInt(subBinary, 2);
  }

  private static getConfig(): string {
    try {
      if (AodConfigUtil.config.trim().length === 0) {
        AodConfigUtil.config = systemParameterEnhance.getSync('const.aod.hardware_config', '');
      }
      return AodConfigUtil.config;
    } catch (e) {
      LogUtil.showError(TAG, `Fail to get system param, error = ${e?.code}, ${e?.message}`);
      return '';
    }
  }
}
