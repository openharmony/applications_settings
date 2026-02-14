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

import { taskpool } from '@kit.ArkTS';
import i18n from '@ohos.i18n';
import emitter from '@ohos.events.emitter';
import bundle from '@ohos.bundle.bundleManager';
import bundleManager from '@ohos.bundle.bundleManager';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import launcherBundleResource from '@ohos.bundle.launcherBundleManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  EVENT_ID_BUNDLE_LIST_CHANGED,
  EVENT_ID_BUNDLE_REMOVE,
  EVENT_ID_MORE_APP_LIST_LOADER,
  EVENT_ID_BUNDLE_RESOURCES_CHANGED
} from '@ohos/settings.common/src/main/ets/event/types';
import {
  BundleStatusChangeListener,
  BundleStatusChangeManager,
} from '@ohos/settings.common/src/main/ets/bundle/BundleStatusChangeManager';
import { AppEntry } from './AppModel';
import { sortByName } from './util/AppManager';
import { AppUtils } from './AppUtils';
import { ThemeManager, PageList } from './util/ThemeManager';
import { HdsDrawableTools } from './AppIconProcessing';
import { AppListLoaderManager, createAndCacheApp } from './AppListLoaderManagerTaskPool';

const TAG: string = 'MoreAppListLoader : ';
const TASK_NUMBER: number = 10;
const CONCURRENCY_THRESHOLD: number = 20;
const BLOCK_PERMISSION_LIST: Set<string> = new Set([
  'ohos.permission.ANSWER_CALL',
  'ohos.permission.MANAGE_VOICEMAIL',
  'ohos.permission.READ_CALL_LOG',
  'ohos.permission.WRITE_CALL_LOG',
  'ohos.permission.GET_INSTALLED_BUNDLE_LIST',
  'ohos.permission.READ_CELL_MESSAGES',
  'ohos.permission.READ_MESSAGES',
  'ohos.permission.RECEIVE_MMS',
  'ohos.permission.RECEIVE_SMS',
  'ohos.permission.RECEIVE_WAP_MESSAGES',
  'ohos.permission.SEND_MESSAGES'
]);

export class MoreAppListLoader {
  public lastSystemLocale: string = '';
  public isRegister: boolean = false;
  public listenerKey: string = 'more_app_list_loader';
  private readonly pageName: PageList = PageList.MORE_APP_LIST_PAGE;
  private static instance: MoreAppListLoader;
  private isFirstLoad: boolean = true;
  private entriesCache: Map<string, AppEntry> = new Map();
  private isRefreshing: boolean = false;
  private lastRemoveBundleName: string = '';

  /**
   * 获取应用列表加载类单例
   */
  static getInstance(): MoreAppListLoader {
    if (!MoreAppListLoader.instance) {
      MoreAppListLoader.instance = new MoreAppListLoader();
    }
    return MoreAppListLoader.instance;
  }

  /**
   * 加载更多应用列表
   */
  async loadAppList(): Promise<void> {
    let isLocaleChanged: boolean = false;
    if (this.lastSystemLocale !== i18n.getSystemLocale() ||
      ThemeManager.getInstance().checkIsNeedToRefresh(this.pageName)) {
      isLocaleChanged = true;
      LogUtil.info(`${TAG} loadAppList clear cache`);
    }

    if (this.isFirstLoad || isLocaleChanged) {
      this.refreshAppList();
      if (this.isFirstLoad) {
        this.isFirstLoad = false;
      }
    } else {
      await this.updateAppList(this.getAppListCache());
    }
  }

  /**
   * 获取更多应用列表缓存信息
   *
   * @return 应用列表缓存信息
   */
  getAppListCache(): AppEntry[] {
    return Array.from(this.entriesCache.values());
  }

  /**
   * 订阅包资源管理变化事件
   */
  public registerStatusChange(): void {
    if (!this.isRegister) {
      BundleStatusChangeManager.getInstance().registerBundleChangedListener(this.bundleStatusCallback);
      this.subscribeBundleResourcesChangeEvents();
      this.isRegister = true;
    }
  }

  /**
   * 取消订阅包资源管理变化事件
   */
  public unRegisterStatusChange(): void {
    if (this.isRegister) {
      BundleStatusChangeManager.getInstance().unRegisterBundleChangedListener(this.bundleStatusCallback);
      this.unSubscribeBundleResourcesChangeEvents();
      this.isRegister = false;
    }
  }

  public isRefreshAppList(): boolean {
    return this.isRefreshing;
  }

