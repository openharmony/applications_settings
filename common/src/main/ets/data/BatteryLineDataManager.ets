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
import { BatteryHistory, BATTERYHISTORY_TABLE, SQL_CREATE_BATTERYHISTORY_TABLE, } from './BatteryLineDataType';
import { HiSysEventUtil } from '../systemEvent/HiSysEventUtil';
import { HiSysRdbEventGroup } from '../systemEvent/BehaviorEventConsts';
import { DeviceUsageHistory, DEVICE_USAGE_HISTORY_TABLE } from './DeviceUsageDataType';

const TAG: string = 'BatteryLineDataManager:';
const POWER_DATA_LINE_LOADING: string = 'PowerDataLineLoading';
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

export class BatteryHistoryManager extends DatabaseManager {
  public rdbStore: relationalStore.RdbStore | undefined;

  /**
   * 获取关系数据库存储对象
   * 如果已初始化过，则直接返回之前获取的对象
   * 如果没有初始化过，则使用接口获取对象，并执行数据库建表命令，如果表未创建，则会创建一张新的表
   *
   * @return 关系数据库存储对象
   */
  async getRdb(context:common.Context): Promise<relationalStore.RdbStore> {
    if (this.rdbStore) {
      return this.rdbStore;
    }
    try {
      LogUtil.info(`${TAG} getRdbStore start.`);
      let rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
      await rdbStore.executeSql(SQL_CREATE_BATTERYHISTORY_TABLE);
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
   * 电池折线图数据库 - 插入数据
   */
  async batchInsertBatteryHistoryData(context: common.Context,
                                      itemInfoList?: relationalStore.ValuesBucket[]): Promise<void> {
    if (itemInfoList) {
      const rdbStore = await this.getRdb(context);
      let transaction: relationalStore.Transaction | undefined = undefined;
      try {
        transaction = await rdbStore.createTransaction();
        if (transaction) {
          const predicates = new relationalStore.RdbPredicates(BATTERYHISTORY_TABLE);
          LogUtil.info(`${TAG} deleteBatteryHistoryData start.`);
          // 先删除保证时序
          let deleteNum: number = await transaction.delete(predicates);
          LogUtil.info(`${TAG} batchInsertBatteryHistoryData start. deleted num: ${deleteNum}, need insert num:${itemInfoList?.length}`);
          let insertNum: number = await transaction.batchInsert(BATTERYHISTORY_TABLE, itemInfoList);
          LogUtil.info(`${TAG} batchInsertBatteryHistoryData success, insertNum: ${insertNum}`);
          await transaction.commit();
          LogUtil.info(`${TAG} commit line data success`);
          this.sendLineChartRefresh();
        }
      } catch (error) {
        LogUtil.error(`${TAG} batchInsertBatteryHistoryData error. code:${error?.code} message:${error?.message}`);
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
   * 电池折线图数据库 - 查询所有数据
   */
  async queryBatteryHistoryData(context: common.Context): Promise<BatteryHistory[]> {
    const rdbStore = await this.getRdb(context);
    let batteryHistoryList: BatteryHistory[] = [];
    let resultSet: relationalStore.ResultSet | undefined;
    try {
      const predicates = new relationalStore.RdbPredicates(BATTERYHISTORY_TABLE);
      predicates.orderByDesc('timestamp');
      LogUtil.info(`${TAG} queryBatteryHistoryData start.`);
      resultSet = await rdbStore.query(predicates);
      LogUtil.info(`${TAG} queryBatteryHistoryData success. resultSet.rowCount:${resultSet?.rowCount}`);
      while (resultSet.goToNextRow()) {
        const timestamp = resultSet.getLong(resultSet.getColumnIndex('timestamp'));
        const charge = resultSet.getLong(resultSet.getColumnIndex('charge'));
        const percentage = resultSet.getLong(resultSet.getColumnIndex('percentage'));
        batteryHistoryList.push({
          timestamp,
          percentage,
          charge,
        });
      }
    } catch (error) {
      LogUtil.error(`${TAG} queryBatteryHistoryData error. code:${error?.code} message:${error?.message}`);
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
   * 通知电池折线图重新查数据库来刷新数据
   */
  sendLineChartRefresh(): void {
    try {
      commonEventManager.publish(POWER_DATA_LINE_LOADING, (error: BusinessError) => {});
    } catch (error) {
      LogUtil.error(`commonEventManager createSubscriber error: ${error?.message}`);
    }
  }
}

export default new BatteryHistoryManager();