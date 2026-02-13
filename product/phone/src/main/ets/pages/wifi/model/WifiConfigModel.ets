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
  SingleChoiceEntryMenu,
  PrivacySingleChoiceMenuStyle,
  SummaryTextStyle,
  TitleTextStyle,
  DefaultEntryMenuStyle,
  QRCodeMenu,
  CardMenuSection,
  NavigatorEntryMenu,
  StateMenu,
  NavigationEntry
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { AccessPoint, WifiSecurityType } from '@ohos/settings.wifi/src/main/ets/model/WifiModel';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import { WifiDeleteButtonController } from '../controller/WifiDeleteButtonController';
import { WIFIQRCodeController } from '../controller/WIFIQRCodeController';
import { WifiSetupProxyEntryController } from '../controller/WifiSetupProxyControllers';
import { WifiSetupIpEntryController } from '../controller/WifiSetupIpControllers';
import privacyController from '../controller/PrivacyController';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';

/* instrument ignore file */
class WifiDeleteTitleStyle extends TitleTextStyle {
  public fontColor = $r('sys.color.ohos_id_color_warning');
}

class WifiDeleteStyle extends DefaultEntryMenuStyle {
  public title = new WifiDeleteTitleStyle();
}

class DeviceNameMenuStyle extends DefaultEntryMenuStyle {
  public startFlexShrink: number = 0;
  public endFlexShrink: number = 1;
  public state: TextStyle = new StateTextStyle();
}

class StateTextStyle extends SummaryTextStyle {
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_sub_title3'),
  };
  public margin: Margin = {
    top: $r('sys.float.ohos_id_text_margin_horizontal'),
    bottom: $r('sys.float.ohos_id_text_margin_horizontal')
  };
  public textAlign: TextAlign = TextAlign.End;
}

class StateStyle extends DeviceNameMenuStyle {
  public maxLines: number = 5;
}

/**
 * Wifi 配置信息
 *
 * @since 2024-02-04
 */
export class WifiConfigModel extends SettingHeaderPage {
  public accessPoint: AccessPoint | undefined;

  private getMultiline(): SettingsBaseMenu[] {
    let result: SettingsBaseMenu[] = [];
    let wifiDeviceConfig = this.accessPoint?.getBestConfig() as wifiManager.WifiDeviceConfig;
    if (wifiDeviceConfig && wifiDeviceConfig.securityType !== WifiSecurityType.WIFI_SEC_TYPE_EAP) {
      result.push(
        new QRCodeMenu(
          {
            key: 'WIFI_SWITCH_QRCode',
            index: 0,
            title: $r('app.string.wifi_settings_QRCode'),
            summary: $r('app.string.Scan_to_connect_to_this_WLAN_network_Pay_attention_to_privacy_and_security'),
            controller: {
              createControllerConstructorInter: WIFIQRCodeController.CreateWIFIQRCodeController,
            },
            extra: this.accessPoint?.getBestConfig() as wifiManager.WifiDeviceConfig,
          },
        ),
      )
    }
    return result
  }

  private async fetchNewestWifiInfo(): Promise<void> {
    let newestWifiLinkedInfo = await WifiUtils.getLinkedInfo();
    let wifiConfigs = this.accessPoint?.configs;
    if (wifiConfigs && wifiConfigs.length > 0 && wifiConfigs[0] && newestWifiLinkedInfo &&
      wifiConfigs[0].netId === newestWifiLinkedInfo.networkId &&
      wifiConfigs[0].ssid === newestWifiLinkedInfo.ssid) {
      LogUtil.info('WifiConfigModel fetchNewestWifiInfo');
      this.accessPoint?.updateLastLinkedInfo(newestWifiLinkedInfo);
    }
  }

