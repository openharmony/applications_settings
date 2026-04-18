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

import account_osAccount from '@ohos.account.osAccount';
import { osAccount } from '@kit.BasicServicesKit';
import { process } from '@kit.ArkTS';
import type { BusinessError } from '@ohos.base';
import distributedAccount from '@ohos.account.distributedAccount';
import { LogUtil } from './LogUtil';
import { AccountConstants } from '../constant/AccountConstants';

const TAG: string = 'AccountUtil: ';
const MAIN_USER: number = 100;

export enum DeviceNameCheckErrCode {
  ERROR_CODE_RISK_CHECK_SUCCESS = 202000,
  ERROR_CODE_NO_LOGIN_ACCOUNT = 202002,
  ERROR_CODE_NETWORK_EXCEPTION = 202005,
  ERROR_CODE_RISK_CHECK_FAIL = 202010,
  ERROR_CODE_RISK_CALL_EXCEPTION = 202011,
  ERROR_CODE_UN_SUPPORT_RISK = 202012,
  ERROR_CODE_DEVICE_NAME_TOO_LONG = 202013,
  ERROR_CODE_CP_AUTH_FAIL = 202910
}

export const CHECK_SUCCESS_CODE: Set<number> = new Set([
  DeviceNameCheckErrCode.ERROR_CODE_RISK_CHECK_SUCCESS,
  DeviceNameCheckErrCode.ERROR_CODE_UN_SUPPORT_RISK
]);

export const CHECK_FAIL_CODE: Set<number> = new Set([
  DeviceNameCheckErrCode.ERROR_CODE_RISK_CHECK_FAIL,
  DeviceNameCheckErrCode.ERROR_CODE_DEVICE_NAME_TOO_LONG
]);

export const CALL_EXCEPTION_CODE: Set<number> = new Set([
  DeviceNameCheckErrCode.ERROR_CODE_NO_LOGIN_ACCOUNT,
  DeviceNameCheckErrCode.ERROR_CODE_NETWORK_EXCEPTION,
  DeviceNameCheckErrCode.ERROR_CODE_RISK_CALL_EXCEPTION,
  DeviceNameCheckErrCode.ERROR_CODE_CP_AUTH_FAIL,
]);

/**
 * AccountUtils
 *
 * @since 2024-04-22
 */
export class AccountUtil {
  public static connectId: number = -1;

  private static isPrivateUser: boolean | undefined = undefined;

  /**
   * 判断用户是否为主用户身份
   *
   * @returns true:当前用户为主用户；false:当前用户为非主用户
   */
  public static isMainUser(): boolean {
    let accountMgr = osAccount.getAccountManager();
    try {
      return accountMgr.getOsAccountLocalIdForUidSync(process.uid) === MAIN_USER;
    } catch (e) {
      LogUtil.error(`${TAG} getOsAccountLocalIdForUidSync error: ${e?.code}`);
    }
    return false;
  }

  /**
   * 判断是否存在隐私用户
   */
  public static async hasPrivateUser(): Promise<boolean> {
    let userId: number = await AccountUtil.getPrivateSpaceUserId();
    return userId !== AccountConstants.INVALID_PRIVATE_SPACE_USER_ID;
  }

  /**
   * 获取isPrivateUser
   *
   * @returns true,是隐私用户；false，不是隐私用户
   */
  public static getIsPrivateUser(): boolean {
    if (AccountUtil.isPrivateUser !== undefined) {
      LogUtil.info(`${TAG} isPrivateUser ${AccountUtil.isPrivateUser}`);
      return AccountUtil.isPrivateUser;
    }
    return false;
  }

  /**
   * 获取隐私用户id
   */
  public static async getPrivateSpaceUserId(): Promise<number> {
    let accountManager = account_osAccount.getAccountManager();
    try {
      let accountArray: account_osAccount.OsAccountInfo[] = await accountManager.queryAllCreatedOsAccounts();
      if (!accountArray || accountArray.length <= 0) {
        LogUtil.warn(`${TAG} getPrivateSpaceUserId account array empty`);
        return AccountConstants.INVALID_PRIVATE_SPACE_USER_ID;
      }
      for (let account of accountArray) {
        if (account.type === account_osAccount.OsAccountType.PRIVATE && account.isCreateCompleted) {
          LogUtil.info(`${TAG} getPrivateSpaceUserId yes`);
          return account.localId;
        }
      }
    } catch (e) {
      LogUtil.error(`${TAG} getPrivateSpaceUserId error: ${(e as BusinessError).code}`);
    }
    return AccountConstants.INVALID_PRIVATE_SPACE_USER_ID;
  }

