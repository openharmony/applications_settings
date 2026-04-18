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

import { LogUtil } from './LogUtil';

const TAG = 'settings_Timer';

/**
 * 定时器的回调
 *
 * @since 2022-03-21
 */

type TimerCallback = () => void // 没有入参。如果存在入参改为 <T>(data:T) => void

/**
 * 定时器
 *
 * @since 2022-03-21
 */
export class Timer {
  private taskId: number | undefined;
  public isTiming: boolean = false;

  public interval: number;
  public callback : TimerCallback;

  constructor(interval: number, callback : TimerCallback) {
    this.interval = interval ?? 0;
    this.callback = callback;
  }

  /**
   * 重新启动定时器
   */
  restart() {
    this.stop();
    this.start();
  }

  /**
   * 启动定时器
   */
  start() {
    if (!this.isTiming) {
      this.isTiming = true;
      this.taskId = setInterval(() => {
        LogUtil.info(TAG + 'callback start');
        this.callback();
      }, this.interval);
    }
  }

  /**
   * 停止定时器
   */
  stop() {
    if (this.isTiming) {
      this.isTiming = false;
      clearInterval(this.taskId);
    }
  }
}
