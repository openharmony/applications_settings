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
import audio from '@ohos.multimedia.audio';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  AUDIO_VOLUME_TYPE_ALL,
  MAX_VOLUME,
  AUDIO_VOLUME_TYPE_MEDIA,
  MIN_VOLUME,
  VolumeAdapter,
  VolumeListener
} from './VolumeAdapter';

const SLIDER_VALUE_0: number = 0;
const SLIDER_STEP_1: number = 1;
const SET_VOLUME_DELAY = 210;
const TAG: string = 'VolumeSliderController : ';

export class VolumeSliderController implements VolumeListener {
  public maxVolume: number = MAX_VOLUME;
  protected currentVolume: number = 0;
  protected sliderValue: number = SLIDER_VALUE_0;
  private playRequest: number = 0;

  private pageShowCallback = () => {
    this.setSliderValue(this.updateSliderValue());
  }

  init(): void {
    this.setSliderValue(this.updateSliderValue());
    EventBus.getInstance().on(CommonEventConstant.EVENT_VOLUME_PAGE_SHOW, this.pageShowCallback);
  }

  destroy():void {
    EventBus.getInstance().detach(CommonEventConstant.EVENT_VOLUME_PAGE_SHOW, this.pageShowCallback);
  }

  onVolumeChange(volumeEvent: audio.VolumeEvent): void {
    if (!volumeEvent) {
      return;
    }
    if (this.currentVolume === volumeEvent.volume) {
      LogUtil.info(`${TAG} same volume`);
      return;
    }
    LogUtil.showInfo(TAG, 'onVolumeChange');
    this.currentVolume = volumeEvent.volume;
    this.setSliderValue(this.convertToVolume(this.currentVolume));
  }

  onDeviceChange(audioDeviceDescriptors: audio.AudioDeviceDescriptors): void {
    if (!audioDeviceDescriptors) {
      return;
    }
    const volumeType = this.getVolumeType();
    if (volumeType === AUDIO_VOLUME_TYPE_MEDIA &&
    VolumeAdapter.getInstance().isInVolumeSetDebounce(AUDIO_VOLUME_TYPE_MEDIA)) {
      LogUtil.info(`${TAG} onDeviceChange skip media refill, user recently set volume (ringtone/media)`);
      return;
    }
    let volume = VolumeAdapter.getInstance().getVolume(volumeType);
    LogUtil.info(`${TAG} onDeviceChange getVolume type: ${volumeType} volume: ${volume}`);
    if (this.currentVolume === volume) {
      LogUtil.info(`${TAG} same volume, return : ${this.currentVolume}`);
      return;
    }
    this.currentVolume = volume;
    LogUtil.info(`${TAG} onDeviceChange : ${volume}`);
    this.setSliderValue(this.convertToVolume(volume));
  }

  onRingerModeChange(audioRingMode: audio.AudioRingMode): void {
    LogUtil.showInfo(TAG, 'onRingerModeChange');
  }

  getVolumeType(): number {
    return AUDIO_VOLUME_TYPE_ALL;
  }

  getListenerName(): string {
    return 'VolumeSliderController';
  }

  getSliderMin(): number {
    return MIN_VOLUME;
  }

  getSliderMax(): number {
    this.getMaxVolume();
    return this.maxVolume;
  }

  getSliderStep(): number {
    return SLIDER_STEP_1;
  }

  getSliderValue(): number {
    return this.sliderValue;
  }

  protected registerListener(): void {
    VolumeAdapter.getInstance().addListener(this);
  }

  protected unRegisterListener(): void {
    VolumeAdapter.getInstance().removeListener(this);
  }

  protected setVolume(volume: number): void {
    this.currentVolume = volume;
    VolumeAdapter.getInstance().setVolume(this.getVolumeType(), volume);
  }

  protected getMaxVolume(): number {
    this.maxVolume = VolumeAdapter.getInstance().getMaxVolume(this.getVolumeType())
    return this.maxVolume;
  }

  protected getVolumeDelay(): number {
    return SET_VOLUME_DELAY;
  }

  protected updateSliderValue(): number {
    let volume = VolumeAdapter.getInstance().getVolume(this.getVolumeType());
    this.currentVolume = volume;
    return this.convertToVolume(volume);
  }

  protected setSliderValue(sliderValue: number): void {
    if (this.sliderValue !== sliderValue) {
      this.sliderValue = sliderValue;
    }
  }

  protected convertToVolume(sliderValue: number): number {
    let volume = Math.round(sliderValue);
    volume = Math.max(MIN_VOLUME, volume);
    volume = Math.min(this.maxVolume, volume);
    return volume;
  }

  protected async audioPlayerControl(): Promise<void> {
    if (this.playRequest > 1) {
      LogUtil.info(`${TAG} too quick, return`);
      return;
    }
    this.playRequest++;
  }

  onSliderChange(sliderValue: number, sliderChangeMode: number): boolean {
    LogUtil.info(`${TAG} setValue [sliderValue:${sliderValue}, sliderChangeMode:${sliderChangeMode}]`);
    this.setValueAndPlayAudio(sliderValue);
    this.setSliderValue(sliderValue);
    return true;
  }

  private setValueAndPlayAudio(sliderValue: number) {
    let volume = this.convertToVolume(sliderValue);
    this.setVolume(volume);
    if (this.currentVolume !== MIN_VOLUME) {
      this.audioPlayerControl();
    }
  }
}