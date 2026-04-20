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
  LoadingMenu,
  LoadingContainerStyle,
  DefaultLoadingProgressStyle,
  DefaultLoadingMenuStyle,
} from '@ohos/settings.uikit';
import { TimeZonePageController } from '@ohos/settings.datetime';
import { PageUrl } from '../../PageUrl';
import { TimeZoneListController, TimeZoneLoadingController } from '../controller/TimeZoneListController';
/* instrument ignore file */
import { SettingHeaderPage } from '@ohos/settings.uikit/src/main/ets/component/SettingHeaderPage';

/**
 * 时区页面数据
 *
 * @since 2022-12-09
 */
export class TimeZoneLoadingContainerStyle extends LoadingContainerStyle {
  // 加载中容器大小占满父布局
  public size: SizeOptions = {
    width: '100%',
    height: '100%',
  };
  public margin: Margin = {
    top: '0vp',
    right: '0vp',
    bottom: '0vp',
    left: '0vp',
  };
  public justifyContent = FlexAlign.Center;
}

export class TimeZoneLoadingProgressStyle extends DefaultLoadingProgressStyle {
  // 加载中控件大小
  public size: SizeOptions = {
    width: '72vp',
    height: '72vp',
  };
  public margin: Margin = {
    left: '0vp',
  };
}

export class TimeZoneLoadingMenuStyle extends DefaultLoadingMenuStyle {
  public rootContainer = new TimeZoneLoadingContainerStyle;
  public loadingProgressStyle = new TimeZoneLoadingProgressStyle();
}

export class TimeZonePage extends SettingHeaderPage {

  constructor(pathInfos: NavPathStack) {
    super({
      pageUrl: PageUrl.TIME_ZONE_PAGE_URL,
      controller: {
        createControllerConstructorInter: TimeZonePageController.CreateTimeZonePageController,
      },
      isStartAbility: (AppStorage.get<boolean>('isWorldClock') as boolean) ? true : false,
      isNavigation: true,
    });
    this.addMenus([
      new CardMenuSection(
        {
          key: 'time_zone_list_group',
          index: 5,
          controller: {
            createControllerConstructorInter: TimeZoneListController.CreateTimeZoneListController,
          },
          pathInfos: pathInfos,
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


