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

import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageLifecycleMenuGroupController } from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';

/**
 * 时区页面控制器类
 *
 * @since 2023-02-16
 */
export class TimeZonePageController extends PageLifecycleMenuGroupController {
  static CreateTimeZonePageController(menu: SettingsBaseMenu): Controller {
    return new TimeZonePageController(menu);
  }

  public tag: string = 'TimeZonePageController : ';

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    LogUtil.info(`${this.tag} world_clock TimeZonePageController constructor `);
    if ((AppStorage.get<boolean>('isWorldClock') as boolean) || (AppStorage.get<boolean>('isPcWorldClock') as boolean)) {
      LogUtil.info(`${this.tag} world_clock title addcity`);
      this.menu.title = $r('app.string.add_city_settings_title');
    } else {
      LogUtil.info(`${this.tag} world_clock title timezone`);
      this.menu.title = $r('app.string.time_zone_settings_title');
    }
  }
}
