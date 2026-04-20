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

import bundle from '@ohos.bundle.bundleManager';
import resourceManager from '@ohos.resourceManager';
import i18n from '@ohos.i18n';
import launcherBundleResource from '@ohos.bundle.launcherBundleManager';
import taskpool from '@ohos.taskpool';
import { systemDateTime } from '@kit.BasicServicesKit';
import { AppGroupType } from '@ohos/settings.common/src/main/ets/utils/Consts';
import {
  EVENT_ID_APP_CACHE_LOADED,
  EVENT_ID_BUNDLE_RESOURCES_CHANGED
} from '@ohos/settings.common/src/main/ets/event/types';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import {
  BundleStatusChangeListener,
  BundleStatusChangeManager,
} from '@ohos/settings.common/src/main/ets/bundle/BundleStatusChangeManager';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import AppInfoDataManager from '@ohos/settings.common/src/main/ets/data/AppInfoDataManager';
import { AppInfoModel } from '@ohos/settings.common/src/main/ets/data/AppInfoDataType';
import { DisplayConstant } from '@ohos/settings.common/src/main/ets/constant/DisplayConstant';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { PackageFilterConfig } from './PackageFilterConfig';
import { AppEntry, AppType } from './AppModel';
import { PackageFilterConfigFileParser } from './util/PackageFilterConfigFileParser';
import { AppUtils } from './AppUtils';
import { AppListLoaderManager, createAndCacheApp } from './AppListLoaderManagerTaskPool';
import { sortByName, AppManager, LanguageStatus, getBundleInfoTask} from './util/AppManager';
import { ThemeManager, PageList } from './util/ThemeManager';
import { HdsDrawableTools } from './AppIconProcessing';
import { AppEntryUtil, sortEntryByName } from './util/AppEntryUtil';

const TAG: string = 'AppListLoader : ';

const APP_MARKET_FILTER_CONFIG_PATH: string = 'app_market_filter_config.json';

const KEY_LAST_SYSTEM_LOCALE: string = 'lastSystemLocale';

const KEY_LAST_VP: string = 'lastVp2Px';

/**
 * 应用列表加载监听接口
 *
 * @since 2022-05-26
 */
export interface AppEntryChangedListener {
  /**
   * 获取 listener name
   * @returns listener name
   */
  getListenerName(): string;

  /**
   * 应用列表变化回调
   */
  onAppListChanged(appList: Array<AppEntry>): void;

  /**
   * 应用更新/数据变化回调
   */
  onAppUpdate(appEntry: AppEntry): void;

  /**
   * 应用卸载回调
   */
  onAppRemove(bundleName: string, appIndex?: number): void;

  /**
   * 应用添加回调
   */
  onAppAdd?(appEntry: AppEntry): void;
}

/**
 * 应用列表加载类
 *
 * @since 2022-05-26
 */
export class AppListLoader {
  public userID: number = 100;
  public listenerKey: string = 'app_list_loader';
  public isRegister: boolean = false;
  public lastSystemLocale: string = PreferencesUtil.getSync(KEY_LAST_SYSTEM_LOCALE, '') as string;
  public lastVp: string = PreferencesUtil.getSync(KEY_LAST_VP, '') as string;
  public entriesCache: Map<string, AppEntry | undefined> = new Map();
  public appChangeListeners: AppEntryChangedListener[] = [];
  private readonly pageName: PageList = PageList.APP_LIST_PAGE;
  private static instance: AppListLoader;
  private isFirstLoad: boolean = true;
  private isRefreshing: boolean = false;
  private isListLoading: boolean = false;
  private isCacheLoading: boolean = false;
  private isCacheLoaded: boolean = false;
  private isSystemAppRefreshed: boolean = true;
  private isUpdateDbData: boolean = true;
  private isHdsHandle: boolean;
  private dpiChangeRegister: boolean = false;
  private clearMemoryAndDbCache = () => {
    LogUtil.showInfo(TAG, 'clearMemoryAndDbCache');
    this.clearAppListCache();
    AppInfoDataManager.clearAllAppInfo();
  }

  /**
   * 获取应用列表加载类单例
   */
  static getInstance(): AppListLoader {
    if (!AppListLoader.instance) {
      AppListLoader.instance = new AppListLoader();
    }
    return AppListLoader.instance;
  }

  /**
   * 加载应用列表
   */
  async loadAppList(): Promise<void> {
    EventBus.getInstance().emit('EVENT_ID_LOADING', true);
    this.isListLoading = true;
    if (AppManager.getInstance().getLanguageChangingStatus(this.lastSystemLocale) === LanguageStatus.CHANGING) {
      LogUtil.warn(`${TAG} loadAppList changing language...`);
      return;
    }
    if (this.isRefreshing) {
      if (this.isSystemAppRefreshed) {
        // 如果正在刷新且系统应用已经完成，则通知应用与元服务刷新系统应用
        EventBus.getInstance().emit('EVENT_ID_APP_LIST_LOADER', AppGroupType.SYSTEM);
      }
      LogUtil.warn(`${TAG} loadAppList refreshAppList is refreshing...`);
      return;
    }
    let isLocaleOrThemeChanged: boolean = false;
    let currentLocal: string = i18n.System.getSystemLocale();
    LogUtil.info(`${TAG} lastSystemLocale is ${this.lastSystemLocale}, current locale is ${currentLocal}`);
    // 判断是否更换了语言或主题（需要hds处理）
    if (this.lastSystemLocale !== currentLocal || (this.isHdsHandle &&
      ThemeManager.getInstance().checkIsNeedToRefresh(this.pageName))) {
      isLocaleOrThemeChanged = true;
      await AppInfoDataManager.clearAllAppInfo();
      LogUtil.info(`${TAG} loadAppList clear cache`);
    }

    LogUtil.info(`${TAG} isFirstLoad: ${this.isFirstLoad}, isLocaleOrThemeChanged: ${isLocaleOrThemeChanged}`);
    if (this.isFirstLoad || isLocaleOrThemeChanged) {
      this.refreshAppList(true, !isLocaleOrThemeChanged);
      if (this.isFirstLoad) {
        this.isFirstLoad = false;
      }
      return;
    }
    let appList: AppEntry[] = await this.getAppList();
    let appListCache: AppEntry[] = this.getAppListCache();
    if (this.isNeedRefresh(appList, appListCache)) {
      LogUtil.info(`${TAG} needRefresh refreshAppList`);
      this.refreshAppList(true, !isLocaleOrThemeChanged, appList);
      return;
    }
    await this.updateAppList(appListCache);
    EventBus.getInstance().emit('EVENT_ID_LOADING', false);
    this.isListLoading = false;
  }

