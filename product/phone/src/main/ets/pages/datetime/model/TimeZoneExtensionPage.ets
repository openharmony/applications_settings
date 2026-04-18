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

import { CardMenuSection, LoadingMenu } from '@ohos/settings.uikit';
import { TimeZonePageController } from '@ohos/settings.datetime';
import { ExtensionTimeZoneListController, TimeZoneLoadingController } from '../controller/TimeZoneListController';
import { PageUrl } from '../../PageUrl';
import { TimeZoneLoadingMenuStyle } from './TimeZonePage'
/* instrument ignore file */
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';

/**
 * 时区页面数据
 *
 * @since 2022-12-09
 */
export class TimeZoneExtensionPage extends SettingHeaderPage {
  constructor() {
    super({
      pageUrl: PageUrl.TIME_ZONE_PAGE_URL,
      controller: {
        createControllerConstructorInter: TimeZonePageController.CreateTimeZonePageController,
      },
      isStartAbility: (AppStorage.get<boolean>('isWorldClock') as boolean) ? true : false,
    });
    this.addMenus([
      new CardMenuSection(
        {
          key: 'time_zone_list_group',
          index: 5,
          controller: {
            createControllerConstructorInter: ExtensionTimeZoneListController.CreateExtensionTimeZoneListController,
          },
        },
        []
      ),
      new LoadingMenu(
        {
          key: 'time_zone_loading',
          index: 10,
          summary: $r('app.string.app_list_loading_message'),
          style: new TimeZoneLoadingMenuStyle(),
          controller: {
            createControllerConstructorInter: TimeZoneLoadingController.CreateTimeZoneLoadingController,
          },
        }
      ),
    ]);
  }
}


