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

import systemParameterEnhance from '@ohos.systemParameterEnhance';
import uiAppearance from '@ohos.uiAppearance';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG = 'ThemeSettingsUtil';

/**
 * 主题设置工具类
 */
export class ThemeSettingsUtil {
  private static isHdd: boolean | undefined = undefined;

  /**
   * 判断当前是否是深色模式。
   * true：是深色模式；false：不是深色模式。
   * @returns isDarkMode
   */
  static isDarkMode(): boolean {
    let isDarkMode: boolean = false;
    try {
      isDarkMode = uiAppearance.getDarkMode() === uiAppearance.DarkMode.ALWAYS_DARK;
    } catch (e) {
      LogUtil.error(`${TAG} uiAppearance.getDarkMode Error, error code = ${e?.code}, error message = ${e?.message}`);
    }
    return isDarkMode;
  }

  /**
   * 判断当前产品是否为2D产品,需要关闭并隐藏某些特性,比如桌面和个性化页面、设置里的主题入口
   * true：是2D产品；false：不是2D产品。
   * @returns isHdd
   */
  static isHddProduct(): boolean {
    if (ThemeSettingsUtil.isHdd) {
      return ThemeSettingsUtil.isHdd;
    }
    try {
      ThemeSettingsUtil.isHdd =
        systemParameterEnhance.getSync('const.scene_board.off_personalization_feature', 'false') === 'true';
      LogUtil.info(`${TAG} is Hdd Product = ${ThemeSettingsUtil.isHdd}`);
    } catch (e) {
      ThemeSettingsUtil.isHdd = false;
      LogUtil.error(`${TAG} Get Hdd Product Param Error, error code = ${e?.code}, error message = ${e?.message}`);
    }
    return ThemeSettingsUtil.isHdd;
  }
}