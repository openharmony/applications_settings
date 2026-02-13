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

export class HiSysWlanStaticEventGroup {
  public static readonly WIFI_STATUS = 'WIFI_STATUS';
}

export class HiSysHotspotStaticEventGroup {
  public static readonly HOTSPOT_STATUS = 'HOTSPOT_STATUS';
}

export class HiSysNearLinkStaticEventGroup {
  public static readonly NEARLINK_STATUS = 'NEARLINK_STATUS';
}

export class HiSysBatteryStaticEventGroup {
  public static readonly WIRELESS_REVERSE_STATUS = 'WIRELESS_REVERSE_STATUS';
  public static readonly BATTERY_SAVE_MODE_STATUS = 'BATTERY_SAVE_MODE_STATUS';
  public static readonly BATTERY_PERCENTAGE_STATUS = 'BATTERY_PERCENTAGE_STATUS';
}

export class HiSysNfcStaticEventGroup {
  public static readonly NFC_STATUS = 'NFC_STATUS';
  public static readonly DEFAULT_NFC_PAY_STATUS = 'DEFAULT_NFC_PAY_STATUS';
  public static readonly DEFAULT_PAYMENT_APPLICATION_STATUS = 'DEFAULT_PAYMENT_APPLICATION_STATUS';
  public static readonly NFC_NOT_DISTURB_STATUS = 'NFC_NOT_DISTURB_STATUS';
}

export class HiSysDisplayBrightnessStaticEventGroup {
  public static readonly SCREEN_BRIGHTNESS_STATUS = 'SCREEN_BRIGHTNESS_STATUS';
  public static readonly AUTO_SCREEN_BRIGHTNESS_STATUS = 'AUTO_SCREEN_BRIGHTNESS_STATUS';
  public static readonly SCREEN_ZOOM_STATUS = 'SCREEN_ZOOM_STATUS';
  public static readonly SCREEN_REFRESH_TYPE_STATUS = 'SCREEN_REFRESH_TYPE_STATUS';
  public static readonly SCREEN_OFF_TIMEOUT_STATUS = 'SCREEN_OFF_TIMEOUT_STATUS';
  public static readonly COLOR_MODE_STATUS = 'COLOR_MODE_STATUS';
  public static readonly COLOR_TEMPERATURE_STATUS = 'COLOR_TEMPERATURE_STATUS';
  public static readonly RESOLUTION_STATUS = 'RESOLUTION_STATUS';
  public static readonly DARK_MODE_STATUS = 'DARK_MODE_STATUS';
  public static readonly EYE_COMFORT_STATUS = 'EYE_COMFORT_STATUS';
  public static readonly EYE_MODE_ALL_DAY_STATUS = 'EYE_MODE_ALL_DAY_STATUS';
  public static readonly EYE_MODE_SCHEDULED_STATUS = 'EYE_MODE_SCHEDULED_STATUS';
  public static readonly EYE_COMFORT_LEVEL_STATUS = 'EYE_COMFORT_LEVEL_STATUS';
  public static readonly EYE_DC_BRIGHTNESS_STATUS = 'EYE_DC_BRIGHTNESS_STATUS';
  public static readonly FONT_SIZE_STATUS = 'FONT_SIZE_STATUS';
  public static readonly FONT_WEIGHT_STATUS = 'FONT_WEIGHT_STATUS';
  public static readonly SMART_RESOLUTION_STATUS = 'SMART_RESOLUTION_STATUS';
  public static readonly EYE_COMFORT_MODE_TIME_STATUS = 'EYE_COMFORT_MODE_TIME_STATUS';//
  public static readonly DISPLAY_EBOOK_STATUS = 'DISPLAY_EBOOK_STATUS';//
  public static readonly EBOOK_MODE_STATUS = 'EBOOK_MODE_STATUS';
  public static readonly WAKEUP_GAZE_STATUS = 'WAKEUP_GAZE_STATUS';
  public static readonly HIDE_SCREEN_CUTOUTS_STATUS = 'HIDE_SCREEN_CUTOUTS_STATUS';
  public static readonly FORCED_LANDSCAPE_STATUS = 'FORCED_LANDSCAPE_STATUS';
  public static readonly PICTURE_HDR_STATUS = 'PICTURE_HDR_STATUS';
  public static readonly BIONIC_VISION_STATUS = 'BIONIC_VISION_STATUS';
  public static readonly AIVIDEO_HDR_STATUS = 'AIVIDEO_HDR_STATUS';
}

export class HiSysSystemAndUpdatesStaticEventGroup {
  public static readonly LANGUAGE_STATUS = 'LANGUAGE_STATUS';
  public static readonly REGION_STATUS = 'REGION_STATUS';
  public static readonly TIME_FORMAT_HOUR_STATUS = 'TIME_FORMAT_HOUR_STATUS';
  public static readonly AUTO_TIMEZONE_STATUS = 'AUTO_TIMEZONE_STATUS';
  public static readonly INPUT_METHOD_STATUS = 'INPUT_METHOD_STATUS';
  public static readonly DOUBLE_CLICK_LOCK_SCREEN_STATUS = 'DOUBLE_CLICK_LOCK_SCREEN_STATUS';
}

