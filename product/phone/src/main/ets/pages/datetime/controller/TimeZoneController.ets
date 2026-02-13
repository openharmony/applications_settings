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

import systemDateTime from '@ohos.systemDateTime';
import i18n from '@ohos.i18n';
import intl from '@ohos.intl';
import emitter from '@ohos.events.emitter';
import { TimeZoneUtil } from '@ohos/settings.datetime/src/main/ets/utils/TimeZoneUtil';
import { Controller, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { PageLifecycleMenuController } from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import commonEventManager from '@ohos.commonEventManager';
import { REFRESH_TIME_ZONE_EVENTS, AUTO_SET_UPDATE_EVENTS } from '@ohos/settings.common/src/main/ets/event/types';
import { DATE_SETTINGS } from '../model/DateAndTimePage';
import { SET_DATE_BUTTON } from './DateController';
import { HiSysSystemAndUpdatesEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

/* instrument ignore file */
const TAG: string = 'TimeZoneController : ';
const KEY_TIME_ZONE_SETTINGS: string = 'time_zone_settings';

/**
 * 时区菜单控制器
 *
 * @since 2022-12-13
 */
export default class TimeZoneController extends PageLifecycleMenuController {
  // 夏令时变化时会触发时区变化
  private subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [
      commonEventManager.Support.COMMON_EVENT_TIME_TICK,
      commonEventManager.Support.COMMON_EVENT_TIME_CHANGED,
      commonEventManager.Support.COMMON_EVENT_TIMEZONE_CHANGED
    ]
  };
  private timeCommonEvent = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    LogUtil.info(`${TAG} receive event:${data?.event}, code:${err.code}`);
    if (!err.code) {
      this.changeValue();
    }
  });

  static CreateTimeZoneController(menu: SettingsBaseMenu): Controller {
    return new TimeZoneController(menu);

  }

  aboutToAppear(): void {
    super.aboutToAppear();
    emitter.on({
      eventId: REFRESH_TIME_ZONE_EVENTS
    }, (eventData: emitter.EventData) => {
      this.updateStatus();
    });
    emitter.on({
      eventId: AUTO_SET_UPDATE_EVENTS
    }, (eventData: emitter.EventData) => {
      this.refreshUi();
    });
    this.timeCommonEvent.registerCommonEvent();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
    emitter.off(REFRESH_TIME_ZONE_EVENTS);
    emitter.off(AUTO_SET_UPDATE_EVENTS);
    this.timeCommonEvent.unRegisterCommonEvent();
  }

  updateStatus(): void {
    super.updateStatus();
    this.changeValue();
  }

  onPageShow(): void {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.TIME_ZONE_POP_FRAME);
    this.updateStatus();
  }

  registerDataChange(): void {
    this.registerControllerDataChange(DATE_SETTINGS);
  }

  unRegisterDataChange(): void {
    this.unRegisterControllerDataChange(DATE_SETTINGS);
  }

  onDataChange(fromKey: string, data: string | number): void {
    if (fromKey === DATE_SETTINGS && data === SET_DATE_BUTTON) {
      LogUtil.info(`${TAG} find data change`);
      this.changeValue();
    }
  }

  pushName(key: string, params: PushParam | null) {
    LogUtil.info(`${TAG} pushName key:${key}`);
    DynamicLoader.getInstance().fire(key).then(() => {
      this.menu.pathInfos?.pushPathByName(key, params);
    });
  }

  onMenuClick(): boolean {
    this.pushName(KEY_TIME_ZONE_SETTINGS, null);
    return true;
  }

  private changeValue(): void {
    systemDateTime.getTimezone().then((timeZoneId) => {
      let timeZone = i18n.getTimeZone(timeZoneId);
      let stateStr = `${TimeZoneUtil.getRawOffsetSummary(timeZone, true)} ${
      timeZone.getDisplayName(new intl.Locale(i18n.System.getSystemLanguage())?.toString())}`;
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup
        .TIME_ZONE_POP_FRAME_CONFIRM, stateStr);
      LogUtil.info(`${TAG} getTimezone, timeZoneId: ${timeZoneId}, stateStr: ${stateStr}`);
      this.menu.state = stateStr;
      this.refreshUi();
    }).catch((error: Error) => {
      LogUtil.error(`${TAG} Failed to get system time zone. Cause: ${error?.message}`);
    });
  }
}