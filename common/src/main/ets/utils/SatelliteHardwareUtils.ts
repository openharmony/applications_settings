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

// @ts-ignore
import satellite from '@ohos.telephony.satellite';
import { LogUtil } from './LogUtil';

const TAG: string = 'SatelliteHardwareUtils : ';
/**
 * SatelliteHardware工具类
 */
export class SatelliteHardwareUtils {

  /**
   * 判断硬件是否支持卫星功能
   *
   * @param tag
   */
  public static isSupportHard(satelliteType : number): boolean {
    try {
      let support: boolean = satellite.getSatelliteHardwareSupportInfo(satelliteType);
      LogUtil.info(`${TAG} getSatelliteHardwareSupportInfo, type:${satelliteType}, support:${support}`);
      return support;
    } catch (error) {
      LogUtil.error(`${TAG} getSatelliteHardwareSupportInfo, failed.`);
    }

    return true;
  }
}
