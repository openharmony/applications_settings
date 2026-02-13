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

export class HiSysPasswdModificationOccurEvent {
  public static readonly EVENT_NAME = 'PASSWD_MODIFICATION_OCCUR_EVENT';
  public static readonly CREATE_PASSWORD = 'CREATE_PASSWORD';
  public static readonly UPDATE_PASSWORD = 'UPDATE_PASSWORD';
  public static readonly CLOSE_SCREEN_LOCK_PASSWORD = 'CLOSE_SCREEN_LOCK_PASSWORD';
}

export class HiSysHarmonyShareEvent {
  public static readonly EVENT_NAME = 'SETTINGS_SHARE_EVENT';
}

// wifi蓝牙相关
export class HiSysAboutBluetoothEventGroup {
  public static readonly CLICK_WLAN_TEXT_SHOW_DIALOG = 'CLICK_WLAN_TEXT_SHOW_DIALOG'
  public static readonly CLICK_BLUETOOTH_TEXT_POP_UPS = 'CLICK_BLUETOOTH_TEXT_POP_UPS'
  public static readonly BLUETOOTH_CLICK_TITLE = 'BLUETOOTH_CLICK_TITLE'
  public static readonly ENTER_SETTINGS_WIFI_PAGE = 'ENTER_SETTINGS_WIFI_PAGE';
  public static readonly CLICK_GENERAL_SETTINGS_ICON = 'CLICK_GENERAL_SETTINGS_ICON';
  public static readonly BLUETOOTH_SYNC_VOLUME_SWITCH = 'BLUETOOTH_SYNC_VOLUME_SWITCH';
  public static readonly CHANGE_WIFI_SWITCH = 'CHANGE_WIFI_SWITCH';
  public static readonly COLLABORATION_SERVICE_SWITCH = 'COLLABORATION_SERVICE_SWITCH';
  public static readonly SELECT_BLUETOOTH_PAIRING = 'SELECT_BLUETOOTH_PAIRING';
  public static readonly WIFI_SECURITY_SWITCH = 'WIFI_SECURITY_SWITCH';
}

// 生物识别和密码
export class HiSysPasswordRelatedEventGroup {
  public static readonly SET_IDENTIFY_PASSWORD = 'SET_IDENTIFY_PASSWORD'
  public static readonly SET_BIOLOGY_PASSWORD_OK = 'SET_BIOLOGY_PASSWORD_OK'
  public static readonly SET_BIOLOGY_OFF_PASSWORD = 'SET_BIOLOGY_OFF_PASSWORD'
  public static readonly SET_IDENTIFY_CLOSURE_TYPE = 'SET_IDENTIFY_CLOSURE_TYPE'
  public static readonly SET_FINGERPRINT_LIST_NAME = 'SET_FINGERPRINT_LIST_NAME'
  public static readonly CLICK_CUSTOMIZE_NUMBER_PWD = 'CLICK_CUSTOMIZE_NUMBER_PWD'
  public static readonly RENAME_FINGERPRINT_SAVE = 'RENAME_FINGERPRINT_SAVE'
  public static readonly SET_PASSWORD_FINGERPRINT_SAVE = 'SET_PASSWORD_FINGERPRINT_SAVE'
  public static readonly SET_PASSWORD_FINGERPRINT_DELETE = 'SET_PASSWORD_FINGERPRINT_DELETE'
  public static readonly SET_DEVICE_UNLOCK = 'SET_DEVICE_UNLOCK'
  public static readonly CREATE_FINGERPRINT = 'CREATE_FINGERPRINT'
  public static readonly CREATE_FINGERPRINT_OK = 'CREATE_FINGERPRINT_OK'
  public static readonly SET_BIOLOGY_EXPIRE_PRE_PASSWORD = 'SET_BIOLOGY_EXPIRE_PRE_PASSWORD'
}

//显示和亮度
export class HiSysDisplayBrightnessEventGroup {
  public static readonly CLICK_SCREEN_REFRESH_RATE_RADIO = 'CLICK_SCREEN_REFRESH_RATE_RADIO';
  public static readonly CLICK_EYE_COMFORT_TIMEON_SWITCH = 'CLICK_EYE_COMFORT_TIMEON_SWITCH';
  public static readonly CLICK_EBOOK_MODE_SWITCH = 'CLICK_EBOOK_MODE_SWITCH';
  public static readonly EBOOK_MODE_SWITCH = 'EBOOK_MODE_SWITCH';
  public static readonly UPDATE_FONT_SIZE = 'UPDATE_FONT_SIZE';
  public static readonly UPDATE_FONT_WEIGHT = 'UPDATE_FONT_WEIGHT';
  public static readonly SMART_RESOLUTION_SWITCH = 'SMART_RESOLUTION_SWITCH';
  public static readonly EYE_COMFORT_MODE_TIME_SWITCH = 'EYE_COMFORT_MODE_TIME_SWITCH';
  public static readonly DISPLAY_EBOOK_SWITCH = 'DISPLAY_EBOOK_SWITCH';
  public static readonly FONT_SIZE_WEIGHT_ENTRY = 'FONT_SIZE_WEIGHT_ENTRY';
  public static readonly DARK_MODE_ENTRY = 'DARK_MODE_ENTRY';
  public static readonly EBOOK_MODE_ENTRY = 'EBOOK_MODE_ENTRY';
  public static readonly EYE_MODE_ENTRY = 'EYE_MODE_ENTRY';
  public static readonly EYE_MODE_SCHEDULED_ENTRY = 'EYE_MODE_SCHEDULED_ENTRY';
  public static readonly COLOR_MODE_ENTRY = 'COLOR_MODE_ENTRY';
  public static readonly SCREEN_RESOLUTION_ENTRY = 'SCREEN_RESOLUTION_ENTRY';
  public static readonly SCREEN_REFRESH_RATE_ENTRY = 'SCREEN_REFRESH_RATE_ENTRY';
  public static readonly LANDSCAPE_STARTUP_ENTRY = 'LANDSCAPE_STARTUP_ENTRY';
  public static readonly ADVANCED_SETTINGS_ENTRY = 'ADVANCED_SETTINGS_ENTRY';
  public static readonly DARK_MODE_SCHEDULED_SWITCH = 'DARK_MODE_SCHEDULED_SWITCH';
  public static readonly EYE_MODE_ALL_DAY_SWITCH = 'EYE_MODE_ALL_DAY_SWITCH';
  public static readonly EYE_MODE_SCHEDULED_SWITCH = 'EYE_MODE_SCHEDULED_SWITCH';
  public static readonly EYE_COMFORT_LEVEL_VALUE = 'EYE_COMFORT_LEVEL_VALUE';
  public static readonly EYE_DC_BRIGHTNESS_SWITCH = 'EYE_DC_BRIGHTNESS_SWITCH';
  public static readonly WAKEUP_GAZE_SWITCH = 'WAKEUP_GAZE_SWITCH';
  public static readonly COLOR_MODE_TYPE = 'COLOR_MODE_TYPE';
  public static readonly COLOR_TEMPERATURE_TYPE = 'COLOR_TEMPERATURE_TYPE';
  public static readonly HIDE_SCREEN_CUTOUTS_SWITCH = 'HIDE_SCREEN_CUTOUTS_SWITCH';
  public static readonly FORCED_LANDSCAPE_SWITCH = 'FORCED_LANDSCAPE_SWITCH';
  public static readonly PICTURE_HDR_SWITCH = 'PICTURE_HDR_SWITCH';
  public static readonly AIVIDEO_HDR_SWITCH = 'AIVIDEO_HDR_SWITCH';
  public static readonly BIONIC_VISION_SWITCH = 'BIONIC_VISION_SWITCH';
  public static readonly INVALID_DATA = '-1';
  public static readonly COLOR_TEMPERATURE_TABLE = 'COLOR_TEMPERATURE_TABLE';
}

