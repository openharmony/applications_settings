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
  it
} from '@ohos/hypium';
import { Response } from '@ohos/settings.common/src/main/ets/constant/Response';
import { CallMessage } from '@ohos/settings.common/src/main/ets/stub/BaseServiceStub';
import { RdbStoreInitService } from '../../../../../Index';
import { TestUtil } from '../TestUtil';

const TAG: string = 'RdbStoreInitServiceTest: ';

export default function RdbStoreInitServiceTest() {
  describe('RdbStoreInitServiceTest', () => {
    beforeAll(async () => {
      TestUtil.startSettingsAbility(TAG);
    });

    afterAll(async () => {
      TestUtil.clearSettings();
    });

    /*
    * @tc.number: initRdbService
    * @tc.name: 数据库初始化数据服务.
    * @tc.type: 0 || TestType.FUNCTION  || Level.LEVEL0
    * @tc.desc: 数据库初始化数据服务.
    */
    it('initRdbService', 0, async () => {
      let rdbInitService: RdbStoreInitService = new RdbStoreInitService();
      let result = await rdbInitService.onCall(JSON.stringify(''));
      expect(result === Response.INVALID_METHOD).assertTrue();

      let message: CallMessage = { method: 'initSearchData' };
      result = await rdbInitService.onCall(JSON.stringify(message));
      expect(result === Response.SUCCESS).assertTrue();
    })
  })
}