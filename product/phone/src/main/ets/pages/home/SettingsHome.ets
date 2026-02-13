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

import taskpool from '@ohos.taskpool';
import Window from '@ohos.window';
import emitter from '@ohos.events.emitter';
import display from '@ohos.display';
import Want from '@ohos.app.ability.Want';
// import search from '@hms.ai.search';
// import { BackgroundBrightnessLevel } from '@hms.hds.hdsBaseComponent';
// import { HdsNavigation, HdsNavigationAttribute, HdsNavigationTitleMode } from '@kit.UIDesignKit';
import { commonEventManager } from '@kit.BasicServicesKit';
import { BusinessError } from '@ohos.base';
import { homeInitData } from '@ohos/settings.common/src/main/ets/sendable/HomeInitData';
import { SearchDataController } from '@ohos/settings.search/src/main/ets/controller/SearchController';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { Params } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import {
  HiSysEventUtil,
} from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { EVENT_ID_NAVIGATION_CHANGE,
  EVENT_ID_CAPSULE_NAVIGATION_CHANGE } from '@ohos/settings.common/src/main/ets/event/types';
import { AppManager } from '@ohos/settings.application/src/main/ets/util/AppManager';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { ExternalMenuPreloadManager } from '@ohos/settings.common/src/main/ets/externalmenu/ExternalMenuPreloadManager'
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import { PageStartReason } from '@ohos/settings.common/src/main/ets/data/types';
import { PageLoader, PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { PageConfig, ScreenType } from '@ohos/settings.common/src/main/ets/framework/common/PageConfig';
import { settingPageBuilder } from '@ohos/settings.common/src/main/ets/framework/view/SettingPage';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
// import { FaceAuthDynamicLoader } from '@hw-hmos/settings-face-auth/src/main/ets/faceauth/Utils/Dynamic';
import { Trace } from '@ohos/settings.common/src/main/ets/utils/Trace';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { DefaultPageConfig } from '@ohos/settings.common/src/main/ets/framework/common/DefaultPageConfig';
import lazy { ThemeManager } from '@ohos/settings.application/src/main/ets/util/ThemeManager';
import lazy { bindBuilder2Comp } from '@ohos/settings.common/src/main/ets/utils/BinderUtil';
import { WalletManageUtils } from '@ohos/settings.common/src/main/ets/utils/WalletManageUtils';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
// import lazy { FaceAuthNavigationInterceptions } from '@hw-hmos/settings-face-auth/src/main/ets/faceauth/Manager/FaceAuthNavigationInterceptions';
import { HiSysSettingHomeEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { PenglaiUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import lazy { initBluetoothState } from '../../Setting/Home/controller/HomePageMenuManager';
import lazy { PageRouteController } from './controller/PageRouteController';
import lazy { ExportPageController, PushParam } from './controller/ExportPageController';
import lazy { SearchSettingsComponent } from '../../Setting/Search/SearchSettings';

const TAG: string = 'SettingsHome : ';
const DEFAULT_PAGE_DELAY: number = 40;
const THEME_COMPONENT_EXT_ABILITY: string = 'SettingThemeComponentExtAbility';
const AOD_SETTINGS_ABILITY: string = 'AodSettingsAbility';
const PRELOAD_DELAY: number = 350;
const DELAY_LOAD_TIME: number = 1000;

// 隐私页面
const SAFETY_PAGES: string[] = [
  NavEntryKey.LOCK_SCREEN_PASSWORD_ENTRY,
  NavEntryKey.CREATE_NUMBER_PSD_ENTRY,
  NavEntryKey.CREATE_MIX_PSD_ENTRY,
  NavEntryKey.CREATE_FOUR_PSD_ENTRY,
  NavEntryKey.CHECK_PSD_ENTRY,
  NavEntryKey.UNDER_SCREEN_FINGERPRINT_INTRO_ENTRY,
  NavEntryKey.UNDER_SCREEN_FINGERPRINT_ENROLL_ENTRY,
  NavEntryKey.OUT_SCREEN_FINGERPRINT_ENROLL_ENTRY,
  NavEntryKey.FINGERPRINT_DECLARATION_ENTRY,
  NavEntryKey.FINGERPRINT_ANIMATION_ENTRY,
  NavEntryKey.FINGERPRINT_CAROUSEL_ENTRY,
  NavEntryKey.FINGERPRINT_SETTING_ENTRY,
  NavEntryKey.UNDER_SCREEN_FINGERPRINT_IDENTIFICATION_ENTRY,
  NavEntryKey.FACE_SETTING_ENTRY,
  NavEntryKey.FACE_AUTH_PREFERENCE_ENTRY,
  NavEntryKey.FACE_AUTH_FEATURE_GUIDE_ENTRY,
  NavEntryKey.FACE_AUTH_ENROLL_ENTRY,
  NavEntryKey.FACE_AUTH_ENROLL_GUIDE_3D_ENTRY,
  NavEntryKey.FACE_AUTH_DECLARATION_3D_ENTRY,
  NavEntryKey.FACE_AUTH_DECLARATION_2D_ENTRY,
  NavEntryKey.FACE_AUTH_MASK_GUIDE_ENTRY,
  NavEntryKey.MULTI_FINGERPRINT_INTRO_ENTRY,
  NavEntryKey.INNER_SCREEN_FINGERPRINT_ENROLL_ENTRY,
  NavEntryKey.EXTERNAL_SCREEN_FINGERPRINT_ENROLL_ENTRY,
]

@Builder
function dummyFunction($$: Params) {
  if (LogUtil.printBuilderLog(`${TAG} dummy settings loader`)) {
  }
};

@Builder
function buildWrapper(builder: Function | undefined, param?: Object) {
  builder?.(param as Params);
}

@Entry
@Component
struct SettingsHome {
  exportPageController: ExportPageController = new ExportPageController();
  loaderFunctionMap: Map<String, Function> = new Map([
    [NavEntryKey.LOCK_SCREEN_PASSWORD_ENTRY, this.loadCreateSixPinSettings],
    [NavEntryKey.DESKTOP_SETTINGS, this.loadDeskTopSettings],
    [NavEntryKey.CREATE_NUMBER_PSD_ENTRY, this.loadCreateNumberPsdSettings],
    [NavEntryKey.CREATE_MIX_PSD_ENTRY, this.loadMixedPsdSettings],
    [NavEntryKey.CREATE_FOUR_PSD_ENTRY, this.loadFourPsdSettings],
    [NavEntryKey.CHECK_PSD_ENTRY, this.loadCheckPasswordSettings],
    [NavEntryKey.AUTHORIZATION_ENTRY, this.loadAuthorizationSettings],
    [NavEntryKey.WIFI_ENTRY, this.loadWifiSettings],
    [NavEntryKey.WIFI_MENU_ENTRY, this.loadWifiPasswordSettings],
    [NavEntryKey.WIFI_MENU_CONFIG_ENTRY, this.loadWifiConfigSettings],
    [NavEntryKey.BIOMETRICS_PASSWORD_ENTRY, this.loadBiometricsAndPasswordSettings],
    [NavEntryKey.AOD_SETTINGS_ENTRY, this.loadAodSettings],
    [NavEntryKey.AOD_STYLE_ENTRY, this.loadAodStyle],
    [NavEntryKey.OOBE_UI_EXTENSION_WIFI_ENTRY, this.loadOobeWifiSettings],
    [NavEntryKey.THEME_ENTRY, this.loadThemeSettings],
    [NavEntryKey.PRIVACY_ENTRY, this.loadPrivacySettings],
    [NavEntryKey.PRIVACY_ENTRY_INNER, this.loadPrivacySettings],
    [NavEntryKey.DATA_TIME_ENTRY, this.loadDateAndTimeSettings],
    [NavEntryKey.INPUT_ENTRY, this.loadInputSettings],
    [NavEntryKey.OTHER_INPUT_DETAIL_SETTINGS, this.loadOtherInputEntry],
    [NavEntryKey.INPUT_UIEXTENSION_LIST, this.loadUiExtensionList],
    [NavEntryKey.TIME_ZONE_ENTRY, this.loadTimeZoneSettings],
    [NavEntryKey.SET_LANGUAGE_ENTRY, this.loadLanguageSettingsHome],
    [NavEntryKey.LANGUAGE_REGION_ENTRY, this.loadLanguageAndRegionPage],
    [NavEntryKey.DEVELOP_OPTION_ENTRY, this.loadDeveloperOptionsSettings],
    [NavEntryKey.EDIT_LANGUAGE_ENTRY, this.loadEditLanguage],
    [NavEntryKey.ADD_LANGUAGE_ENTRY, this.loadAddLanguage],
    [NavEntryKey.SELECT_REGION_ENTRY, this.loadSelectRegion],
    [NavEntryKey.CONFIRM_RESET_FACTORY_ENTRY, this.loadConfirmResetFactorySettings],
    [NavEntryKey.CONFIRM_RESET_NET_ENTRY, this.loadConfirmResetNetSettings],
    [NavEntryKey.HOTSPOT_CONNECTED_ENTRY, this.loadConnectedDevicesSettings],
    [NavEntryKey.BLOCK_LIST_ENTRY, this.loadApBlackListSettings],
    [NavEntryKey.WIFI_PRECISION_MENU_ENTRY, this.loadWifiPrecisionSetting],
    [NavEntryKey.MOBILE_DATA_SETTING_ENTRY, this.loadMobileDateSettings],
    [NavEntryKey.DATA_USAGE_MANAGEMENT_ENTRY, this.loadDataUsageManage],
    [NavEntryKey.AUDIO_BUTLER_ENTRY, this.loadAudioButlerSettings],
    [NavEntryKey.ADD_OTHER_WIFI_ENTRY, this.loadAddOtherWifiPage],
    [NavEntryKey.WIFI_SETUP_PROXY_ENTRY, this.loadWifiSetupProxyPage],
    [NavEntryKey.WIFI_SETUP_IP_ENTRY, this.loadWifiSetupIpPage],
    [NavEntryKey.PHONE_NOTIFICATION_SETTINGS_ENTRY, this.loadNotificationSettings],
    [NavEntryKey.SYSTEM_ROLLBACK_ENTRY, this.loadSystemRollback],
    [NavEntryKey.SYSTM_WIRELESS_COMMISSIONING, this.loadWirelessCommissioningSetting],
    [NavEntryKey.FACE_AUTH_PREFERENCE_ENTRY, this.loadFaceAuth],
    [NavEntryKey.FACE_AUTH_FEATURE_GUIDE_ENTRY, this.loadFaceAuth],
    [NavEntryKey.FACE_AUTH_DECLARATION_2D_ENTRY, this.loadFaceAuth],
    [NavEntryKey.FACE_AUTH_DECLARATION_3D_ENTRY, this.loadFaceAuth],
    [NavEntryKey.FACE_AUTH_ENROLL_GUIDE_3D_ENTRY, this.loadFaceAuth],
    [NavEntryKey.FACE_AUTH_MASK_GUIDE_ENTRY, this.loadFaceAuth],
    [NavEntryKey.FACE_AUTH_ENROLL_ENTRY, this.loadFaceAuth],
    [NavEntryKey.DEFAULT_PAYMENT_APPLICATION, this.loadDefaultPaymentApplication],
    [NavEntryKey.WALLPAPER_PICKER_ENTRY, this.loadWallpaperPickerSettings],
    [NavEntryKey.DEVICE_AND_APPLICATION_ENTRY, this.loadDeviceAndApplicationSettings],
    [NavEntryKey.ENTERPRISE_DEVICE_MANAGEMENT_ENTRY, this.loadEnterpriseDeviceManagementSettings],
    [NavEntryKey.ENTERPRISE_APPLICATION_MANAGEMENT_ENTRY, this.loadEnterpriseApplicationManagementSettings],
    [NavEntryKey.START_FIND_DEVICE_ENTRY, this.loadFindDevice],
    [NavEntryKey.WIFI_INSTALL_CERTIFICATE_ENTRY, this.loadWifiInstallCertificateSetting],
    [NavEntryKey.CLONE_APP_AUTH, this.cloneAppsAuth],
    [NavEntryKey.START_WALLET_ENTRY, this.loadStartWallet],
    [NavEntryKey.MUSIC_SERVICE, this.loadMusicServicePage],
    [NavEntryKey.VIBRATE_SERVICE, this.loadVibrateServicePage],
    [NavEntryKey.VPN_EDIT_ENTRY, this.loadVPNEdit],
    [NavEntryKey.UNIVERSAL_DRAG_ENTRY, this.loadUniversalDrag]
  ]);
  private themeSubTimeoutId: number | null = null;

  @StorageProp('navigationUrl') internalNavigationUrl: string = '';
  @Provide('pathInfos') pathInfos: NavPathStack = new NavPathStack();
  @StorageProp('isSearching') @Watch('handleSearchChange') isSearching: boolean = false;
  @State currentUrl: string[] = [''];
  private navBarWidth: string = '40%';
  @BuilderParam settingPageLoader: ($$: Params) => void = dummyFunction;
  @StorageProp('defaultNavigationMode') defaultNavigationMode: NavigationMode = NavigationMode.Auto;
  @State private homePageUrl: string = this.getHomeUrl();

  // scroller
  private listScroller: Scroller = new Scroller();
  private powerEvent: CommonEventHelper = new CommonEventHelper({
    events: [commonEventManager.Support.COMMON_EVENT_POWER_SAVE_MODE_CHANGED]
  }, () => {
    this.onOutdoorPowerModeChange();
  });
  private onOutdoorPowerModeChange = async () => {
    let homeUrl:string = this.getHomeUrl();
    LogUtil.info(`${TAG} onOutdoorPowerModeChange current ${homeUrl} last ${this.homePageUrl}`);
    if (this.homePageUrl === homeUrl) {
      LogUtil.info(`${TAG} mode is not change,no need refresh page`);
      return;
    }
    await PageRouter.load(homeUrl);
    this.homePageUrl = homeUrl;
    PageRouter.clear('Setting');
  }

  @Builder pageBuilder(param: PageParams): void {
    if (param && param.pageCtx) {
      param.pageCtx.pageBuilder?.builder(param);
    }
  }

  @Builder
  myRouter(name: string, param?: Object) {
    if (LogUtil.printBuilderLog(`${TAG} my router: ${name}, length is ${name?.length}`)) {
      if (DynamicLoader.getInstance().loaderMap.has(name)) {
        buildWrapper(bindBuilder2Comp(this,
          DynamicLoader.getInstance().loaderMap.get(name) as ($$: Params) => void), param);
      } else if (PageRouteController.getInstance().isPageAdapted(name)) {
        this.pageBuilder(param as PageParams);
      } else {
        this.settingPageLoader(param as Params);
      }
    }
  }

  async dynamicLoadCallBack(key: string): Promise<boolean> {
    LogUtil.info(`${TAG} dynamicLoadCallBack: ${key}, length is ${key?.length}`);
    if (DynamicLoader.getInstance().loaderMap.has(key)) {
      return true;
    }

    if (!this.loaderFunctionMap.has(key)) {
      return false;
    }

    await bindBuilder2Comp(this, this.loaderFunctionMap.get(key))();
    if (DynamicLoader.getInstance().loaderMap.get(key)) {
      LogUtil.info(`${TAG} set data to settingPageLoader.`);
      this.settingPageLoader = (DynamicLoader.getInstance().loaderMap.get(key) as ($$: Params) => void);
    } else {
      LogUtil.info(`${TAG} ${key} is not in loaderMap.`);
    }
    LogUtil.info(`${TAG} page transition function name: ${DynamicLoader.getInstance().loaderMap.get(key)?.name}`);
    return true;
  }

  // 全局搜索页面需要拦截系统返回消息
  onBackPress() {
    LogUtil.info(`${TAG} callback onBackPress`);
    if (this.isSearching) {
      PageStartModeManager.getInstance().setStartReason(PageStartReason.DEFAULT);
      this.onChildButtonClicked();
      return true;
    }
    return false;
  }

  /* instrument ignore next */
  private onChildButtonClicked(): void {
    if (AppStorage.get<NavigationMode>('navigationMode') === NavigationMode.Split) {
      // 分栏状态下搜索页和进入搜索前页面一致并且没有通过搜索跳转的页面需要重新加载
      let curPageParam: PageParams | undefined = this.pathInfos?.getParamByIndex(0) as PageParams;
      let startReason: string | undefined = PageStartReason.DEFAULT;
      let allPath: string[] = this.pathInfos.getAllPathName();
      let currentPath: string | undefined = allPath.length > 0 ? allPath[0] : undefined;
      if (curPageParam) {
        startReason = (curPageParam.param as PushParam)?.startReason;
      }
      if (this.currentUrl.length === 0) {
        this.LoadDefaultPage(NavigationMode.Split);
      } else if (this.currentUrl[0] === currentPath && startReason !== PageStartReason.FROM_SEARCH){
        LogUtil.info(`${TAG} current url equals pathInfos top and not from search staying this page.`);
      } else {
        this.pathInfos.clear();
        let topEntry: string = this.currentUrl[0];
        if (PageRouteController.getInstance().isPageAdapted(topEntry)) {
          PageRouter.push(topEntry, this.pathInfos?.getParamByName(topEntry));
        } else {
          this.pathInfos.pushPathByName(topEntry, this.pathInfos?.getParamByName(topEntry));
        }
        this.exportPageController.sendShowBgEventToHomeEntry(topEntry);
      }
    }
    AccessibilityUtils.requestFocusAccessibility('homPageSearchInputColumn');
    LogUtil.info(`${TAG} onChildButtonClicked`);
    animateTo({
      duration: 500,
      curve: Curve.FastOutSlowIn
    }, () => {
      AppStorage.setOrCreate('isSearching', false);
    })
  }

  handleSearchChange(): void {
    if (this.isSearching) {
      this.currentUrl = this.pathInfos.getAllPathName();
      let homeKey: string = AppStorage.get('currentHomeKey') as string;
      if (this.currentUrl.length === 0 && homeKey) {
        this.currentUrl.push(homeKey);
      }
    }
  }

  private registerThemeListener() {
    if (this.themeSubTimeoutId == null) {
      this.themeSubTimeoutId = setTimeout(() => {
        ThemeManager.getInstance().subscribeThemeEvent();
        this.themeSubTimeoutId = null;
      }, 500);
    }
  }

  /* instrument ignore next */
  private unregisterThemeListener() {
    if (this.themeSubTimeoutId != null) {
      clearTimeout(this.themeSubTimeoutId);
      this.themeSubTimeoutId = null;
    }
    ThemeManager.getInstance().unsubscribeThemeEvent();
  }

  build() {
    Navigation(this.pathInfos) {
    // HdsNavigation(this.pathInfos) {
      if (this.isSearching) {
        Column() {
          SearchSettingsComponent({ onBackButtonClicked: () => {
            this.onChildButtonClicked();
          }
          })
        }
        .id('SearchSettingsComponent')
      } else {
        // @State传递到@Builder里的参数，根据参数获取map中对应值通过方法封装后，无法触发界面刷新
        // 此处先通过if-else相同逻辑处理，后续优化
       if (this.homePageUrl === NavEntryKey.PENG_LAI_HOME_PAGE) {
          this.homePageBuilder()
        } else {
          this.homePageBuilder()
        }
      }
    }
    .title($r('app.string.settings_title'))
    // .bindToScrollable([this.listScroller])
    .onNavigationModeChange((mode) => {
      LogUtil.info(`${TAG} onNavigationModeChange ${mode}`);
      AppStorage.setOrCreate<NavigationMode>('navigationMode', mode);
      PageConfig.getInstance().setPageConfigGlobal({
        defaultPageConfig: DefaultPageConfig.getInstance(),
        defaultPageBuilder: wrapBuilder(settingPageBuilder),
        screenType: ScreenType.SCREEN_TYPE_SMALL,
        navMode: mode
      });
      this.setBarWidthByWindowSize();
      this.LoadDefaultPage(mode);
      this.refreshSelectHomeItem(mode);
      emitter.emit({ eventId: EVENT_ID_CAPSULE_NAVIGATION_CHANGE });
    })
    .enableModeChangeAnimation(false)
    .mode(this.defaultNavigationMode)
    .navBarWidth(this.navBarWidth)
    .hideTitleBar(this.isSearching, true)
    .title($r('app.string.settings_title'))
    // .titleBar({
    //   style: {
    //     scrollEffectOpts: {
    //       enableScrollEffect: true
    //     },
    //     scrollEffectStyle: {
    //       backgroundStyle: {
    //         backgroundBrightnessLevel: BackgroundBrightnessLevel.ENHANCED
    //       }
    //     }
    //   },
    //   content: {
    //     title: {
    //       mainTitle: $r('app.string.settings_title')
    //     }
    //   }
    // })
    .backgroundColor(Color.Transparent)
    .navDestination(this.myRouter)
    .titleMode(NavigationTitleMode.Free)
    .hideBackButton(true)
    .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    .keyboardShortcut('F', [ModifierKey.CTRL], () => {
      focusControl.requestFocus('homPageSearchInput');
      AppStorage.setOrCreate('isSearching', true);
    })
  }

  @Builder
  homePageBuilder() {
    this.pageBuilder({
      router: 'Setting',
      pageUrl: this.homePageUrl,
      pageCtx: PageLoader.getPageContext(this.homePageUrl).get(),
      listScroller: this.listScroller
    })
  }

  private refreshSelectHomeItem(mode: NavigationMode): void {
      let homeKey: string = AppStorage.get('currentHomeKey') as string;
      LogUtil.info(`${TAG} onNavigationModeChange ${mode} ${homeKey}`);
      notifyCompStateChange(homeKey,
        new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SELECTED,
          { state: mode === NavigationMode.Split } as SettingCompState]]));
  }

  /* instrument ignore next */
  LoadDefaultPage(mode: NavigationMode): void {
    if (!this.pathInfos.size() && !this.internalNavigationUrl && mode === NavigationMode.Split && !this.isSearching) {
      let defaultEntry = NavEntryKey.ABOUT_DEVICE_ENTRY;
      if (PenglaiUtil.isPengLaiModeOpen()) {
        defaultEntry = NavEntryKey.WIFI_ENTRY;
      }
      LogUtil.info(`${TAG} defaultEntry internal Url: ${defaultEntry}, ${this.internalNavigationUrl}`);
      if (CheckEmptyUtils.checkStrIsEmpty(this.internalNavigationUrl)) {
        PageRouter.push(defaultEntry);
        AppStorage.setOrCreate('currentHomeKey', defaultEntry);
      }
    }
  }

  pageRouterInit(): void {
    PageConfig.getInstance().setPageConfigGlobal({
      defaultPageConfig: DefaultPageConfig.getInstance(),
      defaultPageBuilder: wrapBuilder(settingPageBuilder),
      screenType: ScreenType.SCREEN_TYPE_SMALL,
      navMode: NavigationMode.Auto
    });
    PageRouter.createRouter('Setting', {
      rootDir: '../../',
      loader: async (entryKey: string): Promise<void> => {
        let pageUrl: string = PageRouteController.getInstance().getPageUrl(entryKey) as string;
        LogUtil.showInfo(TAG, `import file ${entryKey} ${pageUrl}`);
        await import(pageUrl);
      },
      path: this.pathInfos,
      isHomeEntryPage: (url: string): boolean => {
        return PageRouteController.getInstance().isHomeEntryPage(url);
      },
      dfxKeyGetter: (url: string): string | undefined => {
        return PageRouteController.getInstance().getDfxKey(url);
      }
    });
    PageRouter.push(this.homePageUrl, undefined, true);
  }

  registerNavPathInterception() {
    this.pathInfos?.setInterception({
      willShow: (from: NavDestinationContext | NavBar, to: NavDestinationContext | NavBar,
        operation: NavigationOperation, isAnimated: boolean) => {
        // FaceAuthNavigationInterceptions.getInstance().willShow(from, to, operation, isAnimated);
      },
      didShow: (from: NavDestinationContext | NavBar, to: NavDestinationContext | NavBar,
        operation: NavigationOperation, isAnimated: boolean) => {
        // FaceAuthNavigationInterceptions.getInstance().didShow(from, to, operation, isAnimated);
      },
      modeChange: (mode: NavigationMode) => {
        // FaceAuthNavigationInterceptions.getInstance().modeChange(mode);
      }
    });
  }

  unregisterNavPathInterception() {
    this.pathInfos?.setInterception({});
  }

  private getHomeUrl(): string {
    return PenglaiUtil.isPengLaiModeOpen() ? NavEntryKey.PENG_LAI_HOME_PAGE : 'Setting.Home';
  }

  aboutToAppear(): void {
    Trace.start('SettingsHome aboutToAppear');
    LogUtil.info(`${TAG} aboutToAppear internal Url: ${this.internalNavigationUrl}`);
    this.registerNavigationChange();
    this.registerThemeListener();
    this.registerPowerModeChange();
    AppStorage.setOrCreate<NavPathStack>(PackagesConstant.SETTINGS_PATH_STACK, this.pathInfos);
    DynamicLoader.getInstance().register(async (str: string): Promise<boolean> => {
      return await this.dynamicLoadCallBack(str);
    });
    // FaceAuthDynamicLoader.getInstance().registerLoader(async (str: string): Promise<boolean> => {
    //   return await this.dynamicLoadCallBack(str);
    // });
    if (DeviceUtil.is2In1Device()) {
      const delayLoadTimer = setTimeout(() => {
        SearchDataController.getInstance().updateSearchItemStatus('screen_lock_tone', !DeviceUtil.is2In1DevicePcType());
        clearTimeout(delayLoadTimer);
      }, DELAY_LOAD_TIME);
    }
    this.internalNavigationUrlChange(this.internalNavigationUrl);
    AppManager.getInstance().unRegisterEventListener();
    AppManager.getInstance().registerEventListener();
    this.unregisterNavPathInterception();
    this.registerNavPathInterception();
    this.pageRouterInit();
    this.internalNavigationUrl = PackagesConstant.SETTINGS_EMPTY_STRING;
    try {
      ExternalMenuPreloadManager.getInstance().preloadUIExtensionAbility(AOD_SETTINGS_ABILITY, getContext());
    } catch (err) {
      LogUtil.warn(`${TAG} preload AOD_SETTINGS_ABILITY failed. err: ${err}`);
    }

    setTimeout(() => {
      try {
        ExternalMenuPreloadManager.getInstance().preloadUIExtensionAbility(THEME_COMPONENT_EXT_ABILITY, getContext());
      } catch (err) {
        LogUtil.warn(`${TAG} preload themeComponentExtAbilty failed. err: ${err}`);
      }
    }, PRELOAD_DELAY);
    Trace.end('SettingsHome aboutToAppear');
  }

  private async registerPowerModeChange(): Promise<void> {
    if (PenglaiUtil.isPengLaiModeSupported()) {
      this.powerEvent.registerCommonEvent();
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    try {
      emitter.off(EVENT_ID_NAVIGATION_CHANGE);
    } catch (error) {
      LogUtil.info(`${TAG} unregisterStateChange error: ${(error as BusinessError).message}`);
    }
    this.unregisterNavPathInterception();
    this.unregisterThemeListener();
    this.unregisterPowerModeChange();
    PageRouter.clear('Setting');
    this.exportPageController.clearTimer();
    this.unRegisterFoldDisplayModeChange();
  }

  private async unregisterPowerModeChange(): Promise<void> {
    if (PenglaiUtil.isPengLaiModeSupported()) {
      this.powerEvent.unRegisterCommonEvent();
    }
  }

  private unRegisterFoldDisplayModeChange() {
    try {
      display.off('foldDisplayModeChange');
      LogUtil.info(`${TAG} off foldDisplayModeChange success`);
    } catch (e) {
      LogUtil.error(`${TAG} off foldDisplayModeChange error`);
    }
  }

  private async updateBluetoothState(): Promise<void> {
    try {
      let initBluetoothStateTask: taskpool.Task = new taskpool.Task(initBluetoothState, homeInitData,
        AbilityContextManager.getContext());
      await taskpool.execute(initBluetoothStateTask, taskpool.Priority.MEDIUM);
      AbilityContextManager.getContext()?.eventHub.emit(CommonEventConstant.EVENT_BLUETOOTH_STATE_CHANGE);
    } catch (error) {
      LogUtil.error(`${TAG} catch exception when updateBluetoothState, errmsg: ${error?.message}`);
    }
  }

  onPageShow(): void {
    Trace.start('SettingsHome onPageShow');
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSettingHomeEventGroup.INTO_SETTING);
    let windowSize: Window.Size = AppStorage.get<Window.Size>('windowSize') ?? { width: 0, height: 0 };
    LogUtil.info(`${TAG} onPageShow width: ${windowSize.width}, height: ${windowSize.height}`);
    this.updateBluetoothState();
    DynamicLoader.getInstance().pageTransitionSuccess(TAG);
    if (AppStorage.get('isMainPageReport') as boolean) {
      AbilityUtils.pageReportCallback(TAG);
      AppStorage.setOrCreate('isMainPageReport', false);
      LogUtil.info(`${TAG} report compeleted`);
    }
    Trace.end('SettingsHome onPageShow');
  };

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.safeRetreat();
    // 页面隐藏后关闭搜索session
    // try {
    //   let searchSession: search.SearchSession =
    //     AppStorage.get<search.SearchSession>('SettingsSearchSession') as search.SearchSession;
    //   if (!CheckEmptyUtils.isEmpty(searchSession)) {
    //     search.endSearch(searchSession);
    //     LogUtil.showInfo(TAG, 'PageHide endSearchSession.');
    //     AppStorage.delete('SettingsSearchSession');
    //   }
    // } catch (err) {
    //   LogUtil.showError(TAG, `PageHide endSearchSession error: ${err?.message}`);
    // }
  }

  /* instrument ignore next */
  safeRetreat(): void {
    const pathNames: string[] = this.pathInfos?.getAllPathName() ?? [];
    if (pathNames.length === 0) {
      return;
    }
    const topName: string = pathNames[pathNames.length - 1];
    LogUtil.info(`${TAG} top page: ${topName}`);
    if (SAFETY_PAGES.indexOf(topName) >= 0) {
      if (pathNames.indexOf(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY) >= 0) {
        // import('@hw-hmos/settings-face-auth/src/main/ets/faceauth/Manager/ContextManager').then((contextManager) => {
        //   contextManager.default.destroy();
        // });
        this.pathInfos?.popToName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY, false);
      } else if (pathNames.indexOf(NavEntryKey.RESET_FACTORY) >= 0) {
        this.pathInfos?.pop();
      } else if (pathNames.indexOf(NavEntryKey.RESET_NET) >= 0) {
        this.pathInfos?.pop();
      } else if (pathNames.indexOf(NavEntryKey.ABOUT_DEVICE_ENTRY) >= 0) {
        this.pathInfos?.clear(false);
        PageRouter.redirectPage(NavEntryKey.ABOUT_DEVICE_ENTRY, false);
      } else {
        this.safetyPageDefaultRouter(topName);
      }
    } else {
      this.noSafetyPageDefaultRouter(topName);
    }
  }

  private safetyPageDefaultRouter(topName: string): void {
    LogUtil.info(`${TAG} safetyPageDefaultRouter`);
    DynamicLoader.getInstance().fire(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY).then(() => {
      if (CommonUtils.isFromSearch()) {
        this.dealHideSearchPage(topName);
      } else {
        this.pathInfos?.pushPathByName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY, null, false);
      }
    });
  }

  private noSafetyPageDefaultRouter(topName: string): void {
    LogUtil.info(`${TAG} topName no in safety_pages`);
    if (!CommonUtils.isFromSearch()) {
      LogUtil.info(`${TAG} not from search`);
      return;
    }
    DynamicLoader.getInstance().fire(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY).then(() => {
      this.dealHideSearchPage(topName);
    });
  }

  private dealHideSearchPage(topName: string): void {
    switch (topName) {
      case NavEntryKey.FINGERPRINT_SETTING_ENTRY:
      case NavEntryKey.CHECK_PSD_ENTRY:
      case NavEntryKey.LOCK_SCREEN_PASSWORD_ENTRY:
      case NavEntryKey.CREATE_NUMBER_PSD_ENTRY:
      case NavEntryKey.CREATE_MIX_PSD_ENTRY:
      case NavEntryKey.CREATE_FOUR_PSD_ENTRY:
        this.pathInfos?.replacePathByName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY, null, false);
        break;
      case NavEntryKey.UNDER_SCREEN_FINGERPRINT_INTRO_ENTRY:
      case NavEntryKey.UNDER_SCREEN_FINGERPRINT_ENROLL_ENTRY:
      case NavEntryKey.FINGERPRINT_DECLARATION_ENTRY:
      case NavEntryKey.OUT_SCREEN_FINGERPRINT_ENROLL_ENTRY:
        this.pathInfos?.pop(false);
        this.pathInfos?.replacePathByName(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY, null, false);
        break;
      default:
        break;
    }
  }

  anyMatchPathTop(target: string[]): boolean {
    if (!this.pathInfos?.size()) {
      return false;
    }
    return target.includes(this.pathInfos?.getAllPathName()[this.pathInfos?.size() - 1]);
  }

  private popToName(target: string): boolean {
    try {
      if (this.pathInfos?.popToName(target, true) !== -1) {
        return true;
      }
    } catch (e) {
      LogUtil.error(`${TAG} popToName failed！ reason: ${e?.code}  ${e?.message}`);
    }
    return false;
  }

  handleOUCNavigationUrlChange(uri: string): boolean {
    let parameters = AppStorage.get<Want>('wantParams')?.parameters;
    let targetUri = (parameters?.subUri ?? uri) as string;
    LogUtil.info(`${TAG} handleOUCNavigationUrlChange uri: ${uri}, subUri: ${parameters?.subUri}`);
    if (uri === NavEntryKey.OUC_SOFTWARE_UPDATE_SETTINGS) {
      if (this.popToName(NavEntryKey.ABOUT_DEVICE_ENTRY)) {
        LogUtil.info(`${TAG} OUC_KEY_GROUP exist`);
        return true;
      }
    } else if (uri === NavEntryKey.OUC_PARAM_VERSION) {
      AppStorage.setOrCreate<string>('com_hmos_ouc_param_version_settings_target_sub_router', targetUri);
      if (this.anyMatchPathTop([NavEntryKey.OUC_PARAM_VERSION])) {
        LogUtil.info(`${TAG} OUC_PARAM_VERSION exist`);
        return true;
      }
    }
    let param = AppStorage.get<Want>('wantParams')?.parameters?.pushParams as Record<string, Object>;
    if (this.isToOucAccessory(uri, param)) {
      LogUtil.info(`${TAG} com_hmos_ouc_accessory_settings_target_sub_router: ${uri}`);
      AppStorage.setOrCreate<string>('com_hmos_ouc_accessory_settings_target_sub_router', uri);
      return true;
    }
    return false;
  }

  handleOUCNavigationUrlTrans(uri: string): string {
    if (uri === NavEntryKey.OUC_SOFTWARE_UPDATE_SETTINGS) {
     return NavEntryKey.ABOUT_DEVICE_ENTRY;
    }
    return uri;
  }

  isToOucAccessory(uri: string, param: Record<string, Object>): boolean {
    const containOucAccessoryUris = [NavEntryKey.PAD_KEYBOARD_FIRMWARE_UPGRADE.toString(),
      NavEntryKey.AUDIO_BUTLER_ENTRY.toString()];
    if (!param) {
      return false;
    }
    return containOucAccessoryUris.includes(uri) && this.anyMatchPathTop([uri]) &&
      StringUtil.isNotEmpty(param.accessoryUrl as string);
  }

  async internalNavigationUrlChange(uri: string): Promise<void> {
    let target: string = uri;
    target = await this.checkExtensionPageUri(target);
    LogUtil.info(`${TAG} nav url change to ${uri},final to ${target}`);
    if (CheckEmptyUtils.checkStrIsEmpty(target)) {
      return;
    }
    if (this.handleOUCNavigationUrlChange(target)) {
      return;
    }
    target = this.handleOUCNavigationUrlTrans(target);

    this.clear();
    let mode: NavigationMode = AppStorage.get('navigationMode') as NavigationMode;
    if(WalletManageUtils.isFromWallet() && !WalletManageUtils.checkWalletPermission() &&
        WalletManageUtils.checkWalletAppIdentifier()) {
      return;
    }
    await this.exportPageController.pageRoute(this.pathInfos, target, mode === NavigationMode.Split);
  }

