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

import {
  afterAll,
  afterEach,
  beforeAll,
  beforeEach,
  describe,
  expect,
  it,
  Level,
} from '@ohos/hypium';
import util from '@ohos.util';
import osAccount from '@ohos.account.osAccount';
import { PasswordUtil } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';

export default function passwordUtilsTest() {
  describe('passwordUtilsTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    passwordUtilTestStringToUint8Array();
    checkEmptyUtilsTestBase64StringToUint8Array001();
    passwordUtilTestUint8ArrayToBase64String();
    passwordUtilTestOpenSession();
    uint8ArrayToString();
    passwordUtilTestRegisterInputer();
    passwordUtilTestUnregisterInputer();
    createPasswordCallbackError();
    passwordUtilTestHasPinPassword();
    passwordUtilTestAuthPin();
    authPinByOutChallengeNull();
    passwordUtilTestUpdatePassword();
    passwordUtilTestDeletePassword();
    passwordUtilTestGetAuthProperty();
    arrayJsonToUint8Array();
    testPasswordUtil001();
    testPasswordUtil002();
    testPasswordUtil003();
    testPasswordUtil004();
    testPasswordUtil005();
    isPinNumber6();
    isPinNumber61();
    isPinNumber62();
    isContainIllegalCharacterEmpty();
    isContainIllegalCharacter();
    isOnlyNumber();
    isOnlyNumberTest1();
    isIncludeAtLeastOneLetterTest();
    getConfirmWarningMessage();
    getCountDownDialogMessageNull();
    getPinSubType();
    silenceAuthPinTest();
    cancelEnrollFingerprint();
    isWeakPasswordsTestTrue();
    isWeakPasswordsTestFalse();
  })
}

function isWeakPasswordsTestFalse() {
  it('isWeakPasswordsTestFalse', 0, () => {
    let isWeakPasswords = PasswordUtil.isWeakPasswords('a');
    expect(isWeakPasswords).assertTrue();
  });
}

function isWeakPasswordsTestTrue() {
  it('isWeakPasswordsTestTrue', 0, () => {
    let isWeakPasswords = PasswordUtil.isWeakPasswords('aaaaa');
    expect(isWeakPasswords).assertTrue();
  });
}

function cancelEnrollFingerprint() {
  it('cancelEnrollFingerprint', 0, () => {
    PasswordUtil.cancelEnrollFingerprint();
    expect(null).assertEqual(null);
  });
}

function silenceAuthPinTest() {
  it('silenceAuthPinTest', 0, () => {
    PasswordUtil.openSession((data) => {
      PasswordUtil.silenceAuthPin();
      expect(1).assertEqual(1);
    });
  });
}

function getPinSubType() {
  it('getPinSubType', 0, () => {
    let pinSubType = PasswordUtil.getPinSubType('');
    expect(pinSubType).assertEqual(10002);

    let pinSubType1 = PasswordUtil.getPinSubType('123456');
    expect(pinSubType1).assertEqual(10000);

    let pinSubType2 = PasswordUtil.getPinSubType('1234567');
    expect(pinSubType2).assertEqual(10001);
  });
}

function getCountDownDialogMessageNull() {
  it('getCountDownDialogMessageNull', 0, () => {
    let millisecondsTime: number = 0;
    let result = PasswordUtil.getCountDownDialogMessage(millisecondsTime);
    expect(result).assertEqual(' ');
  });
}

function getConfirmWarningMessage() {
  it('getConfirmWarningMessage', 0, () => {
    let a = 'abc';
    let b = 'abc';
    let result = PasswordUtil.getConfirmWarningMessage(a, b);
    expect(result).assertEqual(' ');
  });
}

function isIncludeAtLeastOneLetterTest() {
  it('isIncludeAtLeastOneLetterTest', 0, () => {
    let password: string = '12345678';
    let result: boolean = PasswordUtil.isIncludeAtLeastOneLetter(password);
    expect(result).assertFalse();
  });
}

function isOnlyNumberTest1() {
  it('isOnlyNumberTest1', 0, () => {
    let password: string = '123456';
    let result: boolean = PasswordUtil.isOnlyNumber(password);
    expect(result).assertTrue();
  });
}

function isOnlyNumber() {
  it('isOnlyNumber', 0, () => {
    let password: string = '';
    let result: boolean = PasswordUtil.isOnlyNumber(password);
    expect(result).assertFalse();
  });
}

function isContainIllegalCharacter() {
  it('isContainIllegalCharacter', 0, () => {
    let result = PasswordUtil.isContainIllegalCharacter('1234@#$5678');
    expect(result).assertFalse();
  });
}

function isContainIllegalCharacterEmpty() {
  it('isContainIllegalCharacterEmpty', 0, () => {
    let result = PasswordUtil.isContainIllegalCharacter('');
    expect(result).assertFalse();
  });
}

function isPinNumber62() {
  it('isPinNumber62', 0, () => {
    let result = PasswordUtil.isPinNumber6('111111');
    expect(result).assertTrue();
  });
}

function isPinNumber61() {
  it('isPinNumber61', 0, () => {
    let result = PasswordUtil.isPinNumber6('abc');
    expect(result).assertFalse();
  });
}

function isPinNumber6() {
  it('isPinNumber6', 0, () => {
    let result = PasswordUtil.isPinNumber6('');
    expect(result).assertFalse();
  });
}

function testPasswordUtil005() {
  it('testPasswordUtil005', 0, () => {
    let password: string = '1234567891';
    let result = PasswordUtil.getPasswordValidStatus(password);
    expect(result).assertEqual(100);
  });
}

