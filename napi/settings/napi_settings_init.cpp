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
#include "hilog_wrapper.h"

namespace ohos {
namespace settings {
class Date
{
public:
    static const std::string DATE_FORMAT;
    static const std::string TIME_FORMAT;
    static const std::string AUTO_GAIN_TIME;
    static const std::string AUTO_GAIN_TIME_ZONE;
};

class Display
{
public:
    static const std::string FONT_SCALE;
    static const std::string SCREEN_BRIGHTNESS_STATUS;
    static const std::string AUTO_SCREEN_BRIGHTNESS;
    static const int AUTO_SCREEN_BRIGHTNESS_MODE;
    static const int MANUAL_SCREEN_BRIGHTNESS_MODE;
    static const std::string SCREEN_OFF_TIMEOUT;
    static const std::string DEFAULT_SCREEN_ROTATION;
    static const std::string ANIMATOR_DURATION_SCALE;
    static const std::string TRANSITION_ANIMATION_SCALE;
    static const std::string WINDOW_ANIMATION_SCALE;
    static const std::string DISPLAY_INVERSION_STATUS;
};

class General
{
public:
    static const std::string SETUP_WIZARD_FINISHED;
    static const std::string END_BUTTON_ACTION;
    static const std::string AIRPLANE_MODE_STATUS;
    static const std::string ACCELEROMETER_ROTATION_STATUS;
    static const std::string DEVICE_PROVISION_STATUS;
    static const std::string HDC_STATUS;
    static const std::string BOOT_COUNTING;
    static const std::string CONTACT_METADATA_SYNC_STATUS;
    static const std::string DEVELOPMENT_SETTINGS_STATUS;
    static const std::string DEVICE_NAME;
    static const std::string USB_STORAGE_STATUS;
    static const std::string DEBUGGER_WAITING;
    static const std::string DEBUG_APP_PACKAGE;
    static const std::string ACCESSIBILITY_STATUS;
    static const std::string ACTIVATED_ACCESSIBILITY_SERVICES;
    static const std::string GEOLOCATION_ORIGINS_ALLOWED;
    static const std::string SKIP_USE_HINTS;
    static const std::string TOUCH_EXPLORATION_STATUS;
};

class Input
{
public:
    static const std::string DEFAULT_INPUT_METHOD;
    static const std::string ACTIVATED_INPUT_METHOD_SUB_MODE;
    static const std::string ACTIVATED_INPUT_METHODS;
    static const std::string SELECTOR_VISIBILITY_FOR_INPUT_METHOD;
    static const std::string AUTO_CAPS_TEXT_INPUT;
    static const std::string AUTO_PUNCTUATE_TEXT_INPUT;
    static const std::string AUTO_REPLACE_TEXT_INPUT;
    static const std::string SHOW_PASSWORD_TEXT_INPUT;
};

class Network
{
public:
    static const std::string DATA_ROAMING_STATUS;
    static const std::string HTTP_PROXY_CFG;
    static const std::string NETWORK_PREFERENCE_USAGE;
};

class Phone
{
public:
    static const std::string RTT_CALLING_STATUS;
};

class Sound
{
public:
    static const std::string VIBRATE_WHILE_RINGING;
    static const std::string DEFAULT_ALARM_ALERT;
    static const std::string DTMF_TONE_TYPE_WHILE_DIALING;
    static const std::string DTMF_TONE_WHILE_DIALING;
    static const std::string HAPTIC_FEEDBACK_STATUS;
    static const std::string AFFECTED_MODE_RINGER_STREAMS;
    static const std::string AFFECTED_MUTE_STREAMS;
    static const std::string DEFAULT_NOTIFICATION_SOUND;
    static const std::string DEFAULT_RINGTONE;
    static const std::string SOUND_EFFECTS_STATUS;
    static const std::string VIBRATE_STATUS;
    // temp audio key, it will be modify in the feature
    static const std::string AUDIO_RINGTONE;
    static const std::string AUDIO_MEDIA;
    static const std::string AUDIO_VOICECALL;
};

class TTS
{
public:
    static const std::string DEFAULT_TTS_PITCH;
    static const std::string DEFAULT_TTS_RATE;
    static const std::string DEFAULT_TTS_SYNTH;
    static const std::string ENABLED_TTS_PLUGINS;
};

class Wireless
{
public:
    static const std::string BLUETOOTH_RADIO;
    static const std::string CELL_RADIO;
    static const std::string NFC_RADIO;
    static const std::string AIRPLANE_MODE_RADIOS;
    static const std::string BLUETOOTH_STATUS;
    static const std::string BLUETOOTH_DISCOVER_ABILITY_STATUS;
    static const std::string BLUETOOTH_DISCOVER_TIMEOUT;
    static const std::string WIFI_DHCP_MAX_RETRY_COUNT;
    static const std::string WIFI_TO_MOBILE_DATA_AWAKE_TIMEOUT;
    static const std::string WIFI_STATUS;
    static const std::string WIFI_WATCHDOG_STATUS;
    static const std::string WIFI_RADIO;
    static const std::string OWNER_LOCKDOWN_WIFI_CFG;
};

const std::string Date::DATE_FORMAT = "settings.date.date_format";
const std::string Date::TIME_FORMAT = "settings.date.time_format";
const std::string Date::AUTO_GAIN_TIME = "settings.date.auto_gain_time";
const std::string Date::AUTO_GAIN_TIME_ZONE = "settings.date.auto_gain_time_zone";

const std::string Display::FONT_SCALE = "settings.display.font_scale";
const std::string Display::SCREEN_BRIGHTNESS_STATUS = "settings.display.screen_brightness_status";
const std::string Display::AUTO_SCREEN_BRIGHTNESS = "settings.display.auto_screen_brightness";
const int Display::AUTO_SCREEN_BRIGHTNESS_MODE = 1;
const int Display::MANUAL_SCREEN_BRIGHTNESS_MODE = 0;
const std::string Display::SCREEN_OFF_TIMEOUT = "settings.display.screen_off_timeout";
const std::string Display::DEFAULT_SCREEN_ROTATION = "settings.display.default_screen_rotation";
const std::string Display::ANIMATOR_DURATION_SCALE = "settings.display.animator_duration_scale";
const std::string Display::TRANSITION_ANIMATION_SCALE = "settings.display.transition_animation_scale";
const std::string Display::WINDOW_ANIMATION_SCALE = "settings.display.window_animation_scale";
const std::string Display::DISPLAY_INVERSION_STATUS = "settings.display.display_inversion_status";

const std::string General::SETUP_WIZARD_FINISHED = "settings.general.setup_wizard_finished";
const std::string General::END_BUTTON_ACTION = "settings.general.end_button_action";
const std::string General::AIRPLANE_MODE_STATUS = "settings.general.airplane_mode_status";
const std::string General::ACCELEROMETER_ROTATION_STATUS = "settings.general.accelerometer_rotation_status";
const std::string General::DEVICE_PROVISION_STATUS = "settings.general.device_provision_status";
const std::string General::HDC_STATUS = "settings.general.hdc_status";
const std::string General::BOOT_COUNTING = "settings.general.boot_counting";
const std::string General::CONTACT_METADATA_SYNC_STATUS = "settings.general.contact_metadata_sync_status";
const std::string General::DEVELOPMENT_SETTINGS_STATUS = "settings.general.development_settings_status";
const std::string General::DEVICE_NAME = "settings.general.device_name";
const std::string General::USB_STORAGE_STATUS = "settings.general.usb_storage_status";
const std::string General::DEBUGGER_WAITING = "settings.general.debugger_waiting";
const std::string General::DEBUG_APP_PACKAGE = "settings.general.debug_app_package";
const std::string General::ACCESSIBILITY_STATUS = "settings.general.accessibility_status";
const std::string General::ACTIVATED_ACCESSIBILITY_SERVICES = "settings.general.activated_accessibility_services";
const std::string General::GEOLOCATION_ORIGINS_ALLOWED = "settings.general.geolocation_origins_allowed";
const std::string General::SKIP_USE_HINTS = "settings.general.skip_use_hints";
const std::string General::TOUCH_EXPLORATION_STATUS = "settings.general.touch_exploration_status";

const std::string Input::DEFAULT_INPUT_METHOD = "settings.input.default_input_method";
const std::string Input::ACTIVATED_INPUT_METHOD_SUB_MODE = "settings.input.activated_input_method_submode";
const std::string Input::ACTIVATED_INPUT_METHODS = "settings.input.activated_input_methods";
const std::string Input::SELECTOR_VISIBILITY_FOR_INPUT_METHOD = "settings.input.selector_visibility_for_input_method";
const std::string Input::AUTO_CAPS_TEXT_INPUT = "settings.input.auto_caps_text_input";
const std::string Input::AUTO_PUNCTUATE_TEXT_INPUT = "settings.input.auto_punctuate_text_input";
const std::string Input::AUTO_REPLACE_TEXT_INPUT = "settings.input.auto_replace_text_input";
const std::string Input::SHOW_PASSWORD_TEXT_INPUT = "settings.input.show_password_text_input";

const std::string Network::DATA_ROAMING_STATUS = "settings.network.data_roaming_status";
const std::string Network::HTTP_PROXY_CFG = "settings.network.http_proxy_cfg";
const std::string Network::NETWORK_PREFERENCE_USAGE = "settings.network.network_preference_usage";

const std::string Phone::RTT_CALLING_STATUS = "settings.phone.rtt_calling_status";

const std::string Sound::VIBRATE_WHILE_RINGING = "settings.sound.vibrate_while_ringing";
const std::string Sound::DEFAULT_ALARM_ALERT = "settings.sound.default_alarm_alert";
const std::string Sound::DTMF_TONE_TYPE_WHILE_DIALING = "settings.sound.dtmf_tone_type_while_dialing";
const std::string Sound::DTMF_TONE_WHILE_DIALING = "settings.sound.dtmf_tone_while_dialing";
const std::string Sound::HAPTIC_FEEDBACK_STATUS = "settings.sound.haptic_feedback_status";
const std::string Sound::AFFECTED_MODE_RINGER_STREAMS = "settings.sound.affected_mode_ringer_streams";
const std::string Sound::AFFECTED_MUTE_STREAMS = "settings.sound.affected_mute_streams";
const std::string Sound::DEFAULT_NOTIFICATION_SOUND = "settings.sound.default_notification_sound";
const std::string Sound::DEFAULT_RINGTONE = "settings.sound.default_ringtone";
const std::string Sound::SOUND_EFFECTS_STATUS = "settings.sound.sound_effects_status";
const std::string Sound::VIBRATE_STATUS = "settings.sound.vibrate_status";

// audio key, it will be modify in the feature
const std::string Sound::AUDIO_RINGTONE = "settings.audio.media";
const std::string Sound::AUDIO_MEDIA = "settings.audio.ringtone";
const std::string Sound::AUDIO_VOICECALL = "settings.audio.voicecall";

const std::string TTS::DEFAULT_TTS_PITCH = "settings.tts.default_tts_pitch";
const std::string TTS::DEFAULT_TTS_RATE = "settings.tts.default_tts_rate";
const std::string TTS::DEFAULT_TTS_SYNTH = "settings.tts.default_tts_synth";
const std::string TTS::ENABLED_TTS_PLUGINS = "settings.tts.enabled_tts_plugins";

const std::string Wireless::BLUETOOTH_RADIO = "settings.wireless.bluetooth_radio";
const std::string Wireless::CELL_RADIO = "settings.wireless.cell_radio";
const std::string Wireless::NFC_RADIO = "settings.wireless.nfc_radio";
const std::string Wireless::AIRPLANE_MODE_RADIOS = "settings.wireless.airplane_mode_radios";
const std::string Wireless::BLUETOOTH_STATUS = "settings.wireless.bluetooth_status";
const std::string Wireless::BLUETOOTH_DISCOVER_ABILITY_STATUS = "settings.wireless.bluetooth_discoverability_status";
const std::string Wireless::BLUETOOTH_DISCOVER_TIMEOUT = "settings.wireless.bluetooth_discover_timeout";
const std::string Wireless::WIFI_DHCP_MAX_RETRY_COUNT = "settings.wireless.wifi_dhcp_max_retry_count";
const std::string Wireless::WIFI_TO_MOBILE_DATA_AWAKE_TIMEOUT = "settings.wireless.wifi_to_mobile_data_awake_timeout";
const std::string Wireless::WIFI_STATUS = "settings.wireless.wifi_status";
const std::string Wireless::WIFI_WATCHDOG_STATUS = "settings.wireless.wifi_watchdog_status";
const std::string Wireless::WIFI_RADIO = "settings.wireless.wifi_radio";
const std::string Wireless::OWNER_LOCKDOWN_WIFI_CFG = "settings.wireless.owner_lockdown_wifi_cfg";

const std::string DATE_CLASS_NAME = "date";
const std::string DISPLAY_CLASS_NAME = "display";
const std::string GENERAL_CLASS_NAME = "general";
const std::string INPUT_CLASS_NAME = "input";
const std::string NETWORK_CLASS_NAME = "network";
const std::string PHONE_CLASS_NAME = "phone";
const std::string SOUND_CLASS_NAME = "sound";
const std::string TTS_CLASS_NAME = "tts";
const std::string WIRELESS_CLASS_NAME = "wireless";

napi_value ClassConstructor(napi_env env, napi_callback_info info)
{
    HILOG_INFO("%{public}s is called", __FUNCTION__);
    size_t argc = 0;
    napi_value argv = nullptr;
    napi_value thisArg = nullptr;
    void* data = nullptr;
    napi_get_cb_info(env, info, &argc, &argv, &thisArg, &data);

    napi_value global = 0;
    napi_get_global(env, &global);
    HILOG_INFO("%{public}s is end", __FUNCTION__);
    return thisArg;
}

void InitDateMap(napi_env env, std::map<const char*, napi_value>& eventTypeMap)
{
    HILOG_INFO("%{public}s is called", __FUNCTION__);
    napi_value timeFormat = nullptr;
    napi_create_string_utf8(env, Date::TIME_FORMAT.c_str(), NAPI_AUTO_LENGTH, &timeFormat);

    eventTypeMap["TIME_FORMAT"] = timeFormat;
    HILOG_INFO("%{public}s is end", __FUNCTION__);
}

void InitDisplayMap(napi_env env, std::map<const char*, napi_value>& eventMap)
{
    HILOG_INFO("%{public}s is called", __FUNCTION__);
    napi_value brightnessStatus = nullptr;
    napi_create_string_utf8(env, Display::SCREEN_BRIGHTNESS_STATUS.c_str(), NAPI_AUTO_LENGTH, &brightnessStatus);

    eventMap["SCREEN_BRIGHTNESS_STATUS"] = brightnessStatus;
    HILOG_INFO("%{public}s is end", __FUNCTION__);
}

void InitSoundMap(napi_env env, std::map<const char*, napi_value>& paramMap)
{
    HILOG_INFO("%{public}s is called", __FUNCTION__);
    napi_value audioMediaValue = nullptr;
    napi_create_string_utf8(env, Sound::AUDIO_MEDIA.c_str(), NAPI_AUTO_LENGTH, &audioMediaValue);
    napi_value audioRingtoneValue = nullptr;
    napi_create_string_utf8(env, Sound::AUDIO_RINGTONE.c_str(), NAPI_AUTO_LENGTH, &audioRingtoneValue);
    napi_value audioVoiceCallValue = nullptr;
    napi_create_string_utf8(env, Sound::AUDIO_VOICECALL.c_str(), NAPI_AUTO_LENGTH, &audioVoiceCallValue);

    paramMap["AUDIO_MEDIA"] = audioMediaValue;
    paramMap["AUDIO_RINGTONE"] = audioRingtoneValue;
    paramMap["AUDIO_VOICECALL"] = audioVoiceCallValue;
    HILOG_INFO("%{public}s is end", __FUNCTION__);
}

void InitConstClassByName(napi_env env, napi_value exports, std::string name)
{
    HILOG_INFO("%{public}s is called", __FUNCTION__);
    std::map<const char*, napi_value> propertyMap;
    if (name == DATE_CLASS_NAME) {
        InitDateMap(env, propertyMap);
    } else if (name == DISPLAY_CLASS_NAME) {
        InitDisplayMap(env, propertyMap);
    } else if (name == SOUND_CLASS_NAME) {
        InitSoundMap(env, propertyMap);
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
    HILOG_INFO("%{public}s is end", __FUNCTION__);
}

napi_value InitNapiClass(napi_env env, napi_value exports)
{
    HILOG_INFO("%{public}s is called", __FUNCTION__);
    InitConstClassByName(env, exports, DATE_CLASS_NAME);
    InitConstClassByName(env, exports, DISPLAY_CLASS_NAME);
    InitConstClassByName(env, exports, SOUND_CLASS_NAME);
    HILOG_INFO("%{public}s is end", __FUNCTION__);
    return exports;
}

} // settings
} // ohos