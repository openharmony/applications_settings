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

import { HashMap } from '@kit.ArkTS';
import Want from '@ohos.app.ability.Want';
import { BusinessError } from '@ohos.base';
import bundle from '@ohos.bundle.bundleManager';
import storageStatistics from '@ohos.file.storageStatistics';
import usageStatistics from '@ohos.resourceschedule.usageStatistics';
import taskpool from '@ohos.taskpool';
import { AppEntryChangedListener, AppListLoader } from '@ohos/settings.application/src/main/ets/AppListLoader';
import { AppEntry } from '@ohos/settings.application/src/main/ets/AppModel';
import { AppUtils } from '@ohos/settings.application/src/main/ets/AppUtils';
import { AppCloneBadgeComponent } from '@ohos/settings.application/src/main/ets/components/AppCloneBadgeComponent';
import {
  APP_LOADING_DONE_EVENT,
  EVENT_ID_APP_CACHE_LOADED,
  EVENT_ID_BUNDLE_RESOURCES_CHANGED,
  EVENT_ID_CLEAR_CACHE,
  STORAGE_APP_CHANGE_EVENT,
  STORAGE_APP_LOAD_MORE_EVENT
} from '@ohos/settings.common/src/main/ets/event/types';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ComparableSettingItemModel,
  ItemDetailType,
  ItemResultType,
  ItemType,
  SettingIconStyle,
  SettingIconType,
  SettingItemModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  notifyCompStateChange,
  SettingCompState,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { storageTextBuilder } from '../components/StorageTextComponent';
import { NoGetBundleStatsFlag } from '../constant/StorageConstant';
import { StorageSizeUtil } from '../utils/StorageSizeUtil';
import { StorageUtil } from '../utils/StorageUtil';
import { abilityAccessCtrl } from '@kit.AbilityKit';
import { SettingsDataUtils } from '@ohos/settings.common';

/* instrument ignore file */
const TAG = 'AppGroupControl';
const URL_STORAGE_APPITEM: string = 'setting_storage_appItem';
const DEFAULT = 0;
const START_TIMESTAMP = 0;
const END_TIMESTAMP = 20000000000000;
const DIVIDE_NUMBER = 10;
const APP_STORAGE_MGMT: string = 'AppStorageMgmt';

class BundleStats {
  public key: string = '';
  public item: storageStatistics.BundleStats = {
    appSize: 0,
    cacheSize: 0,
    dataSize: 0,
  };
  public name: string = '';
  public appIndex: number = 0;
}

class AppEntryStorage extends AppEntry {
  public abilityPrevAccessTime: number = 0;
  public skillUrl?: bundle.SkillUrl;
}

@Builder
function appCloneBadgeBuilder(param: object): void {
  AppCloneBadgeComponent({
    appCloneBadgeParam: param as SettingItemModel,
    iconSize: 48,
    bundleName: ((param as SettingItemModel)?.extra as AppEntry)?.name
  })
}

@Concurrent
async function getBundleStats(array: AppEntryStorage[]): Promise<BundleStats[]> {
  let promiseList: BundleStats[] = [];
  for (let app of array) {
    let res =
      await StorageUtil.getBundleStats(app.name, app.appIndex, NoGetBundleStatsFlag.GET_BUNDLE_WITHOUT_CACHE_SIZE);
    let item: storageStatistics.BundleStats = res ?? {
      appSize: 0,
      cacheSize: 0,
      dataSize: 0,
    };
    promiseList.push({
      key: AppUtils.getAppKey(app.name, app.appIndex),
      item,
      name: app.name,
      appIndex: app.appIndex,
    })
  }
  return promiseList;
}

