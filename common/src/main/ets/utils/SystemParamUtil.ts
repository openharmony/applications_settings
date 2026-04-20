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

import systemParameterEnhance from '@ohos.systemParameterEnhance';
import osAccount from '@ohos.account.osAccount';
import deviceInfo from '@ohos.deviceInfo';
import { LogUtil } from './LogUtil';

/* instrument ignore file */
const TAG: string = 'SystemParamUtil:';
const KEY_EFL_FORBIDDEN = 'const.telephony.efl_forbidden';
const PRODUCT_MODEL: string = 'const.product.model';
const PRODUCT_MODEL_EMULATOR: string = 'emulator';
const DEVICE_TYPE_TV = 'tv';

export class SystemParamUtil {

  /*
   * 判断当前是否运行在模拟器下
   */
  public static isSimulatorMode: boolean = SystemParamUtil.getParam(PRODUCT_MODEL, '') === PRODUCT_MODEL_EMULATOR;

  /*
   * 判断当前是否具备锁屏密码上云能力
   */
  public static isPwdEnableUpload: boolean =
    SystemParamUtil.getParam('const.pc_security.pwd_upload_enable', 'false') === 'true';

  /**
   * 判断当前是否为大屏
   */
  public static isDeviceTv: boolean = deviceInfo.deviceType === DEVICE_TYPE_TV;

  private constructor() {
  }

  /**
   * 判断设备是否已使能EFL
   *
   * @returns EFL使能时返回true
   */
  public static isEflForbidden(): boolean {
    return systemParameterEnhance.getSync(KEY_EFL_FORBIDDEN, 'false') === 'true';
  }

  /**
   * 判断设备是否禁用壁纸编辑
   *
   * @returns 禁用壁纸编辑时返回true
   */
  public static async isModifyWallpaperDisable(): Promise<boolean> {
    try {
      const isEnterpriseDevice: boolean =
        systemParameterEnhance.getSync('const.edm.is_enterprise_device', 'false') === 'true';
      if (!isEnterpriseDevice) {
        LogUtil.showInfo(TAG, 'not enterprise device');
        return false;
      }
      const result: boolean =
        await osAccount.getAccountManager().isOsAccountConstraintEnabled('constraint.wallpaper.set');
      LogUtil.showInfo(TAG, `set wallpaper isOsAccountConstraintEnabled: ${result}`);
      return result;
    } catch (e) {
      LogUtil.showError(TAG, `get isModifyWallpaperDisable error, code: ${e?.code} message: ${e?.message}`);
      return false;
    }
  }

  public static getParam(parameter: string, defaultValue: string): string {
    try {
      return systemParameterEnhance.getSync(parameter, defaultValue);
    } catch (err) {
      LogUtil.showError(TAG, 'getParam failed');
      return defaultValue;
    }
  }

  public static setParam(parameter: string, value: string): void {
    try {
      systemParameterEnhance.setSync(parameter, value);
    } catch (err) {
      LogUtil.showError(TAG, `setParam failed: ${err?.message}`);
    }
  }
}
