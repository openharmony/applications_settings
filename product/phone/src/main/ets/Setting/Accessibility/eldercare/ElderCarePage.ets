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
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ItemResultType, ItemType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { ElderCareUtils } from '@ohos/settings.accessibility/src/main/ets/ElderCareUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PADDING_0 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { ElderCarePageController } from './controller/ElderCarePageController';
import { ElderCareSwitchController } from './controller/ElderModeSwitchController';
import { DEFAULT_TEXT_STYLE } from '../constant/Constants';
import {
  elderCareGuidePageButtonBuilder,
  elderCareGuidePageContentBuilder,
  elderCarePromptTextBuilder,
  enlargeDisplayBuilder,
} from './view/ElderCareCustomBuilder';

/* instrument ignore file */
const TAG: string = 'ElderCarePage';

function elderCarePage(): SettingPageModel {
  let elderCareHasEnabled = SettingsDataUtils.getSecureValue(ElderCareUtils.ELDER_CARE_HAS_ENABLED, 'false') === 'true';
  LogUtil.info(`${TAG} elder care already turned on: ${elderCareHasEnabled}`);
  if (!elderCareHasEnabled && !ElderCareUtils.isElderCareOn()) {
    return {
      id: 'ElderCareGuide',
      url: NavEntryKey.ACCESSIBILITY_ELDER_CARE_ENTRY,
      type: PageType.PAGE_TYPE_STANDARD,
      title: ResourceUtil.getStringSync($r('app.string.elder_care_title')),
      hdsNavDestinationUx: false,
      layout: {
        padding: {
          top: PADDING_0,
        }
      },
      groups: [
        {
          id: 'guidePageContent',
          type: GroupType.GROUP_TYPE_CUSTOM,
          builder: wrapBuilder(elderCareGuidePageContentBuilder),
        },
      ],
      // 底部开启关怀模式按钮
      stickBottomContent: {
        id: 'elder_care_guide_start_button',
        builder: wrapBuilder(elderCareGuidePageButtonBuilder)
      }
    }
  } else {
    return {
      id: 'ElderCare',
      url: NavEntryKey.ACCESSIBILITY_ELDER_CARE_ENTRY,
      type: PageType.PAGE_TYPE_STANDARD,
      title: ResourceUtil.getStringSync($r('app.string.elder_care_title')),
      hdsNavDestinationUx: false,
      compControl: new ElderCarePageController(),
      groups: [
        // 关怀模式开关
        {
          id: 'elder_care_switch_group',
          type: GroupType.GROUP_TYPE_STANDARD,
          items: [
            {
              id: 'elder_care_switch',
              type: ItemType.ITEM_TYPE_STANDARD,
              title: {
                content: $r('app.string.elder_care_title'),
                style: {
                  textOverflow: TextOverflow.None,
                  wordBreak: WordBreak.HYPHENATION
                }
              },
              result: {
                type: ItemResultType.RESULT_TYPE_TOGGLE,
                result: { state: true },
              },
              compControl: new ElderCareSwitchController(),
            },
          ],
          footer: {
            id: 'elder_care_switch_summary',
            builder: wrapBuilder(elderCarePromptTextBuilder),
            style: DEFAULT_TEXT_STYLE
          },
        },
        // 放大显示
        {
          id: 'enlarge_display_group',
          type: GroupType.GROUP_TYPE_CUSTOM,
          builder: wrapBuilder(enlargeDisplayBuilder),
        },
      ]
    }
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.ACCESSIBILITY_ELDER_CARE_ENTRY, {
  configGenerator: elderCarePage
});