export class AppGroupControl implements ComponentControl, AppEntryChangedListener {
  private nowIndex: number = -1;
  private appList: AppEntryStorage[] = [];
  private dataSource?: OrderedDataSource;
  private compId?: string;
  private defaultDataSize: number = 10;
  private isShowMoreData: boolean = false;
  private isDataReady: boolean = false;
  private dealRemoveAppCallback = (bundleName: string, appIndex: number) => {
    LogUtil.showInfo(TAG, `bundleName:${bundleName} ${appIndex}`);
    this.removeAppData(bundleName, appIndex);
    this.appList = this.appList.filter((i) => {
      if (!AppUtils.isCloneBundle(appIndex)) {
        return i.name !== bundleName;
      }
      return i.name !== bundleName || i.appIndex !== appIndex;
    });
    LogUtil.info(`${TAG} now appListLength is: ${this.appList?.length}`);
  }
  private dealAppChangeCallback = (data: object) => {
    setTimeout(async () => {
      LogUtil.info(`${TAG} storage app change`)
      await this.getAppData(true);
    }, 0);
  }
  private dealLoadMoreCallback = (data: object) => {
    setTimeout(async () => {
      await this.loadMoreData();
    }, 0);
  }
  private dealLoadCacheCallback = (data: object) => {
    setTimeout(async () => {
      LogUtil.info(`${TAG} applist cache loaded`);
      await this.getAppData(true, true);
    }, 0);
  }
  private clearCacheCallback = (bundleName: string, appIndex: number | undefined,
    totalSize: string, appSize: string, dataSize: string) => {
    LogUtil.showInfo(TAG, `bundleName:${bundleName} ${appIndex}, ${totalSize}, ${appSize}, ${dataSize}`);
    for (let index = 0; index < this.appList.length; index++) {
      if (bundleName === this.appList[index].name && appIndex === this.appList[index].appIndex) {
        this.appList[index].totalSize = totalSize;
        this.appList[index].appSize = appSize;
        this.appList[index].dataSize = dataSize;
      }
    }
    this.changeAppListSort(this.nowIndex, true);
    this.onNotifyCompStateChange(AppUtils.getAppKey(bundleName, appIndex),
      StorageSizeUtil.formatDataRound(parseInt(totalSize), 0));
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.dataSource = compParam.dataSource as OrderedDataSource;
    this.compId = compParam.compId;
    this.nowIndex = -1;
    this.initDataSource(DEFAULT);
    this.handleEmitter();
    this.getAppData(true);
  }

  private onBundleResourcesChangedCallback: (isChanged: boolean) => void = async (isChanged: boolean) => {
    LogUtil.info(`${TAG} bundle resources changed: ${isChanged}`);
    if (isChanged) {
      EventBus.getInstance().emit(APP_LOADING_DONE_EVENT, true);
      if (this.dataSource) {
        // 清空除了第一行的所有数据
        this.dataSource.splice(1, this.dataSource.length - 1);
        this.dataSource.notifyDataReload();
      }
      await AppListLoader.getInstance().refreshAppList(true, false);
      LogUtil.info(`${TAG} onBundleResourcesChangedCallback appList length: ${this.appList.length}`);
      EventBus.getInstance().emit(APP_LOADING_DONE_EVENT, false);
    }
  };

  // 获取APP信息并排序
  private async getAppData(isEdit: boolean, isCacheLoaded: boolean = false): Promise<void> {
    if (AppListLoader.getInstance().isRefreshOrLoadingAppList() && !isCacheLoaded) {
      LogUtil.warn(`${TAG} appList is isRefreshing`);
      return;
    }
    let appList: AppEntryStorage[] = AppListLoader.getInstance().getAppListCache() as AppEntryStorage[];
    if (!appList || appList.length < 1) {
      LogUtil.error(`${TAG} appList is empty`);
      return;
    }
    let sceneboardIndex: number = appList.findIndex(item => (item.name === 'com.ohos.sceneboard'));
    if (sceneboardIndex !== -1) {
      appList.splice(sceneboardIndex, 1);
    }
    let sizeList: HashMap<string, storageStatistics.BundleStats> = new HashMap();
    let abilityPrevAccessTimeArr: usageStatistics.BundleStatsInfo[] = [];
    LogUtil.info(`${TAG} new appList length ${appList.length}`);
    try {
      sizeList = await this.getAllBundleStats(appList);
      LogUtil.info(`${TAG} queryBundleStatsInfoByInterval ${sizeList?.length}`);
      abilityPrevAccessTimeArr =
        await usageStatistics.queryBundleStatsInfoByInterval(0, START_TIMESTAMP, END_TIMESTAMP);
    } catch (error) {
      LogUtil.error(`${TAG} get BundleStatsInfo or abilityPrevAccessTimeArr fail, code: ${error?.code} msg: ${error?.message}`);
    }
    this.mergeDataAndAppList(appList, sizeList, abilityPrevAccessTimeArr);
    this.onAppListChanged(appList);
    this.isDataReady = true;
    this.changeAppListSort(this.nowIndex === -1 ? DEFAULT : this.nowIndex, isEdit);
    this.notifyLoadingDone();
  }

