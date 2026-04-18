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

/**
 * 页Url管理
 *
 * @since 2022-05-27
 */
export class PageUrl {
  public static readonly EXTERNAL_SETTINGS_HOME_PAGE_URL: string = 'pages/home/ExternalSettingsHome';
  public static readonly EXTERNAL_NETWORK_SETTINGS_HOME_PAGE_URL: string = 'Setting/Wlan/ExternalNetworkPageComponent';
  public static readonly EXTERNAL_BLUETOOTH_OPP_SETTINGS_PAGE_URL: string = 'Setting/Bluetooth/view/BluetoothOppServicePageComponent';
  public static readonly SETTINGS_HOME_PAGE_URL: string = 'pages/home/SettingsHome';
  public static readonly ABOUT_DEVICE_PAGE_URL: string = 'pages/aboutdevice/AboutDeviceSettings';
  public static readonly ACCESSIBILITY_PAGE_URL: string = 'pages/accessibility/AccessibilitySettings';
  public static readonly ACCESSIBILITY_OPERATION_PAGE_URL: string = 'pages/accessibility/AccessibilityOperationSetting';
  public static readonly ACCESSIBILITY_SCREENREADER_URL: string = 'pages/accessibility/screenreader/AccessibilityScreenReaderSettings';
  public static readonly ACCESSIBILITY_TOUCHSCREEN_PAGE_URL: string = 'pages/accessibility/AccessibilityTouchscreenSettings';
  public static readonly ACCESSIBILITY_SCREENREADER_HAP_URL: string = 'pages/accessibility/screenreader/AccessibilityScreenReaderHapIndex';
  public static readonly ACCESSIBILITY_SERVICE_PAGE_URL: string = 'pages/accessibility/AccessibilityServiceSettings';
  public static readonly ACCESSIBILITY_SERVICE_INFO_PAGE_URL: string = 'pages/accessibility/AccessibilityServiceInfoSettings';
  public static readonly ACCESSIBILITY_MORE_SETTINGS_PAGE_URL: string = 'pages/accessibility/AccessibilityMoreSettings';
  public static readonly ACCESSIBILITY_HEARINGAID_PAGE_URL: string = 'pages/accessibility/AccessibilityHearingAidSettings';
  public static readonly ACCESSIBILITY_HEARINGAID_PAGE_NAME_URL: string = 'pages/accessibility/AccessibilityHearingAidNameSettings';
  public static readonly APPLICATION_PAGE_URL: string = 'pages/application/ApplicationSettings';
  public static readonly APPLICATION_INFO_PAGE_URL: string = 'pages/application/ApplicationInfoSettings';
  public static readonly APPLICATION_RESTORE_PAGE_URL: string = 'pages/application/ApplicationRestoreSettings';
  public static readonly BLUETOOTH_WINDOW_PAGE_URL: string = 'Setting/Bluetooth/view/BluetoothWindowSettings';
  public static readonly FUSION_WINDOW_PAGE_URL: string = 'Setting/Fusion/view/FusionWindowSettings';
  public static readonly PC_MODE_BLUETOOTH_WINDOW_PAGE_URL: string = 'Setting/Bluetooth/view/PcModeBluetoothWindowSettings';
  public static readonly DATE_TIME_PAGE_URL: string = 'pages/datetime/DateAndTimeSettings';
  public static readonly APP_ASSISTANT_PAGE_URL: string = 'pages/system/AppAssistant/AppAssistantSettings';
  public static readonly SMART_MULTI_WINDOW_URL: string = 'pages/multiwindow/SmartMultiWindowSettings';
  public static readonly START_FIND_DEVICE_PAGE_URL: string = 'pages/reset/finddevice/StartFindDeviceSettings';
  public static readonly THEME_PAGE_URL: string = 'pages/display/ThemeSettings';
  public static readonly DISPLAY_PAGE_URL: string = 'pages/display/DisplaySettings';
  public static readonly SCREEN_ZOOM_PAGE_URL: string = 'pages/display/ScreenZoomSettings';
  public static readonly DARK_MODE_PAGE_URL: string = 'pages/display/DisplayModeSettings';
  public static readonly EYE_COMFORT_MODE_URL: string = 'pages/display/EyeComfortModeSettings';
  public static readonly SYSTEM_PAGE_URL: string = 'pages/system/SystemAndUpdatesSettings';
  public static readonly WIFI_PAGE_URL: string = 'pages/wifi/WifiSettings';
  public static readonly WIFI_WINDOW_PAGE_URL: string = 'pages/wifi/WifiWindowSettings';
  public static readonly WIFI_PASSWORD_PAGE_URL: string = 'pages/wifi/WifiPasswordSettings';
  public static readonly WIFI_PRECISION_PAGE_URL: string = 'pages/wifi/WifiPrecisionSetting';
  public static readonly WIFI_OOBE_PAGE_URL: string = 'pages/wifi/OobeWifiExtensionSettings';
  public static readonly WIFI_SETUP_PROXY_ENTRY: string = 'pages/wifi/WifiSetupProxyPage';
  public static readonly WIFI_SETUP_IP_ENTRY: string = 'pages/wifi/WifiSetupIpPage';
  public static readonly STORAGE_PAGE_URL: string = 'pages/storage/StorageSettings';
  public static readonly CREATE_SIX_PIN_PAGE_URL: string = 'pages/password/CreateSixPinSettings';
  public static readonly CREATE_FOUR_PIN_PAGE_URL: string = 'pages/password/CreateFourPinSettings';
  public static readonly CHECK_PSD_PAGE_URL: string = 'pages/password/CheckPasswordSettings';
  public static readonly CREATE_NUMBER_PSD_PAGE_URL: string = 'pages/password/CreateNumberPsdSettings';
  public static readonly CREATE_MIXED_PSD_PAGE_URL: string = 'pages/password/CreateMixedPsdSettings';
  public static readonly VOLUME_PAGE_URL: string = 'pages/volume/VolumeSettings';
  public static readonly RING_TONE_SETTINGS_URL: string = 'pages/volume/RingToneSettings';
  public static readonly MESSAGING_TONE_SETTINGS_URL: string = 'pages/volume/MessagingTone';
  public static readonly NOTIFICATION_TONE_SETTINGS_URL: string = 'pages/volume/NotificationTone';
  public static readonly DEVELOPER_OPTIONS_PAGE_URL: string = 'pages/developeroptions/DeveloperOptionsSettings';
  public static readonly LANGUAGE_AND_SETTINGS_HOME_URL: string = 'pages/system/languageSettings/LanguageSettingsHome'
  public static readonly LANGUAGE_AND_REGION_PAGE_URL: string = 'pages/system/languageSettings/languageAndRegion/LanguageAndRegionPage';
  public static readonly DEVICE_AND_APPLICATION_PAGE_URL: string = 'pages/deviceandapplication/DeviceAndApplicationSettings';
  public static readonly ENTERPRISE_DEVICE_MANAGEMENT_PAGE_URL: string = 'pages/deviceandapplication/EnterpriseDeviceManagementSettings';
  public static readonly ENTERPRISE_APPLICATION_MANAGEMENT_PAGE_URL: string = 'pages/deviceandapplication/EnterpriseApplicationManagementSettings';
  public static readonly WIFI_INSTALL_CERTIFICATE_PAGE_URL: string = 'pages/wifi/WifiInstallCertificateSetting';
  public static readonly DEVICE_NAME_PAGE_URL: string = 'pages/aboutdevice/devicename/DeviceNameSettings';
  public static readonly STATUS_INFORMATION_PAGE_URL: string = 'pages/aboutdevice/StatusInformationSetting';
  public static readonly NETWORK_INFORMATION_PAGE_URL: string = 'pages/aboutdevice/NetworkInformationSetting';
  public static readonly LEGAL_INFORMATION_PAGE_URL: string = 'pages/aboutdevice/LegalInfomationSetting';
  public static readonly OPEN_SOURCE_CODE_LICENSE_URL: string = 'pages/aboutdevice/legalInfo/OpenSourceCodeLicense';
  public static readonly APP_OPEN_SOURCE_STATEMENT_LICENSE_URL: string = 'pages/aboutdevice/legalInfo/AppOpenSourceStatement';
  public static readonly APPLICATION_AND_SERVICE_PAGE_URL: string = 'pages/applicationandservice/ApplicationAndServiceSettings';
  public static readonly MOBILE_NETWORK_PAGE_URL: string = 'pages/mobilenetwork/MobileNetworkSettings';
  public static readonly SYSTEM_ROLLBACK_URL: string = 'pages/developeroptions/SystemRollback';
  public static readonly HOTSPOT_PAGE_URL: string = 'pages/mobilenetwork/HotspotSettings';
  public static readonly HOTSPOT_BLOCK_LIST_URL: string = 'pages/mobilenetwork/BlockListSettings';
  public static readonly HOTSPOT_NAME_URL: string = 'pages/mobilenetwork/HotspotNameSettings';
  public static readonly HOTSPOT_PWD_URL: string = 'pages/mobilenetwork/PasswordSettings';
  public static readonly HOTSPOT_CONNECTED_URL: string = 'pages/mobilenetwork/ConnectedDevicesSettings';
  public static readonly HOTSPOT_MORE_URL: string = 'pages/mobilenetwork/MoreShareSettings';
  public static readonly RESET_PAGE_URL: string = 'pages/reset/ResetSettings';
  public static readonly RESET_FACTORY_PAGE_URL: string = 'pages/reset/ResetFactorySettings';
  public static readonly CONFIRM_RESET_FACTORY_PAGE_URL: string = 'pages/reset/ConfirmResetFactorySettings';
  public static readonly RESET_NET_PAGE_URL: string = 'pages/reset/ResetNetSettings';
  public static readonly CONFIRM_RESET_NET_PAGE_URL: string = 'pages/reset/ConfirmResetNetSettings';
  public static readonly MORE_CONNECTION_PAGE_URL: string = 'pages/moreconnection/MoreConnectionSettings';
  public static readonly SHARE_PAGE_URL: string = 'pages/moreconnection/ShareSettings';
  public static readonly NFC_PAGE_URL: string = 'pages/moreconnection/NFCSettings';
  public static readonly LOCATION_SERVICE_PAGE_URL: string = 'pages/privacy/LocationServiceSettings';
  public static readonly LOCATION_HELP_PAGE_URL: string = 'pages/privacy/LocationHelpSettings';
  public static readonly SAFE_TIPS_DIALOG_PAGE_URL: string = 'pages/password/CreateSafeTipsDialogPage/SafeTipsPage';
  public static readonly EDM_TIPS_DIALOG_PAGE_URL: string = 'pages/password/CreateEdmTipsDialogPage/EdmTipsPage';
  public static readonly COLOR_PAGE_URL: string = 'pages/theme/SystemColorSettings';
  public static readonly WALLPAPER_PAGE_URL: string = 'pages/theme/WallpaperPage';
  public static readonly DEFAULT_BROWSER_URL: string = 'pages/application/DefaultBrowserApplicationSettings';
  public static readonly OUC_PARAM_VERSION_URL: string = 'pages/aboutdevice/paramversion/OucParamVersion';
  public static readonly APPLICATION_PERMISSION_SETTINGS_URL: string = 'pages/application/ApplicationPermissionSettings'
  public static readonly GLOBAL_SEARCH_URL: string = 'pages/search/SearchSettings';
  public static readonly CLOUD_SPACE_PAGE_URL: string = 'pages/cloudspace/CloudSpaceSettings';
  public static readonly WIRELESS_COMISSIONING_URL: string = 'pages/developeroptions/wirelessCommissioningSetting';
  public static readonly DEFAULT_PAYMENT_APPLICATION_URL: string = 'pages/moreconnection/DefaultPaymentApplicationSettings';
  // 用户和账户界面
  public static readonly USERS_AND_ACCOUNTS_PAGE_URL: string = 'pages/users/UsersAccountsSettings';
  public static readonly USERS_PAGE_URL: string = 'pages/users/UserSettings';
  public static readonly TIME_ZONE_PAGE_URL: string = 'pages/datetime/TimeZoneSettings';
  public static readonly BIOMETRICS_AND_PASSWORD_PAGE_URL: string = 'pages/biometricsandpassword/BiometricsAndPasswordSettings';
  public static readonly ACTION_APP_INFO: string = 'action.settings.app.info';
  public static readonly ACTION_TIME_ZONE: string = 'action.settings.timezone';
  public static readonly TIME_ZONE_EXTENSION_PAGE_URL: string = 'pages/datetime/TimeZoneSettingsExtensionPage';
  public static readonly ABOUT_DEVICE_PAGE_NAVIGATION_URL = 'pages/aboutdevice/AboutDevicesSettingsHome';
  public static readonly REFRESH_RATE_PAGE_URL: string = 'pages/display/RefreshRateSettings';
  public static readonly OOBE_LOCAL_USER_PAGE_URL: string = 'Setting/UserSettings/oobe/OobeLocalUser';