//隐私和安全
export class HiSysPrivacyAndSecurityEventGroup {
  public static readonly ENTRY_PRIVACY_SECURITY = 'ENTRY_PRIVACY_SECURITY';
}

// 应用和服务
export class HiSysApplicationsAndServicesEventGroup {
  public static readonly ENTER_APP_MANAGEMENT_PAGE = 'ENTER_APP_MANAGEMENT_PAGE';
  public static readonly ENTER_NOTIFY_MANAGE_PAGE = 'ENTER_NOTIFY_MANAGE_PAGE';
  public static readonly CLICK_NOTIFY_MENU = 'CLICK_NOTIFY_MENU';
  public static readonly ENTER_SERVICE_MANAGEMENT_PAGE = 'ENTER_SERVICE_MANAGEMENT_PAGE';
  public static readonly CLICK_RIGHTS_MANAGEMENT_SWITCH = 'CLICK_RIGHTS_MANAGEMENT_SWITCH';
  public static readonly CLICK_LIVE_VIEW_SWITCH = 'CLICK_LIVE_VIEW_SWITCH';
  public static readonly ENTRY_NOTIFICATION_DETAILS = 'ENTRY_NOTIFICATION_DETAILS';
  public static readonly ENTER_META_MANAGE_PAGE = 'ENTER_META_MANAGE_PAGE';
  public static readonly SET_DEFAULT_EMAIL = 'SET_DEFAULT_EMAIL';
  public static readonly SET_DEFAULT_BROWSER = 'SET_DEFAULT_BROWSER';
  public static readonly ENTER_APPLICATION_INFO_ENTRY = 'ENTER_APPLICATION_INFO_ENTRY';
  public static readonly APPLICATIONS_AND_SERVICES_ENTRY = 'APPLICATIONS_AND_SERVICES_ENTRY';
  public static readonly RESTORING_APPLICATIONS_ENTRY = 'RESTORING_APPLICATIONS_ENTRY';
  public static readonly MORE_APPS_ENTRY = 'MORE_APPS_ENTRY';
  public static readonly RESTORING_SERVICES_ENTRY = 'RESTORING_SERVICES_ENTRY';
  public static readonly APP_AND_SERVICE_UNINSTALL_SWITCH = 'APP_AND_SERVICE_UNINSTALL_SWITCH';
  public static readonly APP_AND_SERVICE_STOPPING_SWITCH = 'APP_AND_SERVICE_STOPPING_SWITCH';
  public static readonly APP_AND_SERVICE_ENABLE_SWITCH = 'APP_AND_SERVICE_ENABLE_SWITCH';
}

// 更多共享设置
export class HotspotDeviceGroup {
  public static readonly HOTSPOT_DEVICE_USB = 'HOTSPOT_DEVICE_USB';
}

// 系统设置相关
export class HiSysAboutSystemSettingsEventGroup {
  public static readonly CLICK_RESTORE_NETWORK_BUTTON = 'CLICK_RESTORE_NETWORK_BUTTON';
  public static readonly CLICK_PARAM_SETTING_BUTTON = 'CLICK_PARAM_SETTING_BUTTON';
  public static readonly CLICK_OFFLINE_MODE_SWITCH = 'CLICK_OFFLINE_MODE_SWITCH';
  public static readonly ENTER_SYSTEM_UPDATE_ENTRY = 'ENTER_SYSTEM_UPDATE_ENTRY';
  public static readonly AUTOMATIC_SYSTEM_UPDATE_SWITCH = 'AUTOMATIC_SYSTEM_UPDATE_SWITCH';
  public static readonly SYSTEM_NAVIGATION_ENTRY = 'SYSTEM_NAVIGATION_ENTRY';
  public static readonly QUICK_LAUNCH_AND_GESTURE_ENTRY = 'QUICK_LAUNCH_AND_GESTURE_ENTRY';
  public static readonly INTELLIGENT_PAYMENT_ENTRY = 'INTELLIGENT_PAYMENT_ENTRY';
  public static readonly INTELLIGENT_SCANNING_CODE_ENTRY = 'INTELLIGENT_SCANNING_CODE_ENTRY';
  public static readonly DEVELOPER_MODE_SWITCH = 'DEVELOPER_MODE_SWITCH';
  public static readonly WIRELESS_COMMISSIONING_ENTRY = 'WIRELESS_COMMISSIONING_ENTRY'
  public static readonly INTENT_FRAMEWORK_DEBUGGING_ENTRY = 'INTENT_FRAMEWORK_DEBUGGING_ENTRY';
  public static readonly ENTER_GRIP_FOLLOW_ENTRY = 'GRIP_FOLLOW_ENTRY';
  public static readonly DOUBLE_CLICK_LOCK_SCREEN_SWITCH = 'DOUBLE_CLICK_LOCK_SCREEN_SWITCH';
}

// 重置
export class HiSysRelocateEventGroup {
  public static readonly ENTER_RESTORE_NETWORK_ENTRY = 'ENTER_RESTORE_NETWORK_ENTRY';
  public static readonly ENTER_RESTORE_NETWORK_PAGE = 'ENTER_RESTORE_NETWORK_PAGE';
  public static readonly ENTER_RESTORE_NETWORK_CONFIRM = 'ENTER_RESTORE_NETWORK_CONFIRM';
  public static readonly ENTER_FACTORY_RESTORE_ENTRY = 'ENTER_FACTORY_RESTORE_ENTRY';
  public static readonly ENTER_RESET_PHONE_ENTRY = 'ENTER_RESET_PHONE_ENTRY';
  public static readonly ENTER_RESET_PHONE_PAGE = 'ENTER_RESET_PHONE_PAGE';
  public static readonly ENTER_RESET_PHONE_CONFIRM = 'ENTER_RESET_PHONE_CONFIRM';
  public static readonly PARAMETER_VERSION_SETTING_ENTRY = 'PARAMETER_VERSION_SETTING_ENTRY';
  public static readonly SECURITY_PATCH_LABEL_ENTRY = 'SECURITY_PATCH_LABEL_ENTRY';
  public static readonly SAFETY_INFORMATION_ENTRY = 'SAFETY_INFORMATION_ENTRY';
  public static readonly WARNING_NOTIFICATION_ENTRY = 'WARNING_NOTIFICATION_ENTRY';
}

// 开发者选项
export class HiSysDeveloperEventGroup {
  public static readonly ENTER_DEVELOPER_OPTIONS_ENTRY = 'ENTER_DEVELOPER_OPTIONS_ENTRY';
  public static readonly FREEZE_DETECT_SWITCH = 'FREEZE_DETECT_SWITCH';
  public static readonly APP_PROCESS_SAMPLING_SWITCH = 'APP_PROCESS_SAMPLING_SWITCH';
  public static readonly UPDATE_SYSTEM_SHARED_LIBRARY = 'UPDATE_SYSTEM_SHARED_LIBRARY';
}