  private async getAllBundleStats(appList: AppEntryStorage[]): Promise<HashMap<string, storageStatistics.BundleStats>> {
    let divideNum: number = Math.ceil(appList.length / DIVIDE_NUMBER);
    let taskGroup: taskpool.TaskGroup = new taskpool.TaskGroup();
    for (let index = 0; index < DIVIDE_NUMBER; index++) {
      const arr = appList.slice(divideNum * index, divideNum * (index + 1));
      LogUtil.info(`${TAG} getAllBundleStats [${divideNum * index}, ${divideNum * (index + 1)}]`);
      taskGroup.addTask(getBundleStats, arr);
    }
    LogUtil.info(`${TAG} execute task`);
    let list = await taskpool.execute(taskGroup, taskpool.Priority.MEDIUM);
    LogUtil.info(`${TAG} execute end`);
    let retArray: BundleStats[] = [];
    for (let item of list) {
      retArray.push(...(item as BundleStats[]));
    }
    return this.getBundleStatsHashMap(retArray);
  }

  private getBundleStatsHashMap(list: BundleStats[]): HashMap<string, storageStatistics.BundleStats> {
    let hashMap: HashMap<string, storageStatistics.BundleStats> = new HashMap();
    if (list.length <= 0) {
      LogUtil.error(`${TAG} getBundleStatsHashMap error`);
      return hashMap;
    }
    list.forEach((item) => {
      hashMap.set(AppUtils.getAppKey(item.name, item.appIndex), item.item);
    })

    return hashMap;
  }

  onAppUpdate(): void {
    LogUtil.info(`${TAG} onAppUpdate`);
  }

  onAppRemove(bundleName: string, appIndex?: number): void {
    LogUtil.info(`${TAG} onAppRemove`);
  }

  getListenerName(): string {
    return '';
  }

  onAppListChanged(appList: AppEntry[]): void {
    this.appList = appList as AppEntryStorage[];
    LogUtil.info(`${TAG} onAppListChanged`);
  }

  private notifyLoadingDone(): void {
    EventBus.getInstance().emit(APP_LOADING_DONE_EVENT, false);
  }

  private handleEmitter(): void {
    EventBus.getInstance().on('EVENT_ID_APP_LIST_REMOVE', this.dealRemoveAppCallback);
    EventBus.getInstance().on(STORAGE_APP_CHANGE_EVENT, this.dealAppChangeCallback);
    EventBus.getInstance().on(STORAGE_APP_LOAD_MORE_EVENT, this.dealLoadMoreCallback);
    EventBus.getInstance().on(EVENT_ID_BUNDLE_RESOURCES_CHANGED, this.onBundleResourcesChangedCallback);
    EventBus.getInstance().on(EVENT_ID_CLEAR_CACHE, this.clearCacheCallback);
    EventBus.getInstance().on(EVENT_ID_APP_CACHE_LOADED, this.dealLoadCacheCallback);
  }

  private isMainApp(index: number | undefined): boolean {
    return index === 0 || index === undefined;
  }

  private getCloneAppIds(bundleName: string): string[] {
    let appIds: string[] = [];
    if (!this.appList) {
      LogUtil.showInfo(TAG, 'getCloneAppIds appList is null');
      return appIds;
    }
    let cloneBundleApps: AppEntryStorage[] = this.appList.filter((i) => {
      return i.name === bundleName && AppUtils.isCloneBundle(i.appIndex);
    });

    if (CheckEmptyUtils.isEmptyArr(cloneBundleApps)) {
      LogUtil.showInfo(TAG, 'no has clone app');
      return appIds;
    }
    for (let app of cloneBundleApps) {
      appIds.push(AppUtils.getAppKey(app.name, app.appIndex));
    }
    return appIds;
  }

