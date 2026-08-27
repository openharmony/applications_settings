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
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { PADDING_0, PADDING_16 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ScreenReaderController } from './controller/ScreenReaderController';
import { ScreenReaderHelpGroupComponent } from './ScreenReaderHelpGroupComponent';
import { SCREEN_READER_SECURITY_NOTIFICATION_MODEL_PAGE } from './ScreenReaderSecurityNotificationModelPage';
import { ScreenReaderSwitchController } from './controller/ScreenReaderSwitchController';
import { HiSysAccessibilityEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DEFAULT_TEXT_STYLE, SCREEN_READER_SWITCH } from '../constant/Constants';

/* instrument ignore file */
const TAG: string = 'operationSettingPage : ';

@Builder
function screenReaderHelpGroupBuilder(param: object): void {
  ScreenReaderHelpGroupComponent();
}

function getSettingsGroupItems(): SettingItemModel[] {
  return [
    {
      id: 'screenreader_switch',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.screenreader'),
        style: DEFAULT_TEXT_STYLE
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TOGGLE,
        result: { state: false, disableAccessibility: true }
      },
      layout: { accessibilityGroup: true },
      compControl: new ScreenReaderSwitchController(),
    },
    {
      id: 'screen_reader_more_settings_entry',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.screenreader_more_settings'),
        style: DEFAULT_TEXT_STYLE
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.SCREEN_READER_MORE_SETTINGS_ENTRY,
      },
    }
  ]
}

function screenReaderMainPage(): SettingPageModel {
  return {
    id: 'AccessibilityScreenReaderSettings',
    url: NavEntryKey.ACCESSIBILITY_SCREEN_READER_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.screenreader'),
    hdsNavDestinationUx: false,
    layout: {
      padding: {
        top: PADDING_0,
      }
    },
    compControl: new ScreenReaderController(),
    fixedGroups: [
      {
        id: 'SecurityNotificationGroup',
        type: GroupType.GROUP_TYPE_STANDARD,
        visible: false,
        items: [
          {
            id: 'SecurityNotificationModel',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: '' },
            visible: true,
            result: {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: {
                content: '',
              }
            },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_MODAL,
              icon: '',
              destination: SCREEN_READER_SECURITY_NOTIFICATION_MODEL_PAGE,
              sheetOptions: {
                height: SheetSize.FIT_CONTENT,
                preferType: SheetType.CENTER,
                dragBar: false,
                showClose: true,
                title: { title: $r('app.string.screenreader_is_sure_open') },
                maskColor: $r('sys.color.mask_fourth'),
                backgroundColor: $r('app.color.component_ultra_thick_panel'),
                onWillDismiss: (action: DismissSheetAction) => {
                  EventBus.getInstance().emit(SCREEN_READER_SWITCH, false);
                  if (action.reason === DismissReason.CLOSE_BUTTON) {
                    LogUtil.info(`${TAG} security notification page click close button`);
                    HiSysEventUtil.abilityReportDefaultBehaviorEventByUE(
                      HiSysAccessibilityEventGroup.CLICK_SELECT_FUNCTION, '', 'RefuseOpen');
                  }
                },
              }
            }
          }
        ],
      }
    ],
    groups: [
      {
        id: 'screenreader_switch_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: getSettingsGroupItems(),
        layout: {
          margin: {
            top: PADDING_16
          }
        },
      },
      {
        id: 'screenreader_group_custom',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(screenReaderHelpGroupBuilder),
      },
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.ACCESSIBILITY_SCREEN_READER_ENTRY, {
  configGenerator: screenReaderMainPage,
});