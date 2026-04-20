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

export const UX_DESIGN_SHEET_HEIGHT_PAD: number = 560;

export const DIALOG_WIDTH_FOLD_EXPAND: number = 400;

export const TYPE_MODAL_SCREEN_HEIGHT_RATE: number = 0.6;

export const SCREEN_HEIGHT_RATE: number = 0.9;

export const DEFAULT_PADDING_START: Length = $r('sys.float.ohos_id_default_padding_start');

export const DEFAULT_PADDING_END: Length = $r('sys.float.ohos_id_default_padding_end');

export const ACCESSIBILITY_FUNCTION_SELECT_TARGETS: string = 'accessibility_function_select_targets';

export const ACCESSIBILITY_SHORTCUT_TARGETS_SERVICE: string = 'accessibility_shortcut_target_service';

export const ACCESSIBILITY_COLOR_FILTER_SWITCH_ENABLED: string = 'accessibility_color_filter_switch_enabled';

export const ACCESSIBILITY_IGNORE_REPEAT_CLICK_ENABLED: string = 'accessibility_ignore_repeat_click_enabled';

export const ZOOM_GESTURE_DIALOG_OPEN: string = 'accessibility_zoom_gesture_enabled_reconfirm';

export const SCREEN_READER_SWITCH: string = 'screen_reader_switch';

export const SECURITY_NOTIFICATION_MODEL_SHOW_EVENT: string = 'SECURITY_NOTIFICATION_MODEL_SHOW';

export const FUNCTION_SELECT_LIST_PAGE_SHOW_EVENT = 'FUNCTION_SELECT_LIST_PAGE_SHOW_EVENT';

export const SHORTCUT_ENABLED_ON_LOCK_SCREEN = 'accessibility_shortcut_enabled_on_lock_screen';

export const SCREEN_MAGNIFICATION: string = 'accessibility_display_magnification_enabled';

export const SCREEN_MAGNIFICATION_TYPE_KEY: string = 'accessibility_magnification_capability';

export const INGORE_REPEAT_CLICK_RECONFIRM: string = 'accessibility_ignore_repeat_click_reconfirm';

export const NIGHT_MODE_STATE_ON = '2';

export const NIGHT_MODE_STATE_OFF = '1';

export const CLICK_SWITCH_ON: string = '1';

export const CLICK_SWITCH_OFF: string = '0';

export const A11Y_CONFIG_CLONE: string = 'accessibility_config_clone';

export const SCREEN_READER_ON_KEY = 'accessibility_screenreader_enabled';

export const ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED: string = 'accessibility_elder_care_switch_enabled';

export const ACCESSIBILITY_SOUND_RECOGNITION_SWITCH_EVENT: string = 'accessibility_sound_recognition_switch_event';

export const ACCESSIBILITY_SOUND_RECOGNITION_SWITCH: string = 'accessibility_sound_recognition_switch';

export const ACCESSIBILITY_SOUND_RECOGNITION_ENABLED: string = 'accessibility_sound_recognition_enabled';

export const ACCESSIBILITY_FLASH_REMINDER_SWITCH_EVENT: string = 'accessibility_flash_reminder_switch_event';

export const ACCESSIBILITY_FLASH_REMINDER_SWITCH: string = 'accessibility_flash_reminder_switch';

export const ACCESSIBILITY_REMINDER_FUNCTION_ENABLED: string = 'accessibility_reminder_function_enabled';

export const OOBE_ZOOM_GESTURE_REQUEST_FOCUS_EVENT: string = 'OOBE_ZOOM_GESTURE_REQUEST_FOCUS_EVENT';

export class SliderConstants {
  public static SLIDER_VALUE_0: number = 0;
  public static MAX: number = 100;
  public static MIN: number = -100;
  public static STEP: number = 20;
  public static MULTIPLES: number = 100;
  public static MOVING: number = 1;
  public static END: number = 2;
  public static CLICK: number = 3;
}

export class TouchscreenConstants {
  public static readonly MINI_NUMBER: number = 0;
  public static readonly INTERMEDIATE_NUMBER: number = 25;
  public static readonly FIFTY_NUMBER: number = 50;
  public static readonly SEVENTY_FIVE_NUMBER: number = 75;
  public static readonly MAX_NUMBER: number = 100;
  public static readonly STEP: number = 25;
  public static readonly END: number = 2;
  public static readonly CLICK: number = 3;
}

export enum TouchScreenType {
  TOUCH_SCREEN_SHORT = 0,
  TOUCH_SCREEN_MEDIUM = 1,
  TOUCH_SCREEN_LONG = 2
}

export enum SelectTouchDurationValue {
  DEFAULTSHORT = 'Short',
  MEDIUM = 'Medium',
  LONG = 'Long'
}

export const TOUCH_DURATION_TYPES_ARRAY: ResourceStr[] = [
  $r('app.string.touchscreen_short'),
  $r('app.string.medium'),
  $r('app.string.long'),
];

export const MAGNIFICATION_TYPES_ARRAY: ResourceStr[] = [
  $r('app.string.full_screen_zoom_text'),
  $r('app.string.partial_screen_zoom_text'),
  $r('app.string.switch_zoom_zone_text')
];