  private mergeDataAndAppList(
    appList: AppEntryStorage[],
    sizeList: HashMap<string, storageStatistics.BundleStats>,
    abilityPrevAccessTimeArr: usageStatistics.BundleStatsInfo[]
  ): void {
    abilityPrevAccessTimeArr.forEach((item, index) => {
      LogUtil.info(`是否走到这里2----${index}----${item.bundleName}----${item.abilityPrevAccessTime}`)
    })
    appList.forEach((item, index) => {
      const key = AppUtils.getAppKey(item.name, item.appIndex);
      const itemInfo = sizeList.get(key);
      if (CheckEmptyUtils.isEmpty(itemInfo) ||
        (itemInfo.appSize <= 0 && itemInfo.cacheSize <= 0 && itemInfo.dataSize <= 0)) {
        LogUtil.error(`${TAG} mergeDataAndAppList failed, size is invalid, ${item.name}}`);
        this.initDefaultItemSize(item, abilityPrevAccessTimeArr);
        return;
      }
      item.appSize = itemInfo.appSize.toString();
      item.cacheSize = itemInfo.cacheSize.toString();
      item.dataSize = itemInfo.dataSize.toString();
      item.totalSize = (itemInfo.dataSize + itemInfo.cacheSize + itemInfo.appSize).toString();
      let arr = abilityPrevAccessTimeArr.filter(timeItem => timeItem.bundleName === item.name);
      item.abilityPrevAccessTime = this.getMaxPrevAccessTime(arr);
    })
  }

  private initDefaultItemSize(item: AppEntryStorage,
    abilityPrevAccessTimeArr: usageStatistics.BundleStatsInfo[]): void {
    if (item.appSize === '' && item.cacheSize === '' && item.dataSize === '') {
      let defAppSize: number = 100 * 1024 * 1024
      let defCacheSize: number = 100 * 1024;
      let defDataSize: number = 500 * 1024;
      item.appSize = defAppSize.toString();
      item.cacheSize = defCacheSize.toString();
      item.dataSize = defDataSize.toString();
      item.totalSize = (defAppSize + defCacheSize + defDataSize).toString();
      let arr = abilityPrevAccessTimeArr.filter(timeItem => timeItem.bundleName === item.name);
      item.abilityPrevAccessTime = this.getMaxPrevAccessTime(arr);
    }
  }

  // 排序获取最后一次使用时间最大的
  private getMaxPrevAccessTime(arr: usageStatistics.BundleStatsInfo[]): number {
    if (arr.length > 0) {
      arr = arr.sort((b, a) => (a.abilityPrevAccessTime || 0) - (b.abilityPrevAccessTime || 0))
      return arr[0].abilityPrevAccessTime || 0;
    }
    return 0;
  }

  private onHandlerItemClick(e: SettingBaseModel): void {
    LogUtil.showInfo(TAG, 'onItemClick');
    if (this.appList && this.appList.length > 0) {
      let params = this.appList.filter(item => AppUtils.getAppKey(item.name, item.appIndex) === e.id)[0];
      if (params) {
        LogUtil.showInfo(TAG, `params info ${params.appSize}, ${params.dataSize}, ${params.totalSize}`);
        this.getSkillUrl(params).then((skillUrl: bundle.SkillUrl | undefined) => {
          params.skillUrl = skillUrl;
          PageRouter.push(URL_STORAGE_APPITEM, params);
        })
      } else {
        LogUtil.error(`${TAG} onItemClick error params is invalid`);
      }
    }
  }

  private async getSkillUrl(param: AppEntryStorage): Promise<bundle.SkillUrl | undefined> {
    let bundleName: string = param.name ?? '';
    if (CheckEmptyUtils.checkStrIsEmpty(bundleName)) {
      LogUtil.error(`${TAG} getLinkFeature bundleName is empty`);
      return undefined;
    }
    try {
      let want: Want = {
        bundleName: bundleName,
        parameters: {
          'linkFeature': APP_STORAGE_MGMT
        }
      };
      let abilityInfos = bundle.queryAbilityInfoSync(want,
        bundle.AbilityFlag.GET_ABILITY_INFO_DEFAULT | bundle.AbilityFlag.GET_ABILITY_INFO_WITH_SKILL);
      return this.getStorageMgmtSkillUrl(abilityInfos, bundleName);
    } catch (e) {
      LogUtil.warn(`${TAG} queryAbilityInfoSync warn, ${(e as BusinessError).code}`);
    }
    return undefined;
  }

  private getStorageMgmtSkillUrl(abilityInfos: bundle.AbilityInfo[], bundleName: string): bundle.SkillUrl | undefined {
    let resSkill: bundle.SkillUrl | undefined = abilityInfos
    ?.flatMap(info => info?.skills)
    ?.flatMap(skill => skill?.uris)
    ?.find(uri => uri?.linkFeature === APP_STORAGE_MGMT);
    LogUtil.info(`${TAG} getSkillUrl bundleName: ${bundleName}, scheme: ${resSkill?.scheme}, linkFeature: ${resSkill?.linkFeature}`);
    return resSkill;
  }

