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

import Settings from '@ohos.settings';
import dataShare from '@ohos.data.dataShare';
import taskpool from '@ohos.taskpool';
import type common from '@ohos.app.ability.common';
import osAccount from '@ohos.account.osAccount';
import type { AsyncCallback, BusinessError } from '@ohos.base';
import { LogUtil } from './LogUtil';
import { CheckEmptyUtils } from './CheckEmptyUtils';
import { StringUtil } from './StringUtil';
import { AbilityContextManager } from '../ability/AbilityContextManager';
import dataSharePredicates from '@ohos.data.dataSharePredicates';
import DataShareResultSet from '@ohos.data.DataShareResultSet';

const TAG = 'SettingsDataUtils : ';

export interface queryDataListParm {
  userId : number,
  key : string,
  defaultValue : string,
  length : number
}

function getValueSync(key: string, defaultValue: string, domain: string, context: common.Context): string {
  'use concurrent';
  if (domain) {
    return Settings.getValueSync(context, key, defaultValue ?? '', domain);
  }
  return Settings.getValueSync(context, key, defaultValue ?? '');
}

function setValueSync(key: string, value: string, domain: string, context: common.Context): void {
  'use concurrent';
  if (domain) {
    Settings.setValueSync(context, key, value ?? '', domain);
  }
  Settings.setValueSync(context, key, value ?? '');
}

/**
 * 设置数据库工具类
 *
 * @since 2022-06-29
 */
export class SettingsDataUtils {
  public static readonly settingsDataUrl = 'datashare:///com.ohos.settingsdata/entry/settingsdata/SETTINGSDATA?Proxy=true&key=';
  public static readonly settingsDataUserUrl = 'datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_';
  public static readonly settingsDataUserSecurityUrl = 'datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_SECURE_';

  static getSettingsData(key: string, defaultValue: string, domain: string = null): string {
    if (StringUtil.isEmpty(key)) {
      LogUtil.warn(`${TAG} getSettingsData ${key} invalid`);
      return '';
    }
    let context: common.Context | undefined = SettingsDataUtils.getContext();
    if (CheckEmptyUtils.isEmpty(context)) {
      LogUtil.error(`${TAG} getSettingsData ${key} failed, context is undefined`);
      return defaultValue ?? '';
    }
    try {
      if (domain) {
        return Settings.getValueSync(context, key, defaultValue ?? '', domain);
      }
      return Settings.getValueSync(context, key, defaultValue ?? '');
    } catch (error) {
      LogUtil.error(`${TAG} getValueSync ${key} failed, ${error?.message}`);
    }
    return defaultValue ?? '';
  }

  static getSettingsDataWithContext(context: common.Context, key: string, defaultValue: string,
    domain: string = null): string {
    if (StringUtil.isEmpty(key)) {
      LogUtil.warn(`${TAG} getSettingsData ${key} invalid`);
      return '';
    }
    if (CheckEmptyUtils.isEmpty(context)) {
      LogUtil.error(`${TAG} getSettingsData ${key} failed, context is undefined`);
      return defaultValue ?? '';
    }
    if (domain) {
      return Settings.getValueSync(context, key, defaultValue ?? '', domain);
    }
    return Settings.getValueSync(context, key, defaultValue ?? '');
  }

  private static getDataShareResultSetCallback(queryDataListParm : queryDataListParm,
    resultValueMaps : Map<number, Map<string, string>>,
    callback: (valueMaps: Map<string, string>) => void) : AsyncCallback<DataShareResultSet> {
    try {
      const dataShareResultSetCallback : AsyncCallback<DataShareResultSet> = (dataShareResultSetErr : BusinessError,
        dataShareResultSet: DataShareResultSet) => {
        if (dataShareResultSetErr) {
          LogUtil.error(`${TAG} dataShareResultSet fail`);
          return;
        }
        const index = 0;
        dataShareResultSet.goToRow(index);
        let targetString: string = dataShareResultSet.getString(index) ?? queryDataListParm.defaultValue;
        LogUtil.info(`userId:${queryDataListParm.userId} get ${queryDataListParm.key} : ${targetString}`);
        resultValueMaps.get(queryDataListParm.userId)?.set(queryDataListParm.key, targetString);
        if (resultValueMaps.get(queryDataListParm.userId)?.size === queryDataListParm.length) {
          callback(resultValueMaps.get(queryDataListParm.userId));
        }
        const isDataShareClosed: boolean = dataShareResultSet.isClosed;
        if (!isDataShareClosed) {
          LogUtil.info(`${TAG} close dataShareHelper`);
          dataShareResultSet.close();
        }
      };
      return dataShareResultSetCallback;
    } catch (e) {
      LogUtil.error(`${TAG} getDataShareResultSetCallback error: ${(e as BusinessError).code}`);
      callback(resultValueMaps.get(queryDataListParm.userId));
      return null;
    }
  }

