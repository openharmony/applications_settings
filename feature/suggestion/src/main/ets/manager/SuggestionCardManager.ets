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

import observer from '@ohos.arkui.observer';
import { HashMap, HashSet, taskpool } from '@kit.ArkTS';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import {
  BundleStatusChangeListener,
  BundleStatusChangeManager
} from '@ohos/settings.common/src/main/ets/bundle/BundleStatusChangeManager';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { SuggestionInfo } from '../model/SuggestionInfo';
import SuggestionUtil, { SINGLE_SUGGESTION, SuggestionOperation } from '../util/SuggestionUtil';
import { SuggestionController } from '../controller/SuggestionController';
import { SuggestionDataShareBaseController } from '../controller/SuggestionDataShareBaseController';
import { SuggestionAccessorConfig } from '../constant/SuggestionAccessorConfig';

const TAG: string = 'SuggestionCardManager';

// 最小查询间隔
const QUERY_INTERVAL: number = 300;

@Concurrent
async function querySuggestion(controller: SuggestionController, context: Context): Promise<Array<SuggestionInfo>> {
  LogUtil.info(`SuggestionCardManager querySuggestion`);
  try {
    if (!controller) {
      LogUtil.info(`SuggestionCardManager queryCardData controller invalid`);
      return [];
    }
    let res: SuggestionInfo[] = await controller.getSuggestionList(context);
    res.forEach(suggestionInfo => {
      suggestionInfo.controller = controller;
    });
    return res;
  } catch (err) {
    LogUtil.error(`SuggestionCardManager queryCardData eror: ${err?.message}`);
  }
  return [];
}

export class SuggestionCardManager {
  private static suggestionCardManager: SuggestionCardManager;
  public suggestionInfoList: SuggestionInfo[] = [];
  private callbacks: HashSet<((suggestionList: SuggestionInfo[]) => void)> = new HashSet();
  private controllerList?: SuggestionController[] = undefined;
  private lastGetDataTime: number = 0;
  private bundleList: string[] = [];
  private bundleStatusCallback?: BundleStatusChangeListener = undefined;
  private lastPage:string = NavEntryKey.ABOUT_DEVICE_ENTRY;
  private currentSuggestionPage?: string = undefined;
  private isInQuerying: boolean = false;
  private navDestinationDataCallback: (Callback<observer.NavDestinationInfo>) = (info) => {
    try {
      if (info.state === observer.NavDestinationState.ON_SHOWN) {
        this.initLastPage();
      }
      if (info.state === observer.NavDestinationState.ON_HIDDEN) {
        // NavDestination组件隐藏时操作
        this.refreshDataWhenPageHide(info);
      }
    } catch (err) {
      LogUtil.error(`${TAG} getAllPathName error ${err?.code} ${err?.message}`);
    }
  };

  private refreshDataWhenPageHide(info: observer.NavDestinationInfo): void {
    let pathInfoStack: NavPathStack | undefined = AppStorage.get<NavPathStack>(PackagesConstant.SETTINGS_PATH_STACK);
    let navigationMode: NavigationMode | undefined = AppStorage.get<NavigationMode>('navigationMode');
    const array: string[] | undefined = pathInfoStack?.getAllPathName();
    let pathLength: number | undefined = array?.length;
    LogUtil.info(`${TAG} page hide ${info.name} navigationMode ${navigationMode} pathLength ${pathLength}
     last page ${this.lastPage}`);
    if (pathLength === 0) {
      // 非分栏场景栈清空则代表回到了首页，刷新数据
      LogUtil.info(`${TAG} goto homePage`);
      this.refreshData(getContext());
    }
    if (navigationMode === NavigationMode.Split && pathLength === 1) {
      if (array && array[0] !== this.lastPage && array[0] !== this.currentSuggestionPage) {
        // 分栏场景栈数量为1且和上一次页面不一致时刷新数据
        LogUtil.info(`${TAG} homePage switch tab`);
        this.refreshData(getContext());
      }
    }
  }

  private initLastPage(): void {
    let pathInfoStack: NavPathStack | undefined = AppStorage.get<NavPathStack>(PackagesConstant.SETTINGS_PATH_STACK);
    const array: string[] | undefined = pathInfoStack?.getAllPathName();
    if (array && array?.length === 1) {
      // 记录path数量为1时显示的页面
      LogUtil.info(`${TAG} page show ${array[0]}`);
      this.lastPage = array[0];
    }
  }

  public getNavDestinationDataCallback(): Callback<observer.NavDestinationInfo> {
    return this.navDestinationDataCallback;
  }

