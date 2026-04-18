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

import { i18n } from '@kit.LocalizationKit';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

/* instrument ignore file */
const TAG: string = 'MoreConnectionUtils';
const XIZANG_LANGUAGES: string[] = ['bo'];
const DEFAULT_BO_LINE_HEIGHT: number = 22; // body_m line height
const NOT_BO_DEFAULT_HEIGHT: number = 0;

export class MoreConnectionUtils {
  /**
   * adapter bo line height
   * @param lineHeight line height
   * @returns if 0 not bo language, use the text default line height, else is bo use the return line height
   */
  public static adapterBoLineHeight(lineHeight?: number): Length {
    try {
      let locale: string = new Intl.Locale(i18n.System.getSystemLanguage()).toString();
      return XIZANG_LANGUAGES.includes(locale) ? (lineHeight ? lineHeight : DEFAULT_BO_LINE_HEIGHT) :
        NOT_BO_DEFAULT_HEIGHT;
    } catch (error) {
      LogUtil.error(`${TAG} getSystemLanguage error code: ${error?.code}, message: ${error?.message}`);
    }
    return NOT_BO_DEFAULT_HEIGHT;
  }
}