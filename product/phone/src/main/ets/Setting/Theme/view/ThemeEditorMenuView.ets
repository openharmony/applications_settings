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
import Common from '@ohos.app.ability.common';
import { Configuration } from '@ohos.app.ability.Configuration';
import { AlertDialog } from '@ohos.arkui.advanced.Dialog';
import { BusinessError } from '@ohos.base';
import commonEventManager from '@ohos.commonEventManager';
import Curves from '@ohos.curves';
import Display from '@ohos.display';
import emitter from '@ohos.events.emitter';
import promptAction from '@ohos.promptAction';
import Router from '@ohos.router';
import { Want, common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { settings } from '@kit.BasicServicesKit';
import { ObservedData, UiExtensionViewModel } from '@ohos/settings.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { ExitAbnormallyComponent } from '@ohos/settings.common/src/main/ets/viewmodel/ExitAbnormallyComponent';
import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant';
import { PushParam, UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageConfig } from '@ohos/settings.common/src/main/ets/framework/common/PageConfig';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import {
  EVENT_ID_SETTING_SEARCH_BACK,
  REFRESH_DESKTOP_AND_PERSONAL_PAGE,
  EVENT_ID_CLOSE_THEME_FULL_SCREEN_PAGE,
} from '@ohos/settings.common/src/main/ets/event/types';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AccessibilityLevelType } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { TsRemoteCaller } from '@ohos/settings.uikit/src/main/ets/service/api/TsRemoteCaller';
import {
  AodConfigUtil,
  AodStateValue,
  AodSwitch,
  AodDisplayMode,
  AodState
} from '@ohos/settings.theme/src/main/ets/utils/AodConfigUtil';
import { enterNoNavigationPage } from '@ohos/settings.common/src/main/ets/other/SettingsNoNavigationPage';
import { ExternalMenuPreloadManager } from '@ohos/settings.common/src/main/ets/externalmenu/ExternalMenuPreloadManager';
import { UIExtensionSessionUtils } from '@ohos/settings.common/src/main/ets/utils/UIExtensionSessionUtils';
import { LoadingDialog } from './CustomDialog';
import { ThemeSettingsController } from '../controller/ThemeSettingsController';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { ThemeEditorUtil } from '@ohos/settings.uikit/src/main/ets/utils/ThemeEditorUtil';
import { enterIconSettingPage } from '@ohos/settings.theme/src/main/ets/IconSettingPage';

const TAG: string = 'ThemeEditorMenuView';
const BUNDLE_NAME: string = 'com.ohos.sceneboard';
const ABILITY_NAME: string = 'SettingThemeComponentExtAbility';
const ENTER_INTERNAL_ENTRY: string = 'enter_internal_entry';
const LOADING_PROGRESS_WIDTH: number = 40;
const DIALOG_OFFSET: number = 0;
const ENABLE_THEME_TIME: number = 8000; // 8s
const DELETE_TIME_OUT: number = 1000;
const THEME_LOAD_FINISH: string = 'ThemeFinishLoading';
const SETTING_KEY: string = 'settings.sceneboard.aod_state';
const CUSTOM_EVENT_AOD_SETTING_CHANGE = 'custom.event.AOD_SETTING_CHANGE';
const FROM_SEARCH = 'from_search';
const FROM_EXTERNAL = 'from_external';
const PATH_INFO_SINGLE_SIZE = 1;
const INSUFFICIENT_STORAGE_SPACE = 110009; // 存储空间不足错误码

/**
 * 沉浸式背景白色
 */
const WINDOW_BG_WHITE: string = '#FFFFFF';

/**
 * 沉浸式背景黑色
 */
const WINDOW_BG_BLACK: string = '#000000';

