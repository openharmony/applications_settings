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

import { LogUtil } from './LogUtil';
import power from '@ohos.power';
import osAccount from '@ohos.account.osAccount';

/* instrument ignore file */
const TAG = 'SecurityUtil : ';

/**
 * 指纹凭据类型
 */
export const FINGERPRINT_CRED_TYPE: number = 4;

/**
 * 指纹凭据子类型
 */
export const FINGERPRINT_SUB_CRED_TYPE: number = 10000;

/**
 * 指纹凭据KEY
 */
export const FINGERPRINT_CRED_KEY: [number] = [5];

/**
 * 器件类型
 */
export const FINGERPRINT_SENSOR_TYPE: string = 'sensorType';

/**
 * 侧边指纹
 */
export const OUT_OF_SCREEN_SENSOR: string = 'OUT_OF_SCREEN_SENSOR';

interface DevModeConfig {
  version: number,
  enable: number,
  type: string,
  authToken: string,
};

export class SecurityUtil {
  static rebootDevice(): void {
    LogUtil.showInfo(TAG, `reboot device`);
    try {
      power.reboot('reboot_settings');
    } catch (err) {
      LogUtil.error(`reboot failed, err: ${err?.code} ${err?.message}`)
    }
  }

  static async setDevelopMode(enable: number): Promise<number> {
    try {
      // let dsmmLoader = await import('@hms.security.dsmm');
      let ret: number = 0;// dsmmLoader.default.setDeveloperMode(`{ "version": 1, "enable": ${enable} }`);
      if (ret != 0) {
        LogUtil.showInfo(TAG, `setDeveloperMode error, ret = ${ret}`);
        return ret;
      }
      LogUtil.showInfo(TAG, `setDeveloperMode success`);
      return ret;
    } catch (err) {
      LogUtil.showError(TAG, `setDevelopMode error, ${err?.message}`);
      return -1;
    }
  }

  static async setDevelopModeNew(enable: number, authToken: string): Promise<number> {
    try {
      // let dsmmLoader = await import('@hms.security.dsmm');
      let type: string = 'authToken';
      let config: DevModeConfig = { version: 2, enable: enable, type: type, authToken: authToken};
      LogUtil.showInfo(TAG, `setDeveloperMode error, ret = ${config}, json = ${JSON.stringify(config)}`);
      let ret: number = 0; //dsmmLoader.default.setDeveloperMode(JSON.stringify(config));
      // dsmmLoader.default.closeSession();
      if (ret != 0) {
        LogUtil.showInfo(TAG, `setDeveloperMode error, ret = ${ret}`);
        return ret;
      }
      LogUtil.showInfo(TAG, `setDeveloperMode success, version 2`);
      return ret;
    } catch (err) {
      LogUtil.showError(TAG, `setDevelopMode error, ${err?.message}`);
      return -1;
    }
  }

  /**
   * 查询设备是否支持指纹
   *
   * @returns true or false
   */
  static async isSupportFingerPrint(): Promise<boolean> {
    try {
      const property = await SecurityUtil.getProperty();
      if (property?.result === osAccount.ResultCode.SUCCESS) {
        LogUtil.info(`${TAG} support fingerprint.`);
        if (property.sensorInfo) {
          const dict: Record<string, Object> = JSON.parse(property.sensorInfo);
          LogUtil.info(`${TAG} sensorInfo: ${dict[FINGERPRINT_SENSOR_TYPE]}`);
          AppStorage.setOrCreate(FINGERPRINT_SENSOR_TYPE, dict[FINGERPRINT_SENSOR_TYPE]);
          return dict[FINGERPRINT_SENSOR_TYPE] === OUT_OF_SCREEN_SENSOR;
        } else {
          LogUtil.error(`${TAG} miss sensor info.`);
          return false;
        }
      } else {
        LogUtil.error(`${TAG} get property failed.`);
        return false;
      }
    } catch (e) {
      LogUtil.error(`${TAG} get property exception. code: ${e?.code} message: ${e?.message}`);
      return false;
    }
  }

  static async getProperty() : Promise<osAccount.ExecutorProperty | null> {
    try {
      const userAuthManager: osAccount.UserAuth = new osAccount.UserAuth();
      const request: osAccount.GetPropertyRequest = {
        authType: FINGERPRINT_CRED_TYPE,
        keys: FINGERPRINT_CRED_KEY,
      }
      return userAuthManager.getProperty(request);
    } catch (e) {
      LogUtil.error(`${TAG} getProperty has exception`);
      return null;
    }
  }
}
