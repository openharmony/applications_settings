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

export class TouchPadConstants {
  // 启用触控板 SettingData Key
  public static readonly SETTINGS_TRACKPAD_TOUCHPAD_SWITCHES = 'settings.trackpad.touchpad_switches';
  public static readonly TOUCHPAD_TAP_SWITCH = 'touchpad_tap_switch';
  public static readonly TOUCHPAD_SPEED = 'touchpad_speed';
  public static readonly TOUCHPAD_GESTURE_SECONDARY = 'touchpad_gesture_secondary';
  public static readonly TOUCHPAD_GESTURE_TAP = 'touchpad_gesture_tap';
  public static readonly EVENT_TOUCHPAD_SWITCH = 'event_touchpad_switch';
  public static readonly POINTER_MIN_SPEED = 1;
  public static readonly POINTER_MAX_SPEED = 11;
  public static readonly POINTER_SPEED_SIZE = 0.1;
  public static readonly DEFAULT_SPEED = 7;
  public static readonly TOUCHPAD_RIGHT_BUTTON = 1;
  public static readonly TOUCHPAD_TWO_FINGER_TAP = 3;
}