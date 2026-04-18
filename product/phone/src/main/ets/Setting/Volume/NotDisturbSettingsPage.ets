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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import {
  ItemDetailType,
  ItemResultType,
  ItemType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { StorageEventConstant } from '@ohos/settings.storage/src/main/ets/constant/StorageConstant';
import { NotDisturbSettingController } from './controller/NotDisturbSettingController';
import { EnableNotDisturbToggleController } from './controller/EnableNotDisturbToggleController';
import { URL_VOLUME_TRUST_LIST_PAGE } from './NotDisturbTrustAppListPage';
import {
  NotDisturbAddTimeController as NotDisturbScheduledTimeGroupController
} from './controller/NotDisturbAddTimeGroupController';
import { IncomingCallSettingController } from './controller/IncomingCallSettingController';
import { NotDisturbNotificationMenuController } from './controller/NotDisturbNotificationMenuController';
import { IncomingCallUtils } from './utils/IncomingCallUtils';

const MAX_LENGTH: string = '10';

// 免打扰设置页面
function notDisturb(): SettingPageModel {
  return {
    id: 'not_disturb_mode',
    url: NavEntryKey.NOT_DISTURB_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: $r('app.string.not_disturb_title'),
    compControl: new NotDisturbSettingController(),
    groups: [
      {
        id: 'turn_on',
        type: GroupType.GROUP_TYPE_STANDARD,
        header: {
          id: 'scheduled',
          content: $r('app.string.not_disturb_tips_settings'),
        },
        items: [
          {
            id: 'turnon_notdisturb',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.not_disturb_turn_on_now') },
            result: {
              type: ItemResultType.RESULT_TYPE_TOGGLE,
              result: { state: true },
            },
            compControl: new EnableNotDisturbToggleController(),
          }
        ]
      },
      {
        id: 'timing_turnon',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        header: {
          id: 'scheduled',
          content: $r('app.string.not_disturb_regularly'),
        },
        compControl: new NotDisturbScheduledTimeGroupController(),
        layout: {
          dividerStyle: {
            startMargin: 8,
            endMargin: 8
          },
        },
      },
      {
        id: 'add_scheduled',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'add_scheduled_menu',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: {
              content: $r('app.string.not_disturb_scheduled'),
              style: {
                fontColor: $r('sys.color.font_emphasize')
              }
            },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: NavEntryKey.TIME_PERIOD_ENTRY,
            },
            enabled: false,
            compControl: {
              init: (param: CompCtrlParam) => {
                EventBus.getInstance().emit(StorageEventConstant.EVENT_NOTDISTURB_GROUP_INIT);
              },
              destroy: () => {},
            },
          },
        ],
        footer: {
          id: 'AddScheduledFooter',
          content: ResourceUtil.getNumberFormatStringSync($r('app.string.not_disturb_maximum_scheduled'), MAX_LENGTH)
        },
      },
      {
        id: 'notification_call',
        type: GroupType.GROUP_TYPE_STANDARD,
        header: {
          id: 'allow_disturb',
          content: $r('app.string.not_disturb_allow'),
        },
        items: [
          {
            id: 'notification',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.not_disturb_notification') },
            result: { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: '' } },
            compControl: new NotDisturbNotificationMenuController(),
            detail: {
              type: ItemDetailType.DETAIL_TYPE_MODAL,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: URL_VOLUME_TRUST_LIST_PAGE,
              sheetOptions: {
                detents: [SheetSize.LARGE],
                preferType: SheetType.CENTER,
                dragBar: true,
                maskColor: $r('sys.color.mask_fourth'),
                backgroundColor: $r('sys.color.comp_background_gray'),
                onDisappear: () => {
                }
              },
            },
          },
        ],
      },
      {
        id: 'incoming_call_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: 'incoming_call',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: { content: $r('app.string.not_disturb_call') },
            detail: {
              type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
              icon: $r('sys.symbol.chevron_right'),
              isSymbolIcon: true,
              destination: NavEntryKey.INCOMING_CALL_ENTRY,
            },
            result: {
              type: ItemResultType.RESULT_TYPE_TEXT,
              result: { content: '' },
            },
            compControl: new IncomingCallSettingController(),
            needHide: () => IncomingCallUtils.isVoiceCapabilityDisable(),
          }
        ]
      },
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.NOT_DISTURB_ENTRY, {
  configGenerator: notDisturb,
});