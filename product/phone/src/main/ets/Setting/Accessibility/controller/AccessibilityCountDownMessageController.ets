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
const TAG: string = 'AccessibilityCountDownMessageController: ';

/**
 * 倒计时弹窗-文本信息控制器
 *
 * @since 2025-09-18
 */
export class AccessibilityCountDownMessageController {
  public timer: Timer | null = null;
  public title: ResourceStr = '';
  public announceTimeleft: ResourceStr = '';
  public freezingTime: number = FREEZING_TIMES;
  public isOnEnabled: boolean = false;
  public timeUp: boolean = false;
  public isApproved: boolean = false;

  private countDownStr: Resource = $r('app.plural.dialog_ok_countdown');
  private finalStr: Resource = $r('app.string.button_title_ok');

  private announceStr: Resource = $r('app.plural.dialog_countdown_time');
 
  constructor(countDownStr: Resource, finalStr: Resource, announceStr: Resource, freezingTime: number) {
    this.countDownStr = countDownStr;
    this.finalStr = finalStr;
    this.announceStr = announceStr;
    this.freezingTime = freezingTime;
  }

  isButtonEnabled(): boolean {
    return this.isOnEnabled;
  }

  setTitle(timeLeft: number): void {
    this.title = timeLeft > COUNT_DOWN_END_TIME ?
      ResourceUtil.getCapitalPluralStringValueSync(this.countDownStr, timeLeft) :
      ResourceUtil.getCapitalStringSync(this.finalStr);
    this.announceTimeleft = timeLeft > COUNT_DOWN_END_TIME ?
      ResourceUtil.getCapitalPluralStringValueSync(this.announceStr, timeLeft) :
      ResourceUtil.getCapitalStringSync(this.finalStr);
  }

  aboutToAppear(): void {
    this.setTitle(this.freezingTime / MILE_SECOND_TO_SECOND);
    AppStorage.setOrCreate<string>('user_approval', 'off');
    this.startCountDownTimer();
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
        let timeLeft: number = this.getCountDownDialogMessage(freezingTime);
        this.setTitle(timeLeft);
        EventBus.getInstance().emit(SECURITY_NOTIFICATION_TIMER_EVENT, this.title, this.announceTimeleft);
      } else {
        this.setTitle(COUNT_DOWN_END_TIME);
        this.timeUp = true;
        if (this.isApproved) {
          this.isOnEnabled = true;
        }
        EventBus.getInstance().emit(SECURITY_NOTIFICATION_TIMER_EVENT, this.title, this.announceTimeleft);
      }
    });
    this.startTimer();
  }

  getCountDownDialogMessage(millisecondsTime: number): number {
    let secondsTime: number = millisecondsTime / MILE_SECOND_TO_SECOND;
    if (secondsTime > COUNT_DOWN_END_TIME) {
      return secondsTime;
    }
    return 0;
  }
}
