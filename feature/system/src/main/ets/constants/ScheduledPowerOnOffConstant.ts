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

const HOUR_7: number = 7;

const HOUR_23: number = 23;

export const MIN_60: number = 60;

export const SHOW_TOAST_TIME: number = 2000;

/**
 * CCM开关显示项
 */
export const SCHEDULED_POWER_ON_OFF_SUPPORT: string = 'const.settings.support_scheduled_power_on_off';

/**
 * 开/关状态
 */
export const SCHEDULED_POWER_ON_OFF_SWITCH: string = 'settings.system.scheduled_power_on_off_switch';

/**
 * 1---开启
 */
export const SCHEDULED_POWER_ON_OFF_OPEN: string = '1';

/**
 * 0--关闭
 */
export const SCHEDULED_POWER_ON_OFF_CLOSE: string = '0';

/**
 * 开机时间
 */
export const SCHEDULED_POWER_ON_TIME: string = 'settings.system.scheduled_power_on_time';

/**
 * 关机时间
 */
export const SCHEDULED_POWER_OFF_TIME: string = 'settings.system.scheduled_power_off_time';

/**
 * 重复周期(0——单次；1——每天；2——每周；3——法定工作日)
 */
export const SCHEDULED_POWER_ON_OFF_REPEAT: string = 'settings.system.scheduled_power_on_off_repeat';

/**
 * 重复周期为week时的具体日期（1:周天；2:周一；3:周二；4:周三；5:周四；6:周五；7:周六）
 */
export const SCHEDULED_POWER_ON_OFF_REPEAT_WEEK: string = 'settings.system.scheduled_power_on_off_repeat_week';

/**
 * 日历信息（法定工作日）
 */
export const SCHEDULED_POWER_ON_OFF_CALENDAR_DATA: string = 'recessInfo';

/**
 * 默认开机时间
 */
export const DEFAULT_SCHEDULED_POWER_ON_TIME: string = (HOUR_7 * MIN_60).toString();

/**
 * 默认关机时间
 */
export const DEFAULT_SCHEDULED_POWER_OFF_TIME: string = (HOUR_23 * MIN_60).toString();

/**
 * 重复周期(2——每周)
 */
export const SCHEDULED_POWER_ON_OFF_WEEK_REPEAT: string = '2';

/**
 * 重复周期(3——法定工作日)
 */
export const SCHEDULED_POWER_ON_OFF_WORKDAY_REPEAT: string = '3';


/**
 * 默认重复周期(0——单次)
 */
export const DEFAULT_SCHEDULED_POWER_ON_OFF_REPEAT: string = '0';

/**
 * 默认每周重复周期
 */
export const DEFAULT_SCHEDULED_POWER_ON_OFF_WEEK_REPEAT: string = '2,3,4,5,6';

/**
 * 开机定时器名称
 */
export const SCHEDULED_POWER_ON_TIMER_NAME: string = 'settings_scheduled_power_on_timer';

/**
 * 关机定时器名称
 */
export const SCHEDULED_POWER_OFF_TIMER_NAME: string = 'powerOffTimer';

/**
 * 立刻关机定时器名称
 */
export const SCHEDULED_POWER_OFF_NOW_TIMER_NAME: string = 'powerOffNowTimer';

/**
 * SystemTimer定时开机时间
 */
export const SCHEDULED_POWER_ON_TIMER_DATE: string = 'settings.system.power_on_timer_date';

/**
 * SystemTimer定时关机通知时间
 */
export const SCHEDULED_POWER_OFF_TIMER_DATE: string = 'settings.system.power_off_timer_date';

/**
 * 定时开机SystemTimerID
 */
export const SCHEDULED_POWER_ON_TIMER_ID: string = 'settings.system.power_on_timer_id';

/**
 * 定时关机通知SystemTimerID
 */
export const SCHEDULED_POWER_OFF_TIMER_ID: string = 'settings.system.power_off_timer_id';

/**
 * 定时关机SystemTimerID
 */
export const SCHEDULED_POWER_OFF_NOW_TIMER_ID: string = 'settings.system.power_off_now_timer_id';

/**
 * 时间未设置
 */
export const SCHEDULED_POWER_TIME_NOT_SET: string = '-1';