  async getAppList(): Promise<AppEntry[]> {
    let allLauncherBundleLabelList: launcherBundleResource.LauncherAbilityInfo[] = [];
    let appList: AppEntry[] = [];
    // Step 1:请求userid
    this.userID = await AppUtils.getActivatedAccountLocalId();
    LogUtil.info(`${TAG} now userid is: ${this.userID}`);

    // Step 2:请求全部桌面应用的信息getAllLauncherAbilityInfo
    allLauncherBundleLabelList = await this.getAllLauncherAbilityInfo();

    // Step 3:获取appList
    try {
      appList = await AppListLoaderManager.getAppList(allLauncherBundleLabelList, this.isHdsHandle) as Array<AppEntry>;
    } catch (error) {
      LogUtil.error(`${TAG} get appList fail, errmsg: ${error?.message}`);
    }

    appList = await this.filterAppList(appList);
    return appList;
  }

  private isNeedRefresh(appList: AppEntry[], appListCache: AppEntry[]): boolean {
    if (appList && appListCache) {
      let appNameCacheList: string[] = appListCache.map(entry => AppUtils.getAppKey(entry?.name, entry?.appIndex));
      let appNameList: string[] = appList.map(entry => AppUtils.getAppKey(entry?.name, entry?.appIndex));
      return (appList.filter(entry => !appNameCacheList.includes(AppUtils.getAppKey(entry?.name, entry?.appIndex)))
        .length !== 0) ||
        (appListCache.filter(entry => !appNameList.includes(AppUtils.getAppKey(entry?.name, entry?.appIndex)))
          .length !== 0);
    }
    return false;
  }

  public setUpdateDbData(isUpdateDbData: boolean): void {
    this.isUpdateDbData = isUpdateDbData;
  }

  /**
   * 从缓存中获取应用数据
   */
  getAppEntry(bundleName: string, appIndex?: number): AppEntry | undefined {
    return this.entriesCache.get(AppUtils.getAppKey(bundleName, appIndex));
  }

  isRefreshAppList(): boolean {
    return this.isRefreshing;
  }

  isRefreshOrLoadingAppList(): boolean {
    return this.isRefreshing || this.isListLoading;
  }

  /**
   * 刷新应用列表数据
   */
  async refreshAppList(isNeedNotify: boolean = true, canUseDbCache: boolean = false,
    appList?: AppEntry[]): Promise<void> {
    if (this.isRefreshing) {
      LogUtil.warn(`${TAG} refreshAppList is refreshing...`);
      if (this.isSystemAppRefreshed) {
        // 如果正在刷新且系统应用已经完成，则通知应用与元服务刷新系统应用
        EventBus.getInstance().emit('EVENT_ID_APP_LIST_LOADER', AppGroupType.SYSTEM);
      }
      return;
    }
    LogUtil.info(`${TAG} refreshAppList start`);
    this.isRefreshing = true;
    this.isSystemAppRefreshed = false;
    // 这重置状态的原因为：在刷新的过程中，若切换主题，需要重新刷新图标的情况
    ThemeManager.getInstance().finishedRefreshAppList();
    EventBus.getInstance().emit('EVENT_ID_LOADING', this.isRefreshing);
    this.clearEntriesCache();
    if (!appList) {
      appList = await this.getAppList();
    }
    let containerApps: AppEntry[] = [];

    await this.updateSystemLocale();

    if (this.isHdsHandle && canUseDbCache && (vp2px(1).toString() === this.lastVp)) {
      await this.loadAppListFromDbToCacheInner(appList);
    }
    PreferencesUtil.putSync(KEY_LAST_VP, vp2px(1).toString());
    if (this.isCacheLoaded) {
      let startTime:number = systemDateTime.getTime(false);
      LogUtil.warn(`${TAG} deleted invalid app start at ${startTime}`);
      let count:number = 0;
      let appNameList: string[] = appList.map(entry => AppUtils.getAppKey(entry?.name, entry?.appIndex));
      this.getAppListCache().forEach(entry => {
        /* instrument ignore next */
        if (!appNameList.includes(AppUtils.getAppKey(entry?.name, entry?.appIndex))) {
          LogUtil.warn(`${TAG} deleted invalid app, name: ${entry?.name}, appIndex: ${entry?.appIndex}`);
          this.removeAppEntry(entry.name, entry.appIndex);
          count++;
        }
      });
      let endTime:number = systemDateTime.getTime(false);
      LogUtil.warn(`${TAG} deleted invalid app end at ${endTime}, cost ${endTime - startTime}, deleted count is ${count}`);
    }
    /* instrument ignore else*/
    if (this.isHdsHandle) {
      // 区分出system和非systemApp并分别对两块区域做排序和拼接
      await this.separateList2Handle(appList, containerApps);
    } else {
      await this.updateAppList(appList);
    }
    LogUtil.info(`${TAG} refreshAppList: appList len:${appList.length}`);
    // 应用与元服务隐藏加载画面
    this.isRefreshing = false;
    EventBus.getInstance().emit('EVENT_ID_LOADING', false);
    this.isListLoading = false;

    if (this.isHdsHandle) {
      // 通知存储或注册了listener的模块做对应动作
      if (isNeedNotify) {
        for (let listener of this.appChangeListeners) {
          listener?.onAppListChanged(appList);
        }
      }
      // 延时3s触发内存回收
      AbilityUtils.timeoutForceGC(3000, 'AppListLoader->refreshAppList');
    }
  }

  /* instrument ignore next */
  async loadAppListFromDb(): Promise<void> {
    if (this.isCacheLoading || this.isCacheLoaded) {
      LogUtil.info(`${TAG} loadAppListFromDb is loading or already loaded`);
      return;
    }
    let currentLocal: string = i18n.System.getSystemLocale();
    if (this.lastSystemLocale !== currentLocal) {
      LogUtil.info(`${TAG} loadAppListFromDb could not use cache`);
      return;
    }
    await this.loadAppListFromDbToCacheInner();
  }

