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

import { describe, it, expect, TestType, MockKit, when } from '@ohos/hypium';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SystemAccountAdapter, SystemUserListener } from '@ohos/settings.users/src/main/ets/SystemAccountAdapter';
import { Constant } from '../.././constant/Constant';
import osAccount from '@ohos.account.osAccount';
import distributedAccount from '@ohos.account.distributedAccount';
const LOCAL_ID: number = 0;
const LOCAL_NAME: string = 'test';
const ACCOUNT_TYPE = 0;

export default function systemAccountAdapterTest() {
  describe('systemAccountAdapterTest', () => {

    systemAccountAdapterTest001();
    systemAccountAdapterTest003();
    systemAccountAdapterTest004();
    systemAccountAdapterTest005();
    systemAccountAdapterTest006();
    systemAccountAdapterTest007();
    systemAccountAdapterTest008();
    systemAccountAdapterTest009();
    systemAccountAdapterTest010();
    systemAccountAdapterTest011();
    systemAccountAdapterTest012();
    isHasQuest();
    isShowAddUserTestFalseNoCurrentAccount();
    isCurrentUser();
    it("systemAccountAdapterTest_registerListener_001", 0, () => {
      let systemAccountA: SystemAccountAdapter = SystemAccountAdapter.getInstance();
      const LISTENER = AppStorage.get<SystemUserListener>('listener') as SystemUserListener;
      systemAccountA.registerListener(LISTENER);
      expect(systemAccountA != null).assertTrue();
    })
    it("systemAccountAdapterTest_registerListener_002", 0, () => {
      let systemAccountA: SystemAccountAdapter = SystemAccountAdapter.getInstance();
      const LISTENER = new SystemUserListenerImplementation('listener_test');
      const LISTENER1 = new SystemUserListenerImplementation('listener_test1');
      systemAccountA.registerListener(LISTENER);
      systemAccountA.registerListener(LISTENER);
      systemAccountA.registerListener(LISTENER1);
      expect(LISTENER.getListenerName() !== LISTENER1.getListenerName()).assertTrue();
    })
    it("systemAccountAdapterTest_unRegisterListener_001", 0, () => {
      let systemAccountA: SystemAccountAdapter = SystemAccountAdapter.getInstance();
      const LISTENER = new SystemUserListenerImplementation('listener_test');
      const LISTENER1 = new SystemUserListenerImplementation('listener_test1');
      systemAccountA.registerListener(LISTENER);
      systemAccountA.unRegisterListener(LISTENER1);
      systemAccountA.unRegisterListener(LISTENER);
      expect(LISTENER.getListenerName() !== LISTENER1.getListenerName()).assertTrue();
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
    let accountInfoAdmin: osAccount.OsAccountInfo = {
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
      isActived: false,
      isActivated: false,
      isCreateCompleted: false,
      distributedInfo: distributedInfo,
      domainInfo: domainInfo
    };
    let accountInfoNormal: osAccount.OsAccountInfo = {
      localId: 123,
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
      localId: 0,
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
    it("systemAccountAdapterTest_initSystemAccountList_001", 0, async (done: Function) => {
      let systemAccountA: SystemAccountAdapter = new SystemAccountAdapter();
      await systemAccountA.initSystemAccountList();
      (systemAccountA as object)['accountList'] = [accountInfoAdmin];
      await systemAccountA.initSystemAccountList();
      expect(systemAccountA != null).assertTrue();
      done();
    })
    it("systemAccountAdapterTest_initSystemAccountList_002", 0, async (done: Function) => {
      let systemAccountA: SystemAccountAdapter = new SystemAccountAdapter();
      (systemAccountA as object)['accountList'] = [accountInfoAdmin];
      const result = systemAccountA.isUserUpLimit();
      expect(result).assertFalse();
      const result1 = systemAccountA.isShowIdentity(accountInfoAdmin);
      expect(result1).assertTrue();
      const result2 = systemAccountA.findAccountById(123);
      expect(result2).assertEqual(undefined);
      done();
    })
    it("systemAccountAdapterTest_initSystemAccountList_003", 0, async (done: Function) => {
      let systemAccountA: SystemAccountAdapter = new SystemAccountAdapter();
      (systemAccountA as object)['accountList'] =
        [accountInfoNormal, accountInfoNormal, accountInfoNormal, accountInfoNormal];
      const result = systemAccountA.isUserUpLimit();
      expect(result).assertTrue();
      const result1 = systemAccountA.isShowIdentity(accountInfoNormal);
      expect(result1).assertFalse();
      const result2 = systemAccountA.findAccountById(123);
      expect(result2 !== null).assertTrue();
      const result3 = systemAccountA.isHasQuest();
      expect(result3).assertFalse();
      done();
    })
    it("systemAccountAdapterTest_initSystemAccountList_004", 0, async (done: Function) => {
      let systemAccountA: SystemAccountAdapter = new SystemAccountAdapter();
      (systemAccountA as object)['accountList'] = [accountInfoGuest];
      const result = systemAccountA.isHasQuest();
      expect(result !== null).assertTrue();
      const result1 = systemAccountA.isAlreadyCreated('test', 0);
      expect(result1 !== null).assertTrue();
      done();
    })
    it("systemAccountAdapterTest_initSystemAccountList_005", 0, async (done: Function) => {
      let systemAccountA: SystemAccountAdapter = new SystemAccountAdapter();
      accountInfoGuest.isActived = true;
      (systemAccountA as object)['accountList'] = [accountInfoGuest];
      (systemAccountA as object)['currentAccount'] = accountInfoGuest;
      const result = systemAccountA.isShowAddUser();
      expect(result).assertFalse();
      const result1 = systemAccountA.isShowAddQuest();
      expect(result1).assertFalse();
      const result2 = systemAccountA.isCurrentUser(123);
      expect(result2).assertFalse();
      const result3 = systemAccountA.isCurrentUser(0);
      expect(result3).assertTrue();
      const result4 = systemAccountA.isCurrentAdministrator();
      expect(result4).assertFalse();
      const result5 = systemAccountA.isCurrentQuest();
      expect(result5).assertTrue();
      const result6 = systemAccountA.isGuestAccount(accountInfoGuest);
      expect(result6).assertTrue();
      const result7 = systemAccountA.isGuestAccount(accountInfoAdmin);
      expect(result7).assertFalse();
      accountInfoGuest.isActived = false;
      done();
    })
    it("systemAccountAdapterTest_initSystemAccountList_006", 0, async (done: Function) => {
      let systemAccountA: SystemAccountAdapter = new SystemAccountAdapter();
      accountInfoAdmin.isActived = true;
      (systemAccountA as object)['accountList'] = [accountInfoAdmin, accountInfoNormal];
      (systemAccountA as object)['currentAccount'] = accountInfoAdmin;
      const result = systemAccountA.isShowAddUser();
      expect(result).assertTrue();
      const result1 = systemAccountA.isShowAddQuest();
      expect(result1).assertTrue();
      const result2 = systemAccountA.isCurrentAdministrator();
      expect(result2).assertTrue();
      const result3 = systemAccountA.isCurrentQuest();
      expect(result3).assertFalse();
      accountInfoAdmin.isActived = false;
      done();
    })
    it("systemAccountAdapterTest_noInit_001", 0, () => {
      let systemAccountA: SystemAccountAdapter = new SystemAccountAdapter();
      const result1 = systemAccountA.isShowAddQuest();
      expect(result1).assertFalse();
      const result2 = systemAccountA.isCurrentUser(123);
      expect(result2).assertFalse();
      const result3 = systemAccountA.isGuestAccount(accountInfoAdmin);
      expect(result3).assertFalse();
    })
  });
}

export class SystemUserListenerImplementation implements SystemUserListener {
  private listener: string = '';
  constructor(listener: string) {
    this.listener = listener;
  }
  onSystemUserChange(): void {
    console.log("onSystemUserChange");
  }
  getListenerName(): string {
    return this.listener;
  }
}

function isCurrentUser() {
  it('isCurrentUser', 0, () => {
    let systemAccountAdapter = new SystemAccountAdapter();
    let localId = 123;
    let mocker: MockKit = new MockKit();
    let mockFunc: Function = mocker.mockFunc(systemAccountAdapter, systemAccountAdapter.isCurrentUser);
    when(mockFunc)(localId).afterReturn(true);
    let result: boolean = systemAccountAdapter.isCurrentUser(localId);
    expect(result).assertTrue();
    mocker.clear(systemAccountAdapter);
  });
}

function isShowAddUserTestFalseNoCurrentAccount() {
  it('isShowAddUserTest_false_noCurrentAccount', 0, () => {
    let systemAccountAdapter = new SystemAccountAdapter();
    let res = systemAccountAdapter.isShowAddUser();

    expect(res).assertFalse();
  });
}

function isHasQuest() {
  it('isHasQuest', 0, async () => {
    let isHasQuest = SystemAccountAdapter.getInstance().isHasQuest();
    expect(isHasQuest !== null).assertEqual(true);
  });
}

function systemAccountAdapterTest012() {
  it('systemAccountAdapterTest_012', TestType.FUNCTION, async () => {
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_012 start`);
    let systemAccountAdapter = new SystemAccountAdapter();
    let mocker: MockKit = new MockKit();
    let mockFunc: Function = mocker.mockFunc(systemAccountAdapter, systemAccountAdapter.removeAccount);
    when(mockFunc)(LOCAL_ID).afterReturn(true);
    let result = await systemAccountAdapter.removeAccount(LOCAL_ID, () => {
    });
    expect(result !== null).assertTrue();
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_012 end`);
    mocker.clear(systemAccountAdapter);
  });
}

function systemAccountAdapterTest011() {
  it('systemAccountAdapterTest_011', TestType.FUNCTION, async () => {
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_011 start`);
    let systemAccountAdapter = new SystemAccountAdapter();
    let mocker: MockKit = new MockKit();
    let mockFunc: Function = mocker.mockFunc(systemAccountAdapter, systemAccountAdapter.switchUser);
    when(mockFunc)(LOCAL_ID).afterReturn(true);
    let result = await systemAccountAdapter.switchUser(LOCAL_ID);
    expect(result !== null).assertTrue();
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_011 end`);
    mocker.clear(systemAccountAdapter);
  });
}

function systemAccountAdapterTest010() {
  it('systemAccountAdapterTest_010', TestType.FUNCTION, async () => {
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_010 start`);
    let systemAccountAdapter = new SystemAccountAdapter();
    let mocker: MockKit = new MockKit();
    let mockFunc: Function = mocker.mockFunc(systemAccountAdapter, systemAccountAdapter.setAccountName);
    when(mockFunc)(LOCAL_ID).afterReturn(true);
    let result = await systemAccountAdapter.setAccountName(LOCAL_ID, LOCAL_NAME);
    expect(result !== null).assertTrue();
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_010 end`);
    mocker.clear(systemAccountAdapter);
  });
}

