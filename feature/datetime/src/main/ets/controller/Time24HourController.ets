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
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { SwitchMenuController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import {
  HiSysEventUtil,
} from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { TIME_24_HOUR_SWITCH_OPEN_EVENTS } from '@ohos/settings.common/src/main/ets/event/types';
import { HiSysSystemAndUpdatesEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DateAndTimeUtil } from '../utils/DateAndTimeUtil';

const TAG: string = 'Time24HourController : ';
/**
 * 24小时制开关控制器
 *
 * @since 2022-04-27
 */
@Observed
export class Time24HourController extends SwitchMenuController {
  private taskTimerId: number | null = null;
  private switchTimerId: number | null = null;
  private currentState: boolean | null = null;

  static createTime24HourController(menu: SettingsBaseMenu): Controller {
    return new Time24HourController(menu);
  }

  protected updateCheckedState(): boolean {
    return DateAndTimeUtil.get24HourTimeFormat();
  }

  protected handleCheckedChange(isOn: boolean): boolean {
    LogUtil.info(`${TAG} handleCheckedChange ${isOn}`);
    if (this.currentState === isOn) {
      LogUtil.info(`${this.tag} current state is same as isChecked`);
      return true;
    }
    this.setToggleState(false, false);
    this.currentState = isOn;
    if (isOn) {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.TWENTY_FOUR_HOURS_SWITCH, 'on');
    } else {
      HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysSystemAndUpdatesEventGroup.TWENTY_FOUR_HOURS_SWITCH, 'off');
    }
    this.startTask(isOn);
    return true;
  }

  private startTask(isOn: boolean) {
    this.stopTask();
    LogUtil.info(`${TAG} startTask ${isOn}`);
    this.taskTimerId = setTimeout(() => {
      this.taskTimerId = null;
      this.modify24HourTimeFormat(isOn);
    }, 200);
    this.switchTimerId = setTimeout(() => {
      this.switchTimerId = null;
      this.setToggleState(true, false);
    }, 200);
  }

  private stopTask(): void {
    if (this.taskTimerId !== null) {
      LogUtil.info(`${this.tag} stop existing task`);
      clearTimeout(this.taskTimerId);
      this.taskTimerId = null;
    }
    if (this.switchTimerId !== null) {
      LogUtil.showInfo(this.tag, 'stop existing switchTimerId task');
      clearTimeout(this.switchTimerId);
      this.switchTimerId = null;
    }
  }

  private modify24HourTimeFormat(isOn: boolean): void {
    let success: boolean = DateAndTimeUtil.set24HourTimFormat(isOn);
    if (!success) {
      this.updateStatus();
    }
    emitter.emit({ eventId: TIME_24_HOUR_SWITCH_OPEN_EVENTS})
    this.publishDataChange(success);
  }

  /**
   * 增加24小时的占位符支持
   *
   */
  private update24HourResource() {
    let message = ResourceUtil.getNumberFormatStringSync($r('app.string.time_24_hour_title'), '24');
    this.menu.title = message;
    this.refreshUi();
    // 第一次进入时无法刷新出title，需要调用该接口
    this.notifyChange()
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    emitter.on({
      eventId: TIME_24_HOUR_SWITCH_OPEN_EVENTS
    }, (eventData: emitter.EventData) => {
      LogUtil.info(`${TAG} emitter aboutToAppear`);
      this.updateStatus();
    });
  }

  updateStatus(): void {
    super.updateStatus();
    this.update24HourResource();
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
    LogUtil.info(`${TAG} aboutToDisappear`);
    emitter.off(TIME_24_HOUR_SWITCH_OPEN_EVENTS);
  }
}
