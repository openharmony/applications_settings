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
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { HiSysVolumeGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { VibratorUtil } from '@ohos/settings.common/src/main/ets/utils/VibratorUtil';
import { AudioRingMode } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AUDIO_VOLUME_TYPE_MEDIA, RINGER_MODE_VIBRATE, VolumeAdapter } from './VolumeAdapter';
/* instrument ignore file */
const isSupportVibrate = VibratorUtil.isSupportVibrate();
const TAG: string = 'VolumeModeWindowController : ';
const VIBRATE_DURATION: number = 50;
const VOLUME_RADIO_VOICE: Resource[] = [
  $r('app.string.ringer_mode_slient'),
  $r('app.string.ringer_mode_vibrate'),
  $r('app.string.ringer_mode_normal')
]

export class VolumeModeWindowController {
  public audioRingMode: AudioRingMode = AudioRingMode.RINGER_MODE_NORMAL;
  public volumeModeVibrateShow: boolean = true;

  init(): void {
    const currentRingMode = VolumeAdapter.getInstance().getRingerMode();
    if (!isSupportVibrate) {
      this.volumeModeVibrateShow = false;
    }
    if (currentRingMode === 1) {
      this.audioRingMode = isSupportVibrate ? 1 : 0;
    } else {
      this.audioRingMode = currentRingMode;
    }
  }

  setAudioRingMode(ringMode: AudioRingMode): void {
    if (this.audioRingMode === ringMode) {
      LogUtil.showInfo(TAG, 'the audio ring mode is same, not set.');
      return;
    }
    this.audioRingMode = ringMode;
    const mediaVolumeBefore = VolumeAdapter.getInstance().getVolume(AUDIO_VOLUME_TYPE_MEDIA);
    VolumeAdapter.getInstance().setRingerMode(ringMode).then(() => {
      VolumeAdapter.getInstance().setVolume(AUDIO_VOLUME_TYPE_MEDIA, mediaVolumeBefore);
    }).catch(() => {
      VolumeAdapter.getInstance().setVolume(AUDIO_VOLUME_TYPE_MEDIA, mediaVolumeBefore);
    });
    LogUtil.showInfo(TAG, `set audio ring mode: ${this.audioRingMode}`);
    if (ringMode === RINGER_MODE_VIBRATE) {
      VibratorUtil.vibrateOnVibrateMode(VIBRATE_DURATION, 'touch');
    }
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysVolumeGroup.VOLUME_MODE_CHANGE, String(ringMode));
    AccessibilityUtils.announceText(VOLUME_RADIO_VOICE[ringMode]);
  }
}