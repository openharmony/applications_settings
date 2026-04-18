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

import type common from '@ohos.app.ability.common';
import relationalStore from '@ohos.data.relationalStore';
import i18n from '@ohos.i18n';
import { LogUtil } from '../utils/LogUtil';
import DatabaseManager from './DatabaseManager';
import {
  ItemInfo,
  ITEMINFO_TABLE,
  SQL_CREATE_ITEMINFO_TABLE,
  SQL_UPDATE_ITEM_INFO,
  ENABLED_TRUE,
  ENABLED_FALSE,
  SQL_DELETE_ITEM_INFO_TABLE,
} from './types';
import { HiSysEventUtil } from '../systemEvent/HiSysEventUtil';
import { CheckEmptyUtils } from '../utils/CheckEmptyUtils';
import { RdbTaskPool } from '../rdb/RdbTaskPool';
import { HiSysRdbEventGroup } from '../systemEvent/BehaviorEventConsts';


const TAG: string = 'SearchItemInfoManager';
const RDB_CORRUPTION_ERROR_CODE: number = 14800011;

export class SearchItemInfoManager extends DatabaseManager {
  /**
   * 获取关系数据库存储对象
   * 如果已初始化过，则直接返回之前获取的对象
   * 如果没有初始化过，则使用接口获取对象，并执行数据库建表命令，如果表未创建，则会创建一张新的表
   *
   * @return 关系数据库存储对象
   */
  async getRdbStore(): Promise<relationalStore.RdbStore> {
    const rdbStore = await super.getRdbStore(SQL_CREATE_ITEMINFO_TABLE);
    return rdbStore;
  }

  async batchInsertSearchItemData(itemInfoList: Array<ItemInfo>, hideSearchItems: Array<string>,
    context?: common.Context): Promise<void> {
    try {
      LogUtil.info(`${TAG} start batchInsertSearchItemData`);
      let searchItemInfos: relationalStore.ValuesBucket[] = [];
      itemInfoList.forEach((itemInfo) => {
        if (hideSearchItems && !hideSearchItems.includes(itemInfo.itemName)) {
          LogUtil.info(`${TAG} insert search item name:${itemInfo.itemName} enable: ${itemInfo.enable}`);
          searchItemInfos.push(this.getDbBucketList(itemInfo));
        }
      })
      LogUtil.info(`${TAG} batchInsertSearchItemData beginTransaction searchItemInfos size:${searchItemInfos.length}`);
      let result = await RdbTaskPool.getInstance().batchInsert(ITEMINFO_TABLE, searchItemInfos, context);
      LogUtil.info(`${TAG} batchInsertSearchItemData result: ${result}`);
      HiSysEventUtil.searchReportEvent(TAG, 'batchInsertSearchItemData success');
    } catch (error) {
      LogUtil.error(`${TAG} batchInsertSearchItemData error: ${error?.message}`);
      HiSysEventUtil.searchReportEvent(TAG, `batchInsertSearchItemData error: ${JSON.stringify(error)}`);
    }
  }