  public notifyMoreAppListLoader(isDone: boolean) {
    emitter.emit({
      eventId: EVENT_ID_MORE_APP_LIST_LOADER,
    }, {
      data: {
        isLoadingDone: isDone
      }
    });
  }

  private notifyMoreAppListRemoveAll() {
    EventBus.getInstance().emit('EVENT_ID_MORE_APP_LIST_REMOVE_ALL');
  }

  /**
   * 清理更多应用列表缓存信息
   *
   */
  public clearAppListCache(): void {
    this.clearEntriesCache();
    this.isFirstLoad = true;
  }

  private async refreshAppList(): Promise<void> {
    if (this.isRefreshing) {
      LogUtil.warn(`${TAG} refreshAppList is refreshing...`);
      return;
    }
    this.isRefreshing = true;
    LogUtil.info(`${TAG} refreshAppList start`);

    ThemeManager.getInstance().resetRefreshStatus(this.pageName);
    this.clearEntriesCache();
    this.notifyMoreAppListLoader(false);
    let moreAppList: AppEntry[] = [];
    let allBundleShowList: bundle.BundleInfo[] = [];
    try {
      allBundleShowList = await this.getMoreAppBundleList();
    } catch (error) {
      LogUtil.info(`${TAG} getMoreAppList faile: ${error?.message}`);
    }

    try {
      moreAppList = await AppListLoaderManager.getSpecAppList(allBundleShowList) as Array<AppEntry>;
    } catch (error) {
      LogUtil.error(`${TAG} get appList fail, errmsg: ${error?.message}`);
    }

    this.updateSystemLocale();
    this.isRefreshing = false;
    this.updateAppList(moreAppList);
  }

  private updateSystemLocale(): void {
    let currentSystemLocale = i18n.System.getSystemLocale();
    LogUtil.info(`${TAG} currentSystemLocale: ${currentSystemLocale}`);
    if (this.lastSystemLocale !== currentSystemLocale) {
      // 语言变化了，清空缓存
      LogUtil.info(`${TAG} clear cache`);
      this.clearEntriesCache();
      this.lastSystemLocale = currentSystemLocale;
    }
  }

  private async updateAppList(appEntryList: AppEntry[]): Promise<void> {
    LogUtil.info(`${TAG} sort start`);
    try {
      appEntryList = sortByName(appEntryList);
    } catch (error) {
      LogUtil.error(`${TAG} catch exception when sorting, errmsg: ${error?.message}`);
    }
    LogUtil.info(`${TAG} sort end`);
    await Promise.resolve(this.dispatchAppListChanged(appEntryList));
    LogUtil.info(`${TAG} refreshAppList dispatchAppListChanged end`);
    await Promise.resolve(this.refreshCache(appEntryList));
  }

  private refreshCache(appList: Array<AppEntry>): void {
    this.entriesCache = new Map<string, AppEntry>();
    appList.map(entry => this.entriesCache.set(entry.name, entry));
  }

  private dispatchAppListChanged(appList: Array<AppEntry>): void {
    emitter.emit({ eventId: EVENT_ID_BUNDLE_LIST_CHANGED });
  }

  private dispatchAppRemove(bundleName: string): void {
    emitter.emit({
      eventId: EVENT_ID_BUNDLE_REMOVE,
    }, {
      data: {
        bundleName: bundleName,
      }
    });
  }

  private removeAppEntry(bundleName: string): void {
    if (!bundleName) {
      LogUtil.error(`${TAG} removeAppEntry bundleName invalid`);
      return;
    }
    LogUtil.info(`${TAG} removeAppEntry enter, bundleName: ${bundleName}`);
    let entry = this.entriesCache.get(bundleName);
    if (entry) {
      HdsDrawableTools.releaseIcon(entry.icon)
      this.entriesCache.delete(bundleName);
      this.lastRemoveBundleName = bundleName;
      LogUtil.info(`${TAG} removeAppEntry func run`);
    }
    this.dispatchAppRemove(bundleName);
  }

  private clearEntriesCache() {
    if (this.entriesCache.size === 0) {
      return;
    }
    this.entriesCache.forEach((value: AppEntry) => {
      // 判断是否为pixelMap，如果是则需要主动释放
      HdsDrawableTools.releaseIcon(value.icon);
    })
    this.entriesCache.clear();
    this.notifyMoreAppListRemoveAll();
  }

