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

// import appLock from '@hms.security.appLock';
import { taskpool } from '@kit.ArkTS';
import { systemDateTime } from '@kit.BasicServicesKit';
import bundleManager from '@ohos.bundle.bundleManager';
import launcherBundleResource from '@ohos.bundle.launcherBundleManager';
import storageStatistics from '@ohos.file.storageStatistics';
import storage from '@ohos.file.storageStatistics';
// import migrate from '@ohos.migrate';
import usageStatistics from '@ohos.resourceschedule.usageStatistics';
import { AppListLoader } from '@ohos/settings.application/src/main/ets/AppListLoader';
import { AppEntry } from '@ohos/settings.application/src/main/ets/AppModel';
import { AppUtils } from '@ohos/settings.application/src/main/ets/AppUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { DeliverUtil } from '@ohos/settings.common/src/main/ets/utils/DeliverUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import {
  DEFAULT_DATA_SIZE,
  LONGEST_UNUSED_TIME,
  MAIN_APP_INDEX,
  NoGetBundleStatsFlag,
  StorageEventConstant
} from '../constant/StorageConstant';
import { BundleStats } from '../model/BundleStats';
import { LocalBackupModel, StorageDataManager } from '../model/StorageDataManager';
import {
  getAllBundleInfoAsync,
  getLauncherBundleListAsync,
  getLockedAppsAsync,
  getUsedAppInMonthMapAsync
} from './StorageAppUtil';

/* instrument ignore file */
const TAG = 'StorageUtil'
const DAY_TIME_MILLIS: number = 1000 * 60 * 60 * 24;
export const INVALID_DATA_SIZE: number = -1;

/**
 * 存储工具类
 *
 * @since 2024-11-22
 */
export class StorageUtil {
  static async getCacheByName(packageName: string, appIndex?: number): Promise<number> {
    try {
      let bundleStats = await StorageUtil.getBundleStats(packageName, appIndex,
        NoGetBundleStatsFlag.GET_BUNDLE_WITHOUT_INSTALL_SIZE | NoGetBundleStatsFlag.GET_BUNDLE_WITHOUT_DATA_SIZE);
      LogUtil.showInfo(TAG, `packageName: ${packageName}, appIndex: ${appIndex}, cacheSize: ${bundleStats?.cacheSize}`);
      return bundleStats ? bundleStats.cacheSize : DEFAULT_DATA_SIZE;
    } catch (err) {
      LogUtil.showError(TAG, `getCacheByName err: ${err?.message}, ${err?.code}`);
    }
    return DEFAULT_DATA_SIZE;
  }

  static async getAllDataByName(packageName: string, appIndex?: number): Promise<BundleStats> {
    let bundleStats: BundleStats = new BundleStats();
    try {
      let res: storageStatistics.BundleStats | undefined =
        await StorageUtil.getBundleStats(packageName, appIndex, NoGetBundleStatsFlag.GET_BUNDLE_WITHOUT_CACHE_SIZE);
      if (res) {
        bundleStats.appSize = String(res.appSize);
        bundleStats.dataSize = String(res.dataSize);
        bundleStats.cacheSize = String(res.cacheSize);
        bundleStats.totalSize = String(res.appSize + res.dataSize);
        return bundleStats;
      }
    } catch (err) {
      LogUtil.showError(TAG, `getAllDataByName err: ${err?.message}, ${err?.code}`);
    }
    return bundleStats;
  }

  /**
   * get migration data size
   */
  static async getMigrationDataSize(): Promise<number> {
    LogUtil.info(`${TAG} get migration data size start`);
    let dataSize: number = 0;
    try {
      // dataSize = await migrate.getMigrator().getMigrationDataSize();
    } catch (err) {
      LogUtil.error(`${TAG} get migration data size error code: ${err?.code}, message: ${err?.message}`);
    }
    LogUtil.info(`${TAG} get migration data size end`);
    return dataSize;
  }

  /**
   * 时间比较，计算当前时间与传入时间的差，以天为单位
   */
  static getDaysByTimeMillis(timeMillis: number): number {
    let nowTime: number = systemDateTime.getTime();
    let timeDiffs: number = nowTime - timeMillis;
    let days = Math.floor(timeDiffs / DAY_TIME_MILLIS);
    return days;
  }

