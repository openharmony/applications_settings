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

import { BusinessError, systemDateTime } from '@kit.BasicServicesKit';
import { relationalStore } from '@kit.ArkData';
import DatabaseManager from './DatabaseManager';
import { LogUtil } from '../utils/LogUtil';
import { APP_INFO_TABLE, AppInfoModel, SQL_CREATE_APP_INFO_TABLE, SQL_INSERT_INSTALL_SOURCE } from './AppInfoDataType';
import { HiSysEventUtil } from '../systemEvent/HiSysEventUtil';
import { HiSysRdbEventGroup } from '../systemEvent/BehaviorEventConsts';
import { CheckEmptyUtils } from '../utils/CheckEmptyUtils';
import { DatabaseUtil } from '../utils/DatabaseUtil';

const TAG: string = 'AppInfoDataManager';
const RDB_CORRUPTION_ERROR_CODE: number = 14800011;
const TABLE_APPINFO: string = 'appInfo';
const TABLE_VERSION: number = 1;

export class AppInfoDataManager extends DatabaseManager {
  private isNeedInsertInstallSource: boolean = true;

  async getRdbStore(): Promise<relationalStore.RdbStore> {
    LogUtil.info(`${TAG} start CREATE_APPINFOENTRY_TABLE`);
    const rdbStore = await super.getRdbStore(SQL_CREATE_APP_INFO_TABLE);
    LogUtil.info(`${TAG} getRdbStore rdbStore is ${rdbStore}`);
    if (!this.isNeedInsertInstallSource) {
      return rdbStore;
    }
    this.isNeedInsertInstallSource = (DatabaseUtil.getRdbStoreVersion(TABLE_APPINFO) !== TABLE_VERSION) &&
      !await this.hasInstallSource(rdbStore);
    if (!this.isNeedInsertInstallSource) {
      return rdbStore;
    }
    LogUtil.info(`${TAG} start CREATE_APPINFOENTRY_TABLE upgradeDb`);
    this.upgradeDb(SQL_INSERT_INSTALL_SOURCE, rdbStore);
    return rdbStore;
  }

  async hasInstallSource(rdbStore: relationalStore.RdbStore): Promise<boolean> {
    let resultSet: relationalStore.ResultSet | undefined;
    try {
      LogUtil.info(`${TAG} isInsertInstallSource start.`);
      const predicates = new relationalStore.RdbPredicates(APP_INFO_TABLE);
      resultSet = await rdbStore.query(predicates);
      LogUtil.info(`${TAG} isInsertInstallSource success. resultSet.rowCount:${resultSet?.rowCount}`);
      let index: number = resultSet.getColumnIndex('installSource');
      LogUtil.info(`${TAG} isInsertInstallSource oldVersion columnIndex: ${index}`);
      return index >= 0;
    } catch (error) {
      LogUtil.error(`${TAG} isInsertInstallSource error. code:${error?.code} message:${error?.message}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
    } finally {
      if (resultSet) {
        resultSet.close();
      }
    }
    return false;
  }

  async upgradeDb(upgradeSql: string, rdbStore: relationalStore.RdbStore): Promise<void> {
    try {
      rdbStore.beginTransaction();
      await rdbStore.executeSql(upgradeSql);
      rdbStore.commit();
      DatabaseUtil.updateRdbStoreVersion(TABLE_APPINFO, TABLE_VERSION);
      this.isNeedInsertInstallSource = false;
      LogUtil.showInfo(TAG, `upgrade db success`);
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

  async batchInsertAppInfos(appInfoList: Array<AppInfoModel>, needClearData: boolean = false): Promise<void> {
    if (!appInfoList || appInfoList.length === 0) {
      LogUtil.error(`${TAG} batchInsertAppInfos list is empty`);
      return;
    }
    try {
      if (needClearData) {
        LogUtil.info(`${TAG} batchInsertAppInfos first`);
        await this.clearAllAppInfo();
      }
      LogUtil.info(`${TAG} batchInsertAppInfos start. length:${appInfoList?.length}`);
      let statTime: number = systemDateTime.getTime(false);
      const rdbStore: relationalStore.RdbStore = await this.getRdbStore();
      let appInfoEntries: relationalStore.ValuesBucket[] = [];
      appInfoList.forEach((itemInfo) => {
        appInfoEntries.push(this.getDbBucketList(itemInfo));
      })
      await rdbStore.batchInsert(APP_INFO_TABLE, appInfoEntries);
      let endTime: number = systemDateTime.getTime(false);
      LogUtil.info(`${TAG} batchInsertAppInfos success. cost time: ${endTime - statTime}}`);
    } catch (error) {
      LogUtil.error(`${TAG} batchInsertAppInfos error. code:${error?.code} message:${error?.message}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
    }
  }

