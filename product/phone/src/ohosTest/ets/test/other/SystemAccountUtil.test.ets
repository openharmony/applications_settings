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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it, MockKit, when } from '@ohos/hypium';

import { SystemAccountUtil } from '@ohos/settings.users/src/main/ets/SystemAccountUtil';
import account_osAccount from '@ohos.account.osAccount'
import { SystemAccountAdapter } from '@ohos/settings.users/src/main/ets/SystemAccountAdapter';
import osAccount from '@ohos.account.osAccount';
import distributedAccount from '@ohos.account.distributedAccount';

export default function systemAccountUtilTest() {
  describe('systemAccountUtilTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    it('SystemAccountTest_getIdentityFromMap_admin', 0, () => {
      let result: string | Resource = SystemAccountUtil.getIdentityFromMap(account_osAccount.OsAccountType.ADMIN);
      expect(result).not().assertNull();
    })
    it('SystemAccountTest_getIdentityFromMap_normal', 0, () => {
      let result: string | Resource = SystemAccountUtil.getIdentityFromMap(account_osAccount.OsAccountType.NORMAL);
      expect(result).assertEqual('');
    })
    it('SystemAccountTest_getIdentityFromMap_guest', 0, () => {
      let result: string | Resource = SystemAccountUtil.getIdentityFromMap(account_osAccount.OsAccountType.GUEST);
      expect(result).not().assertNull();
    })
    it('SystemAccountTest_getIdentityFromMap_unknown', 0, () => {
      let result: string | Resource = SystemAccountUtil.getIdentityFromMap(account_osAccount.OsAccountType.PRIVATE);
      expect(result).assertEqual('未知用户');
    })

    it('checkAdminUserTest', 0, async () => {
      let result = await SystemAccountUtil.checkAdminUser();
      expect(result).assertEqual(true);
    })
    let distributedInfo: distributedAccount.DistributedInfo = {
      name: '',
      id: '',
      event: ''
    };
    let domainInfo: osAccount.DomainAccountInfo = {
      domain: '',
      accountName: ''
    };
    let accountInfoCurrent: osAccount.OsAccountInfo = {
      localId: 0,
      localName: '',
      type: osAccount.OsAccountType.ADMIN,
      constraints: [],
      isVerified: false,
      isUnlocked: false,
      photo: '',
      createTime: 0,
      lastLoginTime: 0,
      serialNumber: 0,
      isActived: true,
      isActivated: false,
      isCreateCompleted: false,
      distributedInfo: distributedInfo,
      domainInfo: domainInfo
    };
    let accountInfoAdmin: osAccount.OsAccountInfo = {
      localId: 100,
      localName: '',
      type: osAccount.OsAccountType.ADMIN,
      constraints: [],
      isVerified: false,
      isUnlocked: false,
      photo: '',
      createTime: 0,
      lastLoginTime: 0,
      serialNumber: 0,
      isActived: false,
      isActivated: false,
      isCreateCompleted: false,
      distributedInfo: distributedInfo,
      domainInfo: domainInfo
    };
    let accountInfoNormal: osAccount.OsAccountInfo = {
      localId: 101,
      localName: '',
      type: osAccount.OsAccountType.NORMAL,
      constraints: [],
      isVerified: false,
      isUnlocked: false,
      photo: '',
      createTime: 0,
      lastLoginTime: 0,
      serialNumber: 0,
      isActived: false,
      isActivated: false,
      isCreateCompleted: false,
      distributedInfo: distributedInfo,
      domainInfo: domainInfo
    };
    let accountInfoGuest: osAccount.OsAccountInfo = {
      localId: 102,
      localName: 'test',
      type: osAccount.OsAccountType.GUEST,
      constraints: [],
      isVerified: false,
      isUnlocked: false,
      photo: '',
      createTime: 0,
      lastLoginTime: 0,
      serialNumber: 0,
      isActived: false,
      isActivated: false,
      isCreateCompleted: false,
      distributedInfo: distributedInfo,
      domainInfo: domainInfo
    };
    const accountArr = [accountInfoAdmin, accountInfoNormal, accountInfoGuest];
    it("systemAccountUtilTest_getCurrentAccount_001", 0, () => {
      let result = SystemAccountUtil.getCurrentAccount(accountArr);
      expect(result != null).assertTrue();
    })
    it("systemAccountUtilTest_sortAccount_001", 0, () => {
      const sysA = SystemAccountAdapter.getInstance();
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(sysA, sysA.getCurrentInfo);
      accountInfoCurrent.localId = 100;
      when(mockFun)().afterReturn(accountInfoCurrent);
      let result = SystemAccountUtil.sortAccount(accountInfoAdmin, accountInfoNormal);
      expect(result).assertEqual(-1);
      let result1 = SystemAccountUtil.sortAccount(accountInfoNormal, accountInfoAdmin);
      expect(result1).assertEqual(1);
      accountInfoCurrent.localId = 0;
      when(mockFun)().afterReturn(accountInfoCurrent);
      let result2 = SystemAccountUtil.sortAccount(accountInfoAdmin, accountInfoNormal);
      expect(result2).assertEqual(-1);
      let result3 = SystemAccountUtil.sortAccount(accountInfoNormal, accountInfoAdmin);
      expect(result3).assertEqual(1);
      let result4 = SystemAccountUtil.sortAccount(accountInfoGuest, accountInfoNormal);
      expect(result4).assertEqual(1);
      let result5 = SystemAccountUtil.sortAccount(accountInfoNormal, accountInfoGuest);
      expect(result5).assertEqual(-1);
      let result6 = SystemAccountUtil.sortAccount(accountInfoNormal, accountInfoNormal);
      expect(result6).assertEqual(0);
      mocker.clear(sysA);
    })
    it("systemAccountUtilTest_sortAccountBindThis_001", 0, () => {
      const sysA = SystemAccountAdapter.getInstance();
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(sysA, sysA.getCurrentInfo);
      accountInfoCurrent.localId = 100;
      when(mockFun)().afterReturn(accountInfoCurrent);
      let result = SystemAccountUtil.sortAccountBindThis(accountInfoAdmin, accountInfoNormal, sysA);
      expect(result).assertEqual(-1);
      let result1 = SystemAccountUtil.sortAccountBindThis(accountInfoNormal, accountInfoAdmin, sysA);
      expect(result1).assertEqual(1);
      accountInfoCurrent.localId = 0;
      when(mockFun)().afterReturn(accountInfoCurrent);
      let result2 = SystemAccountUtil.sortAccountBindThis(accountInfoAdmin, accountInfoNormal, sysA);
      expect(result2).assertEqual(-1);
      let result3 = SystemAccountUtil.sortAccountBindThis(accountInfoNormal, accountInfoAdmin, sysA);
      expect(result3).assertEqual(1);
      let result4 = SystemAccountUtil.sortAccountBindThis(accountInfoGuest, accountInfoNormal, sysA);
      expect(result4).assertEqual(1);
      let result5 = SystemAccountUtil.sortAccountBindThis(accountInfoNormal, accountInfoGuest, sysA);
      expect(result5).assertEqual(-1);
      let result6 = SystemAccountUtil.sortAccountBindThis(accountInfoNormal, accountInfoNormal, sysA);
      expect(result6).assertEqual(0);
      mocker.clear(sysA);
    })
    it("systemAccountUtilTest_checkAdminUser_001", 0, async (done: Function) => {
      const sysA = SystemAccountAdapter.getInstance();
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(sysA, sysA.getCurrentInfo);
      accountInfoCurrent.type = osAccount.OsAccountType.GUEST;
      when(mockFun)().afterReturn(accountInfoCurrent);
      let result = await SystemAccountUtil.checkAdminUser();
      expect(result != null).assertTrue();
      mocker.clear(sysA);
      done();
    })
  })
}

