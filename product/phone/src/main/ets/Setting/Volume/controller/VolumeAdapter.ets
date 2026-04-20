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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';

const TAG: string = 'VolumeAdapter : ';
const SETTINGS_DATA_VOLUME = 'settings.system.last_volume';
/** 用户/设置内主动设置音量后，在此时间内不根据设备变化回填对应滑块，避免铃声预览等触发的瞬时设备变化覆盖媒体条 */
const VOLUME_SET_DEBOUNCE_MS: number = 2000;
export const AUDIO_VOLUME_TYPE_ALL = audio.AudioVolumeType.ALL;

export const AUDIO_VOLUME_TYPE_RINGTONE = audio.AudioVolumeType.RINGTONE;

export const AUDIO_VOLUME_TYPE_CALL = audio.AudioVolumeType.VOICE_CALL;

export const AUDIO_VOLUME_TYPE_MEDIA = audio.AudioVolumeType.MEDIA;

export const AUDIO_VOLUME_TYPE_ALARM = audio.AudioVolumeType.ALARM;

export const AUDIO_VOLUME_TYPE_VOICE_ASSISTANT = audio.AudioVolumeType.VOICE_ASSISTANT;

export const RINGER_MODE_NORMAL = audio.AudioRingMode.RINGER_MODE_NORMAL;

export const RINGER_MODE_VIBRATE = audio.AudioRingMode.RINGER_MODE_VIBRATE;

export const RINGER_MODE_SILENT = audio.AudioRingMode.RINGER_MODE_SILENT;

export const MIN_VOLUME = 0;

export const MAX_VOLUME = 15;

export const VOLUME_RADIO_EVENT: string[] = ['silent', 'vibrate', 'normal'];

export interface VolumeListener {
  onVolumeChange(volumeEvent: audio.VolumeEvent): void;

  onDeviceChange(audioDeviceDescriptors: audio.AudioDeviceDescriptors): void;

  onRingerModeChange(audioRingMode: audio.AudioRingMode): void;

  getVolumeType(): number;

  getListenerName(): string;
}

/**
 * 音量设置适配管理类
 *
 * @since 2024-06-20
 */
export class VolumeAdapter {
  private static sInstance: VolumeAdapter;
  public hasRegister: boolean = false;
  public audioVolumeManager: audio.AudioVolumeManager;
  public audioRoutingManager: audio.AudioRoutingManager;
  public audioVolumeGroupManager: audio.AudioVolumeGroupManager | null = null;
  public listeners: VolumeListener[] = [];
  /** 最近一次由本应用 setVolume 成功的时刻（用于区分用户主动拖条与设备变化回填） */
  private lastVolumeSetByUserTime: number = 0;
  /** 最近一次由本应用 setVolume 的音量类型 */
  private lastVolumeSetByUserType: number = -1;
  private onVolumeChange = (volumeEvent: audio.VolumeEvent) => {
    if (!volumeEvent) {
      LogUtil.warn(`${TAG} onVolumeChange volumeEvent null`);
      return;
    }
    LogUtil.info(`${TAG} onVolumeChange`);
    this.dispatchVolumeChange(volumeEvent);
  };
  private onDeviceChange = (audioDeviceDescriptors: audio.AudioDeviceDescriptors) => {
    if (!audioDeviceDescriptors) {
      LogUtil.warn(`${TAG} onDeviceChange audioDeviceDescriptors null`);
      return;
    }
    LogUtil.info(`${TAG} onDeviceChange audioDeviceDescriptors`);
    this.dispatchDeviceChange(audioDeviceDescriptors);
  };
  private onRingerModeChange = (audioRingMode: audio.AudioRingMode) => {
    LogUtil.info(`${TAG} onRingerModeChange: ${audioRingMode}`);
    this.dispatchRingerModeChange(audioRingMode);
  };

  private constructor() {
    this.audioVolumeManager = audio.getAudioManager().getVolumeManager();
    this.audioRoutingManager = audio.getAudioManager().getRoutingManager();
    this.initVolumeGroupManager();
  }

  private initVolumeGroupManager(): void {
    try {
      if (!this.audioVolumeGroupManager) {
        this.audioVolumeGroupManager = this.audioVolumeManager.getVolumeGroupManagerSync(audio.DEFAULT_VOLUME_GROUP_ID);
      }
    } catch (error) {
      LogUtil.error(`${TAG} initVolumeGroupManager failed, ${error?.message}`);
    }
  }