  /**
   * get backUp data size
   */
  static refreshBackUpDataSize(): void {
    let localBackupInfo = SettingsDataUtils.getSecureValue(StorageEventConstant.LOCAL_BACKUP_INFORMATION, '');
    if (!localBackupInfo) {
      LogUtil.error(`${TAG} local backup information is empty`);
      return;
    }
    try {
      let localBackupModel: LocalBackupModel = JSON.parse(localBackupInfo) as LocalBackupModel;
      if (localBackupModel == null) {
        LogUtil.error(`${TAG} local backup model is null`);
        return;
      }
      StorageDataManager.getInstance().setLocalBackupModel(localBackupModel);
      LogUtil.info(`${TAG} get local backup data end`);
    } catch (err) {
      LogUtil.error(`${TAG} localBackupInfo JSON error code: ${err?.code}, message: ${err?.message}`);
    }
  }

  /**
   * 获取一个月内的已使用应用列表，统计时间段为30天前0点-当天
   *
   * @returns 一个月内的已使用应用列表
   */
  public static async getUsedAppInMonthMap(): Promise<Map<number, string[]>> {
    LogUtil.info(`${TAG} getUsedAppInMonthList`);
    let currentTime = new Date().getTime();
    let res: Record<string, Array<usageStatistics.BundleStatsInfo>> = {};
    try {
      // 统计30天前0点-当天的使用数据
      res = await usageStatistics.queryAppStatsInfos(currentTime - LONGEST_UNUSED_TIME, currentTime);
    } catch (err) {
      LogUtil.error(`${TAG} getUsedAppInMonthList queryAppStatsInfos error, code:${err?.code}, message:${err?.message}`);
    }
    let map: Map<number, string[]> = new Map<number, string[]>();
    Object.keys(res).forEach(key => {
      let bundleInfos: usageStatistics.BundleStatsInfo[] = res[key];
      bundleInfos.forEach(bundleInfo => {
        if (bundleInfo.bundleName && bundleInfo.appIndex !== undefined) {
          let bundleList: string[] = map.get(bundleInfo.appIndex) ?? [];
          bundleList.push(bundleInfo.bundleName);
          map.set(bundleInfo.appIndex, bundleList);
        }
      })
    })
    LogUtil.info(`${TAG} getUsedAppInMonthListMap finish`);
    return map;
  }

  /**
   * 获取应用锁应用
   *
   * @returns 应用锁应用列表
   */
  public static async getLockedApps(): Promise<Map<number, string[]>> {
    LogUtil.info(`${TAG} getLockedApps start`);
    let map: Map<number, string[]> = new Map<number, string[]>();
    if (DeviceUtil.isDevicePc()) {
      LogUtil.info(`${TAG} pc not support appLock`);
      return map;
    }
    try {
      let userID: number = await AppUtils.getActivatedAccountLocalId();
      // let appInfos: appLock.AppInfo[] = await appLock.getSwitchEnabledAppInfos(userID);
      // appInfos.forEach(appInfo => {
      //   let bundleList: string[] = map.get(appInfo.appIndex) ?? [];
      //   bundleList.push(appInfo.bundleName);
      //   map.set(appInfo.appIndex, bundleList);
      // });
    } catch (err) {
      LogUtil.error(`${TAG} getLockedApps error, message: ${err?.message}, code: ${err?.code}`);
    }
    LogUtil.info(`${TAG} getLockedApps finish`);
    return map;
  }

  /**
   * 获取应用列表（不区分分身应用/主应用）
   *
   * @param appMap 应用列表
   * @returns 应用列表（不区分分身应用/主应用）
   */
  private static getAllAppListFromMapIgnoreAppIndex(appMap: Map<number, string[]>): string[] {
    let appList: string[] = [];
    appMap.forEach((appInfos: string[], key: number) => {
      appInfos.forEach(appInfo => {
        appList.push(appInfo);
      })
    })
    return appList;
  }

