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

import { LengthMetrics } from '@ohos.arkui.node';
import { Want } from '@kit.AbilityKit';

export enum NavEntryKey {
  WLAN_MAC_ENTRY = 'WLAN_MAC',
  BLUETOOTH_ENTRY = 'bluetooth_entry',
  WIFI_ENTRY = 'wifi_entry',
  OOBE_WIFI_ENTRY = 'oobe_wifi_entry',
  STORAGE_MORE_CARD = 'setting_storage_moreCard',
  OOBE_UI_EXTENSION_WIFI_ENTRY = 'oobe_wifi_ui_extension_entry',
  EXTERNAL_WIFI_ENTRY = 'external_wifi_entry',
  MOBILE_ENTRY = 'mobile_network_entry',
  THEME_ENTRY = 'theme_settings',
  CENTRAL_AXIS_PERSONALIZATION_ENTRY = 'central_axis_personalization_entry',
  WALLPAPER_PICKER_ENTRY = 'theme_wallpaper',
  DESKTOP_STYLE_ENTRY = 'desktop_style',
  DISPLAY_ENTRY = 'display_settings',
  SCREEN_ZOOM = 'screen_zoom',
  DARK_SETTINGS = 'dark_settings',
  ADVANCED_SETTINGS = 'advanced_setting',
  ADVANCED_SETTINGS_ENTRY = 'advanced_setting_entry',
  AOD_SETTINGS_ENTRY = 'aod_settings_entry',
  AOD_STYLE_ENTRY = 'aod_style_entry',
  SCREEN_MODE_ENTRY = 'screen_mode',
  VOLUME_ENTRY = 'volume_settings',
  RING_TONE_ENTRY = 'ring_tone_settings',
  MESSAGING_TONE_ENTRY = 'Messaging_tone_settings',
  NOTIFICATION_TONE_ENTRY = 'notification_tone_settings',
  MORE_CONNECTION_ENTRY = 'more_connections_settings',
  WIRELESS_PROJECTION_ENTRY = 'wireless_projection_settings',
  WIRELESS_TRUSTED_DEVICE_ENTRY = 'wireless_trusted_settings',
  MORE_COLLABORATION_SETTINGS_ENTRY = 'more_collaboration_settings',
  FAR_FIELD_COMMUNICATION_SERVICE_PRIVACY = 'far_field_communication_service_privacy',
  VPN_SETTINGS_ENTRY = 'vpn_settings',
  VPN_EDIT_ENTRY = 'vpn_edit',
  BIOMETRICS_PASSWORD_ENTRY = 'biometrics_and_password_settings',
  RECOVERKEY_CREATE_ENTRY = 'recoverkey_create_dialog_settings',
  RECOVER_KEY_RESET_PSW_UPLOAD_ENTRY = 'recover_key_reset_password_upload_settings',
  APPLICATION_SERVICE_ENTRY = 'application_and_service_settings',
  BATTERY_ENTRY = 'battery',
  STORAGE_ENTRY = 'storage_settings',
  STORAGE_UNINSTALL = 'storage_uninstall_settings',
  STORAGE_APP_ITEM = 'setting_storage_appItem',
  STORAGE_SYSTEM_FILE = 'storage_system_file',
  PRIVACY_ENTRY = 'privacy_settings',
  PRIVACY_ENTRY_INNER = 'privacy_settings_inner',
  USERS_ACCOUNT_ENTRY = 'users_accounts',
  SYSTEM_UPDATE_ENTRY = 'system_and_updates',
  ABOUT_DEVICE_ENTRY = 'about_device',
  WIFI_MENU_ENTRY = 'wifi_menu',
  OPEN_NETWORK_ENTRY = 'open_network_entry',
  OPEN_BLUETOOTH_INFO_ENTRY = 'open_bluetooth_info_entry',
  WIFI_MENU_CONFIG_ENTRY = 'wifi_config_menu',
  WIFI_PRECISION_MENU_ENTRY = 'wifi_precision_menu',
  BLUETOOTH_BONDED_ENTRY = 'bluetooth_bonded_entry',
  FUSION_BONDED_ENTRY = 'fusion_bonded_entry',
  BLUETOOTH_BONDED_DEVICE_UPDATE_NAME_ENTRY = 'bluetooth_bonded_device_update_name_entry',
  TIME_ZONE_ENTRY = 'time_zone_settings',
  DATA_TIME_ENTRY = 'date_and_time',
  FONT_MANAGE = 'font_manage',
  EMPTY_FONT = 'empty_font',
  INPUT_ENTRY = 'set_input',
  SET_LANGUAGE_ENTRY = 'set_language',
  LANGUAGE_REGION_ENTRY = 'set_language_region',
  RESET_ENTRY = 'reset_settings',
  DEVICE_AND_APPLICATION_ENTRY = 'device_and_application',
  SPACE_MANAGER_ENTRY = 'space_manager',
  ENTERPRISE_DEVICE_MANAGEMENT_ENTRY = 'enterprise_device_management_settings',
  ENTERPRISE_APPLICATION_MANAGEMENT_ENTRY = 'enterprise_application_management_settings',
  DEVELOP_OPTION_ENTRY = 'developer_options_settings',
  INSIGHT_INTENT_DEBUG_SETTING_ENTRY = 'insight_intent_settings',
  NFC_ENTRY = 'nfc_settings',
  BLOCK_LIST_ENTRY = 'block_list_entry',
  PAD_COCKPIT_ENTRY = 'pad_cockpit_setting',
  HOTSPOT_ENTRY = 'hotspot_data_settings',
  HOTSPOT_PWD_ENTRY = 'password_entry',
  HOTSPOT_CONNECTED_ENTRY = 'connected_device_entry',
  HOTSPOT_SHARE_ENTRY = 'more_share_entry',
  LOCK_SCREEN_PASSWORD_ENTRY = 'lock_screen_password_title',
  CHANGE_LOCK_SCREEN_PASSWORD_ENTRY = 'change_lock_screen_password_title',
  CLOSE_LOCK_SCREEN_PASSWORD_ENTRY = 'close_lock_screen_password_title',
  DISABLE_OLD_LOCK_SCREEN_PASSWORD_ENTRY = 'disable_old_lock_screen_password_title',
  CREATE_NUMBER_PSD_ENTRY = 'change_six_to_number_entry',
  CREATE_MIX_PSD_ENTRY = 'change_six_to_mixed_entry',
  CREATE_FOUR_PSD_ENTRY = 'change_to_four_entry',
  CHECK_PSD_ENTRY = 'check_psd_entry',
  AUTHORIZATION_ENTRY = 'Authorization_entry',
  APPLICATION_LIST_ENTRY = 'application_settings',
  APPLICATION_INFO_ENTRY = 'application_info_entry',
  APPLICATION_NETWORKING_ENTRY = 'application_networking_entry',
  OTHER_INPUT_DETAIL_SETTINGS = 'other_input_detail_settings',
  INPUT_UIEXTENSION = 'input_uiextension',
  INPUT_UIEXTENSION_LIST = 'input_uiextension_list',
  LOCATION_MANAGER_ENTRY = 'location_manager_settings',
  LOCATION_HELP_ENTRY = 'location_help_entry',
  EDIT_LANGUAGE_ENTRY = 'edit_language_entry',
  ADD_LANGUAGE_ENTRY = 'add_language_entry',
  SELECT_REGION_ENTRY = 'select_region_entry',
  RESET_FACTORY = 'reset_factory_settings',
  RESET_NET = 'reset_net_settings',
  CONFIRM_RESET_FACTORY_ENTRY = 'reset_confirm_settings',
  CONFIRM_RESET_NET_ENTRY = 'reset_net_confirm_settings',
  PC_CONFIRM_RESET_FACTORY_ENTRY = 'reset_factory_button',
  ADMIN_USER_ENTRY = 'admin_user_entry',
  ACCESSIBILITY_SERVICE_ENTRY = 'accessibility_service_entry',
  ACCESSIBILITY_LIST_ENTRY = 'accessibility_list_entry',
  SMART_COVER_OPERATION_ENTRY = 'smart_cover_operation_entry',
  TOUCH_DISABLE_MODE_ENTRY = 'touch_disable_mode_entry',
  ACCESSIBILITY_COLOR_FILTER_ENTRY = 'accessibility_color_filter_entry',
  ACCESSIBILITY_SOUND_RECOGNITION_ENTRY = 'accessibility_sound_recognition_entry',
  ACCESSIBILITY_FLASH_REMINDER_ENTRY = 'accessibility_flash_reminder_entry',
  ACCESSIBILITY_ZOOM_GESTURE_ENTRY = 'accessibility_zoom_gesture_entry',
  ACCESSIBILITY_HIGH_CONTRAST_TEXT_ENTRY = 'accessibility_high_contrast_text_entry',
  ACCESSIBILITY_INVERT_COLOR_ENTRY = 'accessibility_invert_color_entry',
  ACCESSIBILITY_TRANSITION_ANIMATIONS_ENTRY = 'accessibility_transition_animations_entry',
  ACCESSIBILITY_AUDIO_ADJUSTMENT_ENTRY = 'accessibility_audio_adjustment_entry',
  ACCESSIBILITY_WAKE_SCREEN_ENTRY = 'accessibility_wake_screen_entry',
  ACCESSIBILITY_MORE_SETTINGS_ENTRY = 'accessibility_more_settings_entry',
  ACCESSIBILITY_ELDER_CARE_ENTRY = 'accessibility_elder_care_entry',
  ACCESSIBILITY_ELDER_CARE_SOS_ENTRY = 'accessibility_elder_care_sos_entry',
  ACCESSIBILITY_ELDER_CARE_CALL_FILTER_ENTRY = 'accessibility_elder_care_call_filter_entry',
  ACCESSIBILITY_ELDER_CARE_TIPS_ENTRY = 'accessibility_elder_care_tips_entry',
  FINGERPRINT_SETTING_ENTRY = 'fingerprint_settings_entry',
  UNDER_SCREEN_FINGERPRINT_INTRO_ENTRY = 'under_screen_fingerprint_intro_entry',
  UNDER_SCREEN_FINGERPRINT_ENROLL_ENTRY = 'under_screen_fingerprint_enroll_entry',
  OUT_SCREEN_FINGERPRINT_ENROLL_ENTRY = 'out_screen_fingerprint_enroll_entry',
  INNER_SCREEN_FINGERPRINT_ENROLL_ENTRY = 'inner_screen_fingerprint_enroll_entry',
  EXTERNAL_SCREEN_FINGERPRINT_ENROLL_ENTRY = 'external_screen_fingerprint_enroll_entry',
  MULTI_FINGERPRINT_INTRO_ENTRY = 'multi_fingerprint_intro_entry',
  FINGERPRINT_DECLARATION_ENTRY = 'fingerprint_declaration_entry',
  CONFIGURATION_OPTION_ENTRY = 'configuration_options_settings',
  USER_SETTING_ENTRY = 'users_settings',
  PC_NETWORK_SETTINGS = 'pc_network_settings',
  PC_NETWORK_PROXY_SETTINGS = 'pc_network_proxy_settings',
  NETWORK_SETTINGS = 'network_settings',
  PC_AUDIO_SETTINGS = 'pc_audio_settings',
  SOUND_EFFECT_DETAIL = 'sound_effect_detail',
  PC_APP_SETUP_SETTINGS = 'pc_app_setup_settings',
  PC_APP_ACC_SERVICE_SETTINGS = 'pc_app_acceleration_service_settings',
  PC_KEYBOARD_SETTINGS = 'pc_keyboard',
  PC_MOUSE_SETTINGS = 'pc_mouse_settings',
  PHONE_MOUSE_SETTINGS = 'phone_mouse_settings',
  PC_APP_KEEPALIVE_SETTINGS = 'pc_app_keepalive_settings',
  PC_NOTIFICATION_SETTINGS = 'systemui_notification_settings',
  SOS_EMERGENCY_HELP_ENTRY = 'sos_emergency_help_entry',
  PHONE_NOTIFICATION_SETTINGS_ENTRY = 'systemui_notification_settings',
  NOTIFICATION_SETTINGS_DETAIL_ENTRY = 'systemui_notification_detail_settings',
  PC_TRACKPAD_SETTINGS = 'pc_trackpad_settings',
  FACE_SETTING_ENTRY = 'face_settings_entry',
  FACE_AUTH_PREFERENCE_ENTRY = 'FaceAuthPreference',
  FACE_AUTH_FEATURE_GUIDE_ENTRY = 'FaceAuthFeatureGuide',
  FACE_AUTH_ENROLL_ENTRY = 'FaceAuthEnroll',
  FACE_AUTH_ENROLL_GUIDE_3D_ENTRY = 'FaceAuthEnrollGuide3D',
  FACE_AUTH_DECLARATION_3D_ENTRY = 'FaceAuthDeclaration3d',
  FACE_AUTH_DECLARATION_2D_ENTRY = 'FaceAuthDeclaration2d',
  FACE_AUTH_MASK_GUIDE_ENTRY = 'FaceAuthMaskGuide',
  EID_DETAIL_ENTRY = 'eid_detail_entry',
  STATUS_INFO_SETTING = 'status_information_settings',
  NETWORK_INFO_SETTING = 'network_information_settings',
  LEGAL_INFO_SETTING = 'legal_information_settings',
  APP_OPEN_SOURCE_SHOW = 'AppOpenSourceShow',
  APP_OPEN_SOURCE_STATEMENT_ENTRY = 'app_open_source_statement_entry',
  ENTERPRISE_CUSTOM_INFO_ENTRY = 'enterprise_custom_information_entry',
  VERSION_TYPE_ENTRY = 'version_type_entry',
  BASIC_SERVICE_SHOW = 'BasicServiceShow',
  ACCESSIBILITY_SCREEN_READER_ENTRY = 'accessibility_screen_reader_entry',
  SCREEN_READER_MORE_SETTINGS_ENTRY = 'screen_reader_more_settings_entry',
  SCREEN_READER_VOICE_SETTING_ENTRY = 'screen_reader_voice_setting_entry',
  SCREEN_READER_INTELLIGENT_IDENTIFICATION_ENTRY = 'screen_reader_intelligent_identification_entry',
  SCREEN_READER_CUSTOMIZE_SHORTCUT_GESTURE_ENTRY = 'screen_reader_customize_shortcut_gestures_entry',
  SCREEN_READER_IN_CALL_GESTURE_CUSTOM_ENTRY = 'screen_reader_in_call_gesture_custom_entry',
  SCREEN_READER_SHORTCUT_MENU_CONFIGURATION_ENTRY = 'screen_reader_shortcut_menu_configuration_entry',
  ACCESSIBILITY_SOUND_REPAIR_ENTRY = 'voicefix_setting',
  ACCESSIBILITY_HEARING_AID_ENTRY = 'hearing_aid',
  ACCESSIBILITY_HEARING_AID_NAME_ENTRY = 'hearing_aid_name',
  ADD_ESIM_PROFILE_ENTRY = 'add_esim_profile_entry',
  AUDIO_BUTLER_ENTRY = 'audio_butler',
  MOBILE_DATA_SETTING_ENTRY = 'mobile_data_setting_entry',
  DATA_USAGE_MANAGEMENT_ENTRY = 'mobile_data_manage_entry',
  OUC_SOFTWARE_UPDATE_SETTINGS = 'com_hmos_ouc_software_update_settings',
  OUC_PARAM_VERSION = 'com_hmos_ouc_param_version_settings',
  OUC_ALL_SCENE_UPDATE_ENTRY = 'com_hmos_ouc_all_scene_update',
  PC_PRINTERS_AND_SCANNERS = 'pc_printers_and_scanners',
  SCAN_CODE_ENTRY = 'scan_code',
  QUICK_PAY_ENTRY = 'quick_pay',
  POWER_CONSUMPTION_ENTRY = 'power_consumption_entry',
  DEFAULT_BROWSER_ENTRY = 'default_browser_settings',
  DEFAULT_MAIL_ENTRY = 'default_mail_settings',
  ADD_OTHER_WIFI_ENTRY = 'add_other_wifi_entry',
  WIFI_SETUP_PROXY_ENTRY = 'wifi_setup_proxy_entry',
  WIFI_SETUP_IP_ENTRY = 'wifi_setup_ip_entry',
  SYSTEM_ROLLBACK_ENTRY = 'system_rollback_entry',
  EYE_COMFORT_MODE = 'eye_comfort_mode',
  APPLICATION_PERMISSION_SETTINGS_ENTRY = 'application_permission_settings',
  APPLICATION_RESTORE_ENTRY = 'application_restore_settings',
  MORE_APPLICATION_ENTRY = 'more_application_settings',
  HI_WRITE_SETTINGS_ENTRY = 'hi_write_settings',
  PC_HI_WRITE_SETTINGS_ENTRY = 'pc_hi_write_settings',
  PAD_KEYBOARD_SETTINGS_ENTRY = 'pad_keyboard_settings_entry',
  PAD_KEYBOARD_FIRMWARE_UPGRADE = 'pad_keyboard_firmware_upgrade',
  PAD_KEYBOARD_INFORMATION = 'pad_keyboard_info_entry',
  PAD_TOUCHPAD_SETTINGS_ENTRY = 'pad_touchpad_settings_entry',
  PAD_PRINTER_SETTINGS_ENTRY = 'pad_print_settings_entry',
  USB_DEBUG = 'usb_debug',
  SYSTM_WIRELESS_COMMISSIONING = 'system_wireless_commissioning',
  WRIELLESS_COMMISSIONING = 'wireless_commissioning',
  GLOBAL_SEARCH_ENTRY = 'global_search_entry',
  ONE_TOUCH_ENTRY = 'one_touch_entry',
  DEVICE_INTERCONNECTIVITY_ENTRY = 'device_interconnectivity_entry',
  PC_POWERANDBATTERY_SETTINGS = 'pc_powerandbattery_settings',
  DEFAULT_PAYMENT_APPLICATION = 'default_payment_application',
  PAYMENT_APPLICATION = 'payment_application',
  DESKTOP_SETTINGS = 'desktop_settings',
  VERSION = 'version',
  SCREEN_GROUP_ENTRY = 'screen_group',
  SCREEN_SETTING_ENTRY = 'screen_setting',
  BRIGHTNESS_GROUP_ENTRY = 'brightness_group',
  NEAR_LINK_ENTRY = 'near_link_settings',
  START_FIND_DEVICE_ENTRY = 'start_find_device',
  NEAR_LINK_BOND_DEVICE_SETTINGS_ENTRY = 'near_link_bond_device_settings',
  SMART_MULTI_WINDOW_ENTRY = 'smart_multi_window',
  MULTI_WINDOW_FORCE_SWITCH_ENTRY = 'multi_window_force_switch',
  MULTI_WINDOW_LINKAGE_SCENE_PRIVACY_ENTRY = 'multi_window_linkage_scene_privacy',
  LANDSCAPE_STARTUP_ENTRY = 'forced_landscape',
  DEVICE_AND_APPLICATION_MANAGER = 'device_and_application_manager',
  SYSTEM_NAVIGATION = 'ai_bar_settings',

