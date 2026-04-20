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

/* instrument ignore file */
import common from '@ohos.app.ability.common';
import measure from '@ohos.measure';
import Log from './Log';

const DEFAULT_FONT_SCALE = 1;
const EXTRA_LARGE_FONT_1 = 1.75;
const TAG: string = 'FontScaleUtils: ';

export const LARGE_LIMIT_HEIGHT = 200;

enum FontScale {
  DEFAULT_FONT_SCALE = 1,
  NEED_CHANGE_FONT_SCALE = 1.45,
  FONT_SCALE_ONE = 1.75,
  FONT_SCALE_TWO = 2,
  FONT_SCALE_THREE = 3.2
}

enum SaveDistance {
  SAVE_DISTANCE = 8,
  EXTRA_LARGE_SAVE_DISTANCE_ONE = 16,
  EXTRA_LARGE_SAVE_DISTANCE_TWO = 20,
  EXTRA_LARGE_SAVE_DISTANCE_THREE = 24,
}

/**
 * Font scale utils.
 */
export default class FontScaleUtils {
  private constructor() {
  }

  /**
   * Get device current font scale.
   *
   * @param context current ui context
   * @returns current font scale
   */
  public static getCurrentScale(context: common.UIAbilityContext): number {
    let fontScale = context?.config?.fontSizeScale;
    if (fontScale === undefined) {
      Log.error(TAG, '[getCurrentScale]fontScale is undefined');
      return DEFAULT_FONT_SCALE;
    }
    Log.info(TAG, 'fontScale: ' + fontScale);
    return fontScale;
  }

  /**
   * Current device whether old mode.
   *
   * @param context current ui context
   * @returns current whether old mode
   */
  public static isExtraLargeFontMode(context: common.UIAbilityContext): boolean {
    let fontScale = context?.config?.fontSizeScale;
    if (fontScale === undefined) {
      Log.error(TAG, '[isOldMode]fontScale is undefined');
      return false;
    }
    let isOldMode = fontScale >= EXTRA_LARGE_FONT_1;
    Log.info(TAG, 'isOldMode: ' + isOldMode);
    return isOldMode;
  }

  public static dialogButtonRowLayout(dialogWidth: number, primary: Resource, secondary: Resource): boolean {
    let primaryButtonTextWidth = measure.measureText({
      textContent: primary,
      fontSize: $r('sys.float.ohos_id_text_size_button1'),
      fontWeight: FontWeight.Regular,
      fontFamily: 'HarmonyHeiTi'
    });
    // measureText Unit: px
    let secondaryButtonTextWidth = measure.measureText({
      textContent: secondary,
      fontSize: $r('sys.float.ohos_id_text_size_button1'),
      fontWeight: FontWeight.Regular,
      fontFamily: 'HarmonyHeiTi'
    });
    let maxButtonWidth: number = Math.max(primaryButtonTextWidth, secondaryButtonTextWidth);
    let limit = (dialogWidth - (16 * 2) - 16 - (16 * 2 * 2)) * 0.5;
    return maxButtonWidth <= vp2px(limit);
  }

  public static buttonColumnLayout(buttonAreaWidth: number, resource1: Resource, resource2: Resource): boolean {
    let primaryButtonTextWidth = measure.measureText({
      textContent: resource1,
      fontSize: $r('sys.float.ohos_id_text_size_button1'),
      fontWeight: FontWeight.Medium,
      fontFamily: 'HarmonyHeiTi'
    });
    let secondaryButtonTextWidth = measure.measureText({
      textContent: resource2,
      fontSize: $r('sys.float.ohos_id_text_size_button1'),
      fontWeight: FontWeight.Medium,
      fontFamily: 'HarmonyHeiTi'
    });
    let maxButtonWidth: number = Math.max(primaryButtonTextWidth, secondaryButtonTextWidth);
    let limit = (buttonAreaWidth - 12 - (16 * 2 * 2)) * 0.5;
    return maxButtonWidth > vp2px(limit);
  }


  /**
   * Get save distance with current font scale.
   *
   * @param context Current ui context
   * @param max limit
   * @returns Current save distance
   */
  public static getSaveDistance(context: common.UIAbilityContext, scaleLimit?: FontScale): number {
    let scale = FontScaleUtils.getCurrentScale(context);
    let ret = SaveDistance.SAVE_DISTANCE;
    let maxScale = scaleLimit || FontScale.FONT_SCALE_THREE;
    const currentScale = Math.min(scale, maxScale);
    if (currentScale === FontScale.FONT_SCALE_ONE) {
      ret = SaveDistance.EXTRA_LARGE_SAVE_DISTANCE_ONE;
    } else if (currentScale === FontScale.FONT_SCALE_TWO) {
      ret = SaveDistance.EXTRA_LARGE_SAVE_DISTANCE_TWO;
    } else if (currentScale === FontScale.FONT_SCALE_THREE) {
      ret = SaveDistance.EXTRA_LARGE_SAVE_DISTANCE_THREE;
    } else {
      ret = SaveDistance.SAVE_DISTANCE;
    }
    return ret;
  }

  public static getRealPX(
    context: Context,
    resourceNumber: Resource,
    maxScale: number = EXTRA_LARGE_FONT_1,
  ): string | Resource {
    let realPx: number;
    const fontScale = FontScaleUtils.getCurrentScale(context as common.UIAbilityContext);
    if (fontScale && (fontScale >= maxScale)) {
      try {
        const sysVp = getContext().resourceManager.getNumber(resourceNumber);
        realPx = vp2px(sysVp);
      } catch (err) {
        Log.error(TAG, `getRealPX catch error, code is ${err?.code}，message is ${err?.message}`);
        return '0';
      }
      realPx = realPx * 2;
      return `${realPx}px`;
    }
    return resourceNumber;
  }
}
