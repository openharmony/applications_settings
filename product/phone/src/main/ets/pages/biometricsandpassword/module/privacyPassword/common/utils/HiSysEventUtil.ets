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
import { hiSysEvent } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { bundleManager } from '@kit.AbilityKit';
import { HiSysEventConstants } from '../constants/HiSysEventConstants';
import Log from './Log';
import { PasswordUtils } from './PasswordUtils';

const TAG = 'HiSysEventUtil';

let versionName: string = '';

interface deleteParams {
  'PNAMEID': string,
  'PVERSIONID': string
  'USER_ID': number,
  'DELETE_STATUS': string,
  'LIST_DELETE': string,
  'MODE_DELETE': string
}

interface updateParams {
  'PNAMEID': string,
  'PVERSIONID': string,
  'USER_ID': number,
  'UPDATE_MODE': number,
  'UPDATE_TYPE': number,
  'STATUS_BEF': string,
  'STATUS_AFT': string
}

interface userOperationParams {
  'PNAMEID': string
  'PVERSIONID': string
  'OCCUR_TIME': string
  'USER_OPERA': string
  'PARAM': string
}

interface deletePwdStatus {
  'credentialId': string,
  'templateId': string,
  'pinSubType': number
}

interface updatePwdStatus {
  'credentialId': string,
  'templateId': string
}

export class HiSysEventUtil {
  private static readonly UE_DOMAIN: string = 'PRIVATE_PIN_UE';
  private static readonly PACKAGE_NAME: string = 'com.ohos.settings';
  private static TEMPLET_ID_BEFORE: string = '';
  private static TEMPLET_ID_AFTER: string = '';
  private static isUpdateByPwd: boolean = true;
  private static credentialBefore: string = '';
  private static credentialAfter: string = '';

  static updateByPwdProtect(): void {
    HiSysEventUtil.isUpdateByPwd = false;
  }

  static updateByPwd(): void {
    HiSysEventUtil.isUpdateByPwd = true;
  }

  /**
   * 设置更新前的 credential id 和 template id
   *
   * @param cred credential id
   * @param tempId template id
   * @returns
   */
  static setCredentialAndTempIdBefore(cred: Uint8Array, tempId: Uint8Array): void {
    HiSysEventUtil.credentialBefore = PasswordUtils.uint8ArrayToString(cred);
    HiSysEventUtil.TEMPLET_ID_BEFORE = PasswordUtils.uint8ArrayToString(tempId);
  }

  /**
   * 设置更新后的 credential id 和 template id
   *
   * @param cred credential id
   * @param tempId template id
   * @returns
   */
  static setCredentialAndTempIdAfter(cred: Uint8Array, tempId: Uint8Array): void {
    HiSysEventUtil.credentialAfter = PasswordUtils.uint8ArrayToString(cred);
    HiSysEventUtil.TEMPLET_ID_AFTER = PasswordUtils.uint8ArrayToString(tempId);
  }

  /**
   * 初始化versionName
   *
   * @returns
   */
  static async initData(): Promise<void> {
    Log.info(TAG, 'get versionName success');
    let bundleFlag = bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT;
    try {
      let bundleInfo = await bundleManager.getBundleInfo(HiSysEventUtil.PACKAGE_NAME, bundleFlag);
      versionName = bundleInfo.versionName;
    } catch (err) {
      Log.error(TAG, `getVersionName error, error code: ${err?.code}, message: ${err?.message}.`);
    }
  }

  /**
   * 删除事件打点
   *
   * @params deleteCred 待删除的凭据
   * @params tempId 待删除的templateId
   * @params pinSubType 待删除凭据的子类型
   * @params listDeleted 关联的业务列表
   * @params 用户对于不同业务的处理方式列表
   * @returns
   */
  static reportDeleteEvent(deleteCred: Uint8Array, tempId: Uint8Array, pinSubType: number, listDeleted: number[],
    modeDeleted: number[]): void {
    const deleteStatus: deletePwdStatus = {
      credentialId: HiSysEventUtil.maskStr(PasswordUtils.uint8ArrayToString(deleteCred)),
      templateId: HiSysEventUtil.maskStr(PasswordUtils.uint8ArrayToString(tempId)),
      pinSubType: pinSubType
    }
    let params: deleteParams = {
      'PNAMEID': HiSysEventUtil.PACKAGE_NAME,
      'PVERSIONID': versionName,
      'USER_ID': 100,
      'DELETE_STATUS': JSON.stringify(deleteStatus),
      'LIST_DELETE': listDeleted.toString(),
      'MODE_DELETE': modeDeleted.toString()
    };
    HiSysEventUtil.reportEvent(HiSysEventConstants.PRIVATE_PIN_DELETE, params);
  }

  /**
   * 更新事件打点
   *
   * @params updateType 更新类型（1为更新密码，2为更新密保）
   * @returns
   */
  static reportUpdateEvent(updateType: number): void {
    const before: updatePwdStatus = {
      'credentialId': HiSysEventUtil.maskStr(HiSysEventUtil.credentialBefore),
      'templateId': HiSysEventUtil.maskStr(HiSysEventUtil.TEMPLET_ID_BEFORE)
    }
    const after: updatePwdStatus = {
      'credentialId': HiSysEventUtil.maskStr(HiSysEventUtil.credentialAfter),
      'templateId': HiSysEventUtil.maskStr(HiSysEventUtil.TEMPLET_ID_AFTER)
    }
    let params: updateParams = {
      'PNAMEID': HiSysEventUtil.PACKAGE_NAME,
      'PVERSIONID': versionName,
      'USER_ID': 100,
      'UPDATE_MODE': HiSysEventUtil.isUpdateByPwd ? 1 : 2,
      'UPDATE_TYPE': updateType,
      'STATUS_BEF': JSON.stringify(before),
      'STATUS_AFT': JSON.stringify(after)
    };
    HiSysEventUtil.reportEvent(HiSysEventConstants.PRIVATE_PIN_UPDATE, params);
  }

  /**
   * 用户操作事件打点
   *
   * @params userOperation 用户操作
   * @params param begin/end/click/continue/cancel
   * @returns
   */
  static reportUserOperationEvent(userOperation: string, param: string): void {
    let params: userOperationParams = {
      'PNAMEID': HiSysEventUtil.PACKAGE_NAME,
      'PVERSIONID': versionName,
      'OCCUR_TIME': HiSysEventUtil.getTime(),
      'USER_OPERA': userOperation,
      'PARAM': param
    };
    HiSysEventUtil.reportEvent(HiSysEventConstants.USER_OPERATION, params);
  }

  private static reportEvent(eventName: string, params: object): void {
    hiSysEvent.write({
      domain: HiSysEventUtil.UE_DOMAIN,
      name: eventName,
      eventType: HiSysEventConstants.behaviorEventType,
      params: params
    }).then((value) => {
      Log.info(TAG, 'reportEvent: success to write event');
    }).catch((err: BusinessError) => {
      Log.error(TAG, 'reportEvent: fail to write event: ' + err.code);
    });
  }

  private static maskStr(str: string): string {
    const len = str.length;
    const subLen = len / 3;
    return str.substring(0, subLen);
  }

  private static getTime(): string {
    let date = new Date(Date.now());
    let res = `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}` +
      ` ${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}`
    return res;
  }
}