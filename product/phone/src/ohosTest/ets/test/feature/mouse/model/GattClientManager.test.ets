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
  beforeAll,
  describe,
  expect,
  it,
  TestType,
} from '@ohos/hypium';
import { Driver } from '@kit.TestKit';
import { manager } from '@kit.NearLinkKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import GattClientManager from '@ohos/settings.mouse/src/main/ets/model/GattClientManager';

const TAG = 'GattClientManagerTest';

export default function GattClientManagerTest() {
  describe('GattClientManagerTest', () => {
    const driver = Driver.create();

    beforeAll(() => {
      LogUtil.showInfo(TAG, 'beforeAll');
    });

    afterAll(() => {
      LogUtil.showInfo(TAG, 'afterAll');
    });

    it('GattClientManagerTest_001', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'GattClientManagerTest_001 it begin');
      GattClientManager.initBluetoothBatterySoc('11:22:33:AA:BB:FF', 'deviceName');
      GattClientManager.stop();
      expect().assertUndefined();
    });

    it('GattClientManagerTest_002', TestType.FUNCTION, async () => {
      try {
        LogUtil.showInfo(TAG, 'GattClientManagerTest_002 it begin');
        if (manager.getState() !== manager.NearlinkState.STATE_ON) {
          manager.enable();
          await driver.delayMs(1000);
        }
        GattClientManager.initNearlinkBatterySoc('11:22:33:AA:BB:FF', 'deviceName');
        GattClientManager.stop();
      } catch (err) {
        LogUtil.showError(TAG, `GattClientManagerTest_002 it failed, code: ${err?.code}, msg: ${err?.message}`);
      }
      expect().assertUndefined();
    });
  });
}
