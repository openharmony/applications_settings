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

// import abilityFrameworkBroker from '@hms.virtService.abilityFrameworkBroker';
import intl from '@ohos.intl';
import i18n from '@ohos.i18n';
import bundle from '@ohos.bundle.bundleManager';
import installer from '@ohos.bundle.installer';
import osAccount from '@ohos.account.osAccount';
import bundleManager from '@ohos.bundle.bundleManager';
import appManager from '@ohos.app.ability.appManager';
import relationalStore from '@ohos.data.relationalStore';
import emitter from '@ohos.events.emitter';
import { BusinessError } from '@ohos.base';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  EVENT_ID_HOME_APP_STATE_CHANGED,
  EVENT_ID_BUNDLE_RESOURCES_CHANGED
} from '@ohos/settings.common/src/main/ets/event/types';
import CommonEventManager from '@ohos.commonEventManager';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { RdbTaskPool } from '@ohos/settings.common/src/main/ets/rdb/RdbTaskPool';
import { ITEMINFO_TABLE } from '@ohos/settings.common/src/main/ets/data/types';
import SearchItemInfoManager from '@ohos/settings.common/src/main/ets/data/SearchItemInfoManager';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import {
  HiSysApplicationsAndServicesEventGroup
} from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { AppGroupType } from '@ohos/settings.common/src/main/ets/utils/Consts';
import {
  isMatchKeyWord,
  highLightKeyWord,
  HighlightIndex,
  HIGHLIGHT_DEFAULT_INDEX
} from '@ohos/settings.common/src/main/ets/utils/ApplicationUtil';
import { RenderItemInfo } from '@ohos/settings.search/src/main/ets/model/type';
import { AppEntry, AppType } from '../AppModel';
import { AppUtils } from '../AppUtils';
import { AppListLoader } from '../AppListLoader';
import { UninstallResult } from '../model/UninstallResult';

const TAG: string = 'AppManager : ';
const HOME_PAGE_MAP: Map<string, string> = new Map([
  ['com.ohos.vassistant', 'vassistant_setting'],
]);
const SEARCH_UPDATE_MAP: Map<string, string> = new Map([
  ['com.ohos.vassistant', 'vassistant_setting'],
  ['com.ohos.hicar', 'hicar_setting']
]);
const METADATA_CAN_NOT_DISABLE: string = 'action.settings.app.can_not_disable';
const METADATA_DISABLE_FORCE_STOP: string = 'action.settings.app.disable_force_stop';
const EVENT_BUNDLE_RESOURCES_CHANGED: string = 'usual.event.BUNDLE_RESOURCES_CHANGED';
const LANGUAGE_CHANGE_TIMEOUT: number = 5000;

@Concurrent
export function sortByName(data: AppEntry[]): AppEntry[] {
  let compare = (firstEntry: AppEntry, secondEntry: AppEntry): number => {
    let collator = new intl.Collator();
    return collator.compare(firstEntry.label?.toString(), secondEntry.label?.toString());
  }
  data.sort((firstItem, secondItem) => {
    return compare(firstItem, secondItem);
  });
  return data;
}

@Concurrent
export async function getBundleInfoTask(name: string): Promise<bundle.BundleInfo | undefined> {
  try {
    return await AppListLoader.getInstance().getBundleInfo(name);
  } catch (err) {
    LogUtil.error(`getBundleInfo error:${err?.code} ${err?.message}`);
  }
  return undefined;
}

export enum LanguageStatus {
  SAME = 0,
  CHANGING = 1,
  CHANGED = 2
};

/**
 * 应用管理类
 */
