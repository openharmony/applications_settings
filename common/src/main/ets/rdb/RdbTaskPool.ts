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

import rdb from '@ohos.data.relationalStore';
import taskPool from '@ohos.taskpool';
import common from '@ohos.app.ability.common';
import { Constants } from '../constant/PackagesConstant';
import { CheckEmptyUtils } from '../utils/CheckEmptyUtils';
import { LogUtil } from '../utils/LogUtil';
import { AbilityContextManager } from '../ability/AbilityContextManager';
import lazy { RdbStoreHelper } from './RdbStoreHelper';

const TAG = 'RdbTaskPool';

export class RdbTaskPool {
  public static getInstance(): RdbTaskPool {
    if (globalThis.RdbTaskPoolInstance == null) {
      globalThis.RdbTaskPoolInstance = new RdbTaskPool();
    }
    return globalThis.RdbTaskPoolInstance;
  }

  /**
   * 插入操作
   *
   * @param tableName 表名
   * @param valuesBucket 数据
   * @returns 插入行数
   */
  public async insert(tableName: string, valuesBucket: rdb.ValuesBucket): Promise<number> {
    return <number> await this.doTask(insert, tableName, valuesBucket);
  }

  /**
   * 批量插入操作
   *
   * @param tableName 表名
   * @param valuesBucket 插入到表中的一组数据
   * @returns 返回插入的数据个数
   */
  public async batchInsert(tableName: string, insertBucketList: rdb.ValuesBucket[],
    context?: common.Context): Promise<number> {
    if (context) {
      return <number> await this.doTaskWithContext(context, batchInsert, tableName, insertBucketList);
    } else {
      return <number> await this.doTask(batchInsert, tableName, insertBucketList);
    }
  }

  /**
   * 更新操作
   *
   * @param tableName 表名
   * @param conditions 更新条件
   * @param valuesBucket 更新数据
   * @returns 受影响行数
   */
  public async update(tableName: string, conditions: Map<string, rdb.ValueType>,
    valuesBucket: rdb.ValuesBucket): Promise<number> {
    if (CheckEmptyUtils.isEmpty(conditions)) {
      return Constants.INVALID_VALUE;
    }
    return <number> await this.doTask(updateWithEqual, tableName, conditions, valuesBucket);
  }

  /**
   * 删除操作
   *
   * @param tableName 表名
   * @param conditions 删除条件
   * @returns 受影响行数
   */
  public async delete(tableName: string, conditions: Map<string, rdb.ValueType>): Promise<number> {
    if (CheckEmptyUtils.isEmpty(conditions)) {
      return Constants.INVALID_VALUE;
    }

    return <number> await this.doTask(deleteWithEqual, tableName, conditions);
  }

  /**
   * 查询搜索子项
   *
   * @param tableName 表名
   * @param conditions 查询条件
   * @returns 查询结果
   */
  public async queryChildItems(tableName: string, conditions: Map<string, rdb.ValueType>): Promise<string> {
    if (CheckEmptyUtils.checkStrIsEmpty(tableName) || CheckEmptyUtils.isEmpty(conditions) || conditions.size === 0) {
      LogUtil.showError(TAG, 'queryChildItems fail, tableName or conditions is empty');
      return '';
    }

    let result = String(await this.doTask(querySearchItems, tableName, conditions));
    return result;
  }

  /**
   * 查询entryKey搜索子项
   *
   * @param tableName 表名
   * @param conditions 查询条件
   * @returns 查询结果
   */
  public async queryEntryKey(tableName: string, conditions: Map<string, rdb.ValueType>): Promise<string> {
    if (CheckEmptyUtils.checkStrIsEmpty(tableName) || CheckEmptyUtils.isEmpty(conditions) || conditions.size === 0) {
      LogUtil.showError(TAG, 'queryChildItems fail, tableName or conditions is empty');
      return '';
    }

    let result = String(await this.doTask(querySearchEntryKey, tableName, conditions));
    return result;
  }

