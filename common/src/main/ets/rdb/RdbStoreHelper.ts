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

const TAG = 'RdbStoreHelper';

import rdb from '@ohos.data.relationalStore';
import type common from '@ohos.app.ability.common';
import { LogUtil } from '../utils/LogUtil';
import { Constants } from '../constant/PackagesConstant';
import { CheckEmptyUtils } from '../utils/CheckEmptyUtils';
import { SystemParamUtil } from '../utils/SystemParamUtil';

const RDB_CORRUPTION_ERROR_CODE: number = 14800011;

export const STORE_CONFIG: rdb.StoreConfig = {
  name: 'SettingsApp.db',
  securityLevel: rdb.SecurityLevel.S1,
  encrypt: false,
  isSearchable: !SystemParamUtil.isDeviceTv,
  haMode: rdb.HAMode.MAIN_REPLICA, //配置为双写备份
  allowRebuild: true
};

/**
 * 数据库操作帮助类.
 */
export class RdbStoreHelper {
  private rdbStore: rdb.RdbStore;

  /**
   * Rdb helper instance
   *
   * @return rdbStoreHelper instance
   */
  public static getInstance(): RdbStoreHelper {
    if (globalThis.RdbStoreHelperInstance == null) {
      globalThis.RdbStoreHelperInstance = new RdbStoreHelper();
    }
    return globalThis.RdbStoreHelperInstance;
  }

  /**
   * 插入数据
   *
   * @param context 上下文
   * @param tableName 表名
   * @param valuesBucket 数据
   * @returns 插入行数
   */
  public async insert(context: common.BaseContext, tableName: string, valuesBucket: rdb.ValuesBucket): Promise<number> {
    if (CheckEmptyUtils.isEmpty(valuesBucket) || CheckEmptyUtils.isEmpty(context)) {
      LogUtil.showWarn(TAG, 'empty valuesBucket while insert or rdbStore undefined');
      return Constants.INVALID_VALUE;
    }

    if (!this.rdbStore) {
      await this.getRdbStore(context);
    }
    try {
      return await this.rdbStore?.insert(tableName, valuesBucket, rdb.ConflictResolution.ON_CONFLICT_REPLACE);
    } catch (error) {
      LogUtil.showError(TAG, `insert error ${error?.message}, code: ${error?.code}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        await this.restoreRdb();
      }
    }

    return Constants.INVALID_VALUE;
  }

  /**
   * 批量插入
   *
   * @param context context上下文
   * @param tableName 表名
   * @param insertBucketList 插入到表中的一组数据
   * @returns 返回插入的数据个数
   */
  public async batchInsert(context: common.BaseContext, tableName: string,
    insertBucketList: Array<rdb.ValuesBucket>): Promise<number> {
    if (CheckEmptyUtils.isEmptyArr(insertBucketList) || CheckEmptyUtils.isEmpty(context)) {
      LogUtil.showWarn(TAG, 'empty valuesBucket while batchInsert or context undefined');
      return Constants.INVALID_VALUE;
    }

    if (!this.rdbStore) {
      await this.getRdbStore(context);
    }

    try {
      return await this.rdbStore?.batchInsert(tableName, insertBucketList);
    } catch (error) {
      LogUtil.showError(TAG, `insertBatch error ${error?.message}, code: ${error?.code}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        await this.restoreRdb();
      }
    }

    return Constants.INVALID_VALUE;
  }

  /**
   * 查询某张表所有数据
   *
   * @param context context上下文
   * @param tableName 表的名称
   * @return 查询结果集
   */
  public async queryAll(context: common.BaseContext, tableName: string): Promise<rdb.ResultSet> {
    return await this.query(context, new rdb.RdbPredicates(tableName), []);
  }

