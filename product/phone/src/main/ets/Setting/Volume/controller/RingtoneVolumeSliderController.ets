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
import systemSoundManager from '@ohos.multimedia.systemSoundManager';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { HiSysEventUtil } from '@ohos/settings.common/src/main/ets/systemEvent/HiSysEventUtil';
import { VibratorUtil } from '@ohos/settings.common/src/main/ets/utils/VibratorUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SimUtils } from '@ohos/settings.common/src/main/ets/utils/SimUtils';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { HiSysVolumeEventGroup } from '@ohos/settings.common/src/main/ets/systemEvent/BehaviorEventConsts';
import { RingtonesUtils } from '../utils/RingtonesUtils';
import {
  AUDIO_VOLUME_TYPE_RINGTONE,
  RINGER_MODE_NORMAL,
  RINGER_MODE_SILENT,
  VolumeAdapter
} from './VolumeAdapter';
import { VolumeSliderController } from './VolumeSliderController';
import { AvplayerController } from './AvplayerController';
import { MAX_VOLUME_SLIDER_VALUE, RingtoneType, RINGTONE_TYPE_SYSTEM, VOLUME_PERCENT } from '../constant/VolumeConstant';

const TAG: string = 'RingtoneVolumeSliderController : ';

export class RingtoneVolumeSliderController extends VolumeSliderController {
  public audioRingMode: number;
  private timerClock: number | null = null;
  private curValue: number = -1;
  private cardType: systemSoundManager.RingtoneType = systemSoundManager.RingtoneType.RINGTONE_TYPE_SIM_CARD_0;
  private systemSoundManagerInstance?: systemSoundManager.SystemSoundManager;
  private ringTonePlay?: systemSoundManager.RingtonePlayer;
  private isPlaying: boolean = false;
  private systemTonePlay?: systemSoundManager.SystemTonePlayer;
  private streamId: number | null = null;
  private isShowNow: boolean = false;

  constructor(ringMode: number) {
    super();
    this.audioRingMode = ringMode;
  }

  init(): void {
    LogUtil.info(`${TAG} init.`);
    super.init();
    super.registerListener();
    try {
      this.systemSoundManagerInstance = systemSoundManager.getSystemSoundManager();
      LogUtil.info(`${TAG} getSystemSoundManager success.`);
    } catch (err) {
      LogUtil.error(`${TAG} getSystemSoundManager catch error. code:${err?.code} message:${err?.message}`);
    }
    if (!RingtonesUtils.isVoiceCapabilityDisable()) {
      this.createRingTonePlayer();
    }
    EventBus.getInstance().on(CommonEventConstant.EVENT_VOLUME_PAGE_SHOW, this.onPageShowCallback);
    EventBus.getInstance().on(CommonEventConstant.EVENT_VOLUME_PAGE_HIDE, this.onPageHideCallback);
    EventBus.getInstance().on(CommonEventConstant.EVENT_VOLUME_AVPLAYER_PLAYING, this.onAvplayerCallback);
  }

  /*
  * pageShow
  */
  private onPageShowCallback = (() => {
    LogUtil.info(`${TAG} onPageShowCallback`);
    this.isShowNow = true;
  });

  /*
   * pageHide 暂停ringTonePlayer播放
   */
  private onPageHideCallback = (() => {
    LogUtil.info(`${TAG} onPageHideCallback`);
    this.isShowNow = false;
    RingtonesUtils.isVoiceCapabilityDisable() ? this.offSystemTonePlayer() : this.stopRingTonePlayer();
    AvplayerController.releaseAvplayer();
  });

  destroy(): void {
    LogUtil.info(`${TAG} destroy.`);
    super.unRegisterListener();
    super.destroy();
    RingtonesUtils.isVoiceCapabilityDisable() ? this.offSystemTonePlayer() : this.releaseRingTonePlayer();
    EventBus.getInstance().detach(CommonEventConstant.EVENT_VOLUME_PAGE_SHOW, this.onPageShowCallback);
    EventBus.getInstance().detach(CommonEventConstant.EVENT_VOLUME_PAGE_HIDE, this.onPageHideCallback);
    EventBus.getInstance().detach(CommonEventConstant.EVENT_VOLUME_AVPLAYER_PLAYING, this.onAvplayerCallback);
  }

  /*
   * 如果avplayer开始播放了 暂停ringTonePlayer播放
   */
  private onAvplayerCallback = (() => {
    LogUtil.info(`${TAG} onAvplayerCallback`);
    RingtonesUtils.isVoiceCapabilityDisable() ? this.offSystemTonePlayer() : this.stopRingTonePlayer();
  });