  private async addAppEntry(bundleName: string): Promise<void> {
    if (!bundleName) {
      LogUtil.error(`${TAG} addAppEntry bundleName invalid`);
      return;
    }
    LogUtil.info(`${TAG} addAppEntry enter, bundleName: ${bundleName}`);

    this.isFirstLoad = true;

    let task: taskpool.Task = new taskpool.Task(createAndCacheApp, bundleName, 0);
    let entry: AppEntry = await taskpool.execute(task, taskpool.Priority.MEDIUM) as AppEntry;
    let copyEntry: AppEntry = AppEntry.copy(entry);
    if (this.lastRemoveBundleName === bundleName) {
      this.entriesCache.set(copyEntry.name, copyEntry);
      EventBus.getInstance().emit('EVENT_ID_BUNDLE_ADD', copyEntry);
      this.lastRemoveBundleName === '';
    }
    LogUtil.info(`${TAG} addAppEntry : ${copyEntry}`);
  }

  private readonly bundleStatusCallback: BundleStatusChangeListener = {
    getListenerName: (): string => {
      return this.listenerKey ?? ' ';
    },
    onBundleAdd: (bundleName, userId) => {
      LogUtil.info(`${TAG} bundleStatusCallback add, bundleName: ${bundleName} userId: ${userId}`);
      this.addAppEntry(bundleName);
    },
    onBundleRemove: (bundleName, userId) => {
      LogUtil.info(`${TAG} bundleStatusCallback remove, bundleName: ${bundleName} userId: ${userId}`);
      this.removeAppEntry(bundleName);
    },
    onBundleUpdate: (bundleName, userId) => {
      LogUtil.info(`${TAG} bundleStatusCallback update, bundleName: ${bundleName} userId: ${userId}`);
    }
  };

  private subscribeBundleResourcesChangeEvents(): void {
    EventBus.getInstance().on(EVENT_ID_BUNDLE_RESOURCES_CHANGED, this.onBundleResourcesChangedCallback);
  }

  private onBundleResourcesChangedCallback: (isChanged: boolean) => void = (isChanged: boolean) => {
    LogUtil.info(`${TAG} bundle resources changed: ${isChanged}`);
    if (isChanged) {
      this.refreshAppList();
    }
  };

  public unSubscribeBundleResourcesChangeEvents(): void {
    EventBus.getInstance().detach(EVENT_ID_BUNDLE_RESOURCES_CHANGED, this.onBundleResourcesChangedCallback);
  }

  private async getMoreAppBundleList(): Promise<bundleManager.BundleInfo[]> {
    LogUtil.info(`${TAG} getAllBundleList`);
    let allBundleInfoList: bundleManager.BundleInfo[] = [];

    // Step 1: 获取全应用的信息
    let result = await this.getAllBundleList();
    if (result) {
      allBundleInfoList = result[0];
      LogUtil.info(`${TAG} getAllBundleList: ${allBundleInfoList.length}`);
    }

    // Step 2: 过滤缓存中已有桌面应用，更多应用中不展示桌面应用
    let launchBundleList = await this.getAllLauncherAbilityInfo();
    let bundleInfoList: bundleManager.BundleInfo[] = allBundleInfoList.filter((allBundleObj) => {
      if (allBundleObj.appInfo?.bundleType === 1) {
        return false;
      }
      return launchBundleList.every((appInfoObj) => {
        return allBundleObj.name !== appInfoObj?.applicationInfo?.name;
      })
    });

    // Step 3: 获取申请权限的应用列表
    let reqPermissionsList = await this.getReqPermissionsAppList(bundleInfoList);

    // Step 4: 获取可卸载应用列表
    let removableList = this.getRemovableAppList(bundleInfoList);

    // Step 5: 获取完整展示应用列表
    let allBundleShowList = await this.getAllBundleShowList(reqPermissionsList, removableList);

    return allBundleShowList;
  }

  private async getAllLauncherAbilityInfo(): Promise<launcherBundleResource.LauncherAbilityInfo[]> {
    const userID: number = await AppUtils.getActivatedAccountLocalId();
    LogUtil.info(`${TAG} now userid is: ${userID}`);
    let allLauncherBundleLabelList: launcherBundleResource.LauncherAbilityInfo[] = [];
    try {
      allLauncherBundleLabelList = await launcherBundleResource.getAllLauncherAbilityInfo(userID);
    } catch (error) {
      LogUtil.info(`${TAG} allLauncherBundleLabelList catch error: ${error?.message}`);
    }
    return allLauncherBundleLabelList;
  }