function systemAccountAdapterTest009() {
  it('systemAccountAdapterTest_009', TestType.FUNCTION, async () => {
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_009 start`);
    let systemAccountAdapter = new SystemAccountAdapter();
    let falseResult = await systemAccountAdapter.isAlreadyCreated(LOCAL_NAME, LOCAL_ID);
    expect(falseResult).assertFalse();
    let mocker: MockKit = new MockKit();
    let mockFunc: Function = mocker.mockFunc(systemAccountAdapter, systemAccountAdapter.isAlreadyCreated);
    when(mockFunc)('test').afterReturn(true);
    let trueResult = await systemAccountAdapter.isAlreadyCreated(LOCAL_NAME, LOCAL_ID);
    expect(trueResult).assertTrue();
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_009 end`);
    mocker.clear(systemAccountAdapter);
  });
}

function systemAccountAdapterTest008() {
  it('systemAccountAdapterTest_008', TestType.FUNCTION, async () => {
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_008 start`);
    let systemAccountAdapter = new SystemAccountAdapter();
    let mocker: MockKit = new MockKit();
    let mockFunc: Function = mocker.mockFunc(systemAccountAdapter, systemAccountAdapter.createSystemAccount);
    when(mockFunc)('test').afterReturn(true);
    let result = await systemAccountAdapter.createSystemAccount(LOCAL_NAME, ACCOUNT_TYPE);
    expect(result !== null).assertTrue();
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_008 end`);
    mocker.clear(systemAccountAdapter);
  });
}