@Component
export struct ThemeEditorMenuView {
  private controller: ThemeSettingsController = ThemeSettingsController.getInstance();
  @Prop routerName: string = 'settingsThemePage';
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State isShowGalleryMask: boolean = this.routerName === 'settingsThemePage';
  @State contentWidth: number = 0;
  @State observedData: ObservedData = new ObservedData();
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageProp('navigationMode') navigationMode: NavigationMode = NavigationMode.Stack;
  @Prop private isFromSearch: boolean = false;
  private isFocusAble: boolean = false;
  private allParams: Want | undefined = AppStorage.get<Want>('wantParams');
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  private context = getContext(this) as Common.UIAbilityContext;
  private isLoading: boolean = false;
  private mAlarmId: number = -1;
  private themeGalleryProxy: UIExtensionProxy | null = null;
  private SHORT_DELAY_TIME: number = 500;
  private COMPONENT_ANIMATE_CURVE: ICurve = Curves.interpolatingSpring(0, 0, 228, 26);
  private isSplitMode: boolean = false;
  private aodSubscriber?: commonEventManager.CommonEventSubscriber;
  private aodSubscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [CUSTOM_EVENT_AOD_SETTING_CHANGE],
    publisherBundleName: 'com.ohos.sceneboard',
  };
  private readonly subscribeInfo?: commonEventManager.CommonEventSubscribeInfo = {
    events: [THEME_LOAD_FINISH],
    publisherBundleName: 'com.ohos.sceneboard',
  };
  private static subscriber?: commonEventManager.CommonEventSubscriber;
  private readonly THEME_DETAIL_PAGE_URL: string = 'pages/theme/ThemeDetailPage';
  private readonly MORE_THEME_PAGE_URL: string = 'pages/theme/MoreThemePage';
  private readonly WALLPAPER_PAGE_URL: string = 'pages/theme/WallpaperPage';
  private readonly AOD_STYLE_PAGE_URL: string = 'pages/theme/AodStylePage';
  private readonly FONT_PAGE_URL: string = 'pages/theme/FontPage';
  private readonly ICON_PAGE_URL: string = 'pages/theme/IconPage';
  private isClickRemove: boolean = false;
  private readonly ICON_DOWNLOAD_REVERSE_INDEX: number = 3; // 图标路径中download的索引值
  private readonly WAITING_DURATION: number = 2000; // 加载等待时间，等待桌面图标重建，延时显示完成，避免资源缓存未更新的异常
  private startTime: number = 0;

  private refreshUiCallback: () => void = () => {
    LogUtil.showInfo(TAG, 'receive REFRESH_DESKTOP_AND_PERSONAL_PAGE');
    this.sendAodState();
    const timer: number = setTimeout(() => {
      this.uiRefresher.refreshUi();
      clearTimeout(timer);
    }, this.SHORT_DELAY_TIME);
  }

  private resetCloseFullScreenCallback: () => void = () => {
    LogUtil.showInfo(TAG, 'receive EVENT_ID_CLOSE_THEME_FULL_SCREEN_PAGE');
    this.resetStatusBar();
  }

  private handleSubscriberCallback(err: BusinessError, eventData: commonEventManager.CommonEventData): void {
    if (err) {
      LogUtil.showError(TAG,
        `Failed to recive commoneEvent ${eventData?.event}. Code is ${err.code}, message is ${err.message}`);
      return;
    }
    LogUtil.showInfo(TAG, `recive commoneEvent ${eventData?.event}`);
    if (eventData?.event === THEME_LOAD_FINISH) {
      if (this.isLoading) {
        this.isLoading = false;
        this.loadingController?.close();
      }
      if (this.mAlarmId !== -1) {
        clearTimeout(this.mAlarmId);
        this.mAlarmId = -1;
      }
    } else {
      LogUtil.showError(TAG, `Failed to recive commoneEvent ${eventData?.event}`);
    }
  }

  private subscriberCallback(err: BusinessError, data: commonEventManager.CommonEventSubscriber): void {
    if (err) {
      LogUtil.showError(TAG, `Failed to create subscriber. Code is ${err.code}, message is ${err.message}`);
      return;
    }
    if (!data) {
      LogUtil.showError(TAG, 'invalid subscriber.');
      return;
    }
    ThemeEditorMenuView.subscriber = data;
    if (!ThemeEditorMenuView.subscriber) {
      LogUtil.showError(TAG, 'Failed to subscribe to screen_off event, subscriber is undefined.');
      return;
    }
    LogUtil.showInfo(TAG, 'Successfully subscribed event.');
    try {
      commonEventManager.subscribe(ThemeEditorMenuView.subscriber,
        (err: BusinessError, eventData: commonEventManager.CommonEventData) => {
          this.handleSubscriberCallback(err, eventData);
        });
    } catch (e) {
      LogUtil.showError(TAG, `commonEventManager subscribe error: ${e?.message}`);
    }
  }

  private async initSubscriptions(): Promise<void> {
    try {
      commonEventManager.createSubscriber(this.subscribeInfo,
        (err: BusinessError, data: commonEventManager.CommonEventSubscriber) => {
          this.subscriberCallback(err, data);
        })
    } catch (e) {
      LogUtil.showError(TAG, `commonEventManager createSubscriber error: ${e?.message}`);
    }
    emitter.on({
      eventId: REFRESH_DESKTOP_AND_PERSONAL_PAGE,
      priority: emitter.EventPriority.IMMEDIATE,
    }, this.refreshUiCallback);
    // 监听关闭全屏页面的事件
    emitter.on({
      eventId: EVENT_ID_CLOSE_THEME_FULL_SCREEN_PAGE,
      priority: emitter.EventPriority.IMMEDIATE,
    }, this.resetCloseFullScreenCallback);
    this.initAodSettingsSubscriber();
  }

  private async initAodSettingsSubscriber(): Promise<void> {
    if (this.aodSubscriber) {
      return;
    }
    try {
      commonEventManager.createSubscriber(this.aodSubscribeInfo,
        (err: BusinessError, data: commonEventManager.CommonEventSubscriber) => {
          if (err && err.code !== 0) {
            LogUtil.showError(TAG, `Failed to create Subscriber. ${err.code} - ${err.message}`);
            return;
          }
          this.aodSubscriber = data;
          commonEventManager.subscribe(data,
            (err: BusinessError, eventData: commonEventManager.CommonEventData) => {
              if (err) {
                LogUtil.showError(TAG, `Failed to subscribe eventData:${eventData}. err = ${err.code}, ${err.message}`);
                return;
              }
              this.sendAodState();
            }
          )
        });
    } catch (err) {
      LogUtil.showError(TAG, `Failed on creating event subscriber. ${err?.code} - ${err?.message}`);
    }
  }

  private cancelSubscriptions(): void {
    LogUtil.showInfo(TAG, 'cancelSubscriptions Start');
    try {
      commonEventManager.unsubscribe(ThemeEditorMenuView.subscriber);
    } catch (e) {
      LogUtil.showError(TAG, `commonEventManager unsubscribe error: ${e?.message}`);
    }
    emitter.off(REFRESH_DESKTOP_AND_PERSONAL_PAGE, this.refreshUiCallback);
    emitter.off(EVENT_ID_CLOSE_THEME_FULL_SCREEN_PAGE, this.resetCloseFullScreenCallback);
    this.unSubscribeAodSettings();
  }

  private unSubscribeAodSettings(): void {
    try {
      if (this.aodSubscriber) {
        commonEventManager.unsubscribe(this.aodSubscriber);
        this.aodSubscriber = undefined;
      }
    } catch (err) {
      LogUtil.showError(TAG, `Failed to unsubscribe event. ${err?.code} - ${err?.message}`);
    }
  }

  deleteControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: $r('app.string.remove_this_theme'),
      content: $r('app.string.remove_theme_info'),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          let cancelDelete: Record<string, boolean> = { 'cancelDelete': true };
          this.themeGalleryProxy?.send(cancelDelete);
          this.isClickRemove = false;
        }
      },
      secondaryButton: {
        value: $r('app.string.remove'),
        fontColor: $r('sys.color.warning'),
        action: () => {
          if (!this.isClickRemove) {
            this.isClickRemove = true;
            let confirmDelete: Record<string, boolean> = { 'confirmDelete': true };
            this.themeGalleryProxy?.send(confirmDelete);
            const timer = setTimeout(() => {
              this.isClickRemove = false;
              clearTimeout(timer);
            }, DELETE_TIME_OUT);
          }
        }
      },
    }),
    cancel: () => {
      this.isClickRemove = false;
    },
    alignment: DialogAlignment.Center,
  });

  loadingController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      contentWidth: this.contentWidth,
    }),
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: DIALOG_OFFSET },
    customStyle: true,
    autoCancel: false,
  });
  recoverController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: $r('app.string.recover_Theme_App'),
      content: $r('app.string.recover_Theme_App_massage'),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          let cancelRecover: Record<string, boolean> = { 'cancelRecover': true };
          this.themeGalleryProxy?.send(cancelRecover);
        }
      },
      secondaryButton: {
        value: $r('app.string.recover'),
        action: () => {
          let confirmDelete: Record<string, boolean> = { 'confirmRecover': true };
          this.themeGalleryProxy?.send(confirmDelete);
        }
      },
    })
  })

  showRecoveredToast(): void {
    try {
      promptAction.showToast({
        message: $r('app.string.app_restored'),
        duration: 2000,
      });
    } catch (error) {
      LogUtil.showError(TAG, `showRecoveredToast error, ${error?.code}, ${error?.message}`);
    }
  }

  private enableTheme(): void {
    LogUtil.showInfo(TAG, 'enableTheme');
    if (this.loadingController) {
      this.loadingController.open();
    }
    this.isLoading = true;
    this.mAlarmId = setTimeout(() => {
      if (this.loadingController) {
        this.loadingController.close();
      }
      this.isLoading = false;
    }, ENABLE_THEME_TIME);
  }

  private sendAodState(): void {
    LogUtil.showInfo(TAG, 'getAodState start');
    let curAodState: number = AodStateValue.UNKNOWN;
    try {
      let result: string = settings.getValueSync(
        this.context, SETTING_KEY, JSON.stringify(new AodState()), settings.domainName.USER_SECURITY);
      let aodState: AodState = JSON.parse(result) as AodState;
      if (aodState.switch === AodSwitch.CLOSE) {
        curAodState = AodStateValue.CLOSE;
      } else {
        switch (aodState.displayMode) {
          case AodDisplayMode.INTELLIGENT_SHOW:
            curAodState = AodStateValue.INTELLIGENT_SHOW;
            break;
          case AodDisplayMode.SCHEDULED_SHOW:
            curAodState = AodStateValue.SCHEDULED_SHOW;
            break;
          case AodDisplayMode.ALL_DAY_SHOW:
            curAodState = AodStateValue.ALL_DAY_SHOW;
            break;
          default:
            break;
        }
      }
      let aodStateRecord: Record<string, number> = { 'aodState': curAodState };
      this.themeGalleryProxy?.send(aodStateRecord);
      LogUtil.showInfo(TAG, `getAodState success, aodState:${curAodState}`);
    } catch (e) {
      LogUtil.showError(TAG, `getAodState exception = ${e?.code}, ${e?.message}`);
    }
  }

  @Builder
  LoadingGalleryList() {
    Column()
      .width('100%')
      .height('100%')
      .visibility(this.isShowGalleryMask ? Visibility.Visible : Visibility.Hidden)
      .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
      .animation({
        curve: this.COMPONENT_ANIMATE_CURVE,
      })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .onAppear(() => {
        this.isFocusAble = true;
      })
      .onDisAppear(() => {
        this.isFocusAble = false;
      })

    Row() {
      LoadingProgress()
        .width(LOADING_PROGRESS_WIDTH)
    }
    .height('100%')
    .visibility(this.isShowGalleryMask ? Visibility.Visible : Visibility.Hidden)
    .accessibilityGroup(true)
    .accessibilityLevel(AccessibilityLevelType.NO)
  }

  uiRecoverController: CustomDialogController = new CustomDialogController({
    builder: ExitAbnormallyComponent(),
  });

  @Builder
  ThemeGallery() {
    Stack() {
      UIExtensionComponent({
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME,
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'nav': this.routerName,
          'isFull': true,
          'themeName': (AppStorage.get<Want>('wantParams') as Want)?.parameters?.themeName ?? '', // 从want中取主题名称
          'isJumpPersonalizePage': (AppStorage.get<Want>('wantParams') as Want)?.parameters?.isJumpPersonalizePage,
          'reconnect': this.observedData.reconnect,
          'isFromSearch': this.isFromSearch ? FROM_SEARCH : FROM_EXTERNAL,
          'allParams': this.allParams, // 传递want里的所有信息
          'isSplitMode':this.isSplitMode,
        }
      }, {
        dpiFollowStrategy: DpiFollowStrategy.FOLLOW_HOST_DPI
      })
        .defaultFocus(true)
        .width('100%')
        .height('100%')
        .monopolizeEvents(this.uiRefresher.refreshId ? true : true)
        .onError((error) => {
          LogUtil.showInfo(TAG, `UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
          this.viewModel.refreshing(error, this.uiRecoverController, BUNDLE_NAME, ABILITY_NAME);
        })
        .onTerminated(() => {})
        .onReceive(this.onReceiveSCBData)
        .onRemoteReady(async (proxy: UIExtensionProxy) => {
          this.themeGalleryProxy = proxy;
          AppStorage.setOrCreate('settingsThemePage', proxy);
          UIExtensionSessionUtils.sendTitleAnimationDuration(this.themeGalleryProxy, this.startTime);
          this.themeGalleryProxy?.on('asyncReceiverRegister', () => {
            UIExtensionSessionUtils.sendTitleAnimationDuration(this.themeGalleryProxy, this.startTime);
          });
        })
        .id('theme_gallery_component')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

      this.LoadingGalleryList();
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
    .onAreaChange((_oldValue: Area, newValue: Area) => {
      try {
        let isSplitMode: boolean = PageConfig.getInstance().isSplitMode();
        LogUtil.showInfo(TAG, `isSplitMode: ${isSplitMode}`);
        this.themeGalleryProxy?.send({ 'isSplitMode': isSplitMode });
      } catch (e) {
        LogUtil.showError(TAG, `getIsSplitMode fail: ${e?.code} msg ${e?.message}`);
      }
      this.contentWidth = Number(newValue.width);
      LogUtil.showInfo(TAG, `ThemeGallery onAreaChange end, this.contentWidth = ${this.contentWidth}`);
      if (this.isFocusAble) {
        try {
          this.getUIContext().getFocusController().requestFocus('theme_gallery_component');
        } catch (error) {
          LogUtil.showError(TAG, `requestFocus failed, code: ${error?.code} message: ${error?.message}`);
        }
      }
    })
  }

  private doPopAction(): void {
    if (this.isFromSearch && this.navigationMode === NavigationMode.Split) {
      emitter.emit({
        eventId: EVENT_ID_SETTING_SEARCH_BACK,
        priority: emitter.EventPriority.IMMEDIATE,
      }, {});
    } else {
      this.pathInfos.pop();
    }
  }

  private applyIcon(path: string, callBack: () => void): void {
    const remoteCaller: TsRemoteCaller = new TsRemoteCaller(this.context as common.UIAbilityContext);
    remoteCaller
      .applyIcons(path)
      .then((isSuccess: boolean) => {
        LogUtil.showInfo(TAG, `apply Icon:${isSuccess}`);
        this.themeGalleryProxy?.send({'event': 'applyIcon', 'isSuccess': isSuccess});
        if (isSuccess) {
          // 图标切换后需要等待桌面图标重建，延时一会显示完成，避免资源缓存未更新的异常
          setTimeout(() => {
            callBack();
          }, this.WAITING_DURATION);
        }
      })
      .catch((err: BusinessError) => {
        this.themeGalleryProxy?.send({ 'event': 'applyIcon', 'isSuccess': false });
        callBack();
        LogUtil.showError(TAG, `aboutToAppear currentIcon:${err?.code}, ${err?.message}`);
        ThemeEditorUtil.openToast(this.getUIContext(), err, $r('app.string.icon_apply_failed'));
      });
  }

  private applyThemeIcon(path: string, callBack: () => void): void {
    const remoteCaller: TsRemoteCaller = new TsRemoteCaller(getContext() as common.UIAbilityContext);
    remoteCaller
      .activateThemeIcon(path)
      .then((isSuccess: boolean) => {
        LogUtil.showInfo(TAG, `apply ThemeIcon:${isSuccess}`);
        this.themeGalleryProxy?.send({'event': 'applyOnlineIcon', 'isSuccess': isSuccess});
        if (isSuccess) {
          // 图标切换后需要等待桌面图标重建，延时一会显示完成，避免资源缓存未更新的异常
          setTimeout(() => {
            callBack();
          }, this.WAITING_DURATION);
        }
      })
      .catch((err: BusinessError) => {
        this.themeGalleryProxy?.send({'event': 'applyOnlineIcon', 'isSuccess': false});
        callBack();
        LogUtil.showError(TAG, `error in applyThemeIcon:${err?.code}, ${err?.message}`);
        ThemeEditorUtil.openToast(this.getUIContext(), err, $r('app.string.icon_apply_failed'));
      });
  }

  private onReceiveSCBData: (data: object) => void = (data: object) => {
    LogUtil.showInfo(TAG, 'SCB UIExtension onReceive');
    if (data && data['onItemClick'] !== undefined) {
      if (data['onItemClick'] === 'settingWallpaperItem') {
        LogUtil.showInfo(TAG, `onItemClick settingWallpaperItem`);
        let message: string = `pageUrl: ${this.WALLPAPER_PAGE_URL}`;
        HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
        this.pushName('theme_wallpaper', null);
      } else if (data['onItemClick'] === 'settingAodItem') {
        LogUtil.showInfo(TAG, `onItemClick settingAodItem`);
        this.settingAodItemClick();
      } else if (data['onItemClick'] === 'settingIconItem') {
        LogUtil.showInfo(TAG, `onItemClick settingIconItem`);
        let message: string = `pageUrl: ${this.ICON_PAGE_URL}`;
        HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
        this.pushName('theme_icon', null);
      } else if (data['onItemClick'] === 'settingFontStyleItem') {
        LogUtil.showInfo(TAG, `onItemClick settingFontStyleItem`);
        let message: string = `pageUrl: ${this.FONT_PAGE_URL}`;
        HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
        this.pushName('theme_font', null);
      } else if (data['onItemClick'] === 'settingMoreTheme') {
        LogUtil.showInfo(TAG, `onItemClick settingMoreTheme`);
        let message: string = `pageUrl: ${this.MORE_THEME_PAGE_URL}`;
        HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
        this.pushName('more_theme', null);
      } else if (data['onItemClick'] === 'desktopSettings') {
        LogUtil.showInfo(TAG, `onItemClick desktopSetting`);
        let message: string = `pageUrl: ${NavEntryKey.DESKTOP_SETTINGS}`;
        HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
        this.pushName(NavEntryKey.DESKTOP_SETTINGS, null);
      } else if (data['onItemClick'] === 'aodSettings') {
        LogUtil.showInfo(TAG, `onItemClick aodSetting`);
        let message: string = `pageUrl: ${NavEntryKey.AOD_SETTINGS_ENTRY}`;
        HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
        this.pushName(NavEntryKey.AOD_SETTINGS_ENTRY, null);
      }
    }

    if ((data['themeDetailClick'] !== undefined) && (data['themeDetailClick'] !== null)) {
      let detailParam: string = data['themeDetailClick'] as string;
      let message: string = `pageUrl: ${this.THEME_DETAIL_PAGE_URL}`;
      HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
      let param: PushParam = new PushParam(detailParam, undefined, undefined);
      this.pushName('theme_detail', param);
    }
    if (data['back'] !== undefined) {
      if (this.pathInfos.size() === PATH_INFO_SINGLE_SIZE) {
        if (this.navigationMode === NavigationMode.Split && !this.isFromSearch) {
          Router.back();
        } else {
          this.doPopAction();
        }
      } else {
        this.doPopAction();
      }
    }
    if (data['wallpaperEditor'] !== undefined) {
      LogUtil.showInfo(TAG, 'start to open fullscreen wallpaperEditor');
      let want: Want = {
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME,
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'nav': 'wallpaperEditor',
          'wallpaperParam': data['wallpaperEditor'],
        }
      };
      enterNoNavigationPage(want, true);
    }
    if (data['wallpaperPickerDetailExt'] !== undefined) {
      LogUtil.showInfo(TAG, 'start to open fullscreen wallpaperPickerDetailExt');
      let want: Want = {
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME,
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'nav': 'wallpaperPickerDetailExt',
          'wallpaperParam': data['wallpaperPickerDetailExt'],
        }
      };
      enterNoNavigationPage(want, true, true);
    }
    if (data['iconEditor'] !== undefined) {
      LogUtil.showInfo(TAG, 'start to open fullscreen iconEditor');
      const loadingController: CustomDialogController = new CustomDialogController({
        builder: LoadingDialog({
          contentWidth: this.contentWidth,
          textContent: $r('app.string.applyIcon')
        }),
        alignment: DialogAlignment.Center,
        offset: { dx: 0, dy: DIALOG_OFFSET },
        customStyle: true,
        autoCancel: false,
      });
      loadingController.open();
      let iconPath: string = data['iconEditor']?.['iconPath'];
      if (StringUtil.isEmpty(iconPath)) {
        LogUtil.showWarn(TAG, 'iconPath is invaild');
        return;
      }
      let iconPathParentDir: string[] = iconPath.split('/');
      if (!iconPathParentDir) {
        LogUtil.showWarn(TAG, 'iconPathParentDir is invaild');
        return;
      }
      if (iconPathParentDir.length > this.ICON_DOWNLOAD_REVERSE_INDEX &&
        iconPathParentDir[iconPathParentDir.length - this.ICON_DOWNLOAD_REVERSE_INDEX] === 'download') {
        LogUtil.showInfo(TAG, 'receive iconEditor success, apply theme icon');
        this.applyThemeIcon(data['iconEditor']?.['iconPath'], () => {
          loadingController.close();
        });
      } else {
        LogUtil.showInfo(TAG, 'receive iconEditor success, apply preset icon');
        this.applyIcon(data['iconEditor']?.['iconPath'], () => {
          loadingController.close();
        });
      }
      return;
    }
    if (data['fontPath'] !== undefined) {
      LogUtil.showInfo(TAG, 'start to open fullscreen fontDetail');
      let want: Want = {
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME,
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'nav': 'fontDetail',
          'fontPath': data['fontPath'],
        }
      };
      enterNoNavigationPage(want, false);
    }
    if (data['fullPage'] !== undefined) {
      LogUtil.showInfo(TAG, 'start to open fullscreen page');
      let want: Want = {
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME,
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'fullPage': data['fullPage'],
        }
      };
      const isFull: boolean = data['isFull'] as boolean ?? true;
      enterNoNavigationPage(want, isFull);
    }
    if (data['themeParams'] !== undefined) {
      LogUtil.showInfo(TAG, 'start to open fullscreen themeDetail');
      let want: Want = {
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME,
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'nav': 'themeDetail',
          'themeParams': data['themeParams'],
        }
      };
      enterNoNavigationPage(want, false);
    }

    if (data['cancel'] !== undefined) {
      LogUtil.showInfo(TAG, 'start to cancel Load');
      this.loadingController?.close();
    }

    if (data && data['hideStatusBar'] !== undefined) {
      try {
        window.getLastWindow(getContext(this), (err, win) => {
          win?.setWindowSystemBarEnable(data['hideStatusBar'] as boolean ? [] : ['status', 'navigation']);
        });
      } catch (e) {
        LogUtil.showError(TAG, `hideStatusBar fail ${e?.code} msg ${e?.message}`);
      }
    }
    if (data['apply'] !== undefined) {
      LogUtil.showInfo(TAG, 'SCB UIExtension onReceive: apply');
      this.enableTheme();
    }
    if (data['themeDetailApply'] !== undefined) {
      LogUtil.showInfo(TAG, 'SCB UIExtension onReceive: themeDetailApply');
      if (data['themeDetailApply'] === 'themeDetailDialogOpen') {
        this.loadingController?.open();
      } else {
        this.loadingController?.close();
      }
    }
    if (data && data['systemBarColorChange'] !== undefined) {
      LogUtil.showInfo(TAG, 'SCB UIExtension onReceive: systemBarColorChange');
      if (data['systemBarColorChange'] == 'white') {
        try {
          window.getLastWindow(getContext(this)).then((window) => {
            let systemBarProperties: window.SystemBarProperties = {
              statusBarContentColor: WINDOW_BG_WHITE,
              navigationBarContentColor: WINDOW_BG_WHITE
            };
            window.setWindowSystemBarProperties(systemBarProperties);
          });
        } catch (e) {
          LogUtil.showError(TAG, `systemBarColorChange fail ${e?.code} msg ${e?.message}`);
        }
      }
      if (data['systemBarColorChange'] == 'reset') {
        this.resetStatusBar();
      }
    }
    if (data && data['themeFullScreen'] !== undefined) {
      try {
        window.getLastWindow(getContext(this), (err, win) => {
          win?.setWindowSystemBarEnable(data['themeFullScreen'] as boolean ? [] : ['status', 'navigation']);
          win?.setWindowLayoutFullScreen(data['themeFullScreen'] as boolean);
        });
      } catch (e) {
        LogUtil.showError(TAG, `themeFullScreen fail ${e?.code} msg ${e?.message}`);
      }
    }
    if (data && data['shouldShowStatus'] !== undefined) {
      try {
        window.getLastWindow(getContext(this), (err, win) => {
          win?.setSpecificSystemBarEnabled('status', data['shouldShowStatus'] as boolean);
          win?.setWindowLayoutFullScreen(data['shouldShowStatus'] as boolean);
        });
      } catch (e) {
        LogUtil.showError(TAG, `shouldShowStatus fail: ${e?.code} msg ${e?.message}`);
      }
    }
    if (data['deleteTheme'] !== undefined) {
      LogUtil.showInfo(TAG, 'SCB UIExtension onReceive: delete_theme');
      this.deleteControllerConfirm.open();
    }
    if (data['hideGalleryLoading'] !== undefined) {
      this.isShowGalleryMask = false;
      this.sendAodState();
    }
    if (data['recoverThemeApp'] !== undefined) {
      LogUtil.showInfo(TAG, 'SCB UIExtension onReceive: recover_ThemeApp');
      this.recoverController.open();
    }
    if (data['appRecovered'] !== undefined) {
      LogUtil.showInfo(TAG, 'SCB UIExtension onReceive: app_recovered');
      this.showRecoveredToast();
    }
    if (data && data['iconEditPageWant'] !== undefined) {
      LogUtil.showInfo(TAG, 'SCB UIExtension onReceive: IconEditPageWant');
      enterIconSettingPage(data['iconEditPageWant']);
    }
  };

  private resetStatusBar(): void {
    try {
      window.getLastWindow(getContext(this)).then((window) => {
        const config = AppStorage.get<Configuration>('envConfig');
        if (config) {
          let systemBarProperties: window.SystemBarProperties = {
            statusBarContentColor: config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT ?
              WINDOW_BG_BLACK : WINDOW_BG_WHITE,
            navigationBarContentColor: config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT ?
              WINDOW_BG_BLACK : WINDOW_BG_WHITE
          };
          window.setWindowSystemBarProperties(systemBarProperties);
        }
      });
    } catch (e) {
      LogUtil.showError(TAG, `resetStatusBar fail ${e?.code} msg ${e?.message}`);
    }
  }

  private settingAodItemClick(): void {
    if (AodConfigUtil.isSupportAOD()) {
      let message: string = `pageUrl: ${this.AOD_STYLE_PAGE_URL}`;
      HiSysEventUtil.reportEntryEvent(ENTER_INTERNAL_ENTRY, message);
      this.pushName(NavEntryKey.AOD_STYLE_ENTRY, null);
    } else {
      try {
        LogUtil.showInfo(TAG, 'onItemClick settingAodItem: not support AOD');
        promptAction.showToast({ message: $r('app.string.uncompleted') });
      } catch (e) {
        LogUtil.showError(TAG, 'showToast args error');
      }
    }
  }

  pushName(key: string, params: PushParam | null) {
    DynamicLoader.getInstance().fire(key).then(() => {
      this.pathInfos?.pushPathByName(key, params);
    });
  }

  async aboutToAppear(): Promise<void> {
    LogUtil.showInfo(TAG, 'ThemeEditorMenuView aboutToAppear.');
    this.startTime = new Date().getTime();
    this.viewModel.listening(this.uiRecoverController);
    await this.initSubscriptions();
    await this.controller.updateThemeGalleryWindowStatus(getContext(), this.themeGalleryProxy, false);
    try {
      this.isSplitMode = PageConfig.getInstance().isSplitMode();
    } catch (e) {
      LogUtil.showError(TAG, `getIsSplitMode fail: ${e?.code} msg ${e?.message}`);
    }
  }

  aboutToDisappear(): void {
    LogUtil.showInfo(TAG, 'ThemeEditorMenuView aboutToDisappear');
    this.cancelSubscriptions();
    this.resetStatusBar();
    this.viewModel.destroyListening();
    try {
      ExternalMenuPreloadManager.getInstance().preloadUIExtensionAbility(ABILITY_NAME, getContext());
    } catch (err) {
      LogUtil.showInfo(TAG, `preload themeComponentExtAbilty failed. err: ${err?.code} ${err?.message}`);
    }
    this.controller.updateThemeGalleryWindowStatus(getContext(), this.themeGalleryProxy, true);
  }

  build() {
    if (this.uiRefresher.refreshId) {
      Column() {
        this.ThemeGallery();
      }
    }
  }
}