  onSliderChange(sliderValue: number, sliderChangeMode: number): boolean {
    if (this.timerClock) {
      clearTimeout(this.timerClock);
    }
    if (this.curValue === -1) {
      this.curValue = sliderValue;
    }
    if (this.curValue !== sliderValue && sliderChangeMode === SliderChangeMode.End) {
      this.curValue = sliderValue;
      LogUtil.showInfo(TAG, `cur value is ${sliderValue}`);
       this.startPlayRingtone(sliderValue);
    }
    return super.onSliderChange(sliderValue, sliderChangeMode);
  }

  private startPlayRingtone(targetVolume: number): void {
    HiSysEventUtil.reportDefaultBehaviorEventByUE(HiSysVolumeEventGroup.VOLUME_RINGTONE_CONTROL,
      targetVolume.toString());
    this.timerClock = setTimeout(() => {
      let ringtoneType = SimUtils.getCardSlotNum() > 0 ? RingtoneType.RINGTONE_TYPE_SIM
        : RingtoneType.RINGTONE_TYPE_NOTIFICATION;
      const isLoop = SimUtils.getCardSlotNum() > 0;
      const key: string = RingtonesUtils.getRingtoneKey(true, ringtoneType);
      const flag = PreferencesUtil.getSync(key + '_type', RINGTONE_TYPE_SYSTEM);
      // 先用 PreferencesUtil 来区分系统铃声还是本地铃声
      LogUtil.showInfo(TAG, `onSliderChange. isCustomPlayer:${flag}`);
      if (flag) {
        // 如果avplayer在播放先关闭
        AvplayerController.releaseAvplayer();
        if (this.isShowNow) {
          RingtonesUtils.isVoiceCapabilityDisable() ? this.onSystemTonePlayer() : this.startRingTonePlayer();
        }
      } else {
        RingtonesUtils.getRingtoneUri(ringtoneType, getContext(this)).then((ringToneUri) => {
          const volume: number = Math.floor((targetVolume / MAX_VOLUME_SLIDER_VALUE) * VOLUME_PERCENT) / VOLUME_PERCENT;
          if (this.isShowNow) {
            AvplayerController.avPlayerUrl(volume, this.getVolumeType(), ringToneUri, isLoop);
          }
        });
      }
    }, this.getVolumeDelay());
  }
  onVolumeChange(volumeEvent: audio.VolumeEvent): void {
    super.onVolumeChange(volumeEvent);
    if (volumeEvent?.updateUi) {
      if (this.timerClock) {
        clearTimeout(this.timerClock);
      }
      this.startPlayRingtone(volumeEvent.volume);
    }
  }

  onRingerModeChange(ringMode: audio.AudioRingMode): void {
    LogUtil.info(`${TAG} onRingerModeChange ${ringMode}`);
    if (ringMode < RINGER_MODE_SILENT || ringMode > RINGER_MODE_NORMAL) {
      LogUtil.error(`${TAG} ring mode invalid`);
      return;
    }
    if (this.audioRingMode === ringMode) {
      LogUtil.info(`${TAG} ring mode not change`);
      return;
    }
    let ringtoneType = SimUtils.getCardSlotNum() > 0 ? RingtoneType.RINGTONE_TYPE_SIM
      : RingtoneType.RINGTONE_TYPE_NOTIFICATION;
    const key: string = RingtonesUtils.getRingtoneKey(true, ringtoneType);
    const flag = PreferencesUtil.getSync(key + '_type', RINGTONE_TYPE_SYSTEM);
    LogUtil.showInfo(TAG, `onRingerModeChange. isCustomPlayer:${flag}`);
    if (ringMode !== RINGER_MODE_NORMAL) {
      LogUtil.showInfo(TAG, 'switch slient mode, set value is 0');
      this.curValue = 0;
      if (flag) {
        RingtonesUtils.isVoiceCapabilityDisable() ? this.offSystemTonePlayer() : this.stopRingTonePlayer();
      }
    } else {
      if (flag) {
        RingtonesUtils.isVoiceCapabilityDisable() ? this.onSystemTonePlayer() : this.startRingTonePlayer();
      }
    }
    this.audioRingMode = ringMode;
    this.setSliderValue(this.updateSliderValue());
    EventBus.getInstance().emit('slider_ringTone_volume_mode', ringMode);
  }

  getVolumeType(): number {
    return AUDIO_VOLUME_TYPE_RINGTONE;
  }

