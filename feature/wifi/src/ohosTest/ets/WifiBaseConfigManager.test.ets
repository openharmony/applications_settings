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
import { WifiBaseConfigManager } from '../../main/ets/WifiBaseConfigManager';

export default function wifiBaseConfigManagerTest() {
  describe('wifiBaseConfigManagerTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    convertString2Number();
    validWEPEncryptionPwdTest();
    validWEPEncryptionPwdTest2();
    convertIpString2NumberTest();
    convertIpString2NumberTestNull();
  })
}

function convertIpString2NumberTest() {
  it('convertIpString2NumberTest', 0, () => {
    let ip: string = '192.168.1.123';
    let number: number = WifiBaseConfigManager.convertIpString2Number(ip);
    expect(number).assertEqual(3232235899);
  });
}

function convertIpString2NumberTestNull() {
  it('convertIpString2NumberTestNull', 0, () => {
    let ip: string = '';
    let number: number = WifiBaseConfigManager.convertIpString2Number(ip);
    expect(number).assertNaN();
  });
}

function validWEPEncryptionPwdTest2() {
  it('validWEPEncryptionPwdTest2', Level.LEVEL1, () => {
    let wepPwd: string = '12345678901234567890abcd';
    expect(WifiBaseConfigManager.isValidWepEncryptionPwd(wepPwd)).assertTrue();
  });
}

function validWEPEncryptionPwdTest() {
  it('validWEPEncryptionPwdTest', Level.LEVEL1, () => {
    let wepPwd: string = '12345678901234567890';
    expect(WifiBaseConfigManager.isValidWepEncryptionPwd(wepPwd)).assertTrue();
  });
}

function convertString2Number() {
  it('convertString2Number', 0, () => {
    let result = WifiBaseConfigManager.convertString2Number(10);
    expect(result).assertEqual(10);
    result = WifiBaseConfigManager.convertString2Number('10');
    expect(result).assertEqual(10);
  });
}
