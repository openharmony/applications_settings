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
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { StorageCleanupAllCardBuilder } from '@ohos/settings.storage/src/main/ets/components/StorageCleanupAllCard';
import { MoreCardPageControl } from './controller/MoreCardPageController';

function customPage(): SettingPageModel {
  return {
    id: 'MoreReCard',
    url: NavEntryKey.STORAGE_MORE_CARD,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.load_more_data'),
    compControl: new MoreCardPageControl(),
    groups: [
      {
        id: 'storageCleanupCardGroup4',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(StorageCleanupAllCardBuilder),
        visible: true
      },
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.STORAGE_MORE_CARD, {
  configGenerator: customPage,
});