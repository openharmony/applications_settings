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
import SearchHistoryManager from '@ohos/settings.common/src/main/ets/data/SearchHistoryManager';
import { SearchHistory } from '@ohos/settings.common/src/main/ets/data/searchHistoryTypes';

const TAG: string = 'SearchHistoryController';

export class SearchHistoryController {
  /**
   * 初始化搜索数据到数据库
   */
  static async initSearchData(): Promise<void> {
    LogUtil.info(`${TAG} start init SearchHistoryData to DataBase`);
    await SearchHistoryManager.batchInsertSearchHistoryData();
  }

  /**
   * 添加搜索数据到数据库
   */
  static async addSearchData(searchHistoryData: SearchHistory): Promise<void> {
    LogUtil.info(`${TAG} start insert SearchHistoryData to DataBase`);
    await SearchHistoryManager.insertSearchHistoryData(searchHistoryData);
  }

  /**
   * 查询搜索历史数据
   */
  static async getSearchData(): Promise<SearchHistory[]> {
    LogUtil.info(`${TAG} start query SearchHistoryData`);
    return await SearchHistoryManager.querySearchHistoryData();
  }

  /**
   * 清空搜索历史数据
   */
  static async deleteSearchData(): Promise<void> {
    LogUtil.info(`${TAG} start delete SearchHistoryData`);
    await SearchHistoryManager.clearSearchHistoryData();
  }
}