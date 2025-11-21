/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { AsyncCallback, BusinessError } from '@ohos.base';
import Context from 'application.Context';

export namespace settings {

  loadLibrary("settings_ani.z");

  namespace domainName {
    const DEVICE_SHARED: string = "global";
    const USER_PROPERTY: string = "system";
    const USER_SECURITY: string = "secure";
  }

  namespace date {
    const DATE_FORMAT: string = "settings.date.date_format";
    const TIME_FORMAT: string = "settings.date.time_format";
    const AUTO_GAIN_TIME: string = "settings.date.auto_gain_time";
    const AUTO_GAIN_TIME_ZONE: string = "settings.date.auto_gain_time_zone";
  }

  namespace display {
    const FONT_SCALE: string = "font_scale";
    const SCREEN_BRIGHTNESS_STATUS: string = "settings.display.screen_brightness_status";
    const AUTO_SCREEN_BRIGHTNESS: string = "settings.display.auto_screen_brightness";
    const AUTO_SCREEN_BRIGHTNESS_MODE: int = 1;
    const MANUAL_SCREEN_BRIGHTNESS_MODE: int = 0;
    const SCREEN_OFF_TIMEOUT: string = "settings.display.screen_off_timeout";
    const DEFAULT_SCREEN_ROTATION: string = "settings.display.default_screen_rotation";
    const ANIMATOR_DURATION_SCALE: string = "settings.display.animator_duration_scale";
    const TRANSITION_ANIMATION_SCALE: string = "settings.display.transition_animation_scale";
    const WINDOW_ANIMATION_SCALE: string = "settings.display.window_animation_scale";
    const DISPLAY_INVERSION_STATUS: string = "settings.display.display_inversion_status";
  }

  namespace general {
    const SETUP_WIZARD_FINISHED: string = "settings.general.setup_wizard_finished";
    const END_BUTTON_ACTION: string = "settings.general.end_button_action";
    const ACCELEROMETER_ROTATION_STATUS: string = "settings.general.accelerometer_rotation_status";
    const AIRPLANE_MODE_STATUS: string = "settings.general.airplane_mode_status";
    const DEVICE_PROVISION_STATUS: string = "settings.general.device_provision_status";
    const HDC_STATUS: string = "settings.general.hdc_status";
    const BOOT_COUNTING: string = "settings.general.boot_counting";
    const CONTACT_METADATA_SYNC_STATUS: string = "settings.general.contact_metadata_sync_status";
    const DEVELOPMENT_SETTINGS_STATUS: string = "settings.general.development_settings_status";
    const DEVICE_NAME: string = "settings.general.device_name";
    const USB_STORAGE_STATUS: string = "settings.general.usb_storage_status";
    const DEBUGGER_WAITING: string = "settings.general.debugger_waiting";
    const DEBUG_APP_PACKAGE: string = "settings.general.debug_app_package";
    const ACCESSIBILITY_STATUS: string = "settings.general.accessibility_status";
    const ACTIVATED_ACCESSIBILITY_SERVICES: string = "settings.general.activated_accessibility_services";
    const GEOLOCATION_ORIGINS_ALLOWED: string = "settings.general.geolocation_origins_allowed";
    const SKIP_USE_HINTS: string = "settings.general.skip_use_hints";
    const TOUCH_EXPLORATION_STATUS: string = "settings.general.touch_exploration_status";
  }

  namespace input {
    const DEFAULT_INPUT_METHOD: string = "settings.input.default_input_method";
    const ACTIVATED_INPUT_METHOD_SUB_MODE: string = "settings.input.activated_input_method_submode";
    const ACTIVATED_INPUT_METHODS: string = "settings.input.activated_input_methods";
    const SELECTOR_VISIBILITY_FOR_INPUT_METHOD: string = "settings.input.selector_visibility_for_input_method";
    const AUTO_CAPS_TEXT_INPUT: string = "settings.input.auto_caps_text_input";
    const AUTO_PUNCTUATE_TEXT_INPUT: string = "settings.input.auto_punctuate_text_input";
    const AUTO_REPLACE_TEXT_INPUT: string = "settings.input.auto_replace_text_input";
    const SHOW_PASSWORD_TEXT_INPUT: string = "settings.input.show_password_text_input";
  }

