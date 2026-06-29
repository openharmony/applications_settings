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

/* instrument ignore file */
import { HashMap } from '@kit.ArkTS';
import bundleManager from '@ohos.bundle.bundleManager';
import usageStatistics from '@ohos.resourceschedule.usageStatistics';
import { AppEntryChangedListener, AppListLoader } from '@ohos/settings.application/src/main/ets/AppListLoader';
import { AppEntry } from '@ohos/settings.application/src/main/ets/AppModel';
import { AppUtils } from '@ohos/settings.application/src/main/ets/AppUtils';
import { AppCloneBadgeComponent } from '@ohos/settings.application/src/main/ets/components/AppCloneBadgeComponent';
import {
  APP_LOADING_DONE_EVENT,
  EVENT_ID_BUNDLE_RESOURCES_CHANGED,
  STORAGE_APP_CHANGE_EVENT
} from '@ohos/settings.common/src/main/ets/event/types';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { OrderedDataSource } from '@ohos/settings.common/src/main/ets/framework/model/OrderedDataSource';
import { CompCtrlParam, ComponentControl } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ComparableSettingItemModel,
  ItemResultType,
  ItemType,
  SettingCheckboxModel,
  SettingCheckboxStyle,
  SettingIconStyle,
  SettingIconType,
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { AppEntryStorage } from '../constant/StorageConstant';
import { StorageUtil } from '../utils/StorageUtil';

const TAG: string = 'UninstallAppGroupControl';
const EVENT_ID_APP_REMOVE: string = 'EVENT_ID_APP_LIST_REMOVE';
const SELECT_ALL_ID: string = 'selectAll';
const APP_NOT_FIND: number = -1;
const ITEM_ID_PREFIX: string = '*';
const CHANGE_UNINSTALL_APP_EVENT: string = 'change_chose_app_uninstall';
const PRE_INSTALL_APP_FLAG: string = 'pre-installed';
const CHECKBOX_STYLE: SettingCheckboxStyle = {
  width: 20,
  height: 20
};

class BundleStats {
  public abilityPrevAccessTime: number = 0;
  public name: string = '';
  public appIndex: number = 0;
}

@Builder
function appCloneBadgeBuilder(param: object): void {
  AppCloneBadgeComponent({
    appCloneBadgeParam: param as SettingItemModel,
    iconSize: 48,
    bundleName: ((param as SettingItemModel)?.extra as AppEntry)?.name
  });
}

export class UninstallUnusedAppController implements ComponentControl, AppEntryChangedListener {
  private appList: AppEntryStorage[] = [];
  private dataSource?: OrderedDataSource;
  private compId?: string;
  private selectedApps: AppEntryStorage[] = [];
  private dealRemoveAppCallback = (bundleName: string, appIndex: number) => {
    LogUtil.showInfo(TAG, `dealRemoveAppCallback bundleName:${bundleName} ${appIndex}`);
    this.removeAppData(bundleName, appIndex);
    this.appList = this.appList.filter((app) => {
      if (!AppUtils.isCloneBundle(appIndex)) {
        return app.name !== bundleName;
      }
      return app.name !== bundleName || app.appIndex !== appIndex;
    });
    LogUtil.info(`${TAG} now appListLength is: ${this.appList?.length}`);
    if (!this.appList || this.appList.length <= 0) {
      PageRouter.pop('Setting');
    }
    this.selectedApps = this.selectedApps.filter((app) => {
      if (!AppUtils.isCloneBundle(appIndex)) {
        return app.name !== bundleName;
      }
      return app.name !== bundleName || app.appIndex !== appIndex;
    })
  }
  private dealAppChangeCallback = (data: object) => {
    setTimeout(async () => {
      LogUtil.info(`${TAG} storage app change`)
      await this.getAppData();
    }, 0);
  }

  async init(compParam: CompCtrlParam): Promise<void> {
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.dataSource = compParam.dataSource as OrderedDataSource;
    this.compId = compParam.compId;
    this.handleEmitter();
    this.getAppData();
  }

