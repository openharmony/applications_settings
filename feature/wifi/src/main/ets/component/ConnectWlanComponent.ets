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
import common from '@ohos.app.ability.common';
import wifiManager from '@ohos.wifiManager';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { EventBus, EventCb } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import {
  notifyCompStateChange,
  SettingBaseState,
  SettingCompState,
  SettingContentState,
  SettingStateType,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { FOCUS_BOX_PADDING_METRICS } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';
import {
  CONNECT_RESULT_EVENT,
  OTHER_WLAN_CONNECT_EVENT,
  OTHER_WLAN_SHEET_SHOW_EVENT,
  WLAN_CONFIG_INPUT_CHANGE_EVENT,
  WLAN_PSW_ENTER_EVENT,
  WifiSecurityType,
  KEYBOARD_VISIBLE_EVENT
} from '../model/WifiModel';
import { WlanItemModel } from '../model/WlanItemModel';
import { WifiUtils } from '../WifiUtils';
import { AddOtherWlanConfigManager } from '../AddOtherWlanConfigManager';
import { WifiPasswordConfigManager } from '../WifiPasswordConfigManager';
import { AdvSecurityModeManager, ConnectScene } from '../AdvSecurityModeManager';
import { WifiMenuManager } from '../WifiMenuManager';

const TAG: string = 'ConnectWlanComponent: ';

const EDIT_SHEET_ID: string = 'Setting.Wlan.EditSheetConfig.EditSheet';

const WLAN_PASSWORD_CONFIG: string = 'OpenNetWorkSetting.wifi_password_config';

// 添加其他WLAN 输入框列表
const CONNECT_WLAN_INPUT_ITEM: string[] = [
  'wifi_config_ip_group.wifi_setup_proxy_entry',
  'wifi_config_ip_group.wifi_setup_ip_entry',
  'wifi_privacy_settings_group.ap_privacy_type',
  'key_security_group.key_security_selector',
  'wifi_wapi_cert_as_certificate_section.wifi_wapi_cert_as_certificate',
  'wifi_wapi_cert_user_certificate_section.wifi_wapi_cert_user_certificate',
  'wifi_wapi_psk_password_type_section.wifi_wapi_psk_password_type',
  'wifi_eap_method_section.wifi_eap_method',
  'wifi_eap_sim_select_section.wifi_eap_sim_select',
  'wifi_eap_ca_certificate_section.CaCertificateFooter',
  'wifi_eap_input_menu_group.wifi_eap_domain',
  'wifi_eap_input_menu_group.wifi_eap_identity',
  'wifi_eap_input_menu_group.wifi_eap_anonymous',
  'wifi_eap_select_phase2_section.wifi_eap_select_phase2',
  'wifi_eap_ca_certificate_section.wifi_eap_ca_certificate',
  'key_input_wifi_ssid.key_input_wifi_ssid_item'
];

/**
 * WiFi输入密码界面标志位
 */
export const WIFI_PASSWORD_CONFIG = 0;

/**
 * 添加网络界面标志位
 */
export const ADD_OTHER_WLAN_CONFIG = 1;

@Component
export struct ConnectWlanComponent {
  item?: object;
  configFlag: number = WIFI_PASSWORD_CONFIG;
  private isKeyboardVisible: boolean = false;
  private isAddOtherWlan: boolean = false;
  @State isValid: boolean = false;
  @State isConnecting: boolean = false;
  @State bottomResource: ResourceColor = $r('app.float.padding_44');

  // 监听config 输入变化，改成按钮可用性
  private onWlanConfigChangedCallBack: EventCb = () => {
    let config: wifiManager.WifiDeviceConfig | undefined = WifiPasswordConfigManager.getInstance().getConfig();
    let model: WlanItemModel | undefined = WifiPasswordConfigManager.getInstance().model;
    LogUtil.info(`${TAG} onWlanConfigChangedCallBack`);
    if (this.configFlag === WIFI_PASSWORD_CONFIG) {
      config = WifiPasswordConfigManager.getInstance().getConfig();
    } else if (this.configFlag === ADD_OTHER_WLAN_CONFIG) {
      config = AddOtherWlanConfigManager.getInstance().getConfig();
    } else {
      LogUtil.warn(`${TAG} config flag illegal`);
    }
    // 加密网络密码prekey输入
    if (!config) {
      config = AddOtherWlanConfigManager.getInstance().getConfig();
    }
    if (!config) {
      LogUtil.error(`${TAG} onWlanConfigChangedCallBack occurs error.`);
      return;
    }
    let isHybridSecurity: boolean = this.isAddOtherWlan && config?.securityType === WifiSecurityType.WIFI_SEC_TYPE_PSK;
    this.isValid =
      WifiUtils.validWifiConfig(config, model?.capabilities, isHybridSecurity) && config.ssid.length > 0;
  };

  // 监听done事件，发起连接，如PC上输入密码后按回车
  private onEnterClick: EventCb = () => {
    LogUtil.info(`${TAG} onEnter clicked, is connect button valid: ${this.isValid}`);
    if (this.isValid) {
      this.dealClick();
    }
  };

  private onConnectChangedCallBack: EventCb = (isConnected: boolean) => {
    LogUtil.info(`${TAG} onConnectChangedCallBack, isConnected: ${isConnected}`);
    if (!isConnected) {
      this.isConnecting = false;
      if (this.isAddOtherWlan) {
        this.notifyAddOtherWlanItemStatusChanged(true);
        return;
      }
      this.notifyWlanPasswordInputStatusChanged(true);
      return;
    }
    if (WifiMenuManager.isExternalNetworkStage()) {
      EventBus.getInstance().emit('NetWorkSettingsConnectSuccess');
      return;
    }
    notifyCompStateChange('Setting.Wlan.AddOtherWlan.add_other_wifi_entry',
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SHEET,
        { state: false } as SettingCompState]]));
    notifyCompStateChange('Setting.Wlan',
      new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_PAGE_SCROLL_TO_TOP,
        { content: '' } as SettingContentState]]));
  };

  private notifyAddOtherWlanItemStatusChanged(status: boolean): void {
    LogUtil.info(`${TAG} notifyAddOtherWlanItemStatusChanged: ${status}`);
    EventBus.getInstance().emit('ADD_OTHER_WLAN_STATE_CHANGE', status);
    for (let i = 0; i < CONNECT_WLAN_INPUT_ITEM.length; i++) {
      notifyCompStateChange(`${PageRouter.getRouterName()}.add_other_wlan_config.${CONNECT_WLAN_INPUT_ITEM[i]}`,
        new Map<SettingStateType, SettingCompState>([[SettingStateType.STATE_TYPE_ITEM_ENABLED, {
          state: status,
        } as SettingCompState]]));
    }
  }

  private notifyWlanPasswordInputStatusChanged(status: boolean): void {
    LogUtil.info(`${TAG} notifyWlanPasswordInputStatusChanged: ${status}`);
    EventBus.getInstance().emit('ADD_OTHER_WLAN_STATE_CHANGE', status);
    for (let i = 0; i < CONNECT_WLAN_INPUT_ITEM.length; i++) {
      notifyCompStateChange(WLAN_PASSWORD_CONFIG + '.' + CONNECT_WLAN_INPUT_ITEM[i],
        new Map<SettingStateType, SettingCompState>([[SettingStateType.STATE_TYPE_ITEM_ENABLED, {
          state: status,
        } as SettingCompState]]));
    }
  }

  build() {
    Column() {
      Button({ type: DeviceUtil.isDevicePc() ? ButtonType.Normal : ButtonType.Capsule }) {
        Row() {
          LoadingProgress()
            .width($r('app.float.width_24'))
            .height($r('app.float.height_24'))
            .visibility(this.isConnecting ? Visibility.Visible : Visibility.None)

          Text(this.isConnecting ? $r('app.string.wifi_status_connecting') :
            $r('app.string.wifi_button_tittle_connect'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.Body_L'))
            .fontColor(this.isConnecting ? $r('sys.color.font_tertiary') : $r('sys.color.font_emphasize'))
            .constraintSize({
              minHeight: $r('app.float.wh_value_21'),
            })
            .maxFontScale(FontScaleUtils.EXTRA_LARGE_FONT_1)
            .margin({
              top: '9.5vp',
              bottom: $r('sys.float.padding_level5'),
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .borderRadius(DeviceUtil.isDevicePc() ? 8 : undefined)
      .enabled(this.isValid)
      .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
      .onClick(() => {
        this.dealClick();
      })
      .constraintSize({
        minHeight: 40,
      })
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
    LogUtil.info(`${TAG} aboutToAppear.`);
    EventBus.getInstance().on(WLAN_CONFIG_INPUT_CHANGE_EVENT, this.onWlanConfigChangedCallBack);
    EventBus.getInstance().on(WLAN_PSW_ENTER_EVENT, this.onEnterClick);
    if (AddOtherWlanConfigManager.getInstance().getConfig()) {
      this.isAddOtherWlan = true;
    }
    if (this.isAddOtherWlan || WifiMenuManager.isExternalNetworkStage()) {
      EventBus.getInstance().on(CONNECT_RESULT_EVENT, this.onConnectChangedCallBack);
    }
    WindowManager.getInstance().onKeyboardHeightChange((data: number) => {
      this.isKeyboardVisible = data > 0;
      this.bottomResource = this.isKeyboardVisible ? $r('app.float.padding_24') : $r('app.float.padding_44');
      EventBus.getInstance().emit(KEYBOARD_VISIBLE_EVENT, this.isKeyboardVisible);
    });
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear.`);
    EventBus.getInstance().detach(WLAN_CONFIG_INPUT_CHANGE_EVENT, this.onWlanConfigChangedCallBack);
    EventBus.getInstance().detach(WLAN_PSW_ENTER_EVENT, this.onEnterClick);
    WindowManager.getInstance().offKeyboardHeightChange();
    if (this.isAddOtherWlan || WifiMenuManager.isExternalNetworkStage()) {
      EventBus.getInstance().detach(CONNECT_RESULT_EVENT, this.onConnectChangedCallBack);
    }
  }

  private dealClick(): void {
    LogUtil.info(`${TAG} dealClick`);
    // 正在连接中的按钮无法点击
    if (this.isConnecting) {
      LogUtil.info(`${TAG} is Connecting.`);
      return;
    }
    let config: wifiManager.WifiDeviceConfig | undefined = WifiPasswordConfigManager.getInstance().getConfig();
    // 加密WLAN点击连接后，半模态消失product/phone/src/main/ets/Setting/Wlan/view/ConnectWlanComponent.ets
    if (config) {
      if (AdvSecurityModeManager.getInstance().isNeedShowWifiUnsafeDialog(config.securityType,
        WifiPasswordConfigManager.getInstance().model?.capabilities ?? '', config.ssid)) {
        AdvSecurityModeManager.getInstance().setConnectData({
          connectScene: ConnectScene.WLAN_PAGE_OTHER_WLAN,
        });
        let uiContext: common.UIAbilityContext = AbilityContextManager.getContext() as common.UIAbilityContext;
        AdvSecurityModeManager.getInstance().showWifiUnsafeDialog(uiContext);
        return;
      }
      if (!WifiMenuManager.isExternalNetworkStage()) {
        notifyCompStateChange(EDIT_SHEET_ID,
          new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_ITEM_SHEET,
            { state: false } as SettingCompState]]));
        // 通知WLAN列表滑动到顶部，避免连接中效果被遮挡
        notifyCompStateChange('Setting.Wlan',
          new Map<SettingStateType, SettingBaseState>([[SettingStateType.STATE_TYPE_PAGE_SCROLL_TO_TOP,
            { content: '' } as SettingContentState]]));
      } else {
        this.isConnecting = true;
        this.notifyWlanPasswordInputStatusChanged(false);
      }
    } else {
      // 添加WLAN 点击连接后，仅刷新连接中状态
      this.isConnecting = true;
      this.notifyAddOtherWlanItemStatusChanged(false);
    }
    LogUtil.info(`${TAG} dealClick connect event.`);
    EventBus.getInstance().emit(OTHER_WLAN_SHEET_SHOW_EVENT, false);
    EventBus.getInstance().emit(OTHER_WLAN_CONNECT_EVENT);
  }
}