  namespace network {
    const DATA_ROAMING_STATUS: string = "settings.network.data_roaming_status";
    const HTTP_PROXY_CFG: string = "settings.network.http_proxy_cfg";
    const NETWORK_PREFERENCE_USAGE: string = "settings.network.network_preference_usage";
  }

  namespace phone {
    const RTT_CALLING_STATUS: string = "settings.phone.rtt_calling_status";
  }

  namespace sound {
    const VIBRATE_WHILE_RINGING: string = "settings.sound.vibrate_while_ringing";
    const DEFAULT_ALARM_ALERT: string = "settings.sound.default_alarm_alert";
    const DTMF_TONE_TYPE_WHILE_DIALING: string = "settings.sound.dtmf_tone_type_while_dialing";
    const DTMF_TONE_WHILE_DIALING: string = "settings.sound.dtmf_tone_while_dialing";
    const AFFECTED_MODE_RINGER_STREAMS: string = "settings.sound.affected_mode_ringer_streams";
    const AFFECTED_MUTE_STREAMS: string = "settings.sound.affected_mute_streams";
    const DEFAULT_NOTIFICATION_SOUND: string = "settings.sound.default_notification_sound";
    const DEFAULT_RINGTONE: string = "settings.sound.default_ringtone";
    const SOUND_EFFECTS_STATUS: string = "settings.sound.sound_effects_status";
    const VIBRATE_STATUS: string = "settings.sound.vibrate_status";
    const HAPTIC_FEEDBACK_STATUS: string = "settings.sound.haptic_feedback_status";
  }

  namespace TTS {
    const DEFAULT_TTS_PITCH: string = "settings.tts.default_tts_pitch";
    const DEFAULT_TTS_RATE: string = "settings.tts.default_tts_rate";
    const DEFAULT_TTS_SYNTH: string = "settings.tts.default_tts_synth";
    const ENABLED_TTS_PLUGINS: string = "settings.tts.enabled_tts_plugins";
  }

  namespace wireless {
    const BLUETOOTH_DISCOVER_ABILITY_STATUS: string = "settings.wireless.bluetooth_discoverability_status";
    const BLUETOOTH_DISCOVER_TIMEOUT: string = "settings.wireless.bluetooth_discover_timeout";
    const AIRPLANE_MODE_RADIOS: string = "settings.wireless.airplane_mode_radios";
    const BLUETOOTH_STATUS: string = "settings.wireless.bluetooth_status";
    const BLUETOOTH_RADIO: string = "settings.wireless.bluetooth_radio";
    const CELL_RADIO: string = "settings.wireless.cell_radio";
    const NFC_RADIO: string = "settings.wireless.nfc_radio";
    const WIFI_RADIO: string = "settings.wireless.wifi_radio";
    const OWNER_LOCKDOWN_WIFI_CFG: string = "settings.wireless.owner_lockdown_wifi_cfg";
    const WIFI_DHCP_MAX_RETRY_COUNT: string = "settings.wireless.wifi_dhcp_max_retry_count";
    const WIFI_TO_MOBILE_DATA_AWAKE_TIMEOUT: string = "settings.wireless.wifi_to_mobile_data_awake_timeout";
    const WIFI_STATUS: string = "settings.wireless.wifi_status";
    const WIFI_WATCHDOG_STATUS: string = "settings.wireless.wifi_watchdog_status";
  }

  native function getValue_inner(context: Context, name: string, domainName: string): string;

  native function setValue_inner(context: Context, name: string, value: string, domainName: string): boolean;

  native function enableAirplaneMode_inner(enable: boolean): void;

  native function canShowFloating_inner(): boolean;

  native function getValueSync_inner(context: Context, name: string, defValue: string, domainName: string): string;

  native function setValueSync_inner(context: Context, name: string, value: string, domainName: string): boolean;

  native function openNetworkManagerSettings_inner(context: Context): boolean;

  export native function getUriSync(name: string): string;

  export native function registerKeyObserver(context: Context, name: string, domainName: string, observer: AsyncCallback<void>): boolean;

  export native function unregisterKeyObserver(context: Context, name: string, domainName: string): boolean;

  export function getValue(context: Context, name: string, callback: AsyncCallback<string>): void {
    taskpool.execute((): string => {
      return getValue_inner(context, name, "global");
    })
      .then((ret: Any): void => {
        callback(null, ret as string);
      })
      .catch((ret: Any): void => {
        let data: string;
        callback(ret as BusinessError, data);
      });
  }

