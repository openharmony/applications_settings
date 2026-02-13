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

import storage from '@ohos.file.storageStatistics';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { MenuGroupController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { StorageSizeUtil } from '../utils/StorageSizeUtil';
import { StorageData } from './CircleController';

@Observed
export class StorageItemController extends MenuGroupController {
  public tag: string = 'StorageItemController : ';
  private static readonly STORAGE_CIRCLE: string = 'key_storage_panel';
  private static readonly KEY_IMAGE: string = 'key_image_menu';
  private static readonly KEY_VIDEO: string = 'key_video_menu';
  private static readonly KEY_AUDIO: string = 'key_audio_menu';
  private static readonly KEY_DOC: string = 'key_doc_menu';
  private static readonly KEY_APP: string = 'key_app_menu';
  private static readonly KEY_OTHER: string = 'key_other_menu';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static CreateStorageItemController(menu: SettingsBaseMenu): Controller {
    return new StorageItemController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    this.isRespondTouchEvent = false;
  }

  refreshStorageData(data: StorageData) {
    LogUtil.error(`{$this.tag} receive data ${this.menu.key}`);
    let stats = data.detail as storage.StorageStats;
    let otherStorage = data.otherStorage as number;
    switch (this.menu.key) {
      case StorageItemController.KEY_IMAGE:
        this.menu.state = StorageSizeUtil.formatData(stats.image, 2);
        break;
      case StorageItemController.KEY_VIDEO:
        this.menu.state = StorageSizeUtil.formatData(stats.video, 2);
        break;
      case StorageItemController.KEY_AUDIO:
        this.menu.state = StorageSizeUtil.formatData(stats.audio, 2);
        break;
      case StorageItemController.KEY_DOC:
        this.menu.state = StorageSizeUtil.formatData(stats.file, 2);
        break;
      case StorageItemController.KEY_APP:
        this.menu.state = StorageSizeUtil.formatData(stats.app, 2);
        break;
      case StorageItemController.KEY_OTHER:
        this.menu.state = StorageSizeUtil.formatData(otherStorage, 2);
        break;
      default:
        break;
    }
  }

  registerDataChange() {
    this.registerControllerDataChange(StorageItemController.STORAGE_CIRCLE);
  }

  onDataChange(fromKey: string, data: StorageData) {
    switch (fromKey) {
      case StorageItemController.STORAGE_CIRCLE:
        this.refreshStorageData(data);
        break;
      default:
        break;
    }
  }

  unRegisterDataChange() {
    this.unRegisterControllerDataChange(StorageItemController.STORAGE_CIRCLE);
  }
}



