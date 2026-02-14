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

import i18n from '@ohos.i18n';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AppGroupType } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { AppListLoader, AppEntryChangedListener } from '@ohos/settings.application/src/main/ets/AppListLoader';
import { AppEntry } from '@ohos/settings.application/src/main/ets/AppModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { AppInfoDataSource } from '../model/bean/AppInfoDataSource';
import { AppCondition, AppData, AppInfo } from '../model/bean/AppInfo';
import { IntelligentSceneSessionUtil } from '../utils/IntelligentSceneSessionUtil';
import { EVENT_APP_LIST_LOAD_COMPLETE } from '../event/types';

/* instrument ignore file */
export class AppGroupsController implements AppEntryChangedListener {
  private appGroups: AppInfoDataSource;
  private tag: string = 'AppGroupsController';
  private appList: AppInfo[] = [];
  private selectedApps: AppData[] = [];
  private isAppLoadingProcess: boolean = false;
  private appListLoadEventCb = (data: Object) => {
    LogUtil.info(`${this.tag} appListLoad: ${data?.toString()}`);
    if (this.appList.length > 0) {
      return;
    }
    if (data === undefined || data?.toString() === AppGroupType.CONTAINER) {
      this.changeAppList();
    }
  };
  private appListLoadCompleteEventCb = (data: Object) => {
    LogUtil.info(`${this.tag} app list load complete EventCb, ${this.isAppLoadingProcess}`);
    if (this.isAppLoadingProcess) {
      LogUtil.info(`${this.tag} app loading processed`);
      return;
    }
    this.isAppLoadingProcess = true;
    AppListLoader.getInstance().setUpdateDbData(false);
    AppListLoader.getInstance().loadAppList();
  };

  constructor(datasource: AppInfoDataSource) {
    this.appGroups = datasource;
  }

  getListenerName(): string {
    return this.tag;
  }

  onAppListChanged(appList: AppEntry[]): void {
  }

  onAppUpdate(appEntry: AppEntry): void {
  }

  onAppRemove(bundleName: string, appIndex?: number | undefined): void {
    LogUtil.info(`${this.tag} onAppRemove ${bundleName} appIndex: ${appIndex}`);
    if (appIndex === undefined || this.isTwinApp(appIndex)) {
      LogUtil.warn(`${this.tag} onAppRemove ignore.`);
      return;
    }
    const index: number = this.appList.findIndex((item) => {
      return item.name === bundleName;
    });
    if (index === -1) {
      return;
    }
    const selectedIndex: number = this.selectedApps.findIndex((item) => {
      return item.bundleName === bundleName;
    });
    // 卸载已被手动勾选或已保存的应用
    if (selectedIndex !== -1 || this.appGroups.getData(index).isSelected) {
      this.appList[index].label = this.appList[index].name;
      this.appList[index].icon = $r('app.media.app_uninstall_icon');
      this.reloadAllData();
      this.sendEmptyMessage();
      return;
    }
    this.appList.splice(index, 1);
    this.appGroups?.removeDataByIndex(index);
  }

  onAppAdd?(appEntry: AppEntry): void {
    LogUtil.info(`${this.tag} onAppAdd ${appEntry.name} appIndex: ${appEntry.appIndex}`);
    if (!appEntry.name || this.isTwinApp(appEntry.appIndex)) {
      LogUtil.warn(`${this.tag} onAppAdd ignore.`);
      return;
    }
    const index: number = this.appList.findIndex((item) => {
      return item.name === appEntry.name;
    });
    if (index !== -1) {
      this.appList[index].label = appEntry.label;
      this.appList[index].icon = appEntry.icon;
      this.appGroups.updateData(index, this.appList[index]);
      return;
    }
    const appInfo: AppInfo = appEntry as AppInfo;
    appInfo.prefix = this.getFirstLetter(appEntry.label);
    appInfo.pinyin = this.getPinYinString(appEntry.label);
    this.appList.push(appInfo);
    this.reloadAllData();
  }

  init(): void {
    LogUtil.info(`${this.tag} init`);
    EventBus.getInstance().on('EVENT_ID_APP_LIST_LOADER', this.appListLoadEventCb);
    AppListLoader.getInstance().registerAppChangedListener(this);
    EventBus.getInstance().on(EVENT_APP_LIST_LOAD_COMPLETE, this.appListLoadCompleteEventCb);
    IntelligentSceneSessionUtil.sendMessageToGetLoadState();
  }

  destroy(): void {
    LogUtil.info(`${this.tag} destroy`);
    EventBus.getInstance().detach('EVENT_ID_APP_LIST_LOADER', this.appListLoadEventCb);
    AppListLoader.getInstance().unRegisterAppChangedListener(this);
    EventBus.getInstance().detach(EVENT_APP_LIST_LOAD_COMPLETE, this.appListLoadCompleteEventCb);
  }

