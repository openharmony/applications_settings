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
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  ItemDetailType,
  ItemType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';


function customPage(): SettingPageModel {
  return {
    id: 'LegalInfo',
    url: NavEntryKey.LEGAL_INFO_SETTING,
    type: PageType.PAGE_TYPE_STANDARD,
    title: ResourceUtil.getStringSync($r('app.string.legal_information')),
    groups: [
      {
        id: 'legal_information_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'app_open_source_statement_entry',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.open_source_show_title') },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: NavEntryKey.APP_OPEN_SOURCE_STATEMENT_ENTRY,
            }
          }
        ]
      }
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.LEGAL_INFO_SETTING, {
  configGenerator: customPage,
})