  /**
   * 根据指定条件查询数据
   *
   * @param context context上下文
   * @param predicates 查询条件
   * @param columns 字段列表
   * @return 查询结果集
   */
  public async query(context: common.BaseContext, predicates: rdb.RdbPredicates,
    columns?: Array<string>): Promise<rdb.ResultSet> {
    if (!this.rdbStore) {
      await this.getRdbStore(context);
    }

    try {
      return await this.rdbStore?.query(predicates, columns);
    } catch (error) {
      LogUtil.showError(TAG, `query error ${error?.message}, code: ${error?.code}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        await this.restoreRdb();
      }
    }

    return undefined;
  }

  /**
   * 通过 sql 查询数据
   *
   * @param context context上下文
   * @param sql 待查询的 sql
   * @returns 查询后的结果集
   */
  public async querySql(context: common.BaseContext, sql: string): Promise<rdb.ResultSet> {
    if (!this.rdbStore) {
      await this.getRdbStore(context);
    }

    try {
      return await this.rdbStore?.querySql(sql);
    } catch (error) {
      LogUtil.showError(TAG, `query by sql error: ${error?.message}, code: ${error?.code}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        await this.restoreRdb();
      }
    }

    return undefined;
  }

  /**
   * 执行sql语句
   *
   * @param rdbStore 数据库存储对象
   * @param sql  sql语句
   * @returns 查询后的结果集
   */
  public async executeSql(context: common.BaseContext, sql: string, bindArgs?: Array<rdb.ValueType>): Promise<void> {
    if (!this.rdbStore) {
      await this.getRdbStore(context);
    }

    try {
      return await this.rdbStore?.executeSql(sql, bindArgs);
    } catch (error) {
      LogUtil.showError(TAG, `execute sql error: ${error?.message}, code: ${error?.code}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        await this.restoreRdb();
      }
    }

    return undefined;
  }

  /**
   * 根据条件更新数据库
   *
   * @param rdbStore 数据库存储对象
   * @param predicates 更新条件
   * @param valueBucket 更新的数据
   * @return 受影响的行数
   */
  public async update(context: common.BaseContext, predicates: rdb.RdbPredicates,
    valuesBucket: rdb.ValuesBucket): Promise<number> {
    if (CheckEmptyUtils.isEmpty(valuesBucket) || CheckEmptyUtils.isEmpty(context)) {
      LogUtil.showWarn(TAG, 'empty valuesBucket while update or rdbStore undefined');
      return Constants.INVALID_VALUE;
    }

    if (!this.rdbStore) {
      await this.getRdbStore(context);
    }

    try {
      return await this.rdbStore?.update(valuesBucket, predicates);
    } catch (error) {
      LogUtil.error(`${TAG} removeSearchItemByEntryKey failed, message: ${error?.message}, code: ${error?.code}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        await this.restoreRdb();
      }
    }
    return Constants.INVALID_VALUE;
  }

  /**
   * 根据条件删除数据
   *
   * @param rdbStore 数据库存储对象
   * @param predicates 删除条件
   * @return 受影响的行数
   */
  public async delete(context: common.BaseContext, predicates: rdb.RdbPredicates): Promise<number> {
    if (CheckEmptyUtils.isEmpty(predicates) || CheckEmptyUtils.isEmpty(context)) {
      LogUtil.showWarn(TAG, 'empty predicates while delete or rdbStore undefined');
      return Constants.INVALID_VALUE;
    }

    if (!this.rdbStore) {
      await this.getRdbStore(context);
    }

    try {
      return await this.rdbStore?.delete(predicates);
    } catch (error) {
      LogUtil.error(`${TAG} delete error: ${error?.message}, code: ${error?.code}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        await this.restoreRdb();
      }
    }

    return Constants.INVALID_VALUE;
  }

  public setRdbStore(rdbStore: rdb.RdbStore): void {
    this.rdbStore = rdbStore;
  }

  private async getRdbStore(context: common.BaseContext): Promise<rdb.RdbStore> {
    if (CheckEmptyUtils.isEmpty(this.rdbStore) && context) {
      try {
        this.rdbStore = await rdb.getRdbStore(context, STORE_CONFIG);
      } catch (err) {
        LogUtil.showError(TAG, `getRdbStore error: ${err?.message}`);
        return undefined;
      }
    }
    return this.rdbStore;
  }

  private async restoreRdb(): Promise<void> {
    LogUtil.info('start restore rdb');
    if (!this.rdbStore) {
      LogUtil.error('current rdbStore is empty');
      return;
    }
    try {
      await this.rdbStore.restore();
      LogUtil.info('rdb restore success');
    } catch (err) {
      LogUtil.error(`rdb restore faild. code: ${err.code}, message: ${err.message}`);
    }
  }
}
