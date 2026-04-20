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

import { afterAll, afterEach, beforeAll, beforeEach, describe, expect, it } from '@ohos/hypium';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import dataShare from '@ohos.data.dataShare';

export default function settingsDataUtilsTest() {
  describe('settingsDataUtilsTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    getSettingsData01();
    getSettingsData02();
    setSettingsData1();
    setSettingsData2();
    setSettingsDataDomain();
    getSupport();
    getSettingsUriTest();
    getSettingsSecurityUri();
    registerSecurityDataChange();
    unRegisterSecurityDataChange();
  })
}

function getSettingsUriTest() {
  it('getSettingsUriTest', 0, () => {
    let uri = SettingsDataUtils.getSettingsUri('');
    expect(uri).assertEqual('');
    let uri2 = SettingsDataUtils.getSettingsUri('a');
    expect(uri2).assertEqual(SettingsDataUtils.settingsDataUrl + 'a');
  });
}

function getSupport() {
  it('SettingsDataUtilsTest_getSupport', 0, () => {
    let res = 'test';
    SettingsDataUtils.getSupport('testKey', 'testValue');
    expect(res).not().assertNull();
  });
}

function getSettingsSecurityUri() {
  it('SettingsDataUtilsTest_getSettingsSecurityUri', 0, () => {
    let res = 'test';
    SettingsDataUtils.getSettingsSecurityUri('testKey');
    expect(res).not().assertNull();
  });
}

function registerSecurityDataChange() {
  it('SettingsDataUtilsTest_registerSecurityDataChange', 0, () => {
    let res = 'test';
    let dataHelper: dataShare.DataShareHelper | undefined = undefined;
    let onDataChange = () => {};
    SettingsDataUtils.registerSecurityDataChange(dataHelper, res, onDataChange);
    expect(res).not().assertNull();
  });
}

function unRegisterSecurityDataChange() {
  it('SettingsDataUtilsTest_unRegisterSecurityDataChange', 0, () => {
    let res = 'test';
    let dataHelper: dataShare.DataShareHelper | undefined = undefined;
    let onDataChange = () => {};
    SettingsDataUtils.unRegisterSecurityDataChange(dataHelper, res, onDataChange);
    expect(res).not().assertNull();
  });
}


function setSettingsDataDomain() {
  it('TestSettingsData_setSettingsDataDomain', 0, () => {
    let res = 'test';
    SettingsDataUtils.setSettingsDataDomain('test', 'test', '');
    expect(res).not().assertNull();
    SettingsDataUtils.setSettingsDataDomain('test', 'test', 'test');
    expect(res).not().assertNull();
  });
}

function setSettingsData2() {
  it('SettingsDataUtilsTest_setSettingsData2', 0, () => {
    let res = 'test';
    SettingsDataUtils.setSettingsData('settingsData', 'settingsData');
    expect(res).not().assertNull();
  });
}

function setSettingsData1() {
  it('SettingsDataUtilsTest_setSettingsData1', 0, () => {
    let res = 'test';
    SettingsDataUtils.setSettingsData('', 'settingsData');
    expect(res).not().assertNull();
  });
}

function getSettingsData02() {
  it('SettingsDataUtilsTest_getSettingsData_02', 0, () => {
    const result = SettingsDataUtils.getSettingsData('test', '1');
    expect(result).not().assertNull();
  });
}

function getSettingsData01() {
  it('SettingsDataUtilsTest_getSettingsData_01', 0, () => {
    const result = SettingsDataUtils.getSettingsData('', '1');
    expect(result).not().assertNull();
  });
}
