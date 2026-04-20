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
 * 显示相关常量
 */
export class DisplayConstant {
  /**
   * 字体大小级别 小
   */
  public static readonly TEXT_FONT_SIZE_SMALL: number = 0.85;

  /**
   * 字体大小级别 标准
   */
  public static readonly TEXT_FONT_SIZE_NORMAL: number = 1;

  /**
   * 字体大小级别 大
   */
  public static readonly TEXT_FONT_SIZE_LARGE: number = 1.15;

  /**
   * 字体大小级别 超大
   */
  public static readonly TEXT_FONT_SIZE_EXTRA_LARGE: number = 1.3;

  /**
   * 字体大小级别 特大
   */
  public static readonly TEXT_FONT_SIZE_HUGE: number = 1.45;

  /**
   * 字体大小级别 特大一档
   */
  public static readonly TEXT_FONT_SIZE_HUGE2: number = 1.75;

  /**
   * 字体大小级别 特大二档
   */
  public static readonly TEXT_FONT_SIZE_HUGE3: number = 2;

  /**
   * 字体大小级别 特大三档
   */
  public static readonly TEXT_FONT_SIZE_HUGE4: number = 3.2;

  /**
   * 字体粗细级别 最细
   */
  public static readonly TEXT_FONT_WEIGHT_LIGHTEST: number = 0.75;

  /**
   * 字体粗细级别 标准
   */
  public static readonly TEXT_FONT_WEIGHT_NORMAL: number = 1;

  public static readonly TEXT_FONT_WEIGHT_NORMAL_LEFT: number = 0.96;

  public static readonly TEXT_FONT_WEIGHT_NORMAL_RIGHT: number = 1.04;

  /**
   * 字体粗细级别 最粗
   */
  public static readonly TEXT_FONT_WEIGHT_BOLDEST: number = 1.5;

  /**
   * 字体调节默认字串
   */
  public static readonly TEXT_A: string = 'A';

  /**
   * 字体缩放调节数
   */
  public static readonly FONT_SIZE_STEP_NUM: number = 1;

  /**
   * 字体粗细调节数
   */
  public static readonly FONT_WEIGHT_STEP_NUM: number = 0.01;

  /**
   * 默认字体大小当前位置
   */
  public static readonly DEFAULT_FONT_SIZE_STEP: number = 2;

  /**
   * 默认字体粗细当前位置
   */
  public static readonly DEFAULT_FONT_WEIGHT_STEP: number = 1;

  /**
   * 默认字体粗细
   */
  public static readonly DEFAULT_FONT_WEIGHT: number = 1;

  /**
   * 字体最大缩放级别
   */
  public static readonly MAX_FONT_SIZE_LEVEL: number = 5;

  /**
   * 手机字体最大缩放级别
   */
  public static readonly MAX_FONT_SIZE_LEVEL_PHONE: number = 5;

  /**
   * 关爱模式下字体最大缩放级别
   */
  public static readonly CARING_MODEL_MAX_FONT_SIZE_LEVEL: number = 8;

  /**
   * 字体最小缩放
   */
  public static readonly MIN_FONT_SIZE: number = 1;

  /**
   * 字体粗细缩放
   */
  public static readonly PERSIST_SYS_FONT_WEIGHT_SCALE: string = 'persist.sys.font_wght_scale_for_user0';

  /**
   * 字体大小缩放
   */
  public static readonly PERSIST_SYS_FONT_SIZE_SCALE: string = 'persist.sys.font_scale_for_user0';

  /**
   * pad 图片缩放系数
   */
  public static readonly PAD_DISPLAY_IMAGE_SCALE_RATIO: number = 0.75;

  /**
   * normal fontWeight 数值
   */
  public static readonly NORMAL_FONT_WEIGHT_SIZE: number = 500;

  /**
   * 字体 小 Step值
   */
  public static readonly TEXT_FONT_SIZE_SMALL_STEP: number = 1;

  /**
   * 字体 标准 Step值
   */
  public static readonly TEXT_FONT_SIZE_NORMAL_STEP: number = 2;

  /**
   * 字体 大 Step值
   */
  public static readonly TEXT_FONT_SIZE_LARGE_STEP: number = 3;

  /**
   * 字体 超大 Step值
   */
  public static readonly TEXT_FONT_SIZE_EXTRA_LARGE_STEP: number = 4;

  /**
   * 字体 特大 Step值
   */
  public static readonly TEXT_FONT_SIZE_HUGE_STEP: number = 5;

  /**
   * 字体 特大一档 Step值
   */
  public static readonly TEXT_FONT_SIZE_HUGE2_STEP: number = 6;

  /**
   * 字体 特大二档 Step值
   */
  public static readonly TEXT_FONT_SIZE_HUGE3_STEP: number = 7;

  /**
   * 字体 特大三档 Step值
   */
  public static readonly TEXT_FONT_SIZE_HUGE4_STEP: number = 8;

  /**
   * 默认字体大小缩放倍数
   */
  public static readonly DEFAULT_FONT_SIZE_SCALE: string = '1';

  /**
   * 默认字体粗细缩放倍数
   */
  public static readonly DEFAULT_FONT_WEIGHT_SCALE: string = '1';

  /**
   * 字体粗细缩放 settingData key值
   */
  public static readonly SETTINGS_DATA_FONT_WEIGHT_SCALE: string = 'font_weight_scale';

  /**
   * 显示大小 settingData key值
   */
  public static readonly SETTINGS_DATA_USER_SET_DPI_VALUE: string = 'user_set_dpi_value';

  /**
   * 字体大小fp
   */
  public static readonly DEFAULT_FONT_SIZE: number = 16;

  /**
   * DPI密度基数
   */
  public static readonly DEFAULT_DPI_DENSITY : number = 160;

  /**
   * Regular字重
   */
  public static readonly FONT_WEIGHT_REGULAR : number = 400;

  /**
   * Medium字重
   */
  public static readonly FONT_WEIGHT_MEDIUM : number = 500;

  /**
   * updateConfig接口参数未更改错误码
   */
  public static readonly UPDATE_CONFIG_SAME_PARAMS_CODE : number = 16000050;

	/**
	 * 设置界面内容区左侧padding值
	 */
	public static readonly SETTINGS_PAGE_LEFT_PADDING : number = 85;

	/**
	 * 设置界面内容区右侧padding值
	 */
	public static readonly SETTINGS_PAGE_RIGHT_PADDING : number = 85;

  /**
   * 高对比度打开
   */
  public static readonly HIGH_CONTRAST_ON: string = '1';

  /**
   * 高对比度key
   */
  public static readonly HIGH_TEXT_CONTRAST_ENABLED: string = 'high_text_contrast_enabled';

  /**
   * 高对比度默认值
   */
  public static readonly HIGH_TEXT_CONTRAST_DEFAULT_VALUE : string = '0';

  /**
   * 方向控制字符,从左到右
   */
  public static readonly TEXT_DIRECTION_CTRL_LRE: string = '\u202A';

  /**
   * 方向控制字符结束标记
   */
  public static readonly TEXT_DIRECTION_CTRL_PDF: string = '\u202C';

  /**
   * 在设置在修改显示大小事件
   */
  public static readonly DISPLAY_CHANGE_EVENT: string = 'DISPLAY_CHANGE_EVENT';
}