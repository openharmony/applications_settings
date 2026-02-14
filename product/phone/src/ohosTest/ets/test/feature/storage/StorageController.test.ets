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
import { describe, it, expect, MockKit, when } from '@ohos/hypium'
import storage from '@ohos.file.storageStatistics'
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil'
import { StorageControl } from '../../../../../main/ets/Setting/Storage/controller/StorageController'

export default function StorageControllerTest() {
  describe('StorageControllerTest', () => {
    it("StorageControllerTest_001", 0, () => {
      let storageC: StorageControl = new StorageControl();
      storageC.changeSysData();
      (storageC as object)['showWhenAllDataReady']();

      let storageDetail: storage.StorageStats = {
        total: 200,
        audio: 0,
        video: 0,
        image: 0,
        file: 0,
        app: 0
      };
      (storageC as object)['storageDetail'] = storageDetail;
      (storageC as object)['freeBytesNumber'] = 0;
      storageC.changeSysData();
      (storageC as object)['showWhenAllDataReady']();
      (storageC as object)['freeBytesNumber'] = 5;
      (storageC as object)['showWhenAllDataReady']();
      (storageC as object)['freeBytesNumber'] = 199;
      (storageC as object)['showWhenAllDataReady']();
      expect(storageC != null).assertTrue();
    })
    it("StorageControllerTest_002", 0, async (done: Function) => {
      let storageC: StorageControl = new StorageControl();
      await storageC.loadData();
      expect(storageC != null).assertTrue();
      done();
    })
    it("StorageControllerTest_002_01", 0, async (done: Function) => {
      let storageC: StorageControl = new StorageControl();
      let mocker: MockKit = new MockKit();
      let mockFun: Function = mocker.mockFunc(AccountUtil, AccountUtil.isCurrentPrivate);
      when(mockFun)().afterReturn(true);
      await storageC.loadData();
      mocker.clear(AccountUtil);
      expect(storageC != null).assertTrue();
      mocker.clear(AccountUtil);
      done();
    })
  })
}