  /*
   * 设置音量 根据音量大小来设置声音模式
   * 这里不能用 this.audioRingMode
   * 在 onRingerModeChange 和 onDeviceChange 同时触发的场景下
   * onRingerModeChange 触发要晚于 onDeviceChange 导致 this.audioRingMode 是个旧的 最终会导致声音模式错误
   */
  setSliderValue(sliderValue: number): void {
    const audioRingMode = VolumeAdapter.getInstance().getRingerMode();
    LogUtil.showInfo(TAG, `setSliderValue. audioRingMode:${audioRingMode}`);
    const isSupportVibrate = VibratorUtil.isSupportVibrate();
    if (audioRingMode === RINGER_MODE_NORMAL && isSupportVibrate && !sliderValue) {
      VibratorUtil.vibrateOnVibrateMode(50, 'touch');
    }
    if (this.sliderValue !== sliderValue) {
      this.sliderValue = sliderValue;
      EventBus.getInstance().emit('slider_ringTone_volume_value', sliderValue);
    }
  }

  protected updateSliderValue(): number {
    let volume = VolumeAdapter.getInstance().getVolume(this.getVolumeType());
    if (this.audioRingMode !== RINGER_MODE_NORMAL) {
      volume = 0;
    }
    this.currentVolume = volume;
    return this.convertToVolume(volume);
  }

  /*
   * 创建ringTonePlayer播放器
   */
  private async createRingTonePlayer(): Promise<void> {
    try {
      this.ringTonePlay = await this.systemSoundManagerInstance?.getRingtonePlayer(getContext(this), this.cardType);
      // 流媒体音量 默认1
      await this.ringTonePlay?.configure({ volume: 1, loop: SimUtils.getCardSlotNum() > 0 });
      LogUtil.info(`${TAG} createRingTonePlayer success.`);
    } catch (err) {
      LogUtil.error(`${TAG} createRingTonePlayer catch error. code:${err?.code} message:${err?.message}`);
    }
  }

  /*
   * 启动ringTonePlayer播放器
   */
  private async startRingTonePlayer(): Promise<void> {
    if (this.ringTonePlay && !this.isPlaying && this.isShowNow) {
      try {
        await this.ringTonePlay.start();
        this.isPlaying = true;
        LogUtil.info(`${TAG} startRingTonePlayer success`);
      } catch (err) {
        LogUtil.error(`${TAG} startRingTonePlayer catch error. code:${err?.code} message:${err?.message}`);
      }
    }
  }

  /*
   * 暂停ringTonePlayer播放器
   */
  private async stopRingTonePlayer(): Promise<void> {
    if (this.ringTonePlay && this.isPlaying) {
      try {
        await this.ringTonePlay.stop();
        this.isPlaying = false;
        LogUtil.info(`${TAG} stopRingTonePlayer success.`);
      } catch (err) {
        LogUtil.error(`${TAG} stopRingTonePlayer catch error. code:${err?.code} message:${err?.message}`);
      }
    }
  }

  /*
   * 卸载ringTonePlayer播放器
   */
  private async releaseRingTonePlayer(): Promise<void> {
    if (this.ringTonePlay) {
      try {
        await this.ringTonePlay.release();
        this.ringTonePlay = undefined;
        LogUtil.info(`${TAG} releaseRingTonePlayer success.`);
      } catch (err) {
        LogUtil.error(`${TAG} releaseRingTonePlayer catch error. code:${err?.code} message:${err?.message}`);
      }
    }
  }

  /*
   * 启动systemTonePlayer播放器
   */
  private async onSystemTonePlayer(): Promise<void> {
    if (!this.systemTonePlay) {
      try {
        this.systemTonePlay = await this.systemSoundManagerInstance?.getSystemTonePlayer(getContext(this),
          systemSoundManager.SystemToneType.SYSTEM_TONE_TYPE_NOTIFICATION);
        LogUtil.info(`${TAG} getSystemTonePlayer success.`);
      } catch (err) {
        LogUtil.error(`${TAG} getSystemTonePlayer catch error. code:${err?.code} message:${err?.message}`);
      }
    }
    if (this.systemTonePlay && this.streamId === null) {
      try {
        await this.systemTonePlay.prepare();
        await this.systemTonePlay.start().then((id) => {
          this.streamId = id;
        });
        LogUtil.info(`${TAG} onSystemTonePlayer success.`);
      } catch (err) {
        LogUtil.error(`${TAG} onSystemTonePlayer catch error. code:${err?.code} message:${err?.message}`);
      }
    }
  }

  /*
   * 关闭systemTonePlayer播放器
   */
  private async offSystemTonePlayer(): Promise<void> {
    if (this.systemTonePlay) {
      try {
        if (this.streamId) {
          await this.systemTonePlay.stop(this.streamId);
          this.streamId = null;
        }
        await this.systemTonePlay.release();
        this.systemTonePlay = undefined;
        LogUtil.info(`${TAG} offSystemTonePlayer success.`);
      } catch (err) {
        LogUtil.error(`${TAG} offSystemTonePlayer catch error. code:${err?.code} message:${err?.message}`);
      }
    }
  }
}