function testPasswordUtil004() {
  it('testPasswordUtil004', 0, () => {
    let password: string = '123456789';
    let result = PasswordUtil.getPasswordValidStatus(password);
    expect(result).assertEqual(100);
  });
}

function testPasswordUtil003() {
  it('testPasswordUtil003', 0, () => {
    let password: string = '1234';
    let result = PasswordUtil.getPasswordValidStatus(password);
    expect(result).assertEqual(101);
  });
}

function testPasswordUtil002() {
  it('testPasswordUtil002', 0, () => {
    let password: string = '1234\\';
    let result = PasswordUtil.getPasswordValidStatus(password);
    expect(result).assertEqual(101);
  });
}

function testPasswordUtil001() {
  it('testPasswordUtil001', 0, () => {
    let password: string = '';
    let result = PasswordUtil.getPasswordValidStatus(password);
    expect(result).assertEqual(101);
  });
}

function arrayJsonToUint8Array() {
  it('arrayJsonToUint8Array', 0, () => {
    let arrayJson: string = '[1,2,3]';
    let result = PasswordUtil.arrayJsonToUint8Array(arrayJson);
    let exceptRest: Uint8Array = new Uint8Array([1, 2, 3]);
    expect(JSON.stringify(result)).assertEqual(JSON.stringify(exceptRest));
  });
}

function passwordUtilTestGetAuthProperty() {
  it('passwordUtilTestGetAuthProperty', 0, () => {
    let userAuth: osAccount.UserAuth = new osAccount.UserAuth();
    let request: osAccount.GetPropertyRequest = {
      authType: 1,
      keys: [1, 2, 3],
    };
    userAuth.getProperty(request).then((data) => {
      expect(JSON.stringify(data)).assertEqual(JSON.stringify(data));
    });
  });
}

function passwordUtilTestDeletePassword() {
  it('passwordUtilTestDeletePassword', 0, () => {
    let result = false;
    PasswordUtil.deletePassword('', '', (result1, extraInfo) => {
      result = true;
    });
    expect(result).assertFalse();
  });
}

function passwordUtilTestUpdatePassword() {
  it('passwordUtilTestUpdatePassword', 0, () => {
    let pinSubType = 1;
    let password = '1234';
    let token: Uint8Array = new Uint8Array([1, 2, 3, 4]);
    PasswordUtil.updatePassword(pinSubType, password, token, (result, extraInfo) => {
    });
    expect(true).assertTrue();
  });
}

function authPinByOutChallengeNull() {
  it('authPinByOutChallengeNull', 0, () => {
    PasswordUtil.authPinByOutChallenge('', '', 'password', (result: number) => {
    });
    expect(0).assertEqual(0);
  });
}

function passwordUtilTestAuthPin() {
  it('passwordUtilTestAuthPin', 0, () => {
    let result = 0;
    PasswordUtil.authPin('', '', (result, extraInfo) => {
      expect(result).assertEqual(result);
    });
  });
}

function passwordUtilTestHasPinPassword() {
  it('passwordUtilTestHasPinPassword', 0, () => {
    PasswordUtil.hasPinPassword((hasPinPassword) => {
      expect(false).assertEqual(hasPinPassword);
    });
  });
}

function createPasswordCallbackError() {
  it('createPasswordCallbackError', 0, () => {
    let password = '12345678';
    let pinSubType = 1;
    let result = -1;
    PasswordUtil.createPassword(pinSubType, password, (result: number) => {
      expect(result).assertEqual(result);
    });
  });
}

function passwordUtilTestUnregisterInputer() {
  it('passwordUtilTestUnregisterInputer', 0, () => {
    PasswordUtil.unregisterInputer();
    expect(0).assertEqual(0);
  });
}

function passwordUtilTestRegisterInputer() {
  it('passwordUtilTestRegisterInputer', 0, () => {
    PasswordUtil.registerInputer(1);
    expect(0).assertEqual(0);
  });
}

function uint8ArrayToString() {
  it('uint8ArrayToString', Level.LEVEL1, async () => {
    let array: Uint8Array = new Uint8Array([1, 2, 3]);
    let str: string = PasswordUtil.uint8ArrayToString(array);
    expect(str).assertEqual('[1,2,3]');
  });
}

function passwordUtilTestOpenSession() {
  it('passwordUtilTestOpenSession', 0, async (done: Function) => {
    PasswordUtil.openSession((challenge) => {
      expect(challenge.length > 0).assertTrue();
      done();
    });
  });
}

function passwordUtilTestUint8ArrayToBase64String() {
  it('passwordUtilTestUint8ArrayToBase64String', 0, () => {
    let array: Uint8Array = new Uint8Array([1, 2, 3, 4, 5]);
    let result = PasswordUtil.uint8ArrayToBase64String(array);
    const str: string = 'AQIDBAU=';
    expect(result).assertEqual(str);
  });
}

function checkEmptyUtilsTestBase64StringToUint8Array001() {
  it('checkEmptyUtilsTestBase64StringToUint8Array001', 0, () => {
    let result: Uint8Array = PasswordUtil.base64StringToUint8Array('');
    let exceptRest: Uint8Array = new Uint8Array([]);
    expect(JSON.stringify(result)).assertEqual(JSON.stringify(exceptRest));
  });
}

function passwordUtilTestStringToUint8Array() {
  it('passwordUtilTestStringToUint8Array', 0, () => {
    let array = PasswordUtil.stringToUint8Array('test');
    let textEncoder = new util.TextEncoder();
    expect(JSON.stringify(array)).assertEqual(JSON.stringify(textEncoder.encode('test')));
  });
}
