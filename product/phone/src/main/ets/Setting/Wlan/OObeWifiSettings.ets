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

import common from '@ohos.app.ability.common';
import connection from '@ohos.net.connection';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import { PageLoader, PageParams } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { CardContainerView } from './view/CardContainerView';
/* instrument ignore file */
/**
 * Ability结束后，传值给OOBE，该值与OOBE相约定
 */
enum AbilityTerminateResult {
  LastStep = 101,
  NextStep = 100,
}

const BUTTON_OFF_VALUE: number = 0.4;
const BUTTON_ON_VALUE: number = 1;
// 与oobe侧约定，3表示升级场景
const UPGRADE_SCENE: number = 3;

const netCon: connection.NetConnection = connection.createNetConnection();

const TAG: string = 'OObeWifiSettings : ';

@Component
export struct OObeWifiSettings {
  @StorageProp('wifi_state') @Watch('handledWifiChange') wifiFrequency: number = -1;
  @State isWifiConnected: boolean = false;
  // 当前网络是否可以上网 蜂窝网络/wifi热点
  @State isNetworkConnected: boolean = false;
  @State isPortalUnauthenticated: boolean = false;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State mWifiStatus: boolean = true;
  @StorageProp('oobeFootBtnWidth') footBtnWidth: number | Resource = $r('app.float.wh_value_188');
  isNextClick: boolean = false;
  // 判断是否是升级场景
  isUpgradeScene: boolean = false;
  isFastCloneScene: boolean = false;

  private onNetCapabilitiesChange = (data: connection.NetCapabilityInfo): void => {
    let caps = data?.netCap?.networkCap;
    let bearerTypes = data?.netCap?.bearerTypes;
    LogUtil.info(`${TAG} netCapabilitiesChange, bearerTypes: ${bearerTypes?.join(',')}, caps: ${caps?.join(',')}`);
    // 是否可以上网
    this.isNetworkConnected = WifiUtils.isWifiNetworkValidated(caps);
    this.isPortalUnauthenticated = WifiUtils.isPortalWifiNetwork(caps);
    LogUtil.info(`${TAG} onNetCapabilitiesChange set isNetworkConnected:${this.isNetworkConnected}`);
  };

  private onWifiConnectionChange = (state: number): void => {
    this.isWifiConnected = WifiUtils.isWifiConnected();
    if (this.isWifiConnected) {
      this.mWifiStatus = !this.mWifiStatus;
    }
    LogUtil.info(`${TAG} onWifiConnectionChange state:${state}`);
  };


  @Builder pageBuilder(param: PageParams): void {
    if (param && param.pageCtx) {
      param.pageCtx.pageBuilder?.builder(param);
    }
  }

  @Builder
  pageContentBuilder(): void {
    Stack() {
      CardContainerView({
        bodyContent: () => this.contentBuilder(),
        mHeadName: $r('app.string.connect_the_internet_title'),
        onButtonClick: () => this.onBackBtnClick(),
        isBackArrowVisible: !this.isUpgradeScene,
      })
      this.buttonBuilder()
    }
    .width('100%')
    .height('100%')
    .align(Alignment.End)
    .alignContent(Alignment.Bottom)
  }

  @Builder
  contentBuilder(): void {
    this.pageBuilder({
      router: 'Setting',
      pageUrl: 'wifi_entry',
      pageCtx: PageLoader.getPageContext('wifi_entry').get()
    })
  }

