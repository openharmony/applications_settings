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
import { CompCtrlParam, SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType, ItemType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  FlashReminderPageController,
  FlashReminderSwitchController
} from './controller/FlashReminderPageController';
import { AddReminderFunctionGroupController } from './controller/FlashReminderGroupController';
import { AccessibilityFlashReminderModel } from './utils/AccessibilityCommonModel';
import { DEFAULT_TEXT_STYLE } from './constant/Constants';

function initPage(): SettingPageModel {
  let flashReminderPageController: FlashReminderPageController = new FlashReminderPageController();
  let flashReminderSwitchController: FlashReminderSwitchController = new FlashReminderSwitchController();
  let isSwitchOpen: boolean = AccessibilityFlashReminderModel.getInstance().isSwitchOpen();
  let addReminderGroupController: AddReminderFunctionGroupController =
    new AddReminderFunctionGroupController(isSwitchOpen);
  return {
    id: 'flashReminderSettings',
    url: NavEntryKey.ACCESSIBILITY_FLASH_REMINDER_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.flash_reminder_title'),
    hdsNavDestinationUx: false,
    compControl: {
      init: (compParam: CompCtrlParam) => {
        flashReminderPageController.init(compParam);
      },
      destroy: () => {
        flashReminderPageController.destroy();
      },
      onPageShow: (component: SettingBaseModel) => {
        flashReminderPageController.onPageShow();
        flashReminderSwitchController.onPageShow();
        addReminderGroupController.onPageShow();
      }
    },
    groups: [
      {
        id: 'flash_reminder_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        visible: true,
        items: [
          {
            id: 'flash_reminder_item',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: {
              content: $r('app.string.flash_reminder_title'),
              style: DEFAULT_TEXT_STYLE
            },
            result: {
              type: ItemResultType.RESULT_TYPE_TOGGLE,
                result: { state: isSwitchOpen },
            },
            compControl: flashReminderSwitchController,
          },
        ],
        footer: {
          id: 'flash_reminder_desc',
          content: $r('app.string.flash_reminder_desc'),
          style: DEFAULT_TEXT_STYLE
        }
      },
      {
        id: 'reminder_function_group',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        visible: isSwitchOpen,
        header: {
          id: 'flash_reminder_header',
          content: $r('app.string.flash_reminder_header'),
        },
        compControl: addReminderGroupController,
      },
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.ACCESSIBILITY_FLASH_REMINDER_ENTRY, {
  configGenerator: initPage,
});