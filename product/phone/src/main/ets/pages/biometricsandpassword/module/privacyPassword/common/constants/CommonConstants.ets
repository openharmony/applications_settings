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

export class CommonConstants {
  /**
   * 倒计时时间单位阈值，以一分钟为界，在分钟和秒之间切换
   */
  public static COUNT_DOWN_ONE_MIN: number = 60;
  /**
   * 倒计时时间单位阈值，以一小时为界，在分钟和小时之间切换
   */
  public static COUNT_DOWN_ONE_HOUR: number = 60 * 60;
  /**
   * 10分钟有效期，以毫秒为单位
   */
  public static TEN_MIN_IN_MILE_SECOND: number = 60 * 10 * 1000;
  /**
   * 毫秒换算为秒的单位换算比例
   */
  public static MILE_SECOND_TO_SECOND: number = 1000;
  /**
   * 空格站位字符
   */
  public static SPACE_PLACE_HOLDER_STRING: ResourceStr = ' ';
  /**
   * ArkUI 输入框获焦延时
   */
  public static INPUT_FOCUS_DELAY: number = 300;
  /**
   * ArkUI 输入框获焦后文本选中延时
   */
  public static INPUT_FOCUS_TEXT_SELECT_DELAY: number = 400;
  /**
   * 窗口导航栏
   */
  public static NAVIGATION_INDICATOR_HEIGHT_KEY: string = 'NAVIGATION_INDICATOR_HEIGHT';
  /**
   * Maximum button width.
   */
  public static readonly MAX_BUTTON_WIDTH = 448;
}