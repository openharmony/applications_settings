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


import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { appGroupHeaderBuilder } from '@ohos/settings.storage/src/main/ets/components/AppGroupHeaderComponent';
import { dataPanelBuilder } from '@ohos/settings.storage/src/main/ets/components/DataPanelComponent';
import { AppGroupControl } from '@ohos/settings.storage/src/main/ets/controller/AppGroupContorller';
import { BackupDataGroupController } from './controller/BackupDataGroupController';
import { StorageControl } from './controller/StorageController';
import {
  StorageCleanupCardCustomBuilder
} from '@ohos/settings.storage/src/main/ets/components/StorageCleanupCardCustom';

function customPage(): SettingPageModel {
  return {
    id: 'Storage',
    url: NavEntryKey.STORAGE_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.app_info_storage_title'),
    compControl: new StorageControl(),
    hdsNavDestinationUx: false,
    groups: [
      {
        id: 'dataPanelGroup',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'dataPanel',
            type: ItemType.ITEM_TYPE_CUSTOM,
            builder: wrapBuilder(dataPanelBuilder),
          }
        ],
      },
      {
        id: 'storageCleanupCardGroup3',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(StorageCleanupCardCustomBuilder),
        visible: true
      },
      {
        id: 'AppGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
        header: {
          id: 'AppGroupHeader',
          content: $r('app.string.storage_app_data_size'),
          builder: wrapBuilder(appGroupHeaderBuilder),
        },
        compControl: new AppGroupControl(),
      },
      {
        id: 'SystemDataGroup',
        type: GroupType.GROUP_TYPE_STANDARD,
        header: { id: 'SystemDataHeader', content: $r('app.string.storage_system_data_header') },
        items: [
          ...getSysItems(),
        ],
      },
      {
        id: 'OtherDataGroup',
        type: GroupType.GROUP_TYPE_STANDARD,
        header: { id: 'OtherDataHeader', content: $r('app.string.storage_other_data_header') },
        footer: {
          id: 'OtherDataFooter',
          content: $r('app.string.storage_other_data_footer')
        },
        items: [
          {
            id: 'OtherSystemResource',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.storage_system_data_other_system_resources') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } }
          }
        ],
      },
      {
        id: 'BackupDataGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        visible: true,
        compControl: new BackupDataGroupController()
      },
    ]
  }
}

function getSysItems(): SettingItemModel[] {
  return [
    {
      id: 'systemSizeNumber',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.storage_system_data_system') },
      result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } }
    }
  ]
}

// 页面配置导入
PageLoader.load(NavEntryKey.STORAGE_ENTRY, {
  configGenerator: customPage,
});