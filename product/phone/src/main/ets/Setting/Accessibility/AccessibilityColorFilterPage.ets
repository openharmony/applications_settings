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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingIconType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { COLOR_FILTER_CORRECTION_MODE_ARRAY, DEFAULT_TEXT_STYLE } from './constant/Constants';
import { ColorFilterPageController } from './controller/ColorFilterPageController';
import { ColorFilterSwitchController } from './controller/ColorFilterSwitchController';
import { CorrectionModeController } from './controller/CorrectionModeController';

const TAG: string = 'colorFilterPage: ';

function colorFilterPage(): SettingPageModel {
  return {
    id: 'AccessibilityColorFilterSettings',
    url: NavEntryKey.ACCESSIBILITY_COLOR_FILTER_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.color_correction'),
    hdsNavDestinationUx: false,
    compControl: new ColorFilterPageController(),
    groups: [
      {
        id: 'select_color_filter_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'single_color_filter_switch',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: {
              content: $r('app.string.color_correction'),
              style: DEFAULT_TEXT_STYLE
            },
            result: {
              type: ItemResultType.RESULT_TYPE_TOGGLE,
              result: { state: false },
            },
            compControl: new ColorFilterSwitchController(),
          },
          {
            id: 'correction_mode_select',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: {
              content: $r('app.string.correction_mode'),
              style: DEFAULT_TEXT_STYLE
            },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_MENU,
              icon: $r('app.media.arrow_triangle_down_fill'),
              iconType: SettingIconType.ICON_TYPE_TIP,
              style: {
                width: 24,
                height: 24,
                fillColor: $r('sys.color.icon_tertiary'),
              },
              visible: Visibility.Visible,
              menu: {
                items: COLOR_FILTER_CORRECTION_MODE_ARRAY,
                selectIcon: $r('app.media.ic_selected_ok'),
                onSelected: (index) => {
                  LogUtil.info(`${TAG} onSelect color filter index: ${index}`);
                  CorrectionModeController.onMenuChange(index);
                },
                defaultFocus: CorrectionModeController.selectColorFilterType,
              }
            },
            result: {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: {
                content: '',
                style: DEFAULT_TEXT_STYLE
              },
            },
            enabled: CorrectionModeController.isColorFilterEnable(),
            compControl: new CorrectionModeController(),
          }
        ]
      },
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.ACCESSIBILITY_COLOR_FILTER_ENTRY, {
  configGenerator: colorFilterPage,
});