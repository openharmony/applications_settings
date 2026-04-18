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

import notificationManager from '@ohos.notificationManager';
import i18n from '@ohos.i18n';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AppGroupType } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { AppListLoader } from '@ohos/settings.application/src/main/ets/AppListLoader';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  BundleStatusChangeManager,
  BundleStatusChangeListener,
} from '@ohos/settings.common/src/main/ets/bundle/BundleStatusChangeManager';
import { AppInfoDataSource } from '../model/bean/AppInfoDataSource';
import { AppData, AppInfo } from '../model/bean/AppInfo';
import { AppAndMetaServiceManager } from '../manager/NotDisturbNotificationManager';
import { IntelligentSceneSessionUtil } from '../utils/IntelligentSceneSessionUtil';
import { EVENT_APP_LIST_LOAD_COMPLETE } from '../event/types';

/* instrument ignore file */
const NO_DISTURB_WHITE_LIST: string[] = [
  'com.ohos.clock',
  'com.ohos.callui',
];

enum AppType {
  APP,
  META_SERVICE,
}

export class AppAndMetaServiceListController implements BundleStatusChangeListener {
  private appGroups: AppInfoDataSource;
  private allSearchData?: AppInfoDataSource;
  private allAppList: AppInfo[] = [];
  private metaServiceList: AppInfo[] = [];
  private onAppItemClicked?: (index: number, item: AppInfo) => void;
  private selectIndex: number = 0;
  private isLoading: boolean = true;
  private hasFinishedLoad: boolean = false;
  private hasSetWhiteList: boolean = true;
  private tag: string = 'AppAndMetaServiceListController';
  private isAppLoadingProcess: boolean = false;
  private appListLoadEventCb = (data: Object) => {
    LogUtil.info(`${this.tag} appListLoad ${data?.toString()} count: ${this.appGroups?.totalCount()}, hasFinishedLoad: ${this.hasFinishedLoad}`);
    if (this.appGroups?.totalCount() > 0 || this.hasFinishedLoad) {
      return;
    }
    if (data === undefined || data.toString() === AppGroupType.CONTAINER) {
      this.hasFinishedLoad = true;
      this.onAppListChanged();
    }
  };
  private appListLoadCompleteEventCb = (data: Object) => {
    LogUtil.info(`${this.tag} appListLoadCompleteEventCb, ${this.isAppLoadingProcess}`);
    if (this.isAppLoadingProcess) {
      LogUtil.info(`${this.tag} app Loading Processed`);
      return;
    }
    this.isAppLoadingProcess = true;
    AppListLoader.getInstance().setUpdateDbData(false);
    AppListLoader.getInstance().loadAppList();
  };

  constructor(datasource: AppInfoDataSource, allSearchData?: AppInfoDataSource,
    onAppItemClicked?: (index: number, item: AppInfo) => void) {
    this.appGroups = datasource;
    this.allSearchData = allSearchData;
    this.onAppItemClicked = onAppItemClicked;
  }

  getListenerName(): string {
    return this.tag;
  }

  onBundleAdd(bundleName: string, userId: number, appIndex: number): void {
  }

  onBundleUpdate(bundleName: string, userId: number, appIndex: number): void {
  }

  onBundleRemove(bundleName: string, userId: number, appIndex: number): void {
    LogUtil.info(`${this.tag} onBundleRemove: ${bundleName}`);
    if (!this.onAppItemClicked) {
      return;
    }
    if (!this.appGroups?.getArray()) {
      LogUtil.warn(`${this.tag} appGroups is empty.`);
      return;
    }
    try {
      const removeIndex: number = this.appGroups.getArray().findIndex((item) => {
        return item.name === bundleName && item.appIndex === appIndex;
      });
      const appInfo: AppInfo = this.appGroups.getData(removeIndex);
      appInfo.isSelected = false;
      // 刷新已选界面
      this.onAppItemClicked(0, appInfo);
      this.appGroups.removeDataByIndex(removeIndex);
      this.allAppList = this.allAppList.filter((item) => {
        return item.name !== bundleName || item.appIndex !== appIndex;
      });
      if (this.allSearchData) {
        this.removeFromArray(this.allSearchData, bundleName, appIndex);
      }
    } catch (error) {
      LogUtil.error(`${this.tag} onBundleRemove failed: ${error?.code}, ${error?.message}`);
    }
  }

