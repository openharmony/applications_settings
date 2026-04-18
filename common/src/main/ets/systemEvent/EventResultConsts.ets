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

export enum EventResultConsts {
  SWITCH_ON = 'on',
  SWITCH_OFF = 'off',
}

export enum HotspotBandName {
  HOTSPOT_BAND_2_4 = 'hotspot_band_2_4',
  HOTSPOT_BAND_5 = 'hotspot_band_5'
}

export const EVENT_SYSTEM_RINGTONE: string = 'EVENT_SYSTEM_RINGTONE';

export const EVENT_SYSTEM_MESSAGETONE: string = 'EVENT_SYSTEM_MESSAGETONE';

export const EVENT_SYSTEM_NOTIFICATIONTONE: string = 'EVENT_SYSTEM_NOTIFICATIONTONE';

export const DEFAULT_NO_RINGTONE_URI: string = 'no_system_sound';

export const DEFAULT_CARD0_RINGTONE: string = 'Tune Harmony';

export const DEFAULT_CARD0_RINGTONE_CN: string = '经典旋律';

export const DEFAULT_CARD1_RINGTONE: string = 'Tune Clean';

export const DEFAULT_CARD1_RINGTONE_CN: string = '纯净旋律';

export const DEFAULT_MESSAGE_TONE: string = 'Leap';

export const DEFAULT_MESSAGE_TONE_CN: string = '跃动';

export const DEFAULT_NOTIFICATION_TONE: string = 'Rise';

export const DEFAULT_NOTIFICATION_TONE_CN: string = '昂扬';

export enum SimRingtoneKey {
  CARD_0_RINGTONE_KEY = 'card0_ringtone',
  CARD_1_RINGTONE_KEY = 'card1_ringtone',
  CARD_0_SMS_RINGTONE_KEY = 'card0_sms_ringtone',
  CARD_1_SMS_RINGTONE_KEY = 'card1_sms_ringtone',
  NOTIFICATION_RINGTONE_KEY = 'notification_ringtone'
}