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
import { AccessibilityCanvasComponent } from './view/AccessibilityCanvasComponent';
import { AccessibilityCommonModel } from './utils/AccessibilityCommonModel';
import {
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PADDING_0, PADDING_24 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { TransitionAnimationsController } from './controller/TransitionAnimationsController';
import { AccessibilityPageController } from './controller/AccessibilityPageController';
import { DEFAULT_TEXT_STYLE } from './constant/Constants';
import { HiSysAuxiliaryEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { PageUrl } from '../../pages/PageUrl';

@Builder
function animationImageGroupBuilder(param: object): void {
  AccessibilityCanvasComponent(
    {
      tag: 'animationImageGroupBuilder: ',
      dataPath: 'resources/rawfile/accessibility_transition_animations_phone.json',
      title: 'app.string.transition_animation_text',
      summary: 'app.string.transition_animations_reminder_detail',
    }
  );
}

function getSingleAnimationItems(): SettingItemModel[] {
  let isGrayed: boolean = AccessibilityCommonModel.isEnableRetail();
  return [
    {
      id: 'single_animation_switch',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.transition_animation_text'),
        style: DEFAULT_TEXT_STYLE
      },
      enabled: !isGrayed,
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: true },
      },
      compControl: new TransitionAnimationsController(),
    }
  ]
}

function initPage(): SettingPageModel {
  return {
    id: 'AccessibilityAnimationPage',
    url: NavEntryKey.ACCESSIBILITY_TRANSITION_ANIMATIONS_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.transition_animation_text'),
    hdsNavDestinationUx: false,
    compControl: new AccessibilityPageController('TransitionAnimationsPage',
      HiSysAuxiliaryEventGroup.ENTER_TRANSITION_ANIMATION_PAGE,
      'pageUrl: ' + PageUrl.ACCESSIBILITY_TRANSITION_ANIMATION_PAGE_URL),
    layout: {
      padding: {
        top: PADDING_0,
      }
    },
    groups: [
      {
        id: 'animation_image_group',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(animationImageGroupBuilder),
      },
      {
        id: 'single_animation_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: getSingleAnimationItems(),
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
PageLoader.load(NavEntryKey.ACCESSIBILITY_TRANSITION_ANIMATIONS_ENTRY, {
  configGenerator: initPage,
});