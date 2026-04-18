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

import { PADDING_0, PADDING_16 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { PageLoader } from '@ohos/settings.common/src/main/ets/framework/common/PageLoader';
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { GroupType } from '@ohos/settings.common/src/main/ets/framework/model/SettingGroupModel';
import { ItemType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { PageType, SettingPageModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingPageModel';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';

import { AboutDeviceItemView } from './view/AboutDeviceItemView';
import { SearchComponent } from '../Search/SearchComponent';
import { HomePageControl } from './controller/HomePageControl';
import { VassistantGroupView } from './view/VassistantGroupView';
import { HomePageModelUtil } from './utils/HomePageModelUtil';

const URL_HOME_PAGE: string = 'Setting.Home';
const TAG: string = 'HomePage:';

@Builder function searchIconBuilder(item: object) {
  if (!DeviceUtil.isDeviceEmulator()) {
    SearchComponent({ item: item as SettingBaseModel });
  }
}

@Builder function aboutDeviceItemBuilder(item: object) {
  AboutDeviceItemView({ item: item as SettingBaseModel });
}

@Builder function vassistantGroupBuilder(item: object) {
  VassistantGroupView({ itemInd: (item as SettingBaseModel).tabIndex as number });
}

function homePage(): SettingPageModel {
  return {
    id: 'Home',
    url: URL_HOME_PAGE,
    type: PageType.PAGE_TYPE_HOME,
    title: $r('app.string.settings_title'),
    compControl: new HomePageControl(),
    groups: [
      {
        id: 'search_group',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(searchIconBuilder),
      },
      {
        id: 'about_device_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          {
            id: NavEntryKey.ABOUT_DEVICE_ENTRY,
            type: ItemType.ITEM_TYPE_CUSTOM,
            builder: wrapBuilder(aboutDeviceItemBuilder),
          },
        ],
      },
      {
        id: 'connection_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          HomePageModelUtil.getWlanItem(),
          HomePageModelUtil.getBluetoothItem(),
          HomePageModelUtil.getMobileItem(),
          HomePageModelUtil.getNetworkItem(),
          HomePageModelUtil.getMoreConnectionItem(),
        ]
      },
      {
        id: 'sound_and_notification_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          HomePageModelUtil.getThemeItem(),
          HomePageModelUtil.getDisplayItem(),
          HomePageModelUtil.getVolumeItem(),
          HomePageModelUtil.getNotificationItem(),
          HomePageModelUtil.getIntelligentItem(),
        ]
      },
      {
        id: 'privacy_group',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          HomePageModelUtil.getUpdateItem(),
          HomePageModelUtil.getApplicationItem(),
          HomePageModelUtil.getStorageItem(),
          HomePageModelUtil.getBatteryItem(),
          HomePageModelUtil.getBiometricsItem(),
          HomePageModelUtil.getPrivacyItem(),
        ]
      },
      {
        id: 'vassistant_group',
        type: GroupType.GROUP_TYPE_CUSTOM,
        builder: wrapBuilder(vassistantGroupBuilder),
      },
      {
        id: 'external_device',
        type: GroupType.GROUP_TYPE_STANDARD,
        items: [
          // HomePageModelUtil.getHiWriteItem(),
          // HomePageModelUtil.getMouseItem(),
          // HomePageModelUtil.getKeyboardItem(),
          // HomePageModelUtil.getPadTouchItem(),
          HomePageModelUtil.getPrinterItem(),
        ]
      },
    ]
  }
}

// 页面配置导入
PageLoader.load(URL_HOME_PAGE, {
  configGenerator: homePage,
});