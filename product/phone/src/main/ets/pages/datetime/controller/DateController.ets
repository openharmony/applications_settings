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

import emitter from '@ohos.events.emitter';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { PageLifecycleMenuController } from '@ohos/settings.common/src/main/ets/core/controller/LifecycleMenuController';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { DateAndTimeUtil } from '@ohos/settings.datetime';
import commonEventManager from '@ohos.commonEventManager';
import { AUTO_SET_UPDATE_EVENTS } from '@ohos/settings.common/src/main/ets/event/types';
import { HiSysSystemAndUpdatesEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';

/* instrument ignore file */
export const SET_DATE_BUTTON: string = 'set_date_button';

const TAG: string = 'DateController : ';
const DEFAULT_START_DATE: string = '2008-01-01'; // 设置用户可选的最早的时间
const DEFAULT_END_DATE: string = '2037-12-31'; // 设置用户可选的最晚的时间

/**
 * 日期菜单控制器
 *
 * @since 2022-04-27
 */
export default class DateController extends PageLifecycleMenuController {
  //订阅者信息
  public subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [commonEventManager.Support.COMMON_EVENT_TIME_TICK, commonEventManager.Support.COMMON_EVENT_DATE_CHANGED],
  };
  public timeCommonEvent = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    if (err.code) {
      LogUtil.error(`${TAG} subscribe failed ${err?.message}`);
    } else {
      LogUtil.info(`${TAG} subscribe success`);
      this.refreshUi();
    }
  });

  static CreateDateController(menu: SettingsBaseMenu): Controller {
    return new DateController(menu);
  }

  onMenuClick(): boolean {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.DATE_POP_FRAME);
    this.showDatePickerInternal();
    return true;
  }

  private showDatePickerInternal(): void {
    LogUtil.info(`${TAG} showDatePickerInternal`);
    // 设置用户可选的最早的时间和最晚的时间
    DatePickerDialog.show({
      start: new Date(DEFAULT_START_DATE),
      end: new Date(DEFAULT_END_DATE),
      alignment: DialogAlignment.Center,
      onAccept: (value: DatePickerResult) => {
        HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.DATE_POP_FRAME_CONFIRM,
          JSON.stringify(value));
        LogUtil.info(`${TAG} DatePickerDialog:onAccept()`);
        let datetime = new Date();
        datetime.setFullYear(value.year as number, value.month as number, value.day as number);
        DateAndTimeUtil.setDate(datetime).then((value) => {
          LogUtil.info(`${TAG} SystemTimePlugin success to systemTime.setDate.`);
          this.refreshUi();
        }).catch((error: Error) => {
          LogUtil.error(`${TAG} SystemTimePlugin failed to systemTime.setDate because: ${error?.message}`);
        });
        this.publishDataChange(SET_DATE_BUTTON);
      },
    })
  }

  updateStatus(): void {
    super.updateStatus();
    this.changeValue();
  }

  private changeValue(): void {
    this.menu.state = DateAndTimeUtil.getSystemDate();
    LogUtil.info(`${TAG} state: ${this.menu.state}`);
  }

  refreshUi(): void {
    this.changeValue();
    super.refreshUi();
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    emitter.on({
      eventId: AUTO_SET_UPDATE_EVENTS
    }, (eventData: emitter.EventData) => {
      this.changeValue();
    });
    this.timeCommonEvent.registerCommonEvent();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
    emitter.off(AUTO_SET_UPDATE_EVENTS);
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