  export function getValue(context: Context, name: string): Promise<string> {
    return new Promise<string>((resolve, reject): void => {
      taskpool.execute((): string => {
        return getValue_inner(context, name, "global");
      })
        .then((ret: Any): void => {
          resolve(ret as string);
        })
        .catch((ret: Any): void => {
          reject(ret as BusinessError);
        });
    });
  }

  export function getValue(context: Context, name: string, domainName: string): Promise<string> {
    return new Promise<string>((resolve, reject): void => {
      taskpool.execute((): string => {
        return getValue_inner(context, name, domainName);
      })
        .then((ret: Any): void => {
          resolve(ret as string);
        })
        .catch((ret: Any): void => {
          reject(ret as BusinessError);
        });
    });
  }

  export function setValue(context: Context, name: string, value: string, callback: AsyncCallback<boolean>): void {
    taskpool.execute((): boolean => {
      return setValue_inner(context, name, value, "global");
    })
      .then((ret: Any): void => {
        callback(null, ret as boolean);
      })
      .catch((ret: Any): void => {
        let data: boolean;
        callback(ret as BusinessError, data);
      });
  }

  export function setValue(context: Context, name: string, value: string): Promise<boolean> {
    return new Promise<boolean>((resolve, reject): void => {
      taskpool.execute((): boolean => {
        return setValue_inner(context, name, value, "global");
      })
        .then((ret: Any): void => {
          resolve(ret as boolean);
        })
        .catch((ret: Any): void => {
          reject(ret as BusinessError);
        });
    });
  }

  export function setValue(context: Context, name: string, value: string, domainName: string): Promise<boolean> {
    return new Promise<boolean>((resolve, reject): void => {
      taskpool.execute((): boolean => {
        return setValue_inner(context, name, value, domainName);
      })
        .then((ret: Any): void => {
          resolve(ret as boolean);
        })
        .catch((ret: Any): void => {
          reject(ret as BusinessError);
        });
    });
  }

  export function enableAirplaneMode(enable: boolean, callback: AsyncCallback<void>): void {
    taskpool.execute((): void => {
      return enableAirplaneMode_inner(enable);
    })
      .then((ret: Any): void => {
        callback(null, ret as undefined);
      })
      .catch((ret: Any): void => {
        let data: undefined;
        callback(ret as BusinessError, data);
      });
  }

  export function enableAirplaneMode(enable: boolean): Promise<void> {
    return new Promise<void>((resolve, reject): void => {
      taskpool.execute((): void => {
        return enableAirplaneMode_inner(enable);
      })
        .then((ret: Any): void => {
          resolve(ret as undefined);
        })
        .catch((ret: Any): void => {
          reject(ret as BusinessError);
        });
    });
  }

  export function canShowFloating(callback: AsyncCallback<boolean>): void {
    taskpool.execute((): boolean => {
      return canShowFloating_inner();
    })
      .then((ret: Any): void => {
        callback(null, ret as boolean);
      })
      .catch((ret: Any): void => {
        let data: boolean;
        callback(ret as BusinessError, data);
      });
  }

  export function canShowFloating(): Promise<boolean> {
    return new Promise<boolean>((resolve, reject): void => {
      taskpool.execute((): boolean => {
        return canShowFloating_inner();
      })
        .then((ret: Any): void => {
          resolve(ret as boolean);
        })
        .catch((ret: Any): void => {
          reject(ret as BusinessError);
        });
    });
  }

  export function getValueSync(context: Context, name: string, defValue: string): string {
    return getValueSync_inner(context, name, defValue, "global");
  }

  export function getValueSync(context: Context, name: string, defValue: string, domainName: string): string {
    return getValueSync_inner(context, name, defValue, domainName);
  }

  export function setValueSync(context: Context, name: string, value: string): boolean {
    return setValueSync_inner(context, name, value, "global");
  }

  export function setValueSync(context: Context, name: string, value: string, domainName: string): boolean {
    return setValueSync_inner(context, name, value, domainName);
  }

  export function openNetworkManagerSettings(context: Context): Promise<boolean> {
    return new Promise<boolean>((resolve, reject): void => {
      taskpool.execute((): boolean => {
        return openNetworkManagerSettings_inner(context);
      })
        .then((ret: Any): void => {
          resolve(ret as boolean);
        })
        .catch((ret: Any): void => {
          reject(ret as BusinessError);
        });
    });
  }
}
