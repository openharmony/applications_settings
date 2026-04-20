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
import i18n from '@ohos.i18n';
import type common from '@ohos.app.ability.common';
import relationalStore from '@ohos.data.relationalStore';
import { LogUtil } from '../utils/LogUtil';
import DatabaseManager from './DatabaseManager';
import {
  SQL_CREATE_OPERATION_TABLE,
  ENABLED_TRUE,
  ENABLED_FALSE,
  SearchItemOperation,
  OPERATION_TABLE,
} from './types';
import { CheckEmptyUtils } from '../utils/CheckEmptyUtils';
import { RdbTaskPool } from '../rdb/RdbTaskPool';
/* instrument ignore file */
const TAG: string = 'SearchItemOperationManager';
const RDB_CORRUPTION_ERROR_CODE: number = 14800011;

export class SearchItemOperationManager extends DatabaseManager {
  /**
   * 获取关系数据库存储对象
   * 如果已初始化过，则直接返回之前获取的对象
   * 如果没有初始化过，则使用接口获取对象，并执行数据库建表命令，如果表未创建，则会创建一张新的表
   *
   * @return 关系数据库存储对象
   */
  async getRdbStore(): Promise<relationalStore.RdbStore> {
    const rdbStore = await super.getRdbStore(SQL_CREATE_OPERATION_TABLE);
    return rdbStore;
  }

  /**
   * 插入搜索项的操作记录
   *
   * @param searchOperationData 操作项封装对象
   * @returns
   */
  async insertSearchOperationData(searchOperationData: SearchItemOperation): Promise<void> {
    const rdbStore = await this.getRdbStore();
    if (searchOperationData) {
      try {
        const predicates = new relationalStore.RdbPredicates(OPERATION_TABLE);
        predicates.equalTo('itemName', searchOperationData.itemName).and()
          .equalTo('locale', searchOperationData.locale)
          .and().equalTo('bundleName', searchOperationData.bundleName);
        const resultSet = await rdbStore.query(predicates);
        if (resultSet.rowCount) {
          LogUtil.info(`${TAG} start updateSearchHistoryData... `);
          await rdbStore.update(this.getDbBucketList(searchOperationData), predicates);
          resultSet.close();
          LogUtil.info(`${TAG} updateSearchHistoryData success`);
          return;
        }
        resultSet.close();
        LogUtil.info(`${TAG} start insertSearchHistoryData...`);
        await rdbStore.insert(OPERATION_TABLE, this.getDbBucketList(searchOperationData));
        LogUtil.info(`${TAG} insertSearchHistoryData result`);
      } catch (error) {
        LogUtil.error(`${TAG} insertSearchHistoryData message: ${error?.message}, code: ${error?.code}`);
        if (error.code === RDB_CORRUPTION_ERROR_CODE) {
          await super.restoreRdb();
        }
      }
    }
  }

  /**
   * 批量插入数据
   * @param itemInfoList 操作历史表
   * @param context 上下文
   * @returns void
   */
  async batchInsertSearchItemOperationData(itemInfoList: Array<SearchItemOperation>,
    context?: common.Context): Promise<void> {
    if (itemInfoList === undefined || itemInfoList.length === 0) {
      LogUtil.error(`${TAG} batchInsertSearchItemOperationData error: array is empty!`);
      return;
    }
    try {
      LogUtil.info(`${TAG} start batchInsertSearchItemOperationData`);
      let searchItemOperationInfos: relationalStore.ValuesBucket[] = [];
      itemInfoList.forEach((itemInfo) => {
        searchItemOperationInfos.push(this.getDbBucketList(itemInfo));
      })
      LogUtil.info(`${TAG} batchInsertSearchItemOperationData size:${searchItemOperationInfos.length}`);
      let result = await RdbTaskPool.getInstance().batchInsert(OPERATION_TABLE, searchItemOperationInfos, context);
      LogUtil.info(`${TAG} batchInsertSearchItemOperationData result: ${result}`);
    } catch (error) {
      LogUtil.error(`${TAG} batchInsertSearchItemOperationData error: ${error?.message}`);
    }
  }