  // 手势通话
  GESTURE_MUTE_CALL_ENTRY = 'gesture_mute_call',
  GESTURE_QUICK_CALL_ENTRY = 'gesture_quick_call',
  WIFI_INSTALL_CERTIFICATE_ENTRY = 'wifi_install_certificate',
  WLAN_PRIVACY_STATEMENT = 'wlan_privacy_statement',
  CLONE_APP_MANAGER = 'clone_app_manager',
  CLONE_APP_DETAIL = 'clone_app_detail',
  CLONE_APP_AUTH = 'clone_app_auth',
  START_WALLET_ENTRY = 'start_wallet',
  PC_MORE_POWER_SETTINGS = 'pc_more_power_settings',
  SUBSCRIBE_PAGE_ENTRY = 'iap_settings',
  ACCOUNT_RECOMMENDATION_PAGE_ENTRY = 'account_recommendation',
  CAPSULE_PAGE_ENTRY = 'capsule',
  CLOUD_SPACE_ENTRY = 'cloud_space',
  FIND_DEVICE_ENTRY = 'find_device',
  FINGERPRINT_ANIMATION_ENTRY = 'fingerprint_animation_entry',
  FINGERPRINT_CAROUSEL_ENTRY = 'fingerprint_carousel_entry',
  UNDER_SCREEN_FINGERPRINT_IDENTIFICATION_ENTRY = 'under_screen_fingerprint_identification_entry',
  NOT_DISTURB_ENTRY = 'not_disturb_entry',
  TIME_PERIOD_ENTRY = 'time_period_entry',
  INCOMING_CALL_ENTRY = 'incoming_call',
  MUSIC_SERVICE = 'music_service',
  // 振动服务
  VIBRATE_SERVICE = 'vibrate_service',
  //深色模式定时
  EYE_COMFORT_MODE_TIMEON = 'eye_comfort_mode_time_on',
  LOCAL_BACKUP_DATA = 'local_backup_data',
  UPGRADING_DATA = 'upgrading_data',
  COMMON_PAGE = 'common_page',
  COMMON_ITEM_PAGE = 'common_item_page',
  UNIVERSAL_DRAG_ENTRY = 'universal_drag',
  // 情景模式
  INTELLIGENT_SCENE_SETTINGS_ENTRY = 'intelligent_scene_entry',
  // 推荐建议
  HOMEPAGE_SUGGESTION_MORE_PAGE = 'homepage_suggestion_more_page',
  // 额外输入法设置，点小艺输入法进入
  INPUT_METHOD_UI_EXTENSION_PAGE = 'input_ui_extension_page',
  // 输入法设置，点其他输入法进入
  PC_INPUT_METHOD_PAGE = 'input_method_page',
  // Pc键盘固件升级
  PC_KEYBOARD_FIRMWARE_UPGRADE = 'pc_keyboard_firmware_upgrade',
  // 外接键盘信息
  PC_KEYBOARD_INFORMATION = 'pc_keyboard_info_entry',
  MOUSE_FIRMWARE_UPGRADE = 'mouse_firmware_upgrade', // 鼠标固件升级
  PENG_LAI_HOME_PAGE = 'Setting.PengLaiHome',
  GRIP_POSTURE_FOLLOW_ENTRY = 'grip_posture_follow_entry',
  SYSTEM_WORDS_ENTRY = 'system_select_words',
  HDR_PIC_SWITCH_ENTRY = 'hdr_pic_switch_entry',
  HDR_VIDEO_SWITCH_ENTRY = 'hdr_video_switch_entry',
  PIC_BIONIC_VISION_SWITCH_ENTRY = 'pic_bionic_vision_switch_entry',
}

