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

import connection from '@ohos.bluetooth.connection';
import pbap from '@ohos.bluetooth.pbap';
import map from '@ohos.bluetooth.map';
import { BusinessError } from '@ohos.base';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { BluetoothAdapter } from '../BluetoothAdapter';
import { AccessAuthorization, ShareType } from '../constants/BluetoothConstants';
import { BondState } from '../model/BluetoothModel';

/* instrument ignore file */
const TAG: string = 'Utils : ';

export class Utils {
  public static setPhoneBookAccessAuthorization(profile: pbap.PbapServerProfile | null, deviceId: string,
    authorization: AccessAuthorization): void {
    if (CheckEmptyUtils.checkStrIsEmpty(deviceId) || !profile) {
      LogUtil.error(`${TAG} setPhoneBookAccessAuthorization faill, parameter is invalid`);
      return;
    }

    try {
      LogUtil.info(`${TAG} accessAuthorization, deviceId: ${BluetoothUtils.getLogMAC(deviceId)}, authorization: ${authorization}`);
      profile?.setPhoneBookAccessAuthorization(deviceId, authorization, () => {
        LogUtil.info(`${TAG} setPhoneBookAccessAuthorization success`);
      });
    } catch (err) {
      LogUtil.error(`${TAG} setPhoneBookAccessAuthorization fail, code: ${err?.code} ,message: ${err?.message}`);
    }
  }

  public static setShareType(profile: pbap.PbapServerProfile | null, deviceId: string, shareType: ShareType): void {
    LogUtil.info(`${TAG} setShareType deviceId: ${BluetoothUtils.getLogMAC(deviceId)}, shareType: ${shareType}`);
    if (CheckEmptyUtils.checkStrIsEmpty(deviceId) || !profile) {
      LogUtil.error(`${TAG} setShareType faill, parameter is invalid`);
      return;
    }

    try {
      profile?.setShareType(deviceId, shareType, () => {
        LogUtil.info(`${TAG} setShareType success`);
      });
    } catch (err) {
      LogUtil.error(`${TAG} setShareType fail, code: ${err?.code} ,message: ${err?.message}`);
    }
  }

  public static setMessageAccessAuthorization(mapProfile: map.MapMseProfile, deviceId: string,
    authorization: AccessAuthorization): void {
    LogUtil.info(`${TAG} setMessageAccessAuthorization deviceId: ${BluetoothUtils.getLogMAC(deviceId)}, authorization: ${authorization}`);
    if (CheckEmptyUtils.checkStrIsEmpty(deviceId) || !mapProfile) {
      LogUtil.error(`${TAG} setMessageAccessAuthorization faill, parameter is invalid`);
      return;
    }

    try {
      mapProfile?.setMessageAccessAuthorization(deviceId, authorization).then(() => {
        LogUtil.info(`${TAG} setMessageAccessAuthorization success`);
      });
    } catch (err) {
      LogUtil.error(`${TAG} setMessageAccessAuthorization error. code: ${err?.code} ,message: ${err?.message}`);
    }
  }

  public static async getRemoteDeviceType(deviceId: string): Promise<number> {
    if (CheckEmptyUtils.checkStrIsEmpty(deviceId)) {
      return -1;
    }

    return new Promise((resolve, reject) => {
      connection.getRemoteDeviceType(deviceId).then((deviceType: connection.DeviceType) => {
        LogUtil.info(`${TAG} current device type is : ${deviceType}`);
        resolve(deviceType as number);
      }).catch((error: BusinessError) => {
        LogUtil.error(`${TAG} getRemoteDeviceType faild : ${error?.message}`);
        reject(error?.message);
      });
    });
  }

  public static async getPhoneBookAccessAuthorization(deviceId: string): Promise<AccessAuthorization> {
    if (CheckEmptyUtils.checkStrIsEmpty(deviceId)) {
      return -1;
    }

    return new Promise((resolve, reject) => {
      BluetoothAdapter.getInstance().profileManager.pbapProfile?.getPhoneBookAccessAuthorization(deviceId)
        .then((permission: AccessAuthorization) => {
        LogUtil.info(`${TAG} getPhoneBookAccessAuthorization: ${permission}`);
        resolve(permission);
      }).catch((error: BusinessError) => {
        LogUtil.error(`${TAG} getPhoneBookAccessAuthorization faild : ${error?.message}`);
        resolve(AccessAuthorization.UNKNOWN);
      });
    });
  }

  public static async getShareType(deviceId: string): Promise<ShareType> {
    if (CheckEmptyUtils.checkStrIsEmpty(deviceId)) {
      return -1;
    }

    return new Promise((resolve, reject) => {
      BluetoothAdapter.getInstance().profileManager.pbapProfile?.getShareType(deviceId).then((shareType: ShareType) => {
        LogUtil.info(`${TAG} getShareType: ${shareType}`);
        resolve(shareType);
      }).catch((error: BusinessError) => {
        LogUtil.error(`${TAG} getShareType faild : ${error?.message}`);
        resolve(ShareType.SHARE_NAME_AND_PHONE_NUMBER);
      });
    });
  }

  public static getShareTypeResourceStr(shareType: ShareType): ResourceStr {
    LogUtil.info(`${TAG} getShareTypeResourceStr: ${shareType}`);
    let shareTypeResourceStr: ResourceStr = '';
    switch (shareType) {
      case ShareType.SHARE_NAME_AND_PHONE_NUMBER:
        shareTypeResourceStr = $r('app.string.bluetooth_name_and_numbers_only');
        break;
      case ShareType.SHARE_ALL:
        shareTypeResourceStr = $r('app.string.bluetooth_fulls_detals');
        break;
      case ShareType.SHARE_NOTHING:
        shareTypeResourceStr = $r('app.string.bluetooth_not_share');
        break;
      default:
        shareTypeResourceStr = '';
      break;
    }
    return shareTypeResourceStr;
  }

  public static getPairState(deviceId: string): BondState {
    if (CheckEmptyUtils.checkStrIsEmpty(deviceId)) {
      return BondState.BOND_STATE_INVALID;
    }

    try {
      return connection.getPairState(deviceId);
    } catch (e) {
      LogUtil.error(`${TAG} getPairState fail, errCode: ${e?.code}, errMessage: ${e?.message}`);
    }
    return BondState.BOND_STATE_INVALID;
  }

  public static setBluetoothScanMode(mode: connection.ScanMode): void {
    LogUtil.info(`${TAG} setBluetoothScanMode mode: ${mode}`);
    try {
      connection.setBluetoothScanMode(mode, 0);
    } catch (err) {
      LogUtil.error(`${TAG} connection setBluetoothScanMode err code: ${err?.code} msg: ${err?.message}`);
    }
  }
}