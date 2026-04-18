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

import Router from '@ohos.router';
import common from '@ohos.app.ability.common';
import emitter from '@ohos.events.emitter';
import systemTime from '@ohos.systemTime';
import { MenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { TimeZoneUtil } from '@ohos/settings.datetime/src/main/ets/utils/TimeZoneUtil';
import Want from '@ohos.app.ability.Want';
import { BusinessError } from '@ohos.base';
import { REFRESH_TIME_ZONE_EVENTS } from '@ohos/settings.common/src/main/ets/event/types';
import { HiSysSystemEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

/* instrument ignore file */
const TAG: string = 'TimeZoneMenuController : ';

/**
 * 时区菜单项控制器
 *
 * @since 2022-12-13
 */
export class TimeZoneMenuController extends MenuController {
  static CreateTimeZoneMenuController(menu: SettingsBaseMenu): Controller {
    return new TimeZoneMenuController(menu);
  }

  aboutToAppear(): void {
    super.aboutToAppear();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
  }

  updateStatus(): void {
    super.updateStatus();
  }

  onMenuClick(): boolean {
    let cityId: string = this.menu?.extra as string;
    HiSysEventUtil.reportDefaultBehaviorEvent(HiSysSystemEventGroup.CHANGE_TIME_ZONE, cityId);
    if ((AppStorage.get<boolean>('isWorldClock') as boolean)) {
      LogUtil.info(`${TAG} onMenuClick world_clock`);
      let want: Want = {
        bundleName: 'com.ohos.clock',
        abilityName: 'com.ohos.clock.phone',
        parameters: {
          cityId: cityId,
        },
      };
      let context = getContext(this) as common.UIAbilityContext;
      context.startAbility(want);
    } else {
      let timeZone = TimeZoneUtil.getTimezoneFromCity(cityId);
      systemTime.setTimezone(timeZone.getID()).then((data) => {
        emitter.emit({ eventId: REFRESH_TIME_ZONE_EVENTS });
        this.goBack();
      }).catch((error: BusinessError) => {
        LogUtil.error(`${TAG} Failed to set system time zone. Cause: ${error?.message}`);
      });
    }
    return true;
  }

  protected goBack(): void {
    LogUtil.info(`${TAG} Succeeded in setting system time zone.`);
    this.menu.pathInfos?.pop();
  }
}

export class ExtensionTimeZoneMenuController extends TimeZoneMenuController {
  static CreateExtensionTimeZoneMenuController(menu: SettingsBaseMenu): Controller {
    return new ExtensionTimeZoneMenuController(menu);
  }

  protected goBack(): void {
    LogUtil.info(`${TAG} Succeeded in setting system time zone.`);
    Router.back();
  }
}