// 1-全局放大 2-局部放大 3-缩放区域切换
export enum ScreenMagnificationType {
  TYPE_ALL = 1,
  TYPE_PART = 2,
  TYPE_SWITCH = 3
}

export enum ColorFilterType {
  COLOR_FILTER_DEUTERANOMALY = 0,
  COLOR_FILTER_PROTANOMALY = 1,
  COLOR_FILTER_TRITANOMALY = 2,
  COLOR_FILTER_DEFAULT = 3
}

export enum SelectColorFilterCorrectionValue {
  DEUTERANOMALY = 'Deuteranomaly',
  PROTANOMALY = 'Protanomaly',
  TRITANOMALY = 'Tritanomaly',
  DEFAULT = 'Normal'
}

export const COLOR_FILTER_CORRECTION_MODE_ARRAY: ResourceStr[] = [
  $r('app.string.deuteranomaly_radio'),
  $r('app.string.protanomaly_radio'),
  $r('app.string.tritanomaly_radio'),
  $r('app.string.color_filter_normal'),
];

export const FUNCTION_SELECT_SERVICES_ARRAY: ResourceStr[] = [
  $r('app.string.highContrast_text'),
  $r('app.string.single_audio'),
  $r('app.string.invert_color'),
  $r('app.string.screenreader'),
];

export enum FunctionSelectTargetNameValue {
  HIGH_CONTRAST_TEXT = 'HIGH_CONTRAST_TEXT',
  SINGLE_AUDIO = 'AUDIO_MONO',
  INVERT_COLOR = 'INVERT_COLOR',
  SCREEN_READER = 'SCREEN_READER'
}

export enum FunctionSelectOriginNameValue {
  HIGH_CONTRAST_TEXT = 'HIGH_CONTRAST_TEXT',
  SINGLE_AUDIO = 'AUDIO_MONO',
  INVERT_COLOR = 'INVERT_COLOR',
  SCREEN_READER = 'com.ohos.screenreader/AccessibilityExtAbility',
}

export const FUNCTION_SELECT_TARGET_NAME_ARRAY: string[] = [
  'HIGH_CONTRAST_TEXT',
  'AUDIO_MONO',
  'INVERT_COLOR',
  'SCREEN_READER'
]

export interface ExtensionInfo {
  id: string;
  name: string;
  state: boolean;
}

export enum VoiceRecognitionModeValue {
  DEFAULT = 'DEFAULT',
  ENV_BABYCRY = 'BABYCRY',
  ENV_MEOW = 'MEOW',
  ENV_BARK = 'BARK',
  ENV_DOORBELL = 'DOORBELL',
  ENV_KNOCK = 'KNOCK',
  ENV_ALARM = 'ALARM'
}

export enum ReminderFunctionModeValue {
  ALARM_CLOCK = 'ALARM_CLOCK',
  INCOMING_CALL = 'INCOMING_CALL',
  NOTIFY = 'NOTIFY',
  DEFAULT = 'DEFAULT',
}

export const IGNORE_REPEATED_TIME_NAME_ARRAY: string[] = [
  '0.1 S',
  '0.4 S',
  '0.7 S',
  '1.0 S',
  '1.3 S'
]

export const IGNORE_REPEATED_TIME_NAME_MAP: Map<string, string> = new Map([
  ['Shortest', IGNORE_REPEATED_TIME_NAME_ARRAY[0]],
  ['Short', IGNORE_REPEATED_TIME_NAME_ARRAY[1]],
  ['Medium', IGNORE_REPEATED_TIME_NAME_ARRAY[2]],
  ['Long', IGNORE_REPEATED_TIME_NAME_ARRAY[3]],
  ['Longest', IGNORE_REPEATED_TIME_NAME_ARRAY[4]],
]);

export const ASSISTED_READING_TEXT_SIZE_NAME_LIST: Resource[] = [
  $r('app.string.display_mode_font_size_normal'),
  $r('app.string.display_mode_font_size_large'),
  $r('app.string.display_mode_font_size_extra_large'),
  $r('app.string.display_mode_font_size_huge')
]

export const FONT_SIZE_SCALE_LIST: number[] = [1, 1.15, 1.3, 1.45]

/**
 * 动效参数
 */
export const TRANSACTION_TIME: number = 600;

export const FONT_SIZE_STEP_NUM: number = 1;

export const MAX_FONT_SIZE_LEVEL: number = 4;

export const MIN_FONT_SIZE_LEVEL: number = 1;

export const TEXT_FONT_SIZE_EXTRA_LARGE_STEP: number = 4;

export class TextSizeStepConstants {
  // 字体 标准 Step值
  public static readonly TEXT_FONT_SIZE_NORMAL_STEP = 1;

  // 字体 大 Step值
  public static readonly TEXT_FONT_SIZE_LARGE_STEP = 2;

  // 字体 超大 Step值
  public static readonly TEXT_FONT_SIZE_EXTRA_LARGE_STEP = 3;

  // 字体 特大 Step值
  public static readonly TEXT_FONT_SIZE_HUGE_STEP = 4;
}

export const SWITCH_ON: string = '1';

export const SWITCH_OFF: string = '0';