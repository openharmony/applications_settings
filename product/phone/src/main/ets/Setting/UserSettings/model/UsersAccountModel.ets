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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

export const MAX_USER_NAME_LENGTH: number = 30;
export const MAX_ACCOUNT: number = 5;

const TAG: string = 'UsersAccountModel:';

export class UsersAccountModel {
  private currentAccount: osAccount.OsAccountInfo | undefined = undefined;

  setCurrentAccount(account: osAccount.OsAccountInfo): void {
    this.currentAccount = account;
  }

  updateAccountName(callback: (name: string) => void): void {
    LogUtil.info(`${TAG} updateAccountName`);
    osAccount.getAccountManager().queryAllCreatedOsAccounts().then((list: osAccount.OsAccountInfo[]) => {
      let info = this.getCurrentAccount(list);
      LogUtil.info(`${TAG} current os name: ${info?.localName}`);
      callback(info?.localName ?? '');
    }).catch((err: Error) => {
      LogUtil.error(`${TAG} updateAccountName failed: ${err?.message}`);
      callback('');
    });
  }

  getCurrentAccount(accountList: osAccount.OsAccountInfo[]): osAccount.OsAccountInfo | undefined {
    for (let index = 0; index < accountList.length; index++) {
      if (accountList[index].isActived) {
        return accountList[index];
      }
    }
    return undefined;
  }

  sortAccount(info1: osAccount.OsAccountInfo, info2: osAccount.OsAccountInfo): number {
    if (!this.currentAccount) {
      return info2.localId - info1.localId;
    }
    if (info1.localId === this.currentAccount.localId || info2.localId === this.currentAccount.localId) {
      return info1.localId === this.currentAccount.localId ? -1 : 1;
    }
    if (info1.type === osAccount.OsAccountType.ADMIN || info2.type === osAccount.OsAccountType.ADMIN) {
      return info1.type === osAccount.OsAccountType.ADMIN ? -1 : 1;
    }
    if (info1.type === osAccount.OsAccountType.GUEST || info2.type === osAccount.OsAccountType.GUEST) {
      return info1.type === osAccount.OsAccountType.GUEST ? 1 : -1;
    }
    return info2.localId - info1.localId;
  }

  getIdentityFromMap(accountType: osAccount.OsAccountType): string | Resource {
    if (accountType === osAccount.OsAccountType.ADMIN) {
      return $r('app.string.user_admin');
    } else if (accountType === osAccount.OsAccountType.GUEST) {
      return $r('app.string.user_guest');
    }
    return '';
  }
}

export const usersAccountModel = new UsersAccountModel();
