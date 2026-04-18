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

import { LogUtil } from '../utils/LogUtil';
import { PreferencesUtil } from '../utils/PreferencesUtil';

/**
 * Database工具类
 *
 * @since 2025-07-28
 */
export class DatabaseUtil {
  /**
   * 更新数据库version
   *
   * @param table 需要更新状态的表
   * @param version 版本号
   */
  public static updateRdbStoreVersion(table: string, version: number): void {
    LogUtil.info(`updateRdbStoreVersion table:${table} version:${version}`);
    PreferencesUtil.putSync(table, version);
  }

  /**
   * 获取数据库version
   *
   * @param table 需要更新状态的表
   */
  public static getRdbStoreVersion(table: string): number {
    let version: number = PreferencesUtil.getSync(table, 0) as number;
    LogUtil.info(`getRdbStoreVersion table:${table} version:${version}`);
    return version;
  }
}