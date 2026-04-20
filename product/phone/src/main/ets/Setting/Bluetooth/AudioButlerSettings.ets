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

import connection from '@ohos.bluetooth.connection';
import Curves from '@ohos.curves';
import window from '@ohos.window';
import { ObservedData, UiExtensionViewModel } from '@ohos/settings.common/src/main/ets/viewmodel/UiExtensionViewModel';
import { ExitAbnormallyComponent } from '@ohos/settings.common/src/main/ets/viewmodel/ExitAbnormallyComponent';
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { BluetoothDevice } from '@ohos/settings.bluetooth/src/main/ets/model/BluetoothModel';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { AccessibilityLevelType } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AvoidAreaDirect, WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { BluetoothAdapter } from '@ohos/settings.bluetooth/src/main/ets/BluetoothAdapter';
import { Utils } from '@ohos/settings.bluetooth/src/main/ets/utils/Utils';
/* instrument ignore file */
const TAG: string = 'phoneAudioButlerSettings: ';
const BUNDLE_NAME: string = 'com.ohos.audioaccessorymanager';
const ABILITY_NAME: string = 'AudioDeviceDetailUIExtensionAbility';
const LOADING_PROGRESS_WIDTH: number = 40;

@Builder
export function AudioButlerSettingsLoader($$: Params): void {
  AudioButlerSettings({ params: $$ as Object as PushParam });
}

@Component
export struct AudioButlerSettings {
  uiExtensionProxy?: UIExtensionProxy;
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @State params: PushParam | null = null;
  @State statusBarHeight: number = 39;
  @State observedData: ObservedData = new ObservedData();
  private viewModel: UiExtensionViewModel = new UiExtensionViewModel(this.observedData);
  @Consume('pathInfos') pathInfos: NavPathStack;
  @StorageProp('com_hmos_ouc_accessory_settings_target_sub_router')
  @Watch('onAccessoryUrlChange') targetSubRouter: string = '';
  @State mac: string = '';
  accessoryUrl: string = '';
  deviceType: string = '';
  deviceName: string = '';
  @State isShowLoading: boolean = false;
  private COMPONENT_ANIMATE_CURVE: ICurve = Curves.interpolatingSpring(0, 0, 228, 26);
  externalInfo?: string;

  recoverController: CustomDialogController = new CustomDialogController({
    builder: ExitAbnormallyComponent(),
  });

  build() {
    NavDestination() {
      Stack() {
        UIExtensionComponent({
          bundleName: BUNDLE_NAME,
          abilityName: ABILITY_NAME,
          parameters: {
            mac: this.mac,
            'ability.want.params.uiExtensionType': 'sys/commonUI',
            'ability.want.params.IsNotifyOccupiedAreaChange': true,
            marginTop: this.statusBarHeight,
            'reconnect': this.observedData.reconnect,
            accessoryUrl: this.accessoryUrl,
            deviceType: this.deviceType,
            deviceName: this.deviceName,
            externalInfo: this.externalInfo,
          },
        })
          .defaultFocus(true)
          .width('100%')
          .height('100%')
          .onResult((data) => {
            // 提供方销毁，断开连接时的回调方法
            LogUtil.info(`${TAG} UIExtensionComponent onResult`)
          })
          .onError((error) => {
            LogUtil.info(`${TAG} UIExtensionComponent onError code: ${error?.code} message: ${error?.message}`);
            this.viewModel.refreshing(error, this.recoverController, BUNDLE_NAME, ABILITY_NAME);
          })
          .onTerminated(()=>{})
          .onRemoteReady((proxy) => {
            // 加载完成时的回调方法
            LogUtil.info(`${TAG} UIExtensionComponent onRemoteReady`)
            this.uiExtensionProxy = proxy;
          })
          .onReceive((data) => {
            // 接收到信息
            LogUtil.info(`${TAG} UIExtensionComponent onReceive`)
            if (data.value === 'back') {
              this.pathInfos.pop();
            }
            if (data['action'] === 'hideLoading') {
              LogUtil.info(`${TAG} hideLoading`);
              this.isShowLoading = false;
            }
          })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        this.Loading()
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.Top)
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      this.onPageShow();
    })
    .onHidden(() => {
      this.onPageHide();
    })
    .onBackPressed(() => {
      this.pathInfos.pop();
      return true;
    })
    .id('com.ohos.audioaccessorymanager')
  }

  @Builder
  Loading() {
    Column()
      .width('100%')
      .height('100%')
      .visibility(this.isShowLoading ? Visibility.Visible : Visibility.Hidden)
      .backgroundColor($r('sys.color.ohos_id_color_titlebar_sub_bg'))
      .animation({
        curve: this.COMPONENT_ANIMATE_CURVE,
      })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

    Row() {
      LoadingProgress()
        .width(LOADING_PROGRESS_WIDTH)
    }
    .height('100%')
    .visibility(this.isShowLoading ? Visibility.Visible : Visibility.Hidden)
    .accessibilityGroup(true)
    .accessibilityLevel(AccessibilityLevelType.NO)
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.viewModel.listening(this.recoverController);
    this.mac = (this.params?.config as BluetoothDevice)?.deviceId;

    let param = this.params?.config as Record<string, Object>;
    this.accessoryUrl = param?.accessoryUrl as string;
    if (this.accessoryUrl) {
      this.isShowLoading = true;
    }
    this.deviceType = param?.deviceType as string;
    this.deviceName = param?.deviceName as string;
    this.externalInfo = param?.externalInfo as string;
    this.consumeTargetSubRouter();

    this.statusBarHeight = px2vp(WindowManager.getAvoidAreaHeight(
      AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage, AvoidAreaDirect.TOP,
      window.AvoidAreaType.TYPE_SYSTEM));
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.pageRoot.aboutToDisappear();
    this.viewModel.destroyListening();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
    this.pageRoot.onPageShow();
    if (BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState)) {
      Utils.setBluetoothScanMode(connection.ScanMode.SCAN_MODE_CONNECTABLE_GENERAL_DISCOVERABLE);
    }
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.pageRoot.onPageHide();
  }

  onBackPress(): void {
    LogUtil.info(`${TAG} onPagePress`);
  }

  private onAccessoryUrlChange(): void {
    LogUtil.info(`${TAG} onTargetSubRouterChange in ${this.targetSubRouter}`);
    if (!this.targetSubRouter) {
      return;
    }
    if (!this.uiExtensionProxy) {
      LogUtil.error(`${TAG} uiExtensionProxyEmpty`);
      this.consumeTargetSubRouter();
      return;
    }
    let param = AppStorage.get<Want>('wantParams')?.parameters?.pushParams as Record<string, Object>;
    if (this.mac === param?.deviceId) {
      this.uiExtensionProxy.send({ 'action': 'toAccessoryUrl', 'data': param });
    } else {
      this.mac = param?.deviceId as string;
      this.accessoryUrl = param?.accessoryUrl as string;
      this.deviceType = param?.deviceType as string;
      this.deviceName = param?.deviceName as string;
    }
    this.consumeTargetSubRouter();
  }

  private consumeTargetSubRouter(): void {
    LogUtil.info(`${TAG} consumeTargetSubRouter ${this.targetSubRouter}`);
    AppStorage.setOrCreate<string>('com_hmos_ouc_accessory_settings_target_sub_router', '');
  }
}