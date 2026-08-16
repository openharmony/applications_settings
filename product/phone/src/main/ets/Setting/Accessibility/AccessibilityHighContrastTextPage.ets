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
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { ItemResultType,
ItemType,
SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PADDING_0, PADDING_24 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { HighContrastTextSwitchController } from './controller/HighContrastTextSwitchController';
import { AccessibilityCanvasComponent } from './view/AccessibilityCanvasComponent';
import { AccessibilityPageController } from './controller/AccessibilityPageController';
import { DEFAULT_TEXT_STYLE } from './constant/Constants';
import { HiSysAuxiliaryEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { PageUrl } from '../../pages/PageUrl';

@Builder
function highContrastTextImageGroupBuilder(param: object): void {
  AccessibilityCanvasComponent(
    {
      tag: 'highContrastTextImageGroupBuilder: ',
      dataPath: 'resources/rawfile/accessibility_high_contrast_text_phone.json',
      title: 'app.string.highContrast_text',
      summary: 'app.string.highContrast_text_reminder',
    }
  );
}

function getHighContrastItems(): SettingItemModel[] {
  return [
    {
      id: 'single_high_contrast_text_switch',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.highContrast_text'),
        style: DEFAULT_TEXT_STYLE
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: false },
      },
      compControl: new HighContrastTextSwitchController(),
    }
  ]
}

function initPage(): SettingPageModel {
  return {
    id: 'AccessibilityHighContrastTextPage',
    url: NavEntryKey.ACCESSIBILITY_HIGH_CONTRAST_TEXT_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.highContrast_text'),
    hdsNavDestinationUx: false,
    compControl: new AccessibilityPageController('HighContrastTextPage',
      HiSysAuxiliaryEventGroup.ENTER_HIGH_CONTRAST_TEXT_PAGE,
      'pageUrl: ' + PageUrl.ACCESSIBILITY_HIGH_CONTRAST_TEXT_PAGE_URL),
    layout: {
      padding: {
        top: PADDING_0,
      }
    },
    groups: [
      {
        id: 'highContrastText_image_group',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(highContrastTextImageGroupBuilder),
      },
      {
        id: 'single_high_contrast_text_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: getHighContrastItems(),
        layout: {
          margin: {
            top: PADDING_24,
          }
        }
      },
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.ACCESSIBILITY_HIGH_CONTRAST_TEXT_ENTRY, {
  configGenerator: initPage,
});