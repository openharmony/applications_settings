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

import { LengthMetrics } from '@ohos.arkui.node';
import { router } from '@kit.ArkUI';
import emitter from '@ohos.events.emitter';
import { BusinessError } from '@ohos.base';
import commonEventManager from '@ohos.commonEventManager';
import { EVENT_ID_SETTING_SEARCH_BACK } from '@ohos/settings.common/src/main/ets/event/types';
import {
  INIT_AVOID_WIDTH,
  INIT_DEFAULT_WIDTH,
  INVALID_AVOID_WIDTH,
} from '@ohos/settings.common/src/main/ets/utils/Consts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { EventBus, EventCb } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { ObservedData, UiExtensionViewModel } from '@ohos/settings.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { IAboutDevicePageCtrl } from '../controller/IAboutDevicePageCtrl';
import { OucCardModel } from '../model/OucCardModel';
import {
  AboutDeviceCardAction,
  AboutDeviceOucPublishData,
  AnimateType,
  OucAboutDeviceViewModel,
  OUC_CARD_IMG_MARGIN
} from '../model/OucAboutDeviceViewModel';
import { EVENT_ID_ABOUT_DEVICE_ON_PAGE_HIDE, EVENT_ID_ABOUT_DEVICE_ON_PAGE_SHOW } from '../const/AboutDeviceConst';

const PRELOAD_IMG_HIDE_DURATION = 500;
const BUNDLE_NAME = 'com.ohos.updateapp';
const ABILITY_NAME = 'com.ohos.updateapp.SettingsCardAbility';

/**
 * 关于本机页面OUC卡片
 *
 * @since 2024-03-29
 */
@Component
export struct OucAboutDeviceCard {
  tag: string = 'OucAboutDeviceCard : ';
  uiExtensionProxy?: UIExtensionProxy;
  @ObjectLink pageModel: OucCardModel;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageProp('navigationMode') @Watch('onNavigationModeChange')
  navigationMode: NavigationMode = NavigationMode.Stack;
  @StorageProp('aboutDeviceFoldCardLength') @Watch('onAboutDeviceFoldCardLengthChange')
  aboutDeviceFoldCardLength: number = 0;
  @StorageProp('com_hmos_ouc_software_update_settings_target_sub_router')
  @Watch('onTargetSubRouterChange') targetSubRouter: string = '';
  @State observedData: ObservedData = new ObservedData();
  @StorageProp('navDesDynamicPadding')
  @Watch('onNavDesDynamicPaddingChange') navDesDynamicPadding: number =
    AppStorage.get<number>('navDesDynamicPadding') as number;
  @State defaultAvoidWidth: number | undefined = INIT_DEFAULT_WIDTH;
  private titleButtonRectWidth: number = INIT_AVOID_WIDTH;
  private controller?: IAboutDevicePageCtrl = undefined;
  private isSplit: boolean = this.navigationMode === NavigationMode.Split;
  private foldCardLength: number = this.aboutDeviceFoldCardLength;
  private pushParams: PushParam | null = null;
  private startReason: string = '';
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  private errorInfo: BusinessError | null = null;
  private errorTimes: number = 0;
  private uriTargetSubRouter: string = '';
  private isAboutDevicePageOnPageShow = true;
  private foregroundCb = () => {
    LogUtil.info(`${this.tag} foreground event Cb`);
    this.pageRestore();
  };
  private onPageShowCallback: EventCb = () => {
    this.isAboutDevicePageOnPageShow = true;
    this.pageRestore();
  };
  private onPageHideCallback: EventCb = () => {
    this.isAboutDevicePageOnPageShow = false;
    this.errorTimes = 0;
  };
  private targetSubRouterToJump?: string;
  private targetSubRouterParamsToJump?: Record<string, Object>;
  private isCardReady: boolean = false;
  @State private accessibilitySamePageMode: AccessibilitySamePageMode = AccessibilitySamePageMode.FULL_SILENT;
  private subscriber?: commonEventManager.CommonEventSubscriber;
  private readonly subscribeInfo?: commonEventManager.CommonEventSubscribeInfo = {
    events: [
      commonEventManager.Support.COMMON_EVENT_PACKAGE_CHANGED
    ]
  };

  build() {
    Stack() {
      if (this.pageModel?.isOucPreloadImgShow) {
        this.oucPreloadImgBuild()
      }
      this.oucUIExtensionBuild()
    }
    .alignContent(Alignment.TopStart)
  }

