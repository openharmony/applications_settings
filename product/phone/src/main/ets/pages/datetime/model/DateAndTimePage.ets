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

import { Time24HourController } from '@ohos/settings.datetime/src/main/ets/controller/Time24HourController';
import { CardMenuSection, DateZoneMenu, DefaultEntryMenuStyle,
  EntryMenu,
  NavigationEntry,
  SwitchMenu,
  AccessibilitySwitchMenuWithSummaryStyle,
  RootContainerStyle
} from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { ContainerStyle, Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { BackMode, PrivacyPushParams } from '@ohos/settings.privacy/src/main/ets/PrivacyUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';
import DateController from '../controller/DateController';
import TimeController from '../controller/TimeController';
import TimeZoneController from '../controller/TimeZoneController';
import { PageUrl } from '../../PageUrl';
import AutoTimeZoneController from '../controller/AutoTimeZoneController';
import { DateAndTimeVisibleController } from '../controller/DateAndTimeVisibleController';

export const DATE_SETTINGS: string = 'date_settings';

// 设置时间菜单窗口偏移量
class TimeZoneMenuStyle extends DefaultEntryMenuStyle {
  public rootContainer: ContainerStyle = new RootContainerStyle();
  public startFlexShrink: number = 0;
  public endFlexShrink: number = 1;
}

const setMenus = (pathInfos: NavPathStack): SettingsBaseMenu[] => {
  const menus: SettingsBaseMenu[] = [
    new CardMenuSection(
      {
        key: 'time_24_hour_group',
        index: 100,
      },
      [
        new SwitchMenu(
          {
            key: 'time_24_hour_switch',
            index: 10,
            tabIndex: 101,
            controller: {
              createControllerConstructorInter: Time24HourController.createTime24HourController,
            },
          },
        ),
      ]
    ),
    new CardMenuSection(
      {
        key: 'time_zone_group',
        index: 200,
        controller: {
          createControllerConstructorInter: DateAndTimeVisibleController.CreateDateAndTimeVisibleController,
        },
        pathInfos: pathInfos,
      },
      [
        new SwitchMenu(
          {
            key: 'auto_timezone',
            index: 10,
            tabIndex: 102,
            title: $r('app.string.automatic_setting'),
            summary: $r('app.string.time_date_zone'),
            controller: {
              createControllerConstructorInter: AutoTimeZoneController.ControlAutoTimeZoneController,
            },
            style: new AccessibilitySwitchMenuWithSummaryStyle()
          },
        ),
        new EntryMenu(
          {
            key: DATE_SETTINGS,
            index: 50,
            title: $r('app.string.date_settings_title'),
            controller: {
              createControllerConstructorInter: DateController.CreateDateController,
            },
            symbolIcon: $r('sys.symbol.chevron_right'),
          },
        ),
        new EntryMenu(
          {
            key: 'time_settings',
            index: 100,
            title: $r('app.string.time_settings_title'),
            controller: {
              createControllerConstructorInter: TimeController.CreateTimeController,
            },
            symbolIcon: $r('sys.symbol.chevron_right'),
          },
        ),
        new NavigationEntry(
          {
            key: 'time_zone_settings',
            index: 150,
            title: $r('app.string.time_zone_settings_title'),
            symbolIcon: $r('sys.symbol.chevron_right'),
            style: new TimeZoneMenuStyle(),
            targetPageUrl: PageUrl.TIME_ZONE_PAGE_URL,
            controller: {
              createControllerConstructorInter: TimeZoneController.CreateTimeZoneController,
            },
            pathInfos: pathInfos,
          },
        ),
      ]
    ),
  ];
  menus.push(new DateZoneMenu({
    key: NavEntryKey.PRIVACY_ENTRY_INNER,
    index: 200,
    targetPageUrl: PageUrl.LOCATION_SERVICE_PAGE_URL,
    navRouterParam: new PrivacyPushParams(NavEntryKey.LOCATION_MANAGER_ENTRY, BackMode.Outer),
  }))
  return menus;
}

/**
 * 时间日期页菜单数据
 */
export class DateAndTimePage extends SettingHeaderPage {
  constructor(pathInfos: NavPathStack, params: PushParam) {
    super({
      pageUrl: PageUrl.DATE_TIME_PAGE_URL,
      title: $r('app.string.date_time_settings_title'),
      isNavigation: true,
      showHeader: false,
    });
    this.addMenus(setMenus(pathInfos));
  }
}
