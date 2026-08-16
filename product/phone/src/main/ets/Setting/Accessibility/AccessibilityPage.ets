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

import { bundleManager } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { i18n } from '@kit.LocalizationKit';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import {
  PADDING_0,
  PADDING_4,
  PADDING_8,
  PADDING_12,
  PADDING_16
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import {
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { AccessibilitySettingsController } from './controller/AccessibilitySettingsController';
import { ZoomGestureSettingsController } from './controller/ZoomGestureSettingsController';
import { ElderCareSettingsController } from './eldercare/controller/ElderCareSettingsController';
import { ColorFilterSettingsController } from './controller/ColorFilterSettingsController';
import { FlashReminderSettingsController } from './controller/FlashReminderSettingsController';
import { ShortKeySettingsController } from './controller/ShortKeySettingsController';
import { DarkModeDialogContentComponent } from './view/DarkModeDialogContentComponent';
import { IgnoreRepeatClickReConfirmDialogComponent } from './view/IgnoreRepeatClickReConfirmDialogComponent';
import { AccessibilityCommonModel } from './utils/AccessibilityCommonModel';
import { HighContrastTextSettingsController } from './controller/HighContrastTextSettingsController';
import { InvertColorSettingsController } from './controller/InvertColorSettingsController';
import { AccessibilityCommonHeaderComponent } from './view/AccessibilityCommonHeaderComponent';
import { DEFAULT_TEXT_STYLE } from './constant/Constants';

/* instrument ignore file */
const PRODUCT_MODEL: string = 'const.product.model';
const PRODUCT_MODEL_EMULATOR: string = 'emulator';
const TIPS_APP_BUNDLE_NAME: string = 'com.ohos.tips';
const TIPS_APP_ID: string =
  'com.ohos.tips_BB4oLXt8JLOw5djd42S0oLOGzO6kOnT8hZfFRAAel2gbcQBG5jIsO4genni5cn2SQpKpKvkwOA7Ajsc7qf+MZgM=';
const URI_FORMATTER: string = '';
const MODULE_NAME_APP_GALLERY: string = 'com.XX.hmsapp.appgallery';
const URI_APP_GALLERY: string = '';
const FUN_NUM_HOME: string = 'SF-10044766_f101';
const TYPE: number = 207;

@Builder
export function darkModeDialogContentBuilder(param: SettingItemModel) {
  DarkModeDialogContentComponent({ item: param });
}

@Builder
export function ignoreRepeatClickReConfirmDialogBuilder(param: SettingItemModel) {
  IgnoreRepeatClickReConfirmDialogComponent({ item: param });
}

@Builder
export function visualGroupHeaderBuilder(param: object): void {
  AccessibilityCommonHeaderComponent({
    name: DeviceUtil.is2In1DevicePcType() ? $r('app.string.visual_accessibility') :
      $r('app.string.accessibility_visual_aids')
  });
}

@Builder
export function audioGroupHeaderBuilder(param: object): void {
  AccessibilityCommonHeaderComponent({
    name: DeviceUtil.is2In1DevicePcType() ? $r('app.string.audio_accessibility') :
      $r('app.string.accessibility_hearing_aids')
  });
}

@Builder
export function actionGroupHeaderBuilder(param: object): void {
  AccessibilityCommonHeaderComponent({
    name: $r('app.string.accessibility_interactive_control')
  });
}

function getElderCareItems(): SettingItemModel[] {
  return [
    {
      id: 'accessibility_elder_care_entry',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.elder_care_title'),
        style: DEFAULT_TEXT_STYLE
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: '',
          style: DEFAULT_TEXT_STYLE
        },
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.ACCESSIBILITY_ELDER_CARE_ENTRY,
      },
      compControl: new ElderCareSettingsController()
    }
  ]
}

