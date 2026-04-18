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
  SettingItemModel
} from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { settingSheetBuilder } from '@ohos/settings.common/src/main/ets/framework/view/SettingSheet';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { AddOtherWlanConfigManager } from './AddOtherWlanConfigManager';
import { SaveWlanInfoComponent } from './component/SaveWlanInfoComponent';
import { WlanProxyInputComponent } from './component/WlanProxyInputComponent';
import { WifiSetupProxyButtonController } from './controller/new/WifiSetupProxyButtonController';
import { WifiSetupProxySheetPageController } from './controller/new/WifiSetupProxySheetPageController';
import { WIFI_PROXY_EXCLUSIONLIST_LABEL, WIFI_PROXY_HOSTNAME_LABEL, WIFI_PROXY_PORT_LABEL, } from './WifiMenuManager';
import { WifiPasswordConfigManager } from './WifiPasswordConfigManager';

export const URL_SET_UP_PROXY_PAGE: string = 'Setting.Wlan.WifiSetupProxy';

@Builder
export function wlanProxyInputBuilder(param: object): void {
  WlanProxyInputComponent({
    item: param as SettingGroupModel,
  });
}

@Builder
export function saveWlanInfoComponentBuilder(param: object): void {
  SaveWlanInfoComponent({
    item: param as SettingGroupModel,
  });
}

function customPage(): SettingPageModel {
  let compControl: WifiSetupProxySheetPageController = new WifiSetupProxySheetPageController();
  let isNoneProxyChecked: boolean = true;
  let config: wifiManager.WifiDeviceConfig | undefined = AddOtherWlanConfigManager.getInstance().getConfig();
  if (config) {
    // 添加其他WLAN
    isNoneProxyChecked = config?.proxyConfig?.proxyMethod === wifiManager.ProxyMethod.METHOD_NONE;
  } else {
    // 输入密码界面
    isNoneProxyChecked = WifiPasswordConfigManager.getInstance().getConfig()?.proxyConfig?.proxyMethod ===
      wifiManager.ProxyMethod.METHOD_NONE;
  }
  return {
    id: 'wifi_setup_proxy_config',
    url: URL_SET_UP_PROXY_PAGE,
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
    title: $r('app.string.wifi_proxy_settings_title'),
    compControl: compControl,
    groupForeground: {
      id: 'SaveWlanInfo',
      builder: wrapBuilder(saveWlanInfoComponentBuilder),
      compControl: new WifiSetupProxyButtonController(),
    },
    groups: [
      {
        id: 'proxy_menu_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        cached: false,
        visible: true,
        // 添加代理类型菜单
        items: [
          {
            id: 'key_proxy_option_none',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: {
              content: $r('app.string.wifi_proxy_settings_none'),
            },
            result: {
              type: ItemResultType.RESULT_TYPE_RADIO,
              result: {
                checked: isNoneProxyChecked,
                style: {
                  width: 22,
                  height: 22,
                  showUnchecked: false,
                }
              }
            }
          },
          {
            id: 'key_proxy_option_manual',
            type: ItemType.ITEM_TYPE_STANDARD,
            title: {
              content: $r('app.string.wifi_proxy_settings_manual'),
            },
            result: {
              type: ItemResultType.RESULT_TYPE_RADIO,
              result: {
                checked: !isNoneProxyChecked,
                style: {
                  width: 22,
                  height: 22,
                  showUnchecked: false,
                },
                onCheck: (isCheck: boolean, item: SettingItemModel) => {
                  compControl.onManualProxyChecked(isCheck);
                }
              }
            }
          }
        ]
      },
      {
        id: 'proxy_input_group',
        type: GroupType.GROUP_TYPE_DYNAMIC,
        visible: !isNoneProxyChecked,
        compControl: {
          init: (param: CompCtrlParam) => {
            // 添加手动代理信息输入菜单
            let dataSource: DynamicDataSource = param.dataSource as DynamicDataSource;
            dataSource.pushData({
              id: WIFI_PROXY_HOSTNAME_LABEL,
              type: ItemType.ITEM_TYPE_STANDARD,
              title: {
                content: $r('app.string.proxy_hostname_label'),
                style: {
                  fontColor: $r('sys.color.font_primary'),
                }
              },
              result: {
                result: undefined,
                type: ItemResultType.RESULT_TYPE_CUSTOM,
                builder: wrapBuilder(wlanProxyInputBuilder),
              }
            }, {
              id: WIFI_PROXY_PORT_LABEL,
              type: ItemType.ITEM_TYPE_STANDARD,
              title: {
                content: $r('app.string.proxy_port_label'),
                style: {
                  fontColor: $r('sys.color.font_primary'),
                }
              },
              result: {
                result: undefined,
                type: ItemResultType.RESULT_TYPE_CUSTOM,
                builder: wrapBuilder(wlanProxyInputBuilder),
              }
            }, {
              id: WIFI_PROXY_EXCLUSIONLIST_LABEL,
              type: ItemType.ITEM_TYPE_STANDARD,
              title: {
                content: $r('app.string.proxy_exclusionlist_label'),
                style: {
                  fontColor: $r('sys.color.font_primary'),
                }
              },
              result: {
                result: undefined,
                type: ItemResultType.RESULT_TYPE_CUSTOM,
                builder: wrapBuilder(wlanProxyInputBuilder),
              }
            });
          },
          destroy: () => {},
        },
        header: {
          id: 'proxy_input_group_header',
          style: {
            height: 40,
            fontSize: $r('sys.float.Body_S'),
            fontColor: $r('sys.color.font_secondary'),
            fontWeight: FontWeight.Regular,
            fontFamily: 'HarmonyHeiTi',
          },
          content: $r('app.string.proxy_warning_limited_support'),
        },
      },
    ],
  }
}

ModalLoader.load(URL_SET_UP_PROXY_PAGE, {
  configGenerator: customPage,
  pageBuilder: wrapBuilder(settingSheetBuilder),
});