// 关于本机
export class HiSysAboutDeviceEventGroup {
  public static readonly CLICK_VERSION = 'CLICK_VERSION';
  public static readonly ENTER_ABOUT_MOBILE_ENTRY = 'ENTER_ABOUT_MOBILE_ENTRY';
  public static readonly ENTER_DEVICE_NAME_ENTRY = 'ENTER_DEVICE_NAME_ENTRY';
  public static readonly ENTER_PARAMETER_VERSION_ENTRY = 'ENTER_PARAMETER_VERSION_ENTRY';
  public static readonly ENTER_VERSION_SETTINGS_ENTRY = 'ENTER_VERSION_SETTINGS_ENTRY';
  public static readonly ENTER_AUTO_DOWNLOAD_ENTRY = 'ENTER_AUTO_DOWNLOAD_ENTRY';
  public static readonly OPEN_AUTO_DOWNLOAD_CONFIRM = 'OPEN_AUTO_DOWNLOAD_CONFIRM';
  public static readonly CLOSE_AUTO_DOWNLOAD_CONFIRM = 'CLOSE_AUTO_DOWNLOAD_CONFIRM';
  public static readonly ENTER_STATUS_INFORMATION_ENTRY = 'ENTER_STATUS_INFORMATION_ENTRY';
  public static readonly ENTER_LEGAL_INFORMATION_ENTRY = 'ENTER_LEGAL_INFORMATION_ENTRY';
  public static readonly ENTER_NETWORK_INFORMATION_ENTRY = 'ENTER_NETWORK_INFORMATION_ENTRY';
  public static readonly ENTER_PRIVACY_STATEMENT_ENTRY = 'ENTER_PRIVACY_STATEMENT_ENTRY';
  public static readonly ENTER_USER_AGREEMENT_ENTRY = 'ENTER_USER_AGREEMENT_ENTRY';
  public static readonly ENTER_SOURCE_CODE_LICENSE_ENTRY = 'ENTER_SOURCE_CODE_LICENSE_ENTRY';
  public static readonly ENTER_SERVICE_STATEMENT_ENTRY = 'ENTER_SERVICE_STATEMENT_ENTRY';
  public static readonly ENTER_PRIVATE_USER_CLICK_VERSION = 'ENTER_PRIVATE_USER_CLICK_VERSION';
  public static readonly ENTER_NETWORK_INFO_SETTING = 'ENTER_NETWORK_INFO_SETTING';
  public static readonly PARAMETER_VERSION_SETTING_ENTRY = 'PARAMETER_VERSION_SETTING_ENTRY';
  public static readonly SECURITY_PATCH_LABEL_ENTRY = 'SECURITY_PATCH_LABEL_ENTRY';
  public static readonly SAFETY_INFORMATION_ENTRY = 'SAFETY_INFORMATION_ENTRY';
  public static readonly OPEN_SOURCE_STATEMENT_ENTRY = 'OPEN_SOURCE_STATEMENT_ENTRY';
  public static readonly WARNING_NOTIFICATION_ENTRY = 'WARNING_NOTIFICATION_ENTRY';
  public static readonly DEVICE_INFO_ENTRY = 'DEVICE_INFO_ENTRY';
  public static readonly ESIM_ID_ENTRY = 'ESIM_ID_ENTRY';
}

// 屏幕与睡眠
export class HisysScreenAndSleepEventGroup {
  public static readonly CHOOSE_SCREENOFF_ACTIMEOUT_RADIO = 'CHOOSE_SCREENOFF_ACTIMEOUT_RADIO';
  public static readonly CHOOSE_SCREENOFF_DCTIMEOUT_RADIO = 'CHOOSE_SCREENOFF_DCTIMEOUT_RADIO';
  public static readonly CHOOSE_POWER_KEY_SETTINGS_RADIO = 'CHOOSE_POWER_KEY_SETTINGS_RADIO';
  public static readonly CHOOSE_SWITCH_AC_SETTINGS_RADIO = 'CHOOSE_SWITCH_AC_SETTINGS_RADIO';
  public static readonly CHOOSE_SWITCH_DC_SETTINGS_RADIO = 'CHOOSE_SWITCH_DC_SETTINGS_RADIO';
  public static readonly CHOOSE_HIBERNATE_TOGGLE = 'CHOOSE_HIBERNATE_TOGGLE';
  public static readonly CHOOSE_WAKE_ON_LID_OPEN_TOGGLE = 'CHOOSE_WAKE_ON_LID_OPEN_TOGGLE';
}

// 应用自启动
export class HiSysAutoStartAppEventGroup {
  // 开机自启动应用数量
  public static readonly AUTO_START_APP_NUMBER = 'AUTO_START_APP_NUMBER';
}

export class HiSysBiometricsAndPasswordEventGroup {
  public static readonly ENTER_FINGERPRINT_ENTRY = 'ENTER_FINGERPRINT_ENTRY';
  public static readonly FP_RESOLUTION_DLG_NO_PROMPT = 'FP_RESOLUTION_DLG_NO_PROMPT';
  public static readonly FP_RESOLUTION_DLG_CONFIRM = 'FP_RESOLUTION_DLG_CONFIRM';
  public static readonly FP_RESOLUTION_DLG_CONFIRM_NO_P = 'FP_RESOLUTION_DLG_CONFIRM_NO_P';
  public static readonly ENROLL_FINGERPRINT_ACTION = 'ENROLL_FINGERPRINT_ACTION';
  public static readonly ENROLL_FINGERPRINT_COMPLETED = 'ENROLL_FINGERPRINT_COMPLETED';
  public static readonly ENTER_RENAME_FINGERPRINT_ENTRY = 'ENTER_RENAME_FINGERPRINT_ENTRY';
  public static readonly RENAME_FINGERPRINT_SUBMIT = 'RENAME_FINGERPRINT_SUBMIT';
  public static readonly ENTER_DELETE_FINGERPRINT_ENTRY = 'ENTER_DELETE_FINGERPRINT_ENTRY';
  public static readonly DELETE_FINGERPRINT_SUBMIT = 'DELETE_FINGERPRINT_SUBMIT';
}

export class HiSysMoreConnectionEventGroup {
  public static readonly ENTER_MORE_CONNECTION_ENTRY = 'ENTER_MORE_CONNECTION_ENTRY';
  public static readonly INTO_MORE_CONNECTIONS = 'INTO_MORE_CONNECTIONS';
  public static readonly ENTER_ADVANCED_SETTINGS = 'ENTER_ADVANCED_SETTINGS';
}

export class HiSysHiWriteEventGroup {
  public static readonly ENTER_HI_WRITE_ENTRY = 'ENTER_HI_WRITE_ENTRY';
}

export class HiSysWlanEvenGroup {
  public static readonly ENTER_WLAN_ENTRY = 'ENTER_WLAN_ENTRY';
  public static readonly ENTER_CONNECTED_WLAN_ENTRY = 'ENTER_CONNECTED_WLAN_ENTRY';
  public static readonly DELETE_CONNECTED_WLAN = 'DELETE_CONNECTED_WLAN';
  public static readonly CONNECT_WLAN = 'CONNECT_WLAN';
  public static readonly WLAN_CONNECT_FAILED = 'WLAN_CONNECT_FAILED';
}

export class HiSysBluetoothEventGroup {
  public static readonly ENTER_BT_BONDED_SETTING_ENTRY = 'ENTER_BT_BONDED_SETTING_ENTRY';
  public static readonly A2DP_SWITCH_CHANGE = 'A2DP_SWITCH_CHANGE';
  public static readonly HFP_SWITCH_CHANGE = 'HFP_SWITCH_CHANGE';
  public static readonly INTO_BLUETOOTH = 'INTO_BLUETOOTH';
  public static readonly CLICK_BLUETOOTH_BUTTON = 'CLICK_BLUETOOTH_BUTTON';
}