function getVisualGroupItems(isEmulator: boolean): SettingItemModel[] {
  return [
    {
      id: 'accessibility_zoom_gesture_entry',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.zoom_gesture'),
        style: DEFAULT_TEXT_STYLE
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: '' },
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.ACCESSIBILITY_ZOOM_GESTURE_ENTRY,
      },
      needHide: () => {
        return isEmulator || DeviceUtil.is2In1DevicePcType();
      },
      compControl: new ZoomGestureSettingsController(),
    },
    {
      id: 'high_contrast_text_switch',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.highContrast_text'),
        style: DEFAULT_TEXT_STYLE
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: '' },
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.ACCESSIBILITY_HIGH_CONTRAST_TEXT_ENTRY,
      },
      needHide: () => {
        return DeviceUtil.is2In1DevicePcType();
      },
      compControl: new HighContrastTextSettingsController(),
    },
    {
      id: 'invert_color_switch',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.invert_color'),
        style: DEFAULT_TEXT_STYLE
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: '' },
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.ACCESSIBILITY_INVERT_COLOR_ENTRY,
      },
      compControl: new InvertColorSettingsController(),
    },
    {
      id: 'accessibility_color_filter_entry',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.color_correction'),
        style: DEFAULT_TEXT_STYLE
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: '' },
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.ACCESSIBILITY_COLOR_FILTER_ENTRY,
      },
      compControl: new ColorFilterSettingsController(),
    },
    {
      id: 'advanced_visual_entry',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.accessibility_features'),
        style: DEFAULT_TEXT_STYLE
      },
      needHide: DeviceUtil.is2In1DevicePcType,
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: $r('app.string.load_more_card') },
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.ACCESSIBILITY_ADVANCED_VISUAL_ENTRY,
      }
    },
  ]
}

function getAudioGroupItems(isEmulator: boolean): SettingItemModel[] {
  let isFlashReminderVisible: boolean = AccessibilityCommonModel.isSupportFlashReminderSwitch();
  let isSoundRecognitionVisible: boolean = AccessibilityCommonModel.isSupportSoundRecognitionSwitch();
  let items: SettingItemModel[] = [
    {
      id: 'single_audio_switch',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.audio_adjustment'),
        style: DEFAULT_TEXT_STYLE
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.ACCESSIBILITY_AUDIO_ADJUSTMENT_ENTRY,
      },
    },
  ];
  if (!isEmulator && !DeviceUtil.is2In1DevicePcType() && isFlashReminderVisible) {
    items.push({
      id: 'flash_reminder_entry',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.flash_reminder_title'),
        style: DEFAULT_TEXT_STYLE
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: '' },
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('app.media.ic_settings_arrow'),
        destination: NavEntryKey.ACCESSIBILITY_FLASH_REMINDER_ENTRY,
      },
      compControl: new FlashReminderSettingsController(isFlashReminderVisible),
    });
  }
  return items;
}

function getActionGroupItems(): SettingItemModel[] {
  return [
    {
      id: 'accessibility_touchscreen_entry',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.touchscreen_settings'),
        style: DEFAULT_TEXT_STYLE
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.ACCESSIBILITY_TOUCHSCREEN_ENTRY,
      },
      needHide: DeviceUtil.is2In1DevicePcType
    }
  ]
}

function getShortcutGroupItems(): SettingItemModel[] {
  return [
    {
      id: 'accessibility_operation_entry',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: {
        content: $r('app.string.accessibility_shortKey'),
        style: DEFAULT_TEXT_STYLE
      },
      desc: {
        content: $r('app.string.accessibility_shortKey_tips'),
        style: DEFAULT_TEXT_STYLE
      },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: '',
          style: DEFAULT_TEXT_STYLE
        },
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_NAVIGATE,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.ACCESSIBILITY_OPERATION_ENTRY,
      },
      compControl: new ShortKeySettingsController(),
      needHide: DeviceUtil.is2In1DevicePcType
    },
  ]
}