  /* instrument ignore next */
  private async compareDbCache(appList: AppEntry[] | undefined, cacheList: AppInfoModel[]): Promise<AppInfoModel[]> {
    if (!appList) {
      LogUtil.warn(`${TAG} compareDbCache, appList is empty.`);
      return [];
    }
    let appNameCacheList: string[] = cacheList.map(entry => AppUtils.getAppKey(entry?.bundleName, entry?.appIndex));
    let toAddList: AppEntry[] =
      appList.filter(entry => !appNameCacheList.includes(AppUtils.getAppKey(entry?.name, entry?.appIndex)));
    if (!toAddList) {
      LogUtil.info(`${TAG} compareDbCache, no data needs to be added.`);
      return [];
    }
    let result: AppEntry[] = await AppListLoaderManager.hdsIconsHandle(toAddList, false);
    return await AppEntryUtil.transferEntryListToInfo(result);
  }

  /* instrument ignore next */
  private async loadAppListFromDbToCacheInner(appList?: AppEntry[]): Promise<void> {
    this.isCacheLoading = true;
    let startTime:number = systemDateTime.getTime(false);
    LogUtil.info(`${TAG} loadAppListFromDbToCache start at ${startTime}`);
    let systemApps: AppInfoModel[] = [];
    let userApps: AppInfoModel[] = [];
    let serviceApps: AppInfoModel[] = [];
    let containerApps: AppInfoModel[] = [];
    let cacheList: AppInfoModel[] = await AppInfoDataManager.queryAllAppInfo();

    if (!cacheList || cacheList.length < 10) {
      LogUtil.warn(`${TAG} loadAppListFromDbToCache: appList len:${cacheList?.length}`);
      return;
    }

    if (!appList) {
      appList = await this.getAppList();
    }
    let adds: AppInfoModel[] = await this.compareDbCache(appList, cacheList);
    if (adds) {
      cacheList.push(...adds);
    }
    LogUtil.warn(`${TAG} compareDbCache adds size: ${adds.length}`);

    cacheList.forEach((appEntry: AppInfoModel) => {
      switch (AppEntryUtil.getEntryAppType(appEntry)) {
        case AppType.SYSTEM_APP:
          systemApps.push(appEntry);
          break;
        case AppType.UN_SYSTEM_APP:
          userApps.push(appEntry);
          break;
        case AppType.SERVICE_APP:
          serviceApps.push(appEntry);
          break;
        case AppType.CONTAINER_APP:
          containerApps.push(appEntry)
          break;
        default:
          break;
      }
    });

    try {
      systemApps = sortEntryByName(systemApps);
    } catch (error) {
      LogUtil.error(`${TAG} catch exception when sorting, errmsg: ${error?.message}`);
    }
    let systemAppsResult: AppEntry[] = await AppEntryUtil.processAppItemsAsync(systemApps, 'systemApps');
    systemAppsResult.map(entry => this.setEntriesCache(entry, entry.name, entry.appIndex));

    LogUtil.info(`${TAG} start to show system app `);

    // 通知系统App列表更新
    EventBus.getInstance().emit('EVENT_ID_APP_LIST_LOADER', AppGroupType.SYSTEM);
    this.isSystemAppRefreshed = true;
    let endTime:number = systemDateTime.getTime(false);
    LogUtil.info(`${TAG} load system apps db cache use time ${endTime - startTime}ms`)

    let othersResult: AppEntry[] = await AppEntryUtil.processAppItemsAsync(userApps.concat(serviceApps), 'otherApps');
    let task: taskpool.Task = new taskpool.Task(sortByName, othersResult);
    try {
      othersResult = await taskpool.execute(task, taskpool.Priority.MEDIUM) as AppEntry[];
    } catch (error) {
      LogUtil.error(`${TAG} catch exception when sorting, errmsg: ${error?.message}`);
    }
    othersResult.map(entry => this.setEntriesCache(entry, entry.name, entry.appIndex));

    LogUtil.info(`${TAG} start to show other app `);

    // 通知非系统App列表更新
    EventBus.getInstance().emit('EVENT_ID_APP_LIST_LOADER', AppGroupType.UN_SYSTEM);
    EventBus.getInstance().emit('EVENT_ID_APP_LIST_LOADER', AppGroupType.SERVICE);
    LogUtil.info(`${TAG} start to show containers app `);
    try {
      containerApps = sortEntryByName(containerApps);
    } catch (error) {
      LogUtil.error(`${TAG} catch exception when containerApps sorting, errmsg: ${error?.message}`);
    }
    let containerAppsResult: AppEntry[] = await AppEntryUtil.processAppItemsAsync(containerApps, 'containerApps');
    containerAppsResult.map(entry => this.setEntriesCache(entry, entry.name, entry.appIndex));
    EventBus.getInstance().emit('EVENT_ID_APP_LIST_LOADER', AppGroupType.CONTAINER);
    EventBus.getInstance().emit(EVENT_ID_APP_CACHE_LOADED, true);
    endTime = systemDateTime.getTime(false);
    LogUtil.info(`${TAG} loadAppListFromDbToCache end at ${endTime}`);

    LogUtil.info(`${TAG} load db cache use time ${endTime - startTime}ms`)
    this.isCacheLoaded = true;
    this.isCacheLoading = false;
  }

  /**
   * 获取更多应用列表缓存信息
   *
   * @return 应用列表缓存信息
   */
  getAppListCache(type: AppGroupType = AppGroupType.ALL): AppEntry[] {
    let result: AppEntry[] = [];
    switch (type) {
      case AppGroupType.SYSTEM:
        result = this.getAppListWithType(AppType.SYSTEM_APP);
        break;
      case AppGroupType.UN_SYSTEM:
        result = this.getAppListWithType(AppType.UN_SYSTEM_APP);
        break;
      case AppGroupType.SERVICE:
        result = this.getAppListWithType(AppType.SERVICE_APP);
        break;
      case AppGroupType.CONTAINER:
        result = this.getAppListWithType(AppType.CONTAINER_APP);
        break;
      default:
        this.entriesCache.forEach((value, key) => {
          if (value) {
            result.push(value);
          }
        });
        break;
    }

    LogUtil.info(`${TAG} getAppListCache, result length: ${result.length}`);

    return result;
  }

