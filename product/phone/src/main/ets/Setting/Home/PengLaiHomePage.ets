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

import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { ItemDetailType, ItemType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { DialogUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { PackagesConstant } from '@ohos/settings.common/src/main/ets/constant/PackagesConstant';
import { HomePageControl } from './controller/HomePageControl';
import { HomePageModelUtil } from './utils/HomePageModelUtil';

/* instrument ignore file */

function homePage(): SettingPageModel {
  return {
    id: 'Home',
    url: NavEntryKey.PENG_LAI_HOME_PAGE,
    type: PageType.PAGE_TYPE_HOME,
    title: $r('app.string.settings_title'),
    compControl: new HomePageControl(),
    groups: [
      {
        id: 'connection_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          HomePageModelUtil.getWlanItem(),
          HomePageModelUtil.getBluetoothItem(),
          HomePageModelUtil.getMobileItem(),
        ]
      },
      {
        id: 'sound_and_notification_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          HomePageModelUtil.getDisplayItem(),
          HomePageModelUtil.getVolumeItem()
        ]
      },
      {
        id: 'privacy_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          HomePageModelUtil.getUpdateItem(),
        ]
      },
    ]
  }
}

// 页面配置导入
PageLoader.load(NavEntryKey.PENG_LAI_HOME_PAGE, {
  configGenerator: homePage,
});