function accessibilityMainPage(): SettingPageModel {
  let isEmulator: boolean = DeviceUtil.isDeviceEmulator();
  return {
    id: 'Accessibility',
    url: NavEntryKey.ACCESSIBILITY_FEATURE_ENTRY,
    type: PageType.PAGE_TYPE_STANDARD,
    title: DeviceUtil.is2In1DevicePcType() ? $r('app.string.accessibility') : $r('app.string.accessibility_original'),
    compControl: new AccessibilitySettingsController(),
    layout: DeviceUtil.is2In1DevicePcType() ? { padding: { top: PADDING_0 } } : undefined,
    hdsNavDestinationUx: false,
    fixedGroups: [
      {
        id: 'AccessibilityFixedGroups',
        type: GroupType.GROUP_TYPE_STANDARD,
        visible: false,
        items: [
          {
            id: 'restoreDialog',
            type: ItemType.ITEM_TYPE_STANDARD,
          },
        ],
        layout: {
          backgroupColor: Color.Transparent,
          padding: { top: PADDING_0, bottom: PADDING_0 }
        }
      }
    ],
    groups: [
      // 关怀模式
      {
        id: 'accessibility_elder_care_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: getElderCareItems(),
        visible: !DeviceUtil.is2In1DevicePcType(),
        footer: {
          id: '',
          content: $r('app.string.elder_care_introduction_text'),
          style: DEFAULT_TEXT_STYLE
        },
        layout: {
          margin: { top: PADDING_0 },
        }
      },
      // 视觉
      {
        id: 'visual_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        header: {
          id: 'visual_group_header',
          builder: wrapBuilder(visualGroupHeaderBuilder),
          style: {
            padding: {
              start: PADDING_8,
              end: i18n.isRTL(i18n.System.getSystemLanguage()) ? PADDING_12 : PADDING_4,
              bottom: PADDING_4,
              top: FontScaleUtils.isExtraLargeFontMode() ? PADDING_16 : PADDING_0
            },
          }
        },
        items: getVisualGroupItems(isEmulator),
        footer: {
          id: 'visual_group_footer',
          content: $r('app.string.accessibility_visual_aids_tips'),
          style: DEFAULT_TEXT_STYLE,
          visible: !DeviceUtil.is2In1DevicePcType()
        }
      },
      // 听觉
      {
        id: 'audio_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        header: {
          id: 'audio_group_header',
          builder: wrapBuilder(audioGroupHeaderBuilder),
          style: {
            padding: {
              start: PADDING_8,
              end: i18n.isRTL(i18n.System.getSystemLanguage()) ? PADDING_12 : PADDING_4,
              bottom: PADDING_4,
              top: FontScaleUtils.isExtraLargeFontMode() ? PADDING_16 : PADDING_0
            },
          }
        },
        items: getAudioGroupItems(isEmulator),
        footer: {
          id: 'audio_group_footer',
          content: $r('app.string.accessibility_hearing_aids_tips'),
          style: DEFAULT_TEXT_STYLE,
          visible: !DeviceUtil.is2In1DevicePcType()
        }
      },
      // 交互控制
      {
        id: 'action_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        header: {
          id: 'action_group_header',
          builder: wrapBuilder(actionGroupHeaderBuilder),
          style: {
            padding: {
              start: PADDING_8,
              end: i18n.isRTL(i18n.System.getSystemLanguage()) ? PADDING_12 : PADDING_4,
              bottom: PADDING_4,
              top: FontScaleUtils.isExtraLargeFontMode() ? PADDING_16 : PADDING_0
            },
          }
        },
        items: getActionGroupItems(),
        footer: {
          id: 'action_group_footer',
          content: $r('app.string.accessibility_interactive_control_tips'),
          style: DEFAULT_TEXT_STYLE
        }
      },
      // 辅助功能快捷键
      {
        id: 'accessibility_shortkey_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: getShortcutGroupItems(),
      }
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.ACCESSIBILITY_FEATURE_ENTRY, {
  configGenerator: accessibilityMainPage,
});