export const BLOCK_URI_LIST: Set<string> = new Set([
  NavEntryKey.HOTSPOT_PWD_ENTRY, NavEntryKey.CONFIRM_RESET_NET_ENTRY, NavEntryKey.CONFIRM_RESET_FACTORY_ENTRY,
  NavEntryKey.FINGERPRINT_SETTING_ENTRY, NavEntryKey.UNDER_SCREEN_FINGERPRINT_INTRO_ENTRY,
  NavEntryKey.UNDER_SCREEN_FINGERPRINT_ENROLL_ENTRY, NavEntryKey.FACE_SETTING_ENTRY,
  NavEntryKey.CREATE_NUMBER_PSD_ENTRY, NavEntryKey.CREATE_MIX_PSD_ENTRY,
  NavEntryKey.OUT_SCREEN_FINGERPRINT_ENROLL_ENTRY, NavEntryKey.CHECK_PSD_ENTRY,
  NavEntryKey.FACE_AUTH_PREFERENCE_ENTRY, NavEntryKey.FACE_AUTH_FEATURE_GUIDE_ENTRY,
  NavEntryKey.FACE_AUTH_ENROLL_ENTRY, NavEntryKey.FACE_AUTH_ENROLL_GUIDE_3D_ENTRY,
  NavEntryKey.FACE_AUTH_DECLARATION_3D_ENTRY, NavEntryKey.FACE_AUTH_DECLARATION_2D_ENTRY,
  NavEntryKey.FACE_AUTH_MASK_GUIDE_ENTRY, NavEntryKey.PC_APP_SETUP_SETTINGS,
  NavEntryKey.START_WALLET_ENTRY, NavEntryKey.START_FIND_DEVICE_ENTRY,
  NavEntryKey.PC_CONFIRM_RESET_FACTORY_ENTRY, NavEntryKey.AUTHORIZATION_ENTRY,
  NavEntryKey.USERS_ACCOUNT_ENTRY,
]);

