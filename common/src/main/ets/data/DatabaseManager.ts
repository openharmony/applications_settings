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

import taskpool from '@ohos.taskpool';
import type common from '@ohos.app.ability.common';
import type { BusinessError } from '@ohos.base';
import relationalStore from '@ohos.data.relationalStore';
import { LogUtil } from '../utils/LogUtil';
import { CheckEmptyUtils } from '../utils/CheckEmptyUtils';
import { AbilityContextManager } from '../ability/AbilityContextManager';
import { SystemParamUtil } from '../utils/SystemParamUtil';

const TAG = 'DatabaseManager : ';

/**
 * 数据库管理基类
 * 通过继承实现具体能力
 *
 * @since 2023-08-10
 */
export default abstract class DatabaseManager {
  public rdbStore: relationalStore.RdbStore | undefined;

  /**
   * 获取关系数据库存储对象
   * 如果已初始化过，则直接返回之前获取的对象
   * 如果没有初始化过，则使用接口获取对象，并执行数据库建表命令，如果表未创建，则会创建一张新的表
   *
   * @param createTableSql 创建新表使用的 SQL
   * @return 关系数据库存储对象
   */
  async getRdbStore(createTableSql: string): Promise<relationalStore.RdbStore> {
    if (this.rdbStore) {
      return this.rdbStore;
    }
    try {
      let context: common.Context = DatabaseManager.getContext();
      this.rdbStore = await getRdbStore(context, createTableSql);
      LogUtil.info(`${TAG} Get RdbStore successfully, rdb version ${this.rdbStore.version}`);
    } catch (error) {
      LogUtil.error(`${TAG} Get RdbStore failed, err: ${(error as BusinessError).message}`);
    }
    return this.rdbStore;
  }

  public async restoreRdb(): Promise<void> {
    LogUtil.info('start restore rdb');
    if (!this.rdbStore) {
      LogUtil.error('current rdbStore is empty');
      return;
    }
    try {
      await this.rdbStore.restore();
      LogUtil.info('rdb restore success');
    } catch (error) {
      LogUtil.error(`rdb restore faild. code: ${error?.code}, message: ${error?.message}`);
    }
  }

  /**
   * Context变化，重置rdbStore
   */
  public resetRdbStore(): void {
    this.rdbStore = undefined;
  }

  private static getContext(): common.Context {
    let context = AbilityContextManager.getContext();
    if (CheckEmptyUtils.isEmpty(context)) {
      context = AbilityContextManager.getExtContext();
    }
    if (CheckEmptyUtils.isEmpty(context)) {
      context = AbilityContextManager.getBackgroundIntentContext();
      LogUtil.showWarn(TAG, 'get background intent context.');
    }
    if (CheckEmptyUtils.isEmpty(context)) {
      context = AbilityContextManager.getStageContext();
      LogUtil.showWarn(TAG, 'get stage context.');
    }
    return context;
  }
}

async function getRdbStore(context: common.Context, createTableSql: string): Promise<relationalStore.RdbStore | undefined> {
  'use concurrent';
  const STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'SettingsApp.db',
    securityLevel: relationalStore.SecurityLevel.S1,
    encrypt: false,
    isSearchable: !SystemParamUtil.isDeviceTv,
    haMode: relationalStore.HAMode.MAIN_REPLICA, //配置为双写备份
    allowRebuild: true
  };
  try {
    let rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
    if (!CheckEmptyUtils.checkStrIsEmpty(createTableSql) ) {
      await rdbStore.executeSql(createTableSql);
    }
    return rdbStore;
  } catch (error) {
    LogUtil.error(`DatabaseManager getRdbStore failed ：${error?.message}`);
  }
  return undefined;
}