  static getInstance(): VolumeAdapter {
    if (!VolumeAdapter.sInstance) {
      VolumeAdapter.sInstance = new VolumeAdapter();
    }
    return VolumeAdapter.sInstance;
  }

  addListener(listener: VolumeListener): void {
    this.listeners.forEach((element: VolumeListener) => {
      if (element.getListenerName() === listener.getListenerName()) {
        LogUtil.info(`${TAG} listener already exist`);
        return;
      }
    })
    this.listeners.push(listener);
  }

  removeListener(listener: VolumeListener): void {
    for (let index = 0; index < this.listeners.length; index++) {
      if (this.listeners[index].getListenerName() === listener.getListenerName()) {
        this.listeners.splice(index, 1);
        return;
      }
    }
  }

  private dispatchVolumeChange(volumeEvent: audio.VolumeEvent): void {
    if (!volumeEvent) {
      return;
    }
    // 整体的监控类，会对事件进行分发
    for (let listener of this.listeners) {
      if (listener?.getVolumeType() === volumeEvent.volumeType || listener?.getVolumeType() === AUDIO_VOLUME_TYPE_ALL) {
        listener?.onVolumeChange(volumeEvent);
      }
    }
  }

  private dispatchDeviceChange(audioDeviceDescriptors: audio.AudioDeviceDescriptors) {
    for (let listener of this.listeners) {
      listener?.onDeviceChange(audioDeviceDescriptors);
    }
  }

  private dispatchRingerModeChange(audioRingMode: audio.AudioRingMode): void {
    for (let listener of this.listeners) {
      listener?.onRingerModeChange(audioRingMode);
    }
  }

  getAudioManager(): audio.AudioVolumeManager {
    return this.audioVolumeManager;
  }

  registerVolumeEvents(): void {
    LogUtil.info(`${TAG} registerVolumeEvents, hasRegister: ${this.hasRegister}`);
    if (!this.hasRegister) {
      try {
        this.audioVolumeManager.on('volumeChange', this.onVolumeChange);
        let renderInfo = {
          content: 0, // 媒体类型
          usage: 0, // 音频流使用类型。
          rendererFlags: 0 // 音频渲染器标志
        } as audio.AudioRendererInfo;
        this.audioRoutingManager.on('preferOutputDeviceChangeForRendererInfo', renderInfo, this.onDeviceChange);
        this.initVolumeGroupManager();
        this.audioVolumeGroupManager?.on('ringerModeChange', this.onRingerModeChange);
      } catch (err) {
        LogUtil.error(`${TAG} register audio manager error: code: ${err?.code}, msg: ${err?.message}`);
      }
      this.hasRegister = true;
      LogUtil.info(`${TAG} registerVolumeEvents end`);
    }
  }

  unregisterVolumeEvents(): void {
    LogUtil.info(`${TAG} unregisterVolumeEvents, hasRegister: ${this.hasRegister}`);
    if (this.hasRegister) {
      try {
        this.audioVolumeManager.off('volumeChange', this.onVolumeChange);
        this.audioRoutingManager.off('preferOutputDeviceChangeForRendererInfo', this.onDeviceChange);
        this.audioVolumeGroupManager?.off('ringerModeChange', this.onRingerModeChange);
      } catch (err) {
        LogUtil.error(`${TAG} unregister audio manager error: code: ${err?.code}, msg: ${err?.message}`);
      }
      this.hasRegister = false;
      LogUtil.info(`${TAG} unregisterVolumeEvents end`);
    }
  }

  getRingerMode(): number {
    this.initVolumeGroupManager();
    let audioRingMode = (this.audioVolumeGroupManager as audio.AudioVolumeGroupManager)?.getRingerModeSync();
    LogUtil.info(`${TAG} audioRingMode: ${audioRingMode}`);
    return audioRingMode;
  }

  async setRingerMode(audioRingMode: number): Promise<void> {
    this.initVolumeGroupManager();
    try {
      await (this.audioVolumeGroupManager as audio.AudioVolumeGroupManager).setRingerMode(audioRingMode);
      LogUtil.info(`${TAG} set RingerMode success ${audioRingMode}`);
    } catch (err) {
      LogUtil.error(`${TAG} set RingerMode failed ${err?.code} msg is ${err?.message}`);
    }
  }