export const WALLET_BLOCK_URI_LIST: Set<string> = new Set([
  NavEntryKey.HOTSPOT_PWD_ENTRY, NavEntryKey.CONFIRM_RESET_NET_ENTRY, NavEntryKey.CONFIRM_RESET_FACTORY_ENTRY,
  NavEntryKey.FINGERPRINT_SETTING_ENTRY, NavEntryKey.UNDER_SCREEN_FINGERPRINT_INTRO_ENTRY,
  NavEntryKey.UNDER_SCREEN_FINGERPRINT_ENROLL_ENTRY, NavEntryKey.FACE_SETTING_ENTRY,
  NavEntryKey.OUT_SCREEN_FINGERPRINT_ENROLL_ENTRY,
  NavEntryKey.FACE_AUTH_PREFERENCE_ENTRY, NavEntryKey.FACE_AUTH_FEATURE_GUIDE_ENTRY,
  NavEntryKey.FACE_AUTH_ENROLL_ENTRY, NavEntryKey.FACE_AUTH_ENROLL_GUIDE_3D_ENTRY,
  NavEntryKey.FACE_AUTH_DECLARATION_3D_ENTRY, NavEntryKey.FACE_AUTH_DECLARATION_2D_ENTRY,
  NavEntryKey.FACE_AUTH_MASK_GUIDE_ENTRY,
  NavEntryKey.PC_APP_SETUP_SETTINGS, NavEntryKey.SYSTM_WIRELESS_COMMISSIONING,
  NavEntryKey.START_WALLET_ENTRY, NavEntryKey.START_FIND_DEVICE_ENTRY,
  NavEntryKey.PC_CONFIRM_RESET_FACTORY_ENTRY, NavEntryKey.AUTHORIZATION_ENTRY,
  NavEntryKey.INSIGHT_INTENT_DEBUG_SETTING_ENTRY,
]);

