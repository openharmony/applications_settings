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
 * 数组工具类
 */
export class ArrayUtil {
  /**
   * 判断数组是否为空
   * @param array 数组
   */
  public static isEmpty<T>(array: Array<T> | undefined | null): boolean {
    return array === undefined || array === null || array.length === 0;
  }

  /**
   * 判断数组是否为不为空
   * @param array 数组
   */
  public static isNotEmpty<T>(array: Array<T> | undefined | null): boolean {
    return array !== null && array !== undefined && array.length !== 0;
  }

  /**
   * 判断map是否为空
   * @param map map
   */
  public static isMapEmpty<K, V>(map: Map<K, V> | undefined | null): boolean {
    return map === null || map === undefined || map.size === 0;
  }
}