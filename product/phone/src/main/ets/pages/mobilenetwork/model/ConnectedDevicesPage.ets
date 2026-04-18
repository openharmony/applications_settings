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

import { ContainerStyle, TextStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import {
  CardMenuSection,
  CardSectionListStyle,
  GroupDividerStyle,
  HotspotSummaryStyle,
  NavigationEntry,
  SpaceHeaderStyle,
  SubHeaderSection,
  SubHeaderSectionStyle
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { TextTipsMenu } from '@ohos/settings.uikit/src/main/ets/menus/hotsport/TextTipsMenu';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import { SatelliteUtils } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { TabIndexConstants } from '@ohos/settings.common/src/main/ets/constant/TabIndexConstants';
import { PageUrl } from '../../PageUrl';
import { APUserListController } from '../controller/HotspotDevicesController';

export class HotspotPwdHintSummaryContainerStyle extends ContainerStyle {
  public padding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_start'),
    top: $r('app.float.distance_8'),
  };
}

export class SubHeaderSpaceStyle1 extends SpaceHeaderStyle {
  public space = '22vp';
  public firstVisibleSpace = '12vp';
}

export let subHeaderSpaceStyle1 = new SubHeaderSpaceStyle1();

class APDividerStyle extends GroupDividerStyle {
  public startMargin: Length = '48vp';
}

class APCardSectionListStyle extends CardSectionListStyle {
  public divider = new APDividerStyle();
}

export class APSubHeaderSectionStyle extends SubHeaderSectionStyle {
  public listStyle = new APCardSectionListStyle();
}

/**
 * 已连接设备页面
 *
 * @since 2023-08-15
 */
export class ConnectedDevicesPage extends SettingHeaderPage {
  constructor() {
    super({
      pageUrl: PageUrl.MOBILE_NETWORK_PAGE_URL,
      title: $r('app.string.hotspot_connected_device'),
      isNavigation: true,
      showHeader: false,
    });
    let enable: boolean = !SatelliteUtils.isCommunicationOpen();
    subHeaderSpaceStyle1.space = '0vp';
    subHeaderSpaceStyle1.firstVisibleSpace = '0vp';
    this.addMenus([
      new CardMenuSection(
        {
          key: 'black_list_group',
          index: 10,
        },
        [
          new NavigationEntry(
            {
              key: 'block_list_entry',
              index: 10,
              tabIndex: TabIndexConstants.TAB_INDEX_LEVEL2_PAGE,
              enable: enable,
              title: ResourceUtil.getStringSync($r('app.string.hot_spot_block_list')),
              stateIcon: $r('app.media.ic_settings_arrow'),
              targetPageUrl: PageUrl.HOTSPOT_BLOCK_LIST_URL,
            }
          )
        ]
      ),
      new TextTipsMenu({
        key: 'black_list_sub_title',
        enable: enable,
        title: ResourceUtil.getStringSync($r('app.string.block_list_tips')),
      }),
      new SubHeaderSection(
        {
          key: 'ap_connected_devices',
          index: 50,
          enable: enable,
          title: ResourceUtil.getStringSync($r('app.string.other_wlan')),
          spaceStyle: subHeaderSpaceStyle1,
          style: new APSubHeaderSectionStyle(),
          controller: {
            createControllerConstructorInter: APUserListController.CreateAPUserListController,
          },
        },
        []),
    ]);
  }
}