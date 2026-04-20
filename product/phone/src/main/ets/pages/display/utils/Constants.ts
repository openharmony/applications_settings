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

export class Constants {
  /**
   * 分辨率类型： 智能分辨率
   */
  public static readonly SMART_RESOLUTION_TYPE: string = '0';

  /**
   * 分辨率类型： 屏幕分辨率，高、低
   */
  public static readonly SCREEN_RESOLUTION_TYPE_TWO: string = '2';

  /**
   * 分辨率类型： 屏幕分辨率，高、标准、低
   */
  public static readonly SCREEN_RESOLUTION_TYPE_THREE: string = '3';

  /**
   * 智能分辨率 开
   */
  public static readonly SMART_RESOLUTION_OPEN: string = '0';

  /**
   * 智能分辨率 关
   */
  public static readonly SMART_RESOLUTION_CLOSE: string = '1';

  /**
   * 注视屏幕不熄屏 展示这一栏 1
   */
  public static readonly SHOW_GAZE: string = '1';

  /**
   * 注视屏幕不熄屏 开关打开 1
   */
  public static readonly GAZE_ON: string = '1';

  /**
   * 注视屏幕不熄屏 开关关闭 0 默认值
   */
  public static readonly GAZE_OFF: string = '0';

  /**
   * 低分辨率 menu_key
   */
  public static readonly SCREEN_RESOLUTION_LOW_KEY = 'screenResolution_low';

  /**
   * 标准分辨率 menu_key
   */
  public static readonly SCREEN_RESOLUTION_MIDDLE_KEY = 'screenResolution_middle';

  /**
   * 高分辨率 menu_key
   */
  public static readonly SCREEN_RESOLUTION_HIGH_KEY = 'screenResolution_high';

  /**
   * 低分辨率模式
   */
  public static readonly SCREEN_RESOLUTION_LOW = '1';

  /**
   * 标准分辨率模式
   */
  public static readonly SCREEN_RESOLUTION_MIDDLE = '2';

  /**
   * 高分辨率模式
   */
  public static readonly SCREEN_RESOLUTION_HIGH = '3';

  /**
   * 高分辨率 value
   */
  public static readonly SETTING_RESOLUTION_HIGH: string = 'settings.display.resolution_high';
  /**
   * 标准分辨率 value
   */
  public static readonly SETTING_RESOLUTION_STANDARD: string = 'settings.display.resolution_middle';
  /**
   * 低分辨率 value
   */
  public static readonly SETTING_RESOLUTION_LOW: string = 'settings.display.resolution_low';

  /**
   * 分辨率分隔符
   */
  public static readonly RESOLUTION_SPLIT: string = 'x';

}