  async insertSingleAppInfo(appInfo: AppInfoModel) {
    if (!appInfo || appInfo.bundleName === '') {
      LogUtil.error(`${TAG} insertSingleAppInfo appInfo is invalid`);
      return;
    }
    try {
      LogUtil.info(`${TAG} insertSingleAppInfo start`);
      let statTime: number = systemDateTime.getTime(false);
      const rdbStore: relationalStore.RdbStore = await this.getRdbStore();
      let appInfoModel: relationalStore.ValuesBucket = this.getDbBucketList(appInfo);
      let updateNum = await rdbStore.insert(APP_INFO_TABLE, appInfoModel);
      let endTime: number = systemDateTime.getTime(false);
      LogUtil.info(`${TAG} insertSingleAppInfo success. cost time: ${endTime -
        statTime}}, updateNum: ${updateNum}, insert bundleName:${appInfo.bundleName}`);
    } catch (error) {
      LogUtil.error(`${TAG} insertSingleAppInfo error. code:${error?.code} message:${error?.message}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
    }
  }

  async updateOrReplaceAppInfo(appInfo: AppInfoModel) {
    if (!appInfo || appInfo.bundleName === '') {
      LogUtil.error(`${TAG} updateOrReplaceAppInfo appInfo is invalid`);
      return;
    }
    try {
      LogUtil.info(`${TAG} updateOrReplaceAppInfo start`);
      let statTime: number = systemDateTime.getTime(false);
      const rdbStore: relationalStore.RdbStore = await this.getRdbStore();
      let appEntryData: relationalStore.ValuesBucket = this.getDbBucketList(appInfo);
      const predicates = new relationalStore.RdbPredicates(APP_INFO_TABLE);
      predicates.equalTo('bundleName', appInfo.bundleName);
      predicates.equalTo('appIndex', appInfo.appIndex);
      let updateCount = await rdbStore.update(appEntryData, predicates);
      let endTime: number = systemDateTime.getTime(false);
      LogUtil.info(`${TAG} updateOrReplaceAppInfo success. cost time: ${endTime -
        statTime}}, updateCount: ${updateCount}, updated bundleName:${appInfo.bundleName}`);
    } catch (error) {
      LogUtil.error(`${TAG} updateOrReplaceAppInfo error. code:${error?.code} message:${error?.message}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
    }
  }