  changeAppList(): void {
    this.appList = [];
    this.appGroups?.clearAll();
    this.addToList();
    const session = LocalStorage.getShared()?.get<UIExtensionContentSession>('session');
    if (!session) {
      return;
    }
    session.setReceiveDataCallback((data) => {
      if (!data) {
        LogUtil.error(`${this.tag} data is empty.`);
        return;
      }
      let otherAppBundleNames: string = data['otherAppBundleNames'] as string;
      if (otherAppBundleNames) {
        this.appList = this.appList.filter(app => {
          return otherAppBundleNames?.indexOf(app.name) === -1;
        })
      }
      try {
        if (data['appCondition'] === '') {
          LogUtil.info(`${this.tag} add app scene.`);
          // 新增场景
          EventBus.getInstance().emit('appSwitchDataLoaded', true);
          for (let appListElement of this.appList) {
            appListElement.prefix = this.getFirstLetter(appListElement.label);
            appListElement.pinyin = this.getPinYinString(appListElement.label);
          }
          this.reloadAllData();
          this.sendEmptyMessage();
          EventBus.getInstance().emit('APP_INFO_LOADED');
          return;
        }
        // 修改场景
        LogUtil.info(`${this.tag} modify app scene.`);
        let appCondition: AppCondition = JSON.parse(data['appCondition'] as string);
        this.selectedApps = appCondition.appConditionList;
        for (let appListElement of this.appList) {
          appListElement.prefix = this.getFirstLetter(appListElement.label);
          appListElement.pinyin = this.getPinYinString(appListElement.label);
          for (let selectedAppsElement of this.selectedApps) {
            if (selectedAppsElement.bundleName === appListElement.name) {
              appListElement.isSelected = true;
              selectedAppsElement.isInstalled = true;
            }
          }
        }
        this.restoreUninstalledApp();
        this.reloadAllData();
        EventBus.getInstance().emit('appSwitchDataLoaded', appCondition.enable);
        EventBus.getInstance().emit('APP_INFO_LOADED');
        this.sendEmptyMessage();
      } catch (error) {
        LogUtil.info(`${this.tag} onAppListChanged failed, ${error?.message}`);
      }
    })
    session.sendData({
      action: 'pageReady',
    });
  }

  private isTwinApp(appIndex: number): boolean {
    return appIndex !== 0;
  }

  private addToList(): void {
    let systemAppList: AppInfo[] =
      AppListLoader.getInstance().getAppListCache(AppGroupType.SYSTEM).filter((it) => !this.isTwinApp(it.appIndex));
    let unSystemAppList: AppInfo[] =
      AppListLoader.getInstance().getAppListCache(AppGroupType.UN_SYSTEM).filter((it) => !this.isTwinApp(it.appIndex));
    this.appList.push(...systemAppList);
    for (let appItem of unSystemAppList) {
      this.appList.push(appItem);
    }
    const containerApp: AppInfo[] =
      AppListLoader.getInstance().getAppListCache(AppGroupType.CONTAINER).filter((it) => !this.isTwinApp(it.appIndex));
    this.appList.push(...containerApp);
  }

  private getFirstLetter(str?: string): string {
    if (!str) {
      return '#';
    }
    let pinyin: string = i18n.Transliterator.getInstance('Any-Latn; Latin-ASCII').transform(str);
    let prefix: string = pinyin[0].toUpperCase();
    if (!isNaN(Number(prefix))) {
      prefix = '#';
    }
    return prefix;
  }

  private getPinYinString(str?: string): string {
    if (!str) {
      return '';
    }
    return i18n.Transliterator.getInstance('Any-Latn; Latin-ASCII').transform(str);
  }

  private sendEmptyMessage(): void {
    if (this.appList.length === 0) {
      EventBus.getInstance().emit('EVENT_ID_APP_LIST_EMPTY', true, 0);
    }
  }

  private reloadAllData(): void {
    this.appList.sort((a, b) => (a.pinyin ?? '').localeCompare(b.pinyin ?? ''));
    this.appGroups?.clearAll();
    this.appGroups?.getArray().push(...this.appList);
    this.appGroups?.notifyDataReload();
  }

  private restoreUninstalledApp(): void {
    for (let selectedAppsElement of this.selectedApps) {
      if (!selectedAppsElement.isInstalled) {
        let appInfo: AppInfo = {
          isSelected: true,
          name: selectedAppsElement.bundleName,
          label: selectedAppsElement.bundleName,
          icon: $r('app.media.app_uninstall_icon'),
          appIndex: 0,
          prefix: this.getFirstLetter(selectedAppsElement.bundleName),
          pinyin: this.getPinYinString(selectedAppsElement.bundleName),
        };
        this.appList.push(appInfo);
      }
    }
  }
}