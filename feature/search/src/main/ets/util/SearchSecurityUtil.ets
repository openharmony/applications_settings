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
 * 搜索输入安全工具类，用于防止 SQL 注入等安全问题
 * RdbPredicates 使用参数化查询，本工具作为纵深防御补充
 */
export class SearchSecurityUtil {
  /**
   * 搜索关键词最大长度
   */
  private static readonly MAX_SEARCH_LENGTH: number = 200;

  /**
   * 对搜索关键词进行安全过滤，防止 SQL 注入
   * 过滤危险字符并限制长度，确保输入安全
   *
   * @param searchKey 原始搜索关键词
   * @returns 过滤后的安全搜索关键词，如果输入无效则返回空字符串
   */
  static sanitizeSearchInput(searchKey: string): string {
    if (searchKey === undefined || searchKey === null || typeof searchKey !== 'string') {
      return '';
    }

    let sanitized = searchKey.trim();
    if (sanitized.length === 0) {
      return '';
    }

    // 限制长度，防止 DoS
    if (sanitized.length > SearchSecurityUtil.MAX_SEARCH_LENGTH) {
      sanitized = sanitized.substring(0, SearchSecurityUtil.MAX_SEARCH_LENGTH);
    }

    // 移除 SQL LIKE 通配符，防止 LIKE 注入导致过度匹配
    sanitized = sanitized.replace(/[%_\\]/g, '');

    // 移除可能导致 SQL 注入的特殊字符（分号等）
    sanitized = sanitized.replace(/[;]/g, '');

    // 移除中英文标点及常用分隔符，避免误输入导致搜不到（如输入"，蓝牙"仍可搜到"蓝牙"）
    sanitized = sanitized.replace(/[\s，。、；：？！…—～·""''「」『』（）【】《》〈〉,.;:?!'"\-\]\[{}]/g, '');

    return sanitized.trim();
  }
}