  /**
   * 判断当前用户是否是隐私用户
   */
  public static async isCurrentPrivate(): Promise<boolean> {
    let accountManager = account_osAccount.getAccountManager();
    try {
      let currentAccount = await accountManager.queryOsAccount();
      return currentAccount.type === account_osAccount.OsAccountType.PRIVATE;
    } catch (e) {
      LogUtil.error(`${TAG} queryOsAccount error ${(e as BusinessError).code}`);
      return false;
    }
  }

  /**
   * 从缓存获取当前用户是否是隐私用户
   *
   * @returns true,是隐私用户；false，不是隐私用户
   */
  public static async isCurrentPrivateFromCache(): Promise<boolean> {
    if (AccountUtil.isPrivateUser !== undefined) {
      LogUtil.info(`${TAG} isPrivateUser ${AccountUtil.isPrivateUser} from cache`);
      return AccountUtil.isPrivateUser;
    }
    AccountUtil.isPrivateUser = await this.isCurrentPrivate();
    LogUtil.info(`${TAG} isPrivateUser ${AccountUtil.isPrivateUser} from system`);
    return AccountUtil.isPrivateUser;
  }

  /**
   * 判断当前用户是否是管理员用户（主用户）
   */
  public static async isCurrentAdmin(): Promise<boolean> {
    let accountManager = account_osAccount.getAccountManager();
    try {
      let currentAccount = await accountManager.queryOsAccount();
      return currentAccount.type === account_osAccount.OsAccountType.ADMIN;
    } catch (e) {
      LogUtil.error(`${TAG} queryOsAccount error ${(e as BusinessError).code}`);
      return false;
    }
  }

  /**
   * 获取当前用户ID
   */
  public static async getCurrentUserId(): Promise<number> {
    let accountManager = account_osAccount.getAccountManager();
    try {
      let currentAccount = await accountManager.queryOsAccount();
      return currentAccount.localId;
    } catch (e) {
      LogUtil.error(`${TAG} queryOsAccount error ${(e as BusinessError).code}`);
      return -1;
    }
  }

  /**
   * 获取主用户id
   */
  public static async getMainSpaceUserId(): Promise<number> {
    let accountManager = account_osAccount.getAccountManager();
    /* instrument ignore next */
    try {
      let accountArray: account_osAccount.OsAccountInfo[] = await accountManager.queryAllCreatedOsAccounts();
      if (!accountArray || accountArray.length <= 0) {
        LogUtil.warn(`${TAG} getMainSpaceUserId account array empty`);
        return AccountConstants.INVALID_USER_ID;
      }
      for (let account of accountArray) {
        if (account.type !== account_osAccount.OsAccountType.PRIVATE) {
          LogUtil.info(`${TAG} getMainSpaceUserId yes`);
          return account.localId;
        }
      }
    } catch (e) {
      LogUtil.error(`${TAG} getMainSpaceUserId error: ${(e as BusinessError).code}`);
    }
    return AccountConstants.INVALID_USER_ID;
  }

  /* instrument ignore next */
  public static async isAccountLogged(): Promise<boolean> {
    let info: distributedAccount.DistributedInfo | void =
      await distributedAccount.getDistributedAccountAbility()?.getOsAccountDistributedInfo();
    if (info && info?.nickname) {
      LogUtil.info(`${TAG} isAccountLogged`);
      return true;
    }
    return false;
  }

  /**
   * 获取所有用户ID
   */
  public static async getAllSpaceUserIds(): Promise<number[]> {
    let userIds: number[] = [];
    const accountManager = account_osAccount.getAccountManager();
    /* instrument ignore next */
    try {
      let accountArray: account_osAccount.OsAccountInfo[] = await accountManager.queryAllCreatedOsAccounts();
      if (!accountArray || accountArray.length <= 0) {
        LogUtil.warn(`${TAG} getMainSpaceUserId account array empty`);
        return [];
      }
      for (let accountArrayElement of accountArray) {
        userIds.push(accountArrayElement.localId);
      }
      return userIds;
    } catch (e) {
      LogUtil.error(`${TAG} getAllSpaceUserIds error: ${(e as BusinessError).code}`);
    }
    return userIds;
  }
}