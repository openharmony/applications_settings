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

import type { BusinessError } from '@ohos.base';
import { LogUtil } from './LogUtil';
import systemParameterEnhance from '@ohos.systemParameterEnhance';

/* instrument ignore file */
const TAG: string = 'VibratorUtil : ';
const CONST_VIBRATOR_SUPPORT_VIBRATOR = 'const.vibrator.support_vibrator';
const CONST_SETTINGS_RINGTONE_VIBRATION_ADAPTIVE: string = 'const.settings.ringtone_vibration_adaptive';

type Usage = 'unknown' | 'alarm' | 'ring' | 'notification' | 'communication' |
'touch' | 'media' | 'physicalFeedback' | 'simulateReality';

export class VibratorUtil {
  static vibrateOnVibrateMode(duration: number, usage: Usage, effectStr?: string): void {
    LogUtil.info(`${TAG} vibrateOnVibrateMode ${duration} ${usage}`);
    import('@ohos.vibrator').then(vibrator => {
      vibrator.default.startVibration({
        type: 'preset',
        effectId: effectStr ?? 'haptic.slide',
        count: 1,
      }, {
        id: 0,
        usage: usage
      }).then(() => {
        LogUtil.info(`${TAG} Succeeded to start vibrate`);
      }, (error: BusinessError) => {
        LogUtil.error(`${TAG} Failed to start vibrate. Code: ${error.code}, message: ${error.message}`);
      });
    });
  }

  /**
   * 是否支持铃声振动自适应
   *
   * @returns true: 支持； false：不支持
   */
  static isSupportRingtoneVibrationAdaptive(): boolean {
    try {
      const isRingtoneVibrationAdaptiveSupport: string =
        systemParameterEnhance.getSync(CONST_SETTINGS_RINGTONE_VIBRATION_ADAPTIVE, 'true');
      LogUtil.info(`${TAG} isRingtoneVibrationAdaptiveSupport: ${isRingtoneVibrationAdaptiveSupport}`);
      return isRingtoneVibrationAdaptiveSupport === 'true';
    } catch (err) {
      LogUtil.error(`${TAG} isRingtoneVibrationAdaptiveSupport error code ${err?.code}, message ${err?.message}`);
    }
    return false;
  }

  /**
   * 校验手机是否支持震动
   */
  static isSupportVibrate(): boolean {
    try {
      const isSupportVibrate = systemParameterEnhance.getSync(CONST_VIBRATOR_SUPPORT_VIBRATOR, 'true');
      LogUtil.showInfo(TAG, `isSupportVibrate: ${isSupportVibrate}`);
      return isSupportVibrate === 'true';
    } catch (err) {
      LogUtil.showError(TAG, `showToast error ${err?.code}`);
      return false;
    }
  }

  /**
   * 预置振动效果触发马达振动
   */
  public static startPresetVibration(): void {
    import('@ohos.vibrator').then(vibrator => {
      try {
        vibrator.default.startVibration({
          type: 'preset',
          effectId: 'haptic.slide',
          count: 1,
        }, {
          id: 0,
          usage: 'alarm'
        }, (error: BusinessError) => {
          if (error) {
            LogUtil.error(`${TAG} Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
            return;
          }
          LogUtil.info(`${TAG} Succeed in starting vibration`);
        });
      } catch (err) {
        LogUtil.error(`${TAG} An unexpected error occurred. Code: ${err?.code}, message: ${err?.message}`);
      }
    });
  }
}