  // 指纹相关
  public static readonly FINGERPRINT_PAGE_URL: string = 'pages/biometricsandpassword/module/fingerprint/Fingerprint';
  public static readonly UNDER_SCREEN_FINGERPRINT_INTRO_PAGE_URL: string = 'pages/biometricsandpassword/module/fingerprint/UnderScreenFingerprintIntro';
  public static readonly UNDER_SCREEN_FINGERPRINT_ENROLL_PAGE_URL: string = 'pages/biometricsandpassword/module/fingerprint/UnderScreenFingerprintEnroll';
  public static readonly OUT_SCREEN_FINGERPRINT_ENROLL_PAGE_URL: string = 'pages/biometricsandpassword/module/fingerprint/OutScreenFingerprintEnroll';
  public static readonly FINGERPRINT_ANIMATION_PAGE_URL: string = 'pages/biometricsandpassword/module/fingerprint/FingerprintAnimation';
  public static readonly FINGERPRINT_CAROUSEL_PAGE_URL: string = 'pages/biometricsandpassword/module/fingerprint/FingerprintCarousel';
  public static readonly UNDER_SCREEN_FINGERPRINT_IDENTIFICATION_PAGE_URL: string = 'pages/biometricsandpassword/module/fingerprint/UnderScreenFingerprintIdentification';

