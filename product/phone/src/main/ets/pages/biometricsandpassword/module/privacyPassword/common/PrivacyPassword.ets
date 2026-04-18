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

import osAccount from '@ohos.account.osAccount';
// import appLock from '@hms.security.appLock';
import Log from './utils/Log';
import { SearchDataController } from '@ohos/settings.search';
import { SearchCheckUtil } from '@ohos/settings.search/src/main/ets/util/SearchCheckUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';

/* instrument ignore file */
const TAG: string = 'PrivacyPassword';

export interface CredAndTemplate {
  credentialId: Uint8Array,
  templateId: Uint8Array
}

const curentSupportPwdTypes: Set<osAccount.AuthSubType> = new Set([
  osAccount.AuthSubType.PIN_SIX,
  osAccount.AuthSubType.PIN_NUMBER,
  osAccount.AuthSubType.PIN_MIXED
]);

export async function getCredentials(): Promise<Array<osAccount.EnrolledCredInfo>> {
  try {
    let credentials = await new osAccount.UserIdentityManager().getAuthInfo(osAccount.AuthType.PRIVATE_PIN);
    return credentials;
  } catch (err) {
    Log.error(TAG, 'privacy getCredentials failed')
  }
  return [];
}

export async function isPinType(): Promise<boolean> {
  const credentials = await getCredentials();
  return credentials.some(p => p.authSubType === osAccount.AuthSubType.PIN_SIX);
}

export async function currentPwdType(): Promise<osAccount.AuthSubType> {
  const credentials = await getCredentials();
  const types = credentials
    .filter(p => p.authType === osAccount.AuthType.PRIVATE_PIN && curentSupportPwdTypes.has(p.authSubType))
    .map(p => p.authSubType);
  if (types.length > 0) {
    return types[0]
  }
  return osAccount.AuthSubType.PIN_SIX;
}

export async function getCurrentTokenAndCredId(): Promise<CredAndTemplate> {
  const credentials = await getCredentials();
  let credId: Uint8Array = new Uint8Array();
  let tempId: Uint8Array = new Uint8Array();
  for (const cred of credentials) {
    if (cred.authType === osAccount.AuthType.PRIVATE_PIN && curentSupportPwdTypes.has(cred.authSubType)) {
      credId = cred.credentialId;
      tempId = cred.templateId;
      break;
    }
  }
  let res: CredAndTemplate = {
    credentialId: credId,
    templateId: tempId
  };
  return res;
}

export async function hasLockerApp(): Promise<boolean> {
  // try {
  //   let res: boolean = await appLock.isAuthTypeAllowed(appLock.AuthType.PRIVACY_PIN);
  //   if (!res) {
  //     Log.error(TAG, `private pin auth type is not allowed`);
  //   } else {
  //     Log.info(TAG, `private pin auth type is allowed`);
  //   }
  //   return res;
  // } catch (error) {
  //   Log.error(TAG, `get allow status from appLock failed, errorCode: ${error?.code}, error message: ${error?.message}`);
  //   return false;
  // }
  return false;
}

export async function usePinProtection(): Promise<boolean> {
  // try {
  //   await appLock.setAllowedAuthType(appLock.AuthType.PIN, true);
  //   return true;
  // } catch (error) {
  //   Log.error(TAG, `setAllowedAuthType to pin Failed`);
  //   return false;
  // }
  return false;
}

export async function setUnableToAppLock(): Promise<void> {
  // try {
  //   await appLock.setEnabled(false);
  // } catch (error) {
  //   Log.error(TAG, `set enable to appLock failed`);
  // }
}

export async function changePrivacySearchItem() {
  try {
    const cde = await getCredentials();
    // 更新锁屏密码的搜索使能项
    const hasPin = await SearchCheckUtil.hasSetPinPassword();
    await Promise.all([
      SearchDataController.getInstance().updateChildItemSearchStatus('lock_screen_password', hasPin),
      SearchDataController.getInstance().updateSearchItemStatus('lock_screen_password', !hasPin)
    ]);
    // 指纹、人脸搜索项使能
    SearchCheckUtil.isFingerPrintSupport().then(supportFinger => {
      SearchDataController.getInstance().updateSearchItemStatus('fingerprint_settings_title', supportFinger);
    });
    SearchCheckUtil.isFaceAuthSupport().then(supportFace => {
      SearchDataController.getInstance().updateSearchItemStatus('face_checker', supportFace);
    });
    if (cde.length > 0) {
      await Promise.all([
        SearchDataController.getInstance().updateSearchItemStatus('privacy_password', false),
        SearchDataController.getInstance().updateSearchItemStatus('close_privacy_password', true),
        SearchDataController.getInstance().updateSearchItemStatus('change_security_question', true),
        SearchDataController.getInstance().updateSearchItemStatus('PRIVACY_PASSWORD_CHANGE_ENTRY', true)
      ])
    } else {
      await Promise.all([
        SearchDataController.getInstance().updateSearchItemStatus('privacy_password', true),
        SearchDataController.getInstance().updateSearchItemStatus('close_privacy_password', false),
        SearchDataController.getInstance().updateSearchItemStatus('change_security_question', false),
        SearchDataController.getInstance().updateSearchItemStatus('PRIVACY_PASSWORD_CHANGE_ENTRY', false)
      ])
    }
  } catch (e) {
    Log.error(TAG, `change privacy search item failed`);
  }
}
