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
import relationalStore from '@ohos.data.relationalStore';
import { LogUtil } from '../utils/LogUtil';
import DatabaseManager from './DatabaseManager';
import {
  SearchHistory,
  SEARCHHISTORY_TABLE,
  SQL_CREATE_SEARCHHISTORY_TABLE,
  SQL_DELETE_SEARCHHISTORY_TABLE,
} from './searchHistoryTypes';
import { HiSysEventUtil } from '../systemEvent/HiSysEventUtil';
import { CheckEmptyUtils } from '../utils/CheckEmptyUtils';
import { HiSysRdbEventGroup, HiSysSearchEventGroup } from '../systemEvent/BehaviorEventConsts';

const TAG: string = 'SearchHistoryManager';
const RDB_CORRUPTION_ERROR_CODE: number = 14800011;


export class SearchHistoryManager extends DatabaseManager {
  /**
   * 获取关系数据库存储对象
   * 如果已初始化过，则直接返回之前获取的对象
   * 如果没有初始化过，则使用接口获取对象，并执行数据库建表命令，如果表未创建，则会创建一张新的表
   *
   * @return 关系数据库存储对象
   */
  async getRdbStore(): Promise<relationalStore.RdbStore> {
    LogUtil.info(`${TAG} start CREATE_SEARCHHISTORY_TABLE`);
    const rdbStore = await super.getRdbStore(SQL_CREATE_SEARCHHISTORY_TABLE);
    return rdbStore;
  }

  async batchInsertSearchHistoryData(itemInfoList?: Array<SearchHistory>): Promise<void> {
    const rdbStore = await this.getRdbStore();
    if (itemInfoList) {
      try {
        LogUtil.info(`${TAG} start batchInsertSearchHistoryData`);
        let searchItemInfos: relationalStore.ValuesBucket[] = [];
        itemInfoList.forEach((itemInfo) => {
          searchItemInfos.push(this.getDbBucketList(itemInfo));
        })
        LogUtil.info(`${TAG} batchInsertSearchHistoryData beginTransaction searchHistory`);
        await rdbStore.batchInsert(SEARCHHISTORY_TABLE, searchItemInfos);
        LogUtil.info(`${TAG} batchInsertSearchHistoryData result`);
        HiSysEventUtil.searchReportEvent(TAG, 'InitSearchHistoryData success');
      } catch (error) {
        LogUtil.error(`${TAG} batchInsertSearchHistoryData message: ${error?.message}, code: ${error?.code}`);
        HiSysEventUtil.searchReportEvent(TAG, `batchInsertSearchHistoryData error: ${JSON.stringify(error)}`);
        if (error.code === RDB_CORRUPTION_ERROR_CODE) {
          HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
            HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
          await super.restoreRdb();
        }
      }
    }
  }

  async insertSearchHistoryData(searchHistoryData: SearchHistory): Promise<void> {
    const rdbStore = await this.getRdbStore();
    if (searchHistoryData) {
      try {
        const predicates = new relationalStore.RdbPredicates(SEARCHHISTORY_TABLE);
        predicates.equalTo('query', searchHistoryData.query);
        const resultSet = await rdbStore.query(predicates);
        if (resultSet.rowCount) {
          await rdbStore.update(this.getDbBucketList(searchHistoryData), predicates);
          resultSet.close();
          LogUtil.info(`${TAG} updateSearchHistoryData success`);
          HiSysEventUtil.searchReportEvent(TAG, 'updateSearchHistoryData success');
          return;
        }
        resultSet.close();
        LogUtil.info(`${TAG} start insertSearchHistoryData`);
        await rdbStore.insert(SEARCHHISTORY_TABLE, this.getDbBucketList(searchHistoryData));
        LogUtil.info(`${TAG} insertSearchHistoryData result`);
        HiSysEventUtil.searchReportEvent(TAG, 'InsertSearchHistoryData success');
      } catch (error) {
        LogUtil.error(`${TAG} insertSearchHistoryData message: ${error?.message}, code: ${error?.code}`);
        HiSysEventUtil.searchReportEvent(TAG, `InsertSearchHistoryData error: ${JSON.stringify(error)}`);
        if (error.code === RDB_CORRUPTION_ERROR_CODE) {
          HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
            HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
          await super.restoreRdb();
        }
      }
    }
  }

  async querySearchHistoryData(): Promise<SearchHistory[]> {
    const rdbStore = await this.getRdbStore();
    let searchHistoryList: SearchHistory[] = [];
    try {
      const predicates = new relationalStore.RdbPredicates(SEARCHHISTORY_TABLE);
      predicates.orderByDesc('timestamp').limitAs(10);
      const resultSet = await rdbStore.query(predicates);
      while (resultSet.goToNextRow()) {
        const query = resultSet.getString(resultSet.getColumnIndex('query'));
        if (CheckEmptyUtils.checkStrIsEmpty(query)) {
          continue;
        }
        const timestamp = resultSet.getLong(resultSet.getColumnIndex('timestamp'));
        searchHistoryList.push({
          query,
          timestamp
        });
      }
      resultSet.close();
      return searchHistoryList;
    } catch (error) {
      LogUtil.error(`${TAG} getSearchHistoryData message: ${error?.message}, code: ${error?.code}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
      return searchHistoryList;
    }
  }

  async clearSearchHistoryData(): Promise<void> {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSearchEventGroup.CLEAR_SEARCH_HISTORY_DATA);
    const rdbStore = await this.getRdbStore();
    try {
      rdbStore.beginTransaction();
      await rdbStore.executeSql(SQL_DELETE_SEARCHHISTORY_TABLE);
      rdbStore.commit();
      LogUtil.info(`${TAG} clearSearchHistoryData successfully.`);
      HiSysEventUtil.searchReportEvent(TAG, 'ClearSearchHistoryData success');
    } catch (error) {
      LogUtil.error(`${TAG} clearSearchHistoryData failed, message: ${error?.message}, code: ${error?.code}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
      HiSysEventUtil.searchReportEvent(TAG, `clearSearchHistoryData error: ${JSON.stringify(error)}`);
      rdbStore.rollBack();
    }
  }

  private getDbBucketList(itemInfo: SearchHistory): relationalStore.ValuesBucket {
    return {
      'query': itemInfo.query,
      'timestamp': itemInfo.timestamp,
    }
  }
}

export default new SearchHistoryManager();