  //音频管家
  public static readonly AUDIOBUTLER_PAGE_URL: string = 'pages/audiobutler/AudioButlerSettings';

  //电池
  public static readonly BATTERY_PAGE_URL: string = 'pages/battery/BatterySettings';
  public static readonly POWER_CONSUMPTION_PAGE_URL: string = 'pages/battery/PowerConsumption';

  //输入法
  public static readonly INPUT_PAGE_URL: string = 'pages/input/InputSettings';
  public static readonly OTHER_INPUT_DETAIL_SETTINGS: string = 'pages/input/otherInputDetailSettings';
  public static readonly INPUT_UIEXTENSION_LIST: string = 'pages/input/uiExtensionList';

  public static readonly NEAR_LINK_PAGE_URL: string = 'pages/nearlink/view/NearLinkSettings';
  public static readonly NEAR_LINK_BOND_DEVICE_SETTINGS_URL: string = 'pages/nearlink/view/NearLinkBondDeviceSettings';
  public static readonly NEAR_LINK_WINDOW_PAGE_URL: string = 'Setting/MoreConnection/NearLink/view/NearLinkWindowSettings';

  public static readonly SYSTEMUI_NOTIFICATION_SETTINGS: string = 'pages/notification/NotificationSettings';

  public static readonly VASSISTANT_SETTINGS: string = 'pages/vassistant/VAssistantSettings';

