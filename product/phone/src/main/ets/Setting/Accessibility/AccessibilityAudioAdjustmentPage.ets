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
import { SingleAudioSwitchController } from './controller/SingleAudioSwitchController';
import { SliderComponent } from './view/SliderComponent';
import { AudioAdjustmentContentComponent } from './view/AudioAdjustmentContentComponent';
import { DEFAULT_TEXT_STYLE } from './constant/Constants';
import { AccessibilityPageController } from './controller/AccessibilityPageController';
import { HiSysAuxiliaryEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { PageUrl } from '../../pages/PageUrl';

@Builder
function audioBalanceItemBuilder(param: object) {
  SliderComponent({
    tag: 'accessiblility_audio_balance',
    title: $r('app.string.audio_balance'),
    leftSummary: $r('app.string.left'),
    rightSummary: $r('app.string.right'),
  });
}

@Builder
function audioAdjustmentHelpGroupBuilder(param: object): void {
  AudioAdjustmentContentComponent();
}

function getSingleAudioItems(): SettingItemModel[] {
  return [
    {
      id: 'single_audio_switch',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.single_audio'),
        style: {
          textOverflow: TextOverflow.None,
          wordBreak: WordBreak.HYPHENATION
        }
      },
      desc: {
        content: $r('app.string.single_audio_reminder'),
        style: {
          textOverflow: TextOverflow.None,
          wordBreak: WordBreak.HYPHENATION
        }
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: false },
      },
      compControl: new SingleAudioSwitchController(),
    }
  ]
}

function getAudioBalanceItems(): SettingItemModel[] {
  return [
    {
      id: 'audio_balance_settings',
      type: ItemType.ITEM_TYPE_CUSTOM,
      title: {
        content: $r('app.string.single_audio'),
        style: DEFAULT_TEXT_STYLE
      },
      builder: wrapBuilder(audioBalanceItemBuilder),
    },
  ]
}

function initPage(): SettingPageModel {
  return {
    id: 'AccessibilityAudioAdjustmentPage',
    url: NavEntryKey.ACCESSIBILITY_AUDIO_ADJUSTMENT_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.audio_adjustment'),
    hdsNavDestinationUx: false,
    compControl: new AccessibilityPageController('AudioAdjustmentPage',
      HiSysAuxiliaryEventGroup.ENTER_AUDIO_ADJUSTMENT_PAGE,
      'pageUrl: ' + PageUrl.ACCESSIBILITY_AUDIO_ADJUSTMENT_PAGE_URL),
    groups: [
      {
        id: 'single_audio_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: getSingleAudioItems(),
      },
      {
        id: 'audio_balance_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: getAudioBalanceItems(),
        header: {
          id: 'audio_balance_header',
          content: $r('app.string.audio_balance')
        },
        footer: {
          id: 'audio_balance_group_suggestion',
          content: $r('app.string.audio_balance_suggestion'),
          style: DEFAULT_TEXT_STYLE
        }
      },
      {
        id: 'audio_balance_help_group_custom',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(audioAdjustmentHelpGroupBuilder),
      },
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.ACCESSIBILITY_AUDIO_ADJUSTMENT_ENTRY, {
  configGenerator: initPage,
});