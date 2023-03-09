// @ts-nocheck
/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';

export const MAX_LENGTH: number = 30;
export const MAX_ACCOUNT: number = 5;

export class SystemAccoutModel {
  /**
   * Get current account name and do callback.
   *
   * @param callback related callback when current system account is obtained.
   */
  updateAccountName(callback: (name: string) => void) {
    LogUtil.info("Update account name.");
    osAccount.getAccountManager().queryAllCreatedOsAccounts().then(list => {
      let info = this.getCurrentAccount(list);
      LogUtil.info("Current os name: " + info.localName);
      callback(info.localName);
    });
  }

  /**
   * Get current account name from created account list.
   *
   * @param accountList created system account list.
   */
  getCurrentAccount(accountList: any[]): any {
    for (let index = 0; index < accountList.length; index++) {
      if (accountList[index].isActived) {
        return accountList[index];
      }
    }
    return {};
  }

  /**
   * Sort the account info list according to following rules:
   * 1. If this account is current user, then put it first.
   * 2. If this administrator, then place it after the current user.
   * 2. If this account is quest user, then put it last.
   * 3. If this account is normal user, place it in chronological order of creation.
   *
   * @param info1 input param 1.
   * @param info2 input param 2.
   */
  sortAccount(info1: any, info2: any): number {
    if (info1.localId == this.currentAccount.localId || info2.localId == this.currentAccount.localId) {
      LogUtil.info("Sort current account, info: " + info1.localName);
      return info1.localId == this.currentAccount.localId ? -1 : 1;
    } else if (info1.type == osAccount.OsAccountType.ADMIN || info2.type == osAccount.OsAccountType.ADMIN) {
      LogUtil.info("Sort administrator account, info: " + info1.localName);
      return info1.type == osAccount.OsAccountType.ADMIN ? -1 : 1;
    } else if ( info1.type == osAccount.OsAccountType.GUEST || info2.type == osAccount.OsAccountType.GUEST) {
      LogUtil.info("Sort quest account, info: " + info1.localName);
      return info1.type == osAccount.OsAccountType.GUEST ? 1 : -1;
    } else {
      return info2.localId - info1.localId;
    }
  }

  /**
   * Get identity from account info type.
   *
   * @param type int type, like admin, quest.
   * @return identity string of different account type.
   */
  getIdentityFromMap(accountType: any): string | Resource {
    LogUtil.info("Get identity from map, type: " + JSON.stringify(accountType));
    if (accountType == osAccount.OsAccountType.ADMIN) {
      return $r("app.string.administrator");
    } else if (accountType == osAccount.OsAccountType.NORMAL) {
      return "";
    } else if (accountType == osAccount.OsAccountType.GUEST) {
      return $r("app.string.quest");
    } else {
      LogUtil.info("Unknown system account type.")
      return "未知用户";
    }
  }
}

let systemAccountModel = new SystemAccoutModel();
export default systemAccountModel as SystemAccoutModel;
