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
import {
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PADDING_0, PADDING_24 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { InvertColorSwitchController } from './controller/InvertColorSwitchController';
import { AccessibilityCanvasComponent } from './view/AccessibilityCanvasComponent';
import { AccessibilityPageController } from './controller/AccessibilityPageController';
import { DEFAULT_TEXT_STYLE } from './constant/Constants';
import { HiSysAuxiliaryEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { PageUrl } from '../../pages/PageUrl';

@Builder
function invertColorImageGroupBuilder(param: object): void {
  AccessibilityCanvasComponent(
    {
      tag: 'invertColorImageGroupBuilder: ',
      dataPath: 'resources/rawfile/accessibility_invert_color_phone.json',
      title: 'app.string.invert_color',
      summary: 'app.string.invert_color_reminder',
    }
  );
}

function getInvertColorSwitchItems(): SettingItemModel[] {
  return [
    {
      id: 'single_invert_color_switch',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.invert_color'),
        style: DEFAULT_TEXT_STYLE
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: false },
      },
      compControl: new InvertColorSwitchController(),
    }
  ]
}

function initPage(): SettingPageModel {
  return {
    id: 'AccessibilityInvertColorPage',
    url: NavEntryKey.ACCESSIBILITY_INVERT_COLOR_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.invert_color'),
    hdsNavDestinationUx: false,
    compControl: new AccessibilityPageController('InvertColorPage',
      HiSysAuxiliaryEventGroup.ENTER_INVERT_COLOR_PAGE,
      'pageUrl: ' + PageUrl.ACCESSIBILITY_INVERT_COLOR_PAGE_URL),
    layout: {
      padding: {
        top: PADDING_0,
      }
    },
    groups: [
      {
        id: 'invert_color_image_group',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(invertColorImageGroupBuilder),
      },
      {
        id: 'single_invert_color_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: getInvertColorSwitchItems(),
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
PageLoader.load(NavEntryKey.ACCESSIBILITY_INVERT_COLOR_ENTRY, {
  configGenerator: initPage,
});