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
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import {
  HiSysAboutSystemSettingsEventGroup,
} from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { AccountUtil } from '@ohos/settings.common/src/main/ets/utils/AccountUtil';
import { MASK_OPACITY, FULL_OPACITY } from '@ohos/settings.common/src/main/ets/constant/ViewConstant';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { PenglaiUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { SystemPageMenuManager } from './controller/SystemPageMenuManager';
import { DeviceAndApplicationController } from './controller/DeviceAndApplicationController';
import { SystemPageControl } from './controller/SystemPageControl';
import { DeveloperGroupController } from './controller/DeveloperGroupController';
import { COVER_MODE, SIMPLE_COVER, SMART_COVER } from '../Display/Constant/Constant';

function systemPage(): SettingPageModel {
  let systemPageController = new SystemPageControl();
  return {
    id: 'System',
    url: NavEntryKey.SYSTEM_UPDATE_ENTRY,
    type: PageType.PAGE_TYPE_DYNAMIC,
    title: $r('app.string.system_title'),
    compControl: systemPageController,
    hdsNavDestinationUx: false,
    groups: []
  }
}

export function getFirstFrameGroups(): SettingGroupModel[] {
  let isPengLaiModeOpen:boolean = PenglaiUtil.isPengLaiModeOpen();
  if (isPengLaiModeOpen) {
    return [
      getTimeAndLanguageGroup(isPengLaiModeOpen),
      getEmergencyGroup(isPengLaiModeOpen),
      getDeveloperGroup()
    ];
  }
  if (DeviceUtil.is2In1Device()) {
    return [
      getNavigationGroup(),
      getTimeAndLanguageGroup(),
      getGestureGroup()
    ];
  }
  return [
    getNavigationGroup(),
    getTimeAndLanguageGroup(),
    getGestureGroup()
  ];
}

export function getSecondFrameGroups(): SettingGroupModel[] {
  return [
    // getApplicationAssistantGroup(),
    getDeviceAndApplicationGroup(),
    getEmergencyGroup(),
    getResetGroup(),
    getDeveloperGroup()
  ];
}

function getEmergencyGroup(isPengLaiModeOpen?: boolean): SettingGroupModel {
  return {
    id: 'emergency_group',
    type: GroupType.GROUP_TYPE_STANDARD,
    items: getEmergencyGroups(isPengLaiModeOpen)
  };
}

function getEmergencyGroups(isPengLaiModeOpen?: boolean): SettingItemModel[] {
  if (isPengLaiModeOpen) {
    return [
      getSosEmergencyItem(),
    ];
  }
  return [
    getSosEmergencyItem(),
  ]
}

/**
 * 获取系统导航组
 * @returns 系统导航组
 */
function getNavigationGroup(): SettingGroupModel {
  return {
    id: 'system_navigation',
    type: GroupType.GROUP_TYPE_STANDARD,
    items: [
      {
        id: 'ai_bar_settings',
        type: ItemType.ITEM_TYPE_STANDARD,
        title: { content: $r('app.string.system_navigation') },
        detail: {
          type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
          icon: $r('sys.symbol.chevron_right'),
          isSymbolIcon: true,
          destination: NavEntryKey.SYSTEM_NAVIGATION,
        },
        needHide: SystemPageMenuManager.getInstance().isAIBarNotSupport,
      }
    ],
    visible: !DeviceUtil.is2In1DevicePcType()
  };
}

/**
 * 获取时间和日期组
 * @returns
 */
function getTimeAndLanguageGroup(isPengLaiModeOpen?: boolean): SettingGroupModel {
  return {
    id: 'time_and_language',
    type: GroupType.GROUP_TYPE_STANDARD,
    items: getTimeAndLanguageGroupItems(isPengLaiModeOpen)
  };
}

function getTimeAndLanguageGroupItems(isPengLaiModeOpen?: boolean): SettingItemModel[] | undefined {
  if (isPengLaiModeOpen) {
    return [
      getLanguageItem(),
      getDateAndTimeItem(),
      getInputItem(),
    ]
  }
  return [
    getLanguageItem(),
    getDateAndTimeItem(),
    getInputItem(),
    ...getFontManageEntry()
  ];
}

function getInputItem(): SettingItemModel {
  return {
    id: 'set_input',
    type: ItemType.ITEM_TYPE_STANDARD,
    title: { content: $r('app.string.input') },
    detail: {
      type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
      icon: $r('sys.symbol.chevron_right'),
      isSymbolIcon: true,
      destination: NavEntryKey.INPUT_ENTRY,
    }
  };
}

function getDateAndTimeItem(): SettingItemModel {
  return {
    id: 'date_and_time',
    type: ItemType.ITEM_TYPE_STANDARD,
    title: { content: $r('app.string.date_time_settings_title') },
    detail: {
      type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
      icon: $r('sys.symbol.chevron_right'),
      isSymbolIcon: true,
      destination: NavEntryKey.DATA_TIME_ENTRY,
    }
  };
}

function getLanguageItem(): SettingItemModel {
  return {
    id: 'set_language',
    type: ItemType.ITEM_TYPE_STANDARD,
    title: { content: $r('app.string.languageAndRegion') },
    detail: {
      type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
      icon: $r('sys.symbol.chevron_right'),
      isSymbolIcon: true,
      destination: NavEntryKey.LANGUAGE_REGION_ENTRY,
    }
  };
}

/**
 * 获取手势组
 * @returns 单手模式组
 */
function getGestureGroup(): SettingGroupModel {
  return {
    id: 'quick_gestures_group',
    type: GroupType.GROUP_TYPE_STANDARD,
    items: getGestureGroupItems()
  };
}

function getGestureGroupItems(): SettingItemModel[] {
  return [
    getGesturePositionItem(),
  ];
}

function getGesturePositionItem(): SettingItemModel {
  return {
    id: 'gestures_position',
    type: ItemType.ITEM_TYPE_STANDARD,
    title: { content: $r('app.string.grip_posture_follow') },
    detail: {
      type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
      icon: $r('sys.symbol.chevron_right'),
      isSymbolIcon: true,
      destination: NavEntryKey.GRIP_POSTURE_FOLLOW_ENTRY,
    },
    needHide: SystemPageMenuManager.getInstance().isGripPostureFollowNotSupported,
  };
}

/**
 * 获取应用分身组
 * @returns 应用分身组
 */
function getApplicationAssistantGroup(): SettingGroupModel {
  return {
    id: 'application_assistant_group',
    type: GroupType.GROUP_TYPE_STANDARD,
    items: [
      {
        id: 'smart_multi_window',
        type: ItemType.ITEM_TYPE_STANDARD,
        title: { content: $r('app.string.smart_multi_window') },
        detail: {
          type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
          icon: $r('sys.symbol.chevron_right'),
          isSymbolIcon: true,
          destination: NavEntryKey.SMART_MULTI_WINDOW_ENTRY,
        }
      }
    ]
  };
}

/**
 * 获取企业设备和应用管理组
 * @returns 企业设备和应用管理组
 */
function getDeviceAndApplicationGroup(): SettingGroupModel {
  return {
    id: 'device_and_application_manager',
    type: GroupType.GROUP_TYPE_STANDARD,
    items: [
      {
        id: 'device_and_application',
        type: ItemType.ITEM_TYPE_STANDARD,
        title: { content: $r('app.string.enterprise_device_and_application_management') },
        detail: {
          type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
          icon: $r('sys.symbol.chevron_right'),
          isSymbolIcon: true,
          destination: NavEntryKey.DEVICE_AND_APPLICATION_ENTRY,
        },
        needHide: SystemPageMenuManager.getInstance().isEnterpriseDeviceNotSupport,
      }
    ],
    compControl: new DeviceAndApplicationController()
  };
}

/**
 * 获取重置组
 * @returns 重置组
 */
function getResetGroup(): SettingGroupModel {
  return {
    id: 'reset_clone_group',
    type: GroupType.GROUP_TYPE_STANDARD,
    items: [
      {
        id: 'reset_settings',
        type: ItemType.ITEM_TYPE_STANDARD,
        title: { content: $r('app.string.reset_settings_title') },
        detail: {
          type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
          icon: $r('sys.symbol.chevron_right'),
          isSymbolIcon: true,
          destination: NavEntryKey.RESET_ENTRY,
        }
      }
    ]
  };
}

function getSosEmergencyItem(): SettingItemModel {
  return {
    id: 'sos_emergency_help_entry',
    type: ItemType.ITEM_TYPE_STANDARD,
    title: { content: $r('app.string.sos_emergency_help') },
    detail: {
      type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
      icon: $r('sys.symbol.chevron_right'),
      isSymbolIcon: true,
      destination: NavEntryKey.SOS_EMERGENCY_HELP_ENTRY,
    },
    needHide: SystemPageMenuManager.getInstance().isSOSEmergencyHelpNotSupport,
  };
}

/**
 * 获取开发者选项组
 * @returns 开发者选项组
 */
function getDeveloperGroup(): SettingGroupModel {
  return {
    id: 'emergency_group_developer',
    type: GroupType.GROUP_TYPE_DYNAMIC_LAZY,
    compControl: new DeveloperGroupController(),
  };
}

function getFontManageEntry(): SettingItemModel[] {
  let result: SettingItemModel[] = [];
  if (DeviceUtil.isDevicePad()) {
    result.push({
      id: 'font_manage',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.font_manage') },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.FONT_MANAGE,
      },
      desc: { content: $r('app.string.font_manage_summary') }
    })
  }
  return result;
}

// 页面配置导入
PageLoader.load(NavEntryKey.SYSTEM_UPDATE_ENTRY, {
  configGenerator: systemPage
});