export class HiSysMobileNetworkStaticEventGroup {
  public static readonly AIR_PLANE_MODE_STATUS = 'AIR_PLANE_MODE_STATUS';
  public static readonly NETWORK_OPTIMIZATION_STATUS = 'NETWORK_OPTIMIZATION_STATUS';
}

export class HiSysBiometricsAndPwdStaticEventGroup {
  public static readonly FP_KEYGUARD_STATUS = 'FP_KEYGUARD_STATUS';
}

export class HiSysAccessibilityStaticEventGroup {
  public static readonly SMART_COVER_STATUS = 'SMART_COVER_STATUS';
  public static readonly SMART_COVER_WITH_WINDOW_STATUS = 'SMART_COVER_WITH_WINDOW_STATUS';
  public static readonly ACCESSIBILITY_SHORTCUT_STATUS = 'ACCESSIBILITY_SHORTCUT_STATUS';
  public static readonly SHORTKEY_LOCK_SCREEN_STATUS = 'SHORTKEY_LOCK_SCREEN_STATUS';
  public static readonly ZOOM_GESTURE_SWITCH_STATUS = 'ZOOM_GESTURE_SWITCH_STATUS';
  public static readonly DALTONIZATION_SWITCH_STATUS = 'DALTONIZATION_SWITCH_STATUS';
  public static readonly INVERT_COLOR_SWITCH_STATUS = 'INVERT_COLOR_SWITCH_STATUS';
  public static readonly HIGH_CONTRAST_TEXT_SWITCH_STATUS = 'HIGH_CONTRAST_TEXT_SWITCH_STATUS';
  public static readonly AUDIO_MONO_SWITCH_STATUS = 'AUDIO_MONO_SWITCH_STATUS';
  public static readonly AUDIO_BALANCE_CHANGE_STATUS = 'AUDIO_BALANCE_CHANGE_STATUS';
  public static readonly IGNORE_REPEAT_TOUCHES_STATUS = 'IGNORE_REPEAT_TOUCHES_STATUS';
  public static readonly TOUCHE_DURATION_STATUS = 'TOUCHE_DURATION_STATUS';
  public static readonly TIME_INTERVAL_STATUS = 'TIME_INTERVAL_STATUS';
  public static readonly A11Y_FUNCTION_SELECT_TARGETS = 'A11Y_FUNCTION_SELECT_TARGETS';
  public static readonly SOUND_RECOG_MAIN_SWITCH_STATUS = 'SOUND_RECOG_MAIN_SWITCH_STATUS';
  public static readonly SOUND_RECOG_ENABLED_STATUS = 'SOUND_RECOG_ENABLED_STATUS';
  public static readonly FLASH_REMIND_MAIN_SWITCH_STATUS = 'FLASH_REMIND_MAIN_SWITCH_STATUS';
  public static readonly FLASH_REMIND_ENABLED_STATUS = 'FLASH_REMIND_ENABLED_STATUS';
  public static readonly WAKE_DOUBLE_CLICK_SWITCH_UE = 'WAKE_DOUBLE_CLICK_SWITCH_UE';
  public static readonly WAKE_PICK_UP_SWITCH_UE = 'WAKE_PICK_UP_SWITCH_UE';
  public static readonly PASSWORD_TYPE_STATUS = 'USER_PIN_CONFIG_STATUS';
  public static readonly HEARING_AID_STATUS = 'HEARING_AID_STATUS';
}

export class HiSysModeConnectStaticEventGroup {
  public static readonly COLLABORATION_SERVICE_SCHEDULED = 'COLLABORATION_SERVICE_SCHEDULED';
}

export class HiSysSystemSettingsStaticEventGroup {
  public static readonly AUTOMATIC_SYSTEM_UPDATE_STATUS = 'AUTOMATIC_SYSTEM_UPDATE_STATUS';
}

export class HiSysAPBANDStaticEventGroup {
  public static readonly AP_BAND_STATUS = 'AP_BAND_STATUS';
}

