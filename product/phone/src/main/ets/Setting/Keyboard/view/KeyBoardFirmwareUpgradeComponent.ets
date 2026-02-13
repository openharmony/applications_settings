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

import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SystemParamUtil } from '@ohos/settings.common/src/main/ets/utils/SystemParamUtil';
import Want from '@ohos.app.ability.Want';
import { KeyboardSettingsManager } from '../KeyboardSettingsManager';
import ComponentConfig from '../utils/ComponentConfig';

/* instrument ignore file */
const TAG: string = 'KeyBoardFirmwareUpgrade : ';

@Component
export struct KeyBoardFirmwareUpgrade {
  uiExtensionProxy?: UIExtensionProxy;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;
  @State wantParameter: Record<string, Object> = {
    'ability.want.params.uiExtensionType': 'sys/commonUI',
  };
  @StorageProp('com_hmos_ouc_accessory_settings_target_sub_router')
  @Watch('onAccessoryUrlChange') targetSubRouter: string = '';
  private deviceType: number = 7;

  build() {
    NavDestination() {
      UIExtensionComponent({
        bundleName: 'com.ohos.ouc',
        abilityName: 'com.ohos.ouc.AccessoryAbility',
        parameters: this.wantParameter,
      })
        .defaultFocus(true)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .onRemoteReady((proxy) => {
          this.uiExtensionProxy = proxy;
        })
        .onRelease((code) => {
          // 用于处理被拉起的Ability销毁时的回调。
          // 被拉起的Ability扩展调用terminateSelfWithResult或者terminateSelf时会触发本回调，此时releaseCode为0，即正常销毁。
          // 被拉起的Ability扩展意外Crash或被kill时，触发本回调，此时releaseCode为1。
          LogUtil.info(`${TAG} UIExtensionComponent onRelease: ${code}`);
          // 对端Ability销毁时的code，0为正常销毁，1为异常销毁。
          // 页面销毁时，返回上一页
          this.pathInfos.pop();
        })
        .size({ width: '100%', height: '100%' })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      LogUtil.info(`${TAG} NavDestination onShown`);
    })
    .onHidden(() => {
      LogUtil.info(`${TAG} NavDestination onHidden`);
    })
  }

  aboutToAppear(): void {
    this.wantParameter.deviceType = this.deviceType;
    this.wantParameter.transportType = SystemParamUtil.getParam(ComponentConfig.spTranSport, 'err');
    if (this.params?.config !== undefined) {
      this.setWantParameter(this.params?.config as Record<string, Object>);
    } else {
      this.getFirmwareInfo()
    }
  }

  aboutToDisappear(): void {
  }

  getFirmwareInfo() {
    this.wantParameter.deviceName = KeyboardSettingsManager.getInstance().getKeyboardName();
    this.wantParameter.macId = KeyboardSettingsManager.getInstance().getMacId();
    LogUtil.info(`${TAG} getFirmwareInfo end`);
  }

  private setWantParameter(params: Record<string, Object> | null): boolean {
    LogUtil.info(`${TAG} setWantParameter`);
    this.wantParameter.macId = params?.macId as number;
    let accessoryUrl = params?.accessoryUrl as string;
    if (accessoryUrl) {
      this.wantParameter.accessoryUrl = accessoryUrl;
      this.wantParameter.fromNotify = params?.fromNotify as boolean;
      this.wantParameter.deviceName = params?.deviceName as string;
      this.wantParameter.externalInfo = params?.externalInfo as string;
    }
    this.consumeTargetSubRouter();
    return true;
  }

  private onAccessoryUrlChange(): void {
    if (!this.targetSubRouter) {
      return;
    }
    if (!this.uiExtensionProxy) {
      LogUtil.error(`${TAG} uiExtensionProxyEmpty`);
      this.consumeTargetSubRouter();
      return;
    }
    let param = AppStorage.get<Want>('wantParams')?.parameters?.pushParams as Record<string, Object>;
    LogUtil.info(`${TAG} onTargetSubRouterChange send toAccessoryUrl`);
    this.uiExtensionProxy.send({ 'action': 'toAccessoryUrl', 'data': param });
    this.consumeTargetSubRouter();
  }

  private consumeTargetSubRouter(): void {
    LogUtil.info(`${TAG} consumeTargetSubRouter ${this.targetSubRouter}`);
    AppStorage.setOrCreate<string>('com_hmos_ouc_accessory_settings_target_sub_router', '');
  }
}