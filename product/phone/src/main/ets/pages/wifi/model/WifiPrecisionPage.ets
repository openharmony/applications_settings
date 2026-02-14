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
  CardMenuSection,
  HotspotSummaryMenu,
  HotspotSummaryStyle,
  SwitchMenu
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { WLAN_SCAN_KEY } from '@ohos/settings.wifi/src/main/ets/WifiUtils';
import { ContainerStyle, TextStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import { WifiScanController } from '../controller/WifiScanController';
import { PageUrl } from '../../PageUrl';

export class AboutHotspotSummaryContainerStyle extends ContainerStyle {
  public padding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_start'),
    top: $r('app.float.distance_8'),
    right: '12vp',
    bottom: $r('app.float.distance_24'),
  };
}
export class AboutHotspotSummaryTextStyle {
  public fontColor: ResourceColor = $r('sys.color.ohos_id_color_text_hint');
  public font: Font = {
    size: $r('sys.float.ohos_id_text_size_body2'),
    weight: FontWeight.Regular,
    family: 'HarmonyHeiTi',
  };
}
export class AboutHotspotSummaryStyle extends HotspotSummaryStyle {
  public rootContainer?: ContainerStyle = new AboutHotspotSummaryContainerStyle();
  public title?: TextStyle = new AboutHotspotSummaryTextStyle();
}

let aboutHotspotSummaryStyle = new AboutHotspotSummaryStyle();
export class WifiPrecisionPage extends SettingHeaderPage {
  constructor() {
    super({
      pageUrl: PageUrl.WIFI_PRECISION_PAGE_URL,
      title: $r('app.string.wifi_precision_title'),
      isNavigation: true,
      showHeader: false,
    });
    this.addMenus([
      new CardMenuSection(
        {
          key: 'wifi_precision_setting',
          index: 100,
        },
        [
          new SwitchMenu(
            {
              key: WLAN_SCAN_KEY,
              index: 10,
              title: $r('app.string.wlan_scan_title'),
              controller: {
                createControllerConstructorInter: WifiScanController.CreateWifiScanController,
              },
            }
          )
        ]
      ),
      new HotspotSummaryMenu({
        key: 'wlan_scan_content',
        index: 200,
        title: $r('app.string.wlan_scan_content'),
        style: aboutHotspotSummaryStyle,
      }),
    ]);
  }
}