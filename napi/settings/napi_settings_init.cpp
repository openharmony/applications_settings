/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
#include <map>
#include <string>
#include "napi_settings.h"
#include "napi_settings_log.h"

namespace OHOS {
namespace Settings {
class TableName
{
public:
    static const std::string global;
    static const std::string system;
    static const std::string SECURE;
};

class DomainName
{
public:
    static const std::string deviceShared;
    static const std::string userProperty;
    static const std::string userSecurity;
};

class Date
{
public:
    static const std::string dateFormat;
    static const std::string timeFormat;
    static const std::string autoGainTime;
    static const std::string autoGainTimeZone;
};

class Display
{
public:
    static const std::string fontScale;
    static const std::string screenBrightnessStatus;
    static const std::string autoScreenBrightness;
    static const int autoScreenBrightnessMode;
    static const int manualScreenBrightnessMode;
    static const std::string screenOffTimeout;
    static const std::string defaultScreenRotation;
    static const std::string animatorDurationScale;
    static const std::string transitionAnimationScale;
    static const std::string windowAnimationScale;
    static const std::string displayInversionStatus;
};

class General
{
public:
    static const std::string setupWizardFinished;
    static const std::string endButtonAction;
    static const std::string airplaneModeStatus;
    static const std::string accelerometerRotationStatus;
    static const std::string deviceProvisionStatus;
    static const std::string hdcStatus;
    static const std::string bootCounting;
    static const std::string contactMetaDataSyncStatus;
    static const std::string developmentSettingsStatus;
    static const std::string deviceName;
    static const std::string usbStorageStatus;
    static const std::string debuggerWaiting;
    static const std::string debugAppPackage;
    static const std::string accessibilityStatus;
    static const std::string activatedAccessibilityServices;
    static const std::string geolocationOriginsAllowed;
    static const std::string skipUseHints;
    static const std::string touchExplorationStatus;
};

class Input
{
public:
    static const std::string defaultInputMethod;
    static const std::string activatedInputMethodSubMode;
    static const std::string activatedInputMethods;
    static const std::string selectorVisibilityForInputMethod;
    static const std::string autoCapsTextInput;
    static const std::string autoPunctuateTextInput;
    static const std::string autoReplaceTextInput;
    static const std::string showPasswordTextInput;
};

class Network
{
public:
    static const std::string dataRoamingStatus;
    static const std::string httpProxyCfg;
    static const std::string networkPreferenceUsage;
};

class Phone
{
public:
    static const std::string rttCallingStatus;
};

class Sound
{
public:
    static const std::string vibrateWhileRinging;
    static const std::string defaultAlarmAlert;
    static const std::string dtmfToneTypeWhileDialing;
    static const std::string dtmfToneWhileDialing;
    static const std::string hapticFeedbackStatus;
    static const std::string affectedModeRingerStreams;
    static const std::string affectedMuteStreams;
    static const std::string defaultNotificationSound;
    static const std::string defaultRingtone;
    static const std::string soundEffectsStatus;
    static const std::string vibrateStatus;
    // temp audio key, it will be modify in the feature
    static const std::string audioRingtone;
    static const std::string audioMedia;
    static const std::string audioVoicecall;
};

class TTS
{
public:
    static const std::string defaultTTSPitch;
    static const std::string defaultTTSRate;
    static const std::string defaultTTSSynth;
    static const std::string enableTTSPlugins;
};

class Wireless
{
public:
    static const std::string bluetoothRadio;
    static const std::string cellRadio;
    static const std::string nfcRadio;
    static const std::string airplaneModeRadios;
    static const std::string bluetoothStatus;
    static const std::string bluetoothDiscoverAbilityStatus;
    static const std::string bluetoothDiscoverTimeout;
    static const std::string wifiDHCPMaxRetryCount;
    static const std::string wifiToMobileDataAwakeTimeout;
    static const std::string wifiStatus;
    static const std::string wifiWatchDogStatus;
    static const std::string wifiRadio;
    static const std::string ownerLockdownWifiCfg;
};

class Power
{
public:
    static const std::string suspendSourcesCfg;
};

const std::string TableName::global = "global";
const std::string TableName::system = "system";
const std::string TableName::SECURE = "secure";
const std::string DomainName::deviceShared = "global";
const std::string DomainName::userProperty = "system";
const std::string DomainName::userSecurity = "secure";

const std::string Date::dateFormat = "settings.date.date_format";
const std::string Date::timeFormat = "settings.date.time_format";
const std::string Date::autoGainTime = "settings.date.auto_gain_time";
const std::string Date::autoGainTimeZone = "settings.date.auto_gain_time_zone";

const std::string Display::fontScale = "settings.display.font_scale";
const std::string Display::screenBrightnessStatus = "settings.display.screen_brightness_status";
const std::string Display::autoScreenBrightness = "settings.display.auto_screen_brightness";
const int Display::autoScreenBrightnessMode = 1;
const int Display::manualScreenBrightnessMode = 0;
const std::string Display::screenOffTimeout = "settings.display.screen_off_timeout";
const std::string Display::defaultScreenRotation = "settings.display.default_screen_rotation";
const std::string Display::animatorDurationScale = "settings.display.animator_duration_scale";
const std::string Display::transitionAnimationScale = "settings.display.transition_animation_scale";
const std::string Display::windowAnimationScale = "settings.display.window_animation_scale";
const std::string Display::displayInversionStatus = "settings.display.display_inversion_status";

const std::string General::setupWizardFinished = "settings.general.setup_wizard_finished";
const std::string General::endButtonAction = "settings.general.end_button_action";
const std::string General::airplaneModeStatus = "settings.general.airplane_mode_status";
const std::string General::accelerometerRotationStatus = "settings.general.accelerometer_rotation_status";
const std::string General::deviceProvisionStatus = "settings.general.device_provision_status";
const std::string General::hdcStatus = "settings.general.hdc_status";
const std::string General::bootCounting = "settings.general.boot_counting";
const std::string General::contactMetaDataSyncStatus = "settings.general.contact_metadata_sync_status";
const std::string General::developmentSettingsStatus = "settings.general.development_settings_status";
const std::string General::deviceName = "settings.general.device_name";
const std::string General::usbStorageStatus = "settings.general.usb_storage_status";
const std::string General::debuggerWaiting = "settings.general.debugger_waiting";
const std::string General::debugAppPackage = "settings.general.debug_app_package";
const std::string General::accessibilityStatus = "settings.general.accessibility_status";
const std::string General::activatedAccessibilityServices = "settings.general.activated_accessibility_services";
const std::string General::geolocationOriginsAllowed = "settings.general.geolocation_origins_allowed";
const std::string General::skipUseHints = "settings.general.skip_use_hints";
const std::string General::touchExplorationStatus = "settings.general.touch_exploration_status";

const std::string Input::defaultInputMethod = "settings.input.default_input_method";
const std::string Input::activatedInputMethodSubMode = "settings.input.activated_input_method_submode";
const std::string Input::activatedInputMethods = "settings.input.activated_input_methods";
const std::string Input::selectorVisibilityForInputMethod = "settings.input.selector_visibility_for_input_method";
const std::string Input::autoCapsTextInput = "settings.input.auto_caps_text_input";
const std::string Input::autoPunctuateTextInput = "settings.input.auto_punctuate_text_input";
const std::string Input::autoReplaceTextInput = "settings.input.auto_replace_text_input";
const std::string Input::showPasswordTextInput = "settings.input.show_password_text_input";

const std::string Network::dataRoamingStatus = "settings.network.data_roaming_status";
const std::string Network::httpProxyCfg = "settings.network.http_proxy_cfg";
const std::string Network::networkPreferenceUsage = "settings.network.network_preference_usage";

const std::string Phone::rttCallingStatus = "settings.phone.rtt_calling_status";

const std::string Sound::vibrateWhileRinging = "settings.sound.vibrate_while_ringing";
const std::string Sound::defaultAlarmAlert = "settings.sound.default_alarm_alert";
const std::string Sound::dtmfToneTypeWhileDialing = "settings.sound.dtmf_tone_type_while_dialing";
const std::string Sound::dtmfToneWhileDialing = "settings.sound.dtmf_tone_while_dialing";
const std::string Sound::hapticFeedbackStatus = "settings.sound.haptic_feedback_status";
const std::string Sound::affectedModeRingerStreams = "settings.sound.affected_mode_ringer_streams";
const std::string Sound::affectedMuteStreams = "settings.sound.affected_mute_streams";
const std::string Sound::defaultNotificationSound = "settings.sound.default_notification_sound";
const std::string Sound::defaultRingtone = "settings.sound.default_ringtone";
const std::string Sound::soundEffectsStatus = "settings.sound.sound_effects_status";
const std::string Sound::vibrateStatus = "settings.sound.vibrate_status";

const std::string TTS::defaultTTSPitch = "settings.tts.default_tts_pitch";
const std::string TTS::defaultTTSRate = "settings.tts.default_tts_rate";
const std::string TTS::defaultTTSSynth = "settings.tts.default_tts_synth";
const std::string TTS::enableTTSPlugins = "settings.tts.enabled_tts_plugins";

const std::string Wireless::bluetoothRadio = "settings.wireless.bluetooth_radio";
const std::string Wireless::cellRadio = "settings.wireless.cell_radio";
const std::string Wireless::nfcRadio = "settings.wireless.nfc_radio";
const std::string Wireless::airplaneModeRadios = "settings.wireless.airplane_mode_radios";
const std::string Wireless::bluetoothStatus = "settings.wireless.bluetooth_status";
const std::string Wireless::bluetoothDiscoverAbilityStatus = "settings.wireless.bluetooth_discoverability_status";
const std::string Wireless::bluetoothDiscoverTimeout = "settings.wireless.bluetooth_discover_timeout";
const std::string Wireless::wifiDHCPMaxRetryCount = "settings.wireless.wifi_dhcp_max_retry_count";
const std::string Wireless::wifiToMobileDataAwakeTimeout = "settings.wireless.wifi_to_mobile_data_awake_timeout";
const std::string Wireless::wifiStatus = "settings.wireless.wifi_status";
const std::string Wireless::wifiWatchDogStatus = "settings.wireless.wifi_watchdog_status";
const std::string Wireless::wifiRadio = "settings.wireless.wifi_radio";
const std::string Wireless::ownerLockdownWifiCfg = "settings.wireless.owner_lockdown_wifi_cfg";

const std::string Power::suspendSourcesCfg = "settings.power.suspend_sources";

const std::string TableName_CLASS_NAME = "tableName";
const std::string DomainName_CLASS_NAME = "domainName";
const std::string DATE_CLASS_NAME = "date";
const std::string DISPLAY_CLASS_NAME = "display";
const std::string GENERAL_CLASS_NAME = "general";
const std::string INPUT_CLASS_NAME = "input";
const std::string NETWORK_CLASS_NAME = "network";
const std::string PHONE_CLASS_NAME = "phone";
const std::string SOUND_CLASS_NAME = "sound";
const std::string TTS_CLASS_NAME = "tts";
const std::string WIRELESS_CLASS_NAME = "wireless";
const std::string POWER_CLASS_NAME = "power";

napi_value ClassConstructor(napi_env env, napi_callback_info info)
{
    SETTING_LOG_INFO("%{public}s is called", __FUNCTION__);
    size_t argc = 0;
    napi_value argv = nullptr;
    napi_value thisArg = nullptr;
    void* data = nullptr;
    napi_get_cb_info(env, info, &argc, &argv, &thisArg, &data);

    napi_value global = 0;
    napi_get_global(env, &global);
    SETTING_LOG_INFO("%{public}s is end", __FUNCTION__);
    return thisArg;
}

void InitTableNameMap(napi_env env, std::map<const char*, napi_value> &paramMap)
{
    napi_value varGlobal = nullptr;
    napi_create_string_utf8(env,
        TableName::global.c_str(), NAPI_AUTO_LENGTH, &varGlobal);
    paramMap["GLOBAL"] = varGlobal;

    napi_value varSystem = nullptr;
    napi_create_string_utf8(env,
        TableName::system.c_str(), NAPI_AUTO_LENGTH, &varSystem);
    paramMap["SYSTEM"] = varSystem;

    napi_value varSecure = nullptr;
    napi_create_string_utf8(env,
        TableName::SECURE.c_str(), NAPI_AUTO_LENGTH, &varSecure);
    paramMap["SECURE"] = varSecure;
}

void InitDomainNameMap(napi_env env, std::map<const char*, napi_value> &paramMap)
{
    napi_value varGlobal = nullptr;
    napi_create_string_utf8(env,
        DomainName::deviceShared.c_str(), NAPI_AUTO_LENGTH, &varGlobal);
    paramMap["DEVICE_SHARED"] = varGlobal;

    napi_value varSystem = nullptr;
    napi_create_string_utf8(env,
        DomainName::userProperty.c_str(), NAPI_AUTO_LENGTH, &varSystem);
    paramMap["USER_PROPERTY"] = varSystem;

    napi_value varSecure = nullptr;
    napi_create_string_utf8(env,
        DomainName::userSecurity.c_str(), NAPI_AUTO_LENGTH, &varSecure);
    paramMap["USER_SECURITY"] = varSecure;
}

void InitDateMap(napi_env env, std::map<const char*, napi_value>& paramMap)
{
    napi_value dateFormat = nullptr;
    napi_create_string_utf8(env,
        Date::dateFormat.c_str(), NAPI_AUTO_LENGTH, &dateFormat);
    paramMap["DATE_FORMAT"] = dateFormat;

    napi_value timeFormat = nullptr;
    napi_create_string_utf8(env,
        Date::timeFormat.c_str(), NAPI_AUTO_LENGTH, &timeFormat);
    paramMap["TIME_FORMAT"] = timeFormat;

    napi_value autoGainTime = nullptr;
    napi_create_string_utf8(env,
        Date::autoGainTime.c_str(), NAPI_AUTO_LENGTH, &autoGainTime);
    paramMap["AUTO_GAIN_TIME"] = autoGainTime;

    napi_value autoGainTimeZone = nullptr;
    napi_create_string_utf8(env,
        Date::autoGainTimeZone.c_str(), NAPI_AUTO_LENGTH, &autoGainTimeZone);
    paramMap["AUTO_GAIN_TIME_ZONE"] = autoGainTimeZone;
}

void InitDisplayMap(napi_env env, std::map<const char*, napi_value>& paramMap)
{
    napi_value fontScale = nullptr;
    napi_create_string_utf8(env,
        Display::fontScale.c_str(), NAPI_AUTO_LENGTH, &fontScale);
    paramMap["FONT_SCALE"] = fontScale;

    napi_value brightnessStatus = nullptr;
    napi_create_string_utf8(env,
        Display::screenBrightnessStatus.c_str(), NAPI_AUTO_LENGTH, &brightnessStatus);
    paramMap["SCREEN_BRIGHTNESS_STATUS"] = brightnessStatus;

    napi_value autoScreenStatus = nullptr;
    napi_create_string_utf8(env,
        Display::autoScreenBrightness.c_str(), NAPI_AUTO_LENGTH, &autoScreenStatus);
    paramMap["AUTO_SCREEN_BRIGHTNESS"] = autoScreenStatus;

    napi_value autoMode = nullptr;
    napi_create_int32(env,
        Display::autoScreenBrightnessMode, &autoMode);
    paramMap["AUTO_SCREEN_BRIGHTNESS_MODE"] = autoMode;

    napi_value manualMode = nullptr;
    napi_create_int32(env,
        Display::manualScreenBrightnessMode, &manualMode);
    paramMap["MANUAL_SCREEN_BRIGHTNESS_MODE"] = manualMode;

    napi_value screenOffTimeout = nullptr;
    napi_create_string_utf8(env,
        Display::screenOffTimeout.c_str(), NAPI_AUTO_LENGTH, &screenOffTimeout);
    paramMap["SCREEN_OFF_TIMEOUT"] = screenOffTimeout;

    napi_value defScreenRotation = nullptr;
    napi_create_string_utf8(env,
        Display::defaultScreenRotation.c_str(), NAPI_AUTO_LENGTH, &defScreenRotation);
    paramMap["DEFAULT_SCREEN_ROTATION"] = defScreenRotation;

    napi_value animatorDurationScale = nullptr;
    napi_create_string_utf8(env,
        Display::animatorDurationScale.c_str(), NAPI_AUTO_LENGTH, &animatorDurationScale);
    paramMap["ANIMATOR_DURATION_SCALE"] = animatorDurationScale;

    napi_value transiAnimationScale = nullptr;
    napi_create_string_utf8(env,
        Display::transitionAnimationScale.c_str(), NAPI_AUTO_LENGTH, &transiAnimationScale);
    paramMap["TRANSITION_ANIMATION_SCALE"] = transiAnimationScale;

    napi_value windowAnimationScale = nullptr;
    napi_create_string_utf8(env,
        Display::windowAnimationScale.c_str(), NAPI_AUTO_LENGTH, &windowAnimationScale);
    paramMap["WINDOW_ANIMATION_SCALE"] = windowAnimationScale;

    napi_value displayInversionStatus = nullptr;
    napi_create_string_utf8(env,
        Display::displayInversionStatus.c_str(), NAPI_AUTO_LENGTH, &displayInversionStatus);
    paramMap["DISPLAY_INVERSION_STATUS"] = displayInversionStatus;
}

void InitGeneralMap(napi_env env, std::map<const char*, napi_value>& paramMap)
{
    napi_value setupWizFinished = nullptr;
    napi_create_string_utf8(env,
        General::setupWizardFinished.c_str(), NAPI_AUTO_LENGTH, &setupWizFinished);
    paramMap["SETUP_WIZARD_FINISHED"] = setupWizFinished;

    napi_value endButtonAction = nullptr;
    napi_create_string_utf8(env,
        General::endButtonAction.c_str(), NAPI_AUTO_LENGTH, &endButtonAction);
    paramMap["END_BUTTON_ACTION"] = endButtonAction;

    napi_value airplaneModeStatus = nullptr;
    napi_create_string_utf8(env,
        General::airplaneModeStatus.c_str(), NAPI_AUTO_LENGTH, &airplaneModeStatus);
    paramMap["AIRPLANE_MODE_STATUS"] = airplaneModeStatus;

    napi_value acceleRotationStatus = nullptr;
    napi_create_string_utf8(env,
        General::accelerometerRotationStatus.c_str(), NAPI_AUTO_LENGTH, &acceleRotationStatus);
    paramMap["ACCELEROMETER_ROTATION_STATUS"] = acceleRotationStatus;

    napi_value devProvisionStatus = nullptr;
    napi_create_string_utf8(env,
        General::deviceProvisionStatus.c_str(), NAPI_AUTO_LENGTH, &devProvisionStatus);
    paramMap["DEVICE_PROVISION_STATUS"] = devProvisionStatus;

    napi_value hdcStatus = nullptr;
    napi_create_string_utf8(env,
        General::hdcStatus.c_str(), NAPI_AUTO_LENGTH, &hdcStatus);
    paramMap["HDC_STATUS"] = hdcStatus;

    napi_value bootCounting = nullptr;
    napi_create_string_utf8(env,
        General::bootCounting.c_str(), NAPI_AUTO_LENGTH, &bootCounting);
    paramMap["BOOT_COUNTING"] = bootCounting;

    napi_value contactMetaSyncStatus = nullptr;
    napi_create_string_utf8(env,
        General::contactMetaDataSyncStatus.c_str(), NAPI_AUTO_LENGTH, &contactMetaSyncStatus);
    paramMap["CONTACT_METADATA_SYNC_STATUS"] = contactMetaSyncStatus;

    napi_value developSettingStatus = nullptr;
    napi_create_string_utf8(env,
        General::developmentSettingsStatus.c_str(), NAPI_AUTO_LENGTH, &developSettingStatus);
    paramMap["DEVELOPMENT_SETTINGS_STATUS"] = developSettingStatus;

    napi_value deviceName = nullptr;
    napi_create_string_utf8(env,
        General::deviceName.c_str(), NAPI_AUTO_LENGTH, &deviceName);
    paramMap["DEVICE_NAME"] = deviceName;

    napi_value usbStorageStatus = nullptr;
    napi_create_string_utf8(env,
        General::usbStorageStatus.c_str(), NAPI_AUTO_LENGTH, &usbStorageStatus);
    paramMap["USB_STORAGE_STATUS"] = usbStorageStatus;

    napi_value debuggerWaiting = nullptr;
    napi_create_string_utf8(env,
        General::debuggerWaiting.c_str(), NAPI_AUTO_LENGTH, &debuggerWaiting);
    paramMap["DEBUGGER_WAITING"] = debuggerWaiting;

    napi_value debugAppPackage = nullptr;
    napi_create_string_utf8(env,
        General::debugAppPackage.c_str(), NAPI_AUTO_LENGTH, &debugAppPackage);
    paramMap["DEBUG_APP_PACKAGE"] = debugAppPackage;

    napi_value accessibilityStatus = nullptr;
    napi_create_string_utf8(env,
        General::accessibilityStatus.c_str(), NAPI_AUTO_LENGTH, &accessibilityStatus);
    paramMap["ACCESSIBILITY_STATUS"] = accessibilityStatus;

    napi_value activAccessServices = nullptr;
    napi_create_string_utf8(env,
        General::activatedAccessibilityServices.c_str(), NAPI_AUTO_LENGTH, &activAccessServices);
    paramMap["ACTIVATED_ACCESSIBILITY_SERVICES"] = activAccessServices;

    napi_value geoOriginsAllowed = nullptr;
    napi_create_string_utf8(env,
        General::geolocationOriginsAllowed.c_str(), NAPI_AUTO_LENGTH, &geoOriginsAllowed);
    paramMap["GEOLOCATION_ORIGINS_ALLOWED"] = geoOriginsAllowed;

    napi_value skipUseHints = nullptr;
    napi_create_string_utf8(env,
        General::skipUseHints.c_str(), NAPI_AUTO_LENGTH, &skipUseHints);
    paramMap["SKIP_USE_HINTS"] = skipUseHints;

    napi_value touchExplorationStatus = nullptr;
    napi_create_string_utf8(env,
        General::touchExplorationStatus.c_str(), NAPI_AUTO_LENGTH, &touchExplorationStatus);
    paramMap["TOUCH_EXPLORATION_STATUS"] = touchExplorationStatus;
}

void InitInputMap(napi_env env, std::map<const char*, napi_value>& paramMap)
{
    napi_value defInputMethod = nullptr;
    napi_create_string_utf8(env,
        Input::defaultInputMethod.c_str(), NAPI_AUTO_LENGTH, &defInputMethod);
    paramMap["DEFAULT_INPUT_METHOD"] = defInputMethod;

    napi_value activeSubMode = nullptr;
    napi_create_string_utf8(env,
        Input::activatedInputMethodSubMode.c_str(), NAPI_AUTO_LENGTH, &activeSubMode);
    paramMap["ACTIVATED_INPUT_METHOD_SUB_MODE"] = activeSubMode;

    napi_value activatedInputMethod = nullptr;
    napi_create_string_utf8(env,
        Input::activatedInputMethods.c_str(), NAPI_AUTO_LENGTH, &activatedInputMethod);
    paramMap["ACTIVATED_INPUT_METHODS"] = activatedInputMethod;

    napi_value selectorVisibility = nullptr;
    napi_create_string_utf8(env,
        Input::selectorVisibilityForInputMethod.c_str(), NAPI_AUTO_LENGTH, &selectorVisibility);
    paramMap["SELECTOR_VISIBILITY_FOR_INPUT_METHOD"] = selectorVisibility;

    napi_value autoCapsTextInput = nullptr;
    napi_create_string_utf8(env,
        Input::autoCapsTextInput.c_str(), NAPI_AUTO_LENGTH, &autoCapsTextInput);
    paramMap["AUTO_CAPS_TEXT_INPUT"] = autoCapsTextInput;

    napi_value autoPunctuate = nullptr;
    napi_create_string_utf8(env,
        Input::autoPunctuateTextInput.c_str(), NAPI_AUTO_LENGTH, &autoPunctuate);
    paramMap["AUTO_PUNCTUATE_TEXT_INPUT"] = autoPunctuate;

    napi_value autoReplace = nullptr;
    napi_create_string_utf8(env,
        Input::autoReplaceTextInput.c_str(), NAPI_AUTO_LENGTH, &autoReplace);
    paramMap["AUTO_REPLACE_TEXT_INPUT"] = autoReplace;

    napi_value showPassword = nullptr;
    napi_create_string_utf8(env,
        Input::showPasswordTextInput.c_str(), NAPI_AUTO_LENGTH, &showPassword);
    paramMap["SHOW_PASSWORD_TEXT_INPUT"] = showPassword;
}

void InitNetworkMap(napi_env env, std::map<const char*, napi_value>& paramMap)
{
    SETTING_LOG_INFO("%{public}s is called", __FUNCTION__);

    napi_value dataRoamingStatus = nullptr;
    napi_create_string_utf8(env,
        Network::dataRoamingStatus.c_str(), NAPI_AUTO_LENGTH, &dataRoamingStatus);
    paramMap["DATA_ROAMING_STATUS"] = dataRoamingStatus;

    napi_value httpProxyCfg = nullptr;
    napi_create_string_utf8(env,
        Network::httpProxyCfg.c_str(), NAPI_AUTO_LENGTH, &httpProxyCfg);
    paramMap["HTTP_PROXY_CFG"] = httpProxyCfg;

    napi_value networkPrefUsage = nullptr;
    napi_create_string_utf8(env,
        Network::networkPreferenceUsage.c_str(), NAPI_AUTO_LENGTH, &networkPrefUsage);
    paramMap["NETWORK_PREFERENCE_USAGE"] = networkPrefUsage;

    SETTING_LOG_INFO("%{public}s is end", __FUNCTION__);
}

void InitPhoneMap(napi_env env, std::map<const char*, napi_value>& paramMap)
{
    SETTING_LOG_INFO("%{public}s is called", __FUNCTION__);

    napi_value rttCallingStatus = nullptr;
    napi_create_string_utf8(env,
        Phone::rttCallingStatus.c_str(), NAPI_AUTO_LENGTH, &rttCallingStatus);
    paramMap["RTT_CALLING_STATUS"] = rttCallingStatus;

    SETTING_LOG_INFO("%{public}s is end", __FUNCTION__);
}

void InitSoundMap(napi_env env, std::map<const char*, napi_value>& paramMap)
{
    napi_value vibrateWhileRinging = nullptr;
    napi_create_string_utf8(env,
        Sound::vibrateWhileRinging.c_str(), NAPI_AUTO_LENGTH, &vibrateWhileRinging);
    paramMap["VIBRATE_WHILE_RINGING"] = vibrateWhileRinging;

    napi_value defAlarmAlert = nullptr;
    napi_create_string_utf8(env,
        Sound::defaultAlarmAlert.c_str(), NAPI_AUTO_LENGTH, &defAlarmAlert);
    paramMap["DEFAULT_ALARM_ALERT"] = defAlarmAlert;

    napi_value dtmfToneType = nullptr;
    napi_create_string_utf8(env,
        Sound::dtmfToneTypeWhileDialing.c_str(), NAPI_AUTO_LENGTH, &dtmfToneType);
    paramMap["DTMF_TONE_TYPE_WHILE_DIALING"] = dtmfToneType;

    napi_value dtmfTone = nullptr;
    napi_create_string_utf8(env,
        Sound::dtmfToneWhileDialing.c_str(), NAPI_AUTO_LENGTH, &dtmfTone);
    paramMap["DTMF_TONE_WHILE_DIALING"] = dtmfTone;

    napi_value hapticFeedbackStatus = nullptr;
    napi_create_string_utf8(env,
        Sound::hapticFeedbackStatus.c_str(), NAPI_AUTO_LENGTH, &hapticFeedbackStatus);
    paramMap["HAPTIC_FEEDBACK_STATUS"] = hapticFeedbackStatus;

    napi_value affectedModeRingerStreams = nullptr;
    napi_create_string_utf8(env,
        Sound::affectedModeRingerStreams.c_str(), NAPI_AUTO_LENGTH, &affectedModeRingerStreams);
    paramMap["AFFECTED_MODE_RINGER_STREAMS"] = affectedModeRingerStreams;

    napi_value affectedMuteStreams = nullptr;
    napi_create_string_utf8(env,
        Sound::affectedMuteStreams.c_str(), NAPI_AUTO_LENGTH, &affectedMuteStreams);
    paramMap["AFFECTED_MUTE_STREAMS"] = affectedMuteStreams;

    napi_value defNotificationSound = nullptr;
    napi_create_string_utf8(env,
        Sound::defaultNotificationSound.c_str(), NAPI_AUTO_LENGTH, &defNotificationSound);
    paramMap["DEFAULT_NOTIFICATION_SOUND"] = defNotificationSound;

    napi_value defRingtone = nullptr;
    napi_create_string_utf8(env,
        Sound::defaultRingtone.c_str(), NAPI_AUTO_LENGTH, &defRingtone);
    paramMap["DEFAULT_RINGTONE"] = defRingtone;

    napi_value soundEffectsStatus = nullptr;
    napi_create_string_utf8(env,
        Sound::soundEffectsStatus.c_str(), NAPI_AUTO_LENGTH, &soundEffectsStatus);
    paramMap["SOUND_EFFECTS_STATUS"] = soundEffectsStatus;

    napi_value vibrateStatus = nullptr;
    napi_create_string_utf8(env,
        Sound::vibrateStatus.c_str(), NAPI_AUTO_LENGTH, &vibrateStatus);
    paramMap["VIBRATE_STATUS"] = vibrateStatus;
}

void InitTTSMap(napi_env env, std::map<const char*, napi_value>& paramMap)
{
    napi_value defTTSPitch = nullptr;
    napi_create_string_utf8(env,
        TTS::defaultTTSPitch.c_str(), NAPI_AUTO_LENGTH, &defTTSPitch);
    paramMap["DEFAULT_TTS_PITCH"] = defTTSPitch;

    napi_value defTTSRate = nullptr;
    napi_create_string_utf8(env,
        TTS::defaultTTSRate.c_str(), NAPI_AUTO_LENGTH, &defTTSRate);
    paramMap["DEFAULT_TTS_RATE"] = defTTSRate;

    napi_value defTTSSynth = nullptr;
    napi_create_string_utf8(env,
        TTS::defaultTTSSynth.c_str(), NAPI_AUTO_LENGTH, &defTTSSynth);
    paramMap["DEFAULT_TTS_SYNTH"] = defTTSSynth;

    napi_value enableTTSPlugins = nullptr;
    napi_create_string_utf8(env,
        TTS::enableTTSPlugins.c_str(), NAPI_AUTO_LENGTH, &enableTTSPlugins);
    paramMap["ENABLED_TTS_PLUGINS"] = enableTTSPlugins;
}

void InitWirelessMap(napi_env env, std::map<const char*, napi_value>& paramMap)
{
    napi_value bluetoothRadio = nullptr;
    napi_create_string_utf8(env,
        Wireless::bluetoothRadio.c_str(), NAPI_AUTO_LENGTH, &bluetoothRadio);
    paramMap["BLUETOOTH_RADIO"] = bluetoothRadio;

    napi_value cellRadio = nullptr;
    napi_create_string_utf8(env,
        Wireless::cellRadio.c_str(), NAPI_AUTO_LENGTH, &cellRadio);
    paramMap["CELL_RADIO"] = cellRadio;

    napi_value nfcRadio = nullptr;
    napi_create_string_utf8(env,
        Wireless::nfcRadio.c_str(), NAPI_AUTO_LENGTH, &nfcRadio);
    paramMap["NFC_RADIO"] = nfcRadio;

    napi_value airplaneModeRadios = nullptr;
    napi_create_string_utf8(env,
        Wireless::airplaneModeRadios.c_str(), NAPI_AUTO_LENGTH, &airplaneModeRadios);
    paramMap["AIRPLANE_MODE_RADIOS"] = airplaneModeRadios;

    napi_value bluetoothStatus = nullptr;
    napi_create_string_utf8(env,
        Wireless::bluetoothStatus.c_str(), NAPI_AUTO_LENGTH, &bluetoothStatus);
    paramMap["BLUETOOTH_STATUS"] = bluetoothStatus;

    napi_value blDiscoverAbilityStatus = nullptr;
    napi_create_string_utf8(env,
        Wireless::bluetoothDiscoverAbilityStatus.c_str(), NAPI_AUTO_LENGTH, &blDiscoverAbilityStatus);
    paramMap["BLUETOOTH_DISCOVER_ABILITY_STATUS"] = blDiscoverAbilityStatus;

    napi_value blDiscoverTimeout = nullptr;
    napi_create_string_utf8(env,
        Wireless::bluetoothDiscoverTimeout.c_str(), NAPI_AUTO_LENGTH, &blDiscoverTimeout);
    paramMap["BLUETOOTH_DISCOVER_TIMEOUT"] = blDiscoverTimeout;

    napi_value wifiDHCPMaxRetryCount = nullptr;
    napi_create_string_utf8(env,
        Wireless::wifiDHCPMaxRetryCount.c_str(), NAPI_AUTO_LENGTH, &wifiDHCPMaxRetryCount);
    paramMap["WIFI_DHCP_MAX_RETRY_COUNT"] = wifiDHCPMaxRetryCount;

    napi_value wifiToMobileDataAwakeTimeout = nullptr;
    napi_create_string_utf8(env,
        Wireless::wifiToMobileDataAwakeTimeout.c_str(), NAPI_AUTO_LENGTH, &wifiToMobileDataAwakeTimeout);
    paramMap["WIFI_TO_MOBILE_DATA_AWAKE_TIMEOUT"] = wifiToMobileDataAwakeTimeout;

    napi_value wifiStatus = nullptr;
    napi_create_string_utf8(env,
        Wireless::wifiStatus.c_str(), NAPI_AUTO_LENGTH, &wifiStatus);
    paramMap["WIFI_STATUS"] = wifiStatus;

    napi_value wifiWatchDogStatus = nullptr;
    napi_create_string_utf8(env,
        Wireless::wifiWatchDogStatus.c_str(), NAPI_AUTO_LENGTH, &wifiWatchDogStatus);
    paramMap["WIFI_WATCHDOG_STATUS"] = wifiWatchDogStatus;

    napi_value wifiRadio = nullptr;
    napi_create_string_utf8(env,
        Wireless::wifiRadio.c_str(), NAPI_AUTO_LENGTH, &wifiRadio);
    paramMap["WIFI_RADIO"] = wifiRadio;

    napi_value ownerLockdownWifiCfg = nullptr;
    napi_create_string_utf8(env,
        Wireless::ownerLockdownWifiCfg.c_str(), NAPI_AUTO_LENGTH, &ownerLockdownWifiCfg);
    paramMap["OWNER_LOCKDOWN_WIFI_CFG"] = ownerLockdownWifiCfg;
}

void InitPowerMap(napi_env env, std::map<const char*, napi_value>& paramMap)
{
    napi_value suspendSourcesCfg = nullptr;
    napi_create_string_utf8(env,
        Power::suspendSourcesCfg.c_str(), NAPI_AUTO_LENGTH, &suspendSourcesCfg);
    paramMap["SUSPEND_SOURCES_CFG"] = suspendSourcesCfg;
}

void InitConstClassByName(napi_env env, napi_value exports, std::string name)
{
    std::map<const char*, napi_value> propertyMap;
    if (name == DATE_CLASS_NAME) {
        InitDateMap(env, propertyMap);
    } else if (name == DISPLAY_CLASS_NAME) {
        InitDisplayMap(env, propertyMap);
    } else if (name == GENERAL_CLASS_NAME) {
        InitGeneralMap(env, propertyMap);
    } else if (name == INPUT_CLASS_NAME) {
        InitInputMap(env, propertyMap);
    } else if (name == NETWORK_CLASS_NAME) {
        InitNetworkMap(env, propertyMap);
    } else if (name == PHONE_CLASS_NAME) {
        InitPhoneMap(env, propertyMap);
    } else if (name == SOUND_CLASS_NAME) {
        InitSoundMap(env, propertyMap);
    } else if (name == TTS_CLASS_NAME) {
        InitTTSMap(env, propertyMap);
    } else if (name == WIRELESS_CLASS_NAME) {
        InitWirelessMap(env, propertyMap);
    } else if (name == TableName_CLASS_NAME) {
        InitTableNameMap(env, propertyMap);
    } else if (name == DomainName_CLASS_NAME) {
        InitDomainNameMap(env, propertyMap);
    } else if (name == POWER_CLASS_NAME) {
        InitPowerMap(env, propertyMap);
    } else {
        return;
    }

    int i = 0;
    napi_property_descriptor descriptors[propertyMap.size()];
    for (auto it : propertyMap) {
        descriptors[i++] = DECLARE_NAPI_STATIC_PROPERTY(it.first, it.second);
    }

    napi_value result = nullptr;
    napi_define_class(env, name.c_str(), NAPI_AUTO_LENGTH, ClassConstructor, nullptr,
        sizeof(descriptors) / sizeof(*descriptors), descriptors, &result);
    napi_set_named_property(env, exports, name.c_str(), result);
}

napi_value InitNapiClass(napi_env env, napi_value exports)
{
    SETTING_LOG_INFO("%{public}s is called", __FUNCTION__);
    InitConstClassByName(env, exports, TableName_CLASS_NAME);
    InitConstClassByName(env, exports, DomainName_CLASS_NAME);
    InitConstClassByName(env, exports, DATE_CLASS_NAME);
    InitConstClassByName(env, exports, DISPLAY_CLASS_NAME);
    InitConstClassByName(env, exports, GENERAL_CLASS_NAME);
    InitConstClassByName(env, exports, INPUT_CLASS_NAME);
    InitConstClassByName(env, exports, NETWORK_CLASS_NAME);
    InitConstClassByName(env, exports, PHONE_CLASS_NAME);
    InitConstClassByName(env, exports, SOUND_CLASS_NAME);
    InitConstClassByName(env, exports, TTS_CLASS_NAME);
    InitConstClassByName(env, exports, WIRELESS_CLASS_NAME);
    InitConstClassByName(env, exports, POWER_CLASS_NAME);
    SETTING_LOG_INFO("%{public}s is end", __FUNCTION__);
    return exports;
}

} // Settings
} // OHOS