export class HiSysVolumeGroup {
  public static readonly DIAL_TONE_STATUS = 'DIAL_TONE_STATUS';
  public static readonly BOOT_SOUND_STATUS = 'BOOT_SOUND_STATUS';
  public static readonly SCREEN_LOCK_TONE_STATUS = 'SCREEN_LOCK_TONE_STATUS';
  public static readonly SCREENSHOT_PROMPT_TONE_STATUS = 'SCREENSHOT_PROMPT_TONE_STATUS';
  public static readonly VIBRATE_WHEN_RING_STATUS = 'VIBRATE_WHEN_RING_STATUS';
  public static readonly SYSTEM_TOUCH_FEEDBACK_STATUS = 'SYSTEM_TOUCH_FEEDBACK_STATUS';
  public static readonly VOLUME_MODE_STATUS = 'VOLUME_MODE_STATUS';
  public static readonly VOLUME_INTELLIGENT_CALL_STATUS = 'VOLUME_INTELLIGENT_CALL_STATUS';
  public static readonly CALL_RINGTONE_STATUS_CARD_ONE = 'CALL_RINGTONE_STATUS_CARD_ONE';
  public static readonly CALL_RINGTONE_STATUS_CARD_TWO = 'CALL_RINGTONE_STATUS_CARD_TWO';
  public static readonly INFORMATION_RINGTONE_STATUS_ONE = 'INFORMATION_RINGTONE_STATUS_ONE';
  public static readonly INFORMATION_RINGTONE_STATUS_TWO = 'INFORMATION_RINGTONE_STATUS_TWO';
  public static readonly NOTIFICATION_RINGTONE_STATUS = 'NOTIFICATION_RINGTONE_STATUS';
  public static readonly VOLUME_KEY_DEFAULT_CONTROL_FIXED = 'VOLUME_KEY_DEFAULT_CONTROL_FIXED';
  public static readonly VOLUME_RINGTONE_VIBRATION_STATUS = 'VOLUME_RINGTONE_VIBRATION_STATUS';
}

export class HiSysMoreConnectionGroup {
  public static readonly COLLABORATION_STATUS = 'COLLABORATION_STATUS';
  public static readonly SUPER_DESKTOP_STATUS = 'SUPER_DESKTOP_STATUS';
  public static readonly KEYBOARD_MOUSE_SHARE_STATUS = 'KEYBOARD_MOUSE_SHARE_STATUS';
}

export class HiSysDeveloperOptionsGroup {
  public static readonly DEVELOPER_MODE_STATUS = 'DEVELOPER_MODE_STATUS';
  public static readonly TURN_OFF_CHARGING_LIMIT_STATUS = 'TURN_OFF_CHARGING_LIMIT_STATUS';
  public static readonly DISPLAY_REFRESH_FREQUENCY_STATUS = 'DISPLAY_REFRESH_FREQUENCY_STATUS';
  public static readonly TURN_OFF_CHARGING_STATUS = 'TURN_OFF_CHARGING_STATUS';
  public static readonly CLEARING_TRUSTED_DEVICES_STATUS = 'CLEARING_TRUSTED_DEVICES_STATUS';
  public static readonly READABILITY_IN_THE_SUN_STATUS = 'READABILITY_IN_THE_SUN_STATUS';
  public static readonly SYSTEM_TRACE_ANALYSIS_STATUS = 'SYSTEM_TRACE_ANALYSIS_STATUS';
  public static readonly FROZEN_SCREEN_INFORMATION_STATUS = 'FROZEN_SCREEN_INFORMATION_STATUS';
  public static readonly SYSTEM_RESOURCE_LEAKAGE_STATUS = 'SYSTEM_RESOURCE_LEAKAGE_STATUS';
  public static readonly WLAN_DETAILED_LOG_RECORDING_STATUS = 'WLAN_DETAILED_LOG_RECORDING_STATUS';
  public static readonly SHOW_TOUCH_ACTIONS_STATUS = 'SHOW_TOUCH_ACTIONS_STATUS';
  public static readonly POINTER_POSITION_STATUS = 'POINTER_POSITION_STATUS';
  public static readonly DISPLAY_LAYOUT_INTERFACE_STATUS = 'DISPLAY_LAYOUT_INTERFACE_STATUS';
  public static readonly SHOW_REDRAW_REFRESH_REGION_STATUS = 'SHOW_REDRAW_REFRESH_REGION_STATUS';
  public static readonly CACHE_HIT_DETECTION_STATUS = 'CACHE_HIT_DETECTION_STATUS';
  public static readonly OVERDRAWING_DETECTION_STATUS = 'OVERDRAWING_DETECTION_STATUS';
  public static readonly OVER_ANIMATED_SCALING_STATUS = 'OVER_ANIMATED_SCALING_STATUS';
  public static readonly TO_BE_RESIZEABLE_STATUS = 'TO_BE_RESIZEABLE_STATUS';
  public static readonly SERVICE_EXEMPTION_CONTROL_STATUS = 'SERVICE_EXEMPTION_CONTROL_STATUS';
  public static readonly FREEZE_DETECT_SWITCH_STATUS = 'FREEZE_DETECT_SWITCH_STATUS';
  public static readonly DEBUG_OUTER_APP_SWITCH_STATUS = 'DEBUG_OUTER_APP_SWITCH_STATUS';
  public static readonly NETWORK_NAVIGATOR_SWITCH_STATUS = 'NETWORK_NAVIGATOR_SWITCH_STATUS';
  public static readonly NETWORK_NAVIGATOR_SCENE_STATUS = 'NETWORK_NAVIGATOR_SCENE_STATUS';
}