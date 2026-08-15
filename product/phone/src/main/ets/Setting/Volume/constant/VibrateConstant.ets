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
 * 振动页面的按钮命名
 * VIBRATE_SYNCHRONIZE_WITH_RINGTONE: 与铃声同步
 * NOT_VIBRATE: 无振动
 */
export enum RadioName {
  VIBRATE_SYNCHRONIZE_WITH_RINGTONE = 'vibrate_synchronize_with_ringtone',
  NOT_VIBRATE = 'not_vibrate'
}

// 来电铃声,静音模式和响铃模式,卡1的振动参数
export const CALL_SILENT_AND_NORMAL_CARD1_VIBRATE_PARAM: string = 'settings.sound.call.silent_and_normal.card1.vibrate_param';

// 来电铃声,静音模式和响铃模式,卡2的振动参数
export const CALL_SILENT_AND_NORMAL_CARD2_VIBRATE_PARAM: string = 'settings.sound.call.silent_and_normal.card2.vibrate_param';

// 来电铃声,振动模式,卡1的振动参数
export const CALL_VIBRATE_CARD1_VIBRATE_PARAM: string = 'settings.sound.call.vibrate.card1.vibrate_param';

// 来电铃声,振动模式,卡2的振动参数
export const CALL_VIBRATE_CARD2_VIBRATE_PARAM: string = 'settings.sound.call.vibrate.card2.vibrate_param';

// 信息铃声,静音模式和响铃模式,卡1的振动参数
export const MESSAGE_SILENT_AND_NORMAL_CARD1_VIBRATE_PARAM: string = 'settings.sound.message.silent_and_normal.card1.vibrate_param';

// 信息铃声,静音模式和响铃模式,卡2的振动参数
export const MESSAGE_SILENT_AND_NORMAL_CARD2_VIBRATE_PARAM: string = 'settings.sound.message.silent_and_normal.card2.vibrate_param';

// 信息铃声,振动模式,卡1的振动参数
export const MESSAGE_VIBRATE_CARD1_VIBRATE_PARAM: string = 'settings.sound.message.vibrate.card1.vibrate_param';

// 信息铃声,振动模式,卡2的振动参数
export const MESSAGE_VIBRATE_CARD2_VIBRATE_PARAM: string = 'settings.sound.message.vibrate.card2.vibrate_param';

// 通知铃声,静音模式和响铃模式,卡1的振动参数
export const NOTIFICATION_SILENT_AND_NORMAL_CARD1_VIBRATE_PARAM: string = 'settings.sound.notification.silent_and_normal.card1.vibrate_param';

// 通知铃声,振动模式,卡1的振动参数
export const NOTIFICATION_VIBRATE_CARD1_VIBRATE_PARAM: string = 'settings.sound.notification.vibrate.card1.vibrate_param';

// 来电铃声、非同步模式的默认振动文件名
export const DEFAULT_CALL_VIBRATE_FILENAME: string = 'Classic.json';

// 信息铃声非同步的振动文件名
export const DEFAULT_MESSAGE_VIBRATE_FILENAME: string = 'Tick-tock.json';

// 通知铃声非同步的振动文件名
export const DEFAULT_NOTIFICATION_VIBRATE_FILENAME: string = 'Tick-tock.json';