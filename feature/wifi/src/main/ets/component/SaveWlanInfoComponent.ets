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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { FOCUS_BOX_PADDING_METRICS } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { WifiUtils } from '../WifiUtils';
import { WLAN_PROXY_INPUT_CHANGE_EVENT, KEYBOARD_VISIBLE_EVENT } from '../model/WifiModel';
import { AddOtherWlanConfigManager } from '../AddOtherWlanConfigManager';
import { WifiPasswordConfigManager } from '../WifiPasswordConfigManager';
import { WifiSetupProxyButtonController } from '../controller/new/WifiSetupProxyButtonController';
import { WifiMenuManager } from '../WifiMenuManager';

const TAG: string = 'SaveWlanInfoComponent: ';

@Component
export struct SaveWlanInfoComponent {
  item?: SettingGroupModel;
  private wifiConfig?: wifiManager.WifiDeviceConfig;
  private compControl?: WifiSetupProxyButtonController;
  private isKeyboardVisible: boolean = false;
  @State isProxyConfigValid: boolean = false;
  @State marginBottom: number = 48;
  @State bottomResource: ResourceColor = $r('app.float.padding_44');
  private onProxyInputChangeCallback = () => {
    LogUtil.info(`${TAG} onProxyInputChangeCallback occurs.`);
    this.refreshProxyConfigValid();
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
      .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
      .onClick(() => {
        this.compControl?.onSaveButtonClicked();
      })
      .borderRadius(DeviceUtil.isDevicePc() ? 8 : undefined)
      .enabled(this.isProxyConfigValid)
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
    this.compControl = this.item?.compControl as WifiSetupProxyButtonController;
    this.compControl.aboutToAppear();
    let config: wifiManager.WifiDeviceConfig | undefined = AddOtherWlanConfigManager.getInstance().wifiConfig;
    if (config) {
      this.wifiConfig = config;
    } else {
      this.wifiConfig = WifiPasswordConfigManager.getInstance().getConfig();
    }
    if (this.wifiConfig?.proxyConfig) {
      this.isProxyConfigValid = WifiUtils.isValidProxyConfig(this.wifiConfig?.proxyConfig);
    } else {
      this.isProxyConfigValid = false;
    }
    EventBus.getInstance().on(KEYBOARD_VISIBLE_EVENT, this.keyboardVisibleCallback);
    EventBus.getInstance().on(WLAN_PROXY_INPUT_CHANGE_EVENT, this.onProxyInputChangeCallback);
  }

  private keyboardVisibleCallback = (data: boolean) => {
    this.isKeyboardVisible = data;
    this.bottomResource = this.isKeyboardVisible ? $r('app.float.padding_24') : $r('app.float.padding_44');
  };

  refreshProxyConfigValid(): void {
    if (this.wifiConfig?.proxyConfig === undefined) {
      this.isProxyConfigValid = false;
      return;
    }
    if (this.isProxyConfigValid !== WifiUtils.isValidProxyConfig(this.wifiConfig?.proxyConfig)) {
      this.isProxyConfigValid = !this.isProxyConfigValid;
    }
  }

  aboutToDisappear(): void {
    this.compControl?.aboutToDisappear();
    EventBus.getInstance().off(WLAN_PROXY_INPUT_CHANGE_EVENT);
    EventBus.getInstance().detach(KEYBOARD_VISIBLE_EVENT, this.keyboardVisibleCallback);
  }
}