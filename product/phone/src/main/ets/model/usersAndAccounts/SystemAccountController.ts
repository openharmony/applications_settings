// @ts-nocheck
/**
 * Copyright (c) 2021-2022 Huawei Device Co., Ltd.
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
import featureAbility from '@ohos.ability.featureAbility';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import GlobalResourceManager from '../../../../../../../common/utils/src/main/ets/default/baseUtil/GlobalResourceManager';
import { MAX_ACCOUNT} from './systemAccountModel'
import SystemAccountModel from './systemAccountModel'

export class SystemAccountController {
  private currentAccount: osAccount.OsAccountInfo;
  private accountList: osAccount.OsAccountInfo[] = [];
  private static instance: SystemAccountController;

  public static getInstance(): SystemAccountController {
    if (!SystemAccountController.instance) {
      SystemAccountController.instance = new SystemAccountController();
    }
    return SystemAccountController.instance;
  }

  constructor() {
  }

  /**
   * Get all created system account name.
   */
  async refreshSystemAccountList() {
    LogUtil.info("Refresh system account list.");
    AppStorage.SetOrCreate("systemAccountList", []);
    this.accountList = await osAccount.getAccountManager().queryAllCreatedOsAccounts();
    LogUtil.info("before sort account list, length: " + this.accountList.length + ", list: " + JSON.stringify(this.accountList));
    this.currentAccount = SystemAccountModel.getCurrentAccount(this.accountList);
    LogUtil.info("Current account localId: " + this.currentAccount.localId);
    this.accountList.sort(SystemAccountModel.sortAccount.bind(this));
    LogUtil.info("Successfully sort account list, length: " + this.accountList.length);
    AppStorage.SetOrCreate("systemAccountList", this.accountList);
    AppStorage.SetOrCreate("isShowAddUser", this.isShowAddUser());
    AppStorage.SetOrCreate("isShowAddGuest", this.isShowAddQuest());
    AppStorage.SetOrCreate("isShowDelete",!this.isCurrentAdministrator());
  }

  /**
   * Whether to show system account type.
   *
   * @return true if current account is administrator.
   */
  isShowIdentity(accountInfo) {
    return accountInfo.type == osAccount.OsAccountType.ADMIN;
  }

  /**
   * Whether account list has quest
   *
   * @return boolean.true if account list has quest,false if account list doesn't have quest
   */
  isHasQuest() {
    for (let index = 0; index < this.accountList.length; index++) {
      LogUtil.info("Is show add quest, system account type: " + this.accountList[index].type);
      if (this.accountList[index].type == osAccount.OsAccountType.GUEST) {
        return true;
      }
    }
    return false;
  }

  /**
   * Whether to show add normal user item.
   *
   * @return true if current user is administrator.
   */
  isShowAddUser() {
    return this.currentAccount.type == osAccount.OsAccountType.ADMIN && this.accountList.length < (this.isHasQuest() ? MAX_ACCOUNT : (MAX_ACCOUNT - 1));
  }

  /**
   * Whether to show add create normal account list item.
   *
   * @return true when created account list no contains quest account.
   */
  isShowAddQuest() {
    return this.currentAccount.type == osAccount.OsAccountType.ADMIN && !this.isHasQuest() && this.accountList.length < MAX_ACCOUNT;
  }

  /**
   * Whether is current system account.
   *
   * @return true when clicked item is system account.
   */
  isCurrentUser(accountInfo: any) {
    LogUtil.info("Is current user, account id: " + accountInfo.localId);
    return accountInfo.localId == this.currentAccount.localId;
  }

  /**
   * Whether current account is administrator type.
   *
   * @return true when current account type is administrator.
   */
  isCurrentAdministrator() {
    LogUtil.info("Is current user administrator.")
    return this.currentAccount.type == osAccount.OsAccountType.ADMIN;
  }

  /**
   * Whether current account is quest type.
   *
   * @return true when current account type is quest.
   */
  isCurrentQuest() {
    return this.currentAccount.type == osAccount.OsAccountType.GUEST;
  }

  /**
   * Whether the account is quest.
   *
   * @param account input system account.
   */
  isGuestAccount(account: any) {
    return account.type == osAccount.OsAccountType.GUEST;
  }

  /**
   * Get new created account.
   *
   * @return the local id of newly created system account.
   */
  switchToCreatedAccount(): number {
    this.accountList.sort((account1, account2) => {
      return account2.serialNumber - account1.serialNumber;
    });
    let newlyId = this.accountList[0].localId;
    LogUtil.info("Newly created local id: " + newlyId);
    this.switchUser(newlyId);
  }

  /**
   * Create the quest system account.
   */
  async createQuest(callback: (account: any) => void) {
    LogUtil.info("Create quest account.");
    let localName = GlobalResourceManager.getStringByResource($r("app.string.quest"));
    localName.then(name => {
      osAccount.getAccountManager().createOsAccount(name, osAccount.OsAccountType.GUEST).then((accountInfo) => {
        LogUtil.info("Create quest system account.");
        this.refreshSystemAccountList();
        callback(accountInfo);
      });
    })
  }

  /**
   * Create the normal system account.
   *
   * @param localName create name of normal system account.
   */
  async createSystemAccount(localName: string, callback?: (account: any) => void) {
    LogUtil.info("Create system account.");
    osAccount.getAccountManager().createOsAccount(localName, osAccount.OsAccountType.NORMAL).then(accountInfo => {
      this.refreshSystemAccountList();
      callback(accountInfo);
    });
  }

  /**
   * To check whether the user name is used.
   *
   * @param inputName name of input.
   * @return true if created system accounts include the input name.
   */
  isAlreadyCreated(inputName: string): boolean {
    for (let index = 0; index < this.accountList.length; index++) {
      if (this.accountList[index].localName === inputName) {
        return true;
      }
    }
    return false;
  }

  /**
   * To set the system account name.
   *
   * @param localId local id of system account.
   * @param name name of system account.
   */
  async setAccountName(localId: number, name: string) {
    LogUtil.info("Set system account name.");
    osAccount.getAccountManager().setOsAccountName(localId, name).then(() => {
      this.refreshSystemAccountList();
    });
  }

  /**
   * Switch to other system account.
   *
   * @param localId local id of object system account.
   */
  switchUser(localId: number) {
    LogUtil.info("Switch system account.");
    osAccount.getAccountManager().activateOsAccount(localId).then(() => {
      LogUtil.info("Successfully switched to account: " + localId);
      this.refreshSystemAccountList();
      setTimeout(this.startLockScreenAbility(), 500);
    });
  }

  /**
   * Remove system account by local id.
   *
   * @param localId local id of this system account, if not set, set it current local id.
   */
  async removeAccount(localId?: number, callback: () => void) {
    let removeId = localId ? localId : this.currentAccount.localId;
    LogUtil.info("Remove system account, local Id: " + removeId);
    osAccount.getAccountManager().removeOsAccount(removeId).then(() => {
      this.refreshSystemAccountList();
      callback();
    });
  }

  private startLockScreenAbility() {
    var abilityParam = {
      "bundleName": "com.ohos.screenlock",
      "abilityName": "com.ohos.screenlock.MainAbility",
      "abilityStartSetting": {}
    };
    globalThis.settingsAbilityContext.startAbility(abilityParam)
      .then((data) => {
        LogUtil.info('Start lockscreen successful. Data: ' + JSON.stringify(data))
      }).catch((error) => {
      LogUtil.error('Start lockscreen failed. Cause: ' + JSON.stringify(error));
    })
  }
}

let systemAccountController = SystemAccountController.getInstance();
export default systemAccountController as SystemAccountController;
