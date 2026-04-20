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

/* instrument ignore file */
import { CommonConstants } from '../constants/CommonConstants';
import Log from './Log';

const TAG: string = 'FormatUtil: ';

/**
 * FormatUtil
 *
 * @since 2024-04-25
 */
export default class FormatUtil {
  /**
   * 根据当前剩余时间来获取应该显示的倒计时弹窗提示信息
   *
   * @param millisecondsTime 时间，单位：毫秒
   */
  static getCountDownMessage(millisecondsTime: number): ResourceStr {
    if (!millisecondsTime) {
      Log.error(TAG, `millisecondsTime is null`);
      return CommonConstants.SPACE_PLACE_HOLDER_STRING;
    }
    let secondsTime = millisecondsTime / CommonConstants.MILE_SECOND_TO_SECOND;
    let hour: number = Math.floor(secondsTime / CommonConstants.COUNT_DOWN_ONE_HOUR);
    if (hour > 0) {
      return ($r('app.plural.password_lockscreen_try_after_hours', hour, hour));
    }
    let min: number = Math.floor(secondsTime / CommonConstants.COUNT_DOWN_ONE_MIN);
    if (min > 0) {
      return ($r('app.plural.password_lockscreen_try_after_minutes', min, min));
    }
    let second: number = secondsTime;
    if (second > 0) {
      return ($r('app.plural.password_lockscreen_try_after_seconds', second, second));
    }
    return CommonConstants.SPACE_PLACE_HOLDER_STRING;
  }
}