export class AppManager {
  public userId: number = -1;
  private static instance: AppManager;
  private isLanguageChanging: boolean = false;
  private timer: number | undefined;
  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_LOCALE_CHANGED,
      EVENT_BUNDLE_RESOURCES_CHANGED
    ]
  };
  private appListChange: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    if (CheckEmptyUtils.isEmpty(data)) {
      return;
    }
    LogUtil.info(`${TAG} applist changed: ${data?.event}`);
    if (data?.event === CommonEventManager.Support.COMMON_EVENT_LOCALE_CHANGED) {
      this.isLanguageChanging = true;
      this.timerToChangeBundleResource();
    } else if (data?.event === EVENT_BUNDLE_RESOURCES_CHANGED) {
      this.clearBundleResourceChangeTimer();
      this.isLanguageChanging = false;
      this.notifyBundleResourcesStatus(true);
    } else {
      LogUtil.info(`${TAG} event is invalid`);
    }
  })

  private timerToChangeBundleResource() {
    if (!DeviceUtil.isDevicePc()) {
      return;
    }
    this.clearBundleResourceChangeTimer();
    this.timer = setTimeout(() => {
      LogUtil.showInfo(TAG, 'time to notify bundle resource change');
      this.isLanguageChanging = false;
      this.notifyBundleResourcesStatus(true);
    }, 10000);
  }

  private clearBundleResourceChangeTimer() {
    if (this.timer) {
      clearTimeout(this.timer);
      this.timer = undefined;
    }
  }

  /**
   * 获取应用列表加载类单例
   */
  static getInstance(): AppManager {
    if (!AppManager.instance) {
      AppManager.instance = new AppManager();
    }
    return AppManager.instance;
  }

  /**
   * 获取当前用户ID
   *
   * @return 当前用户ID
   */
  async getUserId(): Promise<number> {
    if (this.userId !== -1) {
      return this.userId;
    }

    let accountManager = osAccount.getAccountManager();
    try {
      this.userId = await accountManager.getOsAccountLocalId();
      LogUtil.info(`$${TAG} verificationSubUser, userId: ${this.userId}`);
    } catch (err) {
      LogUtil.error(`$${TAG} verificationSubUser getOsAccountLocalId exception: ${err.message}`);
    }
    return this.userId;
  }

  /**
   * 停用当前进程
   *
   * @param bundleName 应用包名
   */
  async killProcessesByBundleName(bundleName: string): Promise<void> {
    LogUtil.info(`${TAG} killProcessesByBundleName bundleName: ${bundleName}`);
    if (!bundleName) {
      return;
    }
    try {
      LogUtil.info(`${TAG} killProcessesByBundleName start`);
      await appManager.killProcessesByBundleName(bundleName);
      LogUtil.info(`${TAG} killProcessesByBundleName end`);
    } catch (err) {
      LogUtil.error(`${TAG} killProcessesByBundleName error: ${err?.message} `);
    }
  }

  /**
   * 停用当前进程
   *
   * @param bundleName 应用包名
   * @param appIndex 应用分身索引
   */
  async killProcessWithAccount(bundleName: string, appIndex: number): Promise<void> {
    let userId: number = await this.getUserId();
    if (userId && bundleName) {
      try {
        LogUtil.info(`${TAG} killProcessWithAccount bundleName: ${bundleName}, appIndex: ${appIndex}`);
        if (AppUtils.isCloneBundle(appIndex)) {
          await appManager.killProcessWithAccount(bundleName, userId, true, appIndex);
        } else {
          await appManager.killProcessWithAccount(bundleName, userId);
        }
      } catch (err) {
        LogUtil.info(`${TAG} killProcessWithAccount error: ${err?.message} `);
      }
    }
  }

  /**
   * 获取当前应用运行状态
   *
   * @param bundleName 应用包名
   * @param appIndex 应用分身索引
   * @return 是否运行
   */
  async getIsApplicationRunning(bundleName: string, appIndex: number): Promise<boolean> {
    if (!bundleName) {
      return false;
    }

    let result = false;
    try {
      result = await appManager.isAppRunning(bundleName, appIndex);
      LogUtil.info(`${TAG} isApplicationRunning: ${result}`);
    } catch (err) {
      LogUtil.info(`${TAG} isApplicationRunning error: ${err?.message}`);
    }

    return result;
  }

  /**
   * 设置应用使能状态
   *
   * @param bundleName 应用包名
   * @param isEnable 是否使能
   * @param appIndex 应用分身索引
   * @return 执行结果
   */
  async setApplicationEnabled(bundleName: string, isEnable: boolean, appIndex:number): Promise<boolean> {
    if (!bundleName) {
      return false;
    }
    LogUtil.warn(`${TAG} setApplicationEnabled bundleName: ${bundleName}, isEnable: ${isEnable}, appIndex: ${appIndex}`);
    let params: Record<string, Object> = {};
    params.ENABLE = isEnable ? 'on' : 'off';
    params.BUNDLENAME = bundleName;
    params.APPINDEX = appIndex;
    HiSysEventUtil.reportBehaviorEventByUE(HiSysApplicationsAndServicesEventGroup.APP_AND_SERVICE_ENABLE_SWITCH,
      params);

    let result: boolean = false;
    try {
      await bundleManager.setApplicationEnabled(bundleName, appIndex, isEnable);
      LogUtil.info(`${TAG} setApplicationEnabled success`);
      this.notifyHomePageStateChange(bundleName, isEnable, appIndex);
      await this.updateSearchState(bundleName, isEnable);
      result = true;
    } catch (err) {
      LogUtil.info(`${TAG} setApplicationEnabled error: ${err?.message}`);
    }

    return result;
  }

  /**
   * 获取应用使能状态
   *
   * @param bundleName 应用包名
   * @param appIndex 应用分身索引
   * @param appType 应用类型
   * @return 使能状态
   */
  async getIsApplicationEnabled(bundleName: string, appIndex:number, appType?: AppType): Promise<boolean> {
    if (!bundleName) {
      return false;
    }
    if (appType === AppType.CONTAINER_APP) {
      // BMS isApplicationEnabled/setApplicationEnabled 未适配，需单独处理
      LogUtil.info(`${TAG} isApplicationEnabled, containerApp default true`);
      return true;
    }
    let result = false;
    if (bundleName) {
      try {
        result = await bundleManager.isApplicationEnabled(bundleName, appIndex);
        LogUtil.info(`${TAG} isApplicationEnabled, bundleName: ${bundleName}, result: ${result}`);
      } catch (err) {
        LogUtil.info(`${TAG} isApplicationEnabled error: ${err?.message}`);
      }
    }
    return result;
  }

  /**
   * 卸载应用
   *
   * @param bundleName 应用包名
   * @param appIndex 应用分身索引
   * @returns 卸载结果
   */
  async uninstallApp(bundleName: string, appIndex?: number,
    isDirectUninstall: boolean = true): Promise<UninstallResult> {
    if (!bundleName) {
      return { isSuccess: false };
    }
    LogUtil.info(`${TAG} uninstall bundleName: ${bundleName}`);

    return await this.uninstall(bundleName, appIndex, isDirectUninstall);
  }

  private async uninstall(bundleName: string, appIndex?: number,
    isDirectUninstall: boolean = true): Promise<UninstallResult> {
    let userId: number = await this.getUserId();
    const bundleInstaller: installer.BundleInstaller = await installer.getBundleInstaller();
    let parameter: installer.Parameters = {
      key: 'ohos.bms.param.verifyUninstallRule',
      value: isDirectUninstall ? 'false' : 'true'
    };
    let isSuccess: boolean = false;
    let businessError: BusinessError | undefined = undefined;
    LogUtil.info(`${TAG} uninstall start`);
    if (AppUtils.isCloneBundle(appIndex)) {
      let destroyAppCloneOpt: installer.DestroyAppCloneParam = {
        userId: userId,
        parameters: [parameter]
      };
      await bundleInstaller.destroyAppClone(bundleName, appIndex, destroyAppCloneOpt)
        .then(() => {
          LogUtil.info(`${TAG} destroyAppClone successfully`);
          isSuccess = true;
        }).catch((error: BusinessError) => {
          LogUtil.error(`${TAG} destroyAppClone failed, ${error?.message}`);
          isSuccess = false;
          businessError = error;
        });
    } else {
      await bundleInstaller.uninstall(bundleName, {
        userId: userId,
        installFlag: 0,
        isKeepData: false,
        parameters: [parameter]
      })
        .then(() => {
          LogUtil.info(`${TAG} uninstall success`);
          isSuccess = true;
        }).catch((error: BusinessError) => {
          LogUtil.error(`${TAG} uninstall failed, ${error?.message}`);
          isSuccess = false;
          businessError = error;
        });
    }
    return { isSuccess: isSuccess, error: businessError };
  }

  /**
   * 通知首页应用状态
   *
   * @param bundleName 应用包名
   * @param isVisible 是否显示setApplicationEnabled
   * @param appIndex 应用分身索引
   */
  notifyHomePageStateChange(bundleName: string, isVisible: boolean, appIndex:number): void {
    if (!HOME_PAGE_MAP.has(bundleName)) {
      return;
    }
    LogUtil.info(`${TAG} notifyHomePageStateChange, bundleName: ${bundleName}, isVisible: ${isVisible}, appIndex: ${appIndex}`);

    emitter.emit({
      eventId: EVENT_ID_HOME_APP_STATE_CHANGED,
    }, {
      data: {
        id: HOME_PAGE_MAP.get(bundleName),
        isVisible: isVisible,
        appIndex: appIndex
      }
    });
  }

  /**
   * 获取是否处在语言变化状态
   *
   * @param systemLocale: 需要检测的数据
   * @return LanguageStatus：当前语言状态
   */
  getLanguageChangingStatus(systemLocale: string): LanguageStatus {
    if (systemLocale === i18n.System.getSystemLocale()) {
      return LanguageStatus.SAME;
    } else if (this.isLanguageChanging) {
      return LanguageStatus.CHANGING;
    } else {
      return LanguageStatus.CHANGED;
    }
  }

  /**
   * 设置是否处在语言变化状态
   *
   * @param true：当前正在进行语言切换 false：当前未进行语言切换
   */
  setLanguageChangingStatus(isLanguageChanging: boolean): void {
    this.isLanguageChanging = isLanguageChanging;
  }

  /**
   * 注册包资源管理变化事件和语言变化事件监听
   */
  async registerEventListener(): Promise<void> {
    this.appListChange.registerCommonEvent();
  }

  /**
   * 取消注册包资源管理变化事件和语言变化事件监听
   */
  unRegisterEventListener(): void {
    this.appListChange.unRegisterCommonEvent();
  }

  private notifyBundleResourcesStatus(isChanged: boolean): void {
    EventBus.getInstance().emit(EVENT_ID_BUNDLE_RESOURCES_CHANGED, isChanged);
  }

  /**
   * 是否是系统应用
   * @param bundleName 包名
   * @returns
   */
  isSystemApp(bundleName: string): boolean {
    try {
      let bundleInfo: bundleManager.BundleInfo =
        bundleManager.getBundleInfoSync(bundleName, bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      if (!bundleInfo) {
        LogUtil.error(`${TAG} isSystemApp bundleInfo is empty.`);
        return false;
      }
      LogUtil.info(`${TAG} name: ${bundleInfo?.appInfo?.name} isSystemApp: ${bundleInfo?.appInfo?.systemApp}`);
      return bundleInfo?.appInfo?.systemApp;
    } catch (err) {
      LogUtil.error(`${TAG} isSystemApp error: ${err?.message}`);
    }
    return false;
  }

  /**
   * app是否可以被强制禁用
   * @param bundleName 应用包名
   * @param moduleName 模块名
   */
  isAppForceStop(bundleName: string, moduleName: string): boolean {
    if (!this.isSystemApp(bundleName)) {
      // 三方应用不支持将强行停止按钮置灰,直接返回
      LogUtil.info(`isAppForceStop isSystemApp false`);
      return false;
    }
    const metadataValue = this.getMetadata(bundleName, moduleName, METADATA_DISABLE_FORCE_STOP)?.value || '';
    LogUtil.info(`isAppDisables metadata: ${metadataValue}`);
    return metadataValue === 'true';
  }

  /**
   * app是否可以被禁用
   * @param bundleName 应用包名
   * @param moduleName 模块名
   */
  isAppDisables(bundleName: string, moduleName: string): boolean {
    const metadataValue = this.getMetadata(bundleName, moduleName, METADATA_CAN_NOT_DISABLE)?.value || '';
    LogUtil.info(`isAppDisables metadataValue: ${metadataValue}`);
    return metadataValue === 'true';
  }

  /**
   * app是否通过hdc/应用市场更新预置应用
   * @param bundleName 应用包名
   * @param appType 应用类型
   */
  isAppPreUpdated(bundleName: string, appType?: AppType): boolean {
    const flags = this.getApplicationInfoFlag(bundleName);
    LogUtil.info(`isAppPreUpdated flags: ${flags}`);
    if (!flags) {
      return false;
    }
    return (flags & bundleManager.ApplicationInfoFlag.FLAG_PREINSTALLED_APP_UPDATE) ===
    bundleManager.ApplicationInfoFlag.FLAG_PREINSTALLED_APP_UPDATE;
  }

  /**
   * 获取指定应用的指定模块下的metadata数据
   * @param bundleName 应用包名
   * @param moduleName 模块名
   * @param metaDataName metadata名称
   */
  getMetadata(bundleName: string, moduleName: string, metaDataName: string): bundleManager.Metadata | null {
    try {
      let applicationInfo = bundleManager.getApplicationInfoSync(bundleName,
        bundleManager.ApplicationFlag.GET_APPLICATION_INFO_WITH_METADATA);
      if (applicationInfo === null || applicationInfo.metadata === null) {
        LogUtil.error(
          `${TAG} applicationInfo or metadata is null. getMetadata failed.
          bundleName: ${bundleName} ${(applicationInfo === null)}`);
        return null;
      }
      let metadataObj = applicationInfo.metadata;
      if (metadataObj[moduleName]) {
        for (let metaData of metadataObj[moduleName] as Array<bundleManager.Metadata>) {
          if (metaData.name === metaDataName) {
            return metaData;
          }
        }
      }
    } catch (err) {
      LogUtil.error(`${TAG} getMetadata error: ${err?.message}`);
    }
    return null;
  }

  /**
   * 获取指定应用的指定模块下的flag数据
   * @param bundleName 应用包名
   *
   * @returns ApplicationInfoFlag 应用类型flag
   */
  getApplicationInfoFlag(bundleName: string): bundleManager.ApplicationInfoFlag | null {
    try {
      let applicationInfo = bundleManager.getApplicationInfoSync(bundleName,
        bundleManager.ApplicationFlag.GET_APPLICATION_INFO_DEFAULT);
      if (!applicationInfo || !applicationInfo.flags) {
        LogUtil.error(`${TAG} getApplicationInfoFlag failed.${bundleName} applicationInfo:${applicationInfo}`);
        return null;
      }
      return applicationInfo.flags;
    } catch (err) {
      LogUtil.error(`${TAG} getApplicationInfoFlag error: ${err?.message}`);
    }
    return null;
  }

  private async updateSearchState(bundleName: string, isVisible: boolean): Promise<void> {
    if (!SEARCH_UPDATE_MAP.has(bundleName)) {
      return;
    }
    LogUtil.info(`${TAG} updateSearchState, bundleName: ${bundleName}, isVisible: ${isVisible}`);

    let entryKey = SEARCH_UPDATE_MAP.get(bundleName) ?? '';
    let result = await this.queryEntryKey(entryKey);
    LogUtil.error(`${TAG} updateSearchState entryKey result is ${result}`);
    if (result.length === 0) {
      LogUtil.info(`${TAG} updateSearchState, ${entryKey} is not exist`);
      await SearchDataController.getInstance().initExternalSearchDataWithBundleName(bundleName);
    }

    await SearchItemInfoManager.updateSearchEntry(entryKey, isVisible);
  }

  async queryEntryKey(entryKey: string): Promise<string> {
    if (CheckEmptyUtils.checkStrIsEmpty(entryKey)) {
      LogUtil.error(`${TAG} queryChildItems error, entryKey is empty`);
      return '';
    }

    let result: string = '';
    try {
      let conditions: Map<string, relationalStore.ValueType> = new Map();
      conditions.set('entryKey', entryKey);
      result = await RdbTaskPool.getInstance().queryEntryKey(ITEMINFO_TABLE, conditions);
      LogUtil.info(`${TAG} queryEntryKey result: ${result}`);
    } catch (err) {
      LogUtil.error(`${TAG} queryEntryKey error: ${err?.message}`);
    }

    return result;
  }
}

