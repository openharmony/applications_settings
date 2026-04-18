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

export enum SimRingtoneKey {
  CARD_0_RINGTONE_KEY = 'card0_ringtone',
  CARD_1_RINGTONE_KEY = 'card1_ringtone',
  CARD_0_SMS_RINGTONE_KEY = 'card0_sms_ringtone',
  CARD_1_SMS_RINGTONE_KEY = 'card1_sms_ringtone',
  NOTIFICATION_RINGTONE_KEY = 'notification_ringtone'
}

/**
 * RINGTONE_TYPE_SIM: 来电铃声
 * RINGTONE_TYPE_SMS: 信息铃声
 * RINGTONE_TYPE_NOTIFICATION: 通知铃声
 * RINGTONE_TYPE_ALARM: 闹钟铃声
 */
export enum RingtoneType {
  RINGTONE_TYPE_SIM,
  RINGTONE_TYPE_SMS,
  RINGTONE_TYPE_NOTIFICATION,
  RINGTONE_TYPE_ALARM
}

export const RINGTONE_TOP_ICONS: Resource[] = [
  $r('sys.symbol.bell_slash'),
  $r('sys.symbol.rectangle_portrait_wave_2'),
  $r('sys.symbol.bell'),
];

export const NO_VIBRATE_ICONS: Resource[] = [
  $r('sys.symbol.bell_slash'),
  $r('sys.symbol.bell_slash'),
  $r('sys.symbol.bell'),
];

export const MEDIA_TOP_ICONS: Resource[] = [
  $r('sys.symbol.speaker_slash'),
  $r('sys.symbol.speaker_wave_1'),
  $r('sys.symbol.speaker_wave_2'),
  $r('sys.symbol.speaker_wave_3'),
];

export enum MediaType {
  MEDIA_OFF = 0,
  MEDIA_SMALL,
  MEDIA_MEDIUM,
  MEDIA_ON
};

export const DIAL_TONE_MENU = [
  $r('app.string.no_sound'),
  $r('app.string.default_ringtone'),
  $r('app.string.music_melodies')
];

export const MAX_VOLUME_SLIDER_VALUE: number = 15;

export const VOLUME_PERCENT: number = 100;

export const EVENT_SYSTEM_RINGTONE: string = 'EVENT_SYSTEM_RINGTONE';

export const EVENT_SYSTEM_MESSAGETONE: string = 'EVENT_SYSTEM_MESSAGETONE';

export const EVENT_SYSTEM_NOTIFICATIONTONE: string = 'EVENT_SYSTEM_NOTIFICATIONTONE';

export const DEFAULT_NO_RINGTONE_URI: string = 'no_system_sound';

export const DEFAULT_NO_RING_URI: string = 'no_ring_sound';

export const DEFAULT_CARD0_RINGTONE: string = 'Tune Harmony';

export const DEFAULT_CARD0_RINGTONE_CN: string = '经典旋律';

export const DEFAULT_CARD1_RINGTONE: string = 'Tune Clean';

export const DEFAULT_CARD1_RINGTONE_CN: string = '纯净旋律';

export const DEFAULT_MESSAGE_TONE: string = 'Leap';

export const DEFAULT_MESSAGE_TONE_CN: string = '跃动';

export const DEFAULT_NOTIFICATION_TONE: string = 'Rise';

export const DEFAULT_NOTIFICATION_TONE_CN: string = '昂扬';

export const RINGTONE_TYPE_SYSTEM: number = 0;

export const RINGTONE_TYPE_CUSTOM: number = 1;

// 音效音质
export const SOUND_QUALITY_EFFECT: string = 'settings.audio.sound_effect_model';

// 舒享模式
export const COMFORT_ENJOY_MODE: string = '0';

// 静享模式
export const QUIET_ENJOY_MODE: string = '1';

// 尊享模式
export const NOBLE_ENJOY_MODE: string = '2';

export const DEFAULT_VOLUME_CONTROL_KEY: string = 'default_volume_key_control';

export const VOLUME_CONTROL_MEDIA_VALUE: string = '1';

export const VOLUME_CONTROL_RINGTONE_VALUE: string = '2';