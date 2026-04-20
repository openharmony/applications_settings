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

import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { DisplayConstant } from '@ohos/settings.common/src/main/ets/constant/DisplayConstant';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

// 藏文
const BO_LANGUAGE_ID: string = 'bo';
const ONE_HUNDRED: number = 100;
const TAG: string = 'IntelligentSceneFontScaleUtil:';

export class IntelligentSceneFontScaleUtil {
  /**
   * 获取情景模式toolbar最大字体缩放级别
   *
   * @param context 上下文
   * @returns 字体最大缩放级别
   */
  public static getToolbarMaxFontSize(context: Context, selectCount: number): number {
    if (LanguageUtils.getLanguage() === BO_LANGUAGE_ID &&
      FontScaleUtils.getCurrentScale(context) >= FontScaleUtils.EXTRA_LARGE_FONT_3) {
      return selectCount >= ONE_HUNDRED ? DisplayConstant.TEXT_FONT_SIZE_LARGE : DisplayConstant
        .TEXT_FONT_SIZE_EXTRA_LARGE;
    }
    return FontScaleUtils.EXTRA_LARGE_FONT_1;
  }

  /**
   * 判断是否特大3挡字体
   *
   * @param context 上下文
   * @returns true 是特大3挡字体
   */
  public static isHUGE4Mode(context: Context): boolean {
    if (!context) {
      LogUtil.warn(`${TAG} context is empty.`);
      return false;
    }
    return FontScaleUtils.getCurrentScale(context) >= DisplayConstant.TEXT_FONT_SIZE_HUGE4;
  }
}