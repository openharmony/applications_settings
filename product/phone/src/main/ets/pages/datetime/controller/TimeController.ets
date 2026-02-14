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
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { PageLifecycleMenuController } from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { DateAndTimeUtil } from '@ohos/settings.datetime';
import i18n from '@ohos.i18n';
import emitter from '@ohos.events.emitter';
import { BusinessError } from '@ohos.base';
import commonEventManager from '@ohos.commonEventManager';
import {
  REFRESH_TIME_ZONE_EVENTS, AUTO_SET_UPDATE_EVENTS, TIME_24_HOUR_SWITCH_OPEN_EVENTS
} from '@ohos/settings.common/src/main/ets/event/types';
import { HiSysSystemAndUpdatesEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
/* instrument ignore file */
const TAG: string = 'TimeController: ';
const KEY_TIME_24_HOUR_SWITCH: string = 'time_24_hour_switch';

/**
 * 时间菜单控制器
 *
 * @since 2022-04-27
 */
export default class TimeController extends PageLifecycleMenuController {
  //订阅者信息
  public subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [commonEventManager.Support.COMMON_EVENT_TIME_TICK, commonEventManager.Support.COMMON_EVENT_TIME_CHANGED],
  };
  public timeCommonEvent = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    if (err.code) {
      LogUtil.error(`${TAG} subscribe failed ${err?.message}`);
    } else {
      LogUtil.info(`${TAG} subscribe success`);
      this.refreshUi();
    }
  });

  static CreateTimeController(menu: SettingsBaseMenu): Controller {
    return new TimeController(menu);
  }

  onMenuClick(): boolean {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.TIME_POP_FRAME);
    this.showTimePickerInternal();
    return true;
  }

  private showTimePickerInternal(): void {
    LogUtil.info(`${TAG} showTimePickerInternal`);
    TimePickerDialog.show({
      useMilitaryTime: DateAndTimeUtil.get24HourTimeFormat(),
      alignment: DialogAlignment.Center,
      onAccept: (value: TimePickerResult) => {
        HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.TIME_POP_FRAME_CONFIRM,
          JSON.stringify(value));
        value.second = 0;
        LogUtil.info(`${TAG} TimePickerDialog:onAccept() ${value?.hour}:${value?.minute}:${value?.second}`);
        DateAndTimeUtil.setTime(DateAndTimeUtil.getFixedTime(value).getTime()).then(data => {
          LogUtil.info(`${TAG} SystemTimePlugin success to systemTime.setTime`);
          this.refreshUi();
        }).catch((error: BusinessError) => {
          LogUtil.error(`${TAG} SystemTimePlugin failed to systemTime.setTime because: ${error?.message}`);
        });
      },
    });
  }

  updateStatus(): void {
    super.updateStatus();
    this.changeValue();
  }

  private changeValue(): void {
    let is24HourClock = i18n.System.is24HourClock();
    let newDate = new Date();
    let newDateStr = newDate.toLocaleString();
    this.menu.state = DateAndTimeUtil.getSystemTime(is24HourClock);
    LogUtil.info(`${TAG} menu.state is ${this.menu.state}, newDateStr is ${newDateStr}, is24HourClock is ${is24HourClock}`);
  }

  refreshUi(): void {
    this.changeValue();
    super.refreshUi();
  }

  registerDataChange(): void {
    // 监听24小时制菜单
    this.registerControllerDataChange(KEY_TIME_24_HOUR_SWITCH);
    this.timeCommonEvent.registerCommonEvent();
  }

  unRegisterDataChange(): void {
    this.unRegisterControllerDataChange(KEY_TIME_24_HOUR_SWITCH);
    this.timeCommonEvent.unRegisterCommonEvent();
  }

  onDataChange(fromKey: string, data: Object): void {
    if (fromKey === KEY_TIME_24_HOUR_SWITCH && data) {
      this.refreshUi();
    }
  }

  aboutToAppear(): void {
    this.refreshUi();
    emitter.on({
      eventId: REFRESH_TIME_ZONE_EVENTS
    }, (eventData: emitter.EventData) => {
      this.refreshUi();
    });
    emitter.on({
      eventId: AUTO_SET_UPDATE_EVENTS
    }, (eventData: emitter.EventData) => {
      this.refreshUi();
    });
    emitter.on({
      eventId: TIME_24_HOUR_SWITCH_OPEN_EVENTS
    }, (eventData: emitter.EventData) => {
      this.refreshUi();
    });
    this.timeCommonEvent.registerCommonEvent();
  }

  aboutToDisappear(): void {
    emitter.off(REFRESH_TIME_ZONE_EVENTS);
    emitter.off(AUTO_SET_UPDATE_EVENTS);
    emitter.off(TIME_24_HOUR_SWITCH_OPEN_EVENTS)
    this.timeCommonEvent.unRegisterCommonEvent();
  }

  onPageShow(): void {
    this.refreshUi();
    this.timeCommonEvent.registerCommonEvent();
  }

  onPageHide(): void {
    this.timeCommonEvent.unRegisterCommonEvent();
  }
}