  @Builder
  buttonBuilder(): void {
    Column() {
      Column() {
        Button((this.isNetworkConnected && !this.isWifiConnected) ? $r('app.string.skip_process') :
        $r('app.string.continue_process'), {
          type: ButtonType.Capsule,
          stateEffect: (this.isNetworkConnected || this.isPortalUnauthenticated)
        })
          .backgroundColor(this.isNetworkConnected || (!this.isFastCloneScene && this.isWifiConnected) ? $r('app.color.0A59F7') : $r('app.color.317aff'))
          .enabled(this.isNetworkConnected || (!this.isFastCloneScene && this.isWifiConnected))
          .width('100%')
          .onClick(() => {
            LogUtil.info(`${TAG} isFastCloneScene ${this.isFastCloneScene}, iswificonnected ${this.isWifiConnected}`);
            if (this.isNetworkConnected || (!this.isFastCloneScene && this.isWifiConnected)) {
              this.onNextBtnClick();
            }
          });
      }
      .width(this.footBtnWidth)
      .height($r('app.float.height_40'))
      .margin({ bottom: $r('app.float.height_48') })
    }
    .margin({ top: $r('app.float.margin_24'), bottom: $r('app.float.margin_16') })
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  myRouter(name: string, param?: Object) {
  }

  build() {
    NavDestination() {
      Column() {
        this.pageContentBuilder()
      }
    }
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    }).onBackPressed(()=>{
      LogUtil.info(`${TAG} OObePage does not support back action`)
      return true;
    })
    .onAppear(() => {
      AccessibilityUtils.requestFocusAccessibilityWithBundleName('img_headcomponent_back');
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    WifiUtils.enableWifi();
    AppStorage.setOrCreate('OOBEWifi', true);
    // 初始化监听
    WifiUtils.wifiConnectionChangeOn(TAG, this.onWifiConnectionChange);
    this.registerNetwork();
    this.isUpgradeScene = (AppStorage.get('sceneType') as number) === UPGRADE_SCENE;
    this.isFastCloneScene = AppStorage.get<boolean>('isFastCloneScene') as boolean
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    // 卸载监听
    WifiUtils.wifiConnectionChangeOff(TAG, this.onWifiConnectionChange);
    this.unRegisterNetwork();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.isWifiConnected = WifiUtils.isWifiConnected();
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  handledWifiChange(): void {
    this.isWifiConnected = WifiUtils.isWifiConnected();
    LogUtil.info(`${TAG} wifi isConnected = ${this.isWifiConnected}`);
  }

  private onBackBtnClick(): void {
    LogUtil.info(`${TAG} onBackBtnClick`);
    this.isNextClick = false;
    this.termiteAbility(AbilityTerminateResult.LastStep);
  }

  private onNextBtnClick(): void {
    LogUtil.info(`${TAG} onNextBtnClick`);
    this.isNextClick = true;
    this.termiteAbility(AbilityTerminateResult.NextStep);
  }

  private termiteAbility(flag: number): void {
    let want: Want = {
      bundleName: 'com.ohos.settings',
      abilityName: 'com.ohos.settings.OobeWifiSettingsExtensionAbility',
    };
    let abilityResult: common.AbilityResult = {
      want,
      resultCode: flag,
    };
    try {
      let storage: LocalStorage = LocalStorage.getShared();
      if (!storage) {
        LogUtil.info(`${TAG} storage is undefined.`);
        return;
      }
      let session: UIExtensionContentSession | undefined = storage?.get<UIExtensionContentSession>('session');
      if (!session) {
        LogUtil.info(`${TAG} session is undefined.`);
        return;
      }
      session.terminateSelfWithResult(abilityResult, err => {
        LogUtil.info(`${TAG} termiteAbility err.code= ${err?.code}`);
      });
      storage?.clear();
    } catch (error) {
      LogUtil.error(`${TAG} termiteAbility failed: ${error?.message}`);
    }
  }

  private registerNetwork(): void {
    try {
      // 调用register才能监听后面的on事件
      netCon.register((error) => {
        if (error) {
          LogUtil.error(`${TAG} netCon.register, errCode: ${error?.code}`);
        }
      });
      // 指定网络激活
      netCon.on('netAvailable', (data: connection.NetHandle) => {
        LogUtil.info(`${TAG} netAvailable set isNetworkConnected:true`);
        this.isNetworkConnected = true;
      });
      // 网络不可用事件
      netCon.on('netUnavailable', () => {
        LogUtil.info(`${TAG} netUnavailable set isNetworkConnected:false`);
        this.isNetworkConnected = false;
      })
      // 指定网络断开
      netCon.on('netLost', (data: connection.NetHandle) => {
        LogUtil.info(`${TAG} netLost set isNetworkConnected:false`);
        this.isNetworkConnected = false;
      });
      // 网络属性变化
      netCon.on('netCapabilitiesChange', this.onNetCapabilitiesChange);
    } catch (err) {
      LogUtil.error(`${TAG} registerNetwork catch err, errCode:${err?.code}`);
    }
  }

  private unRegisterNetwork(): void {
    try {
      netCon.unregister((error) => {
        if (error) {
          LogUtil.error(`${TAG} netCon.unregister, errCode: ${error?.code}`);
        }
      });
    } catch (err) {
      LogUtil.error(`${TAG} unRegisterNetwork catch err, errCode:${err?.code}`);
    }
  }
}
