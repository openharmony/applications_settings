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

import { DeviceUtil } from './BaseUtils';

export class SafeMarginUtils {
  // 内容安全边距，平板和PC安全边距是24，手机和折叠屏是16
  public static readonly SMALL_SAFE_MARGIN: Resource = $r('sys.float.padding_level8');
  public static readonly BIG_SAFE_MARGIN: Resource = $r('sys.float.padding_level12');
  //图标文字间距
  public static readonly IMAGE_TEXT_MARGIN: Resource = $r('sys.float.padding_level8');
  public static readonly IMAGE_TEXT_MARGIN_PC: Resource = $r('sys.float.padding_level4');
  public static readonly SUB_TITLE_MARGIN: number = -16;
  public static readonly SUB_TITLE_MARGIN_PC: number = -36;

  /**
   * 获取设备显示内容安全边距，平板和PC安全边距是24，手机和折叠屏是16
   *
   * @returns Resource Margin边距大小
   */
  public static getSafeMargin(): Resource {
    if (DeviceUtil.isDevicePc()) {
      return SafeMarginUtils.BIG_SAFE_MARGIN;
    }
    if (DeviceUtil.isDevicePad()) {
      return SafeMarginUtils.BIG_SAFE_MARGIN;
    }
    if (DeviceUtil.isDevicePhone()) {
      return SafeMarginUtils.SMALL_SAFE_MARGIN;
    }
    return SafeMarginUtils.SMALL_SAFE_MARGIN;
  }

  /**
   * 获取图像与文本之间的边距
   *
   * @returns Resource 边距大小
   */
  public static getImageTextMargin(): Resource {
    if (DeviceUtil.isDevicePc()) {
      return SafeMarginUtils.IMAGE_TEXT_MARGIN_PC;
    } else {
      return SafeMarginUtils.IMAGE_TEXT_MARGIN;
    }
  }

  /**
   * 子标题边距
   *
   * @returns number 边距大小
   */
  public static getSubHeaderMargin(): number {
    if (DeviceUtil.isDevicePc()) {
      return SafeMarginUtils.SUB_TITLE_MARGIN_PC;
    } else {
      return SafeMarginUtils.SUB_TITLE_MARGIN;
    }
  }
}