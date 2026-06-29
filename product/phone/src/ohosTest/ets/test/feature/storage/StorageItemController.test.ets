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
import { StorageData } from '@ohos/settings.storage/src/main/ets/controller/CircleController';
import { StorageItemController } from '@ohos/settings.storage/src/main/ets/controller/StorageItemController';
import storage from '@ohos.file.storageStatistics';

export default function StorageItemControllerTest() {
  describe('StorageItemControllerTest', () => {
    let menu: SettingsBaseMenu = new SettingsBaseMenu();
    let detail: storage.StorageStats = {
      total: 0,
      audio: 0,
      video: 0,
      image: 0,
      file: 0,
      app: 0
    };
    let data: StorageData = {
      detail: detail,
      otherStorage: 0
    };
    // onDataChange
    it('StorageItemControllerTest_001', 0, () => {
      let storageItemC: StorageItemController = new StorageItemController(menu);
      const KEY = 'key_test';
      storageItemC.onDataChange(KEY, data);
      expect(storageItemC != null).assertTrue();
    })
    it('StorageItemControllerTest_001_01', 0, () => {
      let menu: SettingsBaseMenu = new SettingsBaseMenu();
      let storageItemC: StorageItemController = new StorageItemController(menu);
      const KEY = 'key_storage_panel';
      storageItemC.onDataChange(KEY, data);
      expect(storageItemC != null).assertTrue();
    })
    // refreshStorageData
    it('StorageItemControllerTest_002', 0, () => {
      const KEY_ARR =
        ['key_image_menu', 'key_video_menu', 'key_audio_menu', 'key_doc_menu', 'key_app_menu', 'key_other_menu'];
      KEY_ARR.forEach(key => {
        menu.key = key;
        let storageItemC: StorageItemController = new StorageItemController(menu);
        storageItemC.refreshStorageData(data);
        expect(storageItemC.menu.key).assertEqual(key);
      });
    })
  })
}