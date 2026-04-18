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

export class QuickConstants {
  /**
   * 隔空滑动屏幕，默认值传'0'
   */
  public static readonly AIR_OFF: string = '0';

  public static readonly AIR_ON: string = '1';

  /**
   * 隔空滑动屏幕&隔空截屏&隔空分享，是否展示的判断条件
   */
  public static readonly SCREEN_ARR_NUM: number = 6;

  public static readonly SHARE_ARR_NUM: number = 8;
  /*
   *
   * 隔空滑动屏幕：只要下面解析的属性有一个是1，就显示入口
   u:上滑up，1为支持，0为不支持
   d:下滑down，1为支持，0为不支持
   l:左滑left，1为支持，0为不支持
   r:右滑right，1为支持，0为不支持
   *
   * */
  // 上滑up，1为支持，0为不支持
  public static readonly UP_SUPPORT: string = '1';

  // 下滑down，1为支持，0为不支持
  public static readonly DOWN_SUPPORT: string = '1';

  // 左滑left，1为支持，0为不支持
  public static readonly LEFT_SUPPORT: string = '1';

  // 右滑right，1为支持，0为不支持
  public static readonly RIGHT_SUPPORT: string = '1';

  public static readonly SWING_GESTURE_ABILITY: string = 'v:2.0;u:0;d:0;l:0;r:0;p:0;f:0;h:0;s:0';

  public static readonly SWING_GESTURE_ABILITY_UP_INDEX: number = 1;
  public static readonly SWING_GESTURE_ABILITY_DOWN_INDEX: number = 2;
  public static readonly SWING_GESTURE_ABILITY_LEFT_INDEX: number = 3;
  public static readonly SWING_GESTURE_ABILITY_RIGHT_INDEX: number = 4;
  public static readonly SWING_GESTURE_ABILITY_FETCH_INDEX: number = 6;
  public static readonly SWING_GESTURE_ABILITY_SHARE_INDEX: number = 8;

  public static readonly QUICK_ACCESS_FUNCTION_SMART_KEY: string = '0';
  public static readonly QUICK_ACCESS_FUNCTION_X_KEY: string = '1';
  public static readonly QUICK_ACCESS_FUNCTION_NOT_SUPPORT: string = '-1';
  public static readonly QUICK_ACCESS_FUNCTION_TYPE: string = 'const.quickaccess.function_type';
  public static readonly QUICK_ACCESS_MENU_BUNDLE_NAME: string = 'com.ohos.hwquickaccessmenu';
  public static readonly QUICK_ACCESS_IS_SUPPORT_CAMERA_SMART: string = 'const.quickaccess.is_support_camera_smart';
  public static readonly QUICK_ACCESS_IS_SUPPORT_SLIDE: string = 'const.quickaccess.is_support_slide';
  public static readonly QUICK_ACCESS_IS_SUPPORT_FLAG: string = '1';
}