  /**
   * 查询历史操作记录
   *
   * @param bundleName 可选参数包名
   * @returns list
   */
  async querySearchItemOperationData(bundleName?: string, itemList?: string[],
    businessId?: string): Promise<SearchItemOperation[]> {
    const rdbStore = await this.getRdbStore();
    let searchItemOperationList: SearchItemOperation[] = [];
    if (!rdbStore) {
      return searchItemOperationList;
    }
    try {
      const predicates = new relationalStore.RdbPredicates(OPERATION_TABLE);
      let curLocale: string = i18n.System.getSystemLocale();
      predicates.equalTo('locale', curLocale);
      if (bundleName !== undefined) {
        predicates.and().equalTo('bundleName', bundleName);
      }
      if (businessId) {
        predicates.and().equalTo('businessId', businessId);
      }
      if (itemList !== undefined && itemList.length > 0) {
        predicates.and().in('itemName', itemList);
      }
      const resultSet = await rdbStore.query(predicates);
      while (resultSet.goToNextRow()) {
        const locale: string = resultSet.getString(resultSet.getColumnIndex('locale'));
        const itemName: string = resultSet.getString(resultSet.getColumnIndex('itemName'));
        const itemTitle: string = resultSet.getString(resultSet.getColumnIndex('itemTitle'));
        const itemDescription: string = resultSet.getString(resultSet.getColumnIndex('itemDescription'));
        const entryKey: string = resultSet.getString(resultSet.getColumnIndex('entryKey'));
        const pageTitle: string = resultSet.getString(resultSet.getColumnIndex('pageTitle'));
        const params: string = resultSet.getString(resultSet.getColumnIndex('params'));
        const enable: boolean = resultSet.getLong(resultSet.getColumnIndex('enable')) === ENABLED_TRUE;
        const icon: string = resultSet.getString(resultSet.getColumnIndex('icon'));
        const alias: string = resultSet.getString(resultSet.getColumnIndex('alias'));
        const childItems: string = resultSet.getString(resultSet.getColumnIndex('childItems'));
        const path: string = resultSet.getString(resultSet.getColumnIndex('path'));
        const bundleName: string = resultSet.getString(resultSet.getColumnIndex('bundleName'));
        const checkType: string = resultSet.getString(resultSet.getColumnIndex('checkType'));
        const checkKey: string = resultSet.getString(resultSet.getColumnIndex('checkKey'));
        const checkValue: string = resultSet.getString(resultSet.getColumnIndex('checkValue'));
        const content: string = resultSet.getString(resultSet.getColumnIndex('content'));
        const status: string = resultSet.getString(resultSet.getColumnIndex('status'));
        const timestamp: number = resultSet.getLong(resultSet.getColumnIndex('timestamp'));
        const businessId: string = resultSet.getString(resultSet.getColumnIndex('businessId'));
        const optBundleName: string = resultSet.getString(resultSet.getColumnIndex('optBundleName'));
        searchItemOperationList.push({
          locale,
          itemName,
          itemTitle,
          itemDescription,
          entryKey,
          pageTitle,
          params,
          enable,
          icon,
          alias,
          childItems,
          path,
          bundleName,
          checkType,
          checkKey,
          checkValue,
          content,
          status,
          timestamp,
          businessId,
          optBundleName
        });
      }
      resultSet.close();
      return searchItemOperationList;
    } catch (error) {
      LogUtil.error(`${TAG} query searchItemOperationList message: ${error?.message}, code: ${error?.code}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        await super.restoreRdb();
      }
      return searchItemOperationList;
    }
  }

  async querySearchOpMap(bundleName?: string): Promise<Map<string, SearchItemOperation>> {
    let itemMap: Map<string, SearchItemOperation> = new Map();
    let list: SearchItemOperation[] = await this.querySearchItemOperationData(bundleName);
    if (list.length === 0) {
      return itemMap;
    }
    list.forEach(item => {
      itemMap.set(item.itemName, item);
    });
    return itemMap;
  }

  /**
   * 删除itemName的操作历史记录
   *
   * @param itemName
   * @returns
   */
  async deleteSearchItem(itemName: string, bundleName: string): Promise<void> {
    if (CheckEmptyUtils.checkStrIsEmpty(itemName)) {
      LogUtil.showError(TAG, 'deleteSearchItem error, itemName is empty');
      return;
    }

    const rdbStore = await this.getRdbStore();
    try {
      rdbStore.beginTransaction();
      const predicates = new relationalStore.RdbPredicates(OPERATION_TABLE);
      let curLocale: string = i18n.System.getSystemLocale();
      predicates.equalTo('locale', curLocale).and().equalTo('itemName', itemName)
        .and().equalTo('bundleName', bundleName);
      let result = await rdbStore.delete(predicates);
      rdbStore.commit();
      LogUtil.showInfo(TAG, `delete search item operation: ${curLocale}, ${itemName} changeRows: ${result}`);
    } catch (error) {
      LogUtil.showError(TAG, `deleteSearchItem operation error, message: ${error?.message},
        code: ${error?.code}, ${RDB_CORRUPTION_ERROR_CODE}, ${error?.code === RDB_CORRUPTION_ERROR_CODE}}`);
      if (error?.code === RDB_CORRUPTION_ERROR_CODE) {
        await super.restoreRdb();
      }
      rdbStore.rollBack();
    }
  }

  private getDbBucketList(itemInfo: SearchItemOperation): relationalStore.ValuesBucket {
    return {
      'locale': itemInfo.locale,
      'itemName': itemInfo.itemName,
      'itemTitle': itemInfo.itemTitle,
      'itemDescription': itemInfo.itemDescription,
      'entryKey': itemInfo.entryKey,
      'pageTitle': itemInfo.pageTitle,
      'params': itemInfo.params,
      'enable': itemInfo.enable ? ENABLED_TRUE : ENABLED_FALSE,
      'icon': itemInfo.icon,
      'alias': itemInfo.alias,
      'childItems': itemInfo.childItems,
      'path': itemInfo.path,
      'bundleName': itemInfo.bundleName,
      'checkType': itemInfo.checkType,
      'checkKey': itemInfo.checkKey,
      'checkValue': itemInfo.checkValue,
      'content': itemInfo.content,
      'status': itemInfo.status,
      'timestamp': itemInfo.timestamp,
      'businessId': itemInfo.businessId,
      'optBundleName': itemInfo.optBundleName,
    }
  }
}

export default new SearchItemOperationManager();