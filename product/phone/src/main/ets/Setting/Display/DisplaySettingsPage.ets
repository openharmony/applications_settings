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
import { PenglaiUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingDialogModel,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { PADDING_0, PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { DarkModeController } from '@ohos/settings.display/src/main/ets/controller/darkmode/DarkModeController';
import { DisplaySettingController } from './controller/DisplaySettingController';
import { DormancyDialogComponent } from './view/DormancyDialogComponent';
import { BrightnessComponent } from './view/BrightnessComponent';
import { DarkModeCardComponent } from './view/DarkModeCardComponent';

@Builder
function brightnessGroupBuilder(param: object): void {
  BrightnessComponent({ item: param as SettingBaseModel });
}

@Builder
function darkModeCardComponentBuilder(param: object): void {
  DarkModeCardComponent();
}

function displayPage(): SettingPageModel {
  return {
    id: 'Display',
    url: NavEntryKey.DISPLAY_ENTRY,
    type: PageType.PAGE_TYPE_DYNAMIC,
    title: $r('app.string.display_settings_title'),
    compControl: new DisplaySettingController(),
    hdsNavDestinationUx: false,
    layout: {
      padding: {
        top: PADDING_0,
      }
    },
    header: {
      id: 'display_setting_header',
      content: $r('app.string.display_model'),
      style: {
        padding: {
          top: PADDING_0,
          start: PADDING_8,
          bottom: PADDING_8,
        },
        fontWeight: FontWeight.Medium,
      }
    },
    groups: [
      {
        id: 'display_setting',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'dark_mode_card',
            type: ItemType.ITEM_TYPE_CUSTOM,
            builder: wrapBuilder(darkModeCardComponentBuilder),
          },
          {
            id: 'dark_mode',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.dark_mode') },
            result: {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: { content: '' },
            },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: NavEntryKey.DARK_SETTINGS,
            },
            compControl: new DarkModeController(),
          },
        ],
        visible: !PenglaiUtil.isPengLaiModeOpen()
      },
      {
        id: 'brightness',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'brightness_group_mode',
            type: ItemType.ITEM_TYPE_CUSTOM,
            builder: wrapBuilder(brightnessGroupBuilder),
          }
        ]
      }
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.DISPLAY_ENTRY, {
  configGenerator: displayPage,
});