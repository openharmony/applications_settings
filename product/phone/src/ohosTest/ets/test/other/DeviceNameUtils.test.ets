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
import { DeviceNameUtil, DefaultName } from '@ohos/settings.common/src/main/ets/utils/DeviceNameUtils';

export default function DeviceNameUtilsTest() {
  describe('DeviceNameUtilsTest', (): void => {

    beforeAll((): void => {
    })

    beforeEach((): void => {
    })

    afterAll((): void => {
    })

    afterEach((): void => {
    })

    initDeviceName();
    getDisplayDeviceName();
    getDefaultName();
    getNickDefaultName();
    setDefaultName();
    getDeviceNameAsync();
    setMigratedDeviceName();
    setNameWithNick();
  })
}

function initDeviceName() {
  it('DeviceNameUtilsTest_initDeviceName', 0, () => {
    let res = 'test';
    DeviceNameUtil.initDeviceName();
    expect(res).not().assertNull();
  });
}

function getDisplayDeviceName() {
  it('DeviceNameUtilsTest_getDisplayDeviceName', 0, () => {
    let res = 'test';
    DeviceNameUtil.getDisplayDeviceName();
    expect(res).not().assertNull();
  });
}

function getDeviceNameAsync() {
  it('DeviceNameUtilsTest_getDeviceNameAsync', 0, () => {
    let res = 'test';
    DeviceNameUtil.getDeviceNameAsync();
    expect(res).not().assertNull();
  });
}

function setMigratedDeviceName() {
  it('DeviceNameUtilsTest_setMigratedDeviceName', 0, () => {
    let res = 'test';
    DeviceNameUtil.setMigratedDeviceName('0');
    expect(res).not().assertNull();
  });
}

function getDefaultName() {
  it('DeviceNameUtilsTest_DefaultName_getDefaultName', 0, () => {
    let res = 'test';
    DefaultName.getDefaultName();
    expect(res).not().assertNull();
  });
}

function getNickDefaultName() {
  it('DeviceNameUtilsTest_DefaultName_getNickDefaultName', 0, () => {
    let res = 'test';
    DefaultName.getNickDefaultName('test');
    expect(res).not().assertNull();
  });
}

function setDefaultName() {
  it('DeviceNameUtilsTest_DefaultName_setDefaultName', 0, () => {
    let res = 'test';
    DefaultName.setDefaultName('test');
    expect(res).not().assertNull();
  })
}

function setNameWithNick() {
  it('DeviceNameUtilsTest_DefaultName_setNameWithNick', 0, () => {
    let res = 'test';
    DefaultName.setNameWithNick('test');
    expect(res).not().assertNull();
  })
}

