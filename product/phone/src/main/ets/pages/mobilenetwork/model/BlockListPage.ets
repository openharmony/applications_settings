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

import { ContainerStyle, SubHeaderStyle, ResourceUtil } from '@ohos/settings.common';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import { SubHeaderSection } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { PageUrl } from '../../PageUrl';
import { APUserListController } from '../controller/HotspotDevicesController';

class BlockListHeaderStyle extends SubHeaderStyle {
  public rootContainer: ContainerStyle = blockListContainerStyle;
}

class BlockListContainerStyle extends ContainerStyle {
  public size: SizeOptions = {
    width: '100%',
    height: '16vp',
  };
}

let blockListContainerStyle: BlockListContainerStyle = new BlockListContainerStyle();

let blockListHeaderStyle: BlockListHeaderStyle = new BlockListHeaderStyle();

/**
 * 个人热点黑名单
 *
 * @since 2024-04-09
 */
export class BlockListPage extends SettingHeaderPage {
  constructor() {
    super({
      pageUrl: PageUrl.HOTSPOT_BLOCK_LIST_URL,
      title: ResourceUtil.getStringSync($r('app.string.hot_spot_block_list')),
      isNavigation: true,
      showHeader: false,
    });
    this.addMenus([
      new SubHeaderSection(
        {
          key: 'ap_block_list',
          index: 50,
          title: '',
          subHeaderStyle: blockListHeaderStyle,
          controller: {
            createControllerConstructorInter: APUserListController.CreateAPUserListController,
          },
        },
        []),
    ]);
  }
}