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
import bundle from '@ohos.bundle.bundleManager';
import configPolicy from '@ohos.configPolicy';
import fs from '@ohos.file.fs';
import deviceInfo from '@ohos.deviceInfo';
// import search from '@hms.ai.search';
import type common from '@ohos.app.ability.common';
import taskpool from '@ohos.taskpool';
import { JSON } from '@kit.ArkTS';
import { bundleResourceManager } from '@kit.AbilityKit';
import {
  BundleStatusChangeListener,
  BundleStatusChangeManager
} from '@ohos/settings.common/src/main/ets/bundle/BundleStatusChangeManager';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import SearchItemInfoManager from '@ohos/settings.common/src/main/ets/data/SearchItemInfoManager';
import SearchItemOperationManager from '@ohos/settings.common/src/main/ets/data/SearchItemOperationManager';
import { SearchItemOperation } from '@ohos/settings.common/src/main/ets/data/types';
import { Constants, PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { ContextUtils } from '@ohos/settings.common/src/main/ets/utils/baseutils/ContextUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { SearchItem, SearchPage, SearchPageConfig } from '../model/SearchPageConfig';
import { ExternalInfo, ExternalInfoConfig } from '../model/ExternalInfoConfig';
import {
  HideMenu,
  ItemInfo,
  RenderItemChildrenInfo,
  RenderItemInfo,
  ResultItemInfo,
} from '../model/type';
import { SearchConfigFileParser } from '../util/SearchConfigFileParser';
import { PageInfo, PageInfoConfig } from '../model/PageInfoConfig';
import { SettingPageDescController } from './SettingPageDescController';
import { UpgradeConfig, UpgradeInfo } from '../model/UpgradeConfig';
import lazy { CheckItemUtil } from '../util/CheckItemUtil';
import lazy { SearchResourceManager } from './SearchResourceManager';
import lazy { HideSearchItemsConfig } from '../model/HideSearchItemsConfig';
import { initExternalSearchData } from '../util/SearchTaskPoolManager';
import { ResourceManagerUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceManagerUtil';
import { SearchRDBController } from './SearchRDBController';

const TAG: string = 'SearchController';
const phoneSearchConfigPath: string = 'searchConfig/phone/searchPage.json';
const padSearchConfigPath: string = 'searchConfig/pad/searchPage.json';
const pcSearchConfigPath: string = 'searchConfig/phone/searchPage.json';
const externalConfigPath: string = 'searchConfig/externalInfo.json'
const ccmPageConfigPath: string = 'etc/settings/hide_menu.json';
const pageInfoConfigPath: string = 'searchConfig/pageInfo.json';
const UPGRADE_CONFIG: string = 'searchConfig/upgrade.json';
const BUNDLE_NOT_FOUND: number = 17700001;
const BUNDLE_DISABLED: number = 17700026;

export class SearchDataController {
  public static searchController: SearchDataController | undefined = undefined;
  private static latestRdbVersion: number = 0;
  private static localeChangingSet: Set<string> = new Set();
  private externalPageConfigCache: ExternalInfoConfig | undefined;
  private readonly bundleStatusCallback: BundleStatusChangeListener = {
    onBundleAdd: (bundleName, userId, appIndex) => {
      LogUtil.info(`${TAG} bundleStatusCallback add : bundleName:${bundleName} userId:${userId} appIndex:${appIndex}`);
      SearchDataController.getInstance().updateSearchItemInfo(bundleName, true);
    },
    onBundleRemove: (bundleName, userId, appIndex) => {
      LogUtil.info(`${TAG} bundleStatusCallback remove : bundleName:${bundleName} userId:${userId} appIndex:${appIndex}`);
      SearchDataController.getInstance().updateSearchItemInfo(bundleName, false);
    },
    onBundleUpdate: (bundleName, userId, appIndex) => {
      LogUtil.info(`${TAG} bundleStatusCallback update : bundleName:${bundleName} userId:${userId} appIndex:${appIndex}`);
    },
    getListenerName: (): string => {
      return TAG;
    }
  };

  public static getInstance(): SearchDataController {
    if (SearchDataController.searchController) {
      return SearchDataController.searchController;
    }
    SearchDataController.searchController = new SearchDataController();
    return SearchDataController.searchController;
  }

  public static async initSearchTable(): Promise<void> {
    LogUtil.showInfo(TAG, 'start initSearchTable');
    let rdbStore = await SearchItemInfoManager.getRdbStore();
    if (!rdbStore) {
      LogUtil.showError(TAG, 'initSearchTable get rdbStore error');
      return;
    }
    // 初始化操作记录表
    let rdbStoreOp = await SearchItemOperationManager.getRdbStore();
    if (!rdbStoreOp) {
      LogUtil.showError(TAG, 'initSearchItemOperationTable get rdbStore error');
      return;
    }

    let property: string = `ItemInfo${i18n.System.getSystemLocale()}${Constants.ITEMINFO_TABLE_VERSION}`;
    if (await PreferencesUtil.has(property)) {
      LogUtil.showInfo(TAG, 'search table has already init');
      return;
    }
    let versionInDb: number = rdbStore.version;
    let upgradeSqlList: string[] = await SearchDataController.getUpgradeSql(versionInDb);
    LogUtil.showInfo(TAG, `current dbVersion: ${versionInDb}, latestVersion: ${SearchDataController.latestRdbVersion}`);
    /* instrument ignore if*/
    if (SearchDataController.latestRdbVersion > versionInDb && upgradeSqlList.length > 0) {
      await SearchItemInfoManager.upgradeDb(upgradeSqlList, SearchDataController.latestRdbVersion);
    }
  }

  // instrument ignore next
  static async updateSearchData(): Promise<void> {
    LogUtil.info(`${TAG} start update SearchData to DataBase. updateSearchData`);
    if (await PreferencesUtil.has(`InitUpdateItemInfo${Constants.ITEMINFO_TABLE_VERSION}`)) {
      LogUtil.info(`${TAG} InitUpdateItemInfo has done`);
      return;
    }
    await SearchItemInfoManager.updateSearchItemData();
    await PreferencesUtil.put(`InitUpdateItemInfo${Constants.ITEMINFO_TABLE_VERSION}`, 'done');
  }

  /**
   * 清空搜索数据
   * @returns
   */
  static async deleteSearchData(): Promise<void> {
    LogUtil.info(`${TAG} start delete SearchData`);
    if (await PreferencesUtil.has(`ClearItemInfoTable${Constants.ITEMINFO_TABLE_VERSION}`)) {
      LogUtil.info(`${TAG} ClearItemInfoTable has done`);
      return;
    }
    await SearchItemInfoManager.clearSearchData();
    await PreferencesUtil.put(`ClearItemInfoTable${Constants.ITEMINFO_TABLE_VERSION}`, 'done');
  }

  /**
   * 初始化搜索数据到数据库
   * @returns
   */
  static async initSearchData(): Promise<void> {
    LogUtil.info(`${TAG} start init SearchData to DataBase`);
    let curLocale: string = i18n.System.getSystemLocale();
    LogUtil.info(`${TAG} start init SearchData to DataBase ${curLocale}`);
    // await SearchRDBController.initData()
    await SearchRDBController.initialize()
    if (await PreferencesUtil.has(`ItemInfo${curLocale}${Constants.ITEMINFO_TABLE_VERSION}`)) {
      LogUtil.info(`${TAG} ${curLocale}${Constants.ITEMINFO_TABLE_VERSION} has done`);
      return;
    }

    if (SearchDataController.localeChangingSet.has(curLocale)) {
      LogUtil.showInfo(TAG, 'current locale search item is updating');
      return;
    }
    SearchDataController.localeChangingSet.add(curLocale);
    await SearchItemInfoManager.deleteSearchItem(curLocale);

    let hideSearchConfig: HideSearchItemsConfig = await SearchDataController.getInstance().getHideSearchConfig();
    let searchResourceManager: SearchResourceManager = new SearchResourceManager(curLocale);
    await SearchDataController.initInternalSearchData(hideSearchConfig, curLocale, searchResourceManager);
    await SearchDataController.initExternalSearchData(curLocale);
    await SearchDataController.updateOperationSearchItem();
    await PreferencesUtil.put(`ItemInfo${curLocale}${Constants.ITEMINFO_TABLE_VERSION}`, 'done');
    SearchDataController.localeChangingSet.delete(curLocale);
  }

  // instrument ignore next
  private static async initInternalSearchData(hideSearchConfig: HideSearchItemsConfig,
    curLocale: string, resourceManager: SearchResourceManager): Promise<void> {
    let searchPageConfig: SearchPageConfig | undefined = await SearchConfigFileParser.getInstance()
      .parserSearchPageConfig(DeviceUtil.isDevicePc() ? pcSearchConfigPath : DeviceUtil.isDevicePad() ?
        padSearchConfigPath : phoneSearchConfigPath);
    LogUtil.info(`${TAG} searchPageConfig content`);
    if (!searchPageConfig) {
      LogUtil.warn(`${TAG} parse ${phoneSearchConfigPath} not find`);
      return;
    }

    try {
      LogUtil.info(`${TAG} getSearchPage size:${searchPageConfig.searchPages.length}`);
      for (let searchPage of searchPageConfig.searchPages) {
        if (hideSearchConfig.menuEntryList.includes(searchPage.entryKey)) {
          LogUtil.warn(`${TAG} searchPage need hide`);
          continue;
        }
        LogUtil.info(`${TAG} internal search page entrykey:${searchPage.entryKey}`);
        let itemInfoList = await SearchDataController.getItemInfoList(searchPage, curLocale, resourceManager);
        LogUtil.info(`${TAG} itemInfoList: ${itemInfoList?.length}`);
        if (itemInfoList?.length > 0) {
          await SearchItemInfoManager.batchInsertSearchItemData(itemInfoList, hideSearchConfig.getItemList());
        }
      }
      HiSysEventUtil.searchReportEvent(TAG, 'initSearchData success');
    } catch (error) {
      LogUtil.error(`${TAG} parse error ${error?.message}`);
      HiSysEventUtil.searchReportEvent(TAG, `json file parse error ${error?.message}`);
    }
  }

  private static async initExternalSearchData(curLocale: string): Promise<void> {
    LogUtil.info(`${TAG} start init SearchData for external to DataBase. initExternalSearchData`);
    let externalConfig: ExternalInfoConfig | undefined = await SearchConfigFileParser.getInstance()
      .parserExternalInfoConfig(externalConfigPath);
    LogUtil.info(`${TAG} externalConfig content: ${externalConfigPath}`);
    if (externalConfig) {
      try {
        let context: common.Context = ContextUtils.getContext();
        let task: taskpool.Task =
          new taskpool.Task(initExternalSearchData, externalConfig.externalInfos, curLocale, context);
        await taskpool.execute(task, taskpool.Priority.MEDIUM);
      } catch (error) {
        LogUtil.error(`${TAG} catch exception when initExternalSearchData, errcode: ${error?.code}, errmsg: ${error?.message}`);
      }
    }
    LogUtil.info(`${TAG} init SearchData for external to DataBase end. initExternalSearchData`);
  }

  /**
   * 加载操作历史记录中的搜索项，并更新回数据库中
   */
  private static async updateOperationSearchItem(): Promise<void> {
    LogUtil.info(`${TAG} updateOperationSearchItem start.`);
    try {
      // 读取操作历史记录表
      let operationData: SearchItemOperation[] = await SearchItemOperationManager.querySearchItemOperationData();
      LogUtil.info(`${TAG} Query SearchItemOperation List size:  ${operationData.length}`);
      // 配置文件中不存在的，需要额外加入到入库项中
      for (let itemOperation of operationData) {
        let itemInfo = itemOperation;
        if (itemOperation.status === 'delete') {
          itemInfo.enable = false;
        } else {
          itemInfo.enable = (itemOperation.content === '1');
        }
        // 更新搜索项中的值
        await SearchItemInfoManager.insertOrUpdateSearchItemData(itemInfo);
      }
    } catch (error) {
      LogUtil.error(`${TAG} updateOperationSearchItem error, errcode: ${error?.code}, errmsg: ${error?.message}`);
    }
    LogUtil.info(`${TAG} updateOperationSearchItem end.`);
  }

  private static async getItemInfoList(searchPage: SearchPage, curLocale: string,
    resourceManager: SearchResourceManager, bundleName?: string, context?: common.Context): Promise<Array<ItemInfo>> {
    let searchItemList: SearchItem[] = searchPage.searchItems;
    LogUtil.info(`${TAG} searchItemList: ${searchItemList?.length} ${searchPage.supportDevices}`);
    let itemInfoList: ItemInfo[] = [];
    /* instrument ignore if*/
    if (CheckEmptyUtils.isEmpty(searchItemList) ||
      !SearchDataController.checkIsDeviceSupport(searchPage.supportDevices)) {
      LogUtil.warn(`${TAG} searchItemList is not supported or empty`);
      return itemInfoList;
    }
    for (let searchItem of searchItemList) {
      LogUtil.info(`${TAG} searchItem.itemTitle: ${searchItem.itemTitle} ${searchItem.supportDevices}`);
      /* instrument ignore if*/
      if (!SearchDataController.checkIsDeviceSupport(searchItem.supportDevices)) {
        LogUtil.warn(`${TAG} searchItem is not supported`);
        continue;
      }
      let itemInfo: ItemInfo = {
        locale: curLocale,
        itemName: searchItem.itemName,
        itemTitle: searchItem.itemTitle === '$string:time_24_hour_title' ?
          resourceManager.getNumberFormatStringSync($r('app.string.time_24_hour_title'), '24') :
          bundleName ? resourceManager.getExternalStringByName(bundleName, searchItem.itemTitle) : resourceManager
            .getStringByName(searchItem.itemTitle),
        itemDescription: searchItem.itemDescription,
        entryKey: searchPage.entryKey,
        pageTitle: bundleName ? resourceManager.getExternalStringByName(bundleName, searchPage.pageTitle) :
          resourceManager.getStringByName(searchPage.pageTitle),
        params: searchPage.params,
        enable: await (context ? CheckItemUtil.checkItemEnable(searchItem, context) :
          CheckItemUtil.checkItemEnable(searchItem)),
        icon: searchItem.icon,
        alias: searchItem.alias,
        path: resourceManager.getPathByName(bundleName as string, searchPage.path, bundleName !== undefined),
        childItems: searchItem.childItems,
        bundleName: bundleName ?? PackagesConstant.SETTINGS_BUNDLE_NAME,
        checkType: searchItem.checkItem?.type ?? '',
        checkKey: searchItem.checkItem?.checkKey ?? '',
        checkValue: searchItem.checkItem?.value ?? '',
      };
      LogUtil.debug(`${TAG} itemInfo`);
      itemInfoList.push(itemInfo);
    }
    return itemInfoList;
  }

  // instrument ignore next
  public static async processExternalItemInfoList(externalBundle: ExternalInfo, curLocale: string,
    hideSearchConfig: HideSearchItemsConfig, resourceManager: SearchResourceManager,
    context?: common.Context): Promise<void> {
    let bundleInfo: bundle.BundleInfo;
    try {
      bundleInfo = bundle.getBundleInfoSync(externalBundle.bundleName, bundle.BundleFlag
        .GET_BUNDLE_INFO_WITH_APPLICATION | bundle.BundleFlag.GET_BUNDLE_INFO_WITH_METADATA);
      if (!bundleInfo?.appInfo?.systemApp) {
        LogUtil.error(`${TAG} processExternalItemInfoList ${externalBundle.bundleName} is not system app`);
        return;
      }
    } catch (err) {
      LogUtil.error(`${TAG} processExternalItemInfoList failed, code: ${err?.code}, message: ${err?.message}.`);
      return;
    }
    const findMetaData = bundleInfo?.appInfo?.metadataArray?.find(metaData => metaData.moduleName === externalBundle
      .moduleName);
    if (!findMetaData) {
      LogUtil.error(`${TAG} processExternalItemInfoList failed, not find meta data`);
      return;
    }

    const externalSearchConfig = findMetaData?.metadata?.find(meta => meta.name === 'action.settings.search.path');
    if (!externalSearchConfig) {
      LogUtil.error(`${TAG} processExternalItemInfoList failed, not find search config`);
      return;
    }

    let externalSearchPageConfig: SearchPageConfig | undefined = await SearchConfigFileParser.getInstance()
      .parseExternalSearchPageConfig(externalBundle.bundleName, externalSearchConfig?.value);
    LogUtil.info(`${TAG} externalSearchPageConfig content`);
    if (!externalSearchPageConfig) {
      LogUtil.error(`${TAG} processExternalItemInfoList failed, externalConfig not found`);
      return;
    }

    try {
      LogUtil.info(`${TAG} getExternalSearchPage Size:${externalSearchPageConfig.searchPages.length}`);
      for (let externalSearchPage of externalSearchPageConfig.searchPages) {
        LogUtil.info(`${TAG} externalSearchPage entrykey:${externalSearchPage.entryKey}`);
        if (hideSearchConfig.menuEntryList.includes(externalSearchPage.entryKey)) {
          LogUtil.info(`${TAG} externalSearchPage ${externalSearchPage.entryKey} need hide`);
          continue;
        }
        let externalItemInfoList = await SearchDataController.getItemInfoList(externalSearchPage, curLocale,
          resourceManager, externalBundle.bundleName, context);
        LogUtil.info(`${TAG} externalItemInfoList: ${externalItemInfoList?.length}`);
        if (externalItemInfoList.length > 0) {
          await SearchItemInfoManager.batchInsertSearchItemData(externalItemInfoList, hideSearchConfig.itemList,
            context);
        }
      }
      HiSysEventUtil.searchReportEvent(TAG, 'initExternalSearchData success');
    } catch (error) {
      LogUtil.error(`${TAG} parse error ${error?.message}`);
      HiSysEventUtil.searchReportEvent(TAG, `json file parse error ${error?.message}`);
    }
  }


  async getSearchResult(value: string,
    queryMetaService?: (value: string) => RenderItemInfo[]): Promise<RenderItemInfo[]> {
    try {

      const result = await SearchRDBController.queryAllItems(value)
      // 3. 处理查询结果
      LogUtil.info(TAG + 'getSearchResult' + JSON.stringify(result))

      let retResult: RenderItemInfo[] = [];
      if (result?.length) {
        let resList = result.filter((item) => item.locale === i18n.System.getSystemLocale());
        retResult = await SearchDataController.getInstance().getSearchItemInfo(resList, value);
      }
      await SearchDataController.getInstance().initApplicationResult(value, retResult, queryMetaService);
      // instrument ignore next
      retResult.sort((firstItem, secondItem) => {
        if (firstItem.isOuterApp && secondItem.isOuterApp) {
          return 0;
        }
        if (firstItem.isOuterApp) {
          return 1;
        }
        if (secondItem.isOuterApp) {
          return -1;
        }
        return 0;
      });
      retResult.sort((firstItem, secondItem) => {
        if (firstItem.isOuterApp && secondItem.isOuterApp) {
          return 0;
        }
        if (firstItem.isOuterApp) {
          return 1;
        }
        if (secondItem.isOuterApp) {
          return -1;
        }
        return 0;
      });
      return retResult;
    } catch (error) {
      LogUtil.error(`${TAG} getSearchResult error: ${error?.message}`);
    }
    return new Promise((res) => {
      let defaultResult: RenderItemInfo[] = [];
      res(defaultResult);
    });
  }

  private async initApplicationResult(value: string, retResult: RenderItemInfo[],
    queryMetaService?: (value: string) => RenderItemInfo[]): Promise<void> {
    /* instrument ignore if*/
    if (!queryMetaService) {
      LogUtil.showWarn(TAG, 'no queryMetaService');
      return;
    }
    LogUtil.showInfo(TAG, 'start query metaService');
    let serviceResults: RenderItemInfo[] = queryMetaService(value);
    retResult.push(...serviceResults)
  }

  // private async initAppSearchResult(value: string, retResult: RenderItemInfo[],
  //   searchSession: search.SearchSession): Promise<void> {
  //   try {
  //     let appQuery: search.Query = DeviceUtil.isDevicePc() ? SearchAppsDataConfig.getPcSearchQuery(value)
  //       : SearchAppsDataConfig.getSearchQuery(value);
  //     let appResult: search.SearchResult<ResultItemInfo> = await searchSession.search(appQuery);
  //     LogUtil.info(`${TAG} appResult: ${JSON.stringify(appResult)}`);
  //     if (appResult.records?.length) {
  //       let appSearchRenders: RenderItemInfo[] = SearchDataController.getInstance().appResult2RenderItemInfo(appResult);
  //       retResult.push(...appSearchRenders)
  //     }
  //   } catch (e) {
  //     LogUtil.error(`${TAG} initAppSearchResult error: ${e?.code}`);
  //   }
  // }

  // private appResult2RenderItemInfo(appResult: search.SearchResult<ResultItemInfo>): RenderItemInfo[] {
  //   let ret: RenderItemInfo[] = [];
  //   for (let item of appResult.records) {
  //     /* instrument ignore if*/
  //     if (!item || this.isRequiredFilter(item)) {
  //       continue;
  //     }
  //     // pc上分身应用的名称需要加上应用id
  //     let appName: string =
  //       `${item.appName}${DeviceUtil.isDevicePc() && item.appIndex && item.appIndex > 0 ? item.appIndex : ''}`;
  //     let renderItem: RenderItemInfo = {
  //       entryKey: item.bundleName,
  //       isOuterApp: false,
  //       children: [{
  //         title: appName.split(new RegExp(`<|>`, 'gi')),
  //         entryKey: item.bundleName,
  //         path: '',
  //         parentKey: '',
  //         itemName: '',
  //         params: '',
  //         isApp: true,
  //         appName: appName.split(new RegExp(`<em>|</em>`, 'gi')).join(''),
  //         appIndex: item.appIndex,
  //         isOuterApp: false,
  //         installSource: item.installSource
  //       }]
  //     }
  //     ret.push(renderItem);
  //   }
  //   return ret;
  // }

  // private isRequiredFilter(item: ResultItemInfo): boolean {
  //   if (item.appStatus !== 0) {
  //     LogUtil.info(`${TAG} app not installed: ${item.bundleName}`);
  //     return true;
  //   }
  //   if (item.bundleName === 'com.ohos.contacts' && item.typeId === 0 && item.shortcutId === '') {
  //     LogUtil.debug(`${TAG} filter contacts app`);
  //     return true;
  //   }
  //   if (item.bundleName === 'com.ohos.vassistant') {
  //     LogUtil.debug(`${TAG} filter xiaoyi app`);
  //     return true;
  //   }
  //   return false;
  // }

  public registerStatusChange(): void {
    BundleStatusChangeManager.getInstance().registerBundleChangedListener(this.bundleStatusCallback);
  }

  public unRegisterStatusChange(): void {
    BundleStatusChangeManager.getInstance().unRegisterBundleChangedListener(this.bundleStatusCallback);
  }

  public async updateRemovableBundles(): Promise<void> {
    LogUtil.info(`${TAG} updateRemovableBundles start`);
    if (!this.externalPageConfigCache) {
      this.externalPageConfigCache = await SearchConfigFileParser.getInstance()
        .parserExternalInfoConfig(externalConfigPath);
    }

    if (!this.externalPageConfigCache) {
      LogUtil.showError(TAG, 'updateRemovableBundles failed, parserExternalInfoConfig fail');
      return;
    }

    this.externalPageConfigCache.externalInfos.forEach(bundleInfo => {
      if (bundleInfo && bundleInfo.removable) {
        try {
          bundle.getBundleInfoSync(bundleInfo.bundleName, bundle.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
          this.updateSearchItemInfo(bundleInfo.bundleName, true);
        } catch (err) {
          if (err?.code === BUNDLE_NOT_FOUND || err?.code === BUNDLE_DISABLED) {
            this.updateSearchItemInfo(bundleInfo.bundleName, false);
          }
        }
      }
    });
  }

  public async updateSearchItemStatus(itemName: string, enable: boolean): Promise<void> {
    if (CheckEmptyUtils.isEmpty(itemName)) {
      LogUtil.showError(TAG, 'updateSearchItemStatus failed, itemName is empty');
      return;
    }
    await SearchItemInfoManager.updateSearchItem(itemName, enable);
  }

  public async updateSearchEntryStatus(entryKey: string, enable: boolean): Promise<void> {
    if (CheckEmptyUtils.isEmpty(entryKey)) {
      LogUtil.showError(TAG, 'updateSearchEntryStatus failed, entryKey is empty');
      return;
    }
    await SearchItemInfoManager.updateSearchEntry(entryKey, enable);
  }

  public async initExternalSearchDataWithBundleName(bundleName: string): Promise<void> {
    if (CheckEmptyUtils.isEmpty(bundleName)) {
      LogUtil.error(`${TAG} initExternalSearchDataWithBundleName failed, bundleName is empty`);
      return;
    }

    let externalConfig: ExternalInfoConfig | undefined = await SearchConfigFileParser.getInstance()
      .parserExternalInfoConfig(externalConfigPath);
    LogUtil.info(`${TAG} externalConfig content: ${externalConfigPath}`);
    if (externalConfig) {
      for (let bundle of externalConfig.externalInfos) {
        if (bundle.bundleName !== bundleName) {
          continue;
        }
        LogUtil.info(`${TAG} initExternalSearchDataWithBundleName, bundleName: ${bundleName}`);
        let curLocale: string = i18n.System.getSystemLocale();
        let hideSearchConfig: HideSearchItemsConfig = await SearchDataController.getInstance().getHideSearchConfig();
        let searchResourceManager: SearchResourceManager = new SearchResourceManager(curLocale);
        await SearchDataController.processExternalItemInfoList(bundle, curLocale, hideSearchConfig,
          searchResourceManager);
      }
      AbilityUtils.timeoutForceGC(1000, 'SearchController->initExternalSearchDataWithBundleName');
    }
  }

  /**
   * 修改子项的搜索使能
   *
   * @param itemName parent
   * @param enable true：可以搜索
   * @param checkList 需要重新使能的子项列表
   */
  public async updateChildItemSearchStatus(itemName: string, enable: boolean, checkList?: string[]): Promise<void> {
    if (CheckEmptyUtils.isEmpty(itemName)) {
      LogUtil.showError(TAG, 'updateChildItemSearchStatus failed, itemName is empty');
      return;
    }

    let resultArr = await SearchItemInfoManager.queryChildItems(itemName);
    if (CheckEmptyUtils.isEmptyArr(resultArr)) {
      LogUtil.showError(TAG, 'updateChildItemSearchStatus failed, childItems is empty');
      return;
    }

    for (let item of resultArr) {
      await SearchItemInfoManager.updateSearchItem(item, enable);
    }
    this.updateChildSearchStatusUseFunction(enable, checkList);
  }

  private async updateChildSearchStatusUseFunction(enable: boolean, checkList?: string[]): Promise<void> {
    if (checkList && enable) {
      for (let item of checkList) {
        let checkEnable = await CheckItemUtil.checkChildItemEnable(item, enable);
        SearchItemInfoManager.updateSearchItem(item, checkEnable);
      }
    }
  }

  public async getHideSearchConfig(): Promise<HideSearchItemsConfig> {
    let ccmConfigStr = await this.getCcmPageConfigStr();
    let hideSearchConfig: HideSearchItemsConfig = new HideSearchItemsConfig();
    if (CheckEmptyUtils.checkStrIsEmpty(ccmConfigStr)) {
      LogUtil.showInfo(TAG, 'Hide menu ccm config is empty');
      return hideSearchConfig;
    }

    let hideMenuList: HideMenu[] = [];
    try {
      hideMenuList = JSON.parse(ccmConfigStr) as HideMenu[];
    } catch (err) {
      LogUtil.showError(TAG, `parse ccm config error: ${err?.message}`);
    }

    if (CheckEmptyUtils.isEmpty(hideMenuList)) {
      LogUtil.showInfo(TAG, 'Hide menu list is empty');
      return hideSearchConfig;
    }

    LogUtil.debug(`${TAG} hideMenus :${hideMenuList?.length}`);
    let pageInfoConfig: PageInfoConfig | undefined = await SearchConfigFileParser.getInstance()
      .parserPageInfoConfig(pageInfoConfigPath);
    return SearchDataController.getInstance().getEntryKeyList(pageInfoConfig?.pageInfos, hideMenuList);
  }

  private async getSearchItemInfo(resList: ResultItemInfo[], searchValue: string): Promise<RenderItemInfo[]> {
    let parentMap = new Map<string, RenderItemInfo>();
    for (let item of resList) {
      if (CheckEmptyUtils.checkStrIsEmpty(item.title)) {
        continue;
      }
      let newItem: RenderItemChildrenInfo;
      let topLevelEntry = '';
      let isFromOuter: boolean = (item?.callbackType === 1 && item.wantCallback !== undefined);
      LogUtil.showInfo(TAG, `isFromOuter ${isFromOuter}`);
      if (isFromOuter) {
        let outerNewItem: RenderItemChildrenInfo | undefined = SearchDataController.getInstance()
          .getSearchChildrenItemInfoForOuter(item);
        if (!outerNewItem) {
          continue;
        }
        newItem = outerNewItem;
        topLevelEntry = outerNewItem.entryKey;
      } else {
        newItem = SearchDataController.getInstance()
          .getSearchChildrenItemInfo(item);
        if (item.entryKey === NavEntryKey.OUC_SOFTWARE_UPDATE_SETTINGS) {
          topLevelEntry = NavEntryKey.ABOUT_DEVICE_ENTRY;
        } else {
          topLevelEntry = await SettingPageDescController.getTopLevelEntryKey(newItem.entryKey);
        }
      }
      if (CheckEmptyUtils.checkStrIsEmpty(topLevelEntry)) {
        LogUtil.showWarn(TAG, `topLevelEntry is empty, entryKey: ${newItem.entryKey}`);
        continue;
      }
      let parentMapItem: RenderItemInfo | undefined = parentMap.get(topLevelEntry);
      if (parentMapItem) {
        parentMapItem.children.push(newItem)
      } else {
        parentMap.set(topLevelEntry, {
          entryKey: topLevelEntry,
          isOuterApp: isFromOuter,
          children: [newItem],
          appName: item.appName
        })
      }
    }
    return Array.from(parentMap.values());
  }

  private async getCcmPageConfigStr(): Promise<string> {
    try {
      let filePath: string = await configPolicy.getOneCfgFile(ccmPageConfigPath);
      return fs.readTextSync(filePath);
    } catch (e) {
      LogUtil.error(`${TAG} loadCcmConfigs exception:${e?.code}  ${e?.message}`);
    }
    return '';
  }

  private findSubMenus(pageInfoList: PageInfo[] | undefined, entryKey: string): string[] {
    let subMenus: PageInfo[] = [];
    if (pageInfoList) {
      subMenus = pageInfoList.filter(pageInfo => pageInfo.parentKey === entryKey);
    }
    const menuList = [entryKey];
    for (let i = 0; i < subMenus.length; i++) {
      const subMenu = subMenus[i];
      menuList.push(...this.findSubMenus(pageInfoList, subMenu.entryKey));
    }
    return menuList;
  }

  private getEntryKeyList(pageInfoList: PageInfo[] | undefined, menuList: HideMenu[]): HideSearchItemsConfig {
    let hideSearchConfig: HideSearchItemsConfig = new HideSearchItemsConfig();
    for (let i = 0; i < menuList.length; i++) {
      if (CheckEmptyUtils.isEmptyArr(menuList[i].itemName)) {
        hideSearchConfig.menuEntryList.push(...this.findSubMenus(pageInfoList, menuList[i].key));
      } else {
        hideSearchConfig.itemList.push(...menuList[i].itemName);
      }
    }
    return hideSearchConfig;
  }

  private async updateSearchItemInfo(bundleName: string, isEnable: boolean) {
    LogUtil.info(`${TAG} updateSearchItemInfo start ${bundleName}`);
    if (!this.externalPageConfigCache) {
      this.externalPageConfigCache = await SearchConfigFileParser.getInstance()
        .parserExternalInfoConfig(externalConfigPath);
    }

    LogUtil.debug(`${TAG} externalConfig content: ${externalConfigPath}`);
    if (this.externalPageConfigCache) {
      const findBundleInfo =
        this.externalPageConfigCache.externalInfos.find(bundleInfo => bundleInfo.bundleName === bundleName);
      if (findBundleInfo) {
        SearchItemInfoManager.updateSearchItemByBundle(bundleName, isEnable);
      }
    }
  }

  private getSearchChildrenItemInfo(item: ResultItemInfo): RenderItemChildrenInfo {
    return {
      title: item.title.split(new RegExp(`<|>`, 'gi')),
      entryKey: item.entryKey,
      path: CheckEmptyUtils.checkStrIsEmpty(item.path) ? item.title.split(new RegExp(`<em>|</em>`, 'gi'))
        .join('') : item.path,
      parentKey: item.parentKey,
      params: item.uriParams,
      itemName: item.itemName,
      isOuterApp: false
    };
  }

  private getSearchChildrenItemInfoForOuter(item: ResultItemInfo): RenderItemChildrenInfo | undefined {
    if (item.wantCallback) {
      let wantCallBack = JSON.parse(item.wantCallback) as Want;
      if (CheckEmptyUtils.checkStrIsEmpty(item.appName) &&
        !CheckEmptyUtils.checkStrIsEmpty(wantCallBack.bundleName)) {
        let label = ResourceManagerUtil.getBundleResourceInfo(wantCallBack.bundleName,
          bundleResourceManager.ResourceFlag.GET_RESOURCE_INFO_WITH_LABEL)?.label as string;
        item.appName = label ?? '';
      }
      let renderItemInfo: RenderItemChildrenInfo = {
        title: item.title.split(new RegExp(`<|>`, 'gi')),
        entryKey: wantCallBack.bundleName ?? '',
        path: CheckEmptyUtils.checkStrIsEmpty(item.path) ? item.title.split(new RegExp(`<em>|</em>`, 'gi'))
          .join('') : item.path,
        parentKey: item.parentKey,
        params: item.uriParams,
        itemName: item.itemName,
        appName: item.appName,
        isOuterApp: true,
        bundleName: wantCallBack.bundleName,
        abilityName: wantCallBack.abilityName,
        want: wantCallBack,
        isApp: true
      };
      return renderItemInfo;
    }
    return undefined;
  }

  private static async getUpgradeSql(oldVersion: number): Promise<string[]> {
    let upgradeSqlList: string[] = [];
    try {
      LogUtil.showInfo(TAG, 'read upgrade from json');
      let upgradeConfig: UpgradeConfig | undefined = await SearchConfigFileParser.getInstance()
        .parserUpgradeInfo(UPGRADE_CONFIG);
      if (upgradeConfig) {
        let upgradeInfoList: UpgradeInfo[] = upgradeConfig.upgradeInfos;
        SearchDataController.latestRdbVersion = oldVersion;
        upgradeInfoList.forEach(upgradeInfo => {
          if (upgradeInfo.version > SearchDataController.latestRdbVersion) {
            upgradeSqlList = upgradeSqlList.concat(upgradeInfo.sqlList);
            SearchDataController.latestRdbVersion = upgradeInfo.version;
          }
        });
      }
    } catch (err) {
      LogUtil.showError(TAG, `read upgrade from json error: ${err?.message}`);
    }
    LogUtil.showInfo(TAG, `read upgrade end, length: ${upgradeSqlList.length}`);
    return upgradeSqlList;
  }

  private static checkIsDeviceSupport(supportDevices: Array<string>): boolean {
    if (CheckEmptyUtils.isEmptyArr(supportDevices)) {
      return true;
    }
    let deviceType = deviceInfo.deviceType;
    for (let supportDevice of supportDevices) {
      if (supportDevice === deviceType) {
        return true;
      }
    }
    return false;
  }
}