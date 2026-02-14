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

import Router from '@ohos.router';
import common from '@ohos.app.ability.common';
import dialogRequest from '@ohos.app.ability.dialogRequest';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import { ObservedData, UiExtensionViewModel } from '@ohos/settings.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { ExitAbnormallyComponent } from '@ohos/settings.common/src/main/ets/viewmodel/ExitAbnormallyComponent';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { EVENT_ID_SETTING_SEARCH_BACK } from '@ohos/settings.common/src/main/ets/event/types';
import { AppListLoader } from '@ohos/settings.application/src/main/ets/AppListLoader';
import { PageStartReason } from '@ohos/settings.common/src/main/ets/data/types';
import { PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { UIExtensionSessionUtils } from '@ohos/settings.common/src/main/ets/utils/UIExtensionSessionUtils';
import { IntelligentSceneWindowManager } from './manager/IntelligentSceneWindowManager';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { AppGroupType } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { EVENT_APP_LIST_LOAD_COMPLETE } from './event/types';

/* instrument ignore file */
const TAG: string = 'IntelligentSceneSettings : ';
const BUNDLE_NAME: string = 'com.ohos.intelligentscene';
const ABILITY_NAME: string = 'IntelligentSceneUIExtSettingAbility';
const SUB_PAGE_ENTRY_KEY: string = 'sub_page_entry_key';
const INTELLIGENT_SCENE_HOME_ENTRY: string = 'intelligent_scene_home_entry';
const MIN_PATH_LENGTH: number = 1;

@Component
export struct IntelligentSceneSettings {
  uiExtensionProxy?: UIExtensionProxy;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;
  @State observedData: ObservedData = new ObservedData();
  @State startReason: string | null = null;
  @StorageProp('wantParams') @Watch('onWantChange') wantParam: Want | undefined = undefined;
  @StorageProp('navigationMode') @Watch('onNavigationModeChange') navigationMode: NavigationMode = NavigationMode.Stack;
  @State firstNavigationMode: NavigationMode = NavigationMode.Stack;
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  private startTime: number = 0;
  recoverController: CustomDialogController = new CustomDialogController({
    builder: ExitAbnormallyComponent(),
  });
  private appListLoadEventCb = (data: Object) => {
    LogUtil.info(`${TAG} appListLoadEventCb ${data?.toString()}`);
    if (data === undefined || data.toString() === AppGroupType.CONTAINER) {
      const intent: Record<string, Object> = { 'action': EVENT_APP_LIST_LOAD_COMPLETE };
      this.uiExtensionProxy?.send(intent);
    }
  };

  build() {
    NavDestination() {
      UIExtensionComponent({
        bundleName: BUNDLE_NAME,
        abilityName: ABILITY_NAME,
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'action': 'jumpBySettings',
          'navigationMode': this.firstNavigationMode,
          'pushParams': (this.params?.config || this.params?.subUri) as string,
          'searchItemName': (this.params?.itemName ?? '') as string,
          'startReason': this.params?.startReason ?? PageStartModeManager.getInstance().getStartReason(),
          'reconnect': this.observedData.reconnect,
          'specifiedModeId': this.wantParam?.parameters?.specifiedModeId,
        }
      })
        .defaultFocus(true)
        .onRemoteReady((proxy) => {
          this.uiExtensionProxy = proxy;
          LogUtil.info(`${TAG} onRemoteReady start`);
          this.uiExtensionProxy.send({ 'navigationMode': this.navigationMode });
          LogUtil.info(`${TAG} onRemoteReady navigationMode: ${this.navigationMode}`);
          UIExtensionSessionUtils.sendTitleAnimationDuration(this.uiExtensionProxy, this.startTime);
          this.uiExtensionProxy?.on('asyncReceiverRegister', () => {
            UIExtensionSessionUtils.sendTitleAnimationDuration(this.uiExtensionProxy, this.startTime);
          });
        })
        .onError((error) => {
          LogUtil.info(`${TAG} UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
          this.viewModel.refreshing(error, this.recoverController, BUNDLE_NAME, ABILITY_NAME);
        })
        .onTerminated(() => {
        })
        .onReceive((data) => {
          LogUtil.info(`${TAG} UIExtensionComponent onReceive: ${data['action']}`);
          if (data && data[SUB_PAGE_ENTRY_KEY]) {
            LogUtil.info(`${TAG} sub_page_entry_key is ${data[SUB_PAGE_ENTRY_KEY]}`);
            IntelligentSceneWindowManager.setInMainPage(data[SUB_PAGE_ENTRY_KEY] === INTELLIGENT_SCENE_HOME_ENTRY);
          }

          if (data && data['action'] === 'pop') {
            LogUtil.info(`${TAG} pop`);
            if (this.pathInfos.size() === MIN_PATH_LENGTH && this.startReason !== PageStartReason.FROM_SEARCH &&
              this.navigationMode === NavigationMode.Split) {
              Router.back();
            } else {
              this.doPopAction();
            }
          }

          if (data && data['action'] === 'getNavigationMode') {
            this.uiExtensionProxy?.send({ 'navigationMode': this.navigationMode });
            LogUtil.info(`${TAG} send getNavigationMode ${this.navigationMode}`);
            return;
          }

          if (data && data['action'] === 'jump' && StringUtil.isNotEmpty(String(data['uri']))) {
            LogUtil.info(`${TAG} jump uri:${data['uri']}`);
            let param = new PushParam(data['pushParams']);
            param.startReason = PageStartReason.DEFAULT;
            PageRouter.push(String(data['uri']), param, false, undefined, true);
            return;
          }
          if (data && data['action'] === 'restore' && data['restoreApps']) {
            const restoreBundleNames: string[] = data['restoreApps'] as string[];
            this.openRestoreAppModal(restoreBundleNames);
          }
          if (data && data['action'] === 'loadAppList') {
            LogUtil.info(`${TAG} receive load app list`);
            AppListLoader.getInstance().loadAppList();
          }
        })
        .size({ width: '100%', height: '100%' })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      LogUtil.info(`${TAG} NavDestination onShown`);
      // delay start page transition animation
      if (this.navigationMode === NavigationMode.Stack) {
        this.viewModel.delayTransition();
      }
    })
    .onHidden(() => {
      LogUtil.info(`${TAG} NavDestination onHidden`);
    })
  }

  /**
   * 初始化和更新时解析want参数 执行相关业务
   */
  private onWantChange(): void {
    const want: Want | undefined = AppStorage.get<Want>('wantParams');
    if (want?.uri === NavEntryKey.INTELLIGENT_SCENE_SETTINGS_ENTRY && want?.parameters?.restoreApps) {
      const restoreBundleNames: string[] = want.parameters.restoreApps as string[];
      LogUtil.info(`${TAG} onWantChange. restoreBundleNames:${restoreBundleNames}`);
      // 使用后必须立即清空
      want.parameters.restoreApps = [];
      this.openRestoreAppModal(restoreBundleNames);
    }
    if (this.uiExtensionProxy && want?.parameters?.specifiedModeId) {
      LogUtil.info(`${TAG} onWantChange send. specifiedModeId:${want.parameters.specifiedModeId}`);
      this.uiExtensionProxy.send({ 'specifiedModeId': want.parameters.specifiedModeId });
    }
  }

  /**
   * 拉起恢复应用弹框
   */
  private openRestoreAppModal(restoreBundleNames: string[]): void {
    if (!restoreBundleNames?.length) {
      LogUtil.showError(TAG, `openRestoreAppModal. restoreBundleNames is empty`);
      return;
    }
    LogUtil.showInfo(TAG, `openRestoreAppModal. restoreBundleNames:${restoreBundleNames}`);
    const want: Want = {
      bundleName: 'com.ohos.restores',
      abilityName: 'RestoresDialogServiceAbility',
      parameters: {
        restoresBundleNameList: restoreBundleNames,
      },
    };
    try {
      (getContext() as common.UIAbilityContext).requestDialogService(want)
        .then((result: dialogRequest.RequestResult) => {
          LogUtil.info(`${TAG} requestDialogService succeed, resultCode:${result.result}`);
        })
    } catch (error) {
      LogUtil.error(`${TAG} requestDialogService catch error. code:${error?.code} message:${error?.message}`);
    }
  }

  private initStartReason() {
    this.startReason = this.params?.startReason as string;
    if (!this.startReason) {
      try {
        let params: PageParams = this.params as PageParams;
        if (params.param && params.param['startReason']) {
          this.startReason = params.param['startReason'] as string;
        }
        LogUtil.info(`${TAG} getStartReason params ${this.startReason}`);
      } catch (error) {
        LogUtil.error(`${TAG} get isFromSearch error: ${error?.code}, message: ${error?.message}`);
      }
    }
  }

  private doPopAction(): void {
    if (this.startReason === PageStartReason.FROM_SEARCH && this.navigationMode === NavigationMode.Split) {
      try {
        import('@ohos.events.emitter').then(emitter => {
          emitter.default.emit({
            eventId: EVENT_ID_SETTING_SEARCH_BACK,
            priority: emitter.default.EventPriority.IMMEDIATE
          });
        });
        this.startReason = PageStartReason.DEFAULT;
      } catch (error) {
        LogUtil.error(`emitter doPopAction failed, error:${error?.message}`);
        this.pathInfos.pop();
      }
    } else {
      this.pathInfos.pop();
    }
  }

  onNavigationModeChange(): void {
    if (!this.uiExtensionProxy) {
      LogUtil.info(`${TAG} uiExtensionProxy is null`);
      return;
    }
    LogUtil.info(`${TAG} onNavigationModeChange ${this.navigationMode}`);
    this.uiExtensionProxy.send({ 'navigationMode': this.navigationMode });
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.onWantChange();
    this.startTime = new Date().getTime();
    if (this.params?.startReason === PageStartReason.DEFAULT &&
    AppStorage.get<boolean>('isJumpIntelligenceIncomingCallPage')) {
      this.params.config = 'incoming_call_entry';
      AppStorage.SetOrCreate('isJumpIntelligenceIncomingCallPage', false);
    }
    this.viewModel.listening(this.recoverController);
    this.firstNavigationMode = this.navigationMode;
    this.initStartReason();
    this.registerListener();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.viewModel.destroyListening();
    this.unRegisterListener();
  }

  private registerListener(): void {
    EventBus.getInstance().on('EVENT_ID_APP_LIST_LOADER', this.appListLoadEventCb);
  }

  private unRegisterListener(): void {
    EventBus.getInstance().detach('EVENT_ID_APP_LIST_LOADER', this.appListLoadEventCb);
  }
}