  private onBundleResourcesChangedCallback: (isChanged: boolean) => void = async (isChanged: boolean) => {
    LogUtil.info(`${TAG} bundle resources changed: ${isChanged}`);
    if (isChanged) {
      EventBus.getInstance().emit(APP_LOADING_DONE_EVENT, true);
      await AppListLoader.getInstance().refreshAppList();
      LogUtil.info(`${TAG} onBundleResourcesChangedCallback appList length: ${this.appList.length}`);
      EventBus.getInstance().emit(APP_LOADING_DONE_EVENT, false);
    }
  };

  // 获取APP信息并排序
  private async getAppData(apps?: AppEntryStorage[]): Promise<void> {
    if (AppListLoader.getInstance().isRefreshAppList()) {
      LogUtil.warn(`${TAG} appList is isRefreshing`);
      return;
    }
    let appList = (apps && apps.length > 0) ? apps : AppListLoader.getInstance().getAppListCache() as AppEntryStorage[];
    if (!appList || appList.length <= 0) {
      LogUtil.error(`${TAG} appList is empty`);
      PageRouter.pop('Setting');
      return;
    }
    let bundleInfos: bundleManager.BundleInfo[] = await StorageUtil.getUnusedBundleInfoList();
    if (!bundleInfos || bundleInfos.length <= 0) {
      LogUtil.error(`${TAG} bundleInfos is empty`);
      PageRouter.pop('Setting');
      return;
    }
    appList = this.filterApp(appList, bundleInfos);
    await this.getAllBundleStats(appList);
    this.appList = appList;
    this.sortAppList();
    this.reloadDataSource();
  }

  private filterApp(appList: AppEntryStorage[], bundleInfos: Array<bundleManager.BundleInfo>): AppEntryStorage[] {
    let apps: AppEntryStorage[] = [];
    let appMap: Map<string, AppEntryStorage> = new Map();
    appList.forEach((app) => {
      (app as AppEntryStorage).isSelected = false;
      appMap.set(AppUtils.getAppKey(app.name, app.appIndex), app);
    });
    bundleInfos.forEach((bundleInfo) => {
      let app = appMap.get(AppUtils.getAppKey(bundleInfo.name, bundleInfo.appIndex));
      if (app) {
        LogUtil.info(`${TAG} name:${bundleInfo.name}, index:${bundleInfo.appIndex},` +
          `source:${bundleInfo.appInfo?.installSource}, updateTime:${bundleInfo.updateTime}` +
          `, installTime:${bundleInfo.installTime}`);
        app.abilityPrevAccessTime = this.getAppPrevAccessTime(bundleInfo);
        app.unusedDaysDescription = this.getAppUnusedDescription(app.abilityPrevAccessTime);
        apps.push(app);
      }
    });
    LogUtil.info(`${TAG} filtered app length: ${apps.length}`);
    return apps;
  }

  private getAppPrevAccessTime(bundle: bundleManager.BundleInfo): number {
    if (bundle?.appInfo?.installSource === PRE_INSTALL_APP_FLAG && bundle?.installTime === bundle?.updateTime) {
      // 预装应用并且安装时间=更新时间，显示的字符串为未使用的应用，排序时时间戳从小到大排序，需要排在前面
      return 0;
    }
    return bundle.updateTime;
  }

  private getAppUnusedDescription(prevAccessTime: number): ResourceStr {
    if (!prevAccessTime) {
      return $r('app.string.unused_app');
    }
    return this.getPluralStringValueSync($r('app.plural.not_enabled_for_many_days'),
      StorageUtil.getDaysByTimeMillis(prevAccessTime));
  }

  private getPluralStringValueSync(resource: Resource, num: number): string {
    if (!resource) {
      return '';
    }
    try {
      let resourceManager = ResourceUtil.getContext()?.resourceManager;
      return resourceManager?.getPluralStringValueSync(resource.id, num);
    } catch (error) {
      LogUtil.error(`${TAG} getPluralStringValueSync failed, error code: ${error?.code}, message: ${error?.message}.`);
    }
    return '';
  }

