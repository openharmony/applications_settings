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
import { ItemResultType, ItemType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { KeyboardSettingsManager } from './KeyboardSettingsManager';

function customPage(): SettingPageModel {
  return {
    id: 'KeyBoardInformationSettings',
    url: NavEntryKey.PAD_KEYBOARD_INFORMATION,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.product_info'),
    groups: [
      {
        id: 'KeyboardKeyBoardInformationGroup',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [{
          id: 'KeyboardModel',
          type: ItemType.ITEM_TYPE_STANDARD,
          title: { content: $r('app.string.model') },
          result: {
            type: ItemResultType.RESULT_TYPE_TEXT,
            result: { content: KeyboardSettingsManager.getInstance().getModel() }
          }
        },
          {
            id: 'KeyboardSerialNumber',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.serial_number') },
            result: {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: { content: KeyboardSettingsManager.getInstance().getSerialId() }
            }
          },
          {
            id: 'KeyboardHardwareVersion',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.hardware_version') },
            result: {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: { content: KeyboardSettingsManager.getInstance().getHardwareVersion() }
            }
          },
          {
            id: 'KeyboardSoftwareVersion',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.firmware_version') },
            result: {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: { content: KeyboardSettingsManager.getInstance().getSoftwareVersion() }
            }
          }
        ]
      }
    ]
  }
}

PageLoader.load(NavEntryKey.PAD_KEYBOARD_INFORMATION, {
  configGenerator: customPage
});