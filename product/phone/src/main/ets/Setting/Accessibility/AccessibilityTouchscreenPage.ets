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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { PADDING_0, PADDING_16 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { DisplayUtils, SheetDialogStyle } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingIconType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { IgnoreRepeatedTouchesController } from './controller/IgnoreRepeatTouchesController';
import { TouchDurationTypeController } from './controller/TouchDurationTypeController';
import { TouchscreenPageController } from './controller/TouchscreenPageController';
import { TOUCH_DURATION_TYPES_ARRAY, SCREEN_HEIGHT_RATE, DEFAULT_TEXT_STYLE } from './constant/Constants';
import { IGNORE_REPEATED_TIME_SELECT_MODEL_PAGE } from './IgnoreRepeatedTimeSelectModelPage';
import { IGNORE_REPEATED_EXPERIMENT_MODEL_PAGE } from './IgnoreRepeatedExperimentModelPage';

/* instrument ignore file */
const TAG: string = 'TouchScreenPage : ';

function getTouchDurationItems(): SettingItemModel[] {
  let touchDuration = new TouchDurationTypeController();
  return [
    {
      id: 'touch_duration_select',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.touch_duration'),
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
        menu: {
          items: TOUCH_DURATION_TYPES_ARRAY,
          selectIcon: $r('app.media.ic_selected_ok'),
          onSelected: (index) => {
            LogUtil.info(`${TAG} onSelect touchscreen index: ${index}`);
            TouchDurationTypeController.updateTouchScreenType(index);
          },
          defaultFocus: TouchDurationTypeController.touchDurationType,
        },
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: '',
          style: DEFAULT_TEXT_STYLE
        },
      },
      compControl: touchDuration,
    }
  ]
}

function getRepeatedTouchesItems(): SettingItemModel[] {
  return [
    {
      id: 'ignore_repeated_touches_switch',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.ignore_repeated_touches'),
        style: DEFAULT_TEXT_STYLE
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_MODAL,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        visible: Visibility.Visible,
        destination: IGNORE_REPEATED_TIME_SELECT_MODEL_PAGE,
        sheetOptions: {
          backgroundColor: $r('app.color.component_ultra_thick_panel'),
          blurStyle: DeviceUtil.isDevicePc() ? BlurStyle.COMPONENT_ULTRA_THICK : BlurStyle.NONE,
          height: DisplayUtils.getSheetStyle() === SheetDialogStyle.BOTTOM_DIALOG_STYLE ?
            SheetSize.LARGE : DisplayUtils.getScreenHeight() * SCREEN_HEIGHT_RATE,
          detents: [DisplayUtils.getSheetStyle() === SheetDialogStyle.BOTTOM_DIALOG_STYLE ?
            SheetSize.LARGE : DisplayUtils.getScreenHeight() * SCREEN_HEIGHT_RATE],
          dragBar: false,
          preferType: SheetType.CENTER,
          showClose: true,
          title: { title: $r('app.string.ignore_repeated_touches') },
          maskColor: $r('sys.color.mask_fourth')
        }
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: '',
        }
      },
      compControl: new IgnoreRepeatedTouchesController(),
    },
  ]
}

function touchscreenPage(): SettingPageModel {
  return {
    id: 'AccessibilityTouchscreenPage',
    url: NavEntryKey.ACCESSIBILITY_TOUCHSCREEN_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.touchscreen_settings'),
    hdsNavDestinationUx: false,
    compControl: new TouchscreenPageController(),
    layout: {
      padding: {
        top: PADDING_0,
      }
    },
    fixedGroups: [
      {
        id: 'ignore_repeated_experiment_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        visible: false,
        items: [
          {
            id: 'ignoreExperimentModel',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: '' },
            visible: true,
            detail: {
              type: ItemDetailType.DETAIL_TYPE_MODAL,
              icon: '',
              destination: IGNORE_REPEATED_EXPERIMENT_MODEL_PAGE,
              sheetOptions: {
                height: DisplayUtils.getSheetStyle() === SheetDialogStyle.BOTTOM_DIALOG_STYLE ?
                  SheetSize.LARGE : DisplayUtils.getScreenHeight() * SCREEN_HEIGHT_RATE,
                detents: [DisplayUtils.getSheetStyle() === SheetDialogStyle.BOTTOM_DIALOG_STYLE ?
                  SheetSize.LARGE : DisplayUtils.getScreenHeight() * SCREEN_HEIGHT_RATE],
                blurStyle: DeviceUtil.isDevicePc() ? BlurStyle.COMPONENT_ULTRA_THICK : BlurStyle.NONE,
                preferType: SheetType.CENTER,
                dragBar: false,
                showClose: true,
                title: { title: $r('app.string.ignore_repeated_touches') },
                maskColor: $r('sys.color.mask_fourth'),
                backgroundColor: $r('app.color.component_ultra_thick_panel')
              }
            }
          }
        ],
      }
    ],
    groups: [
      {
        id: 'touch_duration_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: getTouchDurationItems(),
        layout: {
          margin: {
            top: PADDING_16
          }
        },
      },
      {
        id: 'ignore_repeated_touches_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: getRepeatedTouchesItems(),
      }
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.ACCESSIBILITY_TOUCHSCREEN_ENTRY, {
  configGenerator: touchscreenPage,
});