  public static readonly SCAN_CODE_SETTINGS: string = 'pages/scanCode/ScanCodeMain';
  public static readonly QUICK_PAY_SETTINGS: string = 'pages/quickPay/QuickPayMain';

  //手写笔
  public static readonly HIWRITE_SETTING_PAGE_URL: string = 'pages/hiwrite/HiWriteSettings';

  //鼠标
  public static readonly MOUSE_SETTING_PAGE_URL: string = 'pages/mouse/MouseSettings';

  //键盘
  public static readonly PAD_KEYBOARD_URL: string = 'pages/keyboard/KeyBoardSettings';
  public static readonly FIRMWARE_UPGRADE: string = 'pages/keyboard/KeyBoardFirmwareUpgrade'
  public static readonly KEYBOARD_INFO: string = 'pages/keyboard/KeyBoardInformationSettings'

  public static readonly START_WALLET_PAGE_URL: string = 'pages/reset/startwallet/StartWalletPage';
  //深色模式控制中心二级页面
  public static readonly DARK_MODE_WINDOW_URL: string = 'Setting/Display/DarkModeWindowPage';

  //个人热点二级页面
  public static readonly HOTSPOT_WINDOW_URL: string = 'Setting/MobileNetwork/HotSpot/HotspotWindowPage';

  //声音模式二级页面
  public static readonly SOUND_MODE_WINDOW_URL: string = 'Setting/Volume/SoundModeWindowPage';

  /**
   * 获取页URL管理单例
   */
  static getInstance(): PageUrl {
    if (!Boolean(AppStorage.get<PageUrl>('pageUrl')).valueOf()) {
      AppStorage.setOrCreate<PageUrl>('pageUrl', new PageUrl());
    }
    return AppStorage.get<PageUrl>('pageUrl') as PageUrl;
  }
}
