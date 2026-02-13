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
   * 文件分隔符
   */
  public static readonly FILE_SEPARATOR: string = '/';

  /**
   * 主题包后缀
   */
  public static readonly HWT_SUFFIX: string = '.hwt';

  /**
   * json文件后缀
   */
  public static readonly JSON_SUFFIX: string = '.json';

  /**
   * zip包后缀
   */
  public static readonly ZIP_SUFFIX: string = '.zip';

  // 资源目录名
  public static readonly DIR_THEME: string = 'default';
  public static readonly DIR_SKIN: string = 'skin';
  public static readonly DIR_ENTRY: string = 'entry';
  public static readonly DIR_BASE: string = 'base';
  public static readonly DIR_DARK: string = 'dark';
  public static readonly DIR_SYS_RES: string = 'systemRes';
  public static readonly DIR_ELEMENT: string = 'element';
  public static readonly DIR_A: string = 'a';
  public static readonly DIR_B: string = 'b';
  public static readonly DIR_APP: string = 'app';
  public static readonly DIR_THEMES: string = 'themes';
  public static readonly FLAG_FILE_NAME: string = 'flag';
  public static readonly SKIN_FILE_NAME: string = 'pattern';
  public static readonly STANDARD_SKIN_PATH: string = '/skin/systemRes/entry/base/element/';
  public static readonly DARK_SKIN_PATH: string = '/skin/systemRes/entry/dark/element/';
  public static readonly READ_SKIN_JSON_PATH: string = '/data/themes';

  // 预览图片数据
  public static readonly LAND_NAV_WIDTH: number = 960;
  public static readonly PORTRAIT_NAV_WIDTH: number = 640;
  public static readonly PAD_PORTRAIT_CARD_WIDTH: number = 434;
  public static readonly PAD_LANDSCAPE_CARD_WIDTH: number = 610;
  public static readonly PAD_PORTRAIT_CARD_HEIGHT: number = 650;
  public static readonly PAD_LANDSCAPE_CARD_HEIGHT: number = 406;
  public static readonly PAD_WIDTH_RATIO: number = 0.8;
  public static readonly PAD_LAND_WIDTH_RATIO: number = 0.7;
  public static readonly SMALL_CARD_RATIO: number = 0.0253;
  public static readonly SMALL_CARD_BOTTOM_RATIO: number = 0.0179;
  public static readonly SMALL_CARD_LEFT_RATIO: number = 0.1137;
  public static readonly BIG_CARD_RATIO: number = 0.048387;
  public static readonly BIG_CARD_BOTTOM_RATIO: number = 0.05845;
  public static readonly BIG_CARD_LEFT_RATIO: number = 0.4746;
  public static readonly SWITCH_HEIGHT_RATIO: number = 0.0207;
  public static readonly SWITCH_WIDTH_RATIO: number = 1.8;
  public static readonly SWITCH_BOTTOM_RATIO: number = 0.5;
  public static readonly SWITCH_LEFT_RATIO: number = 0.437;
  public static readonly SWITCH_RIGHT_RATIO: number = 0.7665;
  public static readonly LAND_SMALL_CARD_RATIO: number = 0.0164;
  public static readonly LAND_SMALL_CARD_BOTTOM_RATIO: number = 0.6594;
  public static readonly LAND_SMALL_CARD_LEFT_RATIO: number = 0.0253;
  public static readonly LAND_BIG_CARD_RATIO: number = 0.032787;
  public static readonly LAND_BIG_CARD_BOTTOM_RATIO: number = 0.029557;
  public static readonly LAND_BIG_CARD_LEFT_RATIO: number = 0.4836;
  public static readonly LAND_SWITCH_HEIGHT_RATIO: number = 0.01475;
  public static readonly LAND_SWITCH_WIDTH_RATIO: number = 1.8;
  public static readonly LAND_SWITCH_BOTTOM_RATIO: number = 0.3734;
  public static readonly LAND_SWITCH_LEFT_RATIO: number = 0.4588;
  public static readonly LAND_SWITCH_RIGHT_RATIO: number = 0.7893;

  // 风格切换参数
  public static readonly CORNER_RADIUS: number = 8;
  public static readonly CHECK_BOX_SIZE: number = 24;
  public static readonly BORDER_WIDTH: number = 2;
}