  @Builder
  private oucPreloadImgBuild(): void {
    Column() {
      Image(this.pageModel.getPreviewUri())
        .objectFit(ImageFit.Cover)
        .interpolation(ImageInterpolation.Low)
        .width('100%')
        .height('100%')
        .draggable(false)
        .borderRadius($r('app.float.border_radius_20'))
        .id(`${this.tag}_Image_01`)
    }
    .margin(OUC_CARD_IMG_MARGIN)
    .height(this.pageModel?.oucPreloadImgSize?.height as Length)
    .width(this.pageModel?.oucPreloadImgSize?.width as Length)
    .transition(TransitionEffect.asymmetric(TransitionEffect.IDENTITY, TransitionEffect.OPACITY))
  }

  @Builder
  private oucUIExtensionBuild(): void {
    UIExtensionComponent({
      bundleName: BUNDLE_NAME,
      abilityName: ABILITY_NAME,
      parameters: {
        'ability.want.params.uiExtensionType': 'sys/commonUI',
        'isSplit': this.isSplit,
        'foldCardLength': this.foldCardLength,
        'targetSubRouter': this.uriTargetSubRouter,
        'startReason': this.startReason,
        'reconnect': this.observedData.reconnect,
        'params': this.pushParams?.config,
      }
    }, {
      dpiFollowStrategy: DpiFollowStrategy.FOLLOW_HOST_DPI
    })
      .defaultFocus(true)
      .onRemoteReady((proxy) => {
        LogUtil.info(`${this.tag} UIExtensionComponent onRemoteReady`);
        this.uiExtensionProxy = proxy;
        this.uiExtensionProxy.on('asyncReceiverRegister', (proxy1) => {
          this.setDefaultAvoidWidth();
          this.sendAvoidWidth();
          /* instrument ignore if*/
          if (this.foldCardLength !== this.aboutDeviceFoldCardLength && this.aboutDeviceFoldCardLength > 0) {
            LogUtil.info(`${this.tag} send foldCardLength onRemoteReady`);
            this.onAboutDeviceFoldCardLengthChange();
          }
        });
      })
      .onError((error) => {
        LogUtil.info(`${this.tag} UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
        this.uiExtensionProxy = undefined;
        this.errorInfo = error;
        /* instrument ignore if*/
        if (this.isAboutDevicePageOnPageShow && this.errorTimes === 0) {
          this.errorTimes = 1;
          this.pageRestore();
        }
      })
      .onTerminated(() => {
        LogUtil.info(`${this.tag} UIExtensionComponent onTerminated`);
        this.pageBack();
      })
      .onReceive((data) => {
        LogUtil.info(`${this.tag} UIExtensionComponent onReceive`);
        this.processReceiveData(data);
      })
      .id('com.ohos.settings.about.updateapp')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .width(this.pageModel?.size?.width ?? '100%')
      .height(this.pageModel?.size?.height ?? '100%')
      .visibility(Visibility.Visible)
      .accessibilityUseSamePage(this.accessibilitySamePageMode)
  }

  private processReceiveData(data: object): void {
    let animateType = (data?.['value']) as AnimateType;
    let extraInfo = (data?.['extraInfo']) as object;
    switch (data?.['action']) {
      case AboutDeviceCardAction.EXPAND:
        this.doExpand(animateType, extraInfo);
        break;
      case AboutDeviceCardAction.FOLD:
        this.doFold(animateType, extraInfo);
        break;
      case AboutDeviceCardAction.POP:
        this.pageBack();
        break;
      case AboutDeviceCardAction.SettingSearchBack:
        this.settingSearchBack();
        break;
      case AboutDeviceCardAction.PRELOAD_IMG_HIDE:
        this.hidePreloadImg();
        break;
      default:
        break;
    }
  }

  private doExpand(animateType: AnimateType, extraInfo?: object): void {
    this.accessibilitySamePageMode = AccessibilitySamePageMode.SEMI_SILENT;
    this.publishData({
      aboutDeviceCardAction: AboutDeviceCardAction.EXPAND,
      animateType: animateType,
      extraInfo: extraInfo
    });
  }

  private doFold(animateType: AnimateType, extraInfo?: object): void {
    this.accessibilitySamePageMode = AccessibilitySamePageMode.FULL_SILENT;
    this.publishData({
      aboutDeviceCardAction: AboutDeviceCardAction.FOLD,
      animateType: animateType,
      extraInfo: extraInfo
    });
  }

  private pageBack(): void {
    this.publishData({
      aboutDeviceCardAction: AboutDeviceCardAction.POP,
    });
  }

  // instrument ignore next
  private settingSearchBack(): void {
    if (AppStorage.get<NavigationMode>('navigationMode') !== NavigationMode.Split) {
      this.pageBack();
      return;
    }
    if (!DeviceUtil.isDevicePc()) {
      emitter.emit({
        eventId: EVENT_ID_SETTING_SEARCH_BACK,
        priority: emitter.EventPriority.IMMEDIATE,
      });
      return;
    }
    router.back();
  }

  private hidePreloadImg(): void {
    LogUtil.info(`${this.tag} this.navigationMode:${this.navigationMode}`);
    this.isCardReady = true;
    this.uiExtensionProxy?.send({ 'eventType' : 'eventSplitChange',
      'value': this.navigationMode === NavigationMode.Split });
    /* instrument ignore if*/
    if (this.targetSubRouterToJump && this.uiExtensionProxy) {
      LogUtil.error(`${this.tag} this.targetSubRouterToJump: ${this.targetSubRouterToJump}`);
      this.sendUrlRouterEventToOuc(this.targetSubRouterToJump, this.targetSubRouterParamsToJump);
      this.targetSubRouterToJump = undefined;
      this.targetSubRouterParamsToJump = undefined;
    }
    animateTo({ duration: PRELOAD_IMG_HIDE_DURATION }, () => {
      this.publishData({
        aboutDeviceCardAction: AboutDeviceCardAction.PRELOAD_IMG_HIDE,
      });
    });
  }

  private sendUrlRouterEventToOuc(jumpUrl: string, params?: Record<string, Object>): void {
    this.uiExtensionProxy?.send({ 'eventType' : 'eventUrlRouter', 'value': jumpUrl, 'params': params });
  }

  private onNavigationModeChange(): void {
    this.uiExtensionProxy?.send({ 'eventType' : 'eventSplitChange',
      'value': this.navigationMode === NavigationMode.Split });
  }

  private onAboutDeviceFoldCardLengthChange(): void {
    this.uiExtensionProxy?.send({ 'eventType' : 'eventCardSizeChange', 'value': this.aboutDeviceFoldCardLength });
  }

  private onTargetSubRouterChange(): void {
    LogUtil.info(`${this.tag} onTargetSubRouterChange in ${this.targetSubRouter}`);
    if (!OucAboutDeviceViewModel.checkTargetSubRouter(this.targetSubRouter)) {
      return;
    }
    let targetSubRouterParams = AppStorage.get<Want>('wantParams')?.parameters?.pushParams as Record<string, Object>;
    /* instrument ignore if*/
    if (!this.uiExtensionProxy || !this.isCardReady) {
      LogUtil.error(`${this.tag} uiExtensionProxyEmpty or card not ready`);
      this.targetSubRouterToJump = this.targetSubRouter;
      this.targetSubRouterParamsToJump = targetSubRouterParams;
      this.consumeTargetSubRouter();
      return;
    }
    this.sendUrlRouterEventToOuc(this.targetSubRouter, targetSubRouterParams);
    LogUtil.info(`${this.tag} onTargetSubRouterChange send ${this.targetSubRouter}`);
    this.consumeTargetSubRouter();
  }

  private consumeTargetSubRouter(): string {
    let temp = this.targetSubRouter;
    LogUtil.info(`${this.tag} consumeTargetSubRouter ${temp}`)
    AppStorage.setOrCreate<string>('com_hmos_ouc_software_update_settings_target_sub_router', '');
    return temp;
  }

  private publishData(data: AboutDeviceOucPublishData): void {
    this.controller?.publishDataChange('about_device_ouc_card', data);
  }

  // instrument ignore next
  private sendAvoidWidth(): void {
    if (this.uiExtensionProxy && DeviceUtil.isDevicePc()) {
      this.uiExtensionProxy.send({'eventType' : 'eventTitleBarMarginChange',
        'value': {end : LengthMetrics.vp(this.defaultAvoidWidth)}});
      LogUtil.info(`${this.tag} send width : ${this.defaultAvoidWidth}`);
    }
  }

  onNavDesDynamicPaddingChange(): void {
    this.setDefaultAvoidWidth();
    this.sendAvoidWidth();
  }

  private setDefaultAvoidWidth() {
    this.titleButtonRectWidth = AppStorage.get<number>('titleButtonRectWidth') as number;
    let avoidWidth: number = CommonUtils.calculateAvoidWidth(this.titleButtonRectWidth, this.navDesDynamicPadding);
    if (avoidWidth !== INVALID_AVOID_WIDTH) {
      this.defaultAvoidWidth = avoidWidth;
    }
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    this.uriTargetSubRouter = OucAboutDeviceViewModel.getTargetSubRouterAboutToAppear(this.pushParams);
    // 兜底
    this.publishData({ aboutDeviceCardAction: AboutDeviceCardAction.INIT_AGAIN,
      extraInfo: { 'uriTargetSubRouter': this.uriTargetSubRouter } as Record<string, string> });
    this.setDefaultAvoidWidth();
    this.startReason = this.pushParams?.startReason ?? PageStartModeManager.getInstance().getStartReason();
    LogUtil.info(`${this.tag} aboutToAppear: subUri: ${this.pushParams?.subUri},` +
      ` config: ${this.pushParams?.config}, startReason: ${this.startReason}, targetSubRouter:${this.targetSubRouter}`);
    this.consumeTargetSubRouter();
    this.initPkgChangedSubscriber();
    EventBus.getInstance().on('EVENT_ID_ON_PAGE_FOREGROUND', this.foregroundCb);
    EventBus.getInstance().on(EVENT_ID_ABOUT_DEVICE_ON_PAGE_SHOW, this.onPageShowCallback);
    EventBus.getInstance().on(EVENT_ID_ABOUT_DEVICE_ON_PAGE_HIDE, this.onPageHideCallback);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    this.unsubscribePkgChangedSubscriber();
    EventBus.getInstance().detach('EVENT_ID_ON_PAGE_FOREGROUND', this.foregroundCb);
    EventBus.getInstance().detach(EVENT_ID_ABOUT_DEVICE_ON_PAGE_SHOW, this.onPageShowCallback);
    EventBus.getInstance().detach(EVENT_ID_ABOUT_DEVICE_ON_PAGE_HIDE, this.onPageHideCallback);
  }

  pageRestore(): void {
    LogUtil.info(`${this.tag} pageRestore, errorCode: ${this.errorInfo?.code}`);
    /* instrument ignore if*/
    if (this.errorInfo) {
      let tempUri = this.uriTargetSubRouter;
      // 当前在关于本机页面，回到关于本机页面，当前在内页，回到初始页面，设置无法知道用户具体点击到哪一个内页去了。
      this.uriTargetSubRouter = AppStorage.get<boolean>('isInAboutDevicePage') ? '' : tempUri;
      this.publishData({ aboutDeviceCardAction: AboutDeviceCardAction.INIT_AGAIN,
        extraInfo: { 'uriTargetSubRouter': this.uriTargetSubRouter } as Record<string, string> });
      LogUtil.info(`${this.tag} uriTargetSubRouter: ${this.uriTargetSubRouter}`);
      this.isSplit = this.navigationMode === NavigationMode.Split;
      this.foldCardLength = this.aboutDeviceFoldCardLength;
      this.viewModel.refreshingNoNeedDialog(this.errorInfo, BUNDLE_NAME, ABILITY_NAME);
      this.errorInfo = null;
      LogUtil.info(`${this.tag} pageRestore success`);
    }
  }

  private initPkgChangedSubscriber(): void {
    LogUtil.info(`${this.tag}, initSubscriber`);
    try {
      commonEventManager.createSubscriber(this.subscribeInfo,
        (err: BusinessError, data: commonEventManager.CommonEventSubscriber) => {
          if (err) {
            LogUtil.error(`${this.tag}, create subscriber failed ${err.code} : ${err.message}`);
            return;
          }
          this.subscriber = data;
          if (!this.subscriber) {
            LogUtil.error(`${this.tag}, 'invalid subscriber.`);
            return;
          }
          this.handleSubscribe();
        })
    } catch (e) {
      LogUtil.error(`${this.tag}, 'initSubscriber failed.`);
    }
  }

  private handleSubscribe(): void {
    try {
      commonEventManager.subscribe(this.subscriber,
        async (err: BusinessError, eventData: commonEventManager.CommonEventData) => {
          if (err) {
            LogUtil.error(`${this.tag}, subscribe failed: ${eventData?.event}. Code:${err.code}, message:${err.message}`);
            return;
          }
          LogUtil.info(`${this.tag}, received ${eventData?.event}`);
          if (eventData.bundleName === BUNDLE_NAME) {
            LogUtil.info(`${this.tag}, updateapp is changed`);
            this.pageRestore();
          }
        });
    } catch (e) {
      LogUtil.error(`${this.tag}, subscribe failed: ${e?.code}, ${e?.message}`);
    }
  }

  private unsubscribePkgChangedSubscriber(): void {
    if (!this.subscriber) {
      LogUtil.error(`${this.tag}, subscriber is null`);
      return;
    }
    try {
      commonEventManager.unsubscribe(this.subscriber, (err: BusinessError) => {
        if (err) {
          LogUtil.error(`${this.tag} unsubscribe failed ${err?.code}, ${err?.message}`);
          return;
        }
        LogUtil.info(`${this.tag} unsubscribe success`);
      })
    } catch (err) {
      LogUtil.error(`${this.tag} unsubscribe catch error ${err?.code}, ${err?.message}`);
    }
  }
}