export const NOT_DEVELOPER_BLOCK_URI_LIST: Set<string> = new Set([
  NavEntryKey.DEVELOP_OPTION_ENTRY, NavEntryKey.SYSTEM_ROLLBACK_ENTRY,
  NavEntryKey.SYSTM_WIRELESS_COMMISSIONING, NavEntryKey.INSIGHT_INTENT_DEBUG_SETTING_ENTRY
]);

export const SYSTEM_APP_URI_LIST: Set<string> = new Set([
  NavEntryKey.LOCK_SCREEN_PASSWORD_ENTRY
]);

export enum DisplayKey {
  REFRESH_RATE_DYNAMIC = 'refresh_rate_dynamic',
  REFRESH_RATE_HIGH = 'refresh_rate_high',
  REFRESH_RATE_MID = 'refresh_rate_mid',
  REFRESH_RATE_STANDARD = 'refresh_rate_standard',
}

export const BACK_ENTRY: string = 'back_url';

export const pagePathMap: Map<string, string> = new Map<string, string>([
  [NavEntryKey.BLUETOOTH_ENTRY, '../bluetooth/BluetoothSettings'],
  [NavEntryKey.WIFI_ENTRY, '../wifi/WifiSettings'],
  [NavEntryKey.WLAN_MAC_ENTRY, '../aboutdevice/StatusInformationSetting'],
  [NavEntryKey.MOBILE_ENTRY, '../mobilenetwork/MobileNetworkSettings'],
  [NavEntryKey.DISPLAY_ENTRY, '../display/DisplaySettings'],
  [NavEntryKey.VOLUME_ENTRY, '../volume/VolumeSettings'],
  [NavEntryKey.RING_TONE_ENTRY, '../volume/RingToneSettings'],
  [NavEntryKey.MESSAGING_TONE_ENTRY, '../volume/MessagingTone'],
  [NavEntryKey.NOTIFICATION_TONE_ENTRY, '../volume/NotificationTone'],
  [NavEntryKey.MORE_CONNECTION_ENTRY, '../moreconnection/MoreConnectionSettings'],
  [NavEntryKey.BIOMETRICS_PASSWORD_ENTRY, '../biometricsandpassword/BiometricsAndPasswordSettings'],
  [NavEntryKey.FINGERPRINT_SETTING_ENTRY, '../biometricsandpassword/module/fingerprint/Fingerprint'],
  [NavEntryKey.APPLICATION_SERVICE_ENTRY, '../applicationandservice/ApplicationAndServiceSettings'],
  [NavEntryKey.STORAGE_ENTRY, '../storage/StorageSettings'],
  [NavEntryKey.BATTERY_ENTRY, '../battery/BatterySettings'],
  [NavEntryKey.POWER_CONSUMPTION_ENTRY, '../battery/PowerConsumptionSettings'],
  [NavEntryKey.PRIVACY_ENTRY, '../privacy/PrivacySettings'],
  [NavEntryKey.USERS_ACCOUNT_ENTRY, '../users/UsersAccountsSettings'],
  [NavEntryKey.SYSTEM_UPDATE_ENTRY, '../system/SystemAndUpdatesSettings'],
  [NavEntryKey.ABOUT_DEVICE_ENTRY, '../aboutdevice/AboutDeviceSettings'],
  [NavEntryKey.WIFI_MENU_ENTRY, '../wifi/WifiPasswordSettings'],
  [NavEntryKey.WIFI_PRECISION_MENU_ENTRY, '../wifi/WifiPrecisionSetting'],
  [NavEntryKey.BLUETOOTH_BONDED_ENTRY, '../bluetooth/BluetoothBondedDeviceSettings'],
  [NavEntryKey.AUDIO_BUTLER_ENTRY, '../audiobutler/AudioButlerSettings'],
  [NavEntryKey.DATA_TIME_ENTRY, '../datetime/DateAndTimeSettings'],
  [NavEntryKey.TIME_ZONE_ENTRY, '../datetime/TimeZoneSettings'],
  [NavEntryKey.SET_LANGUAGE_ENTRY, '../system/languageSettings/LanguageSettingsHome'],
  [NavEntryKey.LANGUAGE_REGION_ENTRY, '../system/languageSettings/languageAndRegion/LanguageAndRegionPage'],
  [NavEntryKey.RESET_ENTRY, '../reset/ResetSettings'],
  [NavEntryKey.DEVELOP_OPTION_ENTRY, '../developeroptions/DeveloperOptionsSettings'],
  [NavEntryKey.PAD_COCKPIT_ENTRY, '../moreconnection/PadCockpitSetting'],
  [NavEntryKey.MORE_COLLABORATION_SETTINGS_ENTRY, '../moreconnection/MoreMultiDeviceCollaborationSettings'],
  [NavEntryKey.VPN_SETTINGS_ENTRY, '../vpn/VpnListSettings'],
  [NavEntryKey.VPN_EDIT_ENTRY, '../vpn/VpnEditComponent'],
  [NavEntryKey.LOCK_SCREEN_PASSWORD_ENTRY, '../password/CreateSixPinSettings'],
  [NavEntryKey.CREATE_NUMBER_PSD_ENTRY, '../password/CreateNumberPsdSettings'],
  [NavEntryKey.CREATE_MIX_PSD_ENTRY, '../password/CreateMixedPsdSettings'],
  [NavEntryKey.CREATE_FOUR_PSD_ENTRY, '../password/CreateFourPinSettings'],
  [NavEntryKey.CHECK_PSD_ENTRY, '../password/CheckPasswordSettings'],
  [NavEntryKey.AUTHORIZATION_ENTRY, '../loadAuthorizationSettings'],
  [NavEntryKey.APPLICATION_LIST_ENTRY, '../application/ApplicationSettings'],
  [NavEntryKey.APPLICATION_INFO_ENTRY, '../application/ApplicationInfoSettings'],
  [NavEntryKey.OTHER_INPUT_DETAIL_SETTINGS, '../input/otherInputDetailSettings'],
  [NavEntryKey.INPUT_UIEXTENSION_LIST, '../input/uiExtensionList'],
  [NavEntryKey.PC_APP_SETUP_SETTINGS, '../application/component/AppSetupSettings'],
  [NavEntryKey.PC_APP_ACC_SERVICE_SETTINGS, '../application/component/AppSetupSettings'],
  [NavEntryKey.LOCATION_MANAGER_ENTRY, '../privacy/LocationServiceSettings'],
  [NavEntryKey.LOCATION_HELP_ENTRY, '../privacy/LocationHelpSettings'],
  [NavEntryKey.EDIT_LANGUAGE_ENTRY, '../system/languageSettings/languageAndRegion/EditLanguage'],
  [NavEntryKey.ADD_LANGUAGE_ENTRY, '../system/languageSettings/languageAndRegion/AddLanguage'],
  [NavEntryKey.SELECT_REGION_ENTRY, '../system/languageSettings/languageAndRegion/SelectRegion'],
  [NavEntryKey.RESET_FACTORY, '../reset/ResetFactorySettings'],
  [NavEntryKey.CONFIRM_RESET_FACTORY_ENTRY, '../reset/ConfirmResetFactorySettings'],
  [NavEntryKey.ACCESSIBILITY_SERVICE_ENTRY, '../accessibility/AccessibilityServiceInfoSettings'],
  [NavEntryKey.ACCESSIBILITY_LIST_ENTRY, '../accessibility/AccessibilityServiceSettings'],
  [NavEntryKey.ACCESSIBILITY_MORE_SETTINGS_ENTRY, '../accessibility/AccessibilityMoreSettings'],
  [NavEntryKey.OOBE_WIFI_ENTRY, '../wifi/OobeWifiSettings'],
  [NavEntryKey.GLOBAL_SEARCH_ENTRY, '../search/SearchSettings'],
  [NavEntryKey.WIFI_MENU_CONFIG_ENTRY, '../wifi/WifiConfigModel'],
  [NavEntryKey.SMART_MULTI_WINDOW_ENTRY, '../multiwindow/SmartMultiWindowSettings'],
  [NavEntryKey.WIFI_INSTALL_CERTIFICATE_ENTRY, '../wifi/WifiInstallCertificateSetting'],
  [NavEntryKey.PC_MORE_POWER_SETTINGS, '../powerandbattery/component/MorePowerSettingsComponent'],
]);

