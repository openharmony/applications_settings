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
import wifiManager from '@ohos.wifiManager';
import inputMethod from '@ohos.inputMethod';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { FOCUS_BOX_PADDING_METRICS } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { WifiUtils, IPV6_FAMILY_FLAG, IPV4_FAMILY_FLAG } from '../WifiUtils';
import { WLAN_IP_INPUT_CHANGE_EVENT, KEYBOARD_VISIBLE_EVENT } from '../model/WifiModel';
import { WifiPasswordConfigManager } from '../WifiPasswordConfigManager';
import { AddOtherWlanConfigManager } from '../AddOtherWlanConfigManager';
import { WifiSetupIpButtonController } from '../controller/new/WifiSetupIpButtonController';
import { WifiMenuManager } from '../WifiMenuManager';

const TAG: string = 'SaveIpInfoComponent: ';

@Component
export struct SaveIpInfoComponent {
  item?: SettingGroupModel;
  private inputMethodSetting = inputMethod.getSetting();
  private compControl?: WifiSetupIpButtonController;
  private wifiConfig?: wifiManager.WifiDeviceConfig;
  private isKeyboardVisible: boolean = false;
  @State isIpConfigValid: boolean = false;
  @State bottomResource: ResourceColor = $r('app.float.padding_44');
  private onIpInputChangeCallback = () => {
    LogUtil.info(`${TAG} onIpInputChangeCallback occurs.`);
    this.refreshIpConfigValid();
  }

  build() {
    Column() {
      Button({ type: DeviceUtil.isDevicePc() ? ButtonType.Normal : ButtonType.Capsule }) {
        Text($r('app.string.wifi_setup_config_save_button'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_emphasize'))
          .constraintSize({
            minHeight: $r('app.float.wh_value_21'),
          })
          .maxFontScale(FontScaleUtils.EXTRA_LARGE_FONT_1)
          .margin({
            top: '9.5vp',
            bottom: $r('sys.float.padding_level5'),
          })
      }
      .borderRadius(DeviceUtil.isDevicePc() ? 8 : undefined)
      .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
      .onClick(() => {
        this.compControl?.onSaveButtonClicked();
      })
      .enabled(this.isIpConfigValid)
      .width('100%')
      .backgroundColor($r('sys.color.comp_background_tertiary'))
    }
    .justifyContent(FlexAlign.End)
    .backgroundColor(DeviceUtil.isDevicePc() ? Color.Transparent : $r('app.color.component_ultra_thick_panel'))
    .padding({
      bottom: WifiMenuManager.isFixedMarginStage() ? $r('app.float.padding_24') : this.bottomResource,
      top: $r('sys.float.padding_level12'),
      left: $r('sys.float.padding_level8'),
      right: $r('sys.float.padding_level8'),
    })
  }

  aboutToAppear(): void {
    this.compControl = this.item?.compControl as WifiSetupIpButtonController;
    this.compControl.aboutToAppear();
    let config: wifiManager.WifiDeviceConfig | undefined = AddOtherWlanConfigManager.getInstance().getConfig();
    if (AddOtherWlanConfigManager.getInstance().getConfig()) {
      this.wifiConfig = config;
    } else {
      this.wifiConfig = WifiPasswordConfigManager.getInstance().getConfig();
    }
    this.isIpConfigValid =
      WifiUtils.isValidWifiIpsConfig(this.wifiConfig?.ipType, this.wifiConfig?.staticIp, this.wifiConfig?.staticIpv6);
    EventBus.getInstance().on(WLAN_IP_INPUT_CHANGE_EVENT, this.onIpInputChangeCallback);
    EventBus.getInstance().on(KEYBOARD_VISIBLE_EVENT, this.keyboardVisibleCallback);
  }

  private keyboardVisibleCallback = (data: boolean) => {
    this.isKeyboardVisible = data;
    this.bottomResource = this.isKeyboardVisible ? $r('app.float.padding_24') : $r('app.float.padding_44');
  };

  refreshIpConfigValid(): void {
    if (!this.wifiConfig) {
      return;
    }
    const isIpv6ConfigValid: boolean =
      WifiUtils.isValidWifiIpv6Config(this.wifiConfig.ipType, this.wifiConfig.staticIpv6);
    const isIpv4ConfigValid: boolean =
      WifiUtils.isValidWifiIpConfig(this.wifiConfig.ipType, this.wifiConfig.staticIp);
    this.wifiConfig.family = isIpv6ConfigValid ? IPV6_FAMILY_FLAG : IPV4_FAMILY_FLAG;
    this.isIpConfigValid = isIpv6ConfigValid || isIpv4ConfigValid;
  }

  aboutToDisappear(): void {
    if (!this.isIpConfigValid && this.wifiConfig) {
      this.wifiConfig!.staticIp!.dnsServers.pop();
      this.wifiConfig!.staticIpv6!.dnsServers.pop();
    }
    this.compControl?.aboutToDisappear();
    EventBus.getInstance().detach(WLAN_IP_INPUT_CHANGE_EVENT, this.onIpInputChangeCallback);
    EventBus.getInstance().detach(KEYBOARD_VISIBLE_EVENT, this.keyboardVisibleCallback);
  }
}