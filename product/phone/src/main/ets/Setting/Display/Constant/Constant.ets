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

export enum SleepTime {
  FIFTEEN_SECONDS = '15000',
  THIRTY_SECONDS = '30000',
  ONE_MINUTE = '60000',
  TWO_MINUTES = '120000',
  FIVE_MINUTES = '300000',
  TEN_MINUTES = '600000',
  NEVER_SLEEP = '-1',
}

export const sleepTimeArr: string[] = [
  SleepTime.FIFTEEN_SECONDS,
  SleepTime.THIRTY_SECONDS,
  SleepTime.ONE_MINUTE,
  SleepTime.TWO_MINUTES,
  SleepTime.FIVE_MINUTES,
  SleepTime.TEN_MINUTES,
  SleepTime.NEVER_SLEEP
]

export enum SleepKey {
  ENTER_DORMANCY_ENTRY = 'enter_dormancy_entry',
  FIFTEEN_SECONDS_KEY = 'fifteen_seconds_dormancy',
  THIRTY_SECONDS_KEY = 'thirty_seconds_dormancy',
  ONE_MINUTE_KEY = 'one_minute_dormancy',
  TWO_MINUTES_KEY = 'two_minutes_dormancy',
  FIVE_MINUTES_KEY = 'five_minutes_dormancy',
  TEN_MINUTES_KEY = 'ten_minutes_dormancy',
}

export enum SleepTimeNum {
  SLEEP_TIME_FIFTEEN_SECONDS = '15',
  SLEEP_TIME_THIRTY_SECONDS = '30',
  SLEEP_TIME_ONE_MINUTE = '1',
  SLEEP_TIME_TWO_MINUTES = '2',
  SLEEP_TIME_FIVE_MINUTES = '5',
  SLEEP_TIME_TEN_MINUTES = '10',
}

export const sleepTimeNumArr: string[] = [
  '15',
  '30',
  '1',
  '2',
  '5',
  '10',
]

/*
 * 隐藏屏幕挖孔
 * */
export const CUTOUTS_PARAM: string = 'persist.sys.graphic.hideNotch.status';

export enum HideCutoutsNum {
  // 0: 不支持隐藏屏幕挖孔 默认值;
  NOT_SUPPORTED = '0',
  // 1: 支持-但是不隐藏屏幕挖孔;
  SUPPORTED_SHOW = '1',
  // 2: 支持-隐藏屏幕挖孔;
  SUPPORTED_HIDE = '2',
}

/**
 * 注释屏幕不熄屏 开关打开 1
 */
export const GAZE_ON: string = '1';

/**
 * 注释屏幕不熄屏 开关关闭 0 默认值
 */
export const GAZE_OFF: string = '0';

/**
 * 分辨率类型： 智能分辨率
 */
export const SMART_RESOLUTION_TYPE: string = '0';

/**
 * 智能分辨率 开
 */
export const SMART_RESOLUTION_OPEN: string = '0';

/**
 * 智能分辨率 关
 */
export const SMART_RESOLUTION_CLOSE: string = '1';

export const SLEEP_KEY_MAP: Map<string, string> = new Map([
  [SleepKey.FIFTEEN_SECONDS_KEY, SleepTimeNum.SLEEP_TIME_FIFTEEN_SECONDS],
  [SleepKey.THIRTY_SECONDS_KEY, SleepTimeNum.SLEEP_TIME_THIRTY_SECONDS],
  [SleepKey.ONE_MINUTE_KEY, SleepTimeNum.SLEEP_TIME_ONE_MINUTE],
  [SleepKey.TWO_MINUTES_KEY, SleepTimeNum.SLEEP_TIME_TWO_MINUTES],
  [SleepKey.FIVE_MINUTES_KEY, SleepTimeNum.SLEEP_TIME_FIVE_MINUTES],
  [SleepKey.TEN_MINUTES_KEY, SleepTimeNum.SLEEP_TIME_TEN_MINUTES],
]);

export const SLEEP_TIME_MAP: Map<string, string> = new Map([
  [SleepTime.FIFTEEN_SECONDS, SleepTimeNum.SLEEP_TIME_FIFTEEN_SECONDS],
  [SleepTime.THIRTY_SECONDS, SleepTimeNum.SLEEP_TIME_THIRTY_SECONDS],
  [SleepTime.ONE_MINUTE, SleepTimeNum.SLEEP_TIME_ONE_MINUTE],
  [SleepTime.TWO_MINUTES, SleepTimeNum.SLEEP_TIME_TWO_MINUTES],
  [SleepTime.FIVE_MINUTES, SleepTimeNum.SLEEP_TIME_FIVE_MINUTES],
  [SleepTime.TEN_MINUTES, SleepTimeNum.SLEEP_TIME_TEN_MINUTES],
]);

// 皮套模式页面字符串常量
export const COVER_ENABLED: string = 'cover_enabled'; // 皮套开关key值, 1: 打开, 0: 关闭
export const COVER_ENABLED_TRUE: string = '1';
export const COVER_ENABLED_FALSE: string = '0';
export const COVER_TYPE: string = 'cover_type'; // 开窗皮套key值, 0: 打开, 1: 关闭
export const COVER_TYPE_ENABLED: string = '0';
export const COVER_TYPE_UNABLED: string = '1';
export const COVER_MODE: string = 'const.product.cover_mode'; // 0表示不支持皮套，1简易皮套，2开窗皮套
export const SIMPLE_COVER: string = '1';
export const SMART_COVER: string = '2';

export const SLEEP_TIME_STR: Resource[] = [
  $r('app.string.fifteen_seconds'),
  $r('app.string.thirty_seconds'),
  $r('app.string.one_minute'),
  $r('app.string.two_minutes'),
  $r('app.string.five_minutes'),
  $r('app.string.ten_minutes'),
];