  public static getSettingsDataWithUserId(context: Context, userId: number, defaultData : Map<string, string>,
    callback: (valueMaps: Map<string, string>) => void): void {
    LogUtil.error(`${TAG} getSettingsDataWithUserId start`);
    const uri = SettingsDataUtils.settingsDataUserSecurityUrl + userId + '?Proxy=true';
    let resultValueMaps = new Map<number, Map<string, string>>();
    resultValueMaps.set(userId, new Map<string, string>());
    try {
      const createDataShareHelperCallBack : AsyncCallback<dataShare.DataShareHelper> =
        (err, dataShareHelper: dataShare.DataShareHelper) => {
          if (err) {
            LogUtil.error(`${TAG} dataShareGetValue err.message:${err.message} err.code:${err.code}`);
            return;
          }
          for (let [key, defaultValue] of defaultData) {
            const predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
            const SETTING_COLUMN_KEYWORD = 'KEYWORD';
            predicates.equalTo(SETTING_COLUMN_KEYWORD, key);
            const columns = ['VALUE'];
            const queryDataListParm : queryDataListParm = {
              userId : userId,
              key : key,
              defaultValue : defaultValue,
              length : defaultData.size
            };
            const dataShareResultSetCallback : AsyncCallback<DataShareResultSet> =
              SettingsDataUtils.getDataShareResultSetCallback(queryDataListParm, resultValueMaps, callback);
            dataShareHelper.query(uri, predicates, columns, dataShareResultSetCallback);
          }
        };
      if (createDataShareHelperCallBack === null) {
        callback(resultValueMaps.get(userId));
        return;
      }
      dataShare.createDataShareHelper(context, uri, createDataShareHelperCallBack);
    } catch (e) {
      callback(resultValueMaps.get(userId));
      LogUtil.error(`${TAG} getSettingsDataWithUserId error: ${(e as BusinessError).code}`);
    }
  }

  static getSecureValue(key: string, defaultValue: string): string {
    return SettingsDataUtils.getSettingsData(key, defaultValue, Settings.domainName.USER_SECURITY);
  }

  static async getSettingsDataAsync(key: string, defaultValue: string, domain: string = null): Promise<string> {
    if (!key) {
      LogUtil.warn(`${TAG} getSettingsDataAsync ${key} invalid`);
      return '';
    }
    let context: common.Context | undefined = SettingsDataUtils.getContext();
    if (CheckEmptyUtils.isEmpty(context)) {
      LogUtil.error(`${TAG} getSettingsData ${key} failed, context is undefined`);
      return defaultValue ?? '';
    }
    return String(await SettingsDataUtils.doTask(getValueSync, key, defaultValue, domain));
  }

  static setSettingsData(key: string, value: string, domain: string = null): boolean {
    if (StringUtil.isEmpty(key)) {
      LogUtil.warn(`${TAG} setSettingsData ${key} invalid`);
      return false;
    }
    let context: common.Context | undefined = SettingsDataUtils.getContext();
    if (CheckEmptyUtils.isEmpty(context)) {
      LogUtil.error(`${TAG} setSettingsData ${key} failed, context is undefined`);
      return false;
    }
    LogUtil.info(`${TAG} setSettingsData key: ${key}---${value}----${domain}`);
    try {
      if (domain) {
        return Settings.setValueSync(context, key, value ?? '', domain);
      } else {
        return Settings.setValueSync(context, key, value ?? '');
      }
    } catch (e) {
      LogUtil.error(`${TAG} setSettingsData ${key} error: ${e?.code}`);
      return false;
    }
  }

  static setSettingsDataAsync(key: string, value: string, domain: string = null): void {
    if (StringUtil.isEmpty(key)) {
      LogUtil.warn(`${TAG} setSettingsDataAsync ${key} invalid`);
      return;
    }
    SettingsDataUtils.setSettingsDataAsyncWithContext(SettingsDataUtils.getContext(), key, value ?? '', domain);
  }

  static setSettingsDataAsyncWithContext(context: common.Context, key: string, value: string,
    domain: string = null): void {
    if (StringUtil.isEmpty(key)) {
      LogUtil.warn(`${TAG} setValue ${key} invalid`);
      return;
    }
    if (CheckEmptyUtils.isEmpty(context)) {
      LogUtil.warn(`${TAG} setValue ${key} context invalid`);
      return;
    }

    LogUtil.info(`${TAG} setSettingsDataAsync key: ${key}, value: ${value}`);
    if (domain) {
      Settings.setValue(context, key, value ?? '', domain);
    } else {
      Settings.setValue(context, key, value ?? '');
    }
  }

  static setSecureValue(key: string, value: string): void {
    SettingsDataUtils.setSettingsData(key, value, Settings.domainName.USER_SECURITY);
  }