  /**
   * 清理更多应用列表缓存信息
   *
   */
  clearAppListCache(): void {
    this.clearEntriesCache();
    this.isFirstLoad = true;
  }

  registerDpiChange() {
    if (!this.dpiChangeRegister) {
      LogUtil.showInfo(TAG, 'registerDpiChange');
      EventBus.getInstance().on(DisplayConstant.DISPLAY_CHANGE_EVENT, this.clearMemoryAndDbCache);
      this.dpiChangeRegister = true;
    }
  }

  unregisterDpiChange() {
    if (this.dpiChangeRegister) {
      LogUtil.showInfo(TAG, 'unregisterDpiChange');
      EventBus.getInstance().detach(DisplayConstant.DISPLAY_CHANGE_EVENT, this.clearMemoryAndDbCache);
      this.dpiChangeRegister = false;
    }
  }

  /**
   * 注册应用加载变化监听
   *
   * @param listener 监听者
   */
  registerAppChangedListener(listener: AppEntryChangedListener): void {
    if (!listener) {
      LogUtil.error(`${TAG} registerAppChangedListener listener invalid`);
      return;
    }
    for (const appChangeListener of this.appChangeListeners) {
      if (appChangeListener.getListenerName() === listener.getListenerName()) {
        LogUtil.info(`${TAG} registerAppChangedListener listener already register`);
        return;
      }
    }

    this.appChangeListeners.push(listener);
    this.registerStatusChange();
  }

  /**
   * 取消注册应用加载变化监听
   *
   * @param listener 监听者
   */
  unRegisterAppChangedListener(listener: AppEntryChangedListener): void {
    if (!listener) {
      LogUtil.error(`${TAG} unRegisterAppChangedListener listener invalid`);
      return;
    }
    for (let index = 0; index < this.appChangeListeners.length; index++) {
      if (this.appChangeListeners[index].getListenerName() === listener.getListenerName()) {
        this.appChangeListeners.splice(index, 1);
        return;
      }
    }
  }

  /**
   * 订阅包资源管理变化事件
   */
  subscribeBundleResourcesChangeEvents(): void {
    EventBus.getInstance().on(EVENT_ID_BUNDLE_RESOURCES_CHANGED, this.onBundleResourcesChangedCallback);
  }

  /* instrument ignore next */
  private onBundleResourcesChangedCallback: (isChanged: boolean) => void = (isChanged: boolean) => {
    LogUtil.info(`${TAG} bundle resources changed: ${isChanged}`);
    if (isChanged) {
      this.refreshAppList(true, false);
    }
  };

  /**
   * 取消订阅包资源管理变化事件
   */
  unSubscribeBundleResourcesChangeEvents(): void {
    EventBus.getInstance().detach(EVENT_ID_BUNDLE_RESOURCES_CHANGED, this.onBundleResourcesChangedCallback);
  }

  /**
   * 更新应用数据
   *
   * @param bundleName 应用包名
   * @param appIndex 应用分身
   * @returns 应用数据
   */
  async updateAppEntry(bundleName: string, appIndex?: number): Promise<void> {
    if (!bundleName) {
      LogUtil.error(`${TAG} updateAppEntry bundleName invalid`);
      return;
    }
    let index: number = appIndex ?? 0;
    LogUtil.info(`${TAG} updateAppEntry bundleNameKey: ${bundleName}, input appIndex ${index}`);
    let entry = await this.createAndCache(bundleName, index) as AppEntry;
    this.loadIconAndSize(entry);
    if (this.isHdsHandle) {
      await AppInfoDataManager.updateOrReplaceAppInfo(await AppEntryUtil.transferSingleEntryToInfo(entry));
    }
    this.updateAppCloneEntry(bundleName);
  }

  private async updateAppCloneEntry(bundleName: string): Promise<void> {
    if (!bundleName) {
      LogUtil.error(`${TAG} updateAppCloneEntry bundleName invalid`);
      return;
    }
    let bundleInfos: bundle.BundleInfo[] = await bundle.getAllAppCloneBundleInfo(bundleName,
      bundle.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION | bundle.BundleFlag.GET_BUNDLE_INFO_WITH_DISABLE);
    LogUtil.info(`${TAG} updateAppCloneEntry bundleInfos: ${!!bundleInfos} ${bundleInfos?.length}`);
    if (CheckEmptyUtils.isEmptyArr(bundleInfos)) {
      return;
    }
    /* instrument ignore next */
    for (let bundleInfo of bundleInfos) {
      if (bundleInfo?.appIndex === 0) {
        continue;
      }
      LogUtil.info(`${TAG} updateAppCloneEntry bundleNameKey: ${bundleInfo.name}, input appIndex ${bundleInfo.appIndex}`);
      let entry = await this.createAndCache(bundleInfo.name, bundleInfo.appIndex) as AppEntry;
      this.loadIconAndSize(entry);
    }
  }

  /**
   * 新建并缓存应用数据
   *
   * @param bundleName 应用包名
   * @param appIndex 应用分身
   * @return 应用信息
   */
  async createAndCache(bundleName: string, appIndex: number = 0): Promise<AppEntry | null> {
    if (!bundleName) {
      LogUtil.error(`${TAG} createAndCache bundleName invalid`);
      return null;
    }
    let task: taskpool.Task = new taskpool.Task(createAndCacheApp, bundleName, appIndex);
    let entry: AppEntry = await taskpool.execute(task, taskpool.Priority.MEDIUM) as AppEntry;
    let copyEntry: AppEntry = AppEntry.copy(entry);
    if (await this.isNeedShow(bundleName, copyEntry)) {
      if (!copyEntry || !copyEntry?.label) {
        LogUtil.warn(`${TAG} createAndCache label invalid, bundleName: ${bundleName}, appIndex: ${appIndex}`);
      }
      this.setEntriesCache(copyEntry, bundleName, copyEntry.appIndex);
    }

    return copyEntry;
  }