export class HiSysDisplayEventGroup {
  public static readonly ENTER_DORMANCY_ENTRY = 'ENTER_DORMANCY_ENTRY';
  public static readonly DARK_MODE_ALL_DAY_SWITCH = 'DARK_MODE_ALL_DAY_SWITCH';
  public static readonly CONTROL_CENTER_DARK_MODE_ALL_DAY = 'CONTROL_CENTER_DARK_MODE_ALL_DAY_SWITCH';
  public static readonly CONTROL_CENTER_DARK_MODE_SCHEDULED = 'CONTROL_CENTER_DARK_MODE_SCHEDULED_SWITCH';
  public static readonly EYE_COMFORT_ENTRY = 'EYE_COMFORT_ENTRY';
  public static readonly EYE_COMFORT_ALL_DAY_SWITCH = 'EYE_COMFORT_ALL_DAY_SWITCH';
  public static readonly EYE_COMFORT_AI_OPEN_SWITCH = 'EYE_COMFORT_AI_OPEN_SWITCH';
  public static readonly DISPLAY_SIZE_ENTRY = 'DISPLAY_SIZE_ENTRY';
  public static readonly DISPLAY_SIZE_SLIDER_CHANGE = 'DISPLAY_SIZE_SLIDER_CHANGE';
  public static readonly EXIT_REPORT_DISPLAY_SIZE = 'EXIT_REPORT_DISPLAY_SIZE';
  public static readonly SLEEP_ENTRY = 'SLEEP_ENTRY';
  public static readonly SCREEN_TIMEOUT_VALUE = 'SCREEN_TIMEOUT_VALUE';
  public static readonly COLOR_AND_COLOR_TEMPERATURE = 'COLOR_AND_COLOR_TEMPERATURE';
  public static readonly COLOR_ADJUSTMENT_RADIO_VALUE = 'COLOR_ADJUSTMENT_RADIO_VALUE';
  public static readonly COLOR_TEMPERATURE_RADIO_VALUE = 'COLOR_TEMPERATURE_RADIO_VALUE';
  public static readonly SCREEN_REFRESH_RATE = 'SCREEN_REFRESH_RATE';
  public static readonly THEME_ENTRY = 'THEME_ENTRY';
  public static readonly INTO_DISPLAY_BRIGHTNESS = 'INTO_DISPLAY_BRIGHTNESS';
  public static readonly CLICK_DARK_COLOR_MODE_BUTTON = 'CLICK_DARK_COLOR_MODE_BUTTON';
  public static readonly OPEN_DARK_COLOR_MODE = 'OPEN_DARK_COLOR_MODE';
  public static readonly CLICK_BRIGHTNESS_ADJUST_BUTTON = 'CLICK_BRIGHTNESS_ADJUST_BUTTON';
  public static readonly MANUALLY_ADJUST_BRIGHTNESS = 'MANUALLY_ADJUST_BRIGHTNESS';
  public static readonly ENTRY_SCREEN_RESOLUTION = 'ENTRY_SCREEN_RESOLUTION';
  public static readonly SELECT_SCREEN_RESOLUTION = 'SELECT_SCREEN_RESOLUTION';
  public static readonly EYE_COMFORT_TIMEON_ENTRY = 'EYE_COMFORT_TIMEON_ENTRY';
}

export class HiSysSettingHomeEventGroup {
  public static readonly INTO_SETTING = 'INTO_SETTING';
  public static readonly ENTER_SYSTEM_NOTIFICATION = 'ENTER_SYSTEM_NOTIFICATION';
  public static readonly ENTER_ASSISTANT = 'ENTER_ASSISTANT';
  public static readonly ENTER_SETTINGS_PAGE = 'ENTER_SETTINGS_PAGE';
}

export class HiSysSearchEventGroup {
  public static readonly CLICK_SEARCH_BUTTON = 'CLICK_SEARCH_BUTTON';
  public static readonly SEARCH_INPUT_VALUE = 'SEARCH_INPUT_VALUE';
  public static readonly QUERY_SEARCH_HISTORY_DATA = 'QUERY_SEARCH_HISTORY_DATA';
  public static readonly CLEAR_SEARCH_HISTORY_DATA = 'CLEAR_SEARCH_HISTORY_DATA';
  public static readonly ENTRY_SEARCH_RESULTS_PAGE = 'ENTRY_SEARCH_RESULTS_PAGE';
}

export class HiSysWlanEventGroup {
  public static readonly INTO_WLAN = 'INTO_WLAN';
  public static readonly WIFI_SWITCH = 'WIFI_SWITCH';
}

export class HiSysNfcEventGroup {
  public static readonly INTO_NFC = 'INTO_NFC';
  public static readonly CLICK_NFC_BUTTON = 'CLICK_NFC_BUTTON';
  public static readonly UPDATE_DEFAULT_NFC_PAY = 'UPDATE_DEFAULT_NFC_PAY';
  public static readonly NFC_NOT_DISTURB = 'NFC_NOT_DISTURB';
}

export class HiSysMobileNetworkEventGroup {
  public static readonly INTO_MOBILE_NETWORK = 'INTO_MOBILE_NETWORK';
  public static readonly ENTER_NETWORK_OPTIMIZATION = 'ENTER_NETWORK_OPTIMIZATION';
  public static readonly NETWORK_OPTIMIZATION_SWITCH = 'NETWORK_OPTIMIZATION_SWITCH';
}