  static setSettingsDataDomain(key: string, value: string, domainName: string): void {
    SettingsDataUtils.setSettingsData(key, value, domainName);
  }

  static getSettingsDataDomain(key: string, defaultValue: string, domainName: string): string {
    return SettingsDataUtils.getSettingsData(key, defaultValue, domainName);
  }

  static registerKeyObserver(key: string, observer: AsyncCallback<void>): boolean {
    try {
      return Settings.registerKeyObserver(SettingsDataUtils.getContext(), key,
        Settings.domainName.DEVICE_SHARED, observer);
    } catch (e) {
      LogUtil.warn(`${TAG} Settings ${key} registerKeyObserver err`);
      return false;
    }
  }

  static unregisterKeyObserver(key: string): boolean {
    return Settings.unregisterKeyObserver(SettingsDataUtils.getContext(), key, Settings.domainName.DEVICE_SHARED);
  }

  static registerKeyObserverUser(key: string, observer: AsyncCallback<void>): boolean {
    try {
      return Settings.registerKeyObserver(SettingsDataUtils.getContext(), key,
        Settings.domainName.USER_PROPERTY, observer);
    } catch (e) {
      LogUtil.warn(`${TAG} Settings ${key} registerKeyObserver err`);
      return false;
    }
  }

  static unregisterKeyObserverUser(key: string): boolean {
    return Settings.unregisterKeyObserver(SettingsDataUtils.getContext(), key, Settings.domainName.USER_PROPERTY);
  }

  static registerKeyObserverWithDomain(key: string, domainName: string, observer: AsyncCallback<void>): boolean {
    return Settings.registerKeyObserver(SettingsDataUtils.getContext(), key, domainName, observer);
  }

  static unregisterKeyObserverWithDomain(key: string, domainName: string): boolean {
    return Settings.unregisterKeyObserver(SettingsDataUtils.getContext(), key, domainName);
  }

  static registerKeyObserverWithDomainAndContext(context: common.Context, key: string, domainName: string,
    observer: AsyncCallback<void>): boolean {
    if (CheckEmptyUtils.isEmpty(context)) {
      LogUtil.error(`${TAG} registerKeyObserverWithDomainAndContext ${key} failed, context is undefined`);
      return false;
    }

    return Settings.registerKeyObserver(context, key, domainName, observer);
  }

  static unregisterKeyObserverWithDomainAndContext(context: common.Context, key: string, domainName: string): boolean {
    if (CheckEmptyUtils.isEmpty(context)) {
      LogUtil.error(`${TAG} unregisterKeyObserverWithDomainAndContext ${key} failed, context is undefined`);
      return false;
    }

    return Settings.unregisterKeyObserver(context, key, domainName);
  }

  static getSupport(key: string, value: string): void {
    SettingsDataUtils.setSettingsData(key, value);
  }

  static getSettingsUri(key: string): string {
    if (!key) {
      LogUtil.warn(TAG + 'getSettingsUri key invalid');
      return '';
    }
    return SettingsDataUtils.settingsDataUrl + key;
  }

  static async getSettingsSecurityUri(key: string): Promise<string> {
    try {
      let accountManager: osAccount.AccountManager = osAccount.getAccountManager();
      let id: number = await accountManager.getOsAccountLocalId();
      let url =
        `datashare:///com.ohos.settingsdata/entry/settingsdata/USER_SETTINGSDATA_SECURE_${id}?Proxy=true&key=${key}`;
      return url;
    } catch (err) {
      LogUtil.error(`${TAG} key: ${key} getOsAccountLocalId fail: ${err?.code}`);
      return '';
    }
  }

  static async getSettingsUserUri(key: string): Promise<string> {
    try {
      let accountManager: osAccount.AccountManager = osAccount.getAccountManager();
      let id: number = await accountManager.getOsAccountLocalId();
      let url: string = `${SettingsDataUtils.settingsDataUserUrl}${id}?Proxy=true&key=${key}`;
      return url;
    } catch (err) {
      LogUtil.error(`${TAG} getOsAccountLocalId ${key} fail: ${err?.code}`);
      return '';
    }
  }

  static registerDataChange(dataHelper: dataShare.DataShareHelper, key: string, onDataChange: () => void): void {
    if (!dataHelper || !onDataChange) {
      LogUtil.warn(TAG + `registerDataChange ${key} params invalid`);
      return;
    }
    let uri = this.getSettingsUri(key);
    if (!uri) {
      LogUtil.error(TAG + `registerDataChange ${key} uri invalid`);
      return;
    }
    dataHelper.on('dataChange', uri, onDataChange);
  }