  /**
   * 获取不常用应用列表
   *
   * @returns 不常用应用列表
   */
  static async getUnusedBundleInfoList(): Promise<bundleManager.BundleInfo[]> {
    LogUtil.info(`${TAG} getUnUsedBundleInfoList start`);
    let lockedAppInfoMap: Map<number, string[]> = new Map();
    let usedAppMap: Map<number, string[]> = new Map();
    let bundleInfos: bundleManager.BundleInfo[] = [];
    let allLauncherBundleLabelList: AppEntry[] = [];
    let group: taskpool.TaskGroup = new taskpool.TaskGroup();
    group.addTask(getLockedAppsAsync);
    group.addTask(getUsedAppInMonthMapAsync);
    group.addTask(getAllBundleInfoAsync);
    group.addTask(getLauncherBundleListAsync);
    let res: Object[] = [];
    try {
      res = await taskpool.execute(group, taskpool.Priority.HIGH);
    } catch (err) {
      LogUtil.error(`${TAG} getUnusedBundleInfoList taskpool err, code: ${err?.code}, message: ${err?.message}`);
    }
    if (!CheckEmptyUtils.isEmptyArr(res) && res.length === 4) {
      lockedAppInfoMap = res[0] as Map<number, string[]>;
      usedAppMap = res[1] as Map<number, string[]>;
      bundleInfos = res[2] as bundleManager.BundleInfo[];
      allLauncherBundleLabelList = res[3] as AppEntry[];
    }
    let usedAppsIgnoreAppIndex: string[] = StorageUtil.getAllAppListFromMapIgnoreAppIndex(usedAppMap);
    let lockedAppsIgnoreAppIndex: string[] = StorageUtil.getAllAppListFromMapIgnoreAppIndex(lockedAppInfoMap);
    let currentTime = new Date().getTime();

    // 过滤可卸载、应用锁、常用应用
    bundleInfos = bundleInfos.filter(bundleInfo => {
      if (!bundleInfo || !bundleInfo.appInfo) {
        return false;
      }
      // 过滤可卸载应用
      if (!bundleInfo.appInfo.removable) {
        return false;
      }
      // 过滤系统应用
      if (bundleInfo.appInfo?.systemApp) {
        return false;
      }
      // 过滤30天内安装应用
      let lastInstallTime = bundleInfo.updateTime;
      if (lastInstallTime <= 0) {
        LogUtil.info(`${TAG} bad installTime:${lastInstallTime},name:${bundleInfo.name},index:${bundleInfo.appIndex}`);
        return false;
      }
      if (currentTime - lastInstallTime < LONGEST_UNUSED_TIME) {
        return false;
      }

      let bundleName: string = bundleInfo.name;
      // 主应用需要过滤分身应用
      let index: number = bundleInfo.appIndex;
      if (index === MAIN_APP_INDEX) {
        if (lockedAppsIgnoreAppIndex.includes(bundleName)) {
          return false;
        }
        if (usedAppsIgnoreAppIndex.includes(bundleName)) {
          return false;
        }
      } else {
        // 过滤应用锁应用
        let lockedList = lockedAppInfoMap.get(index);
        if (lockedList && lockedList.includes(bundleInfo.name)) {
          return false;
        }
        // 过滤常用应用
        let usedAppList = usedAppMap.get(index);
        if (usedAppList && usedAppList.includes(bundleInfo.name)) {
          return false;
        }
      }

      // 只显示桌面应用
      for (let i = 0; i < allLauncherBundleLabelList.length; i++) {
        let appInfo: AppEntry = allLauncherBundleLabelList[i];
        if (appInfo.name === bundleInfo.name && appInfo.appIndex === bundleInfo.appIndex) {
          return true;
        }
      }
      return false;
    });
    LogUtil.info(`${TAG} getUnUsedBundleInfoList finish ${bundleInfos.length}`);
    return bundleInfos;
  }