export class HiSysAccessibilityEventGroup {
  public static readonly AUDIO_BALANCE_SLIDER_CHANGE = 'AUDIO_BALANCE_SLIDER_CHANGE';
  public static readonly ENTER_AB_FUNC_SHORT_KEY_ENTRY = 'ENTER_AB_FUNC_SHORT_KEY_ENTRY';
  public static readonly AUDIO_MONO_RADIO_CHANGE = 'AUDIO_MONO_RADIO_CHANGE';
  public static readonly HIGH_CONTRAST_TEXT_SWITCH = 'HIGH_CONTRAST_TEXT_SWITCH';
  public static readonly CHANGE_INVERT_COLOR_TEXT_SWITCH = 'CHANGE_INVERT_COLOR_TEXT_SWITCH';
  public static readonly DALTONIZATION_SWITCH = 'DALTONIZATION_SWITCH';
  public static readonly CHOOSE_COLOR_FILTER_RADIO = 'CHOOSE_COLOR_FILTER_RADIO';
  public static readonly ACCESSIBILITY_FUNCTION_RADIO = 'ACCESSIBILITY_FUNCTION_RADIO';
  public static readonly CHOOSE_TOUCH_DURATION_RADIO = 'CHOOSE_TOUCH_DURATION_RADIO';
  public static readonly SMART_COVER_SWITCH = 'SMART_COVER_SWITCH';
  public static readonly TOUCH_DISABLE_MODE_SWITCH = 'TOUCH_DISABLE_MODE_SWITCH';
  public static readonly SMART_COVER_WITH_WINDOW_SWITCH = 'SMART_COVER_WITH_WINDOW_SWITCH';
  public static readonly SMART_COVER_ENTER = 'SMART_COVER_ENTER';
  public static readonly WAKE_DOUBLE_CLICK_SWITCH = 'WAKE_DOUBLE_CLICK_SWITCH';
  public static readonly WAKE_PICK_UP_SWITCH = 'WAKE_PICK_UP_SWITCH';
  public static readonly TIME_INTERVAL_CHANGE = 'TIME_INTERVAL_CHANGE';
  public static readonly SERVICE_STATE_CHANGE = 'SERVICE_STATE_CHANGE';
  public static readonly CLICK_SELECT_FUNCTION = 'CLICK_SELECT_FUNCTION';
  public static readonly CLICK_SERVICE_SWITCH = 'CLICK_SERVICE_SWITCH';
  public static readonly ZOOM_GESTURE_SWITCH = 'ZOOM_GESTURE_SWITCH';
  public static readonly SHORTKEY_LOCK_SCREEN_SWITCH = 'SHORTKEY_LOCK_SCREEN_SWITCH';
  public static readonly SOUND_RECOG_MAIN_SWITCH = 'SOUND_RECOG_MAIN_SWITCH';
  public static readonly SOUND_RECOG_FIRE_ALARM_SWITCH = 'SOUND_RECOG_FIRE_ALARM_SWITCH';
  public static readonly SOUND_RECOG_BABY_CRYING_SWITCH = 'SOUND_RECOG_BABY_CRYING_SWITCH';
  public static readonly SOUND_RECOG_KNOCK_DOOR_SWITCH = 'SOUND_RECOG_KNOCK_DOOR_SWITCH';
  public static readonly SOUND_RECOG_DOOR_BELL_SWITCH = 'SOUND_RECOG_DOOR_BELL_SWITCH';
  public static readonly SOUND_RECOG_MEOW_SWITCH = 'SOUND_RECOG_MEOW_SWITCH';
  public static readonly SOUND_RECOG_BARK_SWITCH = 'SOUND_RECOG_BARK_SWITCH';
  public static readonly SOUND_RECOG_SERVICE_RECEIVE = 'SOUND_RECOG_SERVICE_RECEIVE';
  public static readonly ZOOM_GESTUIRE_TYPE = 'ZOOM_GESTUIRE_TYPE';
  public static readonly TRANSITION_ANIMATIONS_STATE = 'TRANSITION_ANIMATIONS_STATE';
  public static readonly FLASH_REMIND_MAIN_SWITCH = 'FLASH_REMIND_MAIN_SWITCH';
  public static readonly FLASH_REMIND_CLOCK_SWITCH = 'FLASH_REMIND_CLOCK_SWITCH';
  public static readonly FLASH_REMIND_CALL_SWITCH = 'FLASH_REMIND_CALL_SWITCH';
  public static readonly FLASH_REMIND_NOTIFY_SWITCH = 'FLASH_REMIND_NOTIFY_SWITCH';
  public static readonly ENTER_HEARING_AID_PAGE = 'ENTER_HEARING_AID_PAGE';
  public static readonly ENTER_LEFT_EAR_SWITCH_CHANGE = 'ENTER_LEFT_EAR_SWITCH_CHANGE';
  public static readonly ENTER_RIGHT_EAR_SWITCH_CHANGE = 'ENTER_RIGHT_EAR_SWITCH_CHANGE';
  public static readonly ENTER_UNILATERAL_ADJUST_CHANGE = 'ENTER_UNILATERAL_ADJUST_CHANGE';
  public static readonly ENTER_LEFT_EAR_SLIDER_CHANGE = 'ENTER_LEFT_EAR_SLIDER_CHANGE';
  public static readonly ENTER_RIGHT_EAR_SLIDER_CHANGE = 'ENTER_RIGHT_EAR_SLIDER_CHANGE';
  public static readonly ENTER_BINAURAL_SLIDER_CHANGE = 'ENTER_BINAURAL_SLIDER_CHANGE';
  public static readonly ENTER_CHANGE_DEVICES_NAME = 'ENTER_CHANGE_DEVICES_NAME';
  public static readonly ENTER_CONFIRM_DEVICES_NAME = 'ENTER_CONFIRM_DEVICES_NAME';
  public static readonly ENTER_CANCEL_DEVICES_NAME = 'ENTER_CANCEL_DEVICES_NAME';
  public static readonly ENTER_UPPAIR_HEARING_AID = 'ENTER_UPPAIR_HEARING_AID';
}

export class HiSysSystemEventGroup {
  public static readonly ENTER_LANGUAGE_EDIT_ENTRY = 'ENTER_LANGUAGE_EDIT_ENTRY';
  public static readonly CANCEL_LANGUAGE_EDIT = 'CANCEL_LANGUAGE_EDIT';
  public static readonly ENTER_TIME_ZONE_ENTRY = 'ENTER_TIME_ZONE_ENTRY';
  public static readonly CHANGE_TIME_ZONE = 'CHANGE_TIME_ZONE';
  public static readonly ENTER_RESET_NET_ENTRY = 'ENTER_RESET_NET_ENTRY';
  public static readonly CLICK_RESET_NET = 'CLICK_RESET_NET';
  public static readonly CONFIRM_RESET_NET = 'CONFIRM_RESET_NET';
  public static readonly ENTER_RESET_FACTORY_ENTRY = 'ENTER_RESET_FACTORY_ENTRY';
  public static readonly CLICK_RESET_FACTORY = 'CLICK_RESET_FACTORY';
  public static readonly USB_DEBUG_SWITCH_CHANGE = 'USB_DEBUG_SWITCH_CHANGE';
  public static readonly ENTER_TRANSITION_ANIMATION_ENTRY = 'ENTER_TRANSITION_ANIMATION_ENTRY';
  public static readonly POWER_ON_TIME_SELECT = 'POWER_ON_TIME_SELECT';
  public static readonly POWER_OFF_TIME_SELECT = 'POWER_OFF_TIME_SELECT';
  public static readonly SCHEDULED_REPEAT_SELECT = 'SCHEDULED_REPEAT_SELECT';
  public static readonly SCHEDULED_POWER_OFF = 'SCHEDULED_POWER_OFF';
  public static readonly NETWORK_NAVIGATOR_SWITCH = 'NETWORK_NAVIGATOR_SWITCH';
  public static readonly NETWORK_NAVIGATOR_SCENE_SELECT = 'NETWORK_NAVIGATOR_SCENE_SELECT';
  public static readonly NETWORK_NAVIGATOR_ENTRY = 'NETWORK_NAVIGATOR_ENTRY';
}

export class HiSysVolumeEventGroup {
  public static readonly VOLUME_SETTINGS_INTERNAL_ENTRY = 'VOLUME_SETTINGS_INTERNAL_ENTRY';
  public static readonly VOLUME_MODE_CHANGE = 'VOLUME_MODE_CHANGE';
  public static readonly VOLUME_CALL_CONTROL = 'VOLUME_CALL_CONTROL';
  public static readonly VOLUME_ALARM_CONTROL = 'VOLUME_ALARM_CONTROL';
  public static readonly VOLUME_MEDIA_CONTROL = 'VOLUME_MEDIA_CONTROL';
  public static readonly VOLUME_RINGTONE_CONTROL = 'VOLUME_RINGTONE_CONTROL';
  public static readonly VOLUME_PHONE_RINGTONE = 'VOLUME_PHONE_RINGTONE';
  public static readonly VOLUME_MESSAGE_RINGTONE = 'VOLUME_MESSAGE_RINGTONE';
  public static readonly VOLUME_NOTIFICATION_RINGTONE = 'VOLUME_NOTIFICATION_RINGTONE';
  public static readonly VOLUME_TOUCH_FEEDBACK = 'VOLUME_TOUCH_FEEDBACK';
  public static readonly VOLUME_PHONE_SELECTED = 'VOLUME_PHONE_SELECTED';
  public static readonly VOLUME_MESSAGE_SELECTED = 'VOLUME_MESSAGE_SELECTED';
  public static readonly VOLUME_NOTIFICATION_SELECTED = 'VOLUME_NOTIFICATION_SELECTED';
  public static readonly VOLUME_RINGER_MODE_STATUS = 'VOLUME_RINGER_MODE_STATUS';
  public static readonly VOLUME_STEREO_ENHANCEMENT_STATUS = 'VOLUME_STEREO_ENHANCEMENT_STATUS';
  public static readonly VOLUME_VASSISTANT_CONTROL = 'VOLUME_VASSISTANT_CONTROL';
  public static readonly VOLUME_INTELLIGENT_CALL_SWITCH = 'VOLUME_INTELLIGENT_CALL_SWITCH';
  public static readonly VOLUME_KEY_DEFAULT_CONTROL = 'VOLUME_KEY_DEFAULT_CONTROL';
  public static readonly VOLUME_RINGTONE_VIBRATION_SWITCH = 'VOLUME_RINGTONE_VIBRATION_SWITCH';
}

