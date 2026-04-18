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
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import commonEventManager from '@ohos.commonEventManager';
import { LogUtil } from '../utils/LogUtil';
import DatabaseManager from './DatabaseManager';
import {
  BatteryListData,
  BATTERYLIST_TABLE,
  SQL_CREATE_BATTERY_LIST_TABLE,
  SQL_DELET_OLD_BATTERYLIST_TABLE,
} from './BatteryListDataType';
import { HiSysEventUtil } from '../systemEvent/HiSysEventUtil';
import { HiSysRdbEventGroup } from '../systemEvent/BehaviorEventConsts';

const TAG: string = 'BatteryListDataManager:';
const POWER_DATA_LOADING: string = 'PowerDataLoading';
const RDB_CORRUPTION_ERROR_CODE: number = 14800011;

// RDB 数据库的初始化配置
export const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'SettingsApp.db',
  securityLevel: relationalStore.SecurityLevel.S1,
  encrypt: false,
  isSearchable: true,
  haMode: relationalStore.HAMode.MAIN_REPLICA, //配置为双写备份
  allowRebuild: true
};

export class BatteryListDataManager extends DatabaseManager {
  public rdbStore: relationalStore.RdbStore | undefined;

  /**
   * 获取关系数据库存储对象
   * 如果已初始化过，则直接返回之前获取的对象
   * 如果没有初始化过，则使用接口获取对象，并执行数据库建表命令，如果表未创建，则会创建一张新的表
   *
   * @return 关系数据库存储对象
   */
  async getRdb(context: common.Context): Promise<relationalStore.RdbStore> {
    if (this.rdbStore) {
      return this.rdbStore;
    }
    try {
      LogUtil.info(`${TAG} getRdbStore start.`);
      let rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
      await rdbStore.executeSql(SQL_DELET_OLD_BATTERYLIST_TABLE);
      await rdbStore.executeSql(SQL_CREATE_BATTERY_LIST_TABLE);
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
    return this.rdbStore as relationalStore.RdbStore;
  }

  /**
   * 电池耗电应用列表数据库 - 插入数据
   */
  async batchInsertBatteryHistoryData(context: common.Context,
                                      itemInfoList?: relationalStore.ValuesBucket[]): Promise<void> {
    if (itemInfoList) {
      const rdbStore = await this.getRdb(context);
      let transaction: relationalStore.Transaction | undefined = undefined;
      try {
        transaction = await rdbStore.createTransaction();
        if (transaction) {
          const predicates = new relationalStore.RdbPredicates(BATTERYLIST_TABLE);
          LogUtil.info(`${TAG} deleteBatteryHistoryData start.`);
          // 先删除保证时序
          let deleteNum: number = await transaction.delete(predicates);
          LogUtil.info(`${TAG} batchInsertBatteryHistoryData start. deleted num: ${deleteNum}, need insert num:${itemInfoList?.length}`);
          let insertNum: number = await transaction.batchInsert(BATTERYLIST_TABLE, itemInfoList);
          LogUtil.info(`${TAG} batchInsertBatteryHistoryData success, insertNum: ${insertNum}`);
          await transaction.commit();
          LogUtil.info(`${TAG} commit list data success`);
          this.sendListChartRefresh();
        }
      } catch (error) {
        LogUtil.error(`${TAG} batchInsertBatteryHistoryData error, message: ${error?.message}, code: ${error?.code}`);
        if (error.code === RDB_CORRUPTION_ERROR_CODE) {
          HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
            HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
          await super.restoreRdb();
        }
        if (transaction) {
          transaction.rollback();
        }
      }
    }
  }

  /**
   * 电池耗电应用列表数据库 - 查询时间段数据
   */
  async queryBatteryTimeAppData(context: common.Context,
                                startTimestamp: number, endTimestamp: number): Promise<BatteryListData[]> {
    let listMap: Map<string, BatteryListData> = new Map();
    let resultSet: relationalStore.ResultSet | undefined;
    try {
      const rdbStore = await this.getRdb(context);
      const timestampPredicates = new relationalStore.RdbPredicates(BATTERYLIST_TABLE);
      timestampPredicates.greaterThan('timestamp', startTimestamp).lessThanOrEqualTo('timestamp', endTimestamp);
      LogUtil.info(`${TAG} queryBatteryTimeAppData start. startTime:${startTimestamp} endTime:${endTimestamp}`);
      resultSet = await rdbStore.query(timestampPredicates);
      LogUtil.info(`${TAG} queryBatteryTimeAppData success. resultSet.rowCount:${resultSet?.rowCount}`);
      let batteryHistoryList = this.resultSet2List(resultSet);
      batteryHistoryList.forEach(item => {
        if (listMap.has(item.bundleName)) {
          let hItem: BatteryListData = listMap.get(item.bundleName) as BatteryListData;
          hItem.foregroundTime += item.foregroundTime;
          hItem.foregroundPower += item.foregroundPower;
          hItem.backgroundTime += item.backgroundTime;
          hItem.backgroundPower += item.backgroundPower;
          hItem.totalPower += item.totalPower;
          listMap.set(item.bundleName, hItem);
        } else {
          listMap.set(item.bundleName, item);
        }
      })
    } catch (error) {
      LogUtil.error(`${TAG} queryBatteryTimeAppData error. code:${error?.code} message:${error?.message}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
    } finally {
      if (resultSet) {
        resultSet && resultSet.close();
      }
    }
    LogUtil.info(`${TAG} queryBatteryTimeAppData. listMap.size:${listMap?.size}`);
    return Array.from(listMap.values());
  }

  /**
   * 组装数据库结果 resultSet 转成 list 对象
   */
  resultSet2List(resultSet: relationalStore.ResultSet): BatteryListData[] {
    let batteryHistoryList: BatteryListData[] = [];
    try {
      while (resultSet.goToNextRow()) {
        const timestamp = resultSet.getLong(resultSet.getColumnIndex('timestamp'));
        const bundleName = resultSet.getString(resultSet.getColumnIndex('bundleName'));
        const percentage = resultSet.getLong(resultSet.getColumnIndex('percentage'));
        const totalPower = resultSet.getLong(resultSet.getColumnIndex('totalPower'));
        const foregroundTime = resultSet.getLong(resultSet.getColumnIndex('foregroundTime'));
        const foregroundPower = resultSet.getLong(resultSet.getColumnIndex('foregroundPower'));
        const backgroundTime = resultSet.getLong(resultSet.getColumnIndex('backgroundTime'));
        const backgroundPower = resultSet.getLong(resultSet.getColumnIndex('backgroundPower'));
        const appType = resultSet.getLong(resultSet.getColumnIndex('appType'));
        batteryHistoryList.push({
          timestamp,
          bundleName,
          percentage,
          totalPower,
          foregroundTime,
          foregroundPower,
          backgroundTime,
          backgroundPower,
          appType,
        });
      }
      resultSet.close();
    } catch (error) {
      resultSet.close();
      LogUtil.error(`${TAG} getBatteryHistoryData error:  ${(error as BusinessError).message}`);
    }
    return batteryHistoryList;
  }


  /**
   * 电池耗电应用列表数据库 - 查询所有数据
   */
  async queryBatteryHistoryData(context: common.Context): Promise<BatteryListData[]> {
    const rdbStore = await this.getRdb(context);
    let batteryHistoryList: BatteryListData[] = [];
    let resultSet: relationalStore.ResultSet | undefined;
    try {
      const predicates = new relationalStore.RdbPredicates(BATTERYLIST_TABLE);
      predicates.orderByDesc('timestamp');
      LogUtil.info(`${TAG} queryBatteryHistoryData start.`);
      resultSet = await rdbStore.query(predicates);
      LogUtil.info(`${TAG} queryBatteryHistoryData success. resultSet.rowCount:${resultSet?.rowCount}`);
      batteryHistoryList = this.resultSet2List(resultSet);
    } catch (error) {
      LogUtil.error(`${TAG} getBatteryHistoryData error, message: ${error?.message}, code: ${error?.code}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
    } finally {
      if (resultSet) {
        resultSet && resultSet.close();
      }
    }
    return batteryHistoryList;
  }

  /**
   * 通知电池耗电列表重新查数据库来刷新数据
   */
  sendListChartRefresh(): void {
    try {
      commonEventManager.publish(POWER_DATA_LOADING, (error: BusinessError) => {});
    } catch (error) {
      LogUtil.error(`commonEventManager createSubscriber error: ${error?.message}`);
    }
  }
}

export default new BatteryListDataManager();