  /**
   * 新建应用数据
   *
   * @param bundleName 应用包名
   * @param appIndex 应用分身
   * @return 应用信息
   */
  async createAppEntryByName(bundleName: string, appIndex?: number): Promise<AppEntry | null> {
    if (!bundleName) {
      LogUtil.error(`${TAG} createAppEntryByName bundleName invalid`);
      return null;
    }
    let bundleInfo: bundle.BundleInfo | undefined = await this.getBundleInfo(bundleName, appIndex);
    if (CheckEmptyUtils.isEmpty(bundleInfo)) {
      return null;
    }
    LogUtil.info(`${TAG} createAppEntryByName bundleInfo ${bundleInfo?.name}, appIndex: ${bundleInfo?.appIndex}`);
    let entry = await this.createAppEntry(bundleInfo as bundle.BundleInfo);
    return entry;
  }

  /**
   * 从缓存读取应用数据，如果没有则创建
   *
   * @param bundleName 应用包名
   * @param appIndex 应用分身
   * @return 应用信息
   */
  async getAndUpdateAppEntryByName(bundleName: string, appIndex?: number): Promise<AppEntry | null> {
    if (!bundleName) {
      LogUtil.error(`${TAG} getAndUpdateAppEntryByName bundleName invalid`);
      return null;
    }
    let bundleInfo: bundle.BundleInfo | undefined = await this.getBundleInfo(bundleName, appIndex);
    if (CheckEmptyUtils.isEmpty(bundleInfo)) {
      return null;
    }
    LogUtil.info(`${TAG} getAndUpdateAppEntryByName bundleInfo ${bundleInfo?.name}, appIndex: ${bundleInfo?.appIndex}`);
    let entry = await this.getAndUpdateAppEntry(bundleInfo as bundle.BundleInfo);
    return entry;
  }

  /**
   * 电池界面从缓存读取应用数据，如果没有则创建
   *
   * @param bundleName 应用包名
   * @param appIndex 应用分身
   * @return 应用信息
   */
  async getAndUpdateAppEntryByNameForBattery(bundleName: string): Promise<AppEntry | null> {
    /* instrument ignore if*/
    if (!bundleName) {
      LogUtil.error(`${TAG} getAndUpdateAppEntryByName bundleName invalid`);
      return null;
    }
    let bundleInfo: bundle.BundleInfo | undefined = undefined;
    try {
      let task: taskpool.Task = new taskpool.Task(getBundleInfoTask, bundleName);
      bundleInfo = await taskpool.execute(task, taskpool.Priority.MEDIUM) as bundle.BundleInfo;
    } catch (error) {
      LogUtil.error(`${TAG} execute getBundleInfoTask fail errcode: ${error?.code}, errmsg: ${error?.message}`);
    }
    /* instrument ignore if*/
    if (CheckEmptyUtils.isEmpty(bundleInfo)) {
      return null;
    }
    LogUtil.info(`${TAG} getAndUpdateAppEntryByName bundleInfo ${bundleInfo?.name}, appIndex: ${bundleInfo?.appIndex}`);
    let entry = await this.getAndUpdateAppEntry(bundleInfo as bundle.BundleInfo);
    return entry;
  }

  public async getBundleInfo(bundleName: string, appIndex?: number): Promise<bundle.BundleInfo | undefined> {
    let bundleInfo: bundle.BundleInfo | undefined = undefined;
    try {
      if (AppUtils.isCloneBundle(appIndex)) {
        bundleInfo = await bundle.getAppCloneBundleInfo(bundleName, appIndex,
          bundle.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION | bundle.BundleFlag.GET_BUNDLE_INFO_WITH_DISABLE);
      } else {
        bundleInfo = await bundle.getBundleInfo(bundleName,
          bundle.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION | bundle.BundleFlag.GET_BUNDLE_INFO_WITH_DISABLE);
      }
    } catch (error) {
      LogUtil.error(`${TAG} getBundleInfo error, errcode: ${error?.code}, errmsg: ${error?.message}`);
      bundleInfo = undefined;
    }
    return bundleInfo;
  }

  private async getAllLauncherAbilityInfo(): Promise<launcherBundleResource.LauncherAbilityInfo[]> {
    let allLauncherBundleLabelList: launcherBundleResource.LauncherAbilityInfo[] = [];
    try {
      allLauncherBundleLabelList = await launcherBundleResource.getAllLauncherAbilityInfo(this.userID);
    } catch (error) {
      LogUtil.info(`${TAG} allLauncherBundleLabelList catch error: ${error?.message}`);
    }
    allLauncherBundleLabelList = await this.deduplicate(allLauncherBundleLabelList);

    return allLauncherBundleLabelList;
  }

  private readonly bundleStatusCallback: BundleStatusChangeListener = {
    getListenerName: (): string => {
      return this.listenerKey ?? ' ';
    },
    onBundleAdd: (bundleName, userId, appIndex) => {
      LogUtil.info(`${TAG} bundleStatusCallback add, bundleName: ${bundleName} userId: ${userId} appIndex: ${appIndex}`);
      this.addAppEntry(bundleName, appIndex ?? 0);
    },
    onBundleRemove: (bundleName, userId, appIndex) => {
      LogUtil.info(`${TAG} bundleStatusCallback remove, bundleName: ${bundleName} userId: ${userId} appIndex: ${appIndex}`);
      this.removeAppEntry(bundleName, appIndex ?? 0);
    },
    onBundleUpdate: (bundleName, userId, appIndex) => {
      LogUtil.info(`${TAG} bundleStatusCallback update, bundleName: ${bundleName} userId: ${userId} appIndex: ${appIndex}`);
      this.updateAppEntry(bundleName, appIndex);
    }
  };

  /**
   * 订阅包资源管理变化事件
   */
  public registerStatusChange(): void {
    if (!this.isRegister) {
      BundleStatusChangeManager.getInstance().registerBundleChangedListener(this.bundleStatusCallback);
      this.isRegister = true;
    }
  }

  /**
   * 取消订阅包资源管理变化事件
   */
  public unRegisterStatusChange(): void {
    if (this.isRegister) {
      BundleStatusChangeManager.getInstance().unRegisterBundleChangedListener(this.bundleStatusCallback);
      this.isRegister = false;
    }
  }