export class HiSysPcVolumeEventGroup {
  public static readonly VOLUME_OPERATION_FEEDBACK_SWITCH = 'VOLUME_OPERATION_FEEDBACK_SWITCH';
  public static readonly VOLUME_OUTPUT_MUTE_SWITCH = 'VOLUME_OUTPUT_MUTE_SWITCH';
  public static readonly SET_VOLUME = 'SET_VOLUME';
  public static readonly VOLUME_ADJUST_FEEDBACK_SWITCH = 'VOLUME_ADJUST_FEEDBACK_SWITCH';
  public static readonly SET_ALERT_VOLUME = 'SET_ALERT_VOLUME';
  public static readonly CALL_NOISE_REDUCT_SWITCH = 'CALL_NOISE_REDUCT_SWITCH';
  public static readonly CURRENT_AUDITION_PLAY = 'CURRENT_AUDITION_PLAY';
  public static readonly SINGLE_CALL_REINFORCE_SWITCH = 'SINGLE_CALL_REINFORCE_SWITCH';
  public static readonly MULTIPLE_CALL_REINFORCE_SWITCH = 'MULTIPLE_CALL_REINFORCE_SWITCH';
  public static readonly RECORD_NOISE_REDUCT_SWITCH = 'RECORD_NOISE_REDUCT_SWITCH';
  public static readonly VACAL_EXTRACT_SWITCH = 'VACAL_EXTRACT_SWITCH';
  public static readonly VOCAL_CANCEL_SWITCH = 'VOCAL_CANCEL_SWITCH';
  public static readonly INPUT_DEVICE_SELECT = 'INPUT_DEVICE_SELECT';
  public static readonly OUTPUT_DEVICE_SELECT = 'OUTPUT_DEVICE_SELECT';
  public static readonly VOLUME_TOUCH_FEEDBACK = 'VOLUME_TOUCH_FEEDBACK';
}

export class HiSysApplicationServiceEventGroup {
  public static readonly APPLICATION_SERVICE_ENTER = 'APPLICATION_SERVICE_ENTER';
  public static readonly APP_KEEPALIVE_SETTINGS_ENTER = 'APP_KEEPALIVE_SETTINGS_ENTER';
  public static readonly UPDATE_KEEPALIVE_APP_LIST = 'UPDATE_KEEPALIVE_APP_LIST';
  public static readonly KEEPALIVE_APP_STATISTIC = 'KEEPALIVE_APP_STATISTIC';
}

export class HiSysBiometricsPasswordEventGroup {
  public static readonly BIOMETRICS_PASSWORD_ENTER = 'BIOMETRICS_PASSWORD_ENTER';
  public static readonly SET_UP_HYBRID_PASSWORD = 'SET_UP_HYBRID_PASSWORD';
  public static readonly HYBRID_PASSWORD_SET_SUCCESS = 'HYBRID_PASSWORD_SET_SUCCESS';
}

export class HiSysStorageEventGroup {
  public static readonly STORAGE_INTERNAL_ENTER = 'STORAGE_INTERNAL_ENTER';
  public static readonly CLICK_CLEAN_CACHE_BUTTON = 'CLICK_CLEAN_CACHE_BUTTON';
  public static readonly STORAGE_UNINSTALL_APP = 'STORAGE_UNINSTALL_APP';
}

export class HiSysUserEventGroup {
  public static readonly ENTER_CHANGE_USER_NAME_ENTRY = 'ENTER_CHANGE_USER_NAME_ENTRY';
  public static readonly ENTER_USERS_SETTINGS = 'ENTER_USERS_SETTINGS';
  public static readonly ENTER_ADD_USER = 'ENTER_ADD_USER';
  public static readonly ENTER_OOBE_ADD_USER = 'ENTER_OOBE_ADD_USER';
  public static readonly CLICK_PROFILE_PIC = 'CLICK_PROFILE_PIC';
  public static readonly MAX_USER_NUM_REACHED = 'MAX_USER_NUM_REACHED';
  public static readonly CLICK_CURRENT_USER = 'CLICK_CURRENT_USER';
  public static readonly CLICK_DELETE_USER = 'CLICK_DELETE_USER';
  public static readonly CONFIRM_DELETE_USER = 'CONFIRM_DELETE_USER';
  public static readonly ENTER_ADD_DOMAIN_USER = 'ENTER_ADD_DOMAIN_USER';
  public static readonly CLICK_ADD_SERVER_CONFIG = 'CLICK_ADD_SERVER_CONFIG';
  public static readonly CLICK_AUTH_ENTR_ACCT = 'CLICK_AUTH_ENTR_ACCT';
  public static readonly CLICK_ADD_DOMAIN_USER = 'CLICK_ADD_DOMAIN_USER';
  public static readonly BIND_DOMAIN_ENTRY = 'BIND_DOMAIN_ENTRY';
  public static readonly BIND_AUTH_CLICK = 'BIND_AUTH_CLICK';
}

export class HiSysPrivacyEventGroup {
  public static readonly ENTER_HELP_ENTRY = 'ENTER_HELP_ENTRY';
}

export class HiSysAuxiliaryEventGroup {
  public static readonly ENTER_AUXILIARY_FUNCTIONS = 'ENTER_AUXILIARY_FUNCTIONS';
  public static readonly ENTER_COLOR_FILTER_FUNCTIONS = 'ENTER_COLOR_FILTER_FUNCTIONS';
  public static readonly ENTER_ACCESSIBILITY_OPERATION = 'ENTER_ACCESSIBILITY_OPERATION';
  public static readonly ENTER_TOUCH_SCREEN = 'ENTER_TOUCH_SCREEN';
  public static readonly ENTER_WAKE_SCREEN = 'ENTER_WAKE_SCREEN';
  public static readonly ENTER_ACCESSIBILITY_SERVICE = 'ENTER_ACCESSIBILITY_SERVICE';
  public static readonly ENTER_SERVICE_INFO = 'ENTER_SERVICE_INFO';
  public static readonly ENTER_ZOOM_GESTURE_FUNCTIONS = 'ENTER_ZOOM_GESTURE_FUNCTIONS';
  public static readonly ENTER_SOUND_RECOG_PAGE = 'ENTER_SOUND_RECOG_PAGE';
  public static readonly ENTER_FLASH_REMIND_PAGE = 'ENTER_FLASH_REMIND_PAGE';
}