/**
 * 根据搜索关键词查询元服务
 *
 * @param keyWord 搜索关键词
 * @returns 查询的元服务结果
 */
export function queryMetaService(keyWord: string): RenderItemInfo[] {
  let renderItemInfos: RenderItemInfo[] = [];
  if (CheckEmptyUtils.checkStrIsEmpty(keyWord)) {
    LogUtil.showWarn(TAG, `queryMetaService keyword is empty`);
    return renderItemInfos;
  }
  let appList: AppEntry[] = AppListLoader.getInstance().getAppListCache(AppGroupType.SERVICE);
  LogUtil.showInfo(TAG, `metaservice length: ${appList?.length}`);
  appList.forEach((item) => {
    if (item.label) {
      let highlightIndex: HighlightIndex = {
        startIndex: HIGHLIGHT_DEFAULT_INDEX,
        endIndex: HIGHLIGHT_DEFAULT_INDEX
      }
      if (isMatchKeyWord(item.label, keyWord, highlightIndex)) {
        let renderItem: RenderItemInfo = {
          entryKey: item.name,
          isOuterApp: false,
          children: [{
            title: highLightKeyWord(item.label, keyWord, highlightIndex),
            entryKey: item.name,
            path: '',
            parentKey: '',
            itemName: '',
            params: '',
            isService: true,
            appName: item.label?.split(new RegExp(`<em>|</em>`, 'gi')).join(''),
            appIndex: item.appIndex,
            isOuterApp: false
          }]
        }
        renderItemInfos.push(renderItem);
      }
    }
  })
  return renderItemInfos;
};