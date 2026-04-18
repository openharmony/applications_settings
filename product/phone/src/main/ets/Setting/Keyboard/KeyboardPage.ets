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
import { ItemDetailType, ItemType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { KeyboardImageComponent } from './view/KeyboardImageComponent';
import { KeyboardSettingsController } from './controller/KeyboardSettingsController';
import { KeyboardSettingsManager } from './KeyboardSettingsManager';

@Builder
function settingKeyboardImageBuilder(param: object): void {
  KeyboardImageComponent({ item: param as SettingBaseModel });
}

function customPage(): SettingPageModel {
  return {
    id: 'Keyboard',
    url: NavEntryKey.PAD_KEYBOARD_SETTINGS_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.keyboard'),
    groups: [
      {
        id: 'KeyboardImageGroup',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(settingKeyboardImageBuilder)
      },
      {
        id: 'KeyboardInfoGroup',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        visible: false,
        compControl: new KeyboardSettingsController()
      },
      {
        id: 'KeyboardAccessibilityGroup',
        type: GroupType.GROUP_TYPE_STANDARD,
        header: { id: 'KeyboardAccessibilityGroup.header', content: $r('app.string.keyboard_accessibility') },
        items: [
          {
            id: 'KeyboardShortcutHelperItem',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.shortcut_helper') },
            desc: { content: $r('app.string.shortcut_helper_summary') },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_CUSTOM,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              onItemClick: (component: SettingBaseModel) => {
                KeyboardSettingsManager.getInstance().sendShowShortcutPanel();
              }
            }
          }
        ]
      }
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.PAD_KEYBOARD_SETTINGS_ENTRY, {
  configGenerator: customPage
});