// 一级菜单（有顺序）
export const PHONE_SETTING_HOME_MENU_KEYS =
  new Set([NavEntryKey.HOMEPAGE_SUGGESTION_MORE_PAGE, 'about_device',
    'wifi_entry', 'bluetooth_entry', 'mobile_network_entry', 'network_settings', 'more_connections_settings',
    'theme_settings', 'display_settings', 'volume_settings', 'systemui_notification_settings',
    'system_and_updates', 'application_and_service_settings', 'accessibility_feature',
    'storage_settings', 'battery', 'biometrics_and_password_settings', 'privacy_settings',
    'vassistant_setting', 'hi_write_settings', 'phone_mouse_settings', 'pad_keyboard_settings_entry',
    'pad_touchpad_settings_entry', 'pad_print_settings_entry', 'intelligent_scene_entry']);


// PC一级菜单（有顺序）
export const PC_SETTING_HOME_MENU_KEYS =
  new Set(['about_device', 'wifi_entry',
    'bluetooth_entry', 'pc_network_settings', 'more_connections_settings', 'theme_settings', 'display_settings',
    'pc_audio_settings', 'systemui_notification_settings', 'system_and_updates', 'application_settings',
    'accessibility_feature', 'storage_settings', 'pc_powerandbattery_settings',
    'biometrics_and_password_settings', 'privacy_settings', 'users_settings', 'admin_user_entry', 'vassistant_setting',
    'pc_keyboard', 'pc_mouse_settings', 'pc_trackpad_settings', 'pc_printers_and_scanners']);
    
