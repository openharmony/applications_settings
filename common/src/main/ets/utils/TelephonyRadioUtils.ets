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

import radio from '@ohos.telephony.radio';
import { LogUtil } from './LogUtil';

const TAG = 'TelephonyRadioUtils: ';
export const DEFAULT_IMEI: string = '000000000000000';
export const DEFAULT_BASEBAND_VERSION: string = '00000000000000000';

export class TelephonyRadioUtils {
  public static async getImeiData(slotId: number): Promise<string> {
    try {
      let imei: string = await radio.getIMEI(slotId);
      LogUtil.showInfo(TAG, 'getIMEI info success');
      return imei;
    } catch (error) {
      LogUtil.showInfo(TAG, `getIMEI error: ${error?.message} code: ${error?.code}`);
    }
    return DEFAULT_IMEI;
  }

  static async getBaseBandVersion(slotId: number) {
    try {
      let basebandVersion: string = await radio.getBasebandVersion(slotId);
      LogUtil.showInfo(TAG, 'getBasebandVersion info success');
      return basebandVersion;
    } catch (error) {
      LogUtil.showInfo(TAG, `getBasebandVersion error: ${error?.message} code: ${error?.code}`);
    }
    return DEFAULT_BASEBAND_VERSION;
  }

  static async getSignalInformation(slotId: number): Promise<radio.SignalInformation[]> {
    let signalInformation: radio.SignalInformation[] = [];
    try {
      signalInformation = await radio.getSignalInformation(slotId);
      LogUtil.showInfo(TAG, 'getSignalInformation success');
    } catch (error) {
      LogUtil.showInfo(TAG, `getSignalInformation error: ${error?.message} code: ${error?.code}`);
    }
    return signalInformation;
  }

  static async getCellInformation(slotId: number): Promise<radio.CellInformation[]> {
    let cellInfo: radio.CellInformation[] = [];
    try {
      cellInfo = await radio.getCellInformation(slotId);
      LogUtil.showInfo(TAG, 'getCellInformation success');
    } catch (error) {
      LogUtil.showInfo(TAG, `getCellInformation error: ${error?.message} code: ${error?.code}`);
    }
    return cellInfo;
  }

  static async getNetworkState(slotId: number): Promise<radio.NetworkState | undefined> {
    let networkState: radio.NetworkState | undefined;
    try {
      networkState = await radio.getNetworkState(slotId);
      LogUtil.showInfo(TAG, 'getNetworkState success');
    } catch (error) {
      LogUtil.showInfo(TAG, `getNetworkState error: ${error?.message} code: ${error?.code}`);
    }
    return networkState;
  }

  /**
   * 网络是否注册服务
   *
   * @param slotId 卡槽id
   * @param networkState 网络状态
   *
   * @returns true:注册服务成功， false:未注册成功
   */
  public static async isRegStateInService(slotId: number,
    networkState?: radio.NetworkState): Promise<boolean> {
    if (!networkState) {
      networkState = await TelephonyRadioUtils.getNetworkState(slotId);
    }
    return !!networkState && networkState.regState === radio.RegState.REG_STATE_IN_SERVICE;
  }

  static async getOperatorName(slotId: number): Promise<string> {
    let operatorName: string = '';
    try {
      operatorName = await radio.getOperatorNameSync(slotId);
      LogUtil.showInfo(TAG, 'getOperatorName success');
    } catch (error) {
      LogUtil.showInfo(TAG, `getOperatorName error: ${error?.message} code: ${error?.code}`);
    }
    return operatorName;
  }
}