  async getReqPermissionsAppList(bundleInfoList: bundle.BundleInfo[]) {
    let reqPermissionsList: bundleManager.BundleInfo[] = [];

    //遍历应用权限，根据应用数量决策是否并发遍历
    if (bundleInfoList.length > CONCURRENCY_THRESHOLD) {
      const bundlesNumberPerTask = bundleInfoList.length / TASK_NUMBER;
      let tasks: taskpool.TaskGroup = new taskpool.TaskGroup();
      for (let index = 0; index < TASK_NUMBER; index++) {
        tasks.addTask(new taskpool.Task(getMoreAppListShowBundleInfo, BLOCK_PERMISSION_LIST, index < TASK_NUMBER - 1
          ? bundleInfoList.slice(index * bundlesNumberPerTask, (index + 1) * bundlesNumberPerTask)
          : bundleInfoList.slice(index * bundlesNumberPerTask)));
      }
      try {
        await taskpool.execute(tasks).then((res: Object[]) => {
          for (let index = 0; index < res.length; index++) {
            reqPermissionsList.push(...(res[index] as bundle.BundleInfo[]));
          }
        });
      } catch (error) {
        LogUtil.error(`${TAG} taskpool error`);
      }
    } else {
      reqPermissionsList = await getMoreAppListShowBundleInfo(BLOCK_PERMISSION_LIST, bundleInfoList);
    }
    LogUtil.info(`${TAG} reqPermissionsList length :${reqPermissionsList.length}`);
    return reqPermissionsList;
  }

  getAllBundleList(): Promise<[bundleManager.BundleInfo[]]> {
    return Promise.all([
      bundleManager.getAllBundleInfo(
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION |
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE |
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_REQUESTED_PERMISSION |
        bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_DISABLE)
    ])
  }

  getRemovableAppList(allBundleResourceList: bundle.BundleInfo[]): bundle.BundleInfo[] {
    let bundleInfo: bundle.BundleInfo[] = [];
    for (const resourceList of allBundleResourceList) {
      if (resourceList?.appInfo?.removable) {
        bundleInfo.push(resourceList);
      }
    }

    return bundleInfo;
  }

  async getAllBundleShowList(reqPermissionsList: bundle.BundleInfo[], removableList: bundle.BundleInfo[]):
    Promise<bundle.BundleInfo[]> {
    let appInfoList: bundle.ApplicationInfo[] = [];
    let flag = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION |
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE |
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_REQUESTED_PERMISSION |
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_DISABLE;
    try {
      appInfoList = await bundle.getAllApplicationInfo(flag, 0);
    } catch (error) {
      LogUtil.info(`${TAG} getUserAppList failed: ${error?.message}`);
    }
    let allBundleShowList = Array.from(new Set(reqPermissionsList.concat(removableList)));

    return allBundleShowList.filter((allBundleObj) =>
      appInfoList.every((appInfoObj) => allBundleObj.name !== appInfoObj.name));
  }
}

@Concurrent
async function getMoreAppListShowBundleInfo(bolockPermissionList: Set<string>,
  allBundleResourceList: bundle.BundleInfo[]): Promise<bundle.BundleInfo[]> {
  let bundleInfo: bundle.BundleInfo[] = [];
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  for (const resourceList of allBundleResourceList) {
    let reqPermissionDetails = resourceList.reqPermissionDetails;
    for (const permissionDetails of reqPermissionDetails) {

      //非敏感权限无需展示，grantMode为0且permissionname不在bolockPermissionList里的为敏感权限
      if (bolockPermissionList.has(permissionDetails.name)) {
        continue;
      }
      let grantMode: number = 1;
      try {
        let permissionDef = await bundleManager.getPermissionDef(permissionDetails.name);
        grantMode = permissionDef.grantMode;
      } catch (err) {
        LogUtil.info(`getPermissionDef failed: ${err?.message}`);
      }
      if (grantMode !== 0) {
        continue;
      }

      //!isPermissionSystemFixed代表为可修改权限，需要展示
      let isPermissionSystemFixed: boolean = false;
      try {
        let flags: number = await atManager
          .getPermissionFlags(resourceList.appInfo.accessTokenId, permissionDetails.name as Permissions);
        if (flags === 1 << 2) {
          isPermissionSystemFixed = true;
        }
      } catch (err) {
        LogUtil.info(`getPermissionFlags failed: ${err?.message}`);
      }
      if (!isPermissionSystemFixed) {
        bundleInfo.push(resourceList);
        break;
      }
    }
  }
  return bundleInfo;
}