  private async getAllBundleStats(appList: AppEntryStorage[]): Promise<void> {
    try {
      LogUtil.info(`${TAG} getBundleStats start`);
      let retArray: BundleStats[] = await this.getBundleStats(appList);
      LogUtil.info(`${TAG} getBundleStats end`);
      let map: HashMap<string, number> = this.getAppTimeStatsHashMap(retArray);
      if (!map || map.isEmpty()) {
        LogUtil.info(`${TAG} no need update appList for map is empty`);
        return;
      }
      appList.forEach((app) => {
        let prevAccessTime: number = map.get(AppUtils.getAppKey(app.name, app.appIndex));
        if (prevAccessTime > 0) {
          app.abilityPrevAccessTime = prevAccessTime;
          app.unusedDaysDescription = this.getPluralStringValueSync($r('app.plural.not_enabled_for_many_days'),
            StorageUtil.getDaysByTimeMillis(prevAccessTime));
        }
      })
    } catch (error) {
      LogUtil.error(`${TAG} getAllBundleStats catch exception, errmsg: ${error?.message}`);
    }
  }

  async getBundleStats(appEntries: AppEntryStorage[]): Promise<BundleStats[]> {
    let promiseList: BundleStats[] = [];
    let record: Record<string, number[]> = this.convertArrayToRecord(appEntries);
    let info: usageStatistics.AppStatsMap | undefined = undefined;
    try {
      info = await usageStatistics.queryLastUseTime(record);
    } catch (err) {
      LogUtil.error(`${TAG} queryLastUseTime error msg:${err?.msg},code:${err?.code}`);
    }
    if (!info) {
      LogUtil.info(`${TAG} getBundleStats fail info is empty`);
      return promiseList;
    }
    for (let app of appEntries) {
      let bundleInfoResults: usageStatistics.BundleStatsInfo[] = info[app.name];
      if (!bundleInfoResults) {
        continue;
      }
      bundleInfoResults.forEach((bundle) => {
        if (bundle?.appIndex !== app.appIndex) {
          return;
        }
        let prevAccessTime: number | undefined = bundle.abilityPrevAccessTime;
        if (!prevAccessTime || prevAccessTime <= 0) {
          return;
        }
        LogUtil.info(`${TAG} queryLastUseTime result name:${bundle.bundleName},
          index:${bundle.appIndex},prevAccessTime${prevAccessTime}`);
        promiseList.push({
          name: app.name,
          appIndex: app.appIndex,
          abilityPrevAccessTime: prevAccessTime,
        });
      });
    }
    return promiseList;
  }

  private convertArrayToRecord(appEntries: AppEntryStorage[]): Record<string, number[]> {
    let record: Record<string, number[]> = {};
    if (!appEntries) {
      return record;
    }
    for (let app of appEntries) {
      let appIndexes: number[] = record[app.name] ?? [];
      appIndexes.push(app.appIndex);
      record[app.name] = appIndexes;
    }
    return record;
  }