  public async updateSystemLocale(): Promise<void> {
    let currentSystemLocale = i18n.System.getSystemLocale();
    LogUtil.info(`${TAG} currentSystemLocale: ${currentSystemLocale}, last system local is ${this.lastSystemLocale}`);
    const languageChange: boolean =
      AppManager.getInstance().getLanguageChangingStatus(this.lastSystemLocale) === LanguageStatus.CHANGED;
    if (languageChange && StringUtil.isNotEmpty(this.lastSystemLocale)) {
      // 语言变化了，清空缓存
      LogUtil.info(`${TAG} clear cache`);
      this.clearEntriesCache();
      AppInfoDataManager.clearAllAppInfo();
      this.lastSystemLocale = currentSystemLocale;
      PreferencesUtil.putSync(KEY_LAST_SYSTEM_LOCALE, currentSystemLocale);
    } else {
      LogUtil.showInfo(TAG, `first load: ${this.lastSystemLocale}`);
      this.lastSystemLocale = currentSystemLocale;
      PreferencesUtil.putSync(KEY_LAST_SYSTEM_LOCALE, currentSystemLocale);
    }
  }

  private async addAppEntry(bundleName: string, appIndex: number): Promise<void> {
    if (!bundleName) {
      LogUtil.error(`${TAG} addAppEntry, bundleName invalid`);
      return;
    }
    LogUtil.info(`${TAG} addAppEntry, bundleName: ${bundleName}, appIndex: ${appIndex}`);

    // 缓存中已经存在应用信息，不需要重新添加
    if (this.entriesCache.has(AppUtils.getAppKey(bundleName, appIndex))) {
      LogUtil.info(`${TAG} addAppEntry, bundleName has exist`);
      return;
    }

    // 先添加空数据，再异步获取应用信息更新map表，保证后台切前台场景同时处理add和remove时缓存信息正常
    this.setEntriesCache(undefined, bundleName, appIndex);
    let entry = await this.createAndCache(bundleName, appIndex) as AppEntry;
    if (!this.entriesCache.has(AppUtils.getAppKey(bundleName, appIndex))) {
      LogUtil.info(`${TAG} addAppEntry, bundleName has remove`);
      return;
    }
    this.setEntriesCache(entry, bundleName, appIndex);
    LogUtil.info(`${TAG} addAppEntry, entriesCache length: ${this.entriesCache.size}`);
    if (this.isHdsHandle) {
      AppInfoDataManager.insertSingleAppInfo(await AppEntryUtil.transferSingleEntryToInfo(entry));
    }

    if (await this.isNeedShow(bundleName, entry)) {
      this.dispatchAppAdd(entry);
    } else {
      this.deleteEntriesCache(bundleName, appIndex);
    }
  }

  private removeAppEntry(bundleName: string, appIndex: number):void {
    if (!bundleName) {
      LogUtil.error(`${TAG} removeAppEntry, bundleName invalid`);
      return;
    }
    LogUtil.info(`${TAG} removeAppEntry, bundleName: ${bundleName}, appIndex: ${appIndex}`);

    let entry = this.getEntriesCache(bundleName, appIndex);
    if (entry) {
      this.deleteEntriesCache(bundleName, appIndex);
      LogUtil.info(`${TAG} removeAppEntry, entriesCache length: ${this.entriesCache.size}`);
    }
    AppInfoDataManager.deleteAppInfo(bundleName, appIndex);
    this.dispatchAppRemove(bundleName, appIndex);
  }

  private async getAndUpdateAppEntry(bundleInfo: bundle.BundleInfo): Promise<AppEntry> {
    let entry = this.getEntriesCache(bundleInfo.name, bundleInfo.appIndex);
    if (entry && this.isBundleMatch(entry, bundleInfo) && !this.isIconEmpty(entry.icon)) {
      return entry;
    }
    HdsDrawableTools.releaseIcon(entry?.icon);
    // 目前单框架应用 codePath 值是路径
    LogUtil.info(`${TAG} getAndUpdateAppEntry createAppEntry.`);
    entry = await this.createAppEntry(bundleInfo);
    if (!bundleInfo.appInfo.codePath.includes('/') && entry.labelId === 0) {
      entry.label = bundleInfo.appInfo.label || bundleInfo.name;
    }
    this.setEntriesCache(entry, bundleInfo.name, bundleInfo.appIndex);
    return entry;
  }

  private isIconEmpty(icon?: ResourceStr | PixelMap): boolean {
    if (!icon) {
      LogUtil.warn(`${TAG} isIconEmpty icon is undefined`);
      return true;
    }
    if (typeof icon === 'string') {
      LogUtil.info(`${TAG} isIconEmpty icon is string, length: ${icon.length}`);
      return icon.length === 0;
    }
    let pixelMap = icon as PixelMap;
    if (pixelMap.getImageInfoSync !== undefined) {
      LogUtil.info(`${TAG} isIconEmpty icon is pixelMap.`);
      return false;
    }
    // 最后icon为Resource
    let iconResource: Resource = icon as Resource;
    LogUtil.info(`${TAG} isIconEmpty icon: is resource ${iconResource.id}`);
    if (iconResource.id === AppEntry.getDefaultIcon().id) {
      return true;
    }
    return false;
  }

  public isBundleMatch(entry: AppEntry, bundleInfo: bundle.BundleInfo): boolean {
    if (!bundleInfo) {
      return false;
    }
    if (!entry.versionName || !bundleInfo.versionName) {
      return false;
    }
    if (entry.versionName.localeCompare(bundleInfo.versionName) !== 0) {
      return false;
    }
    if (entry.updateTime !== bundleInfo.updateTime) {
      return false;
    }
    return true;
  }

  private async createAppEntry(bundleInfo: bundle.BundleInfo): Promise<AppEntry> {
    let entry = new AppEntry(bundleInfo);
    await HdsDrawableTools.getInstance().loadLabelAndIcon(entry, this.isHdsHandle);
    return entry;
  }

