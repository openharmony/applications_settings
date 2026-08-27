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
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PADDING_0 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { HiSysAuxiliaryEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { TransitionAnimationsSettingsController } from './controller/TransitionAnimationsSettingsController';
import { DEFAULT_TEXT_STYLE } from './constant/Constants';
import { AccessibilityPageController } from './controller/AccessibilityPageController';
import { PageUrl } from '../../pages/PageUrl';

/* instrument ignore file */
function getSingleAnimationItems(): SettingItemModel[] {
  return [
    {
      id: 'transition_animation_switch',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.transition_animation_text'),
        style: DEFAULT_TEXT_STYLE
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: $r('app.string.load_more_card') },
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.ACCESSIBILITY_TRANSITION_ANIMATIONS_ENTRY,
      },
      compControl: new TransitionAnimationsSettingsController(),
    },
  ]
}

function initPage(): SettingPageModel {
  return {
    id: 'AccessibilityAdvancedVisualPage',
    url: NavEntryKey.ACCESSIBILITY_ADVANCED_VISUAL_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.accessibility_features'),
    layout: DeviceUtil.is2In1DevicePcType() ? { padding: { top: PADDING_0 } } : undefined,
    compControl: new AccessibilityPageController('advanceVisual',
      HiSysAuxiliaryEventGroup.ENTER_TRANSITION_ANIMATION_PAGE,
      'pageUrl: ' + PageUrl.ACCESSIBILITY_ADVANCE_VISUAL_PAGE_URL),
    hdsNavDestinationUx: false,
    groups: [
      {
        id: 'advancedVisual_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: getSingleAnimationItems(),
      },
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.ACCESSIBILITY_ADVANCED_VISUAL_ENTRY, {
  configGenerator: initPage,
});