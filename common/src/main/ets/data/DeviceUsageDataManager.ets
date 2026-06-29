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

import common from '@ohos.app.ability.common';
import commonEventManager from '@ohos.commonEventManager';
import relationalStore from '@ohos.data.relationalStore';
import { HiSysRdbEventGroup } from '../systemEvent/BehaviorEventConsts';
import { HiSysEventUtil } from '../systemEvent/HiSysEventUtil';
import { LogUtil } from '../utils/LogUtil';
import DatabaseManager from './DatabaseManager';
import { DEVICE_USAGE_HISTORY_TABLE, DeviceUsageHistory, SQL_CREATE_DEVICE_USAGE_TABLE, } from './DeviceUsageDataType';

/* instrument ignore file */
const TAG: string = 'DeviceUsageDataManager:';
const RDB_CORRUPTION_ERROR_CODE: number = 14800011;

export const DEVICE_USAGE_DATA_LOADING: string = 'DeviceUsageDataLoading';

// RDB 数据库的初始化配置
export const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'SettingsApp.db',
  securityLevel: relationalStore.SecurityLevel.S1,
  encrypt: false,
  isSearchable: true,
  haMode: relationalStore.HAMode.MAIN_REPLICA, //配置为双写备份
  allowRebuild: true
};

export class DeviceUsageManager extends DatabaseManager {
  public rdbStore: relationalStore.RdbStore | undefined;

  /**
   * 获取关系数据库存储对象
   * 如果已初始化过，则直接返回之前获取的对象
   * 如果没有初始化过，则使用接口获取对象，并执行数据库建表命令，如果表未创建，则会创建一张新的表
   *
   * @return 关系数据库存储对象
   */
  async getRdb(context: common.Context): Promise<relationalStore.RdbStore | undefined> {
    if (this.rdbStore) {
      return this.rdbStore;
    }
    try {
      LogUtil.info(`${TAG} getRdbStore start.`);
      let rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
      await rdbStore.executeSql(SQL_CREATE_DEVICE_USAGE_TABLE);
      this.rdbStore = rdbStore;
      LogUtil.info(`${TAG} getRdbStore success. rdbStoreBattery.version:${this.rdbStore?.version}`);
    } catch (error) {
      LogUtil.error(`${TAG} getRdbStore error. code:${error?.code} message:${error?.message}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
    }
    return this.rdbStore;
  }

  /**
   * 设备使用时长数据库 - 插入数据
   */
  async batchInsertDeviceUsageHistoryData(context: common.Context,
    itemInfoList?: relationalStore.ValuesBucket[]): Promise<void> {
    if (itemInfoList) {
      const rdbStore = await this.getRdb(context);
      let transaction: relationalStore.Transaction | undefined;
      try {
        transaction = await rdbStore?.createTransaction();
        if (transaction) {
          const predicates = new relationalStore.RdbPredicates(DEVICE_USAGE_HISTORY_TABLE);
          LogUtil.info(`${TAG} deleteDeviceUsageHistoryData start.`);
          // 先删除保证时序
          let deleteNum: number = await transaction.delete(predicates);
          LogUtil.info(`${TAG} batchInsertDeviceUsageHistoryData start. deleted num: ${deleteNum}, need insert num: ${itemInfoList?.length}`);
          let insertNum: number = await transaction.batchInsert(DEVICE_USAGE_HISTORY_TABLE, itemInfoList);
          LogUtil.info(`${TAG} batchInsertDeviceUsageHistoryData success, insertNum: ${insertNum}`);
          await transaction.commit();
          LogUtil.info(`${TAG} commit device usage data success`);
          this.sendBarChartRefresh();
        }
      } catch (error) {
        LogUtil.error(`${TAG} batchInsertDeviceUsageHistoryData error. code: ${error?.code} message: ${error?.message}`);
        if (error.code === RDB_CORRUPTION_ERROR_CODE) {
          HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
            HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
          await super.restoreRdb();
        }
        if (transaction) {
          transaction?.rollback();
        }
      }
    }
  }

  /**
   *  查询所有数据
   */
  async queryDeviceUsageHistoryData(context: common.Context): Promise<DeviceUsageHistory[]> {
    const rdbStore = await this.getRdb(context);
    let resultSet: relationalStore.ResultSet | undefined = undefined;
    let deviceUsageHistoryList: DeviceUsageHistory[] = [];
    try {
      const predicates = new relationalStore.RdbPredicates(DEVICE_USAGE_HISTORY_TABLE);
      predicates.orderByDesc('timestamp');
      LogUtil.info(`${TAG} queryDeviceUsageHistoryData start.`);
      resultSet = await rdbStore?.query(predicates);
      if (!resultSet) {
        LogUtil.warn(`${TAG} queryDeviceUsageHistoryData failed.`);
        return deviceUsageHistoryList;
      }
      LogUtil.info(`${TAG} queryDeviceUsageHistoryData success. resultSet.rowCount: ${resultSet.rowCount}.`);
      while (resultSet.goToNextRow()) {
        const timestamp = resultSet.getLong(resultSet.getColumnIndex('timestamp'));
        const screenOnTime = resultSet.getLong(resultSet.getColumnIndex('screenOnTime'));
        const screenOffActivityTime = resultSet.getLong(resultSet.getColumnIndex('screenOffActivityTime'));
        deviceUsageHistoryList.push({
          timestamp,
          screenOnTime,
          screenOffActivityTime,
        });
      }
    } catch (error) {
      LogUtil.error(`${TAG} queryDeviceUsageHistoryData error. code:${error?.code} message:${error?.message}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
    } finally {
      resultSet?.close();
    }
    return deviceUsageHistoryList;
  }

  /**
   * 通知电池柱状图图重新查数据库来刷新数据
   */
  sendBarChartRefresh(): void {
    try {
      commonEventManager.publish(DEVICE_USAGE_DATA_LOADING, () => {
      });
    } catch (error) {
      LogUtil.error(`commonEventManager createSubscriber error: ${error?.code} ${error?.message}`);
    }
  }
}

export default new DeviceUsageManager();