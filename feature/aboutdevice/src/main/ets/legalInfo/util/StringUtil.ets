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
 * 字符串工具类
 */
export class StringUtil {
  public tag: string = 'StringUtil: '
  /**
   * 判断字串是否是空字串
   * @param stringValue 字符串
   */
  public static isEmpty(stringValue: string | null | undefined): boolean {
    return stringValue === undefined || stringValue === null || stringValue.length === 0;
  }

  /**
   * 判断字串是否是非空字串
   * @param stringValue 字符串
   */
  public static isNotEmpty(stringValue: string | null | undefined): boolean {
    return stringValue !== undefined && stringValue !== null && stringValue.length !== 0;
  }
}