export enum LazyMenuListKeys {
  WIFI_LIST = 'wifi_list_group',
  BLUETOOTH_LIST = 'bluetooth_list_group',
}

export enum TextClickPosition {
  START = 'start',
  MIDDLE = 'middle',
  END = 'end',
}

export const PRIVACY_PORTRAIT_PAGES: string[] = [
  NavEntryKey.HOTSPOT_ENTRY,
  NavEntryKey.HOTSPOT_PWD_ENTRY,
  NavEntryKey.WIFI_MENU_ENTRY,
  NavEntryKey.LOCK_SCREEN_PASSWORD_ENTRY,
  NavEntryKey.CREATE_NUMBER_PSD_ENTRY,
  NavEntryKey.CREATE_MIX_PSD_ENTRY,
  NavEntryKey.CHECK_PSD_ENTRY,
  NavEntryKey.CREATE_FOUR_PSD_ENTRY
];

export const SETTINGS_DATA_COLLABORATION_RECOMMEND_SERVICE_SWITCH: string = 'settings.collaboration.recommend_service_switch';

// 防误触模式开关KEY值
export const TOUCH_DISABLE_MODE_KEY: string = 'touch_disable_mode';

export const SWITCH_ON_VAL: string = '1';

export const SWITCH_OFF_VAL: string = '0';

