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

import { Timer } from '@ohos/settings.common/src/main/ets/utils/Timer';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SECURITY_NOTIFICATION_TIMER_EVENT } from '../constant/Constants';

/* instrument ignore file */
const MIN_COUNT_DOWN_TIME: number = 1000;
const MILE_SECOND_TO_SECOND: number = 1000;
const FREEZING_TIMES: number = 10000;
const COUNT_DOWN_END_TIME: number = 0;
const TAG: string = 'CountDownMessageBaseController: ';


/**
 * 倒计时弹窗-文本信息控制器
 *
 * @since 2024-08-29
 */
export class CountDownMessageController {
  public state: boolean = false;
  public timer: Timer | null = null;
  public title: ResourceStr = '';
  public freezingTime: number = FREEZING_TIMES;
  public isOnEnabled: boolean = false;
  public timeUp: boolean = false;
  public isApproved: boolean = false;

  isButtonEnabled(): boolean {
    return this.isOnEnabled;
  }

  setTitle(timeLeft: number): ResourceStr {
    if (timeLeft > COUNT_DOWN_END_TIME) {
      this.title =
        ResourceUtil.getCapitalPluralStringValueSync($r('app.plural.accessibility_count_down_timer'), timeLeft);
    } else {
      this.title = ResourceUtil.getCapitalStringSync($r('app.string.accessibility_enable'));
    }
    return this.title;
  }

  aboutToAppear(): void {
    this.title = this.setTitle(FREEZING_TIMES / MILE_SECOND_TO_SECOND);
    AppStorage.setOrCreate<string>('user_approval', 'off');
    this.startCountDownTimer();
  }

  aboutToDisappear(): void {
  }

  stopTimer(): void {
    this.timer?.stop();
    this.timer = null;
  }

  startTimer(): void {
    this.timer?.start();
  }

  getFreezingTime(): number {
    return this.freezingTime;
  }

  newTimer(onRefresh: Function): void {
    this.timer = new Timer(MILE_SECOND_TO_SECOND, () => {
      this.freezingTime -= MILE_SECOND_TO_SECOND;
      onRefresh(this.freezingTime);
      if (this.freezingTime <= COUNT_DOWN_END_TIME) {
        this.timer?.stop();
      }
    });
  }

  /**
   * 开始计时，每秒刷新一次倒计时弹窗中的 message 时间信息
   */
  startCountDownTimer(): void {
    this.stopTimer();
    this.newTimer((freezingTime: number) => {
      if (freezingTime >= MIN_COUNT_DOWN_TIME) {
        let timeLeft = this.getCountDownDialogMessage(freezingTime);
        this.setTitle(timeLeft);
        EventBus.getInstance().emit(SECURITY_NOTIFICATION_TIMER_EVENT, this.title);
      } else {
        this.setTitle(COUNT_DOWN_END_TIME);
        this.timeUp = true;
        if (this.isApproved) {
          this.isOnEnabled = true;
        }
        EventBus.getInstance().emit(SECURITY_NOTIFICATION_TIMER_EVENT, this.title);
      }
    });
    this.startTimer();
  }

  getCountDownDialogMessage(millisecondsTime: number): number {
    if (!millisecondsTime) {
      LogUtil.info(`${TAG} millisecondsTime is null`);
      return 0;
    }
    let secondsTime = millisecondsTime / MILE_SECOND_TO_SECOND;
    if (secondsTime > COUNT_DOWN_END_TIME) {
      return secondsTime;
    }
    return 0;
  }

  onCheckboxChange(value: boolean): void {
    if (value !== this.state) {
      LogUtil.info(`${TAG} stateChange: ${value}`);
      this.state = value;
      EventBus.getInstance().emit(SECURITY_NOTIFICATION_TIMER_EVENT, this.title);
    }
  }
}