  getVolume(volumeType: number): number {
    this.initVolumeGroupManager();
    let volume: number = 0;
    try {
      volume = (this.audioVolumeGroupManager as audio.AudioVolumeGroupManager)?.getVolumeSync(volumeType);
      LogUtil.info(`${TAG} getVolume: ${volume}`);
    } catch (err) {
      LogUtil.error(`${TAG} getVolumeSync error code:${err?.code},message:${err?.message}`);
    }
    return volume;
  }

  getMinVolume(volumeType: number): number {
    this.initVolumeGroupManager();
    let minVolume: number = 0;
    try {
      minVolume = (this.audioVolumeGroupManager as audio.AudioVolumeGroupManager)?.getMinVolumeSync(volumeType);
      LogUtil.info(`${TAG} getMinVolume: ${minVolume}`);
    } catch (err) {
      LogUtil.error(`${TAG} getMinVolumeSync error code:${err?.code},message:${err?.message}`);
    }
    return minVolume;
  }

  getMaxVolume(volumeType: number): number {
    this.initVolumeGroupManager();
    let maxVolume: number = 0;
    try {
      maxVolume = (this.audioVolumeGroupManager as audio.AudioVolumeGroupManager)?.getMaxVolumeSync(volumeType);
      LogUtil.info(`${TAG} volumeType: ${volumeType} maxVolume: ${maxVolume}`);
    } catch (err) {
      LogUtil.error(`${TAG} getMaxVolumeSync error code:${err?.code},message:${err?.message}`);
    }
    return maxVolume;
  }

  setVolume(volumeType: number, volume: number): void {
    this.initVolumeGroupManager();
    (this.audioVolumeGroupManager as audio.AudioVolumeGroupManager)?.setVolume(volumeType, volume, (err) => {
      if (err) {
        LogUtil.error(`${TAG} failed to set the volume`);
        return;
      }
      this.lastVolumeSetByUserTime = Date.now();
      this.lastVolumeSetByUserType = volumeType;
      LogUtil.info(`${TAG} setVolume success volume=${volume} volumeType=${volumeType}`);
    });
  }
  /** 是否处于「用户刚设置过音量」的防抖窗口内（用于跳过设备变化对媒体条的瞬时回填） */
  isInVolumeSetDebounce(volumeType: number): boolean {
    const elapsed = Date.now() - this.lastVolumeSetByUserTime;
    if (elapsed >= VOLUME_SET_DEBOUNCE_MS) {
      return false;
    }
    return this.lastVolumeSetByUserType === volumeType || this.lastVolumeSetByUserType === AUDIO_VOLUME_TYPE_RINGTONE;
  }
  saveLastVolume(volume: number): void {
    if (volume === MIN_VOLUME) {
      return;
    }
    LogUtil.info(`${TAG} saveLastVolume ${volume}`);
    SettingsDataUtils.setSettingsData(SETTINGS_DATA_VOLUME, volume.toString());
  }

  getLastVolume(): number {
    let volume: string = SettingsDataUtils.getSettingsData(SETTINGS_DATA_VOLUME, '1');
    LogUtil.info(`${TAG} getLastVolume ${volume}`);
    let lastVolume = Number(volume);
    if (lastVolume === MIN_VOLUME) {
      lastVolume++;
    }
    return lastVolume;
  }

  /**
   * 是否静音
   */
  isMute(volumeType: number): boolean {
    let volume = this.getVolume(volumeType);
    LogUtil.info(`${TAG} isMute: ${volume}`);
    return volume <= MIN_VOLUME;
  }

  /**
   * 设置静音
   *
   * @param isMute True : 静音, false: 非静音
   */
  setMute(isMute: boolean): void {
    // 获取当前模式
    let currentMute = (this.audioVolumeGroupManager as audio.AudioVolumeGroupManager)?.getRingerModeSync();
    LogUtil.info(`${TAG} setMute isMute: ${isMute}, currentMute: ${currentMute}`);
    if ((currentMute == RINGER_MODE_SILENT) == isMute) {
      return
    }
    // 设置静音模式
    this.setRingerMode(isMute ? RINGER_MODE_SILENT : RINGER_MODE_NORMAL);
    return;
  }
}