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

import connection from '@ohos.net.connection';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { GroupStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { Params } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import { WifiPage } from './model/WifiPage';
import { OobeWifiMenuPageComponent } from './OobeWifiMenuPageComponent';
import { CardContainerView } from '../../Setting/Wlan/view/CardContainerView';

/* instrument ignore file */
let storage = LocalStorage.getShared();

@Builder
export function OobeWifiExtensionSettingsLoader($$: Params): void {
  OobeWifiExtensionSettings();
}

/**
 * Ability结束后，传值给OOBE，该值与OOBE相约定
 */
enum AbilityTerminateResult {
  LastStep = 101,
  NextStep = 100,
}

const BUTTON_OFF_VALUE: number = 0.4;
const BUTTON_ON_VALUE: number = 1;
const TRANSACTION_TIME: number = 300;

const TAG: string = 'OobeWifiExtensionSettings : ';
const IS_DEVICE_PAD: boolean = DeviceUtil.isDevicePad();

const netCon: connection.NetConnection = connection.createNetConnection();

@Component
export struct OobeWifiExtensionSettings {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @StorageProp('wifi_state') @Watch('handledWifiChange') wifiFrequency: number = -1;
  @State isWifiConnected: boolean = false;
  // 当前网络是否可以上网 蜂窝网络/wifi热点
  @State isNetworkConnected: boolean = false;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State mWifiStatus: boolean = true;
  @StorageProp('oobeFootBtnWidth') footBtnWidth: number | Resource = $r('app.float.wh_value_188');
  isNextClick: boolean = false;

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
    })
    .transition(TransitionEffect.asymmetric(
      TransitionEffect.OPACITY.animation({ duration: TRANSACTION_TIME })
        .combine(TransitionEffect.move(TransitionEdge.END)),
      TransitionEffect.OPACITY.animation({ duration: TRANSACTION_TIME })
        .combine(TransitionEffect.move(TransitionEdge.START))))
  }

  @Builder
  pageContentBuilder(): void {
    Stack() {
      CardContainerView({
        bodyContent: () => this.contentBuilder(),
        mHeadName: $r('app.string.connect_the_internet_title'),
        onButtonClick: () => this.onBackBtnClick(),
        isBackArrowVisible: true,
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
    if (this.mWifiStatus) {
      this.WifiPage()
    } else {
      this.WifiPage()
    }
  }

  @Builder
  linearMaskBuilder(): void {
    Column() {
      Column() {
      }
      .width('100%')
      .height($r('app.float.wh_value_32'))
      .linearGradient({
        colors: [[$r('app.color.linear_mask_start_color'), 0.0], [$r('app.color.linear_mask_end_color'), 1]],
      })
      .position({ x: '0', y: $r('app.float.length_negative_32') })
    }
    .width(IS_DEVICE_PAD ? $r('app.float.wh_value_480') : '100%')
    .padding({ left: $r('app.float.wh_value_16'), right: $r('app.float.wh_value_16') })
  }

  @Builder
  buttonBuilder(): void {
    Column() {
      Column() {
        Button((this.isNetworkConnected && !this.isWifiConnected) ? $r('app.string.skip_process') :
        $r('app.string.continue_process'), {
          type: ButtonType.Capsule,
          stateEffect: this.isNetworkConnected,
        })
          .backgroundColor(this.isNetworkConnected ? $r('app.color.0A59F7') : $r('app.color.317aff'))
          .opacity(this.isNetworkConnected ? BUTTON_ON_VALUE : BUTTON_OFF_VALUE)
          .width('100%')
          .onClick(() => {
            if (this.isNetworkConnected) {
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
  WifiPage(): void {
    OobeWifiMenuPageComponent({ menuPage: this.pageRoot.menuPage })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    WifiUtils.enableWifi();
    // 初始化页面
    let wifiPage = new WifiPage(this.pathInfos, true);
    let pageStyle = wifiPage?.style as GroupStyle;
    if (pageStyle?.listStyle) {
      pageStyle.listStyle.borderRadius = 0;
    }
    this.pageRoot.aboutToAppear(wifiPage);
    AppStorage.setOrCreate('OOBEWifi', true);
    // 初始化监听
    WifiUtils.wifiConnectionChangeOn(TAG, this.onWifiConnectionChange);
    this.registerNetwork();
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
    this.pageRoot.onPageShow();
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.pageRoot.onPageHide();
  }

  private onNetCapabilitiesChange = (data: connection.NetCapabilityInfo): void => {
    let caps = data?.netCap?.networkCap;
    let bearerTypes = data?.netCap?.bearerTypes;
    LogUtil.info(`${TAG} netCapabilitiesChange, bearerTypes: ${bearerTypes?.join(',')}, caps: ${caps?.join(',')}`);
    // 是否可以上网
    this.isNetworkConnected = WifiUtils.isWifiNetworkValidated(caps);
    LogUtil.info(`${TAG} onNetCapabilitiesChange set isNetworkConnected:${this.isNetworkConnected}`);
  };
  private onWifiConnectionChange = (state: number): void => {
    this.isWifiConnected = WifiUtils.isWifiConnected();
    if (this.isWifiConnected) {
      this.mWifiStatus = !this.mWifiStatus;
    }
    LogUtil.info(`${TAG} onWifiConnectionChange state:${state}`);
  };

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

  handledWifiChange(): void {
    this.isWifiConnected = WifiUtils.isWifiConnected();
    LogUtil.info(`${TAG} wifi isConnected = ${this.isWifiConnected}`);
  }

  private onNextBtnClick(): void {
    LogUtil.info(`${TAG} onNextBtnClick`);
    this.isNextClick = true;
    this.termiteAbility(AbilityTerminateResult.NextStep);
  }

  private onBackBtnClick(): void {
    LogUtil.info(`${TAG} onBackBtnClick`);
    this.isNextClick = false;
    this.termiteAbility(AbilityTerminateResult.LastStep);
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
    const session = storage?.get<UIExtensionContentSession>('session');
    session?.terminateSelfWithResult(abilityResult, err => {
      LogUtil.info(`${TAG} termiteAbility err.code= ${err?.code}`);
    });
    storage?.clear();
  }
}