  private onHandlerSelected(index: number): void {
    LogUtil.showInfo(TAG, `onHandlerSelected ${index}`);
    if (!this.isDataReady) {
      this.nowIndex = index;
      LogUtil.showWarn(TAG, `onHandlerSelected data not ready`);
      return;
    }
    this.changeAppListSort(index, false);
  }

  private initDataSource(index: number): void {
    this.dataSource?.splice(0, this.dataSource.length);
    this.dataSource?.pushData({
      id: 'SortType',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.storage_app_sort_by') },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: { content: index === 0 ? $r('app.string.storage_app_sizes') : $r('app.string.storage_app_last_used') }
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_MENU,
        icon: $r('app.media.ic_storage_spinner'),
        menu: {
          items: [$r('app.string.storage_app_sizes'), $r('app.string.storage_app_last_used')],
          defaultFocus: index,
          selectIcon: $r('app.media.ic_selected'),
          onSelected: (index: number) => {
            this.onHandlerSelected(index);
          }
        }
      },
    })

    // 刷新排序方式下方分割线
    EventBus.getInstance().emit(`${this.compId}.${this.dataSource?.getData(0)?.id}`, new Map([[
      SettingStateType.STATE_TYPE_ITEM_POS, { state: false } as SettingCompState
    ]]));
  }

  private getIconStyle(): SettingIconStyle {
    // 接入了HDS之后，图标不需要主动做描边处理
    let style: SettingIconStyle = {
      border: { width: '0px', color: '#00000000', radius: 0 },
      borderRadius: 0,
      width: 48,
      height: 48,
      mirrored: false,
      draggable: false
    };
    return style;
  }

  private async getComparableSettingItemModel(item: AppEntryStorage,
    isLastItem: boolean): Promise<ComparableSettingItemModel> {
    let appEntry: AppEntry | null =
      await AppListLoader.getInstance().getAndUpdateAppEntryByName(item.name, item.appIndex);
    item.icon = appEntry?.icon;
    let obj: ComparableSettingItemModel = {
      id: AppUtils.getAppKey(item.name, item.appIndex),
      subId: `${isLastItem}`,
      type: ItemType.ITEM_TYPE_STANDARD,
      icon: {
        icon: appEntry?.icon,
        iconType: SettingIconType.ICON_TYPE_APPICON,
        // style: this.getIconStyle(),
        builder: AppUtils.isSupportShowIconBadge(item) ? wrapBuilder(appCloneBadgeBuilder) : undefined
      },
      title: { content: item?.label ?? '' },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: StorageSizeUtil.formatDataIntl(parseInt(item.totalSize), 0, true),
        }
      },
      compare: (dst: ComparableSettingItemModel) => {
        return 0
      },
      desc: { content: '' },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_CUSTOM,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        onItemClick: (component: SettingBaseModel) => {
          this.onHandlerItemClick(component);
        },
      },
      extra: item
    }
    return obj;
  }

  private async changeAppListSort(index: number, isEmit: boolean, isDelete?: boolean): Promise<void> {
    // 如果是首页的pageshow触发的，就要刷新
    if (isEmit || this.nowIndex !== index || isDelete) {
      if (index === 0) {
        this.appList.sort((b, a) => parseInt(a.totalSize) - parseInt(b.totalSize));
      } else {
        this.appList.forEach((item, index) => {
          LogUtil.info(`是否走到这里1----${index}----${item.name}----${item.abilityPrevAccessTime}`)
        })
        this.appList.sort((b, a) => a.abilityPrevAccessTime - b.abilityPrevAccessTime);
      }
      this.nowIndex = index;
      let items: ComparableSettingItemModel[] = [];

      const appListLength = this.appList.length;
      for (let itemIndex = 0; itemIndex < appListLength; itemIndex++) {
        // 默认展示前10条数据
        if (itemIndex >= this.defaultDataSize && !this.isShowMoreData) {
          break;
        }
        items.push(await this.getComparableSettingItemModel(this.appList[itemIndex], itemIndex === appListLength - 1));
      }
      this.initShowMoreDataMenu(items);
      this.initDataSource(index);
      if (this.dataSource) {
        this.dataSource?.pushDataArray(items);
      }
    } else {
      LogUtil.showInfo(TAG, 'same index');
    }
  }

  private async loadMoreData(): Promise<void> {
    LogUtil.showInfo(TAG, `loadMoreData ${this.nowIndex}`);
    this.isShowMoreData = true;
    if (this.nowIndex === 0) {
      this.appList.sort((b, a) => parseInt(a.totalSize) - parseInt(b.totalSize));
    } else {
      this.appList.sort((b, a) => a.abilityPrevAccessTime - b.abilityPrevAccessTime);
    }
    let items: ComparableSettingItemModel[] = [];
    this.appList.forEach((item, itemIndex) => {
      if (itemIndex < this.defaultDataSize) {
        return;
      }
      let obj: ComparableSettingItemModel = {
        id: AppUtils.getAppKey(item.name, item.appIndex),
        type: ItemType.ITEM_TYPE_STANDARD,
        icon: {
          icon: AppUtils.isCloneBundle(item.appIndex) ?
            AppListLoader.getInstance().getAppEntry(item.name)?.icon as ResourceStr : item.icon as ResourceStr,
          iconType: SettingIconType.ICON_TYPE_APPICON,
          // style: this.getIconStyle(),
          builder: AppUtils.isSupportShowIconBadge(item) ? wrapBuilder(appCloneBadgeBuilder) : undefined
        },
        title: { content: item?.label ?? '' },
        result: {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: {
            content: StorageSizeUtil.formatDataIntl(parseInt(item.totalSize), 0, true)
          }
        },
        compare: (dst: ComparableSettingItemModel) => {
          return 0
        },
        desc: { content: '' },
        detail: {
          type: ItemDetailType.DETAIL_TYPE_CUSTOM,
          icon: $r('sys.symbol.chevron_right'),
          isSymbolIcon: true,
          onItemClick: (component: SettingBaseModel) => {
            this.onHandlerItemClick(component);
          },
        },
        extra: item
      }
      items.push(obj);
    })
    if (this.dataSource) {
      let moreMenuItem: ComparableSettingItemModel = {
        id: 'showMoreDataMenu',
        type: ItemType.ITEM_TYPE_CUSTOM,
      }
      this.dataSource?.removeData(moreMenuItem);
      this.dataSource?.pushDataArray(items);
    }
  }

  private initShowMoreDataMenu(items: ComparableSettingItemModel[]): void {
    if (!this.isShowMoreData && this.appList.length > this.defaultDataSize) {
      let item: ComparableSettingItemModel = {
        id: 'showMoreDataMenu',
        type: ItemType.ITEM_TYPE_CUSTOM,
        builder: wrapBuilder(storageTextBuilder),
      }
      items.push(item);
    }
  }

  private removeAppData(name: string, appIndex: number): void {
    let item: ComparableSettingItemModel = {
      id: AppUtils.getAppKey(name, appIndex),
      type: ItemType.ITEM_TYPE_CUSTOM,
    }
    this.dataSource?.removeData(item);
    if (this.isMainApp(appIndex)) {
      let cloneApps: string[] = this.getCloneAppIds(name);
      for (let id of cloneApps) {
        this.dataSource?.removeData({ id: id, type: ItemType.ITEM_TYPE_CUSTOM });
      }
    }
  }

  protected registerDataChange(): void {
    AppListLoader.getInstance().unRegisterAppChangedListener(this);
    AppListLoader.getInstance().registerAppChangedListener(this);
  }

  destroy(): void {
    EventBus.getInstance().detach('EVENT_ID_APP_LIST_REMOVE', this.dealRemoveAppCallback);
    EventBus.getInstance().detach(STORAGE_APP_CHANGE_EVENT, this.dealAppChangeCallback);
    EventBus.getInstance().detach(STORAGE_APP_LOAD_MORE_EVENT, this.dealLoadMoreCallback);
    EventBus.getInstance().detach(EVENT_ID_BUNDLE_RESOURCES_CHANGED, this.onBundleResourcesChangedCallback);
    EventBus.getInstance().detach(EVENT_ID_CLEAR_CACHE, this.clearCacheCallback);
    EventBus.getInstance().detach(EVENT_ID_APP_CACHE_LOADED, this.dealLoadCacheCallback);
    LogUtil.showInfo(TAG, 'onDestroy eventbus');
  }

  onNotifyCompStateChange(id: string, data: string): void {
    notifyCompStateChange(`${this.compId}.${id}`,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        {
          type: ItemResultType.RESULT_TYPE_TEXT,
          result: { content: data }
        } as SettingResultState]]));
  }
}