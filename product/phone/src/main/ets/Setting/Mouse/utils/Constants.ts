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

export class MouseAppStorageName {
  static readonly MOUSE_POINTER_SPEED_DEFAULT_VALUE = 5;
  static readonly MOUSE_POINT_SIZE_DEFAULT_VALUE = 3;
}

export enum MousePointColorIndex {
  MOUSE_POINT_RED_INDEX = 1,
  MOUSE_POINT_YELLOW_INDEX = 2,
  MOUSE_POINT_GREEN_INDEX = 3,
  MOUSE_POINT_CYAN_INDEX = 4,
  MOUSE_POINT_BLUE_INDEX = 5,
  MOUSE_POINT_PURPLE_INDEX = 6,
  MOUSE_POINT_WHITE_INDEX = 7,
  MOUSE_POINT_BLACK_INDEX = 8,
}

export enum MousePointColor {
  MOUSE_POINT_RED = 0xE53D24,
  MOUSE_POINT_YELLOW = 0xF6C800,
  MOUSE_POINT_GREEN = 0x63B959,
  MOUSE_POINT_CYAN = 0x48ADDD,
  MOUSE_POINT_BLUE = 0x5445EF,
  MOUSE_POINT_PURPLE = 0xA946F1,
  MOUSE_POINT_WHITE = 0xFFFFFF,
  MOUSE_POINT_BLACK = 0x171717,
}

export class MouseConstants {
  static MOUSE_IMAGE_RATIO = '80%';
  static MOUSE_MAGIC_CURSOR = 'isMagicCursor';
  static MOUSE_MAGIC_VARIABLE = 'smartChange';
  static MOUSE_MIN_SIZE = 1;
  static MOUSE_MAX_SIZE = 7;
  static MOUSE_STEP_SIZE = 1;
  static MOUSE_MIN_SPEED = 1;
  static MOUSE_MAX_SPEED = 20;
  static MOUSE_STEP_SPEED = 1;
  static MOUSE_SETTING_INTERVAL = 50;
  static MOUSE_SPLIT_DEF = 1; //1为正常模式
  static MOUSE_SPLIT = 5; //5为分屏模式
  static MOUSE_TEXT_WIDTH = '130vp';
}

export enum MouseSliderType {
  DEFAULT,
  MousePointerSize,
  MousePointerSpeed
}

export enum MouseStyleType {
  DEFAULT = 'mouse_default_cursor',
  MouseDotCursor = 'mouse_dot_cursor',
  MouseArrowCursor = 'mouse_arrow_cursor'
}