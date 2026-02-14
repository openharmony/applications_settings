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
import { describe, it, expect } from '@ohos/hypium'
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { CircleController } from '@ohos/settings.storage/src/main/ets/controller/CircleController';
import storage from '@ohos.file.storageStatistics';

export default function CircleControllerTest() {
  describe('CircleControllerTest', () => {
    it('CircleControllerTest_001', 0, async (done: Function) => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu();
      let circleC: CircleController = new CircleController(menu);
      await circleC.initial();
      expect(circleC != null).assertTrue();
      done();
    })
    it('CircleControllerTest_002', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu();
      let circleC: CircleController = new CircleController(menu);
      circleC.menu.key = 'testKey';
      expect(circleC.getObserverKey()).assertEqual('testKey');
    })
    it('CircleControllerTest_002_01', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu();
      let circleC: CircleController = new CircleController(menu);
      expect(circleC.getObserverKey()).assertEqual('');
    })
    it('CircleControllerTest_003', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu();
      let circleC: CircleController = new CircleController(menu);
      (circleC as object)['showWhenAllDataReady']();
      expect(circleC != null).assertTrue();
    })
    it('CircleControllerTest_003_01', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu();
      let circleC: CircleController = new CircleController(menu);
      let storageDetail: storage.StorageStats = {
        total: 1000,
        audio: 0,
        video: 0,
        image: 0,
        file: 0,
        app: 0
      };
      (circleC as object)['freeBytesNumber'] = 999;
      (circleC as object)['storageDetail'] = storageDetail;
      (circleC as object)['showWhenAllDataReady']();
      expect(circleC != null).assertTrue();
    })
    it('CircleControllerTest_003_02', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu();
      let circleC: CircleController = new CircleController(menu);
      let storageDetail: storage.StorageStats = {
        total: 1,
        audio: 0,
        video: 0,
        image: 0,
        file: 0,
        app: 0
      };
      (circleC as object)['freeBytesNumber'] = 0;
      (circleC as object)['storageDetail'] = storageDetail;
      (circleC as object)['showWhenAllDataReady']();
      expect(circleC != null).assertTrue();
    })
  })
}