  /**
   * 初始化接入方
   */
  async initAccessorController(): Promise<void> {
    LogUtil.info(`${TAG} initAccessorController ${this.controllerList?.length}`);
    if (this.controllerList) {
      return;
    }
    this.controllerList = [];
    SuggestionAccessorConfig.getAccessorList().forEach(accessor => {
      this.controllerList?.push(new SuggestionDataShareBaseController(
        accessor.bundleName,
        accessor.queryUri,
        accessor.isProxy
      ));
    });
    this.controllerList.forEach(controller => {
      this.bundleList.push(controller.bundleName);
    });
  }

  /* instrument ignore next */
  private async filterAndSortSuggestion(suggestionList: SuggestionInfo[]): Promise<SuggestionInfo[]> {
    let supportedCardMap: HashMap<string, number> = await SuggestionUtil.getSupportedCardMap();
    if (supportedCardMap.isEmpty() || CheckEmptyUtils.isEmptyArr(suggestionList)) {
      return [];
    }
    suggestionList = suggestionList.filter(suggestionInfo => {
      if (!suggestionInfo) {
        LogUtil.warn(`${TAG} suggestionInfo is invalid`);
        return false;
      }
      if (!suggestionInfo.title) {
        LogUtil.warn(`${TAG} suggestionInfo title is invalid`);
        return false;
      }
      if (!suggestionInfo.routerUri) {
        LogUtil.warn(`${TAG} routerUri is invalid`);
        return false;
      }
      if (!suggestionInfo.iconImg) {
        LogUtil.warn(`${TAG} suggestionInfo iconImg is invalid`);
        return false;
      }
      return supportedCardMap.hasKey(SuggestionUtil.getCardKeyBySuggestion(suggestionInfo));
    });
    if (CheckEmptyUtils.isEmptyArr(suggestionList)) {
      return [];
    }
    suggestionList.sort((firstSuggestion: SuggestionInfo, secondSuggestion: SuggestionInfo) => {
      let firstPriority: number = supportedCardMap.get(SuggestionUtil.getCardKeyBySuggestion(firstSuggestion));
      let secondPriority: number = supportedCardMap.get(SuggestionUtil.getCardKeyBySuggestion(secondSuggestion));
      if (firstPriority === undefined || secondPriority === undefined) {
        return 0;
      }
      // 优先级排序，越小优先级越高
      return firstPriority - secondPriority;
    });
    LogUtil.info(`${TAG} getSuggestionList after filter ${suggestionList.length}`);
    return suggestionList;
  }

  /**
   * 初始化
   *
   * @param context 上下文
   */
  async refreshData(context: Context): Promise<void> {
    LogUtil.info(`${TAG} getData`);
    if (!this.callbacks || this.callbacks.isEmpty()) {
      return;
    }
    await this.initAccessorController();
    if (!this.controllerList || CheckEmptyUtils.isEmptyArr(this.controllerList)) {
      return;
    }
    this.initControllers();
    // 小于QUERY_INTERVAL内连续获取的场景直接丢弃
    let currentTime: number = new Date().getTime();
    if (Math.abs(currentTime - this.lastGetDataTime) < QUERY_INTERVAL) {
      LogUtil.warn(`${TAG} query is shorter than threshold, last ${this.lastGetDataTime}, current ${currentTime}`);
      return;
    }
    if (this.isInQuerying) {
      LogUtil.warn(`${TAG} alreay in querying, not start again`);
      return;
    }
    this.lastGetDataTime = currentTime;
    this.queryAllSuggestionInfo(context);
  }

  async queryAllSuggestionInfo(context: Context): Promise<void> {
    if (!this.controllerList || CheckEmptyUtils.isEmptyArr(this.controllerList)) {
      return;
    }
    this.isInQuerying = true;
    let taskGroup: taskpool.TaskGroup = new taskpool.TaskGroup();
    for (let i = 0; i < this.controllerList.length; i++) {
      let controller: SuggestionController = this.controllerList[i];
      taskGroup.addTask(querySuggestion, controller, context);
    }
    let res: Object[] = [];
    await taskpool.execute(taskGroup).then((result: Object[]) => {
      res = result;
    }).catch((err: Error) => {
      LogUtil.error(`${TAG} failed to query. error: ${err?.message}`);
    });
    let suggestionList: SuggestionInfo[] = [];
    for (let i = 0; i < res.length; i++) {
      let list: SuggestionInfo[] = res[i] as Array<SuggestionInfo>;
      for (let j = 0; j < list.length; j++) {
        let suggestionInfo = list[j];
        if (await SuggestionUtil.isNeedShow(suggestionInfo)) {
          suggestionList.push(suggestionInfo);
        } else {
          LogUtil.info(`${TAG} suggestionInfo is no need show ${suggestionInfo?.name}`);
        }
      }
    }
    LogUtil.info(`${TAG} getSuggestionList finish ${suggestionList.length}`);
    suggestionList = await this.filterAndSortSuggestion(suggestionList);
    this.isInQuerying = false;
    if (CheckEmptyUtils.isEmptyArr(this.suggestionInfoList) && CheckEmptyUtils.isEmptyArr(suggestionList)) {
      return;
    }
    this.suggestionInfoList = suggestionList;
    this.onDataCallback(suggestionList);
  }