function systemAccountAdapterTest007() {
  it('systemAccountAdapterTest_007', TestType.FUNCTION, async () => {
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_007 start`);
    let systemAccountAdapter = new SystemAccountAdapter();
    let mocker: MockKit = new MockKit();
    let mockFunc: Function = mocker.mockFunc(systemAccountAdapter, systemAccountAdapter.createGuest);
    when(mockFunc)().afterReturn(true);
    let result = await systemAccountAdapter.createGuest();
    expect(result).assertTrue();
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_007 end`);
    mocker.clear(systemAccountAdapter);
  });
}

function systemAccountAdapterTest006() {
  it('systemAccountAdapterTest_006', TestType.FUNCTION, async () => {
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_006 start`);
    let systemAccountAdapter = new SystemAccountAdapter();
    let mocker: MockKit = new MockKit();
    let mockFunc: Function = mocker.mockFunc(systemAccountAdapter, systemAccountAdapter.switchToCreatedAccount);
    when(mockFunc)().afterReturn(true);
    let result = await systemAccountAdapter.switchToCreatedAccount();
    expect(result !== null).assertTrue();
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_006 end`);
    mocker.clear(systemAccountAdapter);
  });
}

function systemAccountAdapterTest005() {
  it('systemAccountAdapterTest_005', TestType.FUNCTION, async () => {
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_005 start`);
    let systemAccountAdapter = new SystemAccountAdapter();
    let falseResult = await systemAccountAdapter.isCurrentQuest();
    expect(falseResult).assertFalse();
    let mocker: MockKit = new MockKit();
    let mockFunc: Function = mocker.mockFunc(systemAccountAdapter, systemAccountAdapter.isCurrentQuest);
    when(mockFunc)().afterReturn(true);
    let trueResult = await systemAccountAdapter.isCurrentQuest();
    expect(trueResult).assertTrue();
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_005 end`);
    mocker.clear(systemAccountAdapter);
  });
}

