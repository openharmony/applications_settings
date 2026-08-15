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
import type common from '@ohos.app.ability.common';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import {
  ItemResultType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { MAX_ACCOUNT, usersAccountModel } from '../model/UsersAccountModel';
import { UserSwitchConfigRestorer } from '../utils/UserSwitchConfigRestorer';

const TAG: string = 'UsersAccountController:';
const CURRENT_LOGIN_ITEM_COMP_ID: string = 'Setting.UsersAccounts.users_account_group.current_login_item';

export class UsersAccountController {
  private static instance: UsersAccountController | undefined = undefined;
  private currentAccount: osAccount.OsAccountInfo | undefined = undefined;
  private accountList: osAccount.OsAccountInfo[] = [];

  public static getInstance(): UsersAccountController {
    if (!UsersAccountController.instance) {
      UsersAccountController.instance = new UsersAccountController();
    }
    return UsersAccountController.instance;
  }

  async refreshSystemAccountList(): Promise<void> {
    LogUtil.info(`${TAG} refreshSystemAccountList`);
    try {
      this.accountList = await osAccount.getAccountManager().queryAllCreatedOsAccounts();
      this.currentAccount = usersAccountModel.getCurrentAccount(this.accountList);
      if (this.currentAccount) {
        usersAccountModel.setCurrentAccount(this.currentAccount);
      }
      this.accountList.sort(usersAccountModel.sortAccount.bind(usersAccountModel));
      this.publishAccountListState();
    } catch (err) {
      LogUtil.error(`${TAG} refreshSystemAccountList failed: ${JSON.stringify(err)}`);
    }
  }

  private publishAccountListState(): void {
    AppStorage.setOrCreate('systemAccountList', [...this.accountList]);
    AppStorage.setOrCreate('isShowAddUser', this.isShowAddUser());
    AppStorage.setOrCreate('isShowAddGuest', this.isShowAddGuest());
    AppStorage.setOrCreate('isShowDelete', !this.isCurrentAdministrator());
    AppStorage.setOrCreate('isCurrentGuestUser', this.isCurrentGuest());
  }

  getAccountList(): osAccount.OsAccountInfo[] {
    return this.accountList;
  }

  getCurrentAccount(): osAccount.OsAccountInfo | undefined {
    return this.currentAccount;
  }

  isShowIdentity(accountInfo: osAccount.OsAccountInfo | undefined): boolean {
    return accountInfo?.type === osAccount.OsAccountType.ADMIN;
  }

  isHasGuest(): boolean {
    for (let index = 0; index < this.accountList.length; index++) {
      if (this.accountList[index].type === osAccount.OsAccountType.GUEST) {
        return true;
      }
    }
    return false;
  }

  isShowAddUser(): boolean {
    if (!this.currentAccount) {
      return false;
    }
    return this.currentAccount.type === osAccount.OsAccountType.ADMIN &&
      this.accountList.length < (this.isHasGuest() ? MAX_ACCOUNT : (MAX_ACCOUNT - 1));
  }

  isShowAddGuest(): boolean {
    if (!this.currentAccount) {
      return false;
    }
    return this.currentAccount.type === osAccount.OsAccountType.ADMIN &&
      !this.isHasGuest() && this.accountList.length < MAX_ACCOUNT;
  }

  isCurrentUser(accountInfo: osAccount.OsAccountInfo | undefined): boolean {
    if (!accountInfo || !this.currentAccount) {
      return false;
    }
    return accountInfo.localId === this.currentAccount.localId;
  }

  isCurrentAdministrator(): boolean {
    return this.currentAccount?.type === osAccount.OsAccountType.ADMIN;
  }

  isCurrentGuest(): boolean {
    return this.currentAccount?.type === osAccount.OsAccountType.GUEST;
  }

  isGuestAccount(account: osAccount.OsAccountInfo | undefined): boolean {
    return account?.type === osAccount.OsAccountType.GUEST;
  }

  canAdminDeleteUser(accountInfo: osAccount.OsAccountInfo | undefined): boolean {
    if (!this.isCurrentAdministrator() || !accountInfo) {
      return false;
    }
    if (this.isCurrentUser(accountInfo)) {
      return false;
    }
    return accountInfo.type !== osAccount.OsAccountType.ADMIN;
  }

  switchToCreatedAccount(): void {
    this.accountList.sort((account1, account2) => account2.serialNumber - account1.serialNumber);
    let newlyId = this.accountList[0]?.localId;
    LogUtil.info(`${TAG} switchToCreatedAccount newlyId: ${newlyId}`);
    if (newlyId !== undefined) {
      this.switchUser(newlyId);
    }
  }

  async createGuest(callback?: () => void): Promise<void> {
    LogUtil.info(`${TAG} createGuest`);
    let localName = ResourceUtil.getStringSync($r('app.string.user_guest'));
    try {
      await osAccount.getAccountManager().createOsAccount(localName, osAccount.OsAccountType.GUEST);
      await this.refreshSystemAccountList();
      callback?.();
    } catch (err) {
      LogUtil.error(`${TAG} createGuest failed: ${JSON.stringify(err)}`);
    }
  }

  async createSystemAccount(localName: string, callback?: () => void): Promise<void> {
    LogUtil.info(`${TAG} createSystemAccount`);
    try {
      await osAccount.getAccountManager().createOsAccount(localName, osAccount.OsAccountType.NORMAL);
      await this.refreshSystemAccountList();
      callback?.();
    } catch (err) {
      LogUtil.error(`${TAG} createSystemAccount failed: ${JSON.stringify(err)}`);
    }
  }

  isAlreadyCreated(inputName: string): boolean {
    for (let index = 0; index < this.accountList.length; index++) {
      if (this.accountList[index].localName === inputName) {
        return true;
      }
    }
    return false;
  }

  refreshCurrentLoginName(): void {
    usersAccountModel.updateAccountName((accountName: string) => {
      this.notifyCurrentLoginName(accountName);
    });
  }

  async setAccountName(localId: number, name: string): Promise<void> {
    LogUtil.info(`${TAG} setAccountName localId: ${localId}`);
    try {
      await osAccount.getAccountManager().setOsAccountName(localId, name);
      this.updateLocalAccountName(localId, name);
      this.notifyCurrentLoginName(name);
      await this.refreshSystemAccountList();
    } catch (err) {
      LogUtil.error(`${TAG} setAccountName failed: ${JSON.stringify(err)}`);
    }
  }

  private updateLocalAccountName(localId: number, name: string): void {
    for (let index = 0; index < this.accountList.length; index++) {
      if (this.accountList[index].localId === localId) {
        this.accountList[index].localName = name;
        break;
      }
    }
    if (this.currentAccount?.localId === localId) {
      this.currentAccount.localName = name;
    }
    this.publishAccountListState();
  }

  private notifyCurrentLoginName(name: string): void {
    notifyCompStateChange(CURRENT_LOGIN_ITEM_COMP_ID,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: name }
        } as SettingResultState]]));
  }

  switchUser(localId: number): void {
    LogUtil.info(`${TAG} switchUser localId: ${localId}`);
    osAccount.getAccountManager().activateOsAccount(localId).then(() => {
      LogUtil.info(`${TAG} switchUser success`);
      UserSwitchConfigRestorer.restoreAfterUserSwitch();
      this.refreshSystemAccountList();
      setTimeout(() => {
        this.startLockScreenAbility();
      }, 500);
    }).catch((err: Error) => {
      LogUtil.error(`${TAG} switchUser failed: ${err?.message}`);
    });
  }

  async removeAccount(localId?: number, callback?: () => void): Promise<void> {
    let removeId = localId ?? this.currentAccount?.localId;
    if (removeId === undefined) {
      return;
    }
    LogUtil.info(`${TAG} removeAccount localId: ${removeId}`);
    try {
      await osAccount.getAccountManager().removeOsAccount(removeId);
      this.accountList = this.accountList.filter((account) => account.localId !== removeId);
      this.publishAccountListState();
      await this.refreshSystemAccountList();
      this.accountList = this.accountList.filter((account) => account.localId !== removeId);
      this.publishAccountListState();
      callback?.();
    } catch (err) {
      LogUtil.error(`${TAG} removeAccount failed: ${JSON.stringify(err)}`);
    }
  }

  private startLockScreenAbility(): void {
    let abilityParam: Record<string, Object> = {
      'bundleName': 'com.ohos.screenlock',
      'abilityName': 'com.ohos.screenlock.MainAbility',
    };
    let context = AbilityContextManager.getContext() as common.UIAbilityContext;
    if (!context) {
      LogUtil.error(`${TAG} startLockScreenAbility context is null`);
      return;
    }
    context.startAbility(abilityParam).then(() => {
      LogUtil.info(`${TAG} startLockScreenAbility success`);
    }).catch((err: Error) => {
      LogUtil.error(`${TAG} startLockScreenAbility failed: ${err?.message}`);
    });
  }
}

export const usersAccountController = UsersAccountController.getInstance();
