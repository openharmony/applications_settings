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
import { PADDING_16, PADDING_88 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { ModalLoader } from '@ohos/settings.common/src/main/ets/framework/common/ModalLoader';
import { DynamicDataSource } from '@ohos/settings.common/src/main/ets/framework/model/DynamicDataSource';
import { CompCtrlParam } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { GroupType, SettingGroupModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import {
  ItemResultType,
  ItemType,
  SettingItemModel,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { settingSheetBuilder } from '@ohos/settings.common/src/main/ets/framework/view/SettingSheet';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { AddOtherWlanConfigManager } from './AddOtherWlanConfigManager';
import { SaveIpInfoComponent } from './component/SaveIpInfoComponent';
import { StaticIpInputComponent } from './component/StaticIpInputComponent';
import { WifiSetupIpButtonController } from './controller/new/WifiSetupIpButtonController';
import { WifiSetupIpSheetPageController } from './controller/new/WifiSetupIpSheetPageController';
import {
  WIFI_IP_ADDRESS,
  WIFI_IP_DNS_SERVERS_1,
  WIFI_IP_DNS_SERVERS_2,
  WIFI_IP_GATEWAY,
  WIFI_IP_PREFIX_LENGTH,
} from './WifiMenuManager';
import { WifiPasswordConfigManager } from './WifiPasswordConfigManager';

export const URL_SET_UP_IP_PAGE: string = 'Setting.Wlan.WifiSetupIp';

@Builder
export function staticIpInputBuilder(param: object): void {
  StaticIpInputComponent({
    item: param as SettingGroupModel,
  });
}

@Builder
export function saveIpInfoComponentBuilder(param: object): void {
  SaveIpInfoComponent({
    item: param as SettingGroupModel,
  });
}

function customPage(): SettingPageModel {
  let isDhcp: boolean = true;
  let config: wifiManager.WifiDeviceConfig | undefined = AddOtherWlanConfigManager.getInstance().wifiConfig;
  if (config) {
    // 添加其他WLAN
    isDhcp = config?.ipType === wifiManager.IpType.DHCP;
  } else {
    // 输入密码界面
    isDhcp = WifiPasswordConfigManager.getInstance().getConfig()?.ipType ===
      wifiManager.IpType.DHCP;
  }
  let compControl: WifiSetupIpSheetPageController = new WifiSetupIpSheetPageController();
  return {
    id: 'wifi_setup_ip_config',
    url: URL_SET_UP_IP_PAGE,
    type: PageType.PAGE_TYPE_MODAL,
    layout: {
      backgroundColor: DeviceUtil.isDevicePc() ? $r('sys.color.background_secondary') :
      $r('app.color.component_ultra_thick_panel'),
      blurStyle: DeviceUtil.isDevicePc() ? BlurStyle.COMPONENT_ULTRA_THICK : BlurStyle.NONE,
      padding: {
        start: DeviceUtil.isDevicePc() ? PADDING_16 : undefined,
        end: DeviceUtil.isDevicePc() ? PADDING_16 : undefined,
        bottom: PADDING_88,
      },
    },
    title: $r('app.string.wifi_ip_settings_title'),
    compControl: compControl,
    groupForeground: {
      id: 'SaveIpInfo',
      builder: wrapBuilder(saveIpInfoComponentBuilder),
      compControl: new WifiSetupIpButtonController(),
    },
    groups: [
      {
        id: 'ip_menu_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        cached: false,
        visible: true,
        items: [
          {
            id: 'key_ip_option_dhcp',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: {
              content: $r('app.string.wifi_ip_settings_dhcp'),
            },
            result: {
              type: ItemResultType.RESULT_TYPE_RADIO,
              result: {
                checked: isDhcp,
                style: {
                  width: 22,
                  height: 22,
                  showUnchecked: false,
                }
              }
            }
          },
          {
            id: 'key_ip_option_static',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: {
              content: $r('app.string.wifi_ip_settings_static'),
            },
            result: {
              type: ItemResultType.RESULT_TYPE_RADIO,
              result: {
                checked: !isDhcp,
                style: {
                  width: 22,
                  height: 22,
                  showUnchecked: false,
                },
                onCheck: (isCheck: boolean, item: SettingItemModel) => {
                  compControl.onStaticIpChecked(isCheck);
                }
              }
            }
          }
        ]
      },
      {
        id: 'static_ip_input_group',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        cached: false,
        visible: !isDhcp,
        compControl: {
          init: (param: CompCtrlParam) => {
            // 添加手动代理信息输入菜单
            let dataSource: DynamicDataSource = param.dataSource as DynamicDataSource;
            dataSource.pushData({
              id: WIFI_IP_ADDRESS,
              type: ItemType.ITEM_TYPE_STANDARD,
              title: {
                content: $r('app.string.wifi_ip_address'),
              },
              result: {
                result: undefined,
                type: ItemResultType.RESULT_TYPE_CUSTOM,
                builder: wrapBuilder(staticIpInputBuilder),
              }
            },
              {
                id: WIFI_IP_GATEWAY,
                type: ItemType.ITEM_TYPE_STANDARD,
                title: {
                  content: $r('app.string.wifi_static_ip_gateway'),
                },
                result: {
                  result: undefined,
                  type: ItemResultType.RESULT_TYPE_CUSTOM,
                  builder: wrapBuilder(staticIpInputBuilder),
                }
              },
              {
                id: WIFI_IP_PREFIX_LENGTH,
                type: ItemType.ITEM_TYPE_STANDARD,
                title: {
                  content: $r('app.string.wifi_static_ip_network_prefix'),
                },
                result: {
                  result: undefined,
                  type: ItemResultType.RESULT_TYPE_CUSTOM,
                  builder: wrapBuilder(staticIpInputBuilder),
                }
              },
              {
                id: WIFI_IP_DNS_SERVERS_1,
                type: ItemType.ITEM_TYPE_STANDARD,
                title: {
                  content: $r('app.string.wifi_static_ip_dns1'),
                },
                result: {
                  result: undefined,
                  type: ItemResultType.RESULT_TYPE_CUSTOM,
                  builder: wrapBuilder(staticIpInputBuilder),
                }
              },
              {
                id: WIFI_IP_DNS_SERVERS_2,
                type: ItemType.ITEM_TYPE_STANDARD,
                title: {
                  content: $r('app.string.wifi_static_ip_dns2'),
                },
                result: {
                  result: undefined,
                  type: ItemResultType.RESULT_TYPE_CUSTOM,
                  builder: wrapBuilder(staticIpInputBuilder),
                }
              });
          },
          destroy: () => {
          },
        },
      },
    ],
  }
}

ModalLoader.load(URL_SET_UP_IP_PAGE, {
  configGenerator: customPage,
  pageBuilder: wrapBuilder(settingSheetBuilder),
});