  async filterAppList(appEntryList: AppEntry[]): Promise<AppEntry[]> {
    // Step 5:获取配置文件,过滤其他的应用市场,防止重复加载
    try {
      let packageFilterConfig = await this.getPackageFilterData();
      let packageNameArr = Array.from(packageFilterConfig?.filterList || [], x => x.packageName);
      if (packageNameArr.length > 0) {
        appEntryList = appEntryList?.filter(item => !packageNameArr.includes(item.name));
      }
    } catch (error) {
      LogUtil.error(`${TAG} catch exception when getPackageFilterData, errmsg: ${error?.message}`);
    }
    return appEntryList;
  }

  private getAppListWithType(type: AppType) {
    let result: AppEntry[] = [];
    for (let value of this.entriesCache.values()) {
      if (!value || value.name === 'com.ohos.sceneboard') {
        continue;
      }
      if (this.getAppType(value) === type) {
        result.push(value);
      }
    }
    return result;
  }

  getAppType(appEntry: AppEntry | null): AppType {
    const appInfo = appEntry?.appInfo;
    if (appInfo?.bundleType === 0) {
      const isTrue = appInfo?.codePath?.includes('/');
      if (isTrue) {
        return appInfo?.systemApp ? AppType.SYSTEM_APP : AppType.UN_SYSTEM_APP;
      }
      if (appInfo?.codePath === '1') {
        return AppType.CONTAINER_APP;
      }
    }
    if (appInfo?.bundleType === 1) {
      return AppType.SERVICE_APP;
    }
    return AppType.UNKNOWN_TYPE;
  }

  private async updateAppList(appEntryList: AppEntry[]): Promise<void> {
    // Step 6:sort
    LogUtil.info(`${TAG} updateAppList start`);
    try {
      appEntryList = sortByName(appEntryList);
    } catch (error) {
      LogUtil.error(`${TAG} catch exception when sorting, errmsg: ${error?.message}`);
    }
    await Promise.resolve(this.refreshCache(appEntryList));
    await Promise.resolve(this.dispatchAppListChanged(appEntryList));
    LogUtil.info(`${TAG} updateAppList end`);
  }

  /**获取应用市场配置文件*/
  async getPackageFilterData(): Promise<PackageFilterConfig | undefined> {
    LogUtil.info(`${TAG} start init PackageFilterData to DataBase`);
    let packageFilterConfig: PackageFilterConfig | undefined = await PackageFilterConfigFileParser.getInstance()
      .parserPackageFilterPageConfig(APP_MARKET_FILTER_CONFIG_PATH);
    LogUtil.info(`${TAG}  PackageFilterConfig content`);
    return packageFilterConfig;
  }

  private async deduplicate(arr: Array<launcherBundleResource.LauncherAbilityInfo>):
    Promise<Array<launcherBundleResource.LauncherAbilityInfo>> {
    let newArr: launcherBundleResource.LauncherAbilityInfo[] = [];
    let bundleNameSet: Set<string> = new Set();
    arr.forEach((item) => {
      let launcherBundleKey: string = AppUtils.getAppKey(item.elementName.bundleName, item.applicationInfo.appIndex);
      if (!bundleNameSet.has(launcherBundleKey)) {
        bundleNameSet.add(launcherBundleKey);
        newArr.push(item);
      }
    })
    bundleNameSet.clear();
    return newArr;
  }

  private async loadIconAndSize(entry: AppEntry): Promise<void> {
    let isIconChanged = await entry.loadIcon();
    let isSizeChanged = await entry.loadSize();
    if (isIconChanged || isSizeChanged) {
      this.dispatchAppUpdate(entry);
    }
  }

  private refreshCache(appList: Array<AppEntry>): void {
    // 如果图标使用了PixelMap，清空缓存的时候会有遗漏部分pixelMap没有release的情况
    this.entriesCache = new Map<string, AppEntry>();
    appList.map(entry => this.setEntriesCache(entry, entry.name, entry.appIndex));
    LogUtil.info(`${TAG} refreshCache end`);
  }

  private async separateList2Handle(appList: AppEntry[], containerApps: AppEntry[]) {
    let systemApps: AppEntry[] = [];
    let userApps: AppEntry[] = [];
    let serviceApps: AppEntry[] = [];
    appList.map(entry => this.setEntriesCacheNoDelete(entry, entry.name, entry.appIndex));

    appList.forEach((appEntry: AppEntry) => {
      switch (this.getAppType(appEntry)) {
        case AppType.SYSTEM_APP:
          systemApps.push(appEntry);
          break;
        case AppType.UN_SYSTEM_APP:
          userApps.push(appEntry);
          break;
        case AppType.SERVICE_APP:
          serviceApps.push(appEntry);
          break;
        case AppType.CONTAINER_APP:
          containerApps.push(appEntry)
          break;
        default:
          break;
      }
    })
    let result: AppEntry[] = [];

    // 所有系统应用全部裁剪展示
    result = await AppListLoaderManager.hdsIconsHandle(systemApps, false);
    try {
      systemApps = sortByName(result);
    } catch (error) {
      LogUtil.error(`${TAG} catch exception when sorting, errmsg: ${error?.message}`);
    }
    systemApps.map(entry => this.setEntriesCache(entry, entry.name, entry.appIndex));
    // 通知系统App列表更新
    EventBus.getInstance().emit('EVENT_ID_APP_LIST_LOADER', AppGroupType.SYSTEM);
    this.isSystemAppRefreshed = true;
    LogUtil.info(`${TAG} save system apps to db: ${this.isUpdateDbData}`);
    if (this.isUpdateDbData) {
      await AppInfoDataManager.batchInsertAppInfos(await AppEntryUtil.transferEntryListToInfo(systemApps), true);
    }
    // 后展示非系统应用
    result = await AppListLoaderManager.hdsIconsHandle(userApps.concat(serviceApps), true);
    let task: taskpool.Task = new taskpool.Task(sortByName, result);
    try {
      result = await taskpool.execute(task, taskpool.Priority.MEDIUM) as AppEntry[];
    } catch (error) {
      LogUtil.error(`${TAG} catch exception when sorting, errmsg: ${error?.message}`);
    }
    result.map(entry => this.setEntriesCache(entry, entry.name, entry.appIndex));
    // 通知非系统App列表更新
    EventBus.getInstance().emit('EVENT_ID_APP_LIST_LOADER', AppGroupType.UN_SYSTEM);
    EventBus.getInstance().emit('EVENT_ID_APP_LIST_LOADER', AppGroupType.SERVICE);
    LogUtil.info(`${TAG} save others apps to db: ${this.isUpdateDbData}`);
    if (this.isUpdateDbData) {
      await AppInfoDataManager.batchInsertAppInfos(await AppEntryUtil.transferEntryListToInfo(result), false);
    }
    appList = systemApps.concat(result);
  }

