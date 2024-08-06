/**
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { certificateManager } from '@kit.DeviceCertificateKit';
import { BusinessError } from '@kit.BasicServicesKit';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';

const MODULE_TAG: string = 'setting_vpn:VpnCertMgrModel:';

/**
 * support vpn certification
 */
export class VpnCertMgrModel {
  async getCAList(callback: Function): Promise<void> {
    LogUtil.info(MODULE_TAG + 'getCAList start');
    try {
      let result = await certificateManager.getAllUserTrustedCertificates();
      let certList: VpnCertItem[] = [];
      if (result?.certList !== undefined) {
        LogUtil.info(MODULE_TAG + 'getCAList end size=' + result.certList.length);
        for (let i = 0; i < result.certList.length; i++) {
          if (String(result.certList[i].uri).indexOf('u=0;') === -1) {
            certList.push(new VpnCertItem(
              String(result.certList[i].certAlias), String(result.certList[i].uri)));
          }
        }
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, certList);
      } else {
        LogUtil.error(MODULE_TAG + 'getCAList failed, undefined');
        callback(CMModelErrorCode.CM_MODEL_ERROR_FAILED, undefined);
      }
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      LogUtil.error(MODULE_TAG + 'getCAList err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
    }
  }

  async getUserCertList(callback: Function): Promise<void> {
    LogUtil.info(MODULE_TAG + 'getUserCertList start');
    try {
      let result = await certificateManager.getAllSystemAppCertificates();
      let certList: VpnCertItem[] = [];
      if (result?.credentialList !== undefined) {
        LogUtil.info(MODULE_TAG + 'getUserCertList size=' + result.credentialList.length);
        for (let i = 0; i < result.credentialList.length; i++) {
          certList.push(new VpnCertItem(
            String(result.credentialList[i].alias), String(result.credentialList[i].keyUri)));
        }
        callback(CMModelErrorCode.CM_MODEL_ERROR_SUCCESS, certList);
      } else {
        LogUtil.error(MODULE_TAG + 'getUserCertList failed, undefined.');
        callback(CMModelErrorCode.CM_MODEL_ERROR_FAILED, undefined);
      }
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      LogUtil.error(MODULE_TAG + 'getUserCertList failed with err, message: ' + e.message + ', code: ' + e.code);
      callback(CMModelErrorCode.CM_MODEL_ERROR_EXCEPTION);
    }
  }
}

export class VpnCertItem {
  certAlias: string;
  certUri: string;

  constructor(alias: string, uri: string) {
    this.certAlias = alias;
    this.certUri = uri;
  }
}

enum CMModelErrorCode {
  CM_MODEL_ERROR_SUCCESS = 0,
  CM_MODEL_ERROR_FAILED = -1,
  CM_MODEL_ERROR_EXCEPTION = -2,
  CM_MODEL_ERROR_UNKNOWN_OPT = -3,
  CM_MODEL_ERROR_NOT_SUPPORT = -4,
  CM_MODEL_ERROR_NOT_FOUND = -5,
  CM_MODEL_ERROR_INCORRECT_FORMAT = -6,
  CM_MODEL_ERROR_MAX_QUANTITY_REACHED = -7,
  CM_MODEL_ERROR_ALIAS_LENGTH_REACHED_LIMIT = -8
}