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
import { TextInputMenuStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  EapPasswordInputStyle,
  EapPasswordTextDividerStyle,
  EapPasswordTextInputStyle,
} from '@ohos/settings.commonUikit/src/main/ets/InputStyle';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { InputComponent } from '@ohos/settings.commonUikit/src/main/ets/component/InputComponent';
import { WifiPasswordConfigManager } from '../WifiPasswordConfigManager';
import { AddOtherWlanConfigManager } from '../AddOtherWlanConfigManager';
import { WIFI_EAP_PASSWORD, WIFI_PASSWORD_INPUT } from '../WifiMenuManager';
import {
  ADD_OTHER_WLAN_PASSWORD_ID,
  EAP_METHOD_CHANGED_EVENT,
  SECURITY_CHANGE_EVENT,
  WLAN_CONFIG_INPUT_CHANGE_EVENT,
  WLAN_PSW_ENTER_EVENT,
} from '../model/WifiModel';

let eapPasswordTextInputStyle: EapPasswordTextInputStyle = new EapPasswordTextInputStyle();

let eapPasswordInputStyle: EapPasswordInputStyle = new EapPasswordInputStyle();

let dividerStyle: EapPasswordTextDividerStyle = new EapPasswordTextDividerStyle();

const TAG: string = 'WlanPasswordComponent:';

@Component
export struct WlanPasswordComponent {
  item?: SettingGroupModel;
  private hint: ResourceStr = $r('app.string.wifi_password_input_hint');
  private content: ResourceStr = '';
  private groupModel?: SettingGroupModel;
  private eapConfig?: wifiManager.WifiEapConfig;
  private isEapConfig: boolean = false;
  @State showPasswordComponent: boolean = true;
  @State dividerBackgroundColor: Resource = $r('sys.color.comp_background_tertiary');
  private onEapMethodChangeCallBack = () => {
    this.showPasswordComponent = this.eapConfig?.eapMethod === wifiManager.EapMethod.EAP_PEAP ||
      this.eapConfig?.eapMethod === wifiManager.EapMethod.EAP_PWD ||
      this.eapConfig?.eapMethod === wifiManager.EapMethod.EAP_TTLS;
  };
  private onSecurityChangeCallBack = () => {
    let config: wifiManager.WifiDeviceConfig | undefined = AddOtherWlanConfigManager.getInstance().wifiConfig;
    if (!config) {
      LogUtil.error(`${TAG} onSecurityChangeCallBack error.`);
      return;
    }
    if (this.groupModel?.id === 'add_other_wlan_wifi_eap_password') {
      this.showPasswordComponent = config.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_EAP;
      return;
    }
    this.showPasswordComponent = config.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WEP ||
      config.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_PSK ||
      config.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_SAE ||
      config.securityType === wifiManager.WifiSecurityType.WIFI_SEC_TYPE_WAPI_PSK;
  };

  build() {
    InputComponent({
      hint: this.hint,
      content: this.content,
      onChange: (input: string) => {
        this.inputChange(input);
      },
      onSubmitClick: (enterKeyType: EnterKeyType) => {
        if (enterKeyType === EnterKeyType.Done) {
          EventBus.getInstance().emit(WLAN_PSW_ENTER_EVENT);
        }
      },
      showComponent: this.showPasswordComponent,
      style: this.getStyle(),
      tabInd: this.item?.tabIndex
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear.`);
    this.groupModel = this.item as SettingGroupModel;
    // 添加其他wlan 密码输入
    if (this.groupModel?.id === ADD_OTHER_WLAN_PASSWORD_ID) {
      EventBus.getInstance().on(SECURITY_CHANGE_EVENT, this.onSecurityChangeCallBack);
      this.initStyle();
      this.showPasswordComponent = false;
      return;
    }
    // 添加其他wlan eap密码输入
    if (this.groupModel?.id === 'add_other_wlan_wifi_eap_password') {
      EventBus.getInstance().on('EAP_METHOD_CHANGED', this.onEapMethodChangeCallBack);
      EventBus.getInstance().on(SECURITY_CHANGE_EVENT, this.onSecurityChangeCallBack);
      this.isEapConfig = true;
      this.eapConfig = AddOtherWlanConfigManager.getInstance().getConfig()?.eapConfig;
      this.initStyle();
      this.showPasswordComponent = false;
      return;
    }
    // 加密网络eap密码输入
    if (this.groupModel?.id === WIFI_EAP_PASSWORD) {
      this.isEapConfig = true;
      this.eapConfig = WifiPasswordConfigManager.getInstance().getConfig()?.eapConfig;
      EventBus.getInstance().on(EAP_METHOD_CHANGED_EVENT, this.onEapMethodChangeCallBack);
      return;
    }
    // 普通网络密码输入框
    if (this.groupModel?.id === WIFI_PASSWORD_INPUT) {
      this.isEapConfig = false;
      this.initStyle();
      this.showPasswordComponent = true;
    }
  }

  initStyle(): void {
    eapPasswordInputStyle.padding = {
      left: $r('sys.float.padding_level5'),
    }
    eapPasswordInputStyle.margin = {
      top: DeviceUtil.isDevicePc() ? 0 : $r('app.float.margin_8'),
    }
    dividerStyle.size = {
      width: DeviceUtil.isDevicePc() ? '100%' : 'calc(100% - 24vp)',
      height: $r('app.float.length_1'),
    }
    eapPasswordTextInputStyle.textInputStyle = eapPasswordInputStyle;
    eapPasswordTextInputStyle.dividerStyle = dividerStyle;
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear.`);
    EventBus.getInstance().detach('EAP_METHOD_CHANGED', this.onEapMethodChangeCallBack);
    EventBus.getInstance().detach(SECURITY_CHANGE_EVENT, this.onSecurityChangeCallBack);
  }

  private getStyle(): TextInputMenuStyle {
    return eapPasswordTextInputStyle;
  }

  private inputChange(input: string): void {
    if (this.groupModel?.id === WIFI_PASSWORD_INPUT) {
      // 添加网络半模态菜单、密码输入
      WifiPasswordConfigManager.getInstance().setPreSharedKey(input);
      EventBus.getInstance().emit(WLAN_CONFIG_INPUT_CHANGE_EVENT);
      return;
    }
    // 添加其他wlan 密码输入
    if (this.groupModel?.id === ADD_OTHER_WLAN_PASSWORD_ID) {
      let config: wifiManager.WifiDeviceConfig | undefined = AddOtherWlanConfigManager.getInstance().wifiConfig;
      if (config) {
        config.preSharedKey = input;
        EventBus.getInstance().emit('WLAN_CONFIG_INPUT_CHANGE');
      }
      return;
    }
    // EAP密码输入事件变化
    if (this.isEapConfig && this.eapConfig !== undefined) {
      this.eapConfig.password = input;
      EventBus.getInstance().emit(WLAN_CONFIG_INPUT_CHANGE_EVENT);
      return;
    }
    // 添加网络半模态菜单、密码输入
    WifiPasswordConfigManager.getInstance().setPreSharedKey(input);
    EventBus.getInstance().emit(WLAN_CONFIG_INPUT_CHANGE_EVENT);
  }
}