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

import wifiManager from '@ohos.wifiManager';
import {
  ButtonMenu,
  CardMenuSection,
  CheckboxOptionMenu,
  UnderLineEditMenuEx,
  UnderLineNumEditMenuStyle,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { MenuGroup, SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { PendingIpConfig } from '@ohos/settings.wifi/src/main/ets/model/WifiModel';
import {
  WifiMenuManager,
  WIFI_IP_PREFIX_LENGTH,
} from '@ohos/settings.wifi/src/main/ets/WifiMenuManager';
import {
  WifiSetupIpButtonController,
} from '@ohos/settings.wifi/src/main/ets/controller/WifiSetupIpControllers';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { WifiTextInputBaseController } from '@ohos/settings.wifi/src/main/ets/controller/WifiTextInputBaseController';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import {
  WifiSetupCommonOptionController,
  WifiSetupIpInputGroupController
} from '../controller/WifiSetupIpControllers';

/* instrument ignore file */
export let KEY_IP_OPTION_DHCP = 'key_ip_option_dhcp';

export let KEY_IP_OPTION_STATIC = 'key_ip_option_static';

/**
 * 添加其他网络-设置IP界面-数据模型
 *
 * @since 2023-12-11
 */
export class WifiSetupIpModel extends SettingHeaderPage {
  public pendingIpConfig: PendingIpConfig;

  constructor(pathInfos: NavPathStack, pendingIpConfig: PendingIpConfig) {
    super();
    this.pendingIpConfig = pendingIpConfig;
    this.pathInfos = pathInfos;
    this.showHeader = false;
    this.isNavigation = true;
    this.scrollable = false;
    this.addMenus(
      [
        this.buildOptionsMenu(0),
        this.buildInputsMenu(10),
      ]
    );
    this.setFooter(this.buildSaveButtonMenu());
  }

  private buildOptionsMenu(index: number): SettingsBaseMenu {
    return new CardMenuSection(
      {
        key: 'key_ip_option_group',
        index: index,
      },
      [
        new CheckboxOptionMenu(
          {
            key: KEY_IP_OPTION_DHCP,
            index: 10,
            title: $r('app.string.wifi_ip_settings_dhcp'),
            status: this.pendingIpConfig?.ipType === wifiManager.IpType.DHCP,
            controller: {
              createControllerConstructorInter: WifiSetupCommonOptionController.Creator,
            },
            extra: {
              listenMenuKeyArray: [KEY_IP_OPTION_STATIC]
            },
          }
        ),
        new CheckboxOptionMenu(
          {
            key: KEY_IP_OPTION_STATIC,
            index: 20,
            title: $r('app.string.wifi_ip_settings_static'),
            status: this.pendingIpConfig?.ipType === wifiManager.IpType.STATIC,
            controller: {
              createControllerConstructorInter: WifiSetupCommonOptionController.Creator,
            },
            extra: {
              listenMenuKeyArray: [KEY_IP_OPTION_DHCP]
            },
          }
        ),
      ]
    );
  }

  private buildInputsMenu(index: number): SettingsBaseMenu {
    let ip4Info: wifiManager.IpInfo | null = null;
    let ipv6Info: wifiManager.Ipv6Info | null = null;
    // 已连接详情页面，需要查询当前底座的数据
    if (this.pendingIpConfig.connState === wifiManager.ConnState.CONNECTED) {
      ip4Info = wifiManager.getIpInfo();
      ipv6Info = wifiManager.getIpv6Info();
    } else {
      // 其他网络，从缓存查询数据
      ip4Info = WifiUtils.getIpInfoByPendingConfig(this.pendingIpConfig);
      ipv6Info = WifiUtils.getIpv6InfoByPendingConfig(this.pendingIpConfig);
    }
    let inputMenus: SettingsBaseMenu[] = [];
    WifiMenuManager.getWifiStaticIpMenus(wifiManager.IpType.STATIC).forEach(item => {
      WifiMenuManager.setIpItemTitle(item, ip4Info, ipv6Info, this.pendingIpConfig);
      item.controller = {
        createControllerConstructorInter: WifiTextInputBaseController.CreateWifiTextInputBaseController,
      };
      if (item.key === WIFI_IP_PREFIX_LENGTH) {
        let customStyle: UnderLineNumEditMenuStyle = new UnderLineNumEditMenuStyle();
        customStyle.rootContainer.constraintSize.minHeight = $r('app.float.height_48');
        customStyle.textInputStyle.placeholderColor = $r('sys.color.font_tertiary');
        item.style = customStyle;
      }
      inputMenus.push(new UnderLineEditMenuEx(item))
    });
    return new CardMenuSection(
      {
        key: 'key_inputs_group',
        index: index,
        controller: {
          createControllerConstructorInter: WifiSetupIpInputGroupController.Creator,
        },
        status: this.pendingIpConfig?.ipType === wifiManager.IpType.STATIC,
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
            createControllerConstructorInter: WifiSetupIpButtonController.Creator,
          },
          extra: this.pendingIpConfig,
        }),
      ]
    );
  }
}