  private dispatchAppListChanged(appList: Array<AppEntry>): void {
    for (let listener of this.appChangeListeners) {
      listener?.onAppListChanged(appList);
    }

    EventBus.getInstance().emit('EVENT_ID_APP_LIST_LOADER');
  }

  dispatchAppUpdate(appEntry: AppEntry): void {
    for (let listener of this.appChangeListeners) {
      listener?.onAppUpdate(appEntry);
    }
  }

  private dispatchAppAdd(appEntry: AppEntry): void {
    for (let listener of this.appChangeListeners) {
      listener?.onAppAdd?.(appEntry);
    }

    EventBus.getInstance().emit('EVENT_ID_APP_LIST_ADD', appEntry);
  }

  private dispatchAppRemove(bundleName: string, appIndex: number): void {
    for (let listener of this.appChangeListeners) {
      listener?.onAppRemove(bundleName, appIndex);
    }

    EventBus.getInstance().emit('EVENT_ID_APP_LIST_REMOVE', bundleName, appIndex);
  }

  public async updateAppEntriesCache(bundleNameList: string[], isRefreshWhatever: boolean) {
    LogUtil.info(`${TAG} updateAppEntriesCache start ${bundleNameList.length}, isRefreshWhatever: ${isRefreshWhatever}`);
    if (bundleNameList.length === 0) {
      return;
    }
    if (!isRefreshWhatever && (vp2px(1).toString() === this.lastVp)) {
      await this.loadAppListFromDb();
    }
    let appList: AppEntry[] = [];
    let updateBundleInfos: bundle.BundleInfo[] = [];
    for (let bundleName of bundleNameList) {
      let bundleInfo: bundle.BundleInfo | undefined = await this.getBundleInfo(bundleName);
      if (!bundleInfo) {
        continue;
      }
      // 如果没有对应的图标缓存
      if (this.isNeedToRefreshCache(bundleInfo, isRefreshWhatever)) {
        updateBundleInfos.push(bundleInfo);
      }
    }
    LogUtil.info(`${TAG} updateAppEntriesCache the count of apps need to update is ${updateBundleInfos.length}`);
    // 用子线程刷新缓存
    try {
      appList = await AppListLoaderManager.getSpecAppList(updateBundleInfos) as Array<AppEntry>;
    } catch (error) {
      LogUtil.error(`${TAG} get appList fail, errmsg: ${error?.message}`);
    }
    for (let entry of appList) {
      this.setEntriesCache(entry, entry.name, entry.appIndex);
    }
    LogUtil.info(`${TAG} uupdateAppEntriesCache finished`);
  }

  private isNeedToRefreshCache(bundleInfo: bundle.BundleInfo, isRefreshWhatever: boolean): boolean {
    // 判断是否有缓存，并且包更新时间或版本名称
    let entry = this.getEntriesCache(bundleInfo.name, bundleInfo.appIndex);
    if (!isRefreshWhatever && entry && this.isBundleMatch(entry, bundleInfo)) {
      return false;
    }
    HdsDrawableTools.releaseIcon(entry?.icon);
    return true;
  }

  private getEntriesCache(name: string, appIndex: number): AppEntry | undefined {
    return this.entriesCache.get(AppUtils.getAppKey(name, appIndex));
  }

  private setEntriesCache(entry: AppEntry | undefined, name: string, appIndex: number): void {
    if (this.entriesCache.has(AppUtils.getAppKey(name, appIndex))) {
      this.entriesCache.delete(AppUtils.getAppKey(name, appIndex));
    }
    this.entriesCache.set(AppUtils.getAppKey(name, appIndex), entry);
  }

  private setEntriesCacheNoDelete(entry: AppEntry | undefined, name: string, appIndex: number): void {
    if (this.entriesCache.has(AppUtils.getAppKey(name, appIndex))) {
      return;
    }
    this.entriesCache.set(AppUtils.getAppKey(name, appIndex), entry);
  }

  private deleteEntriesCache(name: string, appIndex: number): boolean {
    let appEntry: AppEntry | undefined = this.getEntriesCache(name, appIndex);
    HdsDrawableTools.releaseIcon(appEntry?.icon);
    return this.entriesCache.delete(AppUtils.getAppKey(name, appIndex));
  }

  private clearEntriesCache() {
    LogUtil.info(`${TAG} clearEntriesCache cacheSize: ${this.entriesCache.size}`);
    if (this.entriesCache.size === 0) {
      return;
    }
    this.entriesCache.forEach((value: AppEntry | undefined) => {
      // 判断是否为pixelMap，如果是则需要主动释放
      if (value) {
        try {
          HdsDrawableTools.releaseIcon(value.icon);
        } catch(e) {
          LogUtil.showError(TAG, `releaseIcon error code: ${e?.code}, message: ${e?.message}`);
        }
        LogUtil.info(`${TAG} clearEntriesCache ${value?.name} ${value?.appIndex}`)
      }
    })
    this.entriesCache.clear();
    EventBus.getInstance().emit('EVENT_ID_APP_LIST_REMOVE_ALL');
  }

  private async isNeedShow(bundleName: string, appInfo: AppEntry): Promise<boolean> {
    // 是元服务或者桌面存在应用才展示在基础应用列表中
    let allLauncherBundleLabelList: launcherBundleResource.LauncherAbilityInfo[] =
      await this.getAllLauncherAbilityInfo();
    const item = allLauncherBundleLabelList.find((item) => item.applicationInfo.name === bundleName);
    if (appInfo.appInfo?.bundleType === 1 || item) {
      return true;
    }
    return false;
  }

  private constructor() {
    // this.isHdsHandle = (!DeviceUtil.isWearable() && !DeviceUtil.isDeviceTv());
    this.isHdsHandle = false;
    LogUtil.info(`${TAG} zzzzzz constructor isHdsHandle: ${this.isHdsHandle}`);
  }
}