  async deleteAppInfo(appBundleName: string, appIndex: number = 0): Promise<void> {
    if (!appBundleName) {
      LogUtil.error(`${TAG} deleteAppInfo app bundle name is empty`);
      return;
    }
    try {
      LogUtil.info(`${TAG} deleteAppInfo start, bundle name:${appBundleName}, index:${appIndex}`);
      const rdbStore: relationalStore.RdbStore = await this.getRdbStore();
      let statTime: number = systemDateTime.getTime(false);
      const predicates = new relationalStore.RdbPredicates(APP_INFO_TABLE);
      predicates.equalTo('bundleName', appBundleName);
      predicates.equalTo('appIndex', appIndex);
      let deleteCount = await rdbStore.delete(predicates);
      let endTime: number = systemDateTime.getTime(false);
      LogUtil.info(`${TAG} deleteAppInfo success. cost time: ${endTime -
        statTime}}, deleteCount: ${deleteCount}, delete bundleName:${appBundleName}`);
    } catch (error) {
      LogUtil.error(`${TAG} deleteAppInfo error. code:${error?.code} message:${error?.message}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
    }
  }

  /**
   * 查询所有数据
   */
  async queryAllAppInfo(): Promise<AppInfoModel[]> {
    let appInfoList: AppInfoModel[] = [];
    let resultSet: relationalStore.ResultSet | undefined;
    try {
      const rdbStore = await this.getRdbStore();
      LogUtil.info(`${TAG} queryAllAppInfo start.`);
      const predicates = new relationalStore.RdbPredicates(APP_INFO_TABLE);
      resultSet = await rdbStore.query(predicates);
      LogUtil.info(`${TAG} queryAllAppInfo success. resultSet.rowCount:${resultSet?.rowCount}`);
      appInfoList = this.resultSet2List(resultSet);
    } catch (error) {
      LogUtil.error(`${TAG} queryAllAppInfo error, message: ${error?.message}, code: ${error?.code}`);
      if (error.code === RDB_CORRUPTION_ERROR_CODE) {
        HiSysEventUtil.reportDefaultFaultEvent(HiSysRdbEventGroup.EVENT_NAME,
          HiSysRdbEventGroup.SETTINGS_DATA_RDB_CORRUPTION);
        await super.restoreRdb();
      }
    } finally {
      if (resultSet) {
        resultSet.close();
      }
    }
    return appInfoList;
  }

  /**
   * 组装数据库结果 resultSet 转成 list 对象
   */
  resultSet2List(resultSet: relationalStore.ResultSet): AppInfoModel[] {
    let appInfoEntryList: AppInfoModel[] = [];
    try {
      while (resultSet.goToNextRow()) {
        const queryBundleName = resultSet.getString(resultSet.getColumnIndex('bundleName'));
        if (CheckEmptyUtils.checkStrIsEmpty(queryBundleName)) {
          continue;
        }
        appInfoEntryList.push({
          bundleName: queryBundleName,
          appInfoName: resultSet.getString(resultSet.getColumnIndex('appInfoName')),
          codePath: resultSet.getString(resultSet.getColumnIndex('codePath')),
          uid: resultSet.getLong(resultSet.getColumnIndex('uid')),
          bundleType: resultSet.getLong(resultSet.getColumnIndex('bundleType')),
          systemApp: resultSet.getLong(resultSet.getColumnIndex('systemApp')) === 1,
          enabled: resultSet.getLong(resultSet.getColumnIndex('enabled')) === 1,
          dataUnclearable: resultSet.getLong(resultSet.getColumnIndex('dataUnclearable')) === 1,
          multiAppModeMaxCount: resultSet.getLong(resultSet.getColumnIndex('multiAppModeMaxCount')),
          removable: resultSet.getLong(resultSet.getColumnIndex('removable')) === 1,
          userDataClearable: resultSet.getLong(resultSet.getColumnIndex('userDataClearable')) === 1,
          label: resultSet.getString(resultSet.getColumnIndex('label')),
          labelId: resultSet.getLong(resultSet.getColumnIndex('labelId')),
          icon: resultSet.getString(resultSet.getColumnIndex('icon')),
          iconId: resultSet.getLong(resultSet.getColumnIndex('iconId')),
          appSize: resultSet.getString(resultSet.getColumnIndex('appSize')),
          cacheSize: resultSet.getString(resultSet.getColumnIndex('cacheSize')),
          dataSize: resultSet.getString(resultSet.getColumnIndex('dataSize')),
          totalSize: resultSet.getString(resultSet.getColumnIndex('totalSize')),
          versionName: resultSet.getString(resultSet.getColumnIndex('versionName')),
          updateTime: resultSet.getLong(resultSet.getColumnIndex('updateTime')),
          locale: resultSet.getString(resultSet.getColumnIndex('locale')),
          currentActivatedId: resultSet.getLong(resultSet.getColumnIndex('currentActivatedId')),
          moduleName: resultSet.getString(resultSet.getColumnIndex('moduleName')),
          appIndex: resultSet.getLong(resultSet.getColumnIndex('appIndex')),
          installSource: resultSet.getString(resultSet.getColumnIndex('installSource')),
        });
      }
      resultSet.close();
    } catch (error) {
      resultSet.close();
      LogUtil.error(`${TAG} resultSet2List error:  ${(error as BusinessError).message}`);
    }
    return appInfoEntryList;
  }

  /**
   *  清空数据
   */
  async clearAllAppInfo(): Promise<void> {
    LogUtil.info(`${TAG} clearAllAppInfo start.`);
    const rdbStore = await this.getRdbStore();
    let transaction: relationalStore.Transaction | undefined = undefined;
    try {
      transaction = await rdbStore.createTransaction();
      if (transaction) {
        const predicates = new relationalStore.RdbPredicates(APP_INFO_TABLE);
        await transaction.delete(predicates);
        await transaction.commit();
        LogUtil.info(`${TAG} clearAllAppInfo success.`);
      }
    } catch (error) {
      LogUtil.error(`${TAG} clearAllAppInfo failed, message: ${error?.message}, code: ${error?.code}`);
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

  private getDbBucketList(itemInfo: AppInfoModel): relationalStore.ValuesBucket {
    return {
      'bundleName': itemInfo.bundleName,
      'appInfoName': itemInfo.appInfoName ?? '',
      'codePath': itemInfo.codePath ?? '',
      'uid': itemInfo.uid ?? '',
      'bundleType': itemInfo.bundleType ?? '',
      'systemApp': itemInfo.systemApp ?? '',
      'enabled': itemInfo.enabled ?? '',
      'dataUnclearable': itemInfo.dataUnclearable ?? '',
      'multiAppModeMaxCount': itemInfo.multiAppModeMaxCount ?? '',
      'removable': itemInfo.removable ?? '',
      'userDataClearable': itemInfo.userDataClearable ?? '',
      'label': itemInfo.label ?? '',
      'labelId': itemInfo.labelId ?? '',
      'icon': itemInfo.icon ?? '',
      'iconId': itemInfo.iconId ?? '',
      'appSize': itemInfo.appSize ?? '',
      'cacheSize': itemInfo.cacheSize ?? '',
      'dataSize': itemInfo.dataSize ?? '',
      'totalSize': itemInfo.totalSize ?? '',
      'versionName': itemInfo.versionName,
      'updateTime': itemInfo.updateTime,
      'locale': itemInfo.locale ?? '',
      'currentActivatedId': itemInfo.currentActivatedId ?? '',
      'moduleName': itemInfo.moduleName ?? '',
      'appIndex': itemInfo.appIndex ?? '',
      'installSource': itemInfo.installSource ?? ''
    }
  }
}

export default new AppInfoDataManager();