  // instrument ignore next
  onDataCallback(suggestionList: SuggestionInfo[]): void {
    LogUtil.info(`${TAG} callbacks length ${this.callbacks?.length}`);
    this.callbacks.forEach(callback => {
      if (callback) {
        callback(suggestionList);
      }
    })
  }

  // instrument ignore next
  public closeSuggestionByClick(suggestionInfo: SuggestionInfo): void {
    SuggestionUtil.setSuggestionSilent(suggestionInfo);
    this.suggestionInfoList = this.suggestionInfoList.filter(suggestion => {
      if (suggestion.bundleName === suggestionInfo.bundleName && suggestion.name === suggestionInfo.name &&
        suggestion.id === suggestionInfo.id) {
        return false;
      }
      return true;
    })
    this.onDataCallback(this.suggestionInfoList);
  }

  // instrument ignore next
  async clickSuggestion(suggestionInfo: SuggestionInfo, suggestionQuantity: number = SINGLE_SUGGESTION,
    isFromHomePage: boolean = false): Promise<void> {
    LogUtil.info(`${TAG} clickSuggestion ${suggestionQuantity}`);
    if (suggestionQuantity > SINGLE_SUGGESTION) {
      this.currentSuggestionPage = NavEntryKey.HOMEPAGE_SUGGESTION_MORE_PAGE;
      PageRouter.push(NavEntryKey.HOMEPAGE_SUGGESTION_MORE_PAGE);
    } else {
      this.currentSuggestionPage = suggestionInfo.routerUri;
      await SuggestionUtil.jumpToSuggestionDetailPage(suggestionInfo, isFromHomePage);
      suggestionInfo.controller?.clickSuggestion(suggestionInfo, getContext());
      SuggestionUtil.setSuggestionSilent(suggestionInfo);
    }
  }

  registerSuggestionCallback(callback: (suggestionList: SuggestionInfo[]) => void): void {
    if (!callback || this.callbacks.has(callback)) {
      return;
    }
    this.callbacks.add(callback);
    this.registerAppInstallCallback();
  }

  unregisterSuggestionCallback(callback: (suggestionList: SuggestionInfo[]) => void): void {
    if (!callback) {
      return;
    }
    this.callbacks.remove(callback);
    this.unregisterAppInstallCallback();
  }

  registerAppInstallCallback(): void {
    if (this.bundleStatusCallback) {
      return;
    }
    this.bundleStatusCallback = {
      getListenerName: (): string => {
        return 'homepage_suggestion';
      },
      onBundleAdd: (bundleName, userId, appIndex) => {
        LogUtil.info(`${TAG} bundleStatusCallback add, bundleName: ${bundleName} userId: ${userId} appIndex: ${appIndex}`);
        if (this.bundleList.includes(bundleName)) {
          this.refreshData(getContext());
        }
      },
      onBundleRemove: (bundleName, userId, appIndex) => {
        LogUtil.info(`${TAG} bundleStatusCallback remove, bundleName: ${bundleName} userId: ${userId} appIndex: ${appIndex}`);
        if (this.bundleList.includes(bundleName)) {
          // 应用卸载场景刷新卡片
          this.refreshData(getContext());
        }
      },
      onBundleUpdate: (bundleName, userId, appIndex) => {
      }
    }
    BundleStatusChangeManager.getInstance().registerBundleChangedListener(this.bundleStatusCallback);
  }

  unregisterAppInstallCallback(): void {
    if (!this.bundleStatusCallback || !this.callbacks.isEmpty()) {
      return;
    }
    BundleStatusChangeManager.getInstance().unRegisterBundleChangedListener(this.bundleStatusCallback);
  }

  initControllers() {
    if (!this.controllerList || CheckEmptyUtils.isEmptyArr(this.controllerList)) {
      return;
    }
    for (let i = 0; i < this.controllerList.length; i++) {
      if (this.controllerList[i]?.isKeepConnect) {
        this.controllerList[i]?.init(getContext());
      }
    }
  }

  destroyControllers() {
    if (!this.controllerList || CheckEmptyUtils.isEmptyArr(this.controllerList)) {
      return;
    }
    for (let i = 0; i < this.controllerList.length; i++) {
      if (this.controllerList[i]?.isKeepConnect) {
        this.controllerList[i]?.destroy(getContext());
      }
    }
  }

  /**
   * 获取单例
   */
  public static getInstance(): SuggestionCardManager {
    if (SuggestionCardManager.suggestionCardManager) {
      return SuggestionCardManager.suggestionCardManager;
    }
    SuggestionCardManager.suggestionCardManager = new SuggestionCardManager();
    return SuggestionCardManager.suggestionCardManager;
  }
}