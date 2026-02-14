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

import emitter from '@ohos.events.emitter';
import Ability from '@ohos.app.ability.UIAbility';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import window from '@ohos.window';
import taskpool from '@ohos.taskpool';
import { BusinessError } from '@ohos.base';
import workScheduler from '@ohos.resourceschedule.workScheduler';
import { Configuration } from '@ohos.app.ability.Configuration';
import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant';
import distributedAccount from '@ohos.account.distributedAccount';
import EnvironmentCallback from '@ohos.app.ability.EnvironmentCallback';
import { UIObserver } from '@kit.ArkUI';
import {
  EVENT_ID_LANGUAGE_UPDATE,
  EVENT_ID_NAVIGATION_CHANGE,
  EVENT_ID_ON_PAGE_BACKGROUND,
  EVENT_ID_ON_PAGE_FOREGROUND,
  EVENT_ID_DARK_MODE_CACHE,
  EVENT_ID_MAINABILITY_ON_FOREGROUND,
  EVENT_ID_MAINABILITY_ON_BACKGROUND,
  EVENT_ID_CLOSE_THEME_FULL_SCREEN_PAGE
} from '@ohos/settings.common/src/main/ets/event/types';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import { hasOwnPropertyCall } from '@ohos/settings.common/src/main/ets/utils/ObjectPrototypeUtil';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import { SettingPageDescController } from '@ohos/settings.search/src/main/ets/controller/SettingPageDescController';
import {
  HiSysEventUtil,
} from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { PageStartReason } from '@ohos/settings.common/src/main/ets/data/types';
import SearchItemInfoManager from '@ohos/settings.common/src/main/ets/data/SearchItemInfoManager';
import SettingPageDescManager from '@ohos/settings.common/src/main/ets/data/SettingPageDescManager';
import {
  BLOCK_URI_LIST,
  NOT_DEVELOPER_BLOCK_URI_LIST,
  DEVELOP_OPTION_STATE,
  WALLET_BLOCK_URI_LIST,
  NavEntryKey,
  SYSTEM_APP_URI_LIST
} from '@ohos/settings.common/src/main/ets/utils/Consts';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import { Trace } from '@ohos/settings.common/src/main/ets/utils/Trace';
import lazy { ExternalMenuPreloadManager } from '@ohos/settings.common/src/main/ets/externalmenu/ExternalMenuPreloadManager';
import lazy { RdbStoreHelper } from '@ohos/settings.common/src/main/ets/rdb/RdbStoreHelper';
import lazy { AppListLoader } from '@ohos/settings.application/src/main/ets/AppListLoader';
import lazy { MoreAppListLoader } from '@ohos/settings.application/src/main/ets/MoreAppListLoader';
import lazy { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import lazy{ WalletManageUtils } from '@ohos/settings.common/src/main/ets/utils/WalletManageUtils';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { MainConstants } from '@ohos/settings.common/src/main/ets/constant/MainConstants';
import { initializingProperties } from './ExternalWifiSettingsAbility';
import { HomePageMenuManager } from '../Setting/Home/controller/HomePageMenuManager';
import { HiSysDisplayEventGroup, HiSysSettingHomeEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { HiSysLoadExternalMenuResException } from '@ohos/settings.common/src/main/ets/systemEvent/ExceptionEventConsts';
import { DeeplinkUtil } from '@ohos/settings.common/src/main/ets/utils/DeeplinkUtil';
import { DataSizeReportHelper } from '@ohos/settings.common/src/main/ets/systemEvent/DataSizeReportHelper';
import { IntelligentSceneWindowManager } from '../Setting/IntelligentScene/manager/IntelligentSceneWindowManager';

/* instrument ignore file */
const TAG: string = 'MainAbility : ';
const INVALID_CALLBACK_ID: number = -1;
const MODE_STATE = 1002;
const SETTINGS_HOME_ACTION = 'action.system.home';
const SETTINGS_HOME_PAGE_URL = 'pages/home/SettingsHome';
const COLOR_MODE_DARK = 0;
const COLOR_MODE_LIGHT = 1;

class DeveloperOptionsSettingsPushParams {
  public systemRollback: number = 0;
}

const linkUriMap: Map<string, string> = new Map([
  ['settings://storage_manager', 'storage_settings'],
  ['settings://battery', 'battery'],
  ['settings://mobile_data_manage_entry', 'mobile_data_manage_entry'],
  ['settings://privacy_settings', 'privacy_settings'],
]);

const whiteLinkUriList : string[] = [
  NavEntryKey.BLUETOOTH_ENTRY,
  NavEntryKey.VOLUME_ENTRY,
  NavEntryKey.ABOUT_DEVICE_ENTRY,
  NavEntryKey.CLOUD_SPACE_ENTRY,
  NavEntryKey.OUC_SOFTWARE_UPDATE_SETTINGS,
  NavEntryKey.NFC_ENTRY
];

const DEEPLINK_HOME_PAGE: string = 'settings://homepage';

export default class MainAbility extends Ability {
  public environmentCallbackId: number = INVALID_CALLBACK_ID;
  private developerState: string = SystemParamUtil.getParam(DEVELOP_OPTION_STATE, 'false');
  private uiObserver?: UIObserver = undefined;

  private initShareData(want: Want): void {
    if (!CheckEmptyUtils.checkStrIsEmpty(want.action) && want.action === "ohos.want.action.viewData") {
      let params = want?.parameters as Record<string, string>;
      if (params?.['ohos.aafwk.param.callerBundleName'] !== 'com.ohos.instantshare') {
        LogUtil.info(`${TAG} is not from hwShare`);
        return;
      }
      LogUtil.info(`${TAG} get wifi share data`);
      if (want?.parameters?.textContent) {
        AppStorage.setOrCreate('shareDataFileUri', want?.parameters?.textContent);
      } else {
        AppStorage.setOrCreate('shareDataFileUri', want.uri);
      }
      want.uri = NavEntryKey.WIFI_ENTRY;
    }
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    LogUtil.info(`${TAG} Settings MainAbility onCreate is called`);
    Trace.start('MainAbility onCreate');
    AbilityContextManager.addContext(this.context);
    AbilityContextManager.setMainAbilityContext(this.context);
    this.initShareData(want);
    this.handleShortcutsUri(want);
    AppStorage.setOrCreate<Want>('wantParams', want);
    AppStorage.setOrCreate<string>(PackagesConstant.SETTINGS_NAVIGATION_URL, '');
    PageStartModeManager.getInstance().setStartReason(PageStartReason.DEFAULT);
    LogUtil.showInfo(TAG, 'on create want: bundleName:%{public}s abilityName:%{public}s ' +
      'moduleName:%{public}s uri:%{public}s shortcuts:%{public}s', want?.bundleName, want?.abilityName,
      want?.moduleName, want?.uri, want?.parameters?.shortcutUri);
    if (hasOwnPropertyCall(want, 'uri') && !CheckEmptyUtils.checkStrIsEmpty(want.uri)) {
      if (!this.initJumpUri(want)) {
        return;
      }
      LogUtil.info(`${TAG} wanted uri is: ${want.uri}`);
      AppStorage.setOrCreate<number>('developerOptionsSettingsSystemRollback', (want?.parameters?.pushParams as
      DeveloperOptionsSettingsPushParams)?.systemRollback);
    }
    HomePageMenuManager.getInstance().initHomeData(this.context);
    this.initTimeConsumingData();
    this.getAccountInfo();
    this.registerEnvironmentChanged();
    this.tryStartStatusReportWorker();
    this.tryReportDataSize();
    Trace.end('MainAbility onCreate');
  }

  private initJumpUri(want: Want): boolean {
    if (WalletManageUtils.isFromWallet() && WALLET_BLOCK_URI_LIST.has(want.uri as string)) {
      return false;
    }
    if (!WalletManageUtils.isFromWallet() && BLOCK_URI_LIST.has(want.uri as string)) {
      return false;
    }
    if (SYSTEM_APP_URI_LIST.has(want.uri as string) && !AbilityUtils.callerIsLocalSystemApp(want)) {
      return false;
    }
    if (this.developerState !== 'true' && NOT_DEVELOPER_BLOCK_URI_LIST.has(want.uri as string)) {
      return false;
    }
    PageStartModeManager.getInstance().setStartReason(PageStartReason.FROM_EXTERNAL);
    const uri: string = this.uriChangeProcess(want.uri as string);
    LogUtil.info(`${TAG} uriChangeProcess want.uri: ${want.uri}, uri: ${uri}`);
    if (this.checkNotPushPageForIntelligentScene(uri)) {
      return false;
    }
    this.hwSystemManagerFormPageHiSysEvent(want, uri);
    want.uri = uri;
    ExternalMenuPreloadManager.getInstance().preloadUIExtensionAbility(uri, this.context);
    AppStorage.setOrCreate<string>(PackagesConstant.SETTINGS_NAVIGATION_URL, want.uri);
    HiSysEventUtil.reportEnterSettingEventByUE(HiSysSettingHomeEventGroup.ENTER_SETTINGS_PAGE,
      CommonUtils.getCallerInfo(want));
    return true;
  }

  private hwSystemManagerFormPageHiSysEvent(want: Want, uri:string): void {
    const requestSource: string = want.parameters?.requestSource as string;
    LogUtil.info(`${TAG} HwSystemManagerForm requestSource: ${requestSource}`);
    if (requestSource === 'HwSystemManagerForm') {
      HiSysEventUtil.hwSystemManagerFormPageJumpReportEvent(uri);
    }
  }

  private uriChangeProcess(uri: string): string {
    if (linkUriMap.has(uri)) {
      return linkUriMap.get(uri) as string;
    }
    if (uri === DEEPLINK_HOME_PAGE) {
      PageRouter.jumpToHomePage();
      return '';
    }
   return DeeplinkUtil.getDeeplinkJumpUri(uri, whiteLinkUriList);
  }

  private async initTimeConsumingData(): Promise<void> {
    SearchDataController.initSearchTable();
    SearchDataController.deleteSearchData();
    SettingPageDescController.initPageInfoTable();
    SettingPageDescController.deletePageInfoData();
    setTimeout(() => {
      SearchDataController.initSearchData();
      SettingPageDescController.initPageInfoData();
      SearchDataController.getInstance().registerStatusChange();
      SearchDataController.getInstance().updateRemovableBundles();
      AppListLoader.getInstance().registerStatusChange();
      AppListLoader.getInstance().registerDpiChange();
    }, 1500);
  }

  private handleShortcutsUri(want: Want): void {
    if (!CheckEmptyUtils.checkStrIsEmpty(want.uri) || CheckEmptyUtils.checkStrIsEmpty(want?.parameters?.shortcutUri as string)) {
      return;
    }
    want.uri = want?.parameters?.shortcutUri as string;
  }

  clearDataBeforeDestroy(): void {
    let intentContext: Context = AbilityContextManager.getBackgroundIntentContext();
    AppStorage.clear();
    AbilityContextManager.setBackgroundIntentContext(intentContext);
  }

  onDestroy(): void {
    LogUtil.info(`${TAG} Settings MainAbility onDestroy is called`);
    WindowManager.unregisterFoldChangeListener();
    WindowManager.unregisterWindowStageListener();
    AbilityContextManager.removeContext(this.context);
    this.unregisterEnvironmentChanged();
    SearchItemInfoManager.resetRdbStore();
    SettingPageDescManager.resetRdbStore();
    AppListLoader.getInstance().clearAppListCache();
    AppListLoader.getInstance().unRegisterStatusChange();
    AppListLoader.getInstance().unregisterDpiChange();
    MoreAppListLoader.getInstance().clearAppListCache();
    RdbStoreHelper.getInstance().setRdbStore(undefined);
    SearchDataController.getInstance().unRegisterStatusChange();
    this.clearDataBeforeDestroy();
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    Trace.start('MainAbility onWindowStageCreate');
    LogUtil.info(`${TAG} Settings MainAbility onWindowStageCreate is called`);
    AppStorage.setOrCreate<window.WindowStage>('windowStage', windowStage);
    // 当前提供给外部的也有UIAbility(eg: ExternalWifiSettingsAbility),会导致AppStorage中的window和windowstage被覆盖
    // 临时方案是先将主window多存一份
    AppStorage.setOrCreate<window.WindowStage>(MainConstants.MAIN_WINDOW_STAGE, windowStage);
    AppStorage.setOrCreate('isMainPageReport', true);
    AppStorage.setOrCreate<Configuration>('envConfig', this.context.config);
    FontScaleUtils.setConfig(this.context.config.fontSizeScale as number);
    LogUtil.info(`${TAG} onWindowStageCreate color mode: ${this.context.config.colorMode}`);
    let colorMode = this.context.config.colorMode as ConfigurationConstant.ColorMode;
    let localStorage: LocalStorage = new LocalStorage({
      windowStage: windowStage,
    } as initializingProperties);
    windowStage?.loadContent(SETTINGS_HOME_PAGE_URL, localStorage).then(() => {
      WindowManager.setMainWindowBgColorByColorMode(windowStage, colorMode);
    });
    WindowManager.adjustOrientation();
    WindowManager.registerWindowStageListener();
    WindowManager.registerFoldChangeListener();
    WindowManager.setWindowProperties(this.context, windowStage);
    WindowManager.setSystemBar(colorMode);
    this.registerNavDestinationUpdateObserver(windowStage);
    Trace.end('MainAbility onWindowStageCreate');
  }

  private registerNavDestinationUpdateObserver(windowStage: window.WindowStage) {
    windowStage.getMainWindow().then((windowClass: window.Window) => {
      if (!windowClass || this.uiObserver) {
        LogUtil.info(`${TAG} observer is already init, or get mainwinidow fail`);
        return;
      }
      // 获取UIContext实例。
      let uiContext: UIContext = windowClass.getUIContext();
      // 获取UIObserver实例。
      this.uiObserver = uiContext.getUIObserver();
      // 注册DevNavigation的状态监听.
    }).catch((err: BusinessError) => {
      LogUtil.error(`${TAG} GetMainWindow Failed: ${err?.message}`);
    });
  }

  onWindowStageDestroy(): void {
    LogUtil.info(`${TAG} Settings MainAbility onWindowStageDestroy is called`);
    this.unregisterNavDestinationUpdateObserver();
  }

  private unregisterNavDestinationUpdateObserver() {
    this.uiObserver?.off('navDestinationUpdate');
    this.uiObserver = undefined;
  }

  onForeground(): void {
    Trace.start('MainAbility onForeground');
    LogUtil.info(`${TAG} Settings MainAbility onForeground is called, color mode: ${this.context?.config?.colorMode}`);
    const envConfig: Configuration = AppStorage.get('envConfig') as Configuration;
    if (envConfig?.colorMode !== this.context?.config?.colorMode) {
      LogUtil.info(`${TAG} envConfig colorMode: ${envConfig?.colorMode};config colorMode: ${this.context?.config?.colorMode}`);
    }
    emitter.emit({
      eventId: EVENT_ID_ON_PAGE_FOREGROUND,
      priority: emitter.EventPriority.IMMEDIATE,
    });
    EventBus.getInstance().emit(EVENT_ID_MAINABILITY_ON_FOREGROUND);
    WindowManager.getInstance().setWaterMarkFlag(true);
    WindowManager.hideOrShowNonSystemFloatingWindows(true);
    Trace.end('MainAbility onForeground');
  }

  onBackground(): void {
    LogUtil.info(`${TAG} Settings MainAbility onBackground is called`);
    WindowManager.getInstance().setWaterMarkFlag(false);
    emitter.emit({
      eventId: EVENT_ID_ON_PAGE_BACKGROUND,
      priority: emitter.EventPriority.IMMEDIATE,
    });
    EventBus.getInstance().emit(EVENT_ID_MAINABILITY_ON_BACKGROUND);
    WindowManager.hideOrShowNonSystemFloatingWindows(false);
  }

  onNewWant(want: Want): void {
    Trace.start('MainAbility onNewWant');
    this.initShareData(want);
    LogUtil.showInfo(TAG, 'on new want: bundleName:%{public}s abilityName:%{public}s ' +
      'moduleName:%{public}s uri:%{public}s shortcuts:%{public}s', want?.bundleName, want?.abilityName,
      want?.moduleName, want?.uri, want?.parameters?.shortcutUri);
    this.handleShortcutsUri(want);
    AppStorage.setOrCreate<Want>('wantParams', want);
    AppStorage.setOrCreate<string>(PackagesConstant.SETTINGS_NAVIGATION_URL, '');
    PageStartModeManager.getInstance().setStartReason(PageStartReason.DEFAULT);
    if (hasOwnPropertyCall(want, 'uri') && !CheckEmptyUtils.checkStrIsEmpty(want.uri)) {
      if (!this.initJumpUri(want)) {
        return;
      }
      this.navigationUrlChangeNotify(want.uri);
      AppStorage.setOrCreate<number>('developerOptionsSettingsSystemRollback', (want?.parameters?.pushParams as
      DeveloperOptionsSettingsPushParams)?.systemRollback);
    }
    Trace.end('MainAbility onNewWant');
  }

  private checkNotPushPageForIntelligentScene(uri: string): boolean {
    if (uri != NavEntryKey.INTELLIGENT_SCENE_SETTINGS_ENTRY) {
      return false;
    }
    let optionalPath = PageRouter.getRouterPath('Setting');
    if (!optionalPath || !optionalPath.isPresent()) {
      return false;
    }
    let navPaths: string[] = optionalPath.get().getAllPathName();
    let length: number = navPaths?.length;
    if (navPaths && length > 0 && navPaths[length - 1] === uri && IntelligentSceneWindowManager.isMainPage()) {
      LogUtil.info(`${TAG} not need to push new page for intelligent scene`);
      return true;
    }
    return false;
  }

  onBackPressed(): boolean {
    LogUtil.info(`${TAG} callback onBackPress`);
    let want: Want | undefined = AppStorage.get<Want>('wantParams');
    return want?.action === SETTINGS_HOME_ACTION;
  }

  private navigationUrlChangeNotify(uri: string | undefined): void {
    LogUtil.info(`${TAG} navigationUrlChangeNotify: ${uri}`);
    if (uri) {
      emitter.emit({
        eventId: EVENT_ID_CLOSE_THEME_FULL_SCREEN_PAGE,
        priority: emitter.EventPriority.IMMEDIATE,
      });
      emitter.emit({
        eventId: EVENT_ID_NAVIGATION_CHANGE,
        priority: emitter.EventPriority.IMMEDIATE,
      }, {
        data: {
          'navigationUrl': uri
        }
      })
    }
  }

  private async getAccountInfo(): Promise<void> {
    LogUtil.info(`${TAG} getAccountInfo begin`);
    distributedAccount.getDistributedAccountAbility()?.getOsAccountDistributedInfo()
      .catch((err: BusinessError) => {
        HiSysEventUtil.reportDefaultFaultEvent(
          HiSysLoadExternalMenuResException.EVENT_NAME,
          HiSysLoadExternalMenuResException.LOAD_OS_ACCOUNT_DISTRIBUTED_INFO_FAILED,
          `getOsAccountDistributedInfo from distributeAccount fail.code:${err?.code} `);
      })
      .then((info: void | distributedAccount.DistributedInfo) => {
        LogUtil.info(`${TAG} getAccountInfo end`);
        AppStorage.setOrCreate('accountInfo', info);
      });
  }

  private async registerEnvironmentChanged(): Promise<void> {
    let envCallback: EnvironmentCallback = {
      onConfigurationUpdated(config): void {
        if (config) {
          const envConfig: Configuration = AppStorage.get('envConfig') as Configuration;
          LogUtil.info(`${TAG} onConfigurationUpdated success:
          newConfigInfo: language:${config?.language} colorMode:${config?.colorMode} fontSizeScale:${config?.fontSizeScale}
          oldConfigInfo: language:${envConfig?.language} colorMode:${envConfig?.colorMode} fontSizeScale:${envConfig?.fontSizeScale}
          newFontId: ${config?.fontId}, oldFontId: ${envConfig?.fontId}`);
          let curLanguage: string = envConfig?.language as string;
          if (curLanguage !== config.language) {
            AppStorage.setOrCreate<Configuration>('envConfig', config);
            emitter.emit({ eventId: EVENT_ID_LANGUAGE_UPDATE });
            SearchDataController.initSearchData();
            SettingPageDescController.initPageInfoData();
          }

          let curFontSizeScale: number = envConfig?.fontSizeScale as number;
          if (curFontSizeScale !== config.fontSizeScale) {
            AppStorage.setOrCreate<Configuration>('envConfig', config);
            FontScaleUtils.setConfig(config.fontSizeScale as number);
          }
          let curColorMode: ConfigurationConstant.ColorMode = envConfig?.colorMode as ConfigurationConstant.ColorMode;
          if (config.colorMode !== ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET &&
            curColorMode !== config.colorMode) {
            EventBus.getInstance().emit(EVENT_ID_DARK_MODE_CACHE, !config.colorMode);
            HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysDisplayEventGroup.OPEN_DARK_COLOR_MODE, config.colorMode === 0 ? 'true' : 'false');
            WindowManager.setSystemBar(config.colorMode as ConfigurationConstant.ColorMode);
          };
          AppStorage.setOrCreate<Configuration>('envConfig', config);
        }
      },
      onMemoryLevel(level): void {
        LogUtil.info(`${TAG} onMemoryLevel success: ${level}`);
      }
    };
    try {
      await Promise.resolve(this.context.getApplicationContext().on('environment', envCallback));
    } catch (err) {
      LogUtil.error(`${TAG} error on environment code: ${err?.code} message: ${err?.message}`);
    }
  }

  private async tryStartStatusReportWorker(): Promise<void> {
    await workScheduler.obtainAllWorks().then((workList) => {
      if (workList.length) {
        LogUtil.info(`${TAG} statusReportWorker already exist.`);
        return
      }
      let task: taskpool.Task = new taskpool.Task(startWork);
      try {
        taskpool.execute(task, taskpool.Priority.MEDIUM);
      } catch (e) {
        LogUtil.error(`${TAG} get title failed ${(e as BusinessError).message}`);
      }
    })
  }

  private tryReportDataSize(): void {
    if (DataSizeReportHelper.isLastReportLessThan24Hour()) {
      LogUtil.showInfo(TAG, `not need report data size in 24 hours again`);
      return;
    }
    let task: taskpool.Task = new taskpool.Task(reportDataSize, this.context);
    try {
      taskpool.execute(task, taskpool.Priority.MEDIUM);
    } catch (err) {
      LogUtil.error(`${TAG} tryReportDataSize failed ${(err as BusinessError).message}`);
    }
  }

  private unregisterEnvironmentChanged(): void {
    if (this.environmentCallbackId !== INVALID_CALLBACK_ID) {
      this.context.getApplicationContext().off('environment', this.environmentCallbackId, (err) => {
        if (err) {
          LogUtil.error(`${TAG} error off environment code: ${err.code} message: ${err.message}`);
        }
      });
    }
  }
}

@Concurrent
function startWork(): void {
  const SEVEN_DAY_IN_MILLIS: number = 7 * 24 * 60 * 60 * 1000;
  const workInfo: workScheduler.WorkInfo = {
    workId: 1,
    bundleName: 'com.ohos.settings',
    abilityName: 'SettingsStatusReportSchedulerExtensionAbility',
    isRepeat: true,
    repeatCycleTime: SEVEN_DAY_IN_MILLIS,
  }
  try {
    workScheduler.startWork(workInfo);
    LogUtil.info(`MainAbility statusReportWorker success`);
  } catch (error) {
    LogUtil.error(`MainAbility statusReportWorker failed. code is ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
  }
}

@Concurrent
function reportDataSize(context: Context): void {
  AbilityContextManager.setSubThreadContext(context);
  DataSizeReportHelper.reportDataSize();
}