  static unRegisterDataChange(dataHelper: dataShare.DataShareHelper, key: string, offDataChange?: () => void): void {
    if (!dataHelper) {
      LogUtil.warn(TAG + `unRegisterDataChange ${key} params invalid`);
      return;
    }
    let uri = this.getSettingsUri(key);
    if (!uri) {
      LogUtil.error(TAG + `unRegisterDataChange ${key} uri invalid`);
      return;
    }
    if (offDataChange) {
      dataHelper.off('dataChange', uri, offDataChange);
    } else {
      dataHelper.off('dataChange', uri);
    }
  }

  static async createSecurityDataHelper(key: string): Promise<dataShare.DataShareHelper> | undefined {
    let uri = await this.getSettingsSecurityUri(key);
    if (!uri) {
      LogUtil.error(TAG + `createDataHelper ${key} uri invalid`);
      return undefined;
    }
    let pageContext: common.Context | undefined = SettingsDataUtils.getContext();

    if (pageContext !== undefined) {
      return dataShare.createDataShareHelper(pageContext, uri);
    }
    return undefined;
  }

  static registerSecurityDataChange(dataHelper: dataShare.DataShareHelper, key: string,
    onDataChange: () => void): Promise<void> {
    if (!dataHelper || !onDataChange) {
      LogUtil.warn(`${TAG}  registerDataChange ${key} params invalid`);
      return;
    }
    this.getSettingsSecurityUri(key)
      .then((uri) => {
        dataHelper.on('dataChange', uri, onDataChange);
      });
  }

  static unRegisterSecurityDataChange(dataHelper: dataShare.DataShareHelper, key: string,
    offDataChange?: () => void): Promise<void> {
    if (!dataHelper) {
      LogUtil.warn(`${TAG}  unRegisterSecurityDataChange ${key} params invalid`);
      return;
    }
    this.getSettingsSecurityUri(key)
      .then((uri) => {
        if (offDataChange) {
          dataHelper.off('dataChange', uri, offDataChange);
        } else {
          dataHelper.off('dataChange', uri);
        }
      });
  }

  static registerUserDataChange(dataHelper: dataShare.DataShareHelper, key: string, onDataChange: () => void): void {
    if (!dataHelper || !onDataChange) {
      LogUtil.warn(`${TAG} registerDataChange ${key} params invalid`);
      return;
    }
    this.getSettingsUserUri(key)
      .then((uri) => {
        dataHelper.on('dataChange', uri, onDataChange);
      });
  }

  static unRegisterUserDataChange(dataHelper: dataShare.DataShareHelper, key: string,
    offDataChange?: () => void): void {
    if (!dataHelper) {
      LogUtil.warn(`${TAG} unRegisterSecurityDataChange ${key} params invalid`);
      return;
    }
    this.getSettingsUserUri(key)
      .then((uri) => {
        if (offDataChange) {
          dataHelper.off('dataChange', uri, offDataChange);
        } else {
          dataHelper.off('dataChange', uri);
        }
      });
  }

  static createDataHelper(key: string): Promise<dataShare.DataShareHelper> | undefined {
    let uri = this.getSettingsUri(key);
    if (!uri) {
      LogUtil.error(TAG + `createDataHelper ${key} uri invalid`);
      return undefined;
    }
    let pageContext: common.Context | undefined = SettingsDataUtils.getContext();

    if (pageContext !== undefined) {
      return dataShare.createDataShareHelper(pageContext, uri);
    }
    return undefined;
  }

  private static async doTask(func: Function, ...args: unknown[]): Promise<unknown> {
    try {
      let context: common.Context = SettingsDataUtils.getContext();
      args.push(context);
      const dbTask = new taskpool.Task(func, ...args);
      return await taskpool.execute(dbTask);
    } catch (err) {
      LogUtil.showError(TAG, `doTask error when execute ${func.name}, ${err?.message}`);
    }

    return undefined;
  }

  public static getContext(): common.Context {
    let context = AbilityContextManager.getContext();
    if (CheckEmptyUtils.isEmpty(context)) {
      context = AbilityContextManager.getExtContext();
    }
    if (CheckEmptyUtils.isEmpty(context)) {
      context = AbilityContextManager.getBackgroundIntentContext();
    }
    if (CheckEmptyUtils.isEmpty(context)) {
      context = AbilityContextManager.getStageContext();
      LogUtil.showWarn(TAG, `get stage context`);
    }
    return context;
  }

  static setSettingsDataWithContext(context: common.Context, key: string, value: string, domain: string = null): void {
    if (StringUtil.isEmpty(key) || !context) {
      LogUtil.warn(`${TAG} setSettingsDataWithContext ${key} invalid or context is empty`);
      return;
    }
    LogUtil.info(`${TAG} setSettingsDataWithContext key: ${key}`);
    if (domain) {
      Settings.setValueSync(context, key, value ?? '', domain);
    } else {
      Settings.setValueSync(context, key, value ?? '');
    }
  }
}
