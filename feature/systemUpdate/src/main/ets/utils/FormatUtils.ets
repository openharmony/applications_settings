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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

const TAG = 'FormatUtils';

/**
 * 格式化工具
 *
 * @since 2024-09-19
 */
export class FormatUtils {
  /**
   * json字符串解析
   *
   * @param content json字符串
   * @return T 解析后返回值
   */
  static parseJson<T>(content: string): T | undefined {
    if (!content) {
      return undefined;
    }
    try {
      return JSON.parse(content) as T;
    } catch (error) {
      LogUtil.showError(TAG, `parseJson failed. code: ${error?.code}, message: ${error?.message}`);
    }
    return undefined;
  }

  /**
   * 对象序列化成json字符串
   *
   * @param value JS对象
   * @return json字符串
   */
  static stringify<T>(value: T): string {
    if (!value) {
      return '';
    }
    try {
      return JSON.stringify(value);
    } catch (error) {
      LogUtil.showError(TAG, `stringify failed. code: ${error?.code}, message: ${error?.message}`);
    }
    return '';
  }

  /**
   * 按顺序格式化字符串
   *
   * @param 待格式化的字符串
   * @param args 待匹配的内容
   * @return 格式化后的字符串
   */
  static formatStrInOrder(message: string, ...args: string[]): string {
    if (!message) {
      return '';
    }
    let formattedStr: string = message;
    for (let i = 0; i < args.length; i++) {
      formattedStr = formattedStr.replace(new RegExp('%s|%d|%' + (i + 1) + '\\$s', 'gm'), args[i]);
    }
    return formattedStr;
  }
}