  private async doTaskWithContext(context: common.Context, func: Function, ...args: unknown[]): Promise<unknown> {
    try {
      args.push(context);
      const dbTask = new taskPool.Task(func, ...args);
      return await taskPool.execute(dbTask);
    } catch (err) {
      LogUtil.showError(TAG, `doTaskWithContext error when execute ${func.name}, ${err?.message}`);
    }
    return undefined;
  }

  private async doTask(func: Function, ...args: unknown[]): Promise<unknown> {
    let context = AbilityContextManager.getExtContext();
    if (CheckEmptyUtils.isEmpty(context)) {
      context = AbilityContextManager.getContext();
    }
    if (CheckEmptyUtils.isEmpty(context)) {
      context = AbilityContextManager.getBackgroundIntentContext();
      LogUtil.showWarn(TAG, 'get background intent context.');
    }
    if (CheckEmptyUtils.isEmpty(context)) {
      context = AbilityContextManager.getStageContext();
      LogUtil.showWarn(TAG, 'get stage context.');
    }
    try {
      args.push(context);
      const dbTask = new taskPool.Task(func, ...args);
      return await taskPool.execute(dbTask);
    } catch (err) {
      LogUtil.showError(TAG, `doTask error when execute ${func.name}, ${err?.message}`);
    }

    return undefined;
  }
}

async function insert(tableName: string, valuesBucket: rdb.ValuesBucket, context: common.BaseContext): Promise<number> {
  'use concurrent';
  return await RdbStoreHelper.getInstance().insert(context, tableName, valuesBucket);
}

async function batchInsert(tableName: string, insertBucketList: rdb.ValuesBucket[],
  context: common.Context): Promise<number> {
  'use concurrent';
  return await RdbStoreHelper.getInstance().batchInsert(context, tableName, insertBucketList);
}

async function updateWithEqual(tableName: string, conditions: Map<string, rdb.ValueType>,
  valuesBucket: rdb.ValuesBucket, context: common.BaseContext): Promise<number> {
  'use concurrent';
  const predicates = new rdb.RdbPredicates(tableName);
  conditions?.forEach((value, key) => {
    predicates.and().equalTo(key, value);
  });
  return await RdbStoreHelper.getInstance().update(context, predicates, valuesBucket);
}

async function deleteWithEqual(tableName: string, conditions: Map<string, rdb.ValueType>,
  context: common.BaseContext): Promise<number> {
  'use concurrent';
  const predicates = new rdb.RdbPredicates(tableName);
  conditions?.forEach((value, key) => {
    predicates.and().equalTo(key, value);
  });
  return await RdbStoreHelper.getInstance().delete(context, predicates);
}

async function querySearchItems(tableName: string, conditions: Map<string, rdb.ValueType>,
  context: common.Context): Promise<string> {
  'use concurrent';
  const predicates = new rdb.RdbPredicates(tableName);
  conditions?.forEach((value, key) => {
    predicates.and().equalTo(key, value);
  });

  let result: string = '';
  try {
    let resultSet = await RdbStoreHelper.getInstance().query(context, predicates, ['childItems']);
    if (resultSet && resultSet.goToNextRow()) {
      result = resultSet.getString(resultSet.getColumnIndex('childItems'));
    }
    resultSet.close();
  } catch (err) {
    LogUtil.showError('RdbTaskPool', `querySearchItems error: ${err?.message}}`);
  }
  return result;
}

async function querySearchEntryKey(tableName: string, conditions: Map<string, rdb.ValueType>,
  context: common.Context): Promise<string> {
  'use concurrent';
  const predicates = new rdb.RdbPredicates(tableName);
  conditions?.forEach((value, key) => {
    predicates.and().equalTo(key, value);
  });

  let result: string = '';
  try {
    let resultSet = await RdbStoreHelper.getInstance().query(context, predicates, ['entryKey']);
    if (resultSet && resultSet.goToNextRow()) {
      result = resultSet.getString(resultSet.getColumnIndex('entryKey'));
    }
    resultSet.close();
  } catch (err) {
    LogUtil.showError('RdbTaskPool', `querySearchEntryKey error: ${err?.message}}`);
  }
  return result;
}