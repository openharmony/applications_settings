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

import { HOUR_22, HOUR_24, HOUR_7, MIN_60 } from './DisplayConstant';

export const EVENTID_DATKALL_SWITCHSTAUTS = 1001;
export const MODE_STATE = 1002;
export const SET_MODE_DELAY: number = 200;
export const SWITCH_DELAY: number = 2200;
export const SYSTEM_COLOR_MODE: string = 'colorMode';
export const COLOR_MODE_LIGHT: number = 1;
export const COLOR_MODE_DARK: number = 0;
export const SETTING_DATA_DARK_MODE: string = '2';
export const SETTING_DATA_LIGHT_MODE: string = '1';
export const SETTINGS_UI_APPEARANCE_DARK_MODE: string = 'settings.uiappearance.darkmode_mode';
export const SETTINGS_UI_APPEARANCE_DARK_MODE_STARTTIME: string = 'settings.uiappearance.darkmode_starttime';
export const SETTINGS_UI_APPEARANCE_DARK_MODE_ENDTIME: string = 'settings.uiappearance.darkmode_endtime';
export const INVALID_VALUE = '-1';
export const DARK_MODE_STATE: string = 'dark_mode_state';
export const DEFAULT_DARK_MODE_STATE: string = '0';
export const DARK_MODE_OPEN_ALL_DAY: string = '1';
export const DARK_MODE_TIMED_ON: string = '2';
export const DEFAULT_DARK_MODE_START_TIME: string = (HOUR_22 * MIN_60).toString();
export const DEFAULT_DARK_MODE_END_TIME: string = ((HOUR_24 + HOUR_7) * MIN_60).toString();
export const TIMED_ON_DARK_MODE_OPEN_EVENT: string = 'timed_on_dark_mode_open_event';
export const CLICK_ENABLE_EVENT: string = 'click_enable_event';