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
import bundleManager from '@ohos.bundle.bundleManager';
import defaultAppMgr from '@ohos.bundle.defaultAppManager';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import {
  CompCtrlParam,
  ComponentControl,
  SettingBaseModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import {
  ItemResultType,
  ItemType,
  SettingIconStyle,
  SettingIconType,
  SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { AppListInfo } from '../model/SettingAppItemModel';
import { BrowserRadioController } from './BrowserRadioController';
import { AppEntry } from '../AppModel';
import { AppListLoader } from '../AppListLoader';
import { DefaultBrowserUtil } from '../util/DefaultBrowserUtil';
/* instrument ignore file */
const TAG = 'BrowserListController: ';

export class BrowserListController implements ComponentControl {
  private compId: string = '';
  private params: PushParam = new PushParam();
  private dataSource: DynamicDataSource = new DynamicDataSource();
  private radioController?: BrowserRadioController;
  private bundleName: string = '';
  private isSystemApp: boolean = true;

  private appListAddCb = (data: object, appIndex: number) => {
    LogUtil.info(`${TAG} app add`);
    let bundleName = (data as String).toString();
    if (bundleName) {
      this.onAppListAdd(bundleName, appIndex);
    }
  };

  private appListRemoveCb = (data: object, appIndex: number) => {
    LogUtil.info(`${TAG} app remove`);
    let bundleName = (data as String).toString();
    if (bundleName) {
      this.onAppListRemove(bundleName, appIndex);
    }
  };

  constructor(radioController: BrowserRadioController, isSystemApp: boolean) {
    this.isSystemApp = isSystemApp;
    this.radioController = radioController;
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(TAG, `onInit`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${TAG} init begin: ${compParam.compId}`);
    this.compId = compParam.compId;
    this.params = compParam.param as PushParam;
    this.dataSource = compParam.dataSource as DynamicDataSource;

    EventBus.getInstance().on('EVENT_ID_APP_LIST_ADD', this.appListAddCb);
    EventBus.getInstance().on('EVENT_ID_APP_LIST_REMOVE', this.appListRemoveCb);
  }

  private async initData(): Promise<void> {
    await this.initDefaultBrowser();
    this.getBrowserList().then((browserListPro) => {
      this.initGroups(browserListPro);
    });
  }

  onPageShow(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} ${this.compId} onPageShow.`);
    this.initData();
  }

  onPageHide(component: SettingBaseModel): void {
    LogUtil.info(`${TAG} ${this.compId} onPageHide.`);
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy');
    EventBus.getInstance().on('EVENT_ID_APP_LIST_ADD', this.appListRemoveCb);
    EventBus.getInstance().detach('EVENT_ID_APP_LIST_REMOVE', this.appListRemoveCb);
  }

  private onAppListAdd(bundleName: string, appIndex: number): void {
    LogUtil.info(`${TAG} onAppListAdd ${bundleName}`);
    this.initData();
  }

  private onAppListRemove(bundleName: string, appIndex: number): void {
    LogUtil.info(`${TAG} onAppListRemove ${bundleName}`);
    this.initData();
  }

  public async getBrowserList(): Promise<AppListInfo[]> {
    let browserListPro: AppListInfo[] = [];
    try {
      let browserList = await bundle.queryAbilityInfo({
        'action': 'ohos.want.action.viewData',
        'entities': ['entity.system.browsable'],
        'uri': 'http'
      }, bundle.AbilityFlag.GET_ABILITY_INFO_WITH_APPLICATION)
      LogUtil.info(`${TAG} getBrowserList, ${browserList.length}`);
      for (let browserListItem of browserList) {
        browserListPro.push(await this.newAppInfo(browserListItem));
      };
      LogUtil.info(`${TAG} browserlistPro, ${browserListPro.length}`);
    } catch (error) {
      LogUtil.error(`${TAG} catch error : ${error?.message}`);
    }
    return browserListPro;
  }

  private async newAppInfo(browserListItem: bundle.AbilityInfo): Promise<AppListInfo> {
    const bundleName: string = browserListItem.bundleName;
    const appIndex: number = browserListItem.appIndex;
    let entry: AppEntry = await AppListLoader.getInstance()
      .getAndUpdateAppEntryByName(bundleName, appIndex) as AppEntry;
    if (!entry) {
      entry = await AppListLoader.getInstance().createAndCache(bundleName, appIndex) as AppEntry;
    }
    return {
      labelId: browserListItem?.labelId as number,
      label: entry?.label,
      icon: entry.icon as PixelMap,
      bundleName: browserListItem?.bundleName,
      name: browserListItem?.name,
      isSystemApp: browserListItem?.applicationInfo?.systemApp,
      moduleName: browserListItem?.moduleName
    };
  }

  private async initDefaultBrowser(): Promise<void> {
    LogUtil.info(`${TAG} initDefaultBrowser`);
    await this.getDefaultBrowser();
  }

  private async getDefaultBrowserApp(curDefaultBundleName: string): Promise<void> {
    try {
      let browserListPro: AppListInfo[] = await this.getBrowserList();
      const defaultApp = browserListPro.find(browser => curDefaultBundleName === browser.bundleName);
      if (defaultApp && defaultApp.isSystemApp === this.isSystemApp) {
        this.bundleName = defaultApp.bundleName as string;
        this.radioController?.initValue(this.compId, defaultApp);
        return;
      }
    } catch (err) {
      LogUtil.error(`${TAG} update browser state fail`);
    }
  }

  private getLabel(defaultApp: AppListInfo): string {
    let label: string = defaultApp?.label as string;
    let text: string = ResourceUtil.getFormatStringSync($r('app.string.system_default'), '');
    return defaultApp?.isSystemApp ? `${label} (${text})` : label;
  }

  private async getDefaultBrowser(): Promise<void> {
    try {
      let data: bundleManager.BundleInfo = await defaultAppMgr.getDefaultApplication(defaultAppMgr.ApplicationType
        .BROWSER);
      this.bundleName = data?.name;
      await this.getDefaultBrowserApp(this.bundleName);
      LogUtil.info(`${TAG} Operation successful. bundleInfo: ${data?.name}`);
    } catch (err) {
      LogUtil.error(`getDefaultBrowser Cause:code: ${err.code} message: ${err.message}`);
      this.setSystemBrowserApp();
    }
  }

  initGroups(appList: AppListInfo[]): void {
    LogUtil.info(`${TAG} initGroups: ${appList.length} ${this.isSystemApp}`);
    let systemBrowsers: AppListInfo[] = [];
    if (this.isSystemApp) {
      systemBrowsers = appList.filter(item => item.isSystemApp);
    } else {
      systemBrowsers = appList.filter(item => !item.isSystemApp);
    }
    if (systemBrowsers.length > 0) {
      this.dataSource?.splice(0, this.dataSource?.length);
      this.dataSource.pushData(...this.createItems(systemBrowsers));
    }
  }

  private setSystemBrowserApp(): void {
    try {
      this.getBrowserList().then((browserListPro) => {
        const systemBrowserApp = browserListPro.find(appInfo => appInfo.isSystemApp);
        if (systemBrowserApp && systemBrowserApp.bundleName) {
          DefaultBrowserUtil.setDefaultBrowser(systemBrowserApp.bundleName, 'entry',
            systemBrowserApp.moduleName as string);
          return;
        }
        LogUtil.error(`${TAG} System browser not foundApp`);
      });
    } catch (err) {
      LogUtil.error(`${TAG} System browser set failed`);
    }
  }

  private createItems(appList: AppListInfo[]): SettingItemModel[] {
    let items: SettingItemModel[] = [];
    for (let appInfo of appList) {
      let item: SettingItemModel = {
        id: appInfo.bundleName as string,
        type: ItemType.ITEM_TYPE_STANDARD,
        icon: {
          icon: appInfo.icon as PixelMap,
          iconType: SettingIconType.ICON_TYPE_APPICON,
          style: this.getIconStyle()
        },
        title: { content: this.getLabel(appInfo) },
        result: {
          type: ItemResultType.RESULT_TYPE_RADIO,
          result: {
            style: { width: 22, height: 22, showUnchecked: true },
            checked: this.setChecked(appInfo),
          },
        },
        compControl: {
          init: (param: CompCtrlParam) => {},
          destroy: () => {},
          onClick: (component: SettingBaseModel) => {
            this.radioController?.onItemClick(this.compId, appInfo);
          }
        }
      };
      items.push(item);
    }
    return items;
  }

  private getIconStyle(): SettingIconStyle {
    // 接入了HDS之后，图标不需要主动做描边处理
    let style: SettingIconStyle = {
      border: { width: '0px', color: '#00000000', radius: 0 },
      borderRadius: 0,
      width: 48,
      height: 48,
      mirrored: false
    };
    return style;
  }

  private setChecked(appInfo: AppListInfo): boolean | undefined {
    LogUtil.info(`${TAG} setChecked ${this.bundleName}`);
    return this.bundleName === appInfo.bundleName;
  }
}