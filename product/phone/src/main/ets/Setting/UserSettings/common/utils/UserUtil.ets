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
import osAccount from '@ohos.account.osAccount';
import { BusinessError } from '@ohos.base';
import configPolicy from '@ohos.configPolicy';
import fs from '@ohos.file.fs';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { OS_ACCOUNT_CONFIG_PATH } from '../constants/UserConstraints';

export interface IAuthResultData {
  result: number;
  extraInfo?: osAccount.AuthResult;
}

const tag: string = 'UserUtil:';
const accountManager: osAccount.AccountManager = osAccount.getAccountManager() as osAccount.AccountManager;

/**
 * 调用帐户子系统创建本地帐户接口返回错误码
 */
export const enum CreateLocalUserCallback {
  SYSTEM_EXCEPTION = 12300001,
  INVALID_TYPE = 12300002,
  LOCAL_NAME_EXIST = 12300004,
  UNSUPPORTED_ACCOUNT_TYPE = 12300006,
  TOKEN_INVALID_TOKEN = 12300101,
}

interface IOsAccountConfig {
  /**
   * 最大系统账号数，为正整数
   */
  'maxOsAccountNum': number;

  /**
   * 最大可登录系统账号数，为正整数，小于等于maxOsAccountNum
   */
  'maxLoggedInOsAccount': number;

  /**
   * 是否强制设置锁屏密码，默认为false
   */
  'PINEnforced': boolean;
}

export class UserUtil {
  /**
   * 获取当前用户id
   * @returns 当前用户id
   */
  static async getCurrentUserId(): Promise<number | undefined> {
    LogUtil.info(`${tag} getCurrentUserId invoked`);
    let accountId: number | undefined = undefined;
    try {
      let osAccountManager = osAccount.getAccountManager();
      const accountIds: number[] = await osAccountManager.getActivatedOsAccountLocalIds();
      if (accountIds.length > 0) {
        // 首个id既为当前用户id
        accountId = accountIds[0];
      }
    } catch (error) {
      LogUtil.error(`${tag} getActivatedOsAccountLocalIds failed`);
    }
    return accountId;
  }

  /**
   * 获取是否强制设置锁屏密码
   * @returns 是否强制设置锁屏密码，默认为false
   */
  static getPINEnforced(): boolean {
    try {
      const osAccountConfigPath = configPolicy.getOneCfgFileSync(OS_ACCOUNT_CONFIG_PATH);
      const osAccountConfig = JSON.parse(fs.readTextSync(osAccountConfigPath)) as IOsAccountConfig;
      const pinEnforced: boolean = osAccountConfig.PINEnforced;
      LogUtil.info(`${tag} succeed to read os_account_config.json. PINEnforced: ${pinEnforced}`);
      return pinEnforced;
    } catch (err) {
      const error: BusinessError = err;
      LogUtil.error(`${tag} failed to read os_account_config.json. Code ${error.code}: ${error.message}`);
      return false;
    }
  }
}