  private removeFromArray(dataSource: AppInfoDataSource, bundleName: string, appIndex: number): void {
    const removeIndex: number = dataSource.getArray().findIndex((item) => {
      return item.name === bundleName && item.appIndex === appIndex;
    });
    dataSource.removeDataByIndex(removeIndex);
  }

  init(): void {
    LogUtil.info(`${this.tag} init`);
    this.hasFinishedLoad = false;
    if ((AppStorage.get('hasSetWhiteList') as boolean) === true) {
      this.hasSetWhiteList = true;
    }
    this.isLoading = true;
    if (AppListLoader.getInstance().getAppListCache(AppGroupType.CONTAINER).length <= 0) {
      EventBus.getInstance().on('EVENT_ID_APP_LIST_LOADER', this.appListLoadEventCb);
    } else {
      LogUtil.info(`${this.tag} container app is not empty.`);
      this.onAppListChanged();
    }
    BundleStatusChangeManager.getInstance().registerBundleChangedListener(this);
    EventBus.getInstance().emit('EVENT_ID_LOADING', true);
    EventBus.getInstance().on(EVENT_APP_LIST_LOAD_COMPLETE, this.appListLoadCompleteEventCb);
    IntelligentSceneSessionUtil.sendMessageToGetLoadState();
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    EventBus.getInstance().off('EVENT_ID_APP_LIST_LOADER');
    AppListLoader.getInstance().clearAppListCache();
    BundleStatusChangeManager.getInstance().unRegisterBundleChangedListener(this);
    EventBus.getInstance().detach(EVENT_APP_LIST_LOAD_COMPLETE, this.appListLoadCompleteEventCb);
  }

  selectIndexesUpdated(selectIndex: number): void {
    this.selectIndex = selectIndex;
    if (this.isLoading) {
      LogUtil.warn(`${this.tag} current is loading.`);
      return;
    }
    this.appGroups?.clearAll();
    if (selectIndex === 0) {
      for (let element of this.allAppList) {
        this.appGroups?.pushData(element);
      }
    } else {
      for (let element of this.metaServiceList) {
        this.appGroups?.pushData(element);
      }
    }
    let isEmpty: boolean = this.appGroups.totalCount() === 0;
    if (isEmpty) {
      this.appGroups.notifyDataReload();
    }
    EventBus.getInstance().emit('EVENT_ID_APP_LIST_EMPTY', isEmpty, selectIndex);
  }