//wifi 安全检测
export const WIFI_CLOUD_SECURITY_CHECK: string = 'wifi_cloud_security_check';
export const WIFI_CLOUD_SECURITY_ENABLED: string = '1';
export const WIFI_CLOUD_SECURITY_DISABLED: string = '0';

export enum EventId {
  UpdateAutoTimeZoneStateNum = 7991
}

export const DEVELOP_OPTION_STATE: string = 'const.security.developermode.state';

export const SUPPORT_SIDEBAR_BLUR: string = 'const.settings.support_sidebar_blur';

export const PUBLISHER_PERMISSION_ACCESS_SYSTEM_SETTINGS: string = 'ohos.permission.ACCESS_SYSTEM_SETTINGS';

export const DIALOG_BUTTON_PADDING_METRICS: LengthMetrics = LengthMetrics.vp(6);

// 无线防盗key
export const WIRELESS_ANTI_THEFT_KEY: string = 'wireless_anti-theft_duty_state';
export const WIRELESS_ANTI_THEFT_HOST_ADDRESS_KEY: string = 'wireless_anti-theft_host_address';
export const NUMBER_OPEN: string = '1';
export const NUMBER_CLOSE: string = '0';

// 按钮避让常量值
export const INIT_AVOID_WIDTH: number = 151;
export const DEFAULT_WINDOW_WIDTH: number = 28;
export const INIT_DEFAULT_WIDTH: number = 147;
export const INVALID_AVOID_WIDTH: number = -1;
export const TITLE_BAR_DEFAULT_PADDING: number = 24;

// SettingGroup类别
export class AppGroupType {
  public static readonly SYSTEM: string = 'ApplicationSystemGroup';
  public static readonly UN_SYSTEM: string = 'ApplicationUnSystemGroup';
  public static readonly SERVICE: string = 'ServiceGroup';
  public static readonly CONTAINER: string = 'ApplicationContainerGroup';
  public static readonly ALL: string = 'ALL';
}

export enum UIExtensionFinishType {
  /**
   * 返回方式 sendPop，分栏时不发送
   */
  FINISH_TYPE_SEND_POP = 1,

  /**
   * 忽略分栏场景，返回sendPop
   */
  IGNORE_SPLIT_SEND_POP = 3
}

// 截屏开关KEY值
export const SCREEN_SHOT_STATUS: string = 'fingersense_smartshot_enabled';

// 录屏开关KEY值
export const SCREEN_RECORDER_STATUS: string = 'fingersense_screen_recording_enabled';

export const DEEPLINK_SCHEME: string = 'settings:';

// 性能开关KEY值
export const POWER_PERFORMANCE_MODE_STATUS: string = 'power_performance_mode_enabled';

export enum MenuHandler {
  VIRUS_DETECTION = 'virus_detection'
}

export const MENU_HANDLE_MAP: Record<string, Want> = {
  [MenuHandler.VIRUS_DETECTION]: {
    uri: NavEntryKey.PRIVACY_ENTRY,
    parameters: {
      'subUri': 'search_virus_protection_home',
      'startReason': 'from_search',
    }
  }
}