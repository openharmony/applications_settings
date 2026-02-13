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
  ComponentControl
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { preferences } from '@kit.ArkData';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { AppDataModel, AppListInfo, SettingAppGroupModel } from '../model/SettingAppItemModel';
import { notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingResultState,
  SettingStateType } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import {
  ItemDetailType,
  ItemResultType,
  ItemType, SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { ResourceManagerUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceManagerUtil';
import { MemoryMgrUtils } from '@ohos/settings.common/src/main/ets/utils/MemoryMgrUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { AppEntry } from '../AppModel';

const TAG = 'DefaultBrowserItemController';
const BROWSER_LIST_DATA: string = 'browser_list_data';

export class DefaultBrowserItemController implements ComponentControl {
  private compId: string = '';
  private dataSource: DynamicDataSource = new DynamicDataSource();
  private entry: AppEntry | null = null;
  private bundleName: string = '';
  private isBrowser: boolean = false;
  private result: string = '';

  private refreshData = (entry: AppEntry) => {
    if (!entry) {
      LogUtil.error(`${TAG} appEntry is invalid`);
      return;
    }
    LogUtil.info(`${TAG} receive app change: ${entry.name}`);
    this.entry = entry;
    this.bundleName = entry?.name;
    this.initDefaultBrowser();
  }

  private browserListChangeEventCb = (data: object) => {
    LogUtil.info(`${TAG} browser list changed`);
    this.checkBrowser();
  };

  private browserAppSelectEventCb = (data: object) => {
    this.getDefaultBrowser();
  };

  init(compParam: CompCtrlParam): void {
    LogUtil.showInfo(TAG, `onInit`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    this.compId = compParam.compId;
    this.dataSource = compParam.dataSource as DynamicDataSource;
    let appItem: SettingAppGroupModel = compParam.component as SettingAppGroupModel;
    this.entry = appItem.entry as AppEntry;
    if (this.entry) {
      this.refreshData(this.entry);
    }
    EventBus.getInstance().on('DEFAULT_BROWSER_APP_SELECT', this.browserAppSelectEventCb);
    EventBus.getInstance().on('EVENT_ID_BROWSER_LIST_CHANGE_EVENTS', this.browserListChangeEventCb);
  }

  destroy(): void {
    LogUtil.showInfo(TAG, 'onDestroy');
    EventBus.getInstance().detach('DEFAULT_BROWSER_APP_SELECT', this.browserAppSelectEventCb);
    EventBus.getInstance().detach('EVENT_ID_BROWSER_LIST_CHANGE_EVENTS', this.browserListChangeEventCb);
  }

  private async initDefaultBrowser(): Promise<void> {
    if (!this.entry) {
      LogUtil.error(`${TAG} entry invalid`);
      return;
    }
    await this.checkBrowser();
    await this.getDefaultBrowser();
    LogUtil.info(`${TAG} entry default_browser_settings: ${this.entry?.name} ${this.isBrowser} ${this.result}`);
    if (this.isBrowser) {
      this.dataSource?.splice(0, this.dataSource.length);
      this.dataSource.pushData(this.createDefaultBrowserItem(() => {
        LogUtil.info(`${TAG} entry default_browser_settings: ${this.entry?.name}`);
        PageRouter.push(NavEntryKey.DEFAULT_BROWSER_ENTRY, new PushParam({
          bundleName: this.entry?.name,
          uid: this.entry?.appInfo?.uid,
        } as AppDataModel));
      }))
    }
  }

  private createDefaultBrowserItem(onItemClick: () => void): SettingItemModel {
    return {
      id: 'DefaultBrowser',
      type: ItemType.ITEM_TYPE_STANDARD,
      title: { content: $r('app.string.default_browser') },
      result: {
        type: ItemResultType.RESULT_TYPE_TEXT,
        result: {
          content: this.result,
        }
      },
      detail: {
        type: ItemDetailType.DETAIL_TYPE_CUSTOM,
        icon: $r('sys.symbol.chevron_right'),
        isSymbolIcon: true,
        destination: NavEntryKey.DEFAULT_BROWSER_ENTRY,
        onItemClick: () => {
          onItemClick();
        }
      }
    }
  }

  private async checkBrowser(): Promise<void> {
    let data: preferences.ValueType = await PreferencesUtil.get(BROWSER_LIST_DATA, '');
    if (data) {
      let defaultList: bundle.AbilityInfo[] = [];
      try {
        defaultList = JSON.parse(data as string);
        LogUtil.info(`${TAG} defaultList parse ${defaultList.length}`);
      } catch (error) {
        LogUtil.info(`${TAG} defaultList parse fail`);
      }
      const bundleNameList: string[] = defaultList?.map((item: bundle.AbilityInfo) => item.bundleName);
      this.isBrowser = bundleNameList.some((item: string) => {
        return item === this.bundleName;
      });
    }
    LogUtil.info(`${TAG} isBrowser: ${this.isBrowser}`);
    this.setVisible(this.isBrowser);
  }

  private async getDefaultBrowser(): Promise<void> {
    try {
      let data: bundleManager.BundleInfo = await defaultAppMgr.getDefaultApplication(defaultAppMgr.ApplicationType
        .BROWSER);
      let curStateBundleName: string = data?.name;
      await this.getDefaultBrowserApp(curStateBundleName);
      LogUtil.info(`${TAG} getDefaultBrowser success`);
    } catch (error) {
      LogUtil.error(`${TAG} getDefaultBrowser fail Cause: ${error?.message} `);
    }
  }

  private async getDefaultBrowserApp(curDefaultBrowserAPPValue: string) {
    try {
      let browserListPro: AppListInfo[] = await this.getBrowserList();
      this.refreshDefaultBrowserApp(curDefaultBrowserAPPValue, browserListPro);
    } catch (err) {
      LogUtil.error(`${TAG} update nfc service state, ${err?.message}`);
    }
  }

  private refreshDefaultBrowserApp(curDefaultBrowserAPPValue: string, browserListPro: AppListInfo[]) {
    const defaultBrowserApp: AppListInfo | undefined = browserListPro.find(
      browser => curDefaultBrowserAPPValue === browser.bundleName
    );
    LogUtil.info(`${TAG} refreshDefaultBrowserApp, ${defaultBrowserApp?.bundleName}`);
    if (defaultBrowserApp?.label) {
      let text = ResourceUtil.getFormatStringSync($r('app.string.system_default'), '');
      let defaultBrowserAPPLabel = defaultBrowserApp?.label;
      this.result = defaultBrowserApp?.bundleName === 'com.ohos.browser' ?
        `${defaultBrowserAPPLabel} (${text})` : defaultBrowserAPPLabel;
      LogUtil.info(`${TAG} refreshDefaultBrowserApp,${this.result}`);
      notifyCompStateChange('Setting.AppDetail.DefaultBrowserGroup.DefaultBrowser',
        new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
          { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: this.result } } as SettingResultState]]));
    }
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

      browserList.forEach((browserListItem: bundle.AbilityInfo, index) => {
        const resourceManager = ResourceManagerUtil.getBundleResourceManager(browserListItem?.bundleName)!;
        let label = resourceManager.getStringSync(browserListItem?.labelId);
        browserListPro.push({
          labelId: browserListItem?.labelId as number,
          label,
          bundleName: browserListItem?.bundleName,
          name: browserListItem?.name,
          isSystemApp: browserListItem?.applicationInfo?.systemApp,
          moduleName: browserListItem?.moduleName
        });
        MemoryMgrUtils.removeNapiWrap(resourceManager, false);
      });
      LogUtil.info(`${TAG} browserlistPro, ${browserListPro.length}`);
    } catch (error) {
      LogUtil.error(`${TAG} catch error : ${error?.message}`);
    }
    return browserListPro;
  }

  private setVisible(isBrowser: boolean) {
    notifyCompStateChange('Setting.AppDetail.DefaultBrowserGroup',
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_GROUP_VISIBLE, {
        state: isBrowser
      } as SettingCompState]]));
  }
}