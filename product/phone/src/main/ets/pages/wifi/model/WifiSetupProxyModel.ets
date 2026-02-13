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

import { MenuGroup, SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LanguageUtils } from '@ohos/settings.common/src/main/ets/utils/LanguageUtils';
import { ButtonMenu, CardMenuSection, UnderLineEditMenuStyle } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import {
  CheckboxOptionMenu,
  SwitchOutSummaryMenu,
  UnderLineEditMenuEx,
  UnderLineNumEditMenuStyle,
  PROXY_EXCLUSION_MAX_LENGTH
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import {
  WIFI_PROXY_PORT_LABEL,
  WIFI_PROXY_EXCLUSIONLIST_LABEL,
  WifiMenuManager,
  WifiTextInputBaseController,
  WifiVisibleController
} from '@ohos/settings.wifi';
import wifiManager from '@ohos.wifiManager';

import {
  PendingProxyConfig,
  WifiSetupProxyButtonController,
  WifiSetupProxyInputGroupController
} from '../controller/WifiSetupProxyControllers';
import { WifiSetupCommonOptionController } from '../controller/WifiSetupIpControllers';

/* instrument ignore file */
export let KEY_PROXY_OPTION_NONE = 'key_proxy_option_none';

export let KEY_PROXY_OPTION_MANUAL = 'key_proxy_option_manual';

export let KEY_PROXY_OPTION_AUTO = 'key_proxy_option_auto';

export let KEY_WIFI_SETUP_PROXY_PAC_INPUT = 'key_wifi_setup_proxy_pac_input';

/**
 * 添加其他网络-设置代理界面-数据模型
 *
 * @since 2023-12-06
 */
export class WifiSetupProxyModel extends SettingHeaderPage {
  public pendingProxyConfig: PendingProxyConfig;

  constructor(pathInfos: NavPathStack, pendingProxyConfig: PendingProxyConfig) {
    super();
    this.pendingProxyConfig = pendingProxyConfig;
    this.pathInfos = pathInfos;
    this.showHeader = false;
    this.isNavigation = true;
    this.scrollable = false;
    this.addMenus(
      [
        this.buildOptionsMenu(0),
        new SwitchOutSummaryMenu({
          key: 'key_proxy_summary',
          index: 20,
          title: $r('app.string.proxy_warning_limited_support'),
          controller: {
            createControllerConstructorInter: WifiVisibleController.CreateWifiVisibleController,
          },
          extra: {
            supportEapMethod: [wifiManager.ProxyMethod.METHOD_MANUAL],
            isCurrentVisible: this.pendingProxyConfig?.proxyMethod === wifiManager.ProxyMethod.METHOD_MANUAL,
            listenMenuKeyArray: [KEY_PROXY_OPTION_NONE, KEY_PROXY_OPTION_MANUAL, KEY_PROXY_OPTION_AUTO],
          },
        }),
        this.buildManualInputsMenu(30),
        this.buildAutoInputsMenu(30),
      ]
    );
    this.setFooter(this.buildSaveButtonMenu());
  }

  private buildOptionsMenu(index: number): SettingsBaseMenu {
    return new CardMenuSection(
      {
        key: 'key_proxy_option_group',
        index: index,
      },
      [
        new CheckboxOptionMenu(
          {
            key: KEY_PROXY_OPTION_NONE,
            index: 10,
            title: $r('app.string.wifi_proxy_settings_none'),
            status: this.pendingProxyConfig?.proxyMethod === wifiManager.ProxyMethod.METHOD_NONE,
            controller: {
              createControllerConstructorInter: WifiSetupCommonOptionController.Creator,
            },
            extra: {
              listenMenuKeyArray: [KEY_PROXY_OPTION_MANUAL, KEY_PROXY_OPTION_AUTO]
            },
          }
        ),
        new CheckboxOptionMenu(
          {
            key: KEY_PROXY_OPTION_MANUAL,
            index: 20,
            title: $r('app.string.wifi_proxy_settings_manual'),
            status: this.pendingProxyConfig?.proxyMethod === wifiManager.ProxyMethod.METHOD_MANUAL,
            controller: {
              createControllerConstructorInter: WifiSetupCommonOptionController.Creator,
            },
            extra: {
              listenMenuKeyArray: [KEY_PROXY_OPTION_NONE, KEY_PROXY_OPTION_AUTO]
            },
          }
        )
      ]
    );
  }

  private buildAutoInputsMenu(index: number): SettingsBaseMenu {
    return new CardMenuSection(
      {
        key: 'key_auto_inputs_group',
        index: index,
        controller: {
          createControllerConstructorInter: WifiSetupProxyInputGroupController.Creator,
        },
        status: this.pendingProxyConfig?.proxyMethod === wifiManager.ProxyMethod.METHOD_AUTO,
        extra: false,
      },
      [
        new UnderLineEditMenuEx(
          {
            key: KEY_WIFI_SETUP_PROXY_PAC_INPUT,
            index: 10,
            summary: $r('app.string.proxy_pac_web_address_label'),
            hint: $r('app.string.wifi_proxy_hostname_hint'),
            title: this.pendingProxyConfig?.pacWebAddress,
            controller: {
              createControllerConstructorInter: WifiTextInputBaseController.CreateWifiTextInputBaseController,
            },
            extra: {
              isCurrentVisible: true,
              isClearTitle: false,
            }
          }
        ),
      ]
    );
  }

  private buildManualInputsMenu(index: number): SettingsBaseMenu {
    let inputMenus: SettingsBaseMenu[] = [];
    WifiMenuManager.getWifiManualProxyMenus(this.pendingProxyConfig).forEach(item => {
      item.extra = {
        isCurrentVisible: true,
        isClearTitle: false,
      }
      item.controller = {
        createControllerConstructorInter: WifiTextInputBaseController.CreateWifiTextInputBaseController,
      };
      let customPadding: Padding = {
        left: $r('sys.float.padding_level0'),
        right: $r('sys.float.padding_level0'),
        bottom: $r('sys.float.padding_level0'),
        top: $r('sys.float.padding_level0'),
      };
      if (item.key == WIFI_PROXY_PORT_LABEL) {
        let customStyle: UnderLineNumEditMenuStyle = new UnderLineNumEditMenuStyle();
        customStyle.rootContainer.constraintSize.minHeight = $r('app.float.height_48');
        customStyle.textInputStyle.placeholderColor = $r('sys.color.font_tertiary');
        customStyle.textInputStyle.padding = customPadding;
        item.style = customStyle;
      } else {
        let customStyle: UnderLineEditMenuStyle = new UnderLineEditMenuStyle();
        customStyle.textInputStyle.textAlign = LanguageUtils.isLtrDirection() ? TextAlign.End : TextAlign.Start;
        customStyle.textInputStyle.direction = Direction.Ltr;
        customStyle.textInputStyle.padding = customPadding;
        if (item.key === WIFI_PROXY_EXCLUSIONLIST_LABEL) {
          customStyle.textInputStyle.maxLength = PROXY_EXCLUSION_MAX_LENGTH;
        }
        item.style = customStyle;
      }
      inputMenus.push(new UnderLineEditMenuEx(item))
    });
    return new CardMenuSection(
      {
        key: 'key_manual_inputs_group',
        index: index,
        controller: {
          createControllerConstructorInter: WifiSetupProxyInputGroupController.Creator,
        },
        status: this.pendingProxyConfig?.proxyMethod === wifiManager.ProxyMethod.METHOD_MANUAL,
        extra: true,
      },
      [
        ...inputMenus,
      ]
    );
  }

  private buildSaveButtonMenu(): MenuGroup {
    return new MenuGroup(
      {
        key: 'key_save_button_group',
        index: 0,
      },
      [
        new ButtonMenu({
          key: 'key_save_button',
          index: 0,
          buttonTittle1: $r('app.string.wifi_setup_config_save_button'),
          pathInfos: this.pathInfos,
          controller: {
            createControllerConstructorInter: WifiSetupProxyButtonController.Creator,
          },
          extra: this.pendingProxyConfig,
        }),
      ]
    );
  }
}