  private getDbBucketList(itemInfo: ItemInfo): relationalStore.ValuesBucket {
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
      'checkValue': itemInfo.checkValue
    }
  }

  async removeSearchItem(entryKey: string[]): Promise<void> {
    const rdbStore = await this.getRdbStore();
    try {
      rdbStore.beginTransaction();
      const predicates = new relationalStore.RdbPredicates(ITEMINFO_TABLE);
      predicates.in('entryKey', entryKey);
      await rdbStore.delete(predicates);
      rdbStore.commit();
      LogUtil.info(`${TAG} removeSearchItem successfully.`);
      HiSysEventUtil.searchReportEvent(TAG, 'removeSearchItem success');
    } catch (error) {
      LogUtil.error(`${TAG} removeSearchItem failed, message: ${error?.message}, code: ${error.code}`);
      HiSysEventUtil.searchReportEvent(TAG, `removeSearchItem error: ${JSON.stringify(error)}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
      rdbStore.rollBack();
    }
  }

  async removeSearchItemByEntryKey(entryKey: string): Promise<void> {
    const rdbStore = await this.getRdbStore();
    try {
      rdbStore.beginTransaction();
      const predicates = new relationalStore.RdbPredicates(ITEMINFO_TABLE);
      predicates.equalTo('entryKey', entryKey);
      await rdbStore.delete(predicates);
      rdbStore.commit();
      LogUtil.info(`${TAG} removeSearchItemByEntryKey successfully.`);
      HiSysEventUtil.searchReportEvent(TAG, 'removeSearchItemByEntryKey success');
    } catch (error) {
      LogUtil.error(`${TAG} removeSearchItemByEntryKey failed, message: ${error?.message}, code: ${error?.code}`);
      HiSysEventUtil.searchReportEvent(TAG, `removeSearchItemByEntryKey error: ${JSON.stringify(error)}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
      rdbStore.rollBack();
    }
  }

  async updateSearchItemData(): Promise<void> {
    const rdbStore = await this.getRdbStore();
    try {
      LogUtil.info(`${TAG} start updateSearchItemData`);
      rdbStore.beginTransaction();
      await rdbStore.executeSql(SQL_UPDATE_ITEM_INFO);
      rdbStore.commit();
      LogUtil.info(`${TAG} updateSearchItemData success`);
      HiSysEventUtil.searchReportEvent(TAG, 'updateSearchItemData success');
    } catch (error) {
      LogUtil.error(`${TAG} updateSearchItemData error, message: ${error?.message}, code: ${error?.code}`);
      HiSysEventUtil.searchReportEvent(TAG, `updateSearchItemData error: ${JSON.stringify(error)}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
      rdbStore.rollBack();
    }
  }

  async clearSearchData(): Promise<void> {
    const rdbStore = await this.getRdbStore();
    try {
      await rdbStore.executeSql(SQL_DELETE_ITEM_INFO_TABLE);
      LogUtil.info(`${TAG} clearSearchData successfully.`);
      HiSysEventUtil.searchReportEvent(TAG, 'ClearSearchData success');
    } catch (error) {
      LogUtil.error(`${TAG} clearSearchata failed, message: ${error?.message}, code: ${error?.code}`);
      HiSysEventUtil.searchReportEvent(TAG, `clearSearchData error: ${JSON.stringify(error)}`)
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
      rdbStore.rollBack();
    }
  }

  async updateSearchItem(itemName: string, enable: boolean): Promise<void> {
    if (CheckEmptyUtils.checkStrIsEmpty(itemName)) {
      LogUtil.showError(TAG, 'updateSearchItem error, itemName is empty');
      return;
    }

    try {
      let valuesBucket: relationalStore.ValuesBucket = {
        'enable': enable ? ENABLED_TRUE : ENABLED_FALSE
      };

      let conditions: Map<string, relationalStore.ValueType> = new Map();
      conditions.set('itemName', itemName);
      let result = await RdbTaskPool.getInstance().update(ITEMINFO_TABLE, conditions, valuesBucket);
      LogUtil.showInfo(TAG, `search item updated changeRows: ${result}, itemName: ${itemName}, enable: ${enable}`);
    } catch (err) {
      LogUtil.showError(TAG, `updateSearchItem error: ${err?.message}`);
    }
  }

  async updateSearchEntry(entryKey: string, enable: boolean): Promise<void> {
    if (CheckEmptyUtils.checkStrIsEmpty(entryKey)) {
      LogUtil.showError(TAG, 'updateSearchEntry error, entryKey is empty');
      return;
    }

    try {
      let valuesBucket: relationalStore.ValuesBucket = {
        'enable': enable ? ENABLED_TRUE : ENABLED_FALSE
      };

      let conditions: Map<string, relationalStore.ValueType> = new Map();
      conditions.set('entryKey', entryKey);
      let result = await RdbTaskPool.getInstance().update(ITEMINFO_TABLE, conditions, valuesBucket);
      LogUtil.showInfo(TAG, `search item updated changeRows: ${result}, entryKey: ${entryKey}, enable: ${enable}`);
    } catch (err) {
      LogUtil.showError(TAG, `updateSearchItem error: ${err?.message}`);
    }
  }

  /* instrument ignore next */
  async updateSearchItemByBundle(bundleName: string, enable: boolean): Promise<void> {
    if (CheckEmptyUtils.checkStrIsEmpty(bundleName)) {
      LogUtil.showError(TAG, 'updateSearchItemByBundle error, bundleName is empty');
      return;
    }

    try {
      let valuesBucket: relationalStore.ValuesBucket = {
        'enable': enable ? ENABLED_TRUE : ENABLED_FALSE
      };
      let conditions: Map<string, relationalStore.ValueType> = new Map();
      conditions.set('bundleName', bundleName);
      let result = await RdbTaskPool.getInstance().update(ITEMINFO_TABLE, conditions, valuesBucket);
      LogUtil.showDebug(TAG, `search item updated bundle: ${bundleName} changeRows: ${result}`);
    } catch (error) {
      LogUtil.showError(TAG, `updateSearchItemByBundle error, message: ${error?.message}, code: ${error?.code}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
    }
  }

  async upgradeDb(upgradeSqlList: string[], latestRdbVersion: number): Promise<void> {
    const rdbStore = await this.getRdbStore();
    try {
      rdbStore.beginTransaction();
      for (const element of upgradeSqlList) {
        await rdbStore.executeSql(element);
      }
      rdbStore.commit();
      rdbStore.version = latestRdbVersion;
      LogUtil.showInfo(TAG, `upgrade db success, newest version : ${rdbStore.version}`);
    } catch (error) {
      LogUtil.showError(TAG, `upgrade db failed, message: ${error?.message}, code: ${error?.code}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
      rdbStore.rollBack();
    }
  }

  async queryChildItems(itemName: string): Promise<string[]> {
    if (CheckEmptyUtils.checkStrIsEmpty(itemName)) {
      LogUtil.showError(TAG, 'queryChildItems error, itemName is empty');
      return [];
    }

    let result: string = '';
    try {
      let conditions: Map<string, relationalStore.ValueType> = new Map();
      conditions.set('itemName', itemName);
      result = await RdbTaskPool.getInstance().queryChildItems(ITEMINFO_TABLE, conditions);
      LogUtil.showDebug(TAG, `queryChildItems result: ${result}`);
    } catch (err) {
      LogUtil.showError(TAG, `queryChildItems error: ${err?.message}`);
      return [];
    }

    return result.split(',');
  }

  /* instrument ignore next */
  async deleteSearchItem(locale: string): Promise<void> {
    if (CheckEmptyUtils.checkStrIsEmpty(locale)) {
      LogUtil.showError(TAG, 'deleteSearchItem error, locale is empty');
      return;
    }

    const rdbStore = await this.getRdbStore();
    try {
      rdbStore.beginTransaction();
      const predicates = new relationalStore.RdbPredicates(ITEMINFO_TABLE);
      predicates.equalTo('locale', locale);
      let result = await rdbStore.delete(predicates);
      rdbStore.commit();
      LogUtil.showInfo(TAG, `delete search item: ${locale} changeRows: ${result}`);
    } catch (error) {
      LogUtil.showError(TAG,
        `deleteSearchItem error, message: ${error?.message}, code: ${error?.code}, ${RDB_CORRUPTION_ERROR_CODE}, ${error?.code ===
          RDB_CORRUPTION_ERROR_CODE}}`);
      if (error?.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
      rdbStore.rollBack();
    }
  }

  /**
   * 查询搜索项的配置表
   * @param itemName 配置项
   * @param bundleName 包名
   * @returns 详情
   */
  async querySearchItemData(itemName: string[], bundleName?: string): Promise<ItemInfo[]> {
    const rdbStore = await this.getRdbStore();
    let itemInfoList: ItemInfo[] = [];
    let resultSet: relationalStore.ResultSet | undefined;
    try {
      const predicates = new relationalStore.RdbPredicates(ITEMINFO_TABLE);
      let curLocale: string = i18n.System.getSystemLocale();
      predicates.equalTo('locale', curLocale).and().in('itemName', itemName);
      if (bundleName) {
        predicates.and().equalTo('bundleName', bundleName);
      }
      resultSet = await rdbStore.query(predicates);
      while (resultSet?.goToNextRow()) {
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
        itemInfoList.push({
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
        });
      }
      return itemInfoList;
    } catch (error) {
      LogUtil.error(`${TAG} query querySearchItemData message: ${error?.message}, code: ${error?.code}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        await super.restoreRdb();
      }
      return itemInfoList;
    } finally {
      resultSet?.close();
    }
  }

  /* instrument ignore next */
  async insertOrUpdateSearchItemData(itemInfo: ItemInfo): Promise<void> {
    const rdbStore = await this.getRdbStore();
    if (itemInfo) {
      let resultSet: relationalStore.ResultSet | undefined;
      try {
        const predicates = new relationalStore.RdbPredicates(ITEMINFO_TABLE);
        predicates.equalTo('itemName', itemInfo.itemName).and()
          .equalTo('locale', itemInfo.locale)
          .and().equalTo('bundleName', itemInfo.bundleName);
        resultSet = await rdbStore.query(predicates);
        if (resultSet.rowCount) {
          await rdbStore.update(this.getDbBucketList(itemInfo), predicates);
          LogUtil.info(`${TAG} insertOrUpdateSearchItemData success`);
          return;
        }
        let result: number = await rdbStore.insert(ITEMINFO_TABLE, this.getDbBucketList(itemInfo));
        LogUtil.info(`${TAG} insertOrUpdateSearchItemData result: ${result}`);
      } catch (error) {
        LogUtil.error(`${TAG} insertSearchHistoryData message: ${error?.message}, code: ${error?.code}`);
        if (error.code === RDB_CORRUPTION_ERROR_CODE) {
          await super.restoreRdb();
        }
      } finally {
        resultSet?.close();
      }
    }
  }
}

export default new SearchItemInfoManager();