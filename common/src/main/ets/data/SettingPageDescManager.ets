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
import { LogUtil } from '../utils/LogUtil';
import DatabaseManager from './DatabaseManager';
import {
  ISVISIBLE_FALSE,
  ISVISIBLE_TRUE,
  PageInfo,
  PAGEINFO_TABLE,
  SQL_CREATE_PAGEINFO_TABLE,
  SQL_DELETE_PAGEINFO_TABLE
} from './types';
import { HiSysEventUtil } from '../systemEvent/HiSysEventUtil';
import { RdbTaskPool } from '../rdb/RdbTaskPool';
import { HiSysRdbEventGroup } from '../systemEvent/BehaviorEventConsts';

const TAG: string = 'SettingPageDescManager';
const RDB_CORRUPTION_ERROR_CODE: number = 14800011;

export class SettingPageDescManager extends DatabaseManager {
  /**
   * 获取关系数据库存储对象
   * 如果已初始化过，则直接返回之前获取的对象
   * 如果没有初始化过，则使用接口获取对象，并执行数据库建表命令，如果表未创建，则会创建一张新的表
   *
   * @return 关系数据库存储对象
   */
  async getRdbStore(): Promise<relationalStore.RdbStore> {
    const rdbStore = await super.getRdbStore(SQL_CREATE_PAGEINFO_TABLE);
    return rdbStore;
  }

  async clearPageInfoData(): Promise<void> {
    const rdbStore = await this.getRdbStore();
    try {
      await rdbStore.executeSql(SQL_DELETE_PAGEINFO_TABLE);
      LogUtil.info(`${TAG} clearPageinfoData successfully.`);
      HiSysEventUtil.searchReportEvent(TAG, 'clearPageinfoData success');
    } catch (error) {
      LogUtil.error(`${TAG} clearPageinfoData failed, message: ${error?.message}, code: ${error?.code}`);
      HiSysEventUtil.searchReportEvent(TAG, `clearPageinfoData error: ${JSON.stringify(error)}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
    }
  }

  /**
   * 设置页描述信息批量插入PageInfo表
   * @return
   */
  async batchInsertPageInfoData(pageInfos: Array<PageInfo>): Promise<void> {
    try {
      LogUtil.info(`${TAG} start batchInsertPageInfoData`);
      let pageInfoList: relationalStore.ValuesBucket[] = [];
      pageInfos.forEach((pageInfo) => {
        pageInfoList.push(this.getDbBucketList(pageInfo));
      })
      LogUtil.info(`${TAG} batchInsertPageInfoData beginTransaction pageInfoList:  ${pageInfoList?.length}`);
      let result = await RdbTaskPool.getInstance().batchInsert(PAGEINFO_TABLE, pageInfoList);
      LogUtil.info(`${TAG} batchInsertPageInfoData result: ${result}`);
    } catch (error) {
      LogUtil.error(`${TAG} batchInsertPageInfoData error, message: ${error?.message}, code: ${error?.code}`);
      HiSysEventUtil.searchReportEvent(TAG, `batchInsertPageInfoData error: ${JSON.stringify(error)}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
    }
  }

  private getDbBucketList(pageInfo: PageInfo): relationalStore.ValuesBucket {
    return {
      'entryKey': pageInfo.entryKey,
      'parentKey': pageInfo.parentKey,
      'isVisible': pageInfo.isVisible ? ISVISIBLE_TRUE : ISVISIBLE_FALSE,
      'permission': pageInfo.permission,
    }
  }
}

export default new SettingPageDescManager();