export class HiSysSystemAndUpdatesEventGroup {
  public static readonly ENTER_SOFTWARE_UPDATES = 'ENTER_SOFTWARE_UPDATES';
  public static readonly ENTER_SYSTEM_AND_UPDATES = 'ENTER_SYSTEM_AND_UPDATES';
  public static readonly ENTER_LANGUAGE_AND_REGION = 'ENTER_LANGUAGE_AND_REGION';
  public static readonly UPDATES_LANGUAGE = 'UPDATES_LANGUAGE';
  public static readonly DELETE_LANGUAGE = 'DELETE_LANGUAGE';
  public static readonly EDIT_LANGUAGE = 'EDIT_LANGUAGE';
  public static readonly EDIT_LANGUAGE_CONFIRM = 'EDIT_LANGUAGE_CONFIRM';
  public static readonly ENTER_DATE_TIME = 'ENTER_DATE_TIME';
  public static readonly ENTER_RESET = 'ENTER_RESET';
  public static readonly ENTER_DEVELOPER_OPTIONS = 'ENTER_DEVELOPER_OPTIONS';
  public static readonly TWENTY_FOUR_HOURS_SWITCH = 'TWENTY_FOUR_HOURS_SWITCH';
  public static readonly AUTO_SETTING_SWITCH = 'AUTO_SETTING_SWITCH';
  public static readonly DATE_POP_FRAME = 'DATE_POP_FRAME';
  public static readonly DATE_POP_FRAME_CONFIRM = 'DATE_POP_FRAME_CONFIRM';
  public static readonly TIME_POP_FRAME = 'TIME_POP_FRAME';
  public static readonly TIME_POP_FRAME_CONFIRM = 'TIME_POP_FRAME_CONFIRM';
  public static readonly TIME_ZONE_POP_FRAME = 'TIME_ZONE_POP_FRAME';
  public static readonly TIME_ZONE_POP_FRAME_CONFIRM = 'TIME_ZONE_POP_FRAME_CONFIRM';
  public static readonly PHONE_CLONING = 'PHONE_CLONING';
  public static readonly BACKUP_AND_RESTORE = 'BACKUP_AND_RESTORE';
  public static readonly CHOOSE_PHONE_CARD = 'CHOOSE_PHONE_CARD';
  public static readonly CHOOSE_INPUT_METHOD = 'CHOOSE_INPUT_METHOD';
  public static readonly ENABLE_METHOD_SWITCH = 'ENABLE_METHOD_SWITCH';
  public static readonly COMPLETE_INPUT_MODE_SWITCH = 'COMPLETE_INPUT_MODE_SWITCH';
  public static readonly ENTRY_DEFAULT_INPUT_METHOD = 'ENTRY_DEFAULT_INPUT_METHOD';
  public static readonly SELECT_DIFFERENT_INPUT_METHOD = 'SELECT_DIFFERENT_INPUT_METHOD';
}

export class HiSysElderCareEventGroup {
  public static readonly ELDER_CARE_TOUCH_FEEDBACK_CLICK = 'ELDER_CARE_TOUCH_FEEDBACK_CLICK';
  public static readonly GET_FONT_SCALE_FAILED = 'GET_FONT_SCALE_FAILED';
  public static readonly GET_FONT_WEIGHT_FAILED = 'GET_FONT_WEIGHT_FAILED';
  public static readonly SET_FONT_SCALE_FAILED = 'SET_FONT_SCALE_FAILED';
  public static readonly SET_FONT_WEIGHT_FAILED = 'SET_FONT_WEIGHT_FAILED';
}


export class HiSysCloneAppEventGroup {
  public static readonly CLONE_APP_CENTER = 'CLONE_APP_CENTER';
  public static readonly CLONE_APP_MANAGE = 'CLONE_APP_MANAGE';
  public static readonly CREATE_CLONE_APP = 'CREATE_CLONE_APP';
  public static readonly DELETE_CLONE_APP_DIALOG = 'DELETE_CLONE_APP_DIALOG';
  public static readonly DELETE_CLONE_APP = 'DELETE_CLONE_APP';
  public static readonly CLONE_APP_STATISTIC = 'CLONE_APP_STATISTIC';
}

export class HiSysMouseEventGroup {
  public static readonly MOUSE_STYLE_CURSOR = 'MOUSE_STYLE_CURSOR';
  public static readonly MOUSE_POINT_SIZE = 'MOUSE_POINT_SIZE';
  public static readonly MOUSE_CURRENT_COLOR = 'MOUSE_CURRENT_COLOR';
  public static readonly MOUSE_CURRENT_COLOR_FAULT = 'MOUSE_CURRENT_COLOR_FAULT';
  public static readonly MOUSE_POINT_SPEED = 'MOUSE_POINT_SPEED';
  public static readonly MOUSE_VARIABLE_CHANGE = 'MOUSE_VARIABLE_CHANGE';
}

export class HiSysTouchPadEventGroup {
  public static readonly TOUCHPAD_POINT_SPEED = 'TOUCHPAD_POINT_SPEED';
  public static readonly GESTURE_TAP = 'GESTURE_TAP';
  public static readonly GESTURE_SECONDARY = 'GESTURE_SECONDARY';
}

export class HiSysEnhanceNetmanagerEventGroup {
  public static readonly ENTER_ENHANCE_NETMANAGER_ENTRY = 'ENTER_ENHANCE_NETMANAGER_ENTRY';
  public static readonly INTO_ENHANCE_NETMANAGER = 'INTO_ENHANCE_NETMANAGER';
}

export class HiSysCapsuleEventGroup {
  public static readonly EVENT_BLADDER_CLOUD_SPACE_SHOW = 'EVENT_BLADDER_CLOUD_SPACE_SHOW';
  public static readonly EVENT_BLADDER_CLOUD_SPACE_CLICK = 'EVENT_BLADDER_CLOUD_SPACE_CLICK';
  public static readonly EVENT_BLADDER_FIND_DEVICE_CLICK = 'EVENT_BLADDER_FIND_DEVICE_CLICK';
}

export class HiSysNotDisturbEventGroup {
  public static readonly EVENT_NOT_DISTURB_SWITCH = 'NOT_DISTURB_SWITCH';
  public static readonly EVENT_NOT_DISTURB = 'NOT_DISTURB';
}

export class HiSysRdbEventGroup {
  public static readonly EVENT_NAME = 'SETTINGS_RDB_EXCEPTION';
  public static readonly SETTINGS_DATA_RDB_CORRUPTION = 'SETTINGS_RDB_CORRUPTION';
}

// 电池设置相关
export class HiSysBatteryEventGroup {
  // 允许休眠时通知
  public static readonly SLEEP_NOTIFICATION_ENABLE = 'SLEEP_NOTIFICATION_ENABLE';
  public static readonly WIRELESS_REVERSE_SWITCH = 'WIRELESS_REVERSE_SWITCH';
  public static readonly BATTERY_SAVE_MODE_SWITCH = 'BATTERY_SAVE_MODE_SWITCH';
  public static readonly ENTER_BATTERY = 'ENTER_BATTERY';
  public static readonly BATTERY_PERCENTAGE_SWITCH = 'BATTERY_PERCENTAGE_SWITCH';
  public static readonly ENTER_APP_BATTERY_USAGE_DETAILS = 'ENTER_APP_BATTERY_USAGE_DETAILS';
  public static readonly POWER_SAVE_SUGGESTION_CONFIRM = 'POWER_SAVE_SUGGESTION_CONFIRM';
  public static readonly BATTERY_PERFORMANCE_MODE_SWITCH = 'BATTERY_PERFORMANCE_MODE_SWITCH';
}

// 系统导航AIBAR相关
export class HiSysAiBarEventGroup {
  // AI横条设置
  public static AI_BAR_SWITCH: string = 'AI_BAR_SWITCH';
  // 三键导航开关设置打点
  public static FLOATING_NAV_SWITCH: string = 'FLOATING_NAV_SWITCH';
  // 悬浮球开关打点
  public static FLOATING_BALL_SWITCH: string = 'FLOATING_BALL_SWITCH';
}

// Swing相关
export class HiSysSwingEventGroup {
  // 注视不息屏开关
  public static EYEGAZE_SETTING_VALUE: string = 'EYEGAZE_SETTING_VALUE';
}

export class HiSysHotspotEventGroup {
  public static readonly HOTSPOT_SWITCH = 'HOTSPOT_SWITCH';
  public static readonly UPDATE_HOTSPOT_PASSWORD = 'UPDATE_HOTSPOT_PASSWORD';
  public static readonly CONNECT_DEVICE = 'CONNECT_DEVICE';
  public static readonly ADD_TO_BLOCK_LIST = 'ADD_TO_BLOCK_LIST';
  public static readonly REMOVE_FROM_BLOCK_LIST = 'REMOVE_FROM_BLOCK_LIST';
  public static readonly VIEW_BLOCK_LIST = 'VIEW_BLOCK_LIST';
  public static readonly HOTSPOT_LIMIT_CLICK = 'HOTSPOT_LIMIT_CLICK';
}

