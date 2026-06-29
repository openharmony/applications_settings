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

import {
  CardSectionListStyle,
  DefaultDialogPageStyle,
  LoadingSubHeaderSection,
  LoadingSubHeaderSectionStyle,
  SpaceHeaderStyle,
  SubHeaderLoadingMenuStyle,
  SuHeaderContainerStyle,
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { BaseStyle, ContainerStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { MenuPageType } from '@ohos/settings.common/src/main/ets/core/model/menu/MenuType';
import { MenuSection } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import WifiWindowController from '../controller/WifiWindowController';
import { PageUrl } from '../../PageUrl';

export const PLUGIN_WIFI_WINDOW_URL: string = 'pages/wifi/model/WifiWindowPage.js';

class WifiListSectionListStyle extends CardSectionListStyle {
  public borderRadius = $r('app.float.border_radius_0');
  public backgroundColor = Color.Transparent;
}

class WifiListMenuStyle extends LoadingSubHeaderSectionStyle {
  public listStyle = new WifiListSectionListStyle();
}

export class WifiWindowPageStyle extends DefaultDialogPageStyle {
  public backgroundColor = Color.Transparent;
  public space = '0vp';
}

export class WifiSpaceHeaderStyle extends SpaceHeaderStyle {
  public space = '3.5vp';
  public firstVisibleSpace = '3.5vp';
}

class HeaderContainerStyle extends SuHeaderContainerStyle {
  public constraintSize: ConstraintSizeOptions = {
    minHeight: '24vp',
  };
}

export class LoadingProgressStyle extends BaseStyle {
  public size: SizeOptions = {
    width: '24vp',
    height: '24vp',
  };
  public margin: Margin = {
    bottom: '4vp',
  };
}

export class WifiSubHeaderLoadingStyle extends SubHeaderLoadingMenuStyle {
  public rootContainer: ContainerStyle = new HeaderContainerStyle();
  public loadingProgressStyle = new LoadingProgressStyle();
}

/**
 * Wifi弹窗页菜单页数据
 *
 * @since 2023-03-13
 */
export class WifiWindowPage extends SettingHeaderPage {
  public menuType = MenuPageType.DIALOG_PAGE

  constructor() {
    super({
      pageUrl: PageUrl.WIFI_WINDOW_PAGE_URL,
      title: $r('app.string.wifi_settings_title'),
      style: new WifiWindowPageStyle(),
      menuType: MenuPageType.DIALOG_PAGE,
    });
    this.setHeader(
      new MenuSection(
        {
          key: 'wifi_window_page_header_group',
        },
        [
          new LoadingSubHeaderSection(
            {
              key: 'wifi_page_header_group',
              index: 10,
              title: $r('app.string.wifi_available_ap_list'),
              style: new WifiListMenuStyle(),
              controller: {
                createControllerConstructorInter: WifiWindowController.CreateWifiWindowController,
              },
            },
            [],
            new WifiSpaceHeaderStyle(),
            new WifiSubHeaderLoadingStyle()),
        ]));
    this.addMenus([
      new MenuSection(
        {
          key: 'wifi_list_group',
          index: 20,
          style: new WifiListMenuStyle(),
          controller: {
            createControllerConstructorInter: WifiWindowController.CreateWifiWindowController,
          },
        },
        []
      )
    ]);
  }
}