  constructor(accessPoint: AccessPoint, pathInfos?: NavPathStack) {
    super();
    this.accessPoint = accessPoint;
    this.showHeader = false;
    this.isNavigation = true;
    this.pathInfos = pathInfos;

    this.fetchNewestWifiInfo();

    // 已保存的WLAN详情
    if (!this.accessPoint?.getSpeed()) {
      this.updateMenus([
        new CardMenuSection(
          {
            key: 'wifi_config_group_zero',
            index: 0,
          },
          [
            new NavigatorEntryMenu({
              key: 'wifi_delete',
              index: 20,
              style: new WifiDeleteStyle(),
              title: $r('app.string.wifi_delete'),
              controller: {
                createControllerConstructorInter: WifiDeleteButtonController.CreateDeleteButtonController,
              },
              pathInfos: this.pathInfos,
              extra: this.accessPoint?.getBestConfig() as wifiManager.WifiDeviceConfig,
            }),
          ]
        ),
        new CardMenuSection(
          {
            key: 'wifi_config_group_one',
            index: 1,
          },
          [
            new StateMenu(
              {
                key: 'ap_signal_level',
                index: 20,
                title: $r('app.string.wifi_signal_level'),
                state: WifiUtils.getApSignalString(this.accessPoint?.bestLevel ?? 0),
              }
            ),
            new StateMenu(
              {
                key: 'ap_security_type',
                index: 50,
                title: $r('app.string.wifi_security_type'),
                state: WifiUtils.getApSecurityString(this.accessPoint?.securityType ?? 0),
              }
            )
          ]
        )
      ])
      return;
    }
    // 已连接WLAN详情
    this.addMenus(
      [
        ...this.getMultiline(),
        new CardMenuSection(
          {
            key: 'wifi_config_group_zero',
            index: 0,
          },
          [
            new NavigatorEntryMenu({
              key: 'wifi_delete',
              index: 20,
              style: new WifiDeleteStyle(),
              title: $r('app.string.wifi_delete'),
              controller: {
                createControllerConstructorInter: WifiDeleteButtonController.CreateDeleteButtonController,
              },
              pathInfos: this.pathInfos,
              extra: this.accessPoint?.getBestConfig() as wifiManager.WifiDeviceConfig,
            }),
          ]
        ),
        new CardMenuSection(
          {
            key: 'wifi_config_group_one',
            index: 1,
          },
          [
            new StateMenu(
              {
                key: 'ap_connect_state',
                index: 10,
                title: $r('app.string.wifi_connect_status_title'),
                state: $r('app.string.wifi_status_connected'),
              }
            ),
            new StateMenu(
              {
                key: 'ap_signal_level',
                index: 20,
                title: $r('app.string.wifi_signal_level'),
                state: WifiUtils.getApSignalString(this.accessPoint?.bestLevel ?? 0),
              }
            ),
            new StateMenu(
              {
                key: 'ap_connected_speed',
                index: 30,
                title: $r('app.string.wifi_connect_speed_title'),
                state: this.accessPoint?.getSpeed().toString() + ' Mbps',
              }
            ),
          ]
        ),
        new CardMenuSection(
          {
            key: 'wifi_config_group_second',
            index: 2,
          },
          [
            new StateMenu(
              {
                key: 'ap_connected_frequency',
                index: 40,
                title: $r('app.string.wifi_frequency'),
                state: WifiUtils.getFrequencyString(this.accessPoint?.getFrequency()),
              }
            ),
            new StateMenu(
              {
                key: 'ap_security_type',
                index: 50,
                title: $r('app.string.wifi_security_type'),
                state: WifiUtils.getApSecurityString(this.accessPoint?.securityType ?? 0),
              }
            ),
            new StateMenu(
              {
                key: 'mac_address_title',
                index: 60,
                title: $r('app.string.wifi_mac_address_title'),
                state: this.accessPoint?.getMacAddress(),
              }
            ),
            new StateMenu(
              {
                key: 'ap_ip_address',
                index: 60,
                title: $r('app.string.wifi_ip_address'),
                state: WifiUtils.getIPInfo(),
                style: new StateStyle(),
              }
            ),
            new SingleChoiceEntryMenu(
              {
                key: 'ap_privacy_type',
                index: 10,
                style: new PrivacySingleChoiceMenuStyle(),
                selectIcon: $r('app.media.ic_selected'),
                stateIcon: $r('app.media.ic_arrow_down'),
                title: $r('app.string.wifi_privacy_settings'),
                pathInfos: this.pathInfos,
                controller: {
                  createControllerConstructorInter: privacyController.CreatePrivacyController,
                },
                extra: this.accessPoint?.getBestConfig() as wifiManager.WifiDeviceConfig,
                singleChoiceData: [
                  { title: $r('app.string.wifi_privacy_random'),
                    isSelect: false,
                    key: wifiManager.DeviceAddressType.RANDOM_DEVICE_ADDRESS
                  },
                  {
                    title: $r('app.string.wifi_privacy_device'),
                    isSelect: false,
                    key: wifiManager.DeviceAddressType.REAL_DEVICE_ADDRESS
                  }]
              }
            ),
          ]
        ),
        new CardMenuSection(
          {
            key: 'wifi_config_group_three',
            index: 3,
          },
          [
            new NavigationEntry({
              key: NavEntryKey.WIFI_SETUP_PROXY_ENTRY,
              index: 20,
              title: $r('app.string.wifi_proxy_settings_title'),
              stateIcon: $r('app.media.ic_settings_arrow'),
              controller: {
                createControllerConstructorInter: WifiSetupProxyEntryController.Creator,
              },
              extra: this.accessPoint?.getBestConfig() as wifiManager.WifiDeviceConfig,
              pathInfos: this.pathInfos
            }),
            new NavigationEntry(
              {
                key: NavEntryKey.WIFI_SETUP_IP_ENTRY,
                index: 20,
                title: $r('app.string.wifi_ip_settings_title'),
                stateIcon: $r('app.media.ic_settings_arrow'),
                targetPageUrl: 'useless',
                controller: {
                  createControllerConstructorInter: WifiSetupIpEntryController.Creator,
                },
                extra: this.accessPoint?.getBestConfig() as wifiManager.WifiDeviceConfig,
                pathInfos: this.pathInfos,
              }
            ),
          ]
        )
      ]
    )
  }
}