  private getAppTimeStatsHashMap(list: BundleStats[]): HashMap<string, number> {
    let hashMap: HashMap<string, number> = new HashMap();
    if (list.length <= 0) {
      LogUtil.error(`${TAG} getAppTimeStatsHashMap error for list is empty`);
      return hashMap;
    }
    list.forEach((item) => {
      hashMap.set(AppUtils.getAppKey(item.name, item.appIndex), item.abilityPrevAccessTime);
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
    return 'UninstallUnusedAppController';
  }

  onAppListChanged(appList: AppEntry[]): void {
    LogUtil.info(`${TAG} onAppListChanged`);
    this.getAppData(appList as AppEntryStorage[]);
  }

  private handleEmitter(): void {
    EventBus.getInstance().on(EVENT_ID_APP_REMOVE, this.dealRemoveAppCallback);
    EventBus.getInstance().on(STORAGE_APP_CHANGE_EVENT, this.dealAppChangeCallback);
    EventBus.getInstance().on(EVENT_ID_BUNDLE_RESOURCES_CHANGED, this.onBundleResourcesChangedCallback);
  }

  private isMainApp(index: number | undefined): boolean {
    return index === 0 || index === undefined;
  }

  private getCloneAppIds(bundleName: string): number[] {
    let appIds: number[] = [];
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
      appIds.push(app.appIndex);
    }
    return appIds;
  }

  private addSelectAllItem(): void {
    this.dataSource?.splice(0, this.dataSource.length);
    this.dataSource?.pushData({
      id: SELECT_ALL_ID,
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.select_all') },
      result: {
        type: ItemResultType.RESULT_TYPE_CHECKBOX,
        result: {
          selected: this.appList.length !== 0 && this.appList?.length === this.selectedApps?.length,
          style: CHECKBOX_STYLE,
          onSelected: (isSelected: boolean, item: SettingItemModel) => {
            if (isSelected && this.selectedApps.length === this.appList.length) {
              return;
            }
            if (!isSelected && this.selectedApps.length === 0) {
              return;
            }
            item.id = this.refreshItemId(item.id);
            this.revertDataSelectResult(isSelected);
            this.handleAllSelect(isSelected);
          }
        }
      },
    });
  }

  /**
   * 全选和取消全选后，更新已选择app列表，并发送列表更新事件
   */
  private handleAllSelect(select: boolean): void {
    if (select) {
      this.selectedApps.splice(0, this.selectedApps.length);
      this.appList.forEach((app) => {
        this.selectedApps.push(app);
      })
    } else {
      this.selectedApps.splice(0, this.selectedApps.length);
    }
    EventBus.getInstance().emit(CHANGE_UNINSTALL_APP_EVENT, this.selectedApps);
  }

  /**
   * 处理全选和取消全选的逻辑,重置数据的选择结果，并通知UI刷新
   */
  private revertDataSelectResult(select: boolean): void {
    let lastDataSource: OrderedDataSource | undefined = this.dataSource;
    this.dataSource = undefined;
    lastDataSource?.forEach((data) => {
      (data.result?.result as SettingCheckboxModel).selected = select;
      data.id = this.refreshItemId(data.id);
    })
    this.dataSource = lastDataSource;
    this.dataSource?.notifyDataReload();
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

  private sortAppList(): void {
    this.appList.sort((first, second) => first.abilityPrevAccessTime - second.abilityPrevAccessTime);
  }

  /**
   * item的选择状态发生变化后，刷新id以更新UI，只需要与上一次的id不一样即可
   */
  private refreshItemId(beforeId: string): string {
    if (CheckEmptyUtils.checkStrIsEmpty(beforeId) || !beforeId.startsWith(ITEM_ID_PREFIX)) {
      return ITEM_ID_PREFIX + beforeId;
    }
    return beforeId.substring(ITEM_ID_PREFIX.length);
  }

  private findAppIndex(appName: string, appIndex: number): number {
    for (let i = 0; i < this.appList.length; i++) {
      let curApp = this.appList[i];
      if (AppUtils.getAppKey(curApp.name, curApp.appIndex) === AppUtils.getAppKey(appName, appIndex)) {
        return i;
      }
    }
    return APP_NOT_FIND;
  }

  private reloadDataSource(): void {
    this.addSelectAllItem();
    let items: ComparableSettingItemModel[] = [];
    this.appList.forEach((item) => {
      let obj: ComparableSettingItemModel = {
        id: AppUtils.getAppKey(item.name, item.appIndex),
        type: ItemType.ITEM_TYPE_STANDARD,
        icon: {
          icon: AppUtils.isCloneBundle(item.appIndex) ?
            AppListLoader.getInstance().getAppEntry(item.name)?.icon as ResourceStr : item.icon as ResourceStr,
          iconType: SettingIconType.ICON_TYPE_APPICON,
          style: this.getIconStyle(),
          builder: AppUtils.isSupportShowIconBadge(item) ? wrapBuilder(appCloneBadgeBuilder) : undefined
        },
        title: { content: item?.label ?? '' },
        result: {
          type: ItemResultType.RESULT_TYPE_CHECKBOX,
          result: {
            selected: item.isSelected,
            style: CHECKBOX_STYLE,
            onSelected: (isSelected: boolean, model: SettingItemModel) => {
              model.id = this.refreshItemId(model.id);
              let index = this.findAppIndex(item.name, item.appIndex);
              this.dataSource?.notifyDataChange(index);
              isSelected ? this.handleSingleItemSelected(item) : this.handleSingleItemDeselected(item);
              this.handleSingleItemSelectChange(item, model, isSelected);
            }
          }
        },
        desc: { content: item.unusedDaysDescription },
        extra: item
      }
      items.push(obj);
    })
    if (this.dataSource) {
      this.dataSource?.pushDataArray(items);
      this.dataSource.notifyDataReload();
    }
  }

  /**
   * 单个item选择状态变化后更新id以更新UI
   */
  private handleSingleItemSelectChange(item: AppEntryStorage, model: SettingItemModel, isSelected: boolean): void {
    if (!item || !model) {
      return;
    }
    (model?.result?.result as SettingCheckboxModel).selected = isSelected;
    model.id = this.refreshItemId(model.id);
    let index = this.findAppIndex(item.name, item.appIndex);
    if (index !== APP_NOT_FIND) {
      this.dataSource?.notifyDataChange(index);
    }
  }

  /**
   * 处理单个item选择后的事件
   */
  private handleSingleItemSelected(item: AppEntryStorage): void {
    if (this.selectedApps.includes(item)) {
      return;
    }
    this.selectedApps.push(item);
    EventBus.getInstance().emit(CHANGE_UNINSTALL_APP_EVENT, this.selectedApps);
    if (this.selectedApps.length !== this.appList.length) {
      return;
    }
    if (this.dataSource) {
      this.dataSource[0].id = this.refreshItemId(this.dataSource[0].id);
      (this.dataSource[0].result?.result as SettingCheckboxModel).selected = true;
      this.dataSource.notifyDataChange(0);
    }
  }

  /**
   * 处理单个item取消选择后的事件
   */
  private handleSingleItemDeselected(item: AppEntryStorage): void {
    if (!this.selectedApps.includes(item)) {
      return;
    }
    for (let i = 0; i < this.selectedApps.length; i++) {
      if (this.selectedApps[i] === item) {
        this.selectedApps.splice(i, 1);
        break;
      }
    }
    EventBus.getInstance().emit(CHANGE_UNINSTALL_APP_EVENT, this.selectedApps);
    if (this.selectedApps.length !== this.appList.length - 1) {
      return;
    }
    if (this.dataSource) {
      this.dataSource[0].id = this.refreshItemId(this.dataSource[0].id);
      (this.dataSource[0].result?.result as SettingCheckboxModel).selected = false;
      this.dataSource.notifyDataChange(0);
    }
  }

  private removeAppData(name: string, appIndex: number): void {
    let lastData = this.dataSource;
    let index: number = this.findAppIndex(name, appIndex);
    if (index >= 0 && lastData && index < lastData.length) {
      LogUtil.info(TAG + ', uninstall app with index:' + index);
      lastData.removeDataByIndex(++index); // dataSource第一个元素是全选，因此序号需要加1
    }
    if (!this.isMainApp(appIndex)) {
      return;
    }
    let cloneApps: number[] = this.getCloneAppIds(name);
    for (let id of cloneApps) {
      index = this.findAppIndex(name, id);
      lastData?.removeDataByIndex(++index);
    }
  }

  protected registerDataChange(): void {
    AppListLoader.getInstance().unRegisterAppChangedListener(this);
    AppListLoader.getInstance().registerAppChangedListener(this);
  }

  destroy(): void {
    EventBus.getInstance().detach(EVENT_ID_APP_REMOVE, this.dealRemoveAppCallback);
    EventBus.getInstance().detach(STORAGE_APP_CHANGE_EVENT, this.dealAppChangeCallback);
    EventBus.getInstance().detach(EVENT_ID_BUNDLE_RESOURCES_CHANGED, this.onBundleResourcesChangedCallback);
    LogUtil.showInfo(TAG, 'onDestroy eventbus');
  }
}