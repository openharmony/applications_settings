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

import { LengthMetrics } from '@ohos.arkui.node';
import { common } from '@kit.AbilityKit';

type FontScaleContext = Context | common.UIAbilityContext | common.ServiceExtensionContext | null;

export class FontScaleUtils {
  public static readonly DEFAULT_FONT_SCALE = 1;
  public static readonly EXTRA_LARGE_FONT = 1.45;
  public static readonly EXTRA_LARGE_FONT_1 = 1.75;
  public static readonly EXTRA_LARGE_FONT_2 = 2;
  public static readonly EXTRA_LARGE_FONT_3 = 3.2;
  private static CONTENTS_PADDING: number = 0;
  private static FONT_SCALE_SIZE: number = 1;
  private static SAFETY_PADDING: number = 8;
  private static BUTTON_PADDING: number = 4;
  private static TAB_BAR_HEIGHT: number = 56;
  private static EXTRA_LARGE_FONT_MODE: boolean = false;

  private constructor() {
  }

  /**
   * 设置字体大小
   *
   * @param fontScaleSize 字体大小
   */
  public static setFontScaleSize(fontScaleSize: number): void {
    FontScaleUtils.FONT_SCALE_SIZE = fontScaleSize;
  }

  public static getContext(context: FontScaleContext): common.UIAbilityContext | null {
    return context as common.UIAbilityContext | null;
  }

  public static getCurrentScale(context: FontScaleContext): number {
    let fontScale = FontScaleUtils.getContext(context)?.config?.fontSizeScale;
    if (fontScale === undefined) {
      return FontScaleUtils.DEFAULT_FONT_SCALE;
    }
    return fontScale;
  }

  /**
   * 获取当前字体大小
   *
   * @returns 字体大小
   */
  public static getFontScaleSize(): number {
    return FontScaleUtils.FONT_SCALE_SIZE;
  }

  public static setConfig(fontScaleSize: number): void {
    FontScaleUtils.setFontScaleSize(fontScaleSize);
    FontScaleUtils.setCurrentTopPadding();
    FontScaleUtils.setCurrentPadding();
    FontScaleUtils.setButtonTopPadding();
    FontScaleUtils.setTabBarHeight();
    FontScaleUtils.setExtraLargeFontMode();
  }

  /**
   * 设置菜单之间间距
   *
   */
  public static setCurrentTopPadding(): void {
    if (FontScaleUtils.FONT_SCALE_SIZE === FontScaleUtils.EXTRA_LARGE_FONT_1) {
      FontScaleUtils.SAFETY_PADDING = 16;
    } else if (FontScaleUtils.FONT_SCALE_SIZE === FontScaleUtils.EXTRA_LARGE_FONT_2) {
      FontScaleUtils.SAFETY_PADDING = 20;
    } else if (FontScaleUtils.FONT_SCALE_SIZE === FontScaleUtils.EXTRA_LARGE_FONT_3) {
      FontScaleUtils.SAFETY_PADDING = 24;
    } else {
      FontScaleUtils.SAFETY_PADDING = 8;
    }
  }

  /**
   * 字体16 行高56 的场景下设置间距
   *
   */
  public static setCurrentPadding(): void {
    if (FontScaleUtils.FONT_SCALE_SIZE === FontScaleUtils.EXTRA_LARGE_FONT_1) {
      FontScaleUtils.CONTENTS_PADDING = 6;
    } else if (FontScaleUtils.FONT_SCALE_SIZE === FontScaleUtils.EXTRA_LARGE_FONT_2) {
      FontScaleUtils.CONTENTS_PADDING = 12;
    } else if (FontScaleUtils.FONT_SCALE_SIZE === FontScaleUtils.EXTRA_LARGE_FONT_3) {
      FontScaleUtils.CONTENTS_PADDING = 24;
    } else {
      FontScaleUtils.CONTENTS_PADDING = 0;
    }
  }

  /**
   * 获取字体16 行高56场景下 设置菜单之间间距
   *
   * @returns padding
   */
  public static getCurrentPadding(): number {
    return FontScaleUtils.CONTENTS_PADDING;
  }

  /**
   * 获取设置菜单之间间距
   *
   * @returns top and bottom padding
   */
  public static getCurrentTopPadding(): number {
    return FontScaleUtils.SAFETY_PADDING;
  }

  /**
   * 获取字体16 行高56场景下 设置菜单之间间距，LengthMetrics类型
   *
   * @returns localized padding
   */
  public static getCurrentContentPadding(): LengthMetrics {
    return LengthMetrics.vp(FontScaleUtils.CONTENTS_PADDING);
  }

  /**
   * 获取设置菜单之间上下间距
   *
   * @returns top and bottom padding
   */
  public static getSafetyPadding(): LengthMetrics {
    return LengthMetrics.vp(FontScaleUtils.SAFETY_PADDING);
  }

  /**
   * 设置button之间间距
   *
   * @param context current ui context
   * @returns top and bottom padding
   */
  public static setButtonTopPadding(): void {
    if (FontScaleUtils.FONT_SCALE_SIZE === FontScaleUtils.EXTRA_LARGE_FONT_2 ||
      FontScaleUtils.FONT_SCALE_SIZE === FontScaleUtils.EXTRA_LARGE_FONT_3) {
      FontScaleUtils.BUTTON_PADDING = 8;
    } else {
      FontScaleUtils.BUTTON_PADDING = 4;
    }
  }

  /**
   * 获取button之间间距
   *
   * @returns top and bottom padding
   */
  public static getButtonTopPadding(): number {
    return FontScaleUtils.BUTTON_PADDING;
  }

  /**
   * 大字体下设置tabbar的高度
   *
   * @param context current ui context
   * @returns tabbar height
   */
  public static setTabBarHeight(): void {
    if (FontScaleUtils.FONT_SCALE_SIZE === FontScaleUtils.EXTRA_LARGE_FONT_2) {
      FontScaleUtils.TAB_BAR_HEIGHT = 62;
    } else if (FontScaleUtils.FONT_SCALE_SIZE === FontScaleUtils.EXTRA_LARGE_FONT_3) {
      FontScaleUtils.TAB_BAR_HEIGHT = 80;
    } else {
      FontScaleUtils.TAB_BAR_HEIGHT = 56;
    }
  }

  /**
   * 大字体下获取tabbar的高度
   *
   * @param context current ui context
   * @returns tabbar height
   */
  public static getTabBarHeight(): number {
    return FontScaleUtils.TAB_BAR_HEIGHT;
  }

  /**
   * 字体是否特大或超过特大
   *
   * @returns 字体大于等于特大返回true
   */
  public static isLargeFontMode(): boolean {
    return FontScaleUtils.FONT_SCALE_SIZE >= FontScaleUtils.EXTRA_LARGE_FONT;
  }

  /**
    * Current device wether old mode.
    *
    * @param context current ui context
    * @returns current font scale
    */
  public static isExtraLargeFontMode(): boolean {
    return FontScaleUtils.EXTRA_LARGE_FONT_MODE;
  }

  public static setExtraLargeFontMode(): void {
    FontScaleUtils.EXTRA_LARGE_FONT_MODE = FontScaleUtils.FONT_SCALE_SIZE >= FontScaleUtils.EXTRA_LARGE_FONT_1;
  }
}