  /**
   * 获取全量应用列表
   *
   * @returns 全量应用列表
   */
  public static async getAllBundleInfo(): Promise<bundleManager.BundleInfo[]> {
    // 获取全量应用列表
    let bundleInfos: bundleManager.BundleInfo[] = [];
    try {
      bundleInfos = await bundleManager.getAllBundleInfo(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    } catch (err) {
      LogUtil.error(`${TAG} getAllBundleInfo error, code:${err?.code}, message:${err?.message}`);
    }
    return bundleInfos;
  }

  /**
   * 获取存储二级界面显示应用列表，参考AppListLoader.refreshAppList
   *
   * @returns 存储二级界面显示应用列表
   */
  public static async getLauncherBundleList(): Promise<AppEntry[]> {
    let userID: number = await AppUtils.getActivatedAccountLocalId();
    let allLauncherBundleLabelList: launcherBundleResource.LauncherAbilityInfo[] = [];
    try {
      allLauncherBundleLabelList = await launcherBundleResource.getAllLauncherAbilityInfo(userID);
    } catch (err) {
      LogUtil.error(`${TAG} getAllLauncherAbilityInfo error, code:${err?.code}, message:${err?.message}`);
      return [];
    }
    let appList: AppEntry[] = [];
    allLauncherBundleLabelList.forEach(appInfo => {
      let appEntry = new AppEntry({
        name: appInfo.applicationInfo?.name,
        versionName: '',
        updateTime: 0,
        appInfo: {
          name: appInfo.applicationInfo?.name,
          removable: appInfo.applicationInfo?.removable,
          appIndex: appInfo.applicationInfo?.appIndex,
        }
      } as bundleManager.BundleInfo);
      appList.push(appEntry);
    })
    return AppListLoader.getInstance().filterAppList(appList);
  }

  /**
   * 获取已使用存储空间的比例，如: 已使用50%，返回50
   *
   * @param freeSize 空闲空间大小，单位为byte
   *
   * @returns 已使用的存储空间比例
   */
  public static async getUsedProportion(freeSize?: number): Promise<number> {
    let detail: storage.StorageStats | undefined = await StorageUtil.getStorageDetail();
    let freeBytesNumber: number = freeSize ?? await StorageUtil.getStorageFreeSize();
    if (detail && detail.total !== 0 && freeBytesNumber >= 0) {
      let usedBytesNumber = detail.total - freeBytesNumber;
      let usedProportion = 0;
      let percent = usedBytesNumber / detail.total * 100;
      if (percent < 1) {
        usedProportion = Math.ceil(Number(percent)).valueOf();
      } else {
        usedProportion = Math.floor(Number(percent)).valueOf();
      }
      LogUtil.info(`${TAG} usedProportion : ${usedProportion}`);
      return usedProportion;
    }
    return 0;
  }

  /**
   * 获取当前存储剩余空间大小
   *
   * @returns 当前存储剩余空间大小
   */
  public static async getStorageFreeSize(): Promise<number> {
    let freeBytesNumber: number = INVALID_DATA_SIZE;
    try {
      freeBytesNumber = await storage.getFreeSize();
    } catch (err) {
      LogUtil.error(`${TAG} getFreeSize error, code: ${err?.code}, message: ${err?.message}`);
    }
    return freeBytesNumber;
  }

  /**
   * 获取当前存储状态信息
   *
   * @returns 当前存储状态信息
   */
  public static async getStorageDetail(): Promise<storage.StorageStats | undefined> {
    let detail: storage.StorageStats | undefined = undefined;
    try {
      return await storage.getUserStorageStats();
    } catch (err) {
      LogUtil.error(`${TAG} getUserStorageStats error, code: ${err?.code}, message: ${err?.message}`);
    }
    return detail;
  }

  /**
   * 获取应用的存储统计数据
   *
   * @param bundleName 应用包名
   * @param appIndex 应用索引 默认为0
   * @param statFlag 统计数据标志
   * @returns 应用的存储统计数据
   */
  public static async getBundleStats(bundleName: string, appIndex?: number,
    statFlag?: NoGetBundleStatsFlag): Promise<storageStatistics.BundleStats | undefined> {
    let res: storageStatistics.BundleStats | undefined;
    res = await StorageUtil.getStatisticsBundleStats(bundleName, appIndex, statFlag);
    return res;
  }

  private static async getStatisticsBundleStats(bundleName: string, appIndex?: number,
    statFlag?: NoGetBundleStatsFlag): Promise<storageStatistics.BundleStats | undefined> {
    const index: number = appIndex ?? 0;
    if (CheckEmptyUtils.checkStrIsEmpty(bundleName) || index < 0) {
      return undefined;
    }
    try {
      const flag = statFlag ?? NoGetBundleStatsFlag.GET_BUNDLE_WITH_ALL_SIZE;
      // return await storageStatistics.getBundleStats(bundleName, index, flag);
      return await storageStatistics.getBundleStats(bundleName, index);
    } catch (error) {
      LogUtil.error(`${TAG} getStatisticsBundleStats failed, ${bundleName},  error: ${error?.code}, ${error?.message}`);
    }
    return undefined;
  }
}