  async onAppListChanged(): Promise<void> {
    LogUtil.info(`${this.tag} onAppListChanged`);
    try {
      this.appGroups?.clearAll();
      this.allSearchData?.clearAll();
      this.allAppList = [];
      this.metaServiceList = [];
      let systemAppList: AppInfo[] = AppListLoader.getInstance().getAppListCache(AppGroupType.SYSTEM);
      let unSystemAppList: AppInfo[] = AppListLoader.getInstance().getAppListCache(AppGroupType.UN_SYSTEM);
      let serviceAppList: AppInfo[] = AppListLoader.getInstance().getAppListCache(AppGroupType.SERVICE);
      let containerAppList: AppInfo[] = AppListLoader.getInstance().getAppListCache(AppGroupType.CONTAINER);
      let allNotificationBundleInfos: notificationManager.BundleOption[] = [];
      let bundles: notificationManager.BundleOption[] =
        await AppAndMetaServiceManager.getInstance().getAllNotificationEnabledBundles();
      bundles.forEach(element => {
        let bundleName: string = JSON.stringify(element.bundle).replace(/"/g, '');
        let uid: number = parseInt(JSON.stringify(element.uid).replace(/"/g, ''));
        allNotificationBundleInfos.push({ bundle: bundleName, uid: uid });
      });
      let allSelectedNames: string[] = this.parseSelectedData();
      this.addDataToSearchList(systemAppList, allSelectedNames, allNotificationBundleInfos, AppType.APP);
      this.addDataToSearchList(unSystemAppList, allSelectedNames, allNotificationBundleInfos, AppType.APP);
      this.addDataToSearchList(serviceAppList, allSelectedNames, allNotificationBundleInfos, AppType.META_SERVICE);
      this.addDataToSearchList(containerAppList, allSelectedNames, allNotificationBundleInfos, AppType.APP);
      this.metaServiceList.sort((a, b) => (a.pinyin ?? '').localeCompare(b.pinyin ?? ''));
      this.appGroups.getArray().sort((a, b) => (a.pinyin ?? '').localeCompare(b.pinyin ?? ''));
      this.allSearchData?.getArray().sort((a, b) => (a.pinyin ?? '').localeCompare(b.pinyin ?? ''));
      // 排序
      this.allAppList.sort((a, b) => (a.pinyin ?? '').localeCompare(b.pinyin ?? ''));
      EventBus.getInstance().emit('APP_INFO_LOADED');
      this.isLoading = false;
      LogUtil.info(`${this.tag} onAppListChanged end.`);
      EventBus.getInstance().emit('EVENT_ID_APP_LIST_EMPTY', this.appGroups.totalCount() === 0, this.selectIndex);
    } catch (error) {
      LogUtil.info(`${this.tag} onAppListChanged failed, ${error?.message}`);
    }
  }

  private parseSelectedData(): string[] {
    let allSelectedNames: string[] = [];
    if (!this.hasSetWhiteList) {
      LogUtil.info(`${this.tag} no white list.`);
      return allSelectedNames;
    }
    let notificationWhiteListString: string = AppStorage.get('notificationWhiteList') as string;
    if (!notificationWhiteListString) {
      LogUtil.error(`${this.tag} notificationWhiteListString is empty.`);
      return allSelectedNames;
    }
    try {
      let notificationBundles: notificationManager.BundleOption[] =
        JSON.parse(notificationWhiteListString) as notificationManager.BundleOption[];
      notificationBundles.forEach(element => {
        allSelectedNames.push(`${element.bundle}${element.uid}`);
      });
      LogUtil.info(`${this.tag} allSelected length: ${allSelectedNames.length}`);
    } catch (error) {
      LogUtil.error(`${this.tag} error data failed: ${error?.message}`);
    }
    return allSelectedNames;
  }

  private addDataToSearchList(appList: AppInfo[], allSelectedNames: string[],
    allNotificationBundleInfos: notificationManager.BundleOption[], appType: AppType): void {
    for (let element of appList) {
      if (NO_DISTURB_WHITE_LIST.includes(element.name)) {
        continue;
      }
      let findIndex: number = -1;
      for (let i: number = 0; i < allNotificationBundleInfos.length; i++) {
        if (allNotificationBundleInfos[i].bundle === element.name &&
          allNotificationBundleInfos[i].uid === element.appInfo?.uid) {
          findIndex = i;
          break;
        }
      }
      if (findIndex === -1) {
        continue;
      }
      element.uid = element.appInfo?.uid;
      element.pinyin = this.getPinYinString(element.label);
      element.prefix = this.getFirstLetter(element.pinyin);
      if (allSelectedNames.includes(`${element.name}${element.uid}`)) {
        element.isSelected = true;
      }
      if (appType === AppType.APP) {
        this.allAppList.push(element);
        if (this.selectIndex === 0) {
          this.appGroups?.pushData(element);
        }
      } else {
        this.metaServiceList.push(element);
        if (this.selectIndex === 1) {
          this.appGroups?.pushData(element);
        }
      }
      this.allSearchData?.pushData(element);
    }
  }

  private getFirstLetter(str?: string): string {
    if (!str) {
      return '#';
    }
    let prefix: string = str[0].toUpperCase();
    if (!isNaN(Number(prefix))) {
      prefix = '#';
    }
    return prefix;
  }

  private getPinYinString(str?: string): string {
    if (!str) {
      return '';
    }
    return i18n.Transliterator.getInstance('Any-Latn; Latin-ASCII')?.transform(str);
  }
}