export class HiSysNearLinkEventGroup {
  public static readonly NEARLINK_SWITCH = 'NEARLINK_SWITCH';
  public static readonly ENTER_NEAR_LINK_SETTINGS = 'ENTER_NEAR_LINK_SETTINGS';
}

export class HiSysUpdateDeviceEventGroup {
  public static readonly UPDATE_DEVICE_NAME = 'UPDATE_DEVICE_NAME';
}

export class HiSysUpdateAPBANDEventGroup {
  public static readonly UPDATE_AP_BAND = 'UPDATE_AP_BAND';
}

export class HiSysNFCEventGroup {
  public static readonly ENTER_DEFAULT_PAY_APPLICATION = 'ENTER_DEFAULT_PAY_APPLICATION';
}

export class HiSysVolumeGroup {
  public static readonly DIAL_TONE_SWITCH = 'DIAL_TONE_SWITCH';
  public static readonly SCREEN_LOCK_TONE_SWITCH = 'SCREEN_LOCK_TONE_SWITCH';
  public static readonly SCREENSHOT_PROMPT_TONE_SWITCH = 'SCREENSHOT_PROMPT_TONE_SWITCH';
  public static readonly BOOT_SOUND_SWITCH = 'BOOT_SOUND_SWITCH';
  public static readonly VIBRATE_WHEN_RING_SWITCH = 'VIBRATE_WHEN_RING_SWITCH';
  public static readonly VOLUME_TOUCH_FEEDBACK = 'VOLUME_TOUCH_FEEDBACK';
  public static readonly VOLUME_MODE_CHANGE = 'VOLUME_MODE_CHANGE';
  public static readonly UPDATE_RINGTONE = 'UPDATE_RINGTONE';
  public static readonly UPDATE_SMS_RINGTONE = 'UPDATE_SMS_RINGTONE';
  public static readonly UPDATE_NOTIFICATION_RINGTONE = 'UPDATE_NOTIFICATION_RINGTONE';
}

export class HiSysVibrationGroup {
  public static readonly ENTER_RINGTONE_VIBRATION_ENTRY = 'ENTER_RINGTONE_VIBRATION_ENTRY';
  public static readonly SET_RINGTONE_VIBRATION_MODE = 'SET_RINGTONE_VIBRATION_MODE';
  public static readonly ENTER_SMS_RINGTONE_VIBRATE_ENTRY = 'ENTER_SMS_RINGTONE_VIBRATE_ENTRY';
  public static readonly SET_SMS_RINGTONE_VIBRATE_MODE = 'SET_SMS_RINGTONE_VIBRATE_MODE';
  public static readonly ENTER_NOTIFY_RINGTONE_VIBRATE = 'ENTER_NOTIFY_RINGTONE_VIBRATE';
  public static readonly SET_NOTIFY_RINGTONE_VIBRATE_MODE = 'SET_NOTIFY_RINGTONE_VIBRATE_MODE';
}

export class HiSysPasswordGroup {
  public static readonly OTHER_PASSWORD_TYPES = 'OTHER_PASSWORD_TYPES';
}

export class HiSysOtherGroup {
  // 隐私和安全
  public static readonly PRIVACY_AND_SECURITY_ENTRY = 'PRIVACY_AND_SECURITY_ENTRY';
  // 小艺
  public static readonly CELIA_ENTRY = 'CELIA_ENTRY';
  // 畅连通信
  public static readonly CONNECTION_COMMUNICATION_ENTRY = 'CONNECTION_COMMUNICATION_ENTRY';
}

export class HiSysKeyboardGroup {
  public static readonly SET_KEY_BOARD_DELAY = 'SET_KEY_BOARD_DELAY';
  public static readonly SET_KEY_BOARD_REPEAT_RATE = 'SET_KEY_BOARD_REPEAT_RATE';
  public static readonly ENTER_SHORTCUT_INFO_ENTRY = 'ENTER_SHORTCUT_INFO_ENTRY';
  public static readonly ENTER_KEYBOARD_INFORMATION_ENTRY = 'ENTER_KEYBOARD_INFORMATION_ENTRY';
  public static readonly ENTER_KEYBOARD_FIRMWARE_ENTRY = 'ENTER_KEYBOARD_FIRMWARE_ENTRY';
  public static readonly ENTER_INPUT_METHOD_PAGE_ENTRY = 'ENTER_INPUT_METHOD_PAGE_ENTRY';
  public static readonly ENTER_INPUT_METHOD_EXTE_ENTRY = 'ENTER_INPUT_METHOD_EXTE_ENTRY';
}

export class HiSysNetworkGroup {
  // 网络进入WLAN页面
  public static readonly ENTER_WLAN_ENTRY_FORM_NETWORK = 'ENTER_WLAN_ENTRY_FORM_NETWORK';
  // 以太网设置
  public static readonly NETWORK_SET_IFACECONFIG = 'NETWORK_SET_IFACECONFIG';
  // 设置代理服务器
  public static readonly NETWORK_SET_GLOBAL_PROXY = 'NETWORK_SET_GLOBAL_PROXY';
  // 代理服务器无效
  public static readonly PROXY_SERVER_HOST_INVALID = 'PROXY_SERVER_HOST_INVALID';
  // 代理服务忽略列表无效
  public static readonly PROXY_SERVER_IGNORE_INVALID = 'PROXY_SERVER_IGNORE_INVALID';
  // 飞行模式
  public static readonly PC_AIRPLANE_MODE_SWITCH = 'PC_AIRPLANE_MODE_SWITCH';
}

export class HiSysMoreConnectionGroup {
  public static readonly COLLABORATION_ENTRY = 'COLLABORATION_ENTRY';
  public static readonly COLLABORATION_SWITCH = 'COLLABORATION_SWITCH';
  public static readonly SUPER_DESKTOP_SWITCH = 'SUPER_DESKTOP_SWITCH';
  public static readonly KEYBOARD_MOUSE_SHARE_ENTRY = 'KEYBOARD_MOUSE_SHARE_ENTRY';
  public static readonly KEYBOARD_MOUSE_SHARE_SWITCH = 'KEYBOARD_MOUSE_SHARE_SWITCH';
  public static readonly HATTERY_HEALTH_ENTRY = 'HATTERY_HEALTH_ENTRY';
  public static readonly ENTER_WIRELESS_PROJECTION = 'ENTER_WIRELESS_PROJECTION';
}

export class HiSysSpaceManagerGroup {
  public static readonly SPACE_CREATE_EVENT = 'SPACE_CREATE_EVENT';
  public static readonly SPACE_DELETE_EVENT = 'SPACE_DELETE_EVENT';
}

export class HiSysAccountRecommendationGroup {
  // 账号建议胶囊展示
  public static readonly ACC_RECOMMENDATION_CAPSULE = 'ACC_RECOMMENDATION_CAPSULE';

  // 进入账号建议列表页
  public static readonly ACC_RECOMMENDATION_PAGE_ENTRY = 'ACC_RECOMMENDATION_PAGE_ENTRY';
}

// 桌面和个性化相关
export class HiSysDesktopAndStyleGroup {
  public static readonly UPDATE_ICON_STYLE = 'UPDATE_ICON_STYLE';
  public static readonly UPDATE_ICON_SIZE = 'UPDATE_ICON_SIZE';
}