/**
 * 检查外部跳转UIExtension是否可用
 * @param target
 * @returns
 */
  private async checkExtensionPageUri(target: string): Promise<string> {
    return target;
  }

  clear() {
    this.pathInfos?.clear();
  }

  setBarWidthByWindowSize(): void {
    if (!PageConfig.getInstance().isSplitMode()) {
      return;
    }
    LogUtil.info(`${TAG} setBarWidthByWindowSize`);
    try {
      (AppStorage.get<Window.WindowStage>('windowStage') as Window.WindowStage)?.getMainWindow((err, data) => {
        if (!data) {
          LogUtil.error(`${TAG} Failed to setBarWidthByWindowSize, data is empty`);
          return;
        }
        this.registerWindowSizeChange(data);
        let windowRect: Window.Rect = data.getWindowProperties()?.windowRect;
        if (!windowRect) {
          LogUtil.error(`${TAG} Failed to setBarWidthByWindowSize, windowRect is empty`);
          return;
        }
        WindowManager.setNavBarWidth(windowRect.width);
        AppStorage.setOrCreate<Window.Size>('windowSize', { width: windowRect.width, height: windowRect.height });
      })
    } catch (err) {
      LogUtil.error(`${TAG} Failed to setBarWidthByWindowSize, code: ${err?.code} message: ${err?.message}`);
    }
  }

  private registerWindowSizeChange(data: Window.Window): void {
    data?.off('windowSizeChange');
    data?.on('windowSizeChange', (size: Window.Size) => {
      const windowMode: number = AppStorage.get('windowMode') as number;
      LogUtil.info(`${TAG} windowSizeChange mode: ${windowMode}, size: ${size?.width}, ${size?.height}`);
      if (PageConfig.getInstance().isSplitMode()) {
        WindowManager.setNavBarWidth(size?.width as number);
      }
      AppStorage.setOrCreate<Window.Size>('windowSize', size);
    });
  }

  async registerNavigationChange(): Promise<void> {
    LogUtil.info(`${TAG} registerNavigationChange`);
    emitter.on({
      eventId: EVENT_ID_NAVIGATION_CHANGE,
      priority: emitter.EventPriority.IMMEDIATE,
    }, async (eventData: emitter.EventData) => {
      this.internalNavigationUrl = PackagesConstant.SETTINGS_EMPTY_STRING;
      let uri: string = eventData?.data?.navigationUrl;
      LogUtil.info(`${TAG} registerNavigationChange uri is ${uri}`);
      this.internalNavigationUrlChange(uri);
    });
  }

  private async loadCreateSixPinSettings(): Promise<void> {
    let createSixPinSettingsLoader = await import('../password/CreateSixPinSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.LOCK_SCREEN_PASSWORD_ENTRY,
      createSixPinSettingsLoader.CreateSixPinSettingsLoader);
  }

  private async loadDeskTopSettings(): Promise<void> {
    let deskTopSettingsLoader = await import('@ohos/settings.theme');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.DESKTOP_SETTINGS,
      deskTopSettingsLoader.DesktopSettingsLoader);
  }

  private async loadAodSettings(): Promise<void> {
    let aodSettingsLoader = await import('@ohos/settings.theme');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.AOD_SETTINGS_ENTRY, aodSettingsLoader.AodSettingsLoader);
  }

  private async loadAodStyle(): Promise<void> {
    let aodStyleLoader = await import('@ohos/settings.theme');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.AOD_STYLE_ENTRY, aodStyleLoader.AodStyleLoader);
  }

  private async loadThemeSettings(): Promise<void> {
    let themeSettingsLoader = await import('@ohos/settings.theme');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.THEME_ENTRY, themeSettingsLoader.ThemeSettingsLoader);
  }

  private async loadCreateNumberPsdSettings(): Promise<void> {
    let createNumberPsdSettingsLoader = await import('../password/CreateNumberPsdSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.CREATE_NUMBER_PSD_ENTRY,
      createNumberPsdSettingsLoader.CreateNumberPsdSettingsLoader);
  }

  private async loadMixedPsdSettings(): Promise<void> {
    let createMixedPsdSettingsLoader = await import('../password/CreateMixedPsdSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.CREATE_MIX_PSD_ENTRY,
      createMixedPsdSettingsLoader.CreateMixedPsdSettingsLoader);
  }

  private async loadFourPsdSettings(): Promise<void> {
    let createFourPsdSettingsLoader = await import('../password/CreateFourPinSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.CREATE_FOUR_PSD_ENTRY,
      createFourPsdSettingsLoader.CreateFourPinSettingsLoader);
  }

  private async loadCheckPasswordSettings(): Promise<void> {
    let checkPasswordSettingsLoader = await import('../password/CheckPasswordSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.CHECK_PSD_ENTRY,
      checkPasswordSettingsLoader.CheckPasswordSettingsLoader);
  }

  private async loadAuthorizationSettings(): Promise<void> {
    let authorizationSettingsLoader = await import('../reset/AuthorizationSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.AUTHORIZATION_ENTRY,
      authorizationSettingsLoader.AuthorizationSettingsLoader);
  }

  private async loadWifiSettings(): Promise<void> {
    let wifiSettingsLoader = await import('../wifi/WifiSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.WIFI_ENTRY, wifiSettingsLoader.WifiSettingsLoader);
  }

  private async loadWifiPasswordSettings(): Promise<void> {
    let wifiPasswordSettingsLoader = await import('../wifi/WifiPasswordSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.WIFI_MENU_ENTRY,
      wifiPasswordSettingsLoader.WifiPasswordSettingsLoader);
  }

  private async loadWifiConfigSettings(): Promise<void> {
    let wifiConfigSettingsLoader = await import('../wifi/WifiConfigSetting');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.WIFI_MENU_CONFIG_ENTRY,
      wifiConfigSettingsLoader.WifiConfigSettingLoader);
  }

  private async loadBiometricsAndPasswordSettings(): Promise<void> {
    let biometricsAndPasswordSettingsLoader =
      await import('../biometricsandpassword/BiometricsAndPasswordSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.BIOMETRICS_PASSWORD_ENTRY,
      biometricsAndPasswordSettingsLoader.BiometricsAndPasswordSettingsLoader);
  }

  private async loadOobeWifiSettings(): Promise<void> {
    let oobeWifiSettingsLoader = await import('../wifi/OobeWifiExtensionSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.OOBE_UI_EXTENSION_WIFI_ENTRY,
      oobeWifiSettingsLoader.OobeWifiExtensionSettingsLoader);
  }

  private async loadPrivacySettings(): Promise<void> {
    let privacySettingLoader = await import ('../../Setting/Privacy/PrivacySettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.PRIVACY_ENTRY, privacySettingLoader.PrivacySettingsLoader);
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.PRIVACY_ENTRY_INNER, privacySettingLoader.PrivacySettingsLoader);
  }

  private async loadDateAndTimeSettings(): Promise<void> {
    let dateAndTimeSettingsLoader = await import('../datetime/DateAndTimeSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.DATA_TIME_ENTRY,
      dateAndTimeSettingsLoader.DateAndTimeSettingsLoader);
  }

  private async loadInputSettings(): Promise<void> {
    let inputSettingsLoader = await import('../input/InputSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.INPUT_ENTRY, inputSettingsLoader.InputSettingsLoader);
  }

  private async loadOtherInputEntry(): Promise<void> {
    let otherInputEntryLoader = await import('../input/otherInputDetailSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.OTHER_INPUT_DETAIL_SETTINGS,
      otherInputEntryLoader.OtherInputDetailSettingsLoader);
  }

  private async loadUiExtensionList(): Promise<void> {
    let uiExtensionListLoader = await import('../input/uiExtensionList');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.INPUT_UIEXTENSION_LIST,
      uiExtensionListLoader.UiExtensionListLoader);
  }

  private async loadTimeZoneSettings(): Promise<void> {
    let timeZoneSettingsLoader = await import('../datetime/TimeZoneSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.TIME_ZONE_ENTRY,
      timeZoneSettingsLoader.TimeZoneSettingsLoader);
  }

  private async loadLanguageSettingsHome(): Promise<void> {
    let languageSettingsHomeLoader = await import('../system/languageSettings/LanguageSettingsHome');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.SET_LANGUAGE_ENTRY,
      languageSettingsHomeLoader.LanguageSettingsHomeLoader);
  }

  private async loadLanguageAndRegionPage(): Promise<void> {
    let languageAndRegionPageLoader =
      await import('../system/languageSettings/languageAndRegion/LanguageAndRegionPage');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.LANGUAGE_REGION_ENTRY,
      languageAndRegionPageLoader.LanguageAndRegionPageLoader);
  }

  private async loadDeveloperOptionsSettings(): Promise<void> {
    let developerOptionsSettingsLoader = await import('../developeroptions/DeveloperOptionsSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.DEVELOP_OPTION_ENTRY,
      developerOptionsSettingsLoader.DeveloperOptionsSettingsLoader);
  }

  private async loadEditLanguage(): Promise<void> {
    let editLanguageLoader = await import('../system/languageSettings/languageAndRegion/EditLanguage');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.EDIT_LANGUAGE_ENTRY, editLanguageLoader.EditLanguageLoader);
  }

  private async loadAddLanguage(): Promise<void> {
    let addLanguageLoader = await import('../system/languageSettings/languageAndRegion/AddLanguage');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.ADD_LANGUAGE_ENTRY, addLanguageLoader.AddLanguageLoader);
  }

  private async loadSelectRegion(): Promise<void> {
    let selectRegionLoader = await import('../system/languageSettings/languageAndRegion/SelectRegion');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.SELECT_REGION_ENTRY, selectRegionLoader.SelectRegionLoader);
  }

  private async loadConfirmResetFactorySettings(): Promise<void> {
    let confirmResetFactorySettingsLoader = await import('../reset/ConfirmResetFactorySettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.CONFIRM_RESET_FACTORY_ENTRY,
      confirmResetFactorySettingsLoader.ConfirmResetFactorySettingsLoader);
  }

  private async loadConfirmResetNetSettings(): Promise<void> {
    let confirmResetNetSettingsLoader = await import('../reset/ConfirmResetNetSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.CONFIRM_RESET_NET_ENTRY,
      confirmResetNetSettingsLoader.ConfirmResetNetSettingsLoader);
  }

  private async loadConnectedDevicesSettings(): Promise<void> {
    let connectedDevicesSettingsLoader = await import('../mobilenetwork/ConnectedDevicesSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.HOTSPOT_CONNECTED_ENTRY,
      connectedDevicesSettingsLoader.ConnectedDevicesSettingsLoader);
  }

  private async loadApBlackListSettings(): Promise<void> {
    let blockListSettingsLoader = await import('../mobilenetwork/BlockListSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.BLOCK_LIST_ENTRY,
      blockListSettingsLoader.BlockListSettingsLoader);
  }

  private async loadWifiPrecisionSetting(): Promise<void> {
    let wifiPrecisionSettingLoader = await import('../wifi/WifiPrecisionSetting');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.WIFI_PRECISION_MENU_ENTRY,
      wifiPrecisionSettingLoader.WifiPrecisionSettingLoader);
  }

  private async loadMobileDateSettings(): Promise<void> {
    let mobileDataSettingsLoader = await import('../mobilenetwork/MobileDataSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.MOBILE_DATA_SETTING_ENTRY,
      mobileDataSettingsLoader.MobileDataSettingLoader);
  }

  private async loadDataUsageManage(): Promise<void> {
    let dataUsageManagementLoader = await import('../mobilenetwork/DataUsageManagement');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.DATA_USAGE_MANAGEMENT_ENTRY,
      dataUsageManagementLoader.DataUsageManagementLoader);
  }

  private async loadAudioButlerSettings(): Promise<void> {
    let audioButlerSettingsLoader = await import('../../Setting/Bluetooth/AudioButlerSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.AUDIO_BUTLER_ENTRY,
      audioButlerSettingsLoader.AudioButlerSettingsLoader);
  }

  private async loadAddOtherWifiPage(): Promise<void> {
    let addOtherWifiPage = await import('../wifi/AddOtherWifiPage');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.ADD_OTHER_WIFI_ENTRY,
      addOtherWifiPage.AddOtherWifiPageLoader);
  }

  private async loadWifiSetupProxyPage(): Promise<void> {
    let wifiSetupProxyPage = await import('../wifi/WifiSetupProxyPage');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.WIFI_SETUP_PROXY_ENTRY,
      wifiSetupProxyPage.WifiSetupProxyPageLoader);
  }

  private async loadWifiSetupIpPage(): Promise<void> {
    let wifiSetupIpPage = await import('../wifi/WifiSetupIpPage');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.WIFI_SETUP_IP_ENTRY,
      wifiSetupIpPage.WifiSetupIpPageLoader);
  }

  private async loadNotificationSettings(): Promise<void> {
    let notificationSettingsLoader = await import('../../Setting/SystemUi/NotificationSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.PHONE_NOTIFICATION_SETTINGS_ENTRY,
      notificationSettingsLoader.NotificationSettingsLoader);
  }

  private async loadSystemRollback(): Promise<void> {
    let systemRollbackLoader = await import('../developeroptions/SystemRollback');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.SYSTEM_ROLLBACK_ENTRY,
      systemRollbackLoader.SystemRollbackLoader);
  }

  private async loadWirelessCommissioningSetting(): Promise<void> {
    let wirelessCommissioningSettingLoader = await import('../developeroptions/wirelessCommissioningSetting');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.SYSTM_WIRELESS_COMMISSIONING,
      wirelessCommissioningSettingLoader.wirelessCommissioningSettingLoader);
  }

  private async loadFaceAuth(): Promise<void> {
    // let faceLoader = await import('@hw-hmos/settings-face-auth');
    // let loaderMap = DynamicLoader.getInstance().loaderMap;
    // loaderMap.set(NavEntryKey.FACE_AUTH_PREFERENCE_ENTRY, faceLoader.FaceAuthPreferenceLoader);
    // loaderMap.set(NavEntryKey.FACE_AUTH_FEATURE_GUIDE_ENTRY, faceLoader.FaceAuthFeatureGuideLoader);
    // loaderMap.set(NavEntryKey.FACE_AUTH_DECLARATION_2D_ENTRY, faceLoader.FaceAuthDeclaration2dLoader);
    // loaderMap.set(NavEntryKey.FACE_AUTH_DECLARATION_3D_ENTRY, faceLoader.FaceAuthDeclaration3dLoader);
    // loaderMap.set(NavEntryKey.FACE_AUTH_MASK_GUIDE_ENTRY, faceLoader.FaceAuthMaskGuideLoader);
    // loaderMap.set(NavEntryKey.FACE_AUTH_ENROLL_ENTRY, faceLoader.FaceAuthEnrollLoader);
  }

  private async loadDefaultPaymentApplication(): Promise<void> {
    let defaultPaymentApplicationLoader = await import('../moreconnection/DefaultPaymentApplicationSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.DEFAULT_PAYMENT_APPLICATION,
      defaultPaymentApplicationLoader.DefaultPaymentApplicationLoader);
  }

  private async loadWallpaperPickerSettings(): Promise<void> {
    let wallpaperPickerLoader = await import('@ohos/settings.theme');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.WALLPAPER_PICKER_ENTRY,
      wallpaperPickerLoader.WallpaperPickerLoader);
  }

  private async loadDeviceAndApplicationSettings(): Promise<void> {
    let deviceAndApplicationSettingsLoader =
      await import('../deviceandapplication/DeviceAndApplicationSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.DEVICE_AND_APPLICATION_ENTRY,
      deviceAndApplicationSettingsLoader.DeviceAndApplicationLoader);
  }

  private async loadEnterpriseApplicationManagementSettings(): Promise<void> {
    let enterpriseApplicationManagementSettingsLoader =
      await import('../deviceandapplication/EnterpriseApplicationManagementSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.ENTERPRISE_APPLICATION_MANAGEMENT_ENTRY,
      enterpriseApplicationManagementSettingsLoader.EnterpriseApplicationManagementSettingsLoader);
  }

  private async loadEnterpriseDeviceManagementSettings(): Promise<void> {
    let enterpriseDeviceManagementSettingsLoader =
      await import('../deviceandapplication/EnterpriseDeviceManagementSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.ENTERPRISE_DEVICE_MANAGEMENT_ENTRY,
      enterpriseDeviceManagementSettingsLoader.EnterpriseDeviceManagementSettingsLoader);
  }

  private async loadFindDevice(): Promise<void> {
    let startFindDeviceSettings = await import('../reset/finddevice/StartFindDeviceSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.START_FIND_DEVICE_ENTRY,
      startFindDeviceSettings.StartFindDeviceSettingsLoader);
  }

  private async loadWifiInstallCertificateSetting(): Promise<void> {
    let wifiInstallCertificateSettingLoader = await import('@ohos/settings.wifi/src/main/ets/WifiInstallCertificateSetting');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.WIFI_INSTALL_CERTIFICATE_ENTRY,
      wifiInstallCertificateSettingLoader.WifiInstallCertificateSettingLoader);
  }

  private async cloneAppsAuth(): Promise<void> {
    let cloneAppsAuth = await import('@ohos/settings.cloneapps/src/main/ets/AuthorizationContainer');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.CLONE_APP_AUTH, cloneAppsAuth.AuthorizationContainerLoader);
  }

  private async loadStartWallet(): Promise<void> {
    let startWalletPage = await import('../reset/startwallet/StartWalletPage');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.START_WALLET_ENTRY,
      startWalletPage.StartWalletSettingsLoader);
  }

  private async loadMusicServicePage(): Promise<void> {
    let musicServiceLoader = await import('../../Setting/Volume/view/MusicServiceComponent');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.MUSIC_SERVICE, musicServiceLoader.MusicServiceLoader);
  }

  private async loadVibrateServicePage(): Promise<void> {
    let vibrateServiceLoader = await import('../../Setting/Volume/view/VibrateServiceComponent');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.VIBRATE_SERVICE, vibrateServiceLoader.VibrateServiceLoader);
  }

  private async loadVPNEdit(): Promise<void> {
    let vpnEditLoader = await import('../../Setting/MoreConnection/VpnEditPage');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.VPN_EDIT_ENTRY,
      vpnEditLoader.VpnEditLoader);
  }

  private async loadUniversalDrag(): Promise<void> {
    let universalDragLoader = await import('../../Setting/System/UniversalDrag/UniversalDragSettings');
    DynamicLoader.getInstance().loaderMap.set(NavEntryKey.UNIVERSAL_DRAG_ENTRY,
      universalDragLoader.UniversalDragSettingsLoader);
  }
}