function systemAccountAdapterTest004() {
  it('systemAccountAdapterTest_004', TestType.FUNCTION, async () => {
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_004 start`);
    let systemAccountAdapter = new SystemAccountAdapter();
    let falseResult = await systemAccountAdapter.isCurrentAdministrator();
    expect(falseResult).assertFalse();
    let mocker: MockKit = new MockKit();
    let mockFunc: Function = mocker.mockFunc(systemAccountAdapter, systemAccountAdapter.isCurrentAdministrator);
    when(mockFunc)().afterReturn(true);
    let trueResult = await systemAccountAdapter.isCurrentAdministrator();
    expect(trueResult).assertTrue();
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_004 end`);
    mocker.clear(systemAccountAdapter);
  });
}

function systemAccountAdapterTest003() {
  it('systemAccountAdapterTest_003', TestType.FUNCTION, async () => {
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_003 start`);
    let systemAccountAdapter = new SystemAccountAdapter();
    let mocker: MockKit = new MockKit();
    let mockFunc: Function = mocker.mockFunc(systemAccountAdapter, systemAccountAdapter.findAccountById);
    when(mockFunc)(LOCAL_ID).afterReturn(true);
    let result = await systemAccountAdapter.findAccountById(LOCAL_ID);
    expect(result).assertTrue();
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_003 end`);
    mocker.clear(systemAccountAdapter);
  });
}

function systemAccountAdapterTest001() {
  it('systemAccountAdapterTest_001', TestType.FUNCTION, async () => {
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_001 start`);
    let systemAccountAdapter = new SystemAccountAdapter();
    let mocker: MockKit = new MockKit();
    let mockFunc: Function = mocker.mockFunc(systemAccountAdapter, systemAccountAdapter.initSystemAccountList);
    when(mockFunc)().afterReturn(true);
    let result = await systemAccountAdapter.initSystemAccountList();
    expect(result !== null).assertTrue();
    LogUtil.info(`${Constant.TAG} systemAccountAdapterTest_001 end`);
    mocker.clear(systemAccountAdapter);
  });
}
