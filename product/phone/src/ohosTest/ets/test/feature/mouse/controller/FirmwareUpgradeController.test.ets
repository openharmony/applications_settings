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
import { FirmwareUpgradeController } from '@ohos/settings.mouse/src/main/ets/controller/FirmwareUpgradeController';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG = 'FirmwareUpgradeControllerTest';

export default function FirmwareUpgradeControllerTest() {
  describe('FirmwareUpgradeControllerTest', () => {
    beforeAll(() => {
      LogUtil.showInfo(TAG, 'beforeAll');
    });

    afterAll(() => {
      LogUtil.showInfo(TAG, 'afterAll');
    });

    it('FirmwareUpgradeControllerTest_001', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'FirmwareUpgradeControllerTest_001 it begin');
      const instance = FirmwareUpgradeController.getInstances();
      expect(instance instanceof FirmwareUpgradeController).assertTrue();
    });

    it('FirmwareUpgradeControllerTest_002', TestType.FUNCTION, () => {
      LogUtil.showInfo(TAG, 'FirmwareUpgradeControllerTest_002 it begin');
      FirmwareUpgradeController.getInstances().init();
      FirmwareUpgradeController.getInstances().destroy();
      LogUtil.showInfo(TAG, 'FirmwareUpgradeControllerTest_002 it end');
    });
  });
}
