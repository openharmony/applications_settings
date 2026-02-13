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
import { audio } from '@kit.AudioKit';
import { process } from '@kit.ArkTS';
import media from '@ohos.multimedia.media';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { HiSysVolumeEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { MAX_VOLUME_SLIDER_VALUE, MediaType, VOLUME_PERCENT } from '../constant/VolumeConstant';
import { AvplayerController } from './AvplayerController';
import { AUDIO_VOLUME_TYPE_MEDIA, VolumeAdapter } from './VolumeAdapter';
import { VolumeSliderController } from './VolumeSliderController';
import { VolumeUtils } from '../utils/VolumeUtils';

/**
 * small图标的档位
 */
const SMALL_SCALE: number = 3;
/**
 * medium图标的档位
 */
const TAG = 'MediaVolumeSliderController';
const MEDIUM_SCALE: number = 1.5;
let timerClock: number | null = null;

export class MediaVolumeSliderController extends VolumeSliderController {
  private curValue: number = -1;
  private avPlayer: media.AVPlayer | null = null;
  private settingUid: number = process.uid;

  init(): void {
    super.init();
    super.registerListener();
    this.isAvPlayerOn();
  }

  destroy(): void {
    super.unRegisterListener();
    super.destroy();
  }

  getVolumeType(): number {
    return AUDIO_VOLUME_TYPE_MEDIA;
  }

  getMaxVolume(): number {
    this.maxVolume = VolumeAdapter.getInstance().getMaxVolume(this.getVolumeType());
    return this.maxVolume;
  }

  setSliderValue(sliderValue: number): void {
    if (this.sliderValue === sliderValue) {
      return;
    }

    let iconValue: number = MediaType.MEDIA_OFF;
    if (sliderValue === 0) {
      iconValue = MediaType.MEDIA_OFF;
    } else if (sliderValue > 0 && sliderValue <= this.maxVolume / SMALL_SCALE) {
      iconValue = MediaType.MEDIA_SMALL;
    } else if (sliderValue > this.maxVolume / SMALL_SCALE && sliderValue <= this.maxVolume / MEDIUM_SCALE) {
      iconValue = MediaType.MEDIA_MEDIUM;
    } else {
      iconValue = MediaType.MEDIA_ON;
    }

    this.sliderValue = sliderValue;
    EventBus.getInstance().emit('slider_media_volume_mode', iconValue);
    EventBus.getInstance().emit('slider_media_volume_value', sliderValue);
  }

  onSliderChange(sliderValue: number, sliderChangeMode: number, typeNum?: number): boolean {
    this.clearTimeout();
    if (this.curValue === -1) {
      this.curValue = sliderValue;
    }
    if (this.curValue !== sliderValue && sliderChangeMode === SliderChangeMode.End) {
      this.curValue = sliderValue;
      this.startPlayRingtone(sliderValue);
    }
    return super.onSliderChange(sliderValue, sliderChangeMode);
  }

  private startPlayRingtone(targetVolume: number): void {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysVolumeEventGroup.VOLUME_MEDIA_CONTROL, String(targetVolume));
    EventBus.getInstance().emit(CommonEventConstant.EVENT_VOLUME_AVPLAYER_PLAYING);
    if (this.avPlayer !== null) {
      LogUtil.info(`${TAG} avPlayer is not null`);
      this.isAvPlayerOn();
    }
    if (!VolumeUtils.isAudioRunning(this.settingUid)) {
      this.startPlayTimeout(targetVolume);
    }
  }

  onVolumeChange(volumeEvent: audio.VolumeEvent): void {
    super.onVolumeChange(volumeEvent);
    if (volumeEvent?.updateUi) {
      this.clearTimeout();
      this.startPlayRingtone(volumeEvent.volume);
    }
  }

  async isAvPlayerOn() {
    // 初始化 Avplayer 创建avPlayer实例对象
    try {
      this.avPlayer = await media.createAVPlayer();
    } catch (error) {
      LogUtil.showError(TAG, `createAVPlayer error, code: ${error?.code}, message: ${error?.message}`);
      return;
    }
  }

  startPlayTimeout(sliderValue: number) {
    timerClock = setTimeout(() => {
      AvplayerController.avPlayerFdSrcDemo(Math.floor((sliderValue / MAX_VOLUME_SLIDER_VALUE) * VOLUME_PERCENT) /
        VOLUME_PERCENT, this.getVolumeType(), 'volume_adjust.wav');
      this.clearTimeout();
    }, this.getVolumeDelay());
  }

  private clearTimeout(): void {
    if (timerClock) {
      clearTimeout(timerClock);
      timerClock = null;
    }
  }
}