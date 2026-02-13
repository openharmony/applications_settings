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

import { WIFI_SWITCH_KEY } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import { WifiSwitchController } from '@ohos/settings.wifi/src/main/ets/controller/WifiSwitchController';
import {
  CardMenuSection,
  NavigationEntry,
  SwitchMenu,
  WifiCardSectionStyle,
  WifiLoadingSubHeaderSection,
  WifiPrecisionMenu,
  WifiSubHeaderSection,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import WifiConnectedApController from '../controller/WifiConnectedApController';
import { WifiListController } from '../controller/WifiListController';
import { PageUrl } from '../../PageUrl';
import { PrecisionSummaryController } from '../controller/PrecisionSummaryController';
import { AddOtherWifiMenuStyle } from '../WifiMenuPageComponent';
import { ExternalAddOtherWifiEntryGroupController } from '../controller/AddOtherWifiControllers';

/**
 * Wifi页菜单页数据
 *
 * @since 2022-03-21
 */
export class WifiPage extends SettingHeaderPage {
  public pathInfos: NavPathStack;
  public isFromExternal: boolean;

  constructor(pathInfos: NavPathStack, isFromExternal?: boolean) {
    super({
      pageUrl: PageUrl.WIFI_PAGE_URL,
      title: $r('app.string.wifi_settings_title'),
      isNavigation: true,
      showHeader: false,
    });
    this.pathInfos = pathInfos;
    this.isFromExternal = isFromExternal ?? false;
    this.setHeader(
      new CardMenuSection(
        {
          key: 'page_header_group',
          index: 0,
          style:new WifiCardSectionStyle(),
        },
        [
          new SwitchMenu(
            {
              key: WIFI_SWITCH_KEY,
              index: 10,
              title: $r('app.string.wifi_settings_title'),
              controller: {
                createControllerConstructorInter: WifiSwitchController.CreateWifiSwitchController,
              },
            }
          ),
        ]
      )
    )
    this.addMenus([
      new WifiPrecisionMenu(
        {
          key: NavEntryKey.WIFI_PRECISION_MENU_ENTRY,
          index: 200,
          title: $r('app.string.wifi_precision_title'),
          targetPageUrl: PageUrl.WIFI_PRECISION_PAGE_URL,
          controller: {
            createControllerConstructorInter: PrecisionSummaryController.CreatePrecisionSummaryController,
          },
        },
      ),
      new WifiSubHeaderSection(
        {
          key: 'wifi_connected_ap_group',
          index: 10,
          title: $r('app.string.wifi_connected_ap'),
          pathInfos: this.pathInfos,
          controller: {
            createControllerConstructorInter: WifiConnectedApController.CreateWifiConnectedApController,
          },
        },
        []),
      new WifiLoadingSubHeaderSection(
        {
          key: 'hotspot_list_group',
          index: 30,
          title: $r('app.string.smart_hotspot_settings_title'),
          extra: {
            isCurrentVisible: false,
          },
        },
        []),
      new WifiLoadingSubHeaderSection(
        {
          key: 'wifi_list_group',
          index: 20,
          title: $r('app.string.wifi_available_ap_group'),
          controller: {
            createControllerConstructorInter: WifiListController.CreateWifiListController,
          },
          pathInfos: this.pathInfos,
          extra: this.isFromExternal,
        },
        []),
      new CardMenuSection(
        {
          key: 'add_other_wifi_entry_section',
          index: 1000,
          controller: {
            createControllerConstructorInter: ExternalAddOtherWifiEntryGroupController.Creator,
          }
        },
        [
          new NavigationEntry({
            key: NavEntryKey.ADD_OTHER_WIFI_ENTRY,
            index: 10,
            title: $r('app.string.wifi_add_other_wifi'),
            style: new AddOtherWifiMenuStyle(),
            targetPageUrl: 'useless',
          })
        ]
      )
    ]);
  }
}
