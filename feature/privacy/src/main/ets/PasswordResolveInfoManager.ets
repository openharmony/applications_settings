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

import { FREEZING_TIMES_DEFAULT, REMAIN_TIMES_DEFAULT } from '@ohos/settings.common/src/main/ets/utils/PasswordUtil';
/* instrument ignore file */
import { Timer } from '@ohos/settings.common/src/main/ets/utils/Timer';

/**
 * 定时器的时间间隔，单位：毫秒
 */
export const TIME_INTERVAL = 1000;

export class PasswordResolveInfoManager {
  private static passwordResolveInfoManager: PasswordResolveInfoManager | null = null;
  public tag: string = 'PasswordResolveInfoManager : ';

  /**
 * 全局的 PinToken 信息
 */
  private globalPinToken: string = '';

  /**
 * 被检查过的密码
 */
  private checkedPassword: string = '';

  /**
   * 剩余可校验次数
   */
  private remainTimes: number = REMAIN_TIMES_DEFAULT;

  /**
   * 倒计时定时器
   */
  private timer: Timer | null = null;

  /**
   * 冻结时间，单位：毫秒
   */
  private freezingTime: number = FREEZING_TIMES_DEFAULT;

  /**
   * 私有构造方法
   */
  private constructor() {
  }

  /**
   * 获取对象实例（单例）
   */
  static getInstance(): PasswordResolveInfoManager {
    if (!Boolean(AppStorage.get<PasswordResolveInfoManager>('passwordResolveInfoManager') as PasswordResolveInfoManager).valueOf()) {
      AppStorage.setOrCreate<PasswordResolveInfoManager>('passwordResolveInfoManager', new PasswordResolveInfoManager());
    }
    return AppStorage.get<PasswordResolveInfoManager>('passwordResolveInfoManager') as PasswordResolveInfoManager;
  }

  /**
   * 释放数据资源
   */
  release(): void {
    this.freezingTime = FREEZING_TIMES_DEFAULT;
    this.remainTimes = REMAIN_TIMES_DEFAULT;
    this.timer = null;
    this.globalPinToken = '';
    this.checkedPassword = '';
  }

  setGlobalPinToken(newGlobalPinToken: string): void {
    this.globalPinToken = newGlobalPinToken;
  }

  setCheckedPassword(newCheckedPassword: string): void {
    this.checkedPassword = newCheckedPassword;
  }

  setRemainTimes(newRemainTimes: number): void {
    this.remainTimes = newRemainTimes;
  }

  setFreezingTime(newFreezingTime: number): void {
    this.freezingTime = newFreezingTime;
  }

  getGlobalPinToken(): string {
    return this.globalPinToken;
  }

  getCheckedPassword(): string {
    return this.checkedPassword;
  }

  getRemainTimes(): number {
    return this.remainTimes;
  }

  getFreezingTime(): number {
    return this.freezingTime;
  }

  stopTimer(): void {
    this.timer?.stop();
    this.timer = null;
  }

  startTimer(): void {
    this.timer?.start();
  }

  newTimer(onRefresh: (freezingTime: number) => void): void {
    this.timer = new Timer(TIME_INTERVAL, () => {
      this.freezingTime -= TIME_INTERVAL;
      onRefresh(this.freezingTime);
